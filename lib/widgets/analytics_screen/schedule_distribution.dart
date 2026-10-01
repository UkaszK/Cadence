import 'package:flutter/material.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

class ScheduleDistribution extends StatelessWidget {
  const ScheduleDistribution({super.key, required this.metrics});

  final AnalyticsMetrics metrics;

  IconData _iconFor(DayWindow window) {
    return switch (window) {
      DayWindow.morning => Icons.wb_twilight,
      DayWindow.afternoon => Icons.wb_sunny_outlined,
      DayWindow.evening => Icons.nights_stay_outlined,
      DayWindow.night => Icons.bedtime_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final windows = metrics.windows;
    final totalPlanned = windows.fold(0, (sum, w) => sum + w.planned);

    return AnalyticsSection(
      title: 'SCHEDULE DISTRIBUTION',
      icon: Icons.schedule,
      isEmpty: totalPlanned == 0,
      emptyLabel: 'NO TASKS SCHEDULED IN RANGE',
      rightSide: Text('TASKS BY TIME', style: analyticsCaptionStyle()),
      child: Column(
        spacing: 14,
        children: [
          for (final window in windows)
            AnalyticsBarRow(
              leading: Icon(
                _iconFor(window.window),
                size: 16,
                color: CadenceColors.textSecondary,
              ),
              label: '${window.window.label}  ${window.window.hint}',
              value: totalPlanned == 0 ? 0 : window.planned / totalPlanned,
              color: window.planned == 0
                  ? CadenceColors.border
                  : analyticsRateColor(window.rate),
              trailing: window.planned == 0
                  ? '-'
                  : '${window.ratePercent}% DONE',
              subLabel:
                  '${window.planned} SCHEDULED  ·  '
                  '${totalPlanned == 0 ? 0 : (window.planned / totalPlanned * 100).round()}% OF ALL',
            ),
        ],
      ),
    );
  }
}
