import 'dart:async';
import 'dart:io';

import 'package:background_task/background_task.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId, required this.intervalMs});

  final String userId;
  final int intervalMs;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _latitude;
  double? _longitude;
  DateTime? _lastUpdated;

  Location? _pendingLocation;

  late final StreamSubscription<Location> _locationSub;
  late final StreamSubscription<StatusEvent> _statusSub;
  Timer? _displayTimer;

  String _statusText = '停止中';
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();

    _locationSub = BackgroundTask.instance.stream.listen((Location event) {
      _pendingLocation = event;
    });

    _statusSub = BackgroundTask.instance.status.listen((StatusEvent event) {
      setState(() {
        _statusText = 'status: ${event.status.value}  ${event.message}';
      });
    });

    // 起動時に自動開始（パーミッションはログイン画面で取得済み）
    // ignore: always_specify_types
    Future(() async {
      if (Platform.isAndroid) {
        await BackgroundTask.instance.setAndroidNotification(title: '位置情報取得中', message: 'バックグラウンドで現在位置を記録しています');
      }
      await _startTracking();
    });

    _startTimers();
  }

  void _startTimers() {
    _displayTimer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {
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

  Future<void> _startTracking() async {
    await BackgroundTask.instance.start(
      updateIntervalInMilliseconds: widget.intervalMs.toDouble(),
    );
    _stopTimers();
    _startTimers();
    setState(() {
      _isRunning = true;
      _statusText = '取得中...';
    });
  }

  Future<void> _stopTracking() async {
    await BackgroundTask.instance.stop();
    _stopTimers();
    setState(() {
      _isRunning = false;
      _statusText = '停止中';
    });
  }

  String _formatCoord(double? value) {
    if (value == null) {
      return '---';
    }
    return value.toStringAsFixed(6);
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) {
      return '---';
    }
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

              Text(
                _statusText,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

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
