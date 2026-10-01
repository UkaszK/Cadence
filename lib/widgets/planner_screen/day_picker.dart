import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';

class DayPicker extends StatelessWidget {
  DayPicker({
    super.key,
    required DateTime selectedDay,
    required this.onDaySelected,
  }) : selectedDay = selectedDay.dateOnly;

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  void _shiftWeeks(int offset) {
    final updatedDate = selectedDay.add(Duration(days: offset * 7));
    onDaySelected(updatedDate);
  }

  List<Map<String, dynamic>> get availableDays {
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return List.generate(7, (index) {
      final date = selectedDay.add(
        Duration(days: index - selectedDay.weekday + 1),
      );
      return {
        'day': weekdays[index],
        'dayNum': date.day,
        'isSelected': DateUtils.isSameDay(date, selectedDay),
        'fullDate': date,
      };
    });
  }

  Widget _buildDayField(String day, int dayNum, bool isSelected) {
    final color = isSelected
        ? CadenceColors.accent
        : CadenceColors.textSecondary;

    final List<Shadow> shadows = isSelected
        ? [Shadow(color: CadenceColors.accent, blurRadius: 32)]
        : [];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: isSelected ? Border.all(color: CadenceColors.accent) : null,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: shadows,
            ),
          ),
          Text(
            dayNum.toString(),
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2000),
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
      onDaySelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _shiftWeeks(-1),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.chevron_left, size: 16),
              ),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'WEEK ${selectedDay.weekOfYear().toString()} // ${DateFormat('EEEE, d/MM/yyyy').format(selectedDay).toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () => _shiftWeeks(1),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.chevron_right, size: 16),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        Row(
          spacing: 25,
          children: [
            Expanded(
              child: Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final dayData in availableDays)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => {onDaySelected(dayData['fullDate'])},
                        behavior: HitTestBehavior.opaque,
                        child: _buildDayField(
                          dayData['day'],
                          dayData['dayNum'],
                          dayData['isSelected'],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),
      ],
    );
  }
}
