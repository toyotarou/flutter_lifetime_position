import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_task/background_task.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/position_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId, required this.intervalMs});

  final String userId;
  final int intervalMs;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location? _pendingLocation;

  late final StreamSubscription<Location> _locationSub;
  late final StreamSubscription<StatusEvent> _statusSub;
  Timer? _displayTimer;

  String _statusText = '停止中';
  bool _isRunning = false;

  List<PositionModel> _positionList = <PositionModel>[];
  bool _isFetchingList = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _locationSub = BackgroundTask.instance.stream.listen((Location event) {
      _pendingLocation = event;
      // insert 完了を待ってからリスト取得（3秒後）
      // ignore: always_specify_types
      Future.delayed(const Duration(seconds: 3), _fetchPositionList);
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

    _fetchPositionList();
    _startTimers();
  }

  void _startTimers() {
    _displayTimer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {
      if (_pendingLocation != null) {
        _pendingLocation = null;
      }
    });
  }

  Future<void> _fetchPositionList() async {
    if (_isFetchingList) {
      return;
    }

    _isFetchingList = true;
    try {
      final http.Response response = await http.get(Uri.parse('http://49.212.175.205:8081/api/getLifetimeAllPosition'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = json['data'] as List<dynamic>;
        final int loginUserId = int.tryParse(widget.userId) ?? -1;
        final List<PositionModel> list = data
            .map((dynamic e) => PositionModel.fromJson(e as Map<String, dynamic>))
            .where((PositionModel p) => p.userId == loginUserId)
            .toList();
        if (mounted) {
          setState(() => _positionList = list);
        }
      }
    } catch (e) {
      debugPrint('getLifetimeAllPosition error: $e');
    } finally {
      _isFetchingList = false;
    }
  }

  void _stopTimers() {
    _displayTimer?.cancel();
  }

  @override
  void dispose() {
    _locationSub.cancel();
    _statusSub.cancel();
    _stopTimers();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startTracking() async {
    await BackgroundTask.instance.start(updateIntervalInMilliseconds: widget.intervalMs.toDouble());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Lifetime Position', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          // ステータス＋ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: <Widget>[
                Text(
                  _statusText,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _startTracking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.withOpacity(0.8),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('開始', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _stopTracking : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.stop),
                      label: const Text('停止', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchPositionList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('再読込', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(72, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.keyboard_arrow_up),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(72, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 履歴リストヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('送信履歴', style: TextStyle(color: Colors.tealAccent, fontSize: 13, letterSpacing: 1)),
                Text('${_positionList.length} 件', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),

          // 履歴リスト
          Expanded(
            child: _positionList.isEmpty
                ? Center(
                    child: Text('データなし', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _positionList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final PositionModel item = _positionList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: <Widget>[
                            // 日時
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.dateLabel,
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                                  ),
                                  Text(
                                    item.time,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 緯度経度
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    'Lat: ${item.latitude}',
                                    style: const TextStyle(color: Colors.tealAccent, fontSize: 12),
                                  ),
                                  Text(
                                    'Lng: ${item.longitude}',
                                    style: TextStyle(color: Colors.tealAccent.withOpacity(0.7), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
