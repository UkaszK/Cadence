import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/day.dart';
import 'package:cadence/theme/cadence_colors.dart';

class FormDaySelector extends StatefulWidget {
  const FormDaySelector({
    super.key,
    required this.weekdays,
    required this.selection,
    required this.onChange,
  });

  final Set<Day> weekdays;
  final Set<Day> selection;
  final void Function(Set<Day>) onChange;

  @override
  State<StatefulWidget> createState() => _FormDaySelectorState();
}

class _FormDaySelectorState extends State<FormDaySelector> {
  void _updateItems(Day day, bool selected) {
    final updated = {...widget.selection};
    if (selected) {
      updated.add(day);
    } else {
      updated.remove(day);
    }

    widget.onChange(updated);
  }

  Widget _buildDayItem(Day day) {
    bool isSelected = widget.selection.contains(day);

    return InkWell(
      onTap: () => _updateItems(day, !isSelected),
      borderRadius: BorderRadius.circular(5),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? CadenceColors.otherAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: CadenceColors.border),
        ),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Text(
              textAlign: TextAlign.center,
              day.label[0],
              style: GoogleFonts.jetBrainsMono(
                color: isSelected ? Colors.black : CadenceColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ON WEEKDAYS',
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 8),

          SingleChildScrollView(
            physics: ScrollPhysics(parent: ClampingScrollPhysics()),
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10,
              children: [for (final day in widget.weekdays) _buildDayItem(day)],
            ),
          ),
        ],
      ),
    );
  }
}
