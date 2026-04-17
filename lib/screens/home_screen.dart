import 'dart:async';
import 'dart:io';

import 'package:background_task/background_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/app_colors.dart';
import '../controllers/app_param/app_param.dart';
import '../data/position_repository.dart';
import 'parts/calendar_grid.dart';
import 'parts/tracking_control_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.userId, required this.intervalMs});

  final String userId;
  final int intervalMs;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final StreamSubscription<Location> _locationSub;
  late final StreamSubscription<StatusEvent> _statusSub;
  Timer? _displayTimer;
  bool _isFetchingList = false;

  @override
  void initState() {
    super.initState();

    _locationSub = BackgroundTask.instance.stream.listen((Location event) {
      // ignore: always_specify_types
      Future.delayed(const Duration(seconds: 3), _fetchPositionList);
    });

    _statusSub = BackgroundTask.instance.status.listen((StatusEvent event) {
      ref.read(appParamProvider.notifier).setStatusText(text: 'status: ${event.status.value}  ${event.message}');
    });

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
    _displayTimer = Timer.periodic(Duration(milliseconds: widget.intervalMs), (_) {});
  }

  void _stopTimers() => _displayTimer?.cancel();

  Future<void> _fetchPositionList() async {
    if (_isFetchingList) return;
    _isFetchingList = true;
    try {
      final int loginUserId = int.tryParse(widget.userId) ?? -1;
      final list = await PositionRepository.fetchAll(loginUserId);
      if (mounted) {
        ref.read(appParamProvider.notifier).setPositionList(list: list);
      }
    } finally {
      _isFetchingList = false;
    }
  }

  Future<void> _startTracking() async {
    await BackgroundTask.instance.start(updateIntervalInMilliseconds: widget.intervalMs.toDouble());
    _stopTimers();
    _startTimers();
    ref.read(appParamProvider.notifier)
      ..setIsTracking(flag: true)
      ..setStatusText(text: '取得中...');
  }

  Future<void> _stopTracking() async {
    await BackgroundTask.instance.stop();
    _stopTimers();
    ref.read(appParamProvider.notifier)
      ..setIsTracking(flag: false)
      ..setStatusText(text: '停止中');
  }

  @override
  void dispose() {
    _locationSub.cancel();
    _statusSub.cancel();
    _stopTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appParamProvider);

    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 72,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ここにーた',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 2),
            ),
            Text(
              'I was here — this place, this day, this moment.',
              style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w300, letterSpacing: 0.5),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          TrackingControlBar(
            statusText: state.statusText,
            isRunning: state.isTracking,
            onStart: _startTracking,
            onStop: _stopTracking,
            onReload: _fetchPositionList,
          ),
          const Expanded(child: CalendarGrid()),
        ],
      ),
    );
  }
}
