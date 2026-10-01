import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_duration_hours_and_minutes.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

class AnalyticsOverviewTiles extends StatelessWidget {
  const AnalyticsOverviewTiles({super.key, required this.metrics});

  final AnalyticsMetrics metrics;

  String _focusTimeText() {
    final (hours, minutes) = getDurationHoursAndMinutes(metrics.focusMinutes);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final rateColor = metrics.hasData
        ? analyticsRateColor(metrics.completionRate)
        : CadenceColors.textSecondary;

    return Column(
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.track_changes,
                label: 'COMPLETION RATE',
                value: metrics.hasData ? '${metrics.completionPercent}%' : '-',
                valueColor: rateColor,
                subtitle: '${metrics.objectivesDone} / ${metrics.objectivesPlanned} PLANNED',
              ),
            ),
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle_outline,
                label: 'ITEMS DONE',
                value: '${metrics.objectivesDone}',
                subtitle: 'LAST ${metrics.range.days} DAYS',
              ),
            ),
          ],
        ),
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.timer_outlined,
                label: 'FOCUS TIME',
                value: _focusTimeText(),
                subtitle: 'TASKS COMPLETED',
              ),
            ),
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department_outlined,
                label: 'STREAK',
                value: '${metrics.currentStreak}D',
                valueColor: metrics.currentStreak > 0
                    ? CadenceColors.otherAccent
                    : CadenceColors.textSecondary,
                subtitle: 'BEST ${metrics.bestStreak}D',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueColor = CadenceColors.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return AnalyticsCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: CadenceColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: analyticsCaptionStyle(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
