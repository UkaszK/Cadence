import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/utils/animations.dart';

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

  Widget _buildDayField(
    BuildContext context,
    String day,
    int dayNum,
    bool isSelected,
  ) {
    final color = isSelected
        ? CadenceColors.accent
        : CadenceColors.textSecondary;
    final shadows = isSelected
        ? const [Shadow(color: CadenceColors.accent, blurRadius: 32)]
        : const <Shadow>[];

    final motion = CadenceMotion.of(context, AnimationDurations.fast);
    return AnimatedContainer(
      duration: motion,
      curve: CadenceMotion.enter,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: isSelected ? Border.all(color: CadenceColors.accent) : null,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: motion,
            curve: CadenceMotion.enter,
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: shadows,
            ),
            child: Text(day),
          ),
          AnimatedDefaultTextStyle(
            duration: motion,
            curve: CadenceMotion.enter,
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: shadows,
            ),
            child: Text(dayNum.toString()),
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
            _WeekShiftButton(
              icon: Icons.chevron_left,
              action: () => _shiftWeeks(-1),
            ),

            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  behavior: HitTestBehavior.opaque,
                  child: _WeekHeader(selectedDay: selectedDay),
                ),
              ),
            ),

            _WeekShiftButton(
              icon: Icons.chevron_right,
              action: () => _shiftWeeks(1),
            ),
          ],
        ),

        const SizedBox(height: 25),

        CadenceValueSwitcher(
          value: selectedDay.subtract(Duration(days: selectedDay.weekday - 1)),
          directionOf: (previous, next) => next.isAfter(previous) ? 1 : -1,
          slideFraction: 0.12,
          builder: (_) => Row(
            spacing: 25,
            children: [
              Expanded(
                child: Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final dayData in availableDays)
                      Expanded(
                        child: PressScale(
                          child: GestureDetector(
                            onTap: () => onDaySelected(dayData['fullDate']),
                            behavior: HitTestBehavior.opaque,
                            child: _buildDayField(
                              context,
                              dayData['day'],
                              dayData['dayNum'],
                              dayData['isSelected'],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.selectedDay});

  final DateTime selectedDay;

  static final _dateFormat = DateFormat('EEEE, d/MM/yyyy');

  static final _style = GoogleFonts.jetBrainsMono(
    color: CadenceColors.textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static DateTime _weekStart(DateTime day) {
    return day.subtract(Duration(days: day.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    return CadenceValueSwitcher(
      value: _weekStart(selectedDay),
      directionOf: (previous, next) => next.isAfter(previous) ? 1 : -1,
      slideFraction: 0.2,
      builder: (_) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentGeometry.centerRight,
            child: Text('WEEK ${selectedDay.weekOfYear()} // ', style: _style),
          ),
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: CadenceValueSwitcher(
              value: selectedDay,
              directionOf: (previous, next) => next.isAfter(previous) ? 1 : -1,
              slideFraction: 0.35,
              builder: (day) =>
                  Text(_dateFormat.format(day).toUpperCase(), style: _style),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekShiftButton extends StatelessWidget {
  const _WeekShiftButton({required this.icon, required this.action});

  final IconData icon;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 20),
      ),
    );
  }
}
