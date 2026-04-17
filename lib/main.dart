import 'dart:convert';
import 'dart:io';

import 'package:background_task/background_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// ファイルパス（プラグイン不要・Isolate をまたいで有効）
const String _packageName = 'com.example.flutter_lifetime_position';
const String _cachePath = '/data/user/0/$_packageName/cache';
final File _lastSentFile = File('$_cachePath/last_sent_ms.txt');
final File _intervalMsFile = File('$_cachePath/interval_ms.txt');
final File _userIdFile = File('$_cachePath/user_id.txt');

// バックグラウンドで位置情報を受け取るハンドラ
// このアノテーションが必須（別 Isolate で動くため）
@pragma('vm:entry-point')
void backgroundHandler(Location data) {
  // ignore: always_specify_types
  Future(() async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    // 送信間隔をファイルから読む（ログイン時に保存された kankaku × 1000）
    int intervalMs = 60000; // デフォルト 60 秒
    try {
      if (_intervalMsFile.existsSync()) {
        intervalMs = int.tryParse(_intervalMsFile.readAsStringSync().trim()) ?? intervalMs;
      }
    } catch (_) {}

    // 前回送信時刻をファイルから読む
    int lastSentMs = 0;
    try {
      if (_lastSentFile.existsSync()) {
        lastSentMs = int.tryParse(_lastSentFile.readAsStringSync().trim()) ?? 0;
      }
    } catch (_) {}

    if (nowMs - lastSentMs < intervalMs) {
      return;
    }

    // 先に書き込んで重複送信を防ぐ
    try {
      _lastSentFile.writeAsStringSync(nowMs.toString());
    } catch (_) {}

    // user_id をファイルから読む
    String userId = '';
    try {
      if (_userIdFile.existsSync()) {
        userId = _userIdFile.readAsStringSync().trim();
      }
    } catch (_) {}

    if (userId.isEmpty) {
      return; // 未ログインなら送信しない
    }

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
      'user_id': userId,
      'latitude': data.lat.toString(),
      'longitude': data.lng.toString(),
    };

    debugPrint('[$date $time] user=$userId lat=${data.lat}, lng=${data.lng} → API送信');

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundTask.instance.setBackgroundHandler(backgroundHandler);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');
  final int? intervalMs = prefs.getInt('intervalMs');
  final bool isLoggedIn = userId != null && intervalMs != null;

  runApp(
    ProviderScope(
      child: MyApp(isLoggedIn: isLoggedIn, userId: userId, intervalMs: intervalMs),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn, this.userId, this.intervalMs});

  final bool isLoggedIn;
  final String? userId;
  final int? intervalMs;

  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ここにーた',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
      ),
      home: isLoggedIn ? HomeScreen(userId: userId!, intervalMs: intervalMs!) : const LoginScreen(),
    );
  }
}
