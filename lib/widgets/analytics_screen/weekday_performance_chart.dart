import 'package:flutter/material.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_bar_chart.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

class WeekdayPerformanceChart extends StatelessWidget {
  const WeekdayPerformanceChart({super.key, required this.metrics});

  final AnalyticsMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final hasData = metrics.weekdays.any((w) => w.planned > 0);

    return AnalyticsSection(
      title: 'WEEKDAY PERFORMANCE',
      icon: Icons.calendar_view_week,
      isEmpty: !hasData,
      rightSide: Text('AVG COMPLETION', style: analyticsCaptionStyle()),
      child: AnalyticsBarChart(
        height: 140,
        bars: [
          for (final weekday in metrics.weekdays)
            AnalyticsBar(
              value: weekday.rate,
              color: weekday.planned == 0
                  ? CadenceColors.border
                  : analyticsRateColor(weekday.rate),
              label: weekday.day.label.substring(0, 3).toUpperCase(),
              tooltip:
                  '${weekday.day.label.toUpperCase()}\n'
                  '${weekday.done} / ${weekday.planned}  ·  ${weekday.ratePercent}%',
            ),
        ],
      ),
    );
  }
}
