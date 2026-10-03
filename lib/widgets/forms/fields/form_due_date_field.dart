import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cadence/theme/cadence_colors.dart';

class FormDueDateField extends StatelessWidget {
  const FormDueDateField({
    super.key,
    required this.selectedDate,
    required this.onChange,
  });

  final DateTime? selectedDate;
  final void Function(DateTime?) onChange;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: CadenceColors.accent,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDate = selectedDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DUE DATE (Optional)',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: CadenceColors.border),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: CadenceColors.textSecondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    hasDate
                        ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                        : 'Select Date...',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: hasDate
                          ? CadenceColors.accent
                          : CadenceColors.textSecondary,
                    ),
                  ),
                ),
                if (hasDate)
                  InkWell(
                    onTap: () => onChange(null),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: CadenceColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
