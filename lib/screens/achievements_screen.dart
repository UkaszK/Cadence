import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/utils/animations.dart';
import 'package:cadence/data/gamification_metrics.dart';
import 'package:cadence/providers/achievement_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/achievements_screen/achievement_badge_tile.dart';
import 'package:cadence/widgets/achievements_screen/achievement_detail_sheet.dart';
import 'package:cadence/widgets/achievements_screen/streak_card.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';
import 'package:cadence/widgets/cadence_loading_screen.dart';
import 'package:cadence/widgets/reusables/cadence_new_screen_container.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationAsync = ref.watch(gamificationStateProvider);

    return gamificationAsync.when(
      data: (metrics) => CadenceNewScreenContainer(
        spacing: 25,
        children: [
          _Header(metrics: metrics),
          StreakCard(metrics: metrics),
          _BadgeGrid(metrics: metrics),
        ],
      ),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error loading: $error'))),
      loading: () => const Scaffold(body: CadenceLoadingScreen()),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.metrics});

  final GamificationMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACHIEVEMENTS',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${metrics.earnedBadges} / ${metrics.totalBadges} BADGES EARNED',
                style: analyticsCaptionStyle(),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: metrics.totalBadges == 0
                    ? 0
                    : metrics.earnedBadges / metrics.totalBadges,
                strokeWidth: 3,
                backgroundColor: CadenceColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CadenceColors.accent,
                ),
              ),
              Text(
                '${((metrics.earnedBadges / metrics.totalBadges) * 100).round()}%',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.metrics});

  final GamificationMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CadenceSectionHeader(
          title: 'BADGES',
          icon: Icons.military_tech,
          iconColor: CadenceColors.accent,
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            for (var i = 0; i < metrics.achievements.length; i++)
              FadeInTransition(
                delay: Duration(milliseconds: 30 * i.clamp(0, 8)),
                child: AchievementBadgeTile(
                  achievement: metrics.achievements[i],
                  onTap: () => showAchievementDetailSheet(
                    context,
                    metrics.achievements[i],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
