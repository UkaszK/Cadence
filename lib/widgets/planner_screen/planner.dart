import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/providers/planner_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/sleep_time.dart';
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

class Planner extends StatefulWidget {
  const Planner({
    super.key,
    required this.scrollController,
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
    this.sleepRanges = const [],
  });

  final DateTime baseDate;
  final ScrollController scrollController;
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

  /// Planned sleep shown as a purely visual band behind the timeline.
  final List<SleepRange> sleepRanges;

  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {
  static const _pixelsPerMinute = 1.0;
  static const _leftOffset = 70.0;
  static const _rightOffset = 15.0;
  static const _dragStepMinutes = 5;
  static const _blocksOffsetY = 8.0;
  static const _tapSnapMinutes = 15;
  static const _defaultSlotMinutes = 60;
  static const _minSlotMinutes = 15;

  DateTime get _endOfDay =>
      widget.baseDate.add(const Duration(hours: 23, minutes: 59));

  void _selectSlot(DateTime start, DateTime end) {
    widget.onSelectTimeSlot((startTime: start, endTime: end));
    widget.onUpdateTimeSlot((startTime: start, endTime: end));
  }

  List<_TimelineBlock> _occupiedBlocks() {
    return <_TimelineBlock>[
      for (final t in widget.scheduledTasks) _TaskBlock(t),
      for (final h in widget.placedHabits) _HabitBlock(h),
    ]..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Opens a slot at the tapped time, snapped to [_tapSnapMinutes] and sized
  /// to [_defaultSlotMinutes] unless an existing block or the end of the day
  /// comes first. Taps inside an occupied range are ignored.
  void _handleFreeTimeTap(double localDy) {
    final rawMinutes = (localDy - _blocksOffsetY) / _pixelsPerMinute;
    final snapped = (rawMinutes / _tapSnapMinutes).floor() * _tapSnapMinutes;
    if (snapped < 0) return;

    final start = widget.baseDate.add(Duration(minutes: snapped));
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
    final editing = widget.editingItem;
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

    if (widget.selectedTimeSlot != null) {
      blocks.add(
        _InteractiveBlock(
          widget.selectedTimeSlot!.startTime,
          widget.selectedTimeSlot!.endTime,
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

    for (int hour = widget.baseDate.hour; hour <= 24; hour += 2) {
      double topPosition =
          (hour - widget.baseDate.hour) * 60 * _pixelsPerMinute;

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
    int minutesFromStart = start.difference(widget.baseDate).inMinutes;
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
        onTap: () => widget.onSelectExistingTask(scheduledTask),
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
        onTap: () => widget.onSelectExistingHabit(occurrence),
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

  Widget _buildSleepBand(SleepRange range) {
    final dayStart = widget.baseDate.hour * 60;
    final start = (range.start - dayStart).clamp(0, minutesPerDay);
    final end = (range.end - dayStart).clamp(0, minutesPerDay);
    if (end <= start) return const SizedBox.shrink();

    final reachesDayStart = range.start == 0;
    final reachesDayEnd = range.end == minutesPerDay;
    final color = CadenceColors.info;
    final edge = BorderSide(color: color.withValues(alpha: 0.35));
    final label = reachesDayStart
        ? 'WAKE UP · ${formatMinutesOfDay(range.end)}'
        : reachesDayEnd
        ? 'BEDTIME · ${formatMinutesOfDay(range.start)}'
        : 'SLEEP · ${formatMinutesOfDay(range.start)} – '
              '${formatMinutesOfDay(range.end)}';
    final height = (end - start) * _pixelsPerMinute;

    return Positioned(
      top: start * _pixelsPerMinute + _blocksOffsetY,
      height: height,
      left: _leftOffset + 1,
      right: 0,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.02),
            border: Border(
              top: reachesDayStart ? BorderSide.none : edge,
              bottom: reachesDayEnd ? BorderSide.none : edge,
            ),
          ),
          child: height < 20
              ? null
              : Align(
                  // Keep the label next to the edge where sleep begins or ends.
                  alignment: reachesDayStart
                      ? Alignment.bottomLeft
                      : Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 4, 8, 4),
                    child: Row(
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.bedtime_outlined,
                          size: 12,
                          color: color.withValues(alpha: 0.7),
                        ),
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              color: color.withValues(alpha: 0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInteractiveSlotBlock(DateTime start, DateTime end) {
    final slotColor = widget.hasOverlap
        ? CadenceColors.danger
        : CadenceColors.accent;

    return _positioned(
      start: start,
      end: end,
      child: InteractiveBlockWidget(
        scrollController: widget.scrollController,
        baseDate: widget.baseDate,
        startTime: start,
        endTime: end,
        color: slotColor,
        onUpdateTimeSlot: widget.onUpdateTimeSlot,
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
    final bool allowTapToCreate =
        widget.canCreateSlot && widget.selectedTimeSlot == null;
    final bool isDayEmpty =
        widget.scheduledTasks.isEmpty && widget.placedHabits.isEmpty;

    return Padding(
      padding: EdgeInsets.only(top: 30, bottom: 150),
      child: SizedBox(
        width: double.infinity,
        height:
            (24 - widget.baseDate.hour) * 60 * _pixelsPerMinute +
            _blocksOffsetY * 2,
        child: Stack(
          children: [
            _buildTimeGrid(),
            for (final range in widget.sleepRanges) _buildSleepBand(range),
            if (allowTapToCreate) _buildFreeTimeTapLayer(),
            if (allowTapToCreate && isDayEmpty) _buildEmptyDayHint(),
            for (final block in blocks) _buildSpecificBlock(block),
          ],
        ),
      ),
    );
  }
}
