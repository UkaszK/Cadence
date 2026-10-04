import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/constants/app_constants.dart';
import 'package:cadence/data/achievement.dart';
import 'package:cadence/data/gamification_metrics.dart';
import 'package:cadence/providers/achievement_providers.dart';
import 'package:cadence/screens/achievements_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';

typedef AchievementUnlockEvent = ({
  AchievementDefinition definition,
  AchievementTier tier,
});

/// Watches derived achievement progress and announces newly earned tiers once.
class AchievementUnlockListener extends ConsumerWidget {
  const AchievementUnlockListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<GamificationMetrics>>(gamificationStateProvider, (
      previous,
      next,
    ) {
      final metrics = next.value;
      if (metrics == null) return;

      final unlocks = ref
          .read(achievementUnlockControllerProvider.notifier)
          .sync(metrics);
      if (unlocks.isEmpty) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _showUnlockSnackBar(context, unlocks);
      });
    });

    return child;
  }
}

void _showUnlockSnackBar(
  BuildContext context,
  List<AchievementUnlockEvent> unlocks,
) {
  final highest = unlocks.last;
  final message = unlocks.length == 1
      ? '${highest.tier.label} - ${highest.definition.title}'
      : '${unlocks.length} NEW BADGES UNLOCKED';

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: CadenceColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: AppConstants.snackBarDuration,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: highest.tier.color, width: 1),
        ),
        content: Row(
          children: [
            Icon(highest.definition.icon, size: 18, color: highest.tier.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACHIEVEMENT UNLOCKED',
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: CadenceColors.accent,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementsScreen()),
          ),
        ),
      ),
    );
}
