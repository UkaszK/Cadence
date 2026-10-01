import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class CadenceSwitch<T> extends StatelessWidget {
  CadenceSwitch({
    super.key,
    required this.options,
    required this.selection,
    required this.onChange,
    required this.labelOf,
    Color Function(T)? primaryColorOf,
  }) : primaryColorOf = primaryColorOf ?? ((_) => CadenceColors.accent);

  final List<T> options;
  final T selection;
  final String Function(T) labelOf;
  final Color Function(T) primaryColorOf;
  final void Function(T) onChange;

  Widget _buildSwitchButton({
    required String label,
    required Color primaryColor,
    required Color backgroundColor,

    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.all(3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: backgroundColor,
            ),
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: CadenceColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          for (final option in options)
            _buildSwitchButton(
              label: labelOf(option),
              primaryColor: option == selection
                  ? primaryColorOf(option)
                  : CadenceColors.textSecondary,
              backgroundColor: option == selection
                  ? CadenceColors.textPrimary.withValues(alpha: 0.1)
                  : Colors.transparent,
              onTap: () => onChange(option),
            ),
        ],
      ),
    );
  }
}
