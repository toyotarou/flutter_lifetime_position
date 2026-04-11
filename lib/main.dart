import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_task/background_task.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// 最終送信時刻をファイルで管理（プラグイン不要・Isolate をまたいで有効）
const String _packageName = 'com.example.flutter_lifetime_position';
final File _lastSentFile = File('/data/user/0/$_packageName/cache/last_sent_ms.txt');

// 位置情報の送信間隔（ミリ秒）
// TODO: 将来的にユーザーごとの設定値を API から取得して切り替える
const int kLocationIntervalMs = 10000;

// バックグラウンドで位置情報を受け取るハンドラ
// このアノテーションが必須（別 Isolate で動くため）
@pragma('vm:entry-point')
void backgroundHandler(Location data) {
  // ignore: always_specify_types
  Future(() async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    // 前回送信時刻をファイルから読む
    int lastSentMs = 0;
    try {
      if (_lastSentFile.existsSync()) {
        lastSentMs = int.tryParse(_lastSentFile.readAsStringSync().trim()) ?? 0;
      }
    } catch (_) {}

    if (nowMs - lastSentMs < kLocationIntervalMs) {
      return;
    }

    // 先に書き込んで重複送信を防ぐ
    try {
      _lastSentFile.writeAsStringSync(nowMs.toString());
    } catch (_) {}

    final DateTime now = DateTime.fromMillisecondsSinceEpoch(nowMs);
    final String date =
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final String time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';

    final Map<String, String> body = <String, String>{
      'date': date,
      'time': time,
      'user_id': '10000001',
      'latitude': data.lat.toString(),
      'longitude': data.lng.toString(),
    };

    debugPrint('[$date $time] lat=${data.lat}, lng=${data.lng} → API送信');

    try {
      final http.Response response = await http.post(
        Uri.parse('http://49.212.175.205:8081/api/insertUserGeoloc'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint('API response: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('API error: $e');
    }
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundTask.instance.setBackgroundHandler(backgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lifetime Position',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 表示用の座標
  double? _latitude;
  double? _longitude;
  DateTime? _lastUpdated;

  // stream から届いた最新座標（Timer でまとめて表示）
  Location? _pendingLocation;

  late final StreamSubscription<Location> _locationSub;
  late final StreamSubscription<StatusEvent> _statusSub;
  Timer? _displayTimer;

  String _statusText = '停止中';
  bool _isRunning = false;

  static const int _intervalSeconds = 10;

  @override
  void initState() {
    super.initState();

    // 位置情報ストリームの購読
    _locationSub = BackgroundTask.instance.stream.listen((Location event) {
      _pendingLocation = event;
    });

    // ステータスイベントの購読
    _statusSub = BackgroundTask.instance.status.listen((StatusEvent event) {
      setState(() {
        _statusText = 'status: ${event.status.value}  ${event.message}';
      });
    });

    // 起動時に自動開始
    Future(() async {
      if (Platform.isAndroid) {
        await Permission.notification.request();
        await BackgroundTask.instance.setAndroidNotification(title: '位置情報取得中', message: 'バックグラウンドで現在位置を記録しています');
      }
      await _startTracking();
    });

    _startTimers();
  }

  void _startTimers() {
    _displayTimer = Timer.periodic(const Duration(seconds: _intervalSeconds), (_) {
      if (_pendingLocation != null) {
        setState(() {
          _latitude = _pendingLocation!.lat;
          _longitude = _pendingLocation!.lng;
          _lastUpdated = DateTime.now();
          _pendingLocation = null;
        });
      }
    });
  }

  void _stopTimers() {
    _displayTimer?.cancel();
  }

  @override
  void dispose() {
    _locationSub.cancel();
    _statusSub.cancel();
    _stopTimers();
    super.dispose();
  }

  // 位置情報取得を開始
  Future<void> _startTracking() async {
    final PermissionStatus location = await Permission.location.request();
    final PermissionStatus always = await Permission.locationAlways.request();

    if (location.isGranted && always.isGranted) {
      await BackgroundTask.instance.start(
        isEnabledEvenIfKilled: true,
        updateIntervalInMilliseconds: kLocationIntervalMs.toDouble(),
      );
      _stopTimers();
      _startTimers();
      setState(() {
        _isRunning = true;
        _statusText = '取得中...';
      });
    } else {
      setState(() => _statusText = '位置情報のパーミッションが必要です');
    }
  }

  // 位置情報取得を停止
  Future<void> _stopTracking() async {
    await BackgroundTask.instance.stop();
    _stopTimers();
    setState(() {
      _isRunning = false;
      _statusText = '停止中';
    });
  }

  String _formatCoord(double? value) {
    if (value == null) return '---';
    return value.toStringAsFixed(6);
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '---';
    final String h = dt.hour.toString().padLeft(2, '0');
    final String m = dt.minute.toString().padLeft(2, '0');
    final String s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Lifetime Position', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 座標表示カード
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: <Widget>[
                    const Text('現在位置', style: TextStyle(color: Colors.tealAccent, fontSize: 14, letterSpacing: 2)),
                    const SizedBox(height: 20),
                    _CoordRow(label: 'Latitude', value: _formatCoord(_latitude)),
                    const SizedBox(height: 12),
                    _CoordRow(label: 'Longitude', value: _formatCoord(_longitude)),
                    const SizedBox(height: 20),
                    Text(
                      '最終更新: ${_formatTime(_lastUpdated)}',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ステータス
              Text(
                _statusText,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 開始 / 停止ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _isRunning ? null : _startTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.withOpacity(0.8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('開始', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _stopTracking : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('停止', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 座標1行の表示ウィジェット
class _CoordRow extends StatelessWidget {
  const _CoordRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
