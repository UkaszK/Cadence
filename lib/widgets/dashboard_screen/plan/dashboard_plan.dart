import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/blocked_time.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/sub_task.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_time_text.dart';
import 'package:cadence/widgets/dashboard_screen/plan/planned_blocked_time_block.dart';
import 'package:cadence/widgets/dashboard_screen/plan/planned_habit_block.dart';
import 'package:cadence/widgets/dashboard_screen/plan/scheduled_task_block.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

sealed class _PlanEntry {
  DateTime get startTime;
}

class _TaskEntry extends _PlanEntry {
  _TaskEntry(this.task);
  final ScheduledTask task;
  @override
  DateTime get startTime => task.startTime;
}

class _HabitEntry extends _PlanEntry {
  _HabitEntry(this.occurrence);
  final HabitOccurrence occurrence;
  @override
  DateTime get startTime => occurrence.startTime!;
}

class _BlockedTimeEntry extends _PlanEntry {
  _BlockedTimeEntry(this.blockedTime);
  final BlockedTime blockedTime;
  @override
  DateTime get startTime => blockedTime.startTime;
}

class DashboardPlan extends StatelessWidget {
  const DashboardPlan({
    super.key,
    required this.scheduledTasks,
    required this.placedHabits,
    this.blockedTimes = const [],
    required this.onCheckScheduledTask,
    required this.onCheckSubTask,
    required this.onCheckHabitOccurrence,
    required this.onEditScheduledTask,
  });

  final List<ScheduledTask> scheduledTasks;
  final List<HabitOccurrence> placedHabits;
  final List<BlockedTime> blockedTimes;
  final void Function(ScheduledTask, bool) onCheckScheduledTask;
  final void Function(ScheduledTask, SubTask, bool) onCheckSubTask;
  final void Function(HabitOccurrence, bool) onCheckHabitOccurrence;
  final void Function(ScheduledTask) onEditScheduledTask;

  Widget _buildHeader(String? timelineText) {
    return CadenceSectionHeader(
      title: 'PLAN',
      icon: Icons.access_time,
      dividerStyle: (dividerDistance: 8),
      iconColor: CadenceColors.accent,
      rightSide: Text(
        'TIMELINE (${timelineText ?? '-'})',
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
                  border: Border.all(color: CadenceColors.accent),
                  color: CadenceColors.accent.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: CadenceColors.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'NO PLAN FOR TODAY',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Build your day in the Planner',
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
    final entries = <_PlanEntry>[
      for (final t in scheduledTasks) _TaskEntry(t),
      for (final h in placedHabits) _HabitEntry(h),
      for (final b in blockedTimes) _BlockedTimeEntry(b),
    ]..sort((a, b) => a.startTime.compareTo(b.startTime));

    String? timelineText;
    if (entries.isNotEmpty) {
      final start = entries.first.startTime;
      final end = [
        for (final t in scheduledTasks) t.endTime,
        for (final h in placedHabits) h.endTime!,
        for (final b in blockedTimes) b.endTime,
      ].reduce((a, b) => a.isAfter(b) ? a : b);
      timelineText = getTimeText(start, end, false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(timelineText),

        if (entries.isNotEmpty) ...[
          for (final entry in entries) ...[
            const SizedBox(height: 10),
            switch (entry) {
              _TaskEntry(:final task) => ScheduledTaskBlock(
                scheduledTask: task,
                onCheckTask: (newValue) => onCheckScheduledTask(task, newValue),
                onCheckSubTask: (subTask, newValue) =>
                    onCheckSubTask(task, subTask, newValue),
                onEdit: () => onEditScheduledTask(task),
              ),
              _HabitEntry(:final occurrence) => PlannedHabitBlock(
                occurrence: occurrence,
                onCheck: (newValue) =>
                    onCheckHabitOccurrence(occurrence, newValue),
              ),
              _BlockedTimeEntry(:final blockedTime) => PlannedBlockedTimeBlock(
                blockedTime: blockedTime,
              ),
            },
          ],
        ] else ...[
          const SizedBox(height: 10),
          _buildEmptyBlock(),
        ],
      ],
    );
  }
}
