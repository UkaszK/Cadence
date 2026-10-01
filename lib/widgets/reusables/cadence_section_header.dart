import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class CadenceSectionHeader extends StatelessWidget {
  const CadenceSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.rightSide,
    this.hideDivider = false,
    this.dividerStyle = (dividerDistance: 8),
    this.crossAxisAlignment = CrossAxisAlignment.end,
  });

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? rightSide;
  final bool hideDivider;
  final ({double? dividerDistance}) dividerStyle;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: iconColor),

                  const SizedBox(width: 10),
                ],

                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            rightSide ?? const SizedBox.shrink(),
          ],
        ),

        if (!hideDivider) ...[
          SizedBox(height: dividerStyle.dividerDistance),

          Divider(height: 1),
        ],
      ],
    );
  }
}
