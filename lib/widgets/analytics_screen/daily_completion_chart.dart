import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_bar_chart.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

class DailyCompletionChart extends StatelessWidget {
  const DailyCompletionChart({super.key, required this.metrics});

  final AnalyticsMetrics metrics;

  static final _dayFormat = DateFormat('dd.MM');
  static final _weekdayFormat = DateFormat('E');

  bool get _groupWeekly => metrics.range == AnalyticsRange.quarter;

  Color _barColor(int done, int planned, bool isCurrent) {
    if (planned == 0) return CadenceColors.border;
    final color = analyticsRateColor(done / planned);
    return isCurrent ? color : color.withValues(alpha: 0.75);
  }

  List<AnalyticsBar> _dailyBars() {
    final daily = metrics.daily;
    final labelEvery = switch (metrics.range) {
      AnalyticsRange.week => 1,
      AnalyticsRange.month => 5,
      AnalyticsRange.quarter => 1,
    };

    return [
      for (var i = 0; i < daily.length; i++)
        AnalyticsBar(
          value: daily[i].rate,
          color: _barColor(
            daily[i].done,
            daily[i].planned,
            i == daily.length - 1,
          ),
          label: (i % labelEvery == 0 || i == daily.length - 1)
              ? (metrics.range == AnalyticsRange.week
                    ? _weekdayFormat.format(daily[i].date).toUpperCase()
                    : _dayFormat.format(daily[i].date))
              : '',
          tooltip:
              '${_dayFormat.format(daily[i].date)}\n'
              '${daily[i].done} / ${daily[i].planned}  ·  ${daily[i].ratePercent}%',
        ),
    ];
  }

  List<AnalyticsBar> _weeklyBars() {
    final daily = metrics.daily;
    final bars = <AnalyticsBar>[];

    for (var start = 0; start < daily.length; start += 7) {
      final end = (start + 7).clamp(0, daily.length);
      final chunk = daily.sublist(start, end);
      final done = chunk.fold(0, (sum, d) => sum + d.done);
      final planned = chunk.fold(0, (sum, d) => sum + d.planned);
      final isCurrent = end == daily.length;
      final weekIndex = start ~/ 7;

      bars.add(
        AnalyticsBar(
          value: planned == 0 ? 0 : done / planned,
          color: _barColor(done, planned, isCurrent),
          label: (weekIndex % 3 == 0 || isCurrent)
              ? _dayFormat.format(chunk.first.date)
              : '',
          tooltip:
              '${_dayFormat.format(chunk.first.date)} - ${_dayFormat.format(chunk.last.date)}\n'
              '$done / $planned  ·  ${planned == 0 ? 0 : (done / planned * 100).round()}%',
        ),
      );
    }

    return bars;
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsSection(
      title: 'DAILY COMPLETION',
      icon: Icons.bar_chart,
      isEmpty: !metrics.hasData,
      rightSide: Text(
        _groupWeekly ? 'PER WEEK' : 'PER DAY',
        style: analyticsCaptionStyle(),
      ),
      child: AnalyticsBarChart(
        bars: _groupWeekly ? _weeklyBars() : _dailyBars(),
      ),
    );
  }
}
