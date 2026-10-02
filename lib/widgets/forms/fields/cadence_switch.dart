import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';

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

  @override
  Widget build(BuildContext context) {
    final selectedIndex = options
        .indexOf(selection)
        .clamp(0, options.length - 1);
    final selectedColor = primaryColorOf(options[selectedIndex]);
    final motion = CadenceMotion.of(context, AnimationDurations.fast);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: CadenceColors.border),
        borderRadius: BorderRadius.circular(5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / options.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: motion,
                curve: CadenceMotion.enter,
                left: segmentWidth * selectedIndex,
                width: segmentWidth,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CadenceColors.textPrimary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final option in options)
                    Expanded(
                      child: InkWell(
                        onTap: () => onChange(option),
                        borderRadius: BorderRadius.circular(5),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(3, 13, 3, 13),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: motion,
                              curve: CadenceMotion.enter,
                              style: GoogleFonts.jetBrainsMono(
                                color: option == selection
                                    ? selectedColor
                                    : CadenceColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              child: Text(labelOf(option)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
