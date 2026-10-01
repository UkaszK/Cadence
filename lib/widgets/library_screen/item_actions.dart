import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/reusables/cadence_button.dart';

class ItemIconButton extends StatelessWidget {
  const ItemIconButton({super.key, required this.icon, required this.onPress});

  final IconData icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        radius: 10,
        customBorder: const CircleBorder(),
        onTap: onPress,
        child: Container(
          padding: EdgeInsets.all(5),
          child: Icon(icon, size: 16, color: CadenceColors.textSecondary),
        ),
      ),
    );
  }
}

/// Asks the user to confirm archiving [name]. Returns true when confirmed.
Future<bool> confirmArchive(
  BuildContext context, {
  required String name,
  required String kind,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: CadenceColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CadenceColors.warning, width: 0.67),
            boxShadow: [
              BoxShadow(
                color: CadenceColors.warning.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  'ARCHIVE ${kind.toUpperCase()}',
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.warning,
                    fontSize: 16,
                    fontWeight: .w900,
                  ),
                ),

                const SizedBox(height: 20),

                Text.rich(
                  TextSpan(
                    text: 'Archive ',
                    children: [
                      TextSpan(
                        text: '"$name"',
                        style: const TextStyle(fontWeight: .bold),
                      ),
                      TextSpan(
                        text:
                            '? It will be hidden from the library and the planner. '
                            'You can bring it back with "Show archived".',
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: CadenceColors.textPrimary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: .end,
                  spacing: 8,
                  children: [
                    CadenceButton(
                      primaryColor: CadenceColors.textSecondary,
                      onPress: () => Navigator.pop(context, false),
                      label: 'CANCEL',
                      borderColor: CadenceColors.border,
                      backgroundColor: CadenceColors.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    CadenceButton(
                      primaryColor: CadenceColors.warning,
                      backgroundColor: CadenceColors.surfaceOnSurface,
                      onPress: () => Navigator.pop(context, true),
                      prefixIcon: Icons.archive_outlined,
                      label: 'ARCHIVE',
                      glow: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result ?? false;
}
