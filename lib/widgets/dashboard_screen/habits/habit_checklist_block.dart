import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';
import 'package:cadence/widgets/library_screen/task_block.dart';
import 'package:cadence/widgets/reusables/cadence_badge.dart';

class HabitChecklistBlock extends StatelessWidget {
  const HabitChecklistBlock({
    super.key,
    required this.habit,
    required this.completed,
    required this.placedTimeText,
    required this.onCheck,
  });

  final Habit habit;
  final bool completed;

  /// Time text when the habit was placed in the planner, otherwise null.
  final String? placedTimeText;
  final void Function(bool) onCheck;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AnimationDurations.fast,
      curve: CadenceMotion.enter,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: completed
              ? CadenceColors.otherAccent.withValues(alpha: 0.45)
              : CadenceColors.border,
        ),
        color: CadenceColors.surface,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: AnimatedCheckbox(
              value: completed,
              onChanged: onCheck,
              activeColor: CadenceColors.otherAccent,
              side: const BorderSide(
                color: CadenceColors.otherAccent,
                width: 1,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => onCheck(!completed),
                  child: AnimatedDefaultTextStyle(
                    duration: AnimationDurations.fast,
                    curve: CadenceMotion.enter,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      color: completed
                          ? CadenceColors.textSecondary
                          : CadenceColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                    child: Text(habit.name),
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        habit.categoryName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          color: CadenceColors.textSecondary,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    CadenceBadge(
                      label: formatDurationLabel(habit.durationMinutes),
                      primaryColor: CadenceColors.otherAccent,
                      borderColor: CadenceColors.otherAccentLessOpacity,
                      padding: EdgeInsets.symmetric(horizontal: 2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          CadenceBadge(
            label: placedTimeText ?? 'ANYTIME',
            primaryColor: placedTimeText != null
                ? CadenceColors.otherAccent
                : CadenceColors.textSecondary,
            prefixIcon: placedTimeText != null ? Icons.schedule : null,
          ),
        ],
      ),
    );
  }
}
