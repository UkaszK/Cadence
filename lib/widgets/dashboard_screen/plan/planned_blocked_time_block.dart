import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/blocked_time.dart';
import 'package:cadence/theme/cadence_colors.dart';

/// Blocked time shown inside the plan. Purely informative, it can't be
/// completed.
class PlannedBlockedTimeBlock extends StatelessWidget {
  const PlannedBlockedTimeBlock({super.key, required this.blockedTime});

  final BlockedTime blockedTime;

  @override
  Widget build(BuildContext context) {
    const color = CadenceColors.blocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: color.withValues(alpha: 0.6)),
        color: color.withValues(alpha: 0.08),
      ),
      child: Row(
        spacing: 10,
        children: [
          const SizedBox(
            width: 24,
            child: Icon(Icons.block, size: 16, color: color),
          ),
          Expanded(
            child: Text(
              blockedTime.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                color: CadenceColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            blockedTime.timeTextOneLine,
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
