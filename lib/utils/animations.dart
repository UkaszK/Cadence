import 'dart:async';

import 'package:flutter/material.dart';

/// Common animation durations used throughout the app.
class AnimationDurations {
  static const Duration veryFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Shared motion language: short, decisive, and skipped when reduced motion is on.
class CadenceMotion {
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;

  static Duration of(BuildContext context, Duration duration) {
    if (MediaQuery.disableAnimationsOf(context)) return Duration.zero;
    return duration;
  }
}

/// Starts [controller] after [delay]. Returns a timer that must be cancelled.
///
/// Call from [State.didChangeDependencies] so reduced-motion can snap to the
/// end before the first frame.
Timer? scheduleCadenceEntrance(
  State state,
  AnimationController controller, {
  Duration delay = Duration.zero,
}) {
  void start() {
    if (!state.mounted) return;
    if (MediaQuery.disableAnimationsOf(state.context)) {
      controller.value = 1;
    } else {
      controller.forward();
    }
  }

  if (delay == Duration.zero || MediaQuery.disableAnimationsOf(state.context)) {
    start();
    return null;
  }
  return Timer(delay, start);
}

/// Helper to create a smooth fade-in transition for content appearing on screen.
class FadeInTransition extends StatefulWidget {
  const FadeInTransition({
    super.key,
    required this.child,
    this.duration = AnimationDurations.medium,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  Timer? _timer;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: CadenceMotion.enter,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _timer = scheduleCadenceEntrance(this, _controller, delay: widget.delay);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        return Opacity(
          opacity: _progress.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _progress.value) * 12),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Helper to create a slide-in-from-top transition.
class SlideInTransition extends StatefulWidget {
  const SlideInTransition({
    super.key,
    required this.child,
    this.duration = AnimationDurations.medium,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<SlideInTransition> createState() => _SlideInTransitionState();
}

class _SlideInTransitionState extends State<SlideInTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  Timer? _timer;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _offset = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: CadenceMotion.enter));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _timer = scheduleCadenceEntrance(this, _controller, delay: widget.delay);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offset, child: widget.child);
  }
}

/// Helper to create a scale-pop animation (scales from 0.8 to 1.0).
class ScalePopTransition extends StatefulWidget {
  const ScalePopTransition({
    super.key,
    required this.child,
    this.duration = AnimationDurations.medium,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<ScalePopTransition> createState() => _ScalePopTransitionState();
}

class _ScalePopTransitionState extends State<ScalePopTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  Timer? _timer;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _timer = scheduleCadenceEntrance(this, _controller, delay: widget.delay);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

/// Animates a widget sliding out to the right and fading out.
/// Calls [onComplete] when the animation finishes.
class SlideOutTransition extends StatefulWidget {
  const SlideOutTransition({
    super.key,
    required this.child,
    required this.animate,
    this.duration = AnimationDurations.medium,
    this.onComplete,
  });

  final Widget child;
  final bool animate;
  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<SlideOutTransition> createState() => _SlideOutTransitionState();
}

class _SlideOutTransitionState extends State<SlideOutTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.2, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: CadenceMotion.exit));
    _opacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: CadenceMotion.exit));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(SlideOutTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onComplete?.call();
        });
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

/// A checkbox with a scale pulse animation on toggle.
class AnimatedCheckbox extends StatefulWidget {
  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.blue,
    this.checkColor,
    this.side,
  });

  final bool value;
  final void Function(bool) onChanged;
  final Color activeColor;
  final Color? checkColor;
  final BorderSide? side;

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.veryFast,
    );
    _scale = Tween<double>(
      begin: 1,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(bool? newValue) {
    if (newValue == null) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onChanged(newValue);
      return;
    }
    _controller.forward().then((_) {
      if (mounted) _controller.reverse();
    });
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Checkbox(
        value: widget.value,
        onChanged: _onChanged,
        activeColor: widget.activeColor,
        checkColor: widget.checkColor,
        side: widget.side,
      ),
    );
  }
}

/// Scales down while a pointer is down. Does not handle the tap itself.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.scale = 0.96});

  final Widget child;
  final double scale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  var _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed && !reduced ? widget.scale : 1,
        duration: reduced ? Duration.zero : const Duration(milliseconds: 120),
        curve: CadenceMotion.enter,
        child: widget.child,
      ),
    );
  }
}

