import 'package:cadence/data/habit.dart';
import 'package:cadence/data/day.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';

/// Whether [habit] is expected to be done on [date] according to its rule.
bool isHabitExpectedOn(Habit habit, DateTime date) {
  final day = date.dateOnly;
  switch (habit.scheduleType) {
    case HabitScheduleType.weekdays:
      return habit.repeatDays.contains(Day.fromDateTime(day));
    case HabitScheduleType.interval:
      final anchor = habit.anchorDate?.dateOnly;
      final interval = habit.intervalDays;
      if (anchor == null || interval == null || interval < 1) return false;
      if (day.isBefore(anchor)) return false;
      return day.difference(anchor).inDays % interval == 0;
  }
}
