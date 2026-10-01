import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

/// Bordered surface card used by all analytics sections.
class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: CadenceColors.border, width: 1),
        color: CadenceColors.surface,
      ),
      child: child,
    );
  }
}

/// Section header + card, with a dotted empty state when there is no data.
class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.rightSide,
    this.isEmpty = false,
    this.emptyLabel = 'NO DATA IN RANGE',
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? rightSide;
  final bool isEmpty;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CadenceSectionHeader(
          title: title,
          icon: icon,
          iconColor: CadenceColors.accent,
          rightSide: rightSide,
        ),

        const SizedBox(height: 12),

        if (isEmpty)
          Container(
            color: CadenceColors.surface,
            child: DottedBorder(
              options: RectDottedBorderOptions(
                strokeWidth: 1,
                color: CadenceColors.border,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Text(
                  emptyLabel,
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        else
          AnalyticsCard(child: child),
      ],
    );
  }
}

/// Small caption used for axis labels and secondary info.
TextStyle analyticsCaptionStyle({Color color = CadenceColors.textSecondary}) {
  return GoogleFonts.jetBrainsMono(
    color: color,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );
}

/// Color scale for completion rates.
Color analyticsRateColor(double rate) {
  if (rate >= 0.8) return CadenceColors.success;
  if (rate >= 0.5) return CadenceColors.accent;
  return CadenceColors.warning;
}

/// Label + horizontal bar + trailing text; used by list-style sections.
class AnalyticsBarRow extends StatelessWidget {
  const AnalyticsBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.trailing,
    this.leading,
    this.color = CadenceColors.accent,
    this.subLabel,
  });

  final String label;
  final String? subLabel;
  final double value;
  final String trailing;
  final Widget? leading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        color: CadenceColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(trailing, style: analyticsCaptionStyle(color: color)),
                ],
              ),

              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: CadenceColors.border,
                minHeight: 5,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),

              if (subLabel != null) ...[
                const SizedBox(height: 4),
                Text(subLabel!, style: analyticsCaptionStyle()),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
