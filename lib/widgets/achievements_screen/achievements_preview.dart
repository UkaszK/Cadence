import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/gamification_metrics.dart';
import 'package:cadence/providers/achievement_providers.dart';
import 'package:cadence/screens/achievements_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/achievements_screen/achievement_badge_tile.dart';
import 'package:cadence/widgets/achievements_screen/achievement_detail_sheet.dart';
import 'package:cadence/widgets/achievements_screen/streak_card.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

/// Streak plus the badges closest to their next tier, with a link to the full
/// achievements screen. Rendered as a section of the analytics screen.
class AchievementsPreview extends ConsumerWidget {
  const AchievementsPreview({super.key});

  static const int _previewCount = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationStateProvider);

    return gamificationAsync.maybeWhen(
      data: (metrics) => _Content(metrics: metrics),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.metrics});

  final GamificationMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final preview = metrics.nearestToNextTier
        .take(AchievementsPreview._previewCount)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CadenceSectionHeader(
          title: 'ACHIEVEMENTS',
          icon: Icons.military_tech,
          iconColor: CadenceColors.accent,
          rightSide: _ViewAllButton(
            label: '${metrics.earnedBadges}/${metrics.totalBadges}',
          ),
          crossAxisAlignment: CrossAxisAlignment.end,
        ),

        const SizedBox(height: 12),

        StreakCard(metrics: metrics),

        if (preview.isNotEmpty) ...[
          const SizedBox(height: 12),

          SizedBox(
            height: 150,
            child: Row(
              spacing: 12,
              children: [
                for (final achievement in preview)
                  Expanded(
                    child: AchievementBadgeTile(
                      achievement: achievement,
                      onTap: () =>
                          showAchievementDetailSheet(context, achievement),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AchievementsScreen()),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Text(
              'VIEW ALL $label',
              style: analyticsCaptionStyle(color: CadenceColors.accent),
            ),
            const Icon(
              Icons.chevron_right,
              size: 14,
              color: CadenceColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
