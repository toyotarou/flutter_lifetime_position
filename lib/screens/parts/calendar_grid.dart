import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../const/app_colors.dart';
import '../../controllers/app_param/app_param.dart';
import '../../models/position_model.dart';
import '../components/day_map_dialog.dart';

class CalendarGrid extends ConsumerWidget {
  const CalendarGrid({super.key});

  static const List<String> _weekdayLabels = <String>['日', '月', '火', '水', '木', '金', '土'];
  static final DateTime _earliestMonth = DateTime(2024);

  Map<String, List<PositionModel>> _buildDateMap(List<PositionModel> positionList) {
    final Map<String, List<PositionModel>> map = <String, List<PositionModel>>{};
    for (final PositionModel p in positionList) {
      final String key = '${p.year}-${p.month.padLeft(2, '0')}-${p.day.padLeft(2, '0')}';
      map.putIfAbsent(key, () => <PositionModel>[]).add(p);
    }
    return map;
  }

  List<DateTime?> _buildCalendarDays(DateTime month) {
    final DateTime firstDay = DateTime(month.year, month.month);
    final DateTime lastDay = DateTime(month.year, month.month + 1, 0);
    final int leadingBlanks = firstDay.weekday % 7;
    final List<DateTime?> days = <DateTime?>[];
    for (int i = 0; i < leadingBlanks; i++) {
      days.add(null);
    }
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }
    return days;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appParamProvider);
    final notifier = ref.read(appParamProvider.notifier);

    final DateTime displayMonth = state.displayMonth!;
    final DateTime now = DateTime.now();
    final Map<String, List<PositionModel>> dateMap = _buildDateMap(state.positionList);
    final List<DateTime?> calendarDays = _buildCalendarDays(displayMonth);
    final int rowCount = calendarDays.length ~/ 7;
    const BorderSide borderSide = BorderSide(color: appBorderColor);

    final bool canGoPrevious =
        displayMonth.isAfter(_earliestMonth) ||
        (displayMonth.year == _earliestMonth.year && displayMonth.month > _earliestMonth.month);

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // 月ナビゲーション
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Opacity(
                  opacity: canGoPrevious ? 1.0 : 0.25,
                  child: IconButton(
                    tooltip: '前の月',
                    onPressed: canGoPrevious ? notifier.goToPreviousMonth : null,
                    icon: const Icon(Icons.arrow_back, color: appTextColor),
                  ),
                ),
                Text(
                  '${displayMonth.year}年 ${displayMonth.month}月',
                  style: const TextStyle(
                    color: appTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  tooltip: '次の月',
                  onPressed: notifier.goToNextMonth,
                  icon: const Icon(Icons.arrow_forward, color: appTextColor),
                ),
              ],
            ),
          ),

          // 曜日ヘッダー＋カレンダーグリッド
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double cellSize = (constraints.maxWidth - 7) / 7;

              return Column(
                children: <Widget>[
                  Row(
                    // ignore: always_specify_types
                    children: List.generate(7, (int col) {
                      final Color color = col == 0
                          ? appSundayColor
                          : col == 6
                          ? appSaturdayColor
                          : appTextColor.withOpacity(0.5);
                      return SizedBox(
                        width: cellSize + 1,
                        height: 32,
                        child: Center(
                          child: Text(
                            _weekdayLabels[col],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // ignore: always_specify_types
                  ...List.generate(rowCount, (int row) {
                    return Row(
                      // ignore: always_specify_types
                      children: List.generate(7, (int col) {
                        final DateTime? date = calendarDays[row * 7 + col];
                        final bool isToday = date != null &&
                            date.year == now.year &&
                            date.month == now.month &&
                            date.day == now.day;

                        Color textColor = appTextColor;
                        if (col == 0) textColor = appSundayColor;
                        if (col == 6) textColor = appSaturdayColor;

                        final BorderSide activeBorder =
                            isToday ? const BorderSide(color: appTodayBorderColor) : borderSide;

                        final String? dateKey = date != null
                            ? '${date.year}-'
                                  '${date.month.toString().padLeft(2, '0')}-'
                                  '${date.day.toString().padLeft(2, '0')}'
                            : null;
                        final int count = dateKey != null ? (dateMap[dateKey]?.length ?? 0) : 0;

                        final Widget cell = Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            border: Border(
                              top: activeBorder,
                              right: activeBorder,
                              bottom: activeBorder,
                              left: activeBorder,
                            ),
                          ),
                          child: date != null
                              ? Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Text(
                                          '${date.day}',
                                          style: TextStyle(fontSize: 12, color: textColor),
                                        ),
                                      ),
                                    ),
                                    if (count > 0)
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: Text(
                                            '$count',
                                            style: const TextStyle(fontSize: 12, color: Colors.tealAccent),
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        );

                        if (count > 0 && date != null) {
                          return GestureDetector(
                            onTap: () {
                              notifier.resetDialogState();
                              showDialog<void>(
                                context: context,
                                builder: (_) => ProviderScope(
                                  parent: ProviderScope.containerOf(context),
                                  child: DayMapDialog(date: date, items: dateMap[dateKey]!),
                                ),
                              );
                            },
                            child: cell,
                          );
                        }
                        return cell;
                      }),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
