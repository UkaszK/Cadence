import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/achievement.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

/// Grid tile showing a single achievement track and its progress.
class AchievementBadgeTile extends StatelessWidget {
  const AchievementBadgeTile({
    super.key,
    required this.achievement,
    this.onTap,
  });

  final AchievementProgress achievement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tier = achievement.tier;
    final locked = tier == null;
    final color = achievement.color;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CadenceColors.surface,
          border: Border.all(
            color: locked ? CadenceColors.border : color,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  achievement.definition.icon,
                  size: 18,
                  color: locked ? CadenceColors.border : color,
                ),
                const Spacer(),
                AchievementTierDots(achievement: achievement),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              achievement.definition.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                color: locked
                    ? CadenceColors.textSecondary
                    : CadenceColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              locked ? 'LOCKED' : tier.label,
              style: analyticsCaptionStyle(
                color: locked ? CadenceColors.textSecondary : color,
              ),
            ),

            const Spacer(),

            LinearProgressIndicator(
              value: achievement.progress,
              valueColor: AlwaysStoppedAnimation<Color>(
                locked ? CadenceColors.textSecondary : color,
              ),
              backgroundColor: CadenceColors.border,
              minHeight: 4,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),

            const SizedBox(height: 6),

            Text(achievement.goalLabel, style: analyticsCaptionStyle()),
          ],
        ),
      ),
    );
  }
}

/// Three dots indicating which of bronze / silver / gold have been earned.
class AchievementTierDots extends StatelessWidget {
  const AchievementTierDots({super.key, required this.achievement});

  final AchievementProgress achievement;

  @override
  Widget build(BuildContext context) {
    final earned = achievement.earnedTiers;

    return Row(
      spacing: 4,
      children: [
        for (final tier in AchievementTier.values)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned.contains(tier)
                  ? tier.color
                  : CadenceColors.border,
            ),
          ),
      ],
    );
  }
}
