// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_param.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppParamState {
  // ── ホーム画面 ──────────────────────────────────
  List<PositionModel> get positionList => throw _privateConstructorUsedError;
  bool get isTracking => throw _privateConstructorUsedError;
  String get statusText =>
      throw _privateConstructorUsedError; // ── カレンダー ──────────────────────────────────
  DateTime? get displayMonth =>
      throw _privateConstructorUsedError; // ── 地図ダイアログ ──────────────────────────────
  bool get showPanel => throw _privateConstructorUsedError;
  int? get selectedMarkerIndex => throw _privateConstructorUsedError;

  /// Create a copy of AppParamState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppParamStateCopyWith<AppParamState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppParamStateCopyWith<$Res> {
  factory $AppParamStateCopyWith(
    AppParamState value,
    $Res Function(AppParamState) then,
  ) = _$AppParamStateCopyWithImpl<$Res, AppParamState>;
  @useResult
  $Res call({
    List<PositionModel> positionList,
    bool isTracking,
    String statusText,
    DateTime? displayMonth,
    bool showPanel,
    int? selectedMarkerIndex,
  });
}

/// @nodoc
class _$AppParamStateCopyWithImpl<$Res, $Val extends AppParamState>
    implements $AppParamStateCopyWith<$Res> {
  _$AppParamStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppParamState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? positionList = null,
    Object? isTracking = null,
    Object? statusText = null,
    Object? displayMonth = freezed,
    Object? showPanel = null,
    Object? selectedMarkerIndex = freezed,
  }) {
    return _then(
      _value.copyWith(
            positionList: null == positionList
                ? _value.positionList
                : positionList // ignore: cast_nullable_to_non_nullable
                      as List<PositionModel>,
            isTracking: null == isTracking
                ? _value.isTracking
                : isTracking // ignore: cast_nullable_to_non_nullable
                      as bool,
            statusText: null == statusText
                ? _value.statusText
                : statusText // ignore: cast_nullable_to_non_nullable
                      as String,
            displayMonth: freezed == displayMonth
                ? _value.displayMonth
                : displayMonth // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            showPanel: null == showPanel
                ? _value.showPanel
                : showPanel // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectedMarkerIndex: freezed == selectedMarkerIndex
                ? _value.selectedMarkerIndex
                : selectedMarkerIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppParamStateImplCopyWith<$Res>
    implements $AppParamStateCopyWith<$Res> {
  factory _$$AppParamStateImplCopyWith(
    _$AppParamStateImpl value,
    $Res Function(_$AppParamStateImpl) then,
  ) = __$$AppParamStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<PositionModel> positionList,
    bool isTracking,
    String statusText,
    DateTime? displayMonth,
    bool showPanel,
    int? selectedMarkerIndex,
  });
}

/// @nodoc
class __$$AppParamStateImplCopyWithImpl<$Res>
    extends _$AppParamStateCopyWithImpl<$Res, _$AppParamStateImpl>
    implements _$$AppParamStateImplCopyWith<$Res> {
  __$$AppParamStateImplCopyWithImpl(
    _$AppParamStateImpl _value,
    $Res Function(_$AppParamStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppParamState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? positionList = null,
    Object? isTracking = null,
    Object? statusText = null,
    Object? displayMonth = freezed,
    Object? showPanel = null,
    Object? selectedMarkerIndex = freezed,
  }) {
    return _then(
      _$AppParamStateImpl(
        positionList: null == positionList
            ? _value._positionList
            : positionList // ignore: cast_nullable_to_non_nullable
                  as List<PositionModel>,
        isTracking: null == isTracking
            ? _value.isTracking
            : isTracking // ignore: cast_nullable_to_non_nullable
                  as bool,
        statusText: null == statusText
            ? _value.statusText
            : statusText // ignore: cast_nullable_to_non_nullable
                  as String,
        displayMonth: freezed == displayMonth
            ? _value.displayMonth
            : displayMonth // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        showPanel: null == showPanel
            ? _value.showPanel
            : showPanel // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectedMarkerIndex: freezed == selectedMarkerIndex
            ? _value.selectedMarkerIndex
            : selectedMarkerIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$AppParamStateImpl implements _AppParamState {
  const _$AppParamStateImpl({
    final List<PositionModel> positionList = const <PositionModel>[],
    this.isTracking = false,
    this.statusText = '停止中',
    this.displayMonth,
    this.showPanel = false,
    this.selectedMarkerIndex,
  }) : _positionList = positionList;

  // ── ホーム画面 ──────────────────────────────────
  final List<PositionModel> _positionList;
  // ── ホーム画面 ──────────────────────────────────
  @override
  @JsonKey()
  List<PositionModel> get positionList {
    if (_positionList is EqualUnmodifiableListView) return _positionList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_positionList);
  }

  @override
  @JsonKey()
  final bool isTracking;
  @override
  @JsonKey()
  final String statusText;
  // ── カレンダー ──────────────────────────────────
  @override
  final DateTime? displayMonth;
  // ── 地図ダイアログ ──────────────────────────────
  @override
  @JsonKey()
  final bool showPanel;
  @override
  final int? selectedMarkerIndex;

  @override
  String toString() {
    return 'AppParamState(positionList: $positionList, isTracking: $isTracking, statusText: $statusText, displayMonth: $displayMonth, showPanel: $showPanel, selectedMarkerIndex: $selectedMarkerIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppParamStateImpl &&
            const DeepCollectionEquality().equals(
              other._positionList,
              _positionList,
            ) &&
            (identical(other.isTracking, isTracking) ||
                other.isTracking == isTracking) &&
            (identical(other.statusText, statusText) ||
                other.statusText == statusText) &&
            (identical(other.displayMonth, displayMonth) ||
                other.displayMonth == displayMonth) &&
            (identical(other.showPanel, showPanel) ||
                other.showPanel == showPanel) &&
            (identical(other.selectedMarkerIndex, selectedMarkerIndex) ||
                other.selectedMarkerIndex == selectedMarkerIndex));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_positionList),
    isTracking,
    statusText,
    displayMonth,
    showPanel,
    selectedMarkerIndex,
  );

  /// Create a copy of AppParamState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppParamStateImplCopyWith<_$AppParamStateImpl> get copyWith =>
      __$$AppParamStateImplCopyWithImpl<_$AppParamStateImpl>(this, _$identity);
}

abstract class _AppParamState implements AppParamState {
  const factory _AppParamState({
    final List<PositionModel> positionList,
    final bool isTracking,
    final String statusText,
    final DateTime? displayMonth,
    final bool showPanel,
    final int? selectedMarkerIndex,
  }) = _$AppParamStateImpl;

  // ── ホーム画面 ──────────────────────────────────
  @override
  List<PositionModel> get positionList;
  @override
  bool get isTracking;
  @override
  String get statusText; // ── カレンダー ──────────────────────────────────
  @override
  DateTime? get displayMonth; // ── 地図ダイアログ ──────────────────────────────
  @override
  bool get showPanel;
  @override
  int? get selectedMarkerIndex;

  /// Create a copy of AppParamState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppParamStateImplCopyWith<_$AppParamStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
