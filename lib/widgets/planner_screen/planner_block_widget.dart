import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

/// A block on the planner timeline. Used for both scheduled tasks and placed
/// habit occurrences.
class PlannerBlockWidget extends StatelessWidget {
  const PlannerBlockWidget({
    super.key,
    required this.title,
    required this.timeText,
    required this.timeTextOneLine,
    required this.color,
    this.description = '',
    this.isHabit = false,
    required this.onTap,
  });

  final String title;
  final String timeText;
  final String timeTextOneLine;
  final Color color;
  final String description;
  final bool isHabit;
  final VoidCallback onTap;

  bool get _hasDescription => description.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final borderWidth = 1.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isHabit ? color.withValues(alpha: 0.08) : null,
          border: Border.all(color: color, width: borderWidth),
        ),
        child: LayoutBuilder(
          builder: ((context, constraints) {
            final availableHeight = constraints.maxHeight + borderWidth * 2;

            final isTiny = availableHeight < 30;
            if (isTiny) return const SizedBox.expand();

            final isSmall = availableHeight < 60;
            final isLarge = availableHeight >= 82;

            final time = isSmall ? timeTextOneLine : timeText;

            return Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 10,
                vertical: isSmall ? 0 : 10,
              ),
              child: Column(
                mainAxisAlignment: isSmall
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isSmall, time),
                  if (isLarge && _hasDescription) _buildDescription(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isSmall
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHabit) ...[
                Icon(Icons.repeat, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Text(
          time,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textPrimary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
