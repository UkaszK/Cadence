import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cadence/theme/cadence_colors.dart';

/// "Every N days" picker with a start date. N below [minIntervalDays] is
/// rejected with a hint to use the weekday schedule instead.
class FormIntervalField extends StatelessWidget {
  const FormIntervalField({
    super.key,
    required this.intervalDays,
    required this.startDate,
    required this.onIntervalChange,
    required this.onStartDateChange,
    this.minIntervalDays = 2,
    this.maxIntervalDays = 30,
  });

  final int intervalDays;
  final DateTime startDate;
  final int minIntervalDays;
  final int maxIntervalDays;
  final void Function(int) onIntervalChange;
  final void Function(DateTime) onStartDateChange;

  bool get _isTooSmall => intervalDays < minIntervalDays;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: CadenceColors.otherAccent,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) onStartDateChange(picked);
  }

  Widget _stepButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: CadenceColors.border),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? CadenceColors.textSecondary.withValues(alpha: 0.3)
              : CadenceColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          'REPEAT EVERY',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

        Row(
          spacing: 10,
          children: [
            _stepButton(
              Icons.remove,
              intervalDays > minIntervalDays
                  ? () => onIntervalChange(intervalDays - 1)
                  : null,
            ),
            Expanded(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isTooSmall
                        ? CadenceColors.danger
                        : CadenceColors.border,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$intervalDays DAYS',
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.otherAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            _stepButton(
              Icons.add,
              intervalDays < maxIntervalDays
                  ? () => onIntervalChange(intervalDays + 1)
                  : null,
            ),
          ],
        ),

        if (_isTooSmall)
          Text(
            'Use the weekday schedule for daily habits',
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.danger,
              fontSize: 10,
            ),
          ),

        const SizedBox(height: 4),

        Text(
          'STARTING ON',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

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
              spacing: 16,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: CadenceColors.textSecondary,
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(startDate),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: CadenceColors.otherAccent,
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
