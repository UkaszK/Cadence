import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CadenceButton extends StatelessWidget {
  const CadenceButton({
    super.key,
    required this.primaryColor,
    this.borderColor,
    this.backgroundColor,
    this.onPress,
    this.prefixIcon,
    required this.label,
    this.fontSize = 12,
    this.suffixIcon,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.glow = false,
    this.expandHorizontally = false,
  });

  final Color primaryColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final dynamic Function()? onPress;
  final IconData? prefixIcon;
  final String label;
  final double fontSize;
  final IconData? suffixIcon;
  final bool disabled;
  final EdgeInsetsGeometry? padding;
  final bool glow;
  final bool expandHorizontally;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(3);

    final updatedPrimaryColor = disabled
        ? primaryColor.withValues(alpha: 0.5)
        : primaryColor;
    final updatedBackgroundColor = disabled
        ? backgroundColor?.withValues(alpha: 0.5) ??
              primaryColor.withValues(alpha: 0.25)
        : backgroundColor ?? primaryColor.withValues(alpha: 0.1);
    final updatedBorderColor = disabled
        ? borderColor?.withValues(alpha: 0.5) ??
              primaryColor.withValues(alpha: 0.5)
        : borderColor ?? primaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: updatedPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 5,
                  blurStyle: BlurStyle.outer,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: disabled ? null : onPress,
          borderRadius: borderRadius,
          child: Ink(
            padding: padding,
            decoration: BoxDecoration(
              color: updatedBackgroundColor,
              borderRadius: borderRadius,
              border: Border.all(color: updatedBorderColor),
            ),
            child: Row(
              mainAxisSize: expandHorizontally
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: .center,
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    color: updatedPrimaryColor,
                    size: fontSize + 2.0,
                  ),
                  const SizedBox(width: 5),
                ],

                Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(
                    color: updatedPrimaryColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                if (suffixIcon != null) ...[
                  const SizedBox(width: 5),
                  Icon(suffixIcon, color: primaryColor, size: fontSize + 2.0),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
