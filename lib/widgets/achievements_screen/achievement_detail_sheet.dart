import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/achievement.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

/// Opens the tier breakdown for a single achievement.
Future<void> showAchievementDetailSheet(
  BuildContext context,
  AchievementProgress achievement,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => AchievementDetailSheet(achievement: achievement),
  );
}

class AchievementDetailSheet extends StatelessWidget {
  const AchievementDetailSheet({super.key, required this.achievement});

  final AchievementProgress achievement;

  @override
  Widget build(BuildContext context) {
    final definition = achievement.definition;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CadenceColors.surface,
        border: Border.all(color: CadenceColors.border, width: 1),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(definition.icon, size: 22, color: achievement.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        definition.title,
                        style: GoogleFonts.jetBrainsMono(
                          color: CadenceColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.valueLabel,
                        style: analyticsCaptionStyle(
                          color: achievement.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              definition.description,
              style: GoogleFonts.jetBrainsMono(
                color: CadenceColors.textSecondary,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 18),

            for (final tier in AchievementTier.values) ...[
              _TierRow(achievement: achievement, tier: tier),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.achievement, required this.tier});

  final AchievementProgress achievement;
  final AchievementTier tier;

  @override
  Widget build(BuildContext context) {
    final definition = achievement.definition;
    final threshold = definition.thresholdOf(tier);
    final earned = achievement.value >= threshold;

    return Row(
      children: [
        Icon(
          earned ? Icons.check_circle : Icons.lock_outline,
          size: 14,
          color: earned ? tier.color : CadenceColors.border,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            tier.label,
            style: analyticsCaptionStyle(
              color: earned ? tier.color : CadenceColors.textSecondary,
            ),
          ),
        ),

        Text(
          definition.unit.format(threshold),
          style: analyticsCaptionStyle(
            color: earned ? CadenceColors.textPrimary : CadenceColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
