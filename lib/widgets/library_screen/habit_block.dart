import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/day.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/habit_schedule.dart';
import 'package:cadence/widgets/library_screen/item_container.dart';
import 'package:cadence/widgets/library_screen/task_block.dart';
import 'package:cadence/widgets/reusables/cadence_badge.dart';

class HabitBlock extends StatelessWidget {
  const HabitBlock({super.key, required this.habit, this.footer});

  final Habit habit;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final color = habit.archived
        ? CadenceColors.textSecondary
        : CadenceColors.otherAccent;
    final expectedToday = isHabitExpectedOn(habit, DateTime.now());

    return ItemContainer(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
            children: [
              CadenceBadge(
                label: habit.archived ? 'ARCHIVED' : 'HABIT',
                primaryColor: color,
              ),

              CadenceBadge(
                label: formatDurationLabel(habit.durationMinutes),
                primaryColor: CadenceColors.textSecondary,
                backgroundColor: CadenceColors.surface,
                borderColor: CadenceColors.border,
                prefixIcon: Icons.timer_outlined,
              ),

              CadenceBadge(
                label: habit.ruleText.toUpperCase(),
                primaryColor: color,
                backgroundColor: CadenceColors.surface,
                borderColor: CadenceColors.border,
                prefixIcon: Icons.repeat,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            habit.name,
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight(1000),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CadenceColors.black,
              border: Border.all(color: CadenceColors.border, width: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                switch (habit.scheduleType) {
                  HabitScheduleType.weekdays => Row(
                    spacing: 5,
                    children: [
                      Text(
                        'REPEAT:',
                        style: GoogleFonts.jetBrainsMono(
                          color: CadenceColors.textPrimary,
                          fontSize: 10,
                        ),
                      ),
                      for (final day in Day.values)
                        _DayBox(
                          label: day.label[0],
                          selected: habit.repeatDays.contains(day),
                          color: color,
                        ),
                    ],
                  ),
                  HabitScheduleType.interval => Text(
                    'EVERY ${habit.intervalDays} DAYS',
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textPrimary,
                      fontSize: 10,
                    ),
                  ),
                },

                if (expectedToday)
                  Text(
                    'TODAY',
                    style: GoogleFonts.jetBrainsMono(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),

          if (footer != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1),
            const SizedBox(height: 5),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({
    required this.label,
    required this.selected,
    required this.color,
  });

  final String label;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? color : CadenceColors.surface,
        border: Border.all(color: CadenceColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              color: selected ? CadenceColors.black : CadenceColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
