import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CadenceBadge extends StatelessWidget {
  const CadenceBadge({
    super.key,
    required this.label,
    required this.primaryColor,
    this.backgroundColor,
    this.borderColor,
    this.prefixIcon,
    this.suffixIcon,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
  });

  final String label;
  final Color primaryColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? primaryColor, width: 0.5),
        borderRadius: BorderRadiusGeometry.circular(2),
        color: backgroundColor ?? primaryColor.withValues(alpha: 0.15),
      ),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: primaryColor, size: 12),
            const SizedBox(width: 5),
          ],

          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: primaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (suffixIcon != null) ...[
            const SizedBox(width: 5),
            Icon(suffixIcon, color: primaryColor, size: 12),
          ],
        ],
      ),
    );
  }
}
