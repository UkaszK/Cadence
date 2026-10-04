import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/reusables/cadence_choice_chip_bar.dart';

class FormCategorySelector extends StatelessWidget {
  const FormCategorySelector({
    super.key,
    required this.taskCategories,
    required this.selection,
    required this.onChange,
    this.primaryColor = CadenceColors.accent,
  });

  final List<TaskCategory> taskCategories;
  final TaskCategory selection;
  final void Function(TaskCategory) onChange;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORY',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        CadenceChoiceChipBar(
          options: taskCategories,
          selection: selection,
          onChange: onChange,
          labelOf: (category) => category.name,
          iconOf: (category) => category.icon,
          primaryColorOf: (_) => primaryColor,
          style: CadenceChoiceChipBarStyle.outlined,
        ),
      ],
    );
  }
}
