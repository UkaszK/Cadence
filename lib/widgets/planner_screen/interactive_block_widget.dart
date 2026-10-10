import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_time_text.dart';
import 'package:cadence/utils/planner_time_scale.dart';

class InteractiveBlockWidget extends StatefulWidget {
  const InteractiveBlockWidget({
    super.key,
    required this.scrollController,
    required this.baseDate,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.onUpdateTimeSlot,
    required this.dragStepMinutes,
    required this.timeScale,
  });

  final ScrollController scrollController;
  final DateTime baseDate;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final ValueChanged<TimeSlot> onUpdateTimeSlot;
  final int dragStepMinutes;

  /// Timeline scale without this block. Moving the block or its top edge is
  /// converted to minutes through it so the block follows the finger even in
  /// compressed ranges. The block itself is always drawn at normal scale, so
  /// the bottom edge maps pixels to minutes directly.
  final PlannerTimeScale timeScale;

  @override
  State<InteractiveBlockWidget> createState() => _InteractiveBlockWidgetState();
}

class _InteractiveBlockWidgetState extends State<InteractiveBlockWidget>
    with SingleTickerProviderStateMixin {
  late DateTime _startTime;
  late DateTime _endTime;
  late int _dragStepMinutes;
  double _dragAccumulator = 0.0;
  late final Ticker _edgeScrollTicker;
  RenderBox? _scrollViewport;
  double _dragDirection = 0;
  bool? _resizeTop;
  Duration _lastEdgeScrollTick = Duration.zero;
  ValueChanged<double>? _onEdgeScroll;

  DateTime get _endOfDay =>
      widget.baseDate.add(const Duration(hours: 23, minutes: 59));

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
    _dragStepMinutes = widget.dragStepMinutes;
    _edgeScrollTicker = createTicker(_scrollAtEdge);
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
    final minutes = _consumeScaledDrag(delta);
    if (minutes != 0) _moveBlock(minutes);
  }

  /// Converts accumulated drag pixels at the block's start into whole minutes
  /// along [InteractiveBlockWidget.timeScale].
  int _consumeScaledDrag(double delta) {
    _dragAccumulator += delta;
    final scale = widget.timeScale;
    final startMinute = _startTime.difference(widget.baseDate).inMinutes;
    final startY = scale.yOf(startMinute);
    final minutes = (scale.minuteAt(startY + _dragAccumulator) - startMinute)
        .round();
    if (minutes == 0) return 0;

    _dragAccumulator -= scale.yOf(startMinute + minutes) - startY;
    return minutes;
  }

  void _startDrag(ValueChanged<double> onEdgeScroll, {bool? resizeTop}) {
    _dragAccumulator = 0.0;
    _dragDirection = 0;
    _resizeTop = resizeTop;
    _onEdgeScroll = onEdgeScroll;
    _scrollViewport =
        Scrollable.of(context).context.findRenderObject() as RenderBox;
    _lastEdgeScrollTick = Duration.zero;
    _edgeScrollTicker.stop();
    _edgeScrollTicker.start();
  }

  void _updateDragDirection(double delta) {
    if (delta != 0) _dragDirection = delta.sign;
  }

  void _stopDrag() {
    _edgeScrollTicker.stop();
    _scrollViewport = null;
    _onEdgeScroll = null;
    _resizeTop = null;
    _dragDirection = 0;
  }

  void _scrollAtEdge(Duration elapsed) {
    final elapsedSeconds =
        (elapsed - _lastEdgeScrollTick).inMicroseconds / 1000000;
    _lastEdgeScrollTick = elapsed;
    final viewport = _scrollViewport;
    if (!mounted || viewport == null || !widget.scrollController.hasClients) {
      return;
    }

    final viewportTop = viewport.localToGlobal(Offset.zero).dy;
    final block = context.findRenderObject() as RenderBox;
    // Follow the leading edge when moving, or only the handle being resized.
    final useTop = _resizeTop ?? (_dragDirection < 0);
    final edgeY =
        block.localToGlobal(Offset(0, useTop ? 0 : block.size.height)).dy -
        viewportTop;
    final viewportHeight = viewport.size.height;
    const edgeSize = 64.0;
    var direction = 0.0;
    var intensity = 0.0;

    if (_dragDirection < 0 && edgeY < edgeSize) {
      direction = -1;
      intensity = ((edgeSize - edgeY) / edgeSize).clamp(0.0, 1.0);
    } else if (_dragDirection > 0 && edgeY > viewportHeight - edgeSize) {
      direction = 1;
      intensity = ((edgeY - (viewportHeight - edgeSize)) / edgeSize).clamp(
        0.0,
        1.0,
      );
    } else {
      return;
    }

    final position = widget.scrollController.position;
    final scrollDelta = direction * 360 * intensity * elapsedSeconds;
    final nextOffset = (position.pixels + scrollDelta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    final actualDelta = nextOffset - position.pixels;
    if (actualDelta == 0) return;

    widget.scrollController.jumpTo(nextOffset);
    _onEdgeScroll?.call(actualDelta);
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
              onVerticalDragStart: (_) => _startDrag(_accumulateFreeDrag),
              onVerticalDragUpdate: (details) {
                _updateDragDirection(details.delta.dy);
                _accumulateFreeDrag(details.delta.dy);
              },
              onVerticalDragEnd: (_) {
                _stopDrag();
                _snapMovedBlock();
              },
              onVerticalDragCancel: _stopDrag,
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
        onVerticalDragStart: (_) => _startDrag(
          (delta) => _accumulateFreeDragFor(delta, onStep, scaled: top),
          resizeTop: top,
        ),
        onVerticalDragUpdate: (details) {
          _updateDragDirection(details.delta.dy);
          _accumulateFreeDragFor(details.delta.dy, onStep, scaled: top);
        },
        onVerticalDragEnd: (_) {
          _stopDrag();
          onEnd();
        },
        onVerticalDragCancel: _stopDrag,
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

  void _accumulateFreeDragFor(
    double delta,
    void Function(int) onStep, {
    required bool scaled,
  }) {
    if (scaled) {
      final minutes = _consumeScaledDrag(delta);
      if (minutes != 0) onStep(minutes);
      return;
    }

    _dragAccumulator += delta;
    final minutes = _dragAccumulator.round();
    if (minutes == 0) return;

    _dragAccumulator -= minutes;
    onStep(minutes);
  }

  @override
  void dispose() {
    _stopDrag();
    _edgeScrollTicker.dispose();
    super.dispose();
  }
}
