import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';
import 'package:cadence/widgets/reusables/cadence_badge.dart';

/// A habit that has been placed into a time slot, shown inside the plan.
class PlannedHabitBlock extends StatelessWidget {
  const PlannedHabitBlock({
    super.key,
    required this.occurrence,
    required this.onCheck,
  });

  final HabitOccurrence occurrence;
  final void Function(bool) onCheck;

  @override
  Widget build(BuildContext context) {
    final status = occurrence.status;
    final color = occurrence.completed
        ? CadenceColors.success
        : CadenceColors.otherAccent;

    return AnimatedContainer(
      duration: AnimationDurations.fast,
      curve: CadenceMotion.enter,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: color),
        color: CadenceColors.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: AnimatedCheckbox(
                    value: occurrence.completed,
                    onChanged: onCheck,
                    side: BorderSide(color: color),
                    activeColor: CadenceColors.otherAccent,
                    checkColor: CadenceColors.black,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            occurrence.timeTextOneLine,
                            style: GoogleFonts.jetBrainsMono(
                              color: CadenceColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Flexible(
                            child: Text(
                              occurrence.categoryName.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.jetBrainsMono(
                                color: CadenceColors.textSecondary,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        spacing: 6,
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 12,
                            color: CadenceColors.otherAccent,
                          ),
                          Flexible(
                            child: InkWell(
                              onTap: () => onCheck(!occurrence.completed),
                              child: AnimatedDefaultTextStyle(
                                duration: AnimationDurations.fast,
                                curve: CadenceMotion.enter,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.jetBrainsMono(
                                  color: occurrence.completed
                                      ? CadenceColors.textSecondary
                                      : CadenceColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  decoration: occurrence.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                child: Text(occurrence.name),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CadenceBadge(
            label: status.label.toUpperCase(),
            primaryColor: status.color,
          ),
        ],
      ),
    );
  }
}
