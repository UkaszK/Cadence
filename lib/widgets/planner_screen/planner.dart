import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/providers/planner_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
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

class _InteractiveBlock extends _TimelineBlock {
  _InteractiveBlock(super.startTime, super.endTime);
}

class Planner extends StatelessWidget {
  const Planner({
    super.key,
    required this.baseDate,
    required this.scheduledTasks,
    required this.placedHabits,
    required this.canCreateSlot,
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

  /// Whether tapping free time on the timeline should open a new slot.
  final bool canCreateSlot;
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
  static const _tapSnapMinutes = 15;
  static const _defaultSlotMinutes = 60;
  static const _minSlotMinutes = 15;

  DateTime get _endOfDay =>
      baseDate.add(const Duration(hours: 23, minutes: 59));

  void _selectSlot(DateTime start, DateTime end) {
    onSelectTimeSlot((startTime: start, endTime: end));
    onUpdateTimeSlot((startTime: start, endTime: end));
  }

  List<_TimelineBlock> _occupiedBlocks() {
    return <_TimelineBlock>[
      for (final t in scheduledTasks) _TaskBlock(t),
      for (final h in placedHabits) _HabitBlock(h),
    ]..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Opens a slot at the tapped time, snapped to [_tapSnapMinutes] and sized
  /// to [_defaultSlotMinutes] unless an existing block or the end of the day
  /// comes first. Taps inside an occupied range are ignored.
  void _handleFreeTimeTap(double localDy) {
    final rawMinutes = (localDy - _blocksOffsetY) / _pixelsPerMinute;
    final snapped = (rawMinutes / _tapSnapMinutes).floor() * _tapSnapMinutes;
    if (snapped < 0) return;

    final start = baseDate.add(Duration(minutes: snapped));
    if (!start.isBefore(_endOfDay)) return;

    DateTime gapEnd = _endOfDay;
    for (final block in _occupiedBlocks()) {
      if (_isBeingEdited(block)) continue;
      if (!start.isBefore(block.startTime) && start.isBefore(block.endTime)) {
        return;
      }
      if (!block.startTime.isBefore(start) &&
          block.startTime.isBefore(gapEnd)) {
        gapEnd = block.startTime;
      }
    }

    final available = gapEnd.difference(start).inMinutes;
    if (available < _minSlotMinutes) return;

    final end = start.add(
      Duration(
        minutes: available < _defaultSlotMinutes
            ? available
            : _defaultSlotMinutes,
      ),
    );
    _selectSlot(start, end);
  }

  // Avoid a record-pattern switch over (block, editingItem) here: the Dart AOT
  // compiler miscompiles it when editingItem is null, causing a SIGSEGV in
  // release builds (debug/JIT builds are unaffected).
  bool _isBeingEdited(_TimelineBlock block) {
    final editing = editingItem;
    if (block is _TaskBlock && editing is EditingScheduledTask) {
      return block.scheduledTask.id == editing.scheduledTask.id;
    }
    if (block is _HabitBlock && editing is EditingHabitOccurrence) {
      return block.occurrence.id == editing.occurrence.id;
    }
    return false;
  }

  List<_TimelineBlock> _generateTimelineBlocks() {
    final List<_TimelineBlock> blocks = [
      for (final item in _occupiedBlocks())
        if (!_isBeingEdited(item)) item,
    ];

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

  Widget _buildFreeTimeTapLayer() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) => _handleFreeTimeTap(details.localPosition.dy),
      ),
    );
  }

  Widget _buildEmptyDayHint() {
    final color = CadenceColors.textSecondary.withValues(alpha: 0.4);

    return Positioned(
      top: _blocksOffsetY + 24,
      left: _leftOffset + 15,
      right: _rightOffset,
      child: IgnorePointer(
        child: Row(
          spacing: 8,
          children: [
            Icon(Icons.touch_app_outlined, size: 14, color: color),
            Expanded(
              child: Text(
                'TAP A FREE TIME TO ADD A BLOCK',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
      _InteractiveBlock() => _buildInteractiveSlotBlock(
        block.startTime,
        block.endTime,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final blocks = _generateTimelineBlocks();
    final bool allowTapToCreate = canCreateSlot && selectedTimeSlot == null;
    final bool isDayEmpty = scheduledTasks.isEmpty && placedHabits.isEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 30, bottom: 150),
      child: SizedBox(
        width: double.infinity,
        height:
            (24 - baseDate.hour) * 60 * _pixelsPerMinute + _blocksOffsetY * 2,
        child: Stack(
          children: [
            _buildTimeGrid(),
            if (allowTapToCreate) _buildFreeTimeTapLayer(),
            if (allowTapToCreate && isDayEmpty) _buildEmptyDayHint(),
            for (final block in blocks) _buildSpecificBlock(block),
          ],
        ),
      ),
    );
  }
}
