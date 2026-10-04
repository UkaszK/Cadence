import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/constants/app_constants.dart';
import 'package:cadence/data/gamification_metrics.dart';
import 'package:cadence/providers/achievement_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';

/// Watches the derived current streak and celebrates every in-session
/// increase. The streak only grows when the first completion of the day
/// lands, so an increase means exactly that moment. When the increase passes
/// the best streak so far, a record variant is shown instead.
class StreakUpListener extends ConsumerWidget {
  const StreakUpListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<GamificationMetrics>>(gamificationStateProvider, (
      previous,
      next,
    ) {
      final oldStreak = previous?.value?.currentStreak;
      final oldBest = previous?.value?.bestStreak;
      final newStreak = next.value?.currentStreak;
      // A null previous value is the initial load, not an upgrade.
      if (oldStreak == null ||
          oldBest == null ||
          newStreak == null ||
          newStreak <= oldStreak) {
        return;
      }

      // Passing the best streak shown on the achievements page is a record.
      // The very first streak has nothing to beat yet.
      final previousBest = oldBest > 0 && newStreak > oldBest ? oldBest : null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _showStreakUpSnackBar(context, oldStreak, newStreak, previousBest);
      });
    });

    return child;
  }
}

void _showStreakUpSnackBar(
  BuildContext context,
  int oldStreak,
  int newStreak,
  int? previousBest,
) {
  final color = previousBest == null
      ? CadenceColors.otherAccent
      : CadenceColors.gold;

  // No hideCurrentSnackBar(): let this queue behind any achievement snackbar
  // triggered by the same completion instead of dismissing it.
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: CadenceColors.surface,
      behavior: SnackBarBehavior.floating,
      duration: AppConstants.snackBarDuration,
      shape: RoundedRectangleBorder(side: BorderSide(color: color, width: 1)),
      content: _StreakUpSnackBarContent(
        oldStreak: oldStreak,
        newStreak: newStreak,
        previousBest: previousBest,
      ),
    ),
  );
}

class _StreakUpSnackBarContent extends StatefulWidget {
  const _StreakUpSnackBarContent({
    required this.oldStreak,
    required this.newStreak,
    required this.previousBest,
  });

  final int oldStreak;
  final int newStreak;

  /// Set when this upgrade beats the all-time best.
  final int? previousBest;

  @override
  State<_StreakUpSnackBarContent> createState() =>
      _StreakUpSnackBarContentState();
}

class _StreakUpSnackBarContentState extends State<_StreakUpSnackBarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flameScale;

  bool _showNew = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _flameScale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(
              begin: 1.0,
              end: 1.5,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 1.5,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.bounceOut)),
            weight: 60,
          ),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
        );

    // Hold the old number briefly, then swap in the new one.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _showNew = true);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecord = widget.previousBest != null;
    final color = isRecord ? CadenceColors.gold : CadenceColors.otherAccent;

    return Row(
      children: [
        ScaleTransition(
          scale: _flameScale,
          child: Icon(
            isRecord ? Icons.emoji_events : Icons.local_fire_department,
            size: 22,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRecord ? 'NEW RECORD!' : 'STREAK UP!',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    transitionBuilder: (child, animation) {
                      final isNew = child.key == const ValueKey('new');
                      final slide =
                          Tween<Offset>(
                            begin: isNew
                                ? const Offset(0, 1)
                                : const Offset(0, -1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: isNew ? Curves.easeOutBack : Curves.easeIn,
                            ),
                          );
                      return ClipRect(
                        child: SlideTransition(
                          position: slide,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      _showNew
                          ? '${widget.newStreak}D'
                          : '${widget.oldStreak}D',
                      key: ValueKey(_showNew ? 'new' : 'old'),
                      style: GoogleFonts.jetBrainsMono(
                        color: isRecord
                            ? CadenceColors.gold
                            : CadenceColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (isRecord) ...[
                    const SizedBox(width: 10),
                    Text(
                      'PREVIOUS BEST ${widget.previousBest}D STREAK',
                      style: GoogleFonts.jetBrainsMono(
                        color: CadenceColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
