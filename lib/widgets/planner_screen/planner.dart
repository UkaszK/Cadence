import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/providers/planner_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/planner_screen/insert_block_widget.dart';
import 'package:cadence/widgets/planner_screen/interactive_block_widget.dart';
import 'package:cadence/widgets/planner_screen/planner_block_widget.dart';

sealed class _TimelineBlock {
  _TimelineBlock(this.startTime, this.endTime);

  final DateTime startTime;
  final DateTime endTime;
}

class _TaskBlock extends _TimelineBlock {
  _TaskBlock(this.scheduledTask)
    : super(scheduledTask.startTime, scheduledTask.endTime);

  final ScheduledTask scheduledTask;
}

class _HabitBlock extends _TimelineBlock {
  _HabitBlock(this.occurrence)
    : super(occurrence.startTime!, occurrence.endTime!);

  final HabitOccurrence occurrence;
}

class _InsertBlock extends _TimelineBlock {
  _InsertBlock(super.startTime, super.endTime);
}

class _InteractiveBlock extends _TimelineBlock {
  _InteractiveBlock(super.startTime, super.endTime);
}

class Planner extends StatelessWidget {
  const Planner({
    super.key,
    required this.baseDate,
    required this.scheduledTasks,
    required this.placedHabits,
    required this.displayInsertBlocks,
    required this.hasOverlap,
    this.selectedTimeSlot,
    this.editingItem,
    required this.onSelectTimeSlot,
    required this.onUpdateTimeSlot,
    required this.onSelectExistingTask,
    required this.onSelectExistingHabit,
  });

  final DateTime baseDate;
  final List<ScheduledTask> scheduledTasks;
  final List<HabitOccurrence> placedHabits;
  final bool displayInsertBlocks;
  final bool hasOverlap;
  final TimeSlot? selectedTimeSlot;
  final EditingPlannerItem? editingItem;
  final void Function(TimeSlot) onSelectTimeSlot;
  final void Function(TimeSlot) onUpdateTimeSlot;
  final void Function(ScheduledTask) onSelectExistingTask;
  final void Function(HabitOccurrence) onSelectExistingHabit;

  static const _pixelsPerMinute = 1.0;
  static const _leftOffset = 70.0;
  static const _rightOffset = 15.0;
  static const _dragStepMinutes = 5;
  static const _blocksOffsetY = 8.0;

  void _selectSlot(DateTime start, DateTime end) {
    onSelectTimeSlot((startTime: start, endTime: end));
    onUpdateTimeSlot((startTime: start, endTime: end));
  }

  bool _isBeingEdited(_TimelineBlock block) {
    return switch ((block, editingItem)) {
      (_TaskBlock(:final scheduledTask), EditingScheduledTask(scheduledTask: final e)) =>
        scheduledTask.id == e.id,
      (_HabitBlock(:final occurrence), EditingHabitOccurrence(occurrence: final o)) =>
        occurrence.id == o.id,
      _ => false,
    };
  }

  List<_TimelineBlock> _generateTimelineBlocks() {
    final List<_TimelineBlock> blocks = [];

    final items = <_TimelineBlock>[
      for (final t in scheduledTasks) _TaskBlock(t),
      for (final h in placedHabits) _HabitBlock(h),
    ]..sort((a, b) => a.startTime.compareTo(b.startTime));

    final endOfDay = baseDate.add(const Duration(hours: 23, minutes: 59));

    DateTime currentTracker = baseDate;

    final bool showInsertBlocks =
        displayInsertBlocks && selectedTimeSlot == null;

    void fillWithInsertBlocks(DateTime gapStart, DateTime gapEnd) {
      DateTime tracker = gapStart;
      while (tracker.isBefore(gapEnd)) {
        final desiredEndTime = tracker.add(const Duration(hours: 4));
        final actualEndTime = desiredEndTime.isBefore(gapEnd)
            ? desiredEndTime
            : gapEnd;

        blocks.add(_InsertBlock(tracker, actualEndTime));
        tracker = actualEndTime;
      }
    }

    for (final item in items) {
      if (showInsertBlocks && currentTracker.isBefore(item.startTime)) {
        fillWithInsertBlocks(currentTracker, item.startTime);
      }

      if (!_isBeingEdited(item)) {
        blocks.add(item);
      }

      if (item.endTime.isAfter(currentTracker)) {
        currentTracker = item.endTime;
      }
    }

    if (showInsertBlocks && currentTracker.isBefore(endOfDay)) {
      fillWithInsertBlocks(currentTracker, endOfDay);
    }

    if (selectedTimeSlot != null) {
      blocks.add(
        _InteractiveBlock(
          selectedTimeSlot!.startTime,
          selectedTimeSlot!.endTime,
        ),
      );
    }

    return blocks;
  }

