import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/position_model.dart';

part 'app_param.freezed.dart';

part 'app_param.g.dart';

@freezed
class AppParamState with _$AppParamState {
  const factory AppParamState({
    // ── ホーム画面 ──────────────────────────────────
    @Default(<PositionModel>[]) List<PositionModel> positionList,
    @Default(false) bool isTracking,
    @Default('停止中') String statusText,

    // ── カレンダー ──────────────────────────────────
    DateTime? displayMonth,

    // ── 地図ダイアログ ──────────────────────────────
    @Default(false) bool showPanel,
    int? selectedMarkerIndex,
  }) = _AppParamState;
}

@riverpod
class AppParam extends _$AppParam {
  @override
  AppParamState build() {
    return AppParamState(displayMonth: DateTime(DateTime.now().year, DateTime.now().month));
  }

  // ── ホーム画面 ──────────────────────────────────────

  void setPositionList({required List<PositionModel> list}) => state = state.copyWith(positionList: list);

  void setIsTracking({required bool flag}) => state = state.copyWith(isTracking: flag);

  void setStatusText({required String text}) => state = state.copyWith(statusText: text);

  // ── カレンダー ────────────────────────────────────────

  void setDisplayMonth({required DateTime month}) => state = state.copyWith(displayMonth: month);

  void goToPreviousMonth() {
    final DateTime cur = state.displayMonth!;
    state = state.copyWith(displayMonth: DateTime(cur.year, cur.month - 1));
  }

  void goToNextMonth() {
    final DateTime cur = state.displayMonth!;
    state = state.copyWith(displayMonth: DateTime(cur.year, cur.month + 1));
  }

  // ── 地図ダイアログ ──────────────────────────────────────

  void setShowPanel({required bool flag}) => state = state.copyWith(showPanel: flag);

  void toggleShowPanel() => state = state.copyWith(showPanel: !state.showPanel);

  /// 同じインデックスを再タップしたら解除（トグル）
  void toggleSelectedMarkerIndex({required int index}) {
    state = state.copyWith(selectedMarkerIndex: state.selectedMarkerIndex == index ? null : index);
  }

  /// ダイアログを開くたびにリセット
  void resetDialogState() => state = state.copyWith(showPanel: false, selectedMarkerIndex: null);
}
