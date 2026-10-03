import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/day.dart';
import 'package:cadence/data/gamification_metrics.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

/// Current streak, best streak and the last seven days of activity.
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.metrics});

  final GamificationMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final active = metrics.currentStreak > 0;
    final color = active
        ? CadenceColors.otherAccent
        : CadenceColors.textSecondary;

    return AnalyticsCard(
      child: Row(
        children: [
          Icon(
            active
                ? Icons.local_fire_department
                : Icons.local_fire_department_outlined,
            size: 32,
            color: color,
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CadenceValueSwitcher(
                value: metrics.currentStreak,
                axis: Axis.vertical,
                directionOf: (previous, next) => next >= previous ? 1 : -1,
                slideFraction: 0.8,
                builder: (streak) => Text(
                  '${streak}D',
                  style: GoogleFonts.jetBrainsMono(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'BEST ${metrics.bestStreak}D',
                style: analyticsCaptionStyle(),
              ),
            ],
          ),

          const Spacer(),

          Row(
            spacing: 6,
            children: [
              for (final day in metrics.recentDays)
                _DayDot(day: day, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day, required this.color});

  final StreakDay day;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: day.active ? color : Colors.transparent,
            border: Border.all(
              color: day.active ? color : CadenceColors.border,
              width: 1,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          Day.fromDateTime(day.date).label[0],
          style: analyticsCaptionStyle(),
        ),
      ],
    );
  }
}
