import 'package:isar/isar.dart';
import 'package:cadence/data/day.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/data/task_categories.dart';

part 'habit.g.dart';

enum HabitScheduleType { weekdays, interval }

/// A recurring routine. Expected either on a fixed set of weekdays or every
/// [intervalDays] days counted from [anchorDate].
@collection
class Habit {
  Habit({
    required this.categoryName,
    required this.name,
    required this.durationMinutes,
    required this.scheduleType,
    this.repeatDays = const [],
    this.intervalDays,
    this.anchorDate,
    this.archived = false,
  });

  Habit copyWith({
    String? categoryName,
    String? name,
    int? durationMinutes,
    HabitScheduleType? scheduleType,
    List<Day>? repeatDays,
    int? intervalDays,
    DateTime? anchorDate,
    bool? archived,
  }) {
    return Habit(
        categoryName: categoryName ?? this.categoryName,
        name: name ?? this.name,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        scheduleType: scheduleType ?? this.scheduleType,
        repeatDays: repeatDays ?? this.repeatDays,
        intervalDays: intervalDays ?? this.intervalDays,
        anchorDate: anchorDate ?? this.anchorDate,
        archived: archived ?? this.archived,
      )
      ..id = id;
  }

  Id id = Isar.autoIncrement;

  final String categoryName;
  final String name;
  final int durationMinutes;
  @enumerated
  final HabitScheduleType scheduleType;
  @enumerated
  final List<Day> repeatDays;
  final int? intervalDays;
  final DateTime? anchorDate;
  final bool archived;

  @ignore
  TaskCategory get category =>
      taskCategories.firstWhere((c) => c.name == categoryName);

  @ignore
  Set<Day> get repeatDaySet => repeatDays.toSet();

  /// Human readable schedule, e.g. "Every day", "Mon, Wed, Fri", "Every 3 days".
  @ignore
  String get ruleText {
    switch (scheduleType) {
      case HabitScheduleType.interval:
        return 'Every ${intervalDays ?? 2} days';
      case HabitScheduleType.weekdays:
        if (repeatDays.isEmpty) return 'No schedule';
        if (repeatDays.length == Day.values.length) return 'Every day';
        final sorted = [...repeatDays]
          ..sort((a, b) => a.index.compareTo(b.index));
        return sorted.map((d) => d.shortLabel).join(', ');
    }
  }
}
