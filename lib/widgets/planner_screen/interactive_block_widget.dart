import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_time_text.dart';

class InteractiveBlockWidget extends StatefulWidget {
  const InteractiveBlockWidget({
    super.key,
    required this.baseDate,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.onUpdateTimeSlot,
    required this.dragStepMinutes,
  });

  final DateTime baseDate;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final ValueChanged<TimeSlot> onUpdateTimeSlot;
  final int dragStepMinutes;

  @override
  State<InteractiveBlockWidget> createState() => _InteractiveBlockWidgetState();
}

class _InteractiveBlockWidgetState extends State<InteractiveBlockWidget> {
  late DateTime _startTime;
  late DateTime _endTime;
  late int _dragStepMinutes;
  double _dragAccumulator = 0.0;

  DateTime get _endOfDay =>
      widget.baseDate.add(const Duration(hours: 23, minutes: 59));

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
    _dragStepMinutes = widget.dragStepMinutes;
  }

  @override
  void didUpdateWidget(covariant InteractiveBlockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTime != oldWidget.startTime ||
        widget.endTime != oldWidget.endTime) {
      _startTime = widget.startTime;
      _endTime = widget.endTime;
    }
  }

  DateTime _snapToDragStep(DateTime time) {
    final minutesSinceBase = time.difference(widget.baseDate).inMinutes;
    final snapped =
        (minutesSinceBase / _dragStepMinutes).round() * _dragStepMinutes;
    return widget.baseDate.add(Duration(minutes: snapped));
  }

  void _notifyTimeSlotUpdated() {
    widget.onUpdateTimeSlot((startTime: _startTime, endTime: _endTime));
  }

  void _moveBlock(int minutes) {
    final duration = _endTime.difference(_startTime);
    var newStart = _startTime.add(Duration(minutes: minutes));
    var newEnd = newStart.add(duration);

    if (newStart.isBefore(widget.baseDate)) {
      newStart = widget.baseDate;
      newEnd = newStart.add(duration);
    } else if (newEnd.isAfter(_endOfDay)) {
      newEnd = _endOfDay;
      newStart = newEnd.subtract(duration);
    }

    setState(() {
      _startTime = newStart;
      _endTime = newEnd;
    });
    _notifyTimeSlotUpdated();
  }

  void _snapMovedBlock() {
    final duration = _endTime.difference(_startTime);
    var newStart = _snapToDragStep(_startTime);
    var newEnd = newStart.add(duration);

    if (newStart.isBefore(widget.baseDate)) {
      newStart = widget.baseDate;
      newEnd = newStart.add(duration);
    } else if (newEnd.isAfter(_endOfDay)) {
      newEnd = _endOfDay;
      newStart = newEnd.subtract(duration);
    }

    setState(() {
      _startTime = newStart;
      _endTime = newEnd;
    });
    _notifyTimeSlotUpdated();
  }

  void _resizeStart(int minutes) {
    var newStart = _startTime.add(Duration(minutes: minutes));
    if (newStart.isBefore(widget.baseDate)) newStart = widget.baseDate;

    if (newStart.isBefore(_endTime.subtract(const Duration(minutes: 15)))) {
      setState(() => _startTime = newStart);
      _notifyTimeSlotUpdated();
    }
  }

  void _resizeEnd(int minutes) {
    var newEnd = _endTime.add(Duration(minutes: minutes));
    if (newEnd.isAfter(_endOfDay)) newEnd = _endOfDay;

    if (newEnd.isAfter(_startTime.add(const Duration(minutes: 15)))) {
      setState(() => _endTime = newEnd);
      _notifyTimeSlotUpdated();
    }
  }

  void _snapResizedStart() {
    var newStart = _snapToDragStep(_startTime);
    if (newStart.isBefore(widget.baseDate)) newStart = widget.baseDate;

    if (newStart.isBefore(_endTime.subtract(const Duration(minutes: 15)))) {
      setState(() => _startTime = newStart);
      _notifyTimeSlotUpdated();
    }
  }

  void _snapResizedEnd() {
    var newEnd = _snapToDragStep(_endTime);
    if (newEnd.isAfter(_endOfDay)) newEnd = _endOfDay;

    if (newEnd.isAfter(_startTime.add(const Duration(minutes: 15)))) {
      setState(() => _endTime = newEnd);
      _notifyTimeSlotUpdated();
    }
  }

  void _accumulateFreeDrag(double delta) {
    _dragAccumulator += delta;
    final minutes = _dragAccumulator.round();
    if (minutes == 0) return;

    _dragAccumulator -= minutes;
    _moveBlock(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final duration = _endTime.difference(_startTime).inMinutes.toDouble();
    final smallSized = duration < 60;
    final displayedStart = _snapToDragStep(_startTime);
    final displayedEnd = _snapToDragStep(_endTime);
    final timeText = getTimeText(displayedStart, displayedEnd, !smallSized);

    return Container(
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.1),
        border: Border.all(color: widget.color, width: 2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _dragAccumulator = 0.0,
              onVerticalDragUpdate: (details) =>
                  _accumulateFreeDrag(details.delta.dy),
              onVerticalDragEnd: (_) => _snapMovedBlock(),
              child: duration >= 30
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeText,
                          style: GoogleFonts.jetBrainsMono(
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          _buildResizeHandle(
            top: true,
            onStep: _resizeStart,
            onEnd: _snapResizedStart,
          ),
          _buildResizeHandle(
            top: false,
            onStep: _resizeEnd,
            onEnd: _snapResizedEnd,
          ),
        ],
      ),
    );
  }

  Widget _buildResizeHandle({
    required bool top,
    required void Function(int) onStep,
    required VoidCallback onEnd,
  }) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragStart: (_) => _dragAccumulator = 0.0,
        onVerticalDragUpdate: (details) =>
            _accumulateFreeDragFor(details.delta.dy, onStep),
        onVerticalDragEnd: (_) => onEnd(),
        child: Container(
          height: 15,
          color: Colors.transparent,
          child: const Center(
            child: Icon(
              Icons.drag_handle,
              size: 16,
              color: CadenceColors.accent,
            ),
          ),
        ),
      ),
    );
  }

  void _accumulateFreeDragFor(double delta, void Function(int) onStep) {
    _dragAccumulator += delta;
    final minutes = _dragAccumulator.round();
    if (minutes == 0) return;

    _dragAccumulator -= minutes;
    onStep(minutes);
  }
}
