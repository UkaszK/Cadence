import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/daily_progress_metrics.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';

class DashboardDailyProgress extends StatelessWidget {
  const DashboardDailyProgress({super.key, required this.progress});

  final DailyProgressMetrics progress;

  @override
  Widget build(BuildContext context) {
    final complete = progress.progress >= 1;

    return AnimatedContainer(
      duration: CadenceMotion.of(context, AnimationDurations.medium),
      curve: CadenceMotion.enter,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: complete ? CadenceColors.accent : CadenceColors.border,
          width: 1,
        ),
        color: CadenceColors.surface,
        boxShadow: complete
            ? [
                BoxShadow(
                  color: CadenceColors.accent.withValues(alpha: 0.22),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAILY PROGRESS',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progress.progressPercent}%',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress.progress,
            valueColor: const AlwaysStoppedAnimation<Color>(
              CadenceColors.accent,
            ),
            backgroundColor: CadenceColors.border,
            minHeight: 5,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.tasksDone} OF ${progress.tasksPlanned} PLANNED ITEMS COMPLETED',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
