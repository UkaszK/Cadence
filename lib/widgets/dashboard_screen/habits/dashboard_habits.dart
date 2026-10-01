import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/dashboard_screen/habits/habit_checklist_block.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

class DashboardHabits extends StatelessWidget {
  const DashboardHabits({
    super.key,
    required this.expectedHabits,
    required this.completedHabitIds,
    required this.dayOccurrences,
    required this.onCheckHabit,
  });

  final List<Habit> expectedHabits;
  final Set<int> completedHabitIds;
  final List<HabitOccurrence> dayOccurrences;
  final void Function(Habit, bool) onCheckHabit;

  Widget _buildHeader() {
    final done = expectedHabits
        .where((h) => completedHabitIds.contains(h.id))
        .length;

    return CadenceSectionHeader(
      title: 'HABITS',
      icon: Icons.repeat,
      iconColor: CadenceColors.otherAccent,
      dividerStyle: (dividerDistance: 8),
      rightSide: Text(
        '$done / ${expectedHabits.length} DONE',
        style: GoogleFonts.jetBrainsMono(
          color: CadenceColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyBlock() {
    return Container(
      color: CadenceColors.surface,
      child: DottedBorder(
        options: RectDottedBorderOptions(
          strokeWidth: 1,
          color: CadenceColors.border,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: AlignmentGeometry.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CadenceColors.otherAccent),
                  color: CadenceColors.otherAccent.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.repeat,
                  color: CadenceColors.otherAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NO HABITS DUE TODAY',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.otherAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add habits in the Library and schedule them on weekdays or every N days',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),

        const SizedBox(height: 10),

        if (expectedHabits.isNotEmpty)
          Column(
            spacing: 10,
            children: [
              for (final habit in expectedHabits)
                HabitChecklistBlock(
                  habit: habit,
                  completed: completedHabitIds.contains(habit.id),
                  placedTimeText: dayOccurrences
                      .where((o) => o.habitId == habit.id && o.isPlaced)
                      .map((o) => o.timeTextOneLine)
                      .firstOrNull,
                  onCheck: (newValue) => onCheckHabit(habit, newValue),
                ),
            ],
          )
        else
          _buildEmptyBlock(),
      ],
    );
  }
}
