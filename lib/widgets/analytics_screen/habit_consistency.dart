import 'package:flutter/material.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

class HabitConsistency extends StatelessWidget {
  const HabitConsistency({super.key, required this.metrics});

  final AnalyticsMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final habits = metrics.habits;

    return AnalyticsSection(
      title: 'HABIT CONSISTENCY',
      icon: Icons.repeat,
      isEmpty: habits.isEmpty,
      emptyLabel: 'NO HABITS EXPECTED IN RANGE',
      rightSide: Text('WEAKEST FIRST', style: analyticsCaptionStyle()),
      child: Column(
        spacing: 14,
        children: [
          for (final habit in habits)
            AnalyticsBarRow(
              leading: Icon(
                habit.habit.category.icon,
                size: 16,
                color: CadenceColors.otherAccent,
              ),
              label: habit.habit.name,
              value: habit.rate,
              color: analyticsRateColor(habit.rate),
              trailing: '${habit.ratePercent}%',
              subLabel: '${habit.done} / ${habit.scheduled} DAYS',
            ),
        ],
      ),
    );
  }
}
