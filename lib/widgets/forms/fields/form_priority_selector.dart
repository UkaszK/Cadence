import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/task_priority.dart';
import 'package:cadence/theme/cadence_colors.dart';

class FormPrioritySelector extends StatelessWidget {
  const FormPrioritySelector({
    super.key,
    required this.priorities,
    required this.selection,
    required this.onChange,
  });

  final List<TaskPriority> priorities;
  final TaskPriority selection;
  final void Function(TaskPriority) onChange;

  Widget _buildPriorityBox(TaskPriority priority) {
    bool isSelected = priority == selection;
    String label = priority.label.toUpperCase();
    Color color = priority.color;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () => onChange(priority),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 1,
              color: isSelected ? color : CadenceColors.border,
            ),
          ),
          alignment: AlignmentGeometry.center,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Icon(Icons.square, size: 12, color: color),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(color: color, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRIORITY',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          spacing: 10,
          children: [
            for (final priority in TaskPriority.values)
              _buildPriorityBox(priority),
          ],
        ),
      ],
    );
  }
}
