import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../models/login_user_model.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    await Permission.location.request();
    await Permission.locationAlways.request();
  }

  Future<void> _onLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'IDとパスワードを入力してください');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = '';
    });

    try {
      final http.Response response = await http.get(
        Uri.parse('http://49.212.175.205:8081/api/getLifetimePositionLogin'),
      );

      if (response.statusCode != 200) {
        setState(() => _errorText = 'サーバーエラー (${response.statusCode})');
        return;
      }

      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = json['data'] as List<dynamic>;
      final List<LoginUserModel> users = data
          .map((dynamic e) => LoginUserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final LoginUserModel? matched = users
          .where((LoginUserModel u) => u.email == email && u.password == password)
          .firstOrNull;

      if (matched == null) {
        setState(() => _errorText = 'メールアドレスまたはパスワードが違います');
        return;
      }

      // user_id と kankaku（ms）をファイルに保存（backgroundHandler が参照）
      const String cachePath = '/data/user/0/com.example.flutter_lifetime_position/cache';
      await File('$cachePath/user_id.txt').writeAsString(matched.userId.toString());
      await File('$cachePath/interval_ms.txt').writeAsString((matched.kankaku * 1000).toString());

      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(userId: matched.userId.toString(), intervalMs: matched.kankaku * 1000),
        ),
      );
    } catch (e) {
      setState(() => _errorText = '通信エラー: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Lifetime Position',
                style: TextStyle(color: Colors.tealAccent, fontSize: 24, fontWeight: FontWeight.w300, letterSpacing: 2),
              ),
              const SizedBox(height: 48),

              // メールアドレス
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // パスワード
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.tealAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // エラーメッセージ
              if (_errorText.isNotEmpty)
                Text(
                  _errorText,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 16),

              // ログインボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('ログイン', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