  Widget _buildTimeGrid() {
    List<Widget> gridElements = [];

    gridElements.add(
      Positioned(
        left: _leftOffset,
        top: 0,
        bottom: 0,
        child: Container(width: 1, color: CadenceColors.textSecondary),
      ),
    );

    for (int hour = baseDate.hour; hour <= 24; hour += 2) {
      double topPosition = (hour - baseDate.hour) * 60 * _pixelsPerMinute;

      gridElements.add(
        Positioned(
          top: topPosition,
          left: 10,
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  maxLines: 1,
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              Container(
                width: 11,
                height: 1,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CadenceColors.textSecondary,
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(children: gridElements);
  }

  Widget _positioned({
    required DateTime start,
    required DateTime end,
    double inset = 0,
    required Widget child,
  }) {
    int minutesFromStart = start.difference(baseDate).inMinutes;
    int duration = end.difference(start).inMinutes;

    double topPosition =
        minutesFromStart * _pixelsPerMinute + _blocksOffsetY + inset;
    double height = duration * _pixelsPerMinute - inset * 2;

    return Positioned(
      top: topPosition,
      left: _leftOffset,
      right: _rightOffset,
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 15),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTaskBlock(ScheduledTask scheduledTask) {
    return _positioned(
      start: scheduledTask.startTime,
      end: scheduledTask.endTime,
      child: PlannerBlockWidget(
        title: scheduledTask.name,
        timeText: scheduledTask.timeText,
        timeTextOneLine: scheduledTask.timeTextOneLine,
        color: scheduledTask.status.color,
        description: scheduledTask.subTasksListed,
        onTap: () => onSelectExistingTask(scheduledTask),
      ),
    );
  }

  Widget _buildHabitBlock(HabitOccurrence occurrence) {
    return _positioned(
      start: occurrence.startTime!,
      end: occurrence.endTime!,
      child: PlannerBlockWidget(
        title: occurrence.name,
        timeText: occurrence.timeText,
        timeTextOneLine: occurrence.timeTextOneLine,
        color: occurrence.completed
            ? CadenceColors.success
            : CadenceColors.otherAccent,
        isHabit: true,
        onTap: () => onSelectExistingHabit(occurrence),
      ),
    );
  }

  Widget _buildInsertBlock(DateTime start, DateTime end) {
    return _positioned(
      start: start,
      end: end,
      inset: 3,
      child: InsertBlockWidget(
        startTime: start,
        endTime: end,
        onTap: () => _selectSlot(start, end),
      ),
    );
  }

  Widget _buildInteractiveSlotBlock(DateTime start, DateTime end) {
    final slotColor = hasOverlap ? CadenceColors.danger : CadenceColors.accent;

    return _positioned(
      start: start,
      end: end,
      child: InteractiveBlockWidget(
        baseDate: baseDate,
        startTime: start,
        endTime: end,
        color: slotColor,
        onUpdateTimeSlot: onUpdateTimeSlot,
        dragStepMinutes: _dragStepMinutes,
      ),
    );
  }

  Widget _buildSpecificBlock(_TimelineBlock block) {
    return switch (block) {
      _TaskBlock(:final scheduledTask) => _buildTaskBlock(scheduledTask),
      _HabitBlock(:final occurrence) => _buildHabitBlock(occurrence),
      _InsertBlock() => _buildInsertBlock(block.startTime, block.endTime),
      _InteractiveBlock() => _buildInteractiveSlotBlock(
        block.startTime,
        block.endTime,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final blocks = _generateTimelineBlocks();

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 30, bottom: 150),
      child: SizedBox(
        width: double.infinity,
        height:
            (24 - baseDate.hour) * 60 * _pixelsPerMinute + _blocksOffsetY * 2,
        child: Stack(
          children: [
            _buildTimeGrid(),
            for (final block in blocks) _buildSpecificBlock(block),
          ],
        ),
      ),
    );
  }
}