/// Brief scale pulse when [value] changes. Skips the first build.
class CadencePulseOnChange<T> extends StatefulWidget {
  const CadencePulseOnChange({
    super.key,
    required this.value,
    required this.child,
    this.scale = 1.06,
  });

  final T value;
  final Widget child;
  final double scale;

  @override
  State<CadencePulseOnChange<T>> createState() =>
      _CadencePulseOnChangeState<T>();
}

class _CadencePulseOnChangeState<T> extends State<CadencePulseOnChange<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.medium,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: widget.scale,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.scale,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(CadencePulseOnChange<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

/// Crossfades and slides when [value] changes. Direction comes from
/// [directionOf]: positive enters from the right (or below).
class CadenceValueSwitcher<T> extends StatefulWidget {
  const CadenceValueSwitcher({
    super.key,
    required this.value,
    required this.builder,
    this.directionOf,
    this.axis = Axis.horizontal,
    this.duration = AnimationDurations.fast,
    this.slideFraction = 0.08,
  });

  final T value;
  final Widget Function(T value) builder;
  final int Function(T previous, T next)? directionOf;
  final Axis axis;
  final Duration duration;
  final double slideFraction;

  @override
  State<CadenceValueSwitcher<T>> createState() =>
      _CadenceValueSwitcherState<T>();
}

class _CadenceValueSwitcherState<T> extends State<CadenceValueSwitcher<T>> {
  var _direction = 1;

  @override
  void didUpdateWidget(CadenceValueSwitcher<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    final direction =
        widget.directionOf?.call(oldWidget.value, widget.value) ?? 1;
    _direction = direction == 0 ? 1 : direction.sign;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CadenceMotion.of(context, widget.duration),
      switchInCurve: CadenceMotion.enter,
      switchOutCurve: CadenceMotion.exit,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey<T>(widget.value);
        final sign = incoming ? _direction : -_direction;
        final begin = widget.axis == Axis.horizontal
            ? Offset(sign * widget.slideFraction, 0)
            : Offset(0, sign * widget.slideFraction);
        return ClipRect(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<T>(widget.value),
        child: widget.builder(widget.value),
      ),
    );
  }
}

/// Keeps every tab alive and slides between them. Later tabs enter from the right.
class CadenceTabSwitcher extends StatefulWidget {
  const CadenceTabSwitcher({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<CadenceTabSwitcher> createState() => _CadenceTabSwitcherState();
}

class _CadenceTabSwitcherState extends State<CadenceTabSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _current;
  int? _outgoing;

  @override
  void initState() {
    super.initState();
    _current = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: AnimationDurations.fast,
      value: 1,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _outgoing != null && mounted) {
        setState(() => _outgoing = null);
      }
    });
  }

  @override
  void didUpdateWidget(CadenceTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == _current) return;
    _outgoing = _current;
    _current = widget.index;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _outgoing = null;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacityFor(int index) {
    if (index == _current) return _outgoing == null ? 1 : _controller.value;
    if (index == _outgoing) return 1 - _controller.value;
    return 0;
  }

  Offset _offsetFor(int index) {
    if (_outgoing == null) return Offset.zero;
    final forward = _current > _outgoing!;
    const travel = 28.0;
    if (index == _current) {
      final from = forward ? travel : -travel;
      return Offset(from * (1 - _controller.value), 0);
    }
    if (index == _outgoing) {
      final to = forward ? -travel : travel;
      return Offset(to * _controller.value, 0);
    }
    return Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final paintOrder = [
      for (var i = 0; i < widget.children.length; i++)
        if (i != _current) i,
      _current,
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            for (final i in paintOrder)
              Positioned.fill(
                child: Offstage(
                  offstage: i != _current && i != _outgoing,
                  child: IgnorePointer(
                    ignoring: i != _current,
                    child: Opacity(
                      opacity: _opacityFor(i),
                      child: Transform.translate(
                        offset: _offsetFor(i),
                        child: widget.children[i],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Fade and slight rise for pushed routes. iOS keeps the cupertino transition
/// so the interactive back swipe still works.
class CadencePageTransitionsBuilder extends PageTransitionsBuilder {
  const CadencePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final incoming = CurvedAnimation(
      parent: animation,
      curve: CadenceMotion.enter,
      reverseCurve: CadenceMotion.exit,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: CadenceMotion.enter,
      reverseCurve: CadenceMotion.exit,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.94).animate(outgoing),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.985).animate(outgoing),
        child: FadeTransition(
          opacity: incoming,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(incoming),
            child: child,
          ),
        ),
      ),
    );
  }
}
