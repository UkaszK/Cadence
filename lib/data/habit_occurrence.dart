import 'package:isar/isar.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/data/task_categories.dart';
import 'package:cadence/data/task_status.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/utils/get_time_text.dart';

part 'habit_occurrence.g.dart';

/// One expected instance of a Habit on a given date. A record exists only once
/// the habit has been checked off or placed into the Planner for that day.
@collection
class HabitOccurrence {
  HabitOccurrence({
    required this.habitId,
    required this.name,
    required this.categoryName,
    required this.occurrenceDate,
    this.completedAt,
    this.startTime,
    this.endTime,
  });

  factory HabitOccurrence.from(
    Habit habit,
    DateTime occurrenceDate, {
    DateTime? completedAt,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return HabitOccurrence(
      habitId: habit.id,
      name: habit.name,
      categoryName: habit.categoryName,
      occurrenceDate: occurrenceDate.dateOnly,
      completedAt: completedAt,
      startTime: startTime,
      endTime: endTime,
    );
  }

  HabitOccurrence copyWith({
    int? habitId,
    String? name,
    String? categoryName,
    DateTime? occurrenceDate,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    DateTime? startTime,
    DateTime? endTime,
    bool clearTimes = false,
  }) {
    return HabitOccurrence(
        habitId: habitId ?? this.habitId,
        name: name ?? this.name,
        categoryName: categoryName ?? this.categoryName,
        occurrenceDate: occurrenceDate ?? this.occurrenceDate,
        completedAt: clearCompletedAt
            ? null
            : (completedAt ?? this.completedAt),
        startTime: clearTimes ? null : (startTime ?? this.startTime),
        endTime: clearTimes ? null : (endTime ?? this.endTime),
      )
      ..id = id;
  }

  Id id = Isar.autoIncrement;

  final int habitId;
  final String name;
  final String categoryName;
  final DateTime occurrenceDate;
  final DateTime? completedAt;

  /// Set only when the occurrence has been placed into a Planner slot.
  final DateTime? startTime;
  final DateTime? endTime;

  @ignore
  bool get completed => completedAt != null;

  @ignore
  bool get isPlaced => startTime != null && endTime != null;

  @ignore
  TaskCategory get category =>
      taskCategories.firstWhere((c) => c.name == categoryName);

  @ignore
  TaskStatus get status => computeTaskStatus(
    startTime: startTime ?? occurrenceDate,
    endTime: endTime ?? occurrenceDate.add(const Duration(days: 1)),
    completed: completed,
  );

  @ignore
  String get timeText =>
      isPlaced ? getTimeText(startTime!, endTime!) : 'ANYTIME';

  @ignore
  String get timeTextOneLine =>
      isPlaced ? getTimeText(startTime!, endTime!, false) : 'ANYTIME';
}
