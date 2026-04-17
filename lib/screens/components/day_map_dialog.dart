import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../const/app_colors.dart';
import '../../controllers/app_param/app_param.dart';
import '../../models/position_model.dart';

class DayMapDialog extends ConsumerStatefulWidget {
  const DayMapDialog({super.key, required this.date, required this.items});

  final DateTime date;
  final List<PositionModel> items;

  @override
  ConsumerState<DayMapDialog> createState() => _DayMapDialogState();
}

class _DayMapDialogState extends ConsumerState<DayMapDialog> {
  final MapController _mapController = MapController();

  String get _dateLabel =>
      '${widget.date.year}-'
      '${widget.date.month.toString().padLeft(2, '0')}-'
      '${widget.date.day.toString().padLeft(2, '0')}';

  late final List<PositionModel> _sorted;
  late final List<LatLng> _points;

  @override
  void initState() {
    super.initState();
    _sorted = <PositionModel>[...widget.items]
      ..sort((PositionModel a, PositionModel b) => a.time.compareTo(b.time));

    _points = _sorted
        .map((PositionModel p) {
          final double? lat = double.tryParse(p.latitude);
          final double? lng = double.tryParse(p.longitude);
          if (lat == null || lng == null) return null;
          return LatLng(lat, lng);
        })
        .whereType<LatLng>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appParamProvider);
    final notifier = ref.read(appParamProvider.notifier);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: <Widget>[
              // 地図（常にフル表示・インタラクティブ）
              _points.isEmpty
                  ? const ColoredBox(
                      color: appSurfaceColor,
                      child: Center(
                        child: Text('位置データなし', style: TextStyle(color: appTextColor)),
                      ),
                    )
                  : _MapWithCircle(
                      points: _points,
                      mapController: _mapController,
                      selectedIndex: state.selectedMarkerIndex,
                    ),

              // AppBar オーバーレイ
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 4,
                  ),
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _dateLabel,
                              style: const TextStyle(
                                color: appTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '${widget.items.length} 件',
                              style: TextStyle(fontSize: 11, color: appTextColor.withOpacity(0.55)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          state.showPanel ? Icons.close : Icons.menu,
                          color: appTextColor,
                        ),
                        onPressed: notifier.toggleShowPanel,
                      ),
                    ],
                  ),
                ),
              ),

              // リストパネル オーバーレイ
              if (state.showPanel)
                Positioned(
                  top: kToolbarHeight + MediaQuery.of(context).padding.top,
                  left: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.33,
                  child: _PositionListPanel(
                    dateLabel: _dateLabel,
                    sorted: _sorted,
                    points: _points,
                    selectedIndex: state.selectedMarkerIndex,
                    onPointTap: (int index) =>
                        notifier.toggleSelectedMarkerIndex(index: index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapWithCircle extends StatelessWidget {
  const _MapWithCircle({required this.points, required this.mapController, required this.selectedIndex});

  final List<LatLng> points;
  final MapController mapController;
  final int? selectedIndex;

  LatLng get _center {
    final double minLat = points.map((LatLng p) => p.latitude).reduce(min);
    final double maxLat = points.map((LatLng p) => p.latitude).reduce(max);
    final double minLng = points.map((LatLng p) => p.longitude).reduce(min);
    final double maxLng = points.map((LatLng p) => p.longitude).reduce(max);
    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  double _radius(LatLng center) {
    const Distance calc = Distance();
    return points.map((LatLng p) => calc(center, p)).reduce(max) * 1.1;
  }

  CameraFit _cameraFit(LatLng center, double radiusM) {
    const Distance calc = Distance();
    final List<LatLng> cardinals = <LatLng>[
      calc.offset(center, radiusM, 0),
      calc.offset(center, radiusM, 90),
      calc.offset(center, radiusM, 180),
      calc.offset(center, radiusM, 270),
    ];
    return CameraFit.coordinates(coordinates: cardinals, padding: const EdgeInsets.all(40));
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _center;
    final double radiusM = _radius(center);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCameraFit: _cameraFit(center, radiusM)),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flutter_lifetime_position',
        ),
        CircleLayer(
          circles: <CircleMarker>[
            CircleMarker(
              point: center,
              radius: radiusM,
              useRadiusInMeter: true,
              color: Colors.redAccent.withOpacity(0.15),
              borderColor: Colors.redAccent.withOpacity(0.5),
              borderStrokeWidth: 1.5,
            ),
          ],
        ),
        MarkerLayer(
          markers: points.asMap().entries.map((MapEntry<int, LatLng> entry) {
            final bool isSelected = entry.key == selectedIndex;
            final double size = isSelected ? 40 : 10;
            return Marker(
              point: entry.value,
              width: size,
              height: size,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 1.5),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PositionListPanel extends StatefulWidget {
  const _PositionListPanel({
    required this.dateLabel,
    required this.sorted,
    required this.points,
    required this.selectedIndex,
    required this.onPointTap,
  });

  final String dateLabel;
  final List<PositionModel> sorted;
  final List<LatLng> points;
  final int? selectedIndex;
  final void Function(int index) onPointTap;

  @override
  State<_PositionListPanel> createState() => _PositionListPanelState();
}

class _PositionListPanelState extends State<_PositionListPanel> {
  final ScrollController _scrollController = ScrollController();

  void _scrollUp() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12)),
      ),
      child: Column(
        children: <Widget>[
          // ↑↓ スクロールボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: _scrollUp,
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.keyboard_arrow_up, color: appTextColor, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: _scrollDown,
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.keyboard_arrow_down, color: appTextColor, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // リスト
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              itemCount: widget.sorted.length,
              itemBuilder: (BuildContext context, int index) {
                final PositionModel item = widget.sorted[index];
                final bool isSelected = index == widget.selectedIndex;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: appTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.latitude,
                              style: TextStyle(fontSize: 10, color: appTextColor.withOpacity(0.4)),
                            ),
                            Text(
                              item.longitude,
                              style: TextStyle(fontSize: 10, color: appTextColor.withOpacity(0.4)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => widget.onPointTap(index),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: isSelected ? Colors.white : Colors.redAccent.withOpacity(0.75),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.redAccent : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
