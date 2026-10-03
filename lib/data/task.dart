import 'package:isar/isar.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/data/task_categories.dart';
import 'package:cadence/data/task_priority.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';

part 'task.g.dart';

/// A reusable piece of work kept in the Library. Can be placed into the
/// Planner any number of times. Tasks with a [dueDate] are "one-off" and are
/// archived automatically once their scheduled instance is completed.
@collection
class Task implements Comparable<Task> {
  Task({
    required this.categoryName,
    required this.name,
    required this.priority,
    required this.durationMinutes,
    this.dueDate,
    this.subTasks = const [],
    this.archived = false,
  });

  Task copyWith({
    String? categoryName,
    String? name,
    TaskPriority? priority,
    int? durationMinutes,
    DateTime? dueDate,
    bool clearDueDate = false,
    List<String>? subTasks,
    bool? archived,
  }) {
    return Task(
        categoryName: categoryName ?? this.categoryName,
        name: name ?? this.name,
        priority: priority ?? this.priority,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        subTasks: subTasks ?? this.subTasks,
        archived: archived ?? this.archived,
      )
      ..id = id;
  }

  Id id = Isar.autoIncrement;

  final String categoryName;
  final String name;
  @enumerated
  final TaskPriority priority;
  final int durationMinutes;
  final DateTime? dueDate;
  final List<String> subTasks;
  final bool archived;

  @ignore
  bool get oneOff => dueDate != null;

  @ignore
  TaskCategory get category =>
      taskCategories.firstWhere((c) => c.name == categoryName);

  @ignore
  String get dueText {
    final due = dueDate;
    if (due == null) return '';
    final today = DateTime.now().dateOnly;
    final diff = due.dateOnly.difference(today).inDays;
    return switch (diff) {
      0 => 'TODAY',
      -1 => 'YESTERDAY',
      1 => 'TOMORROW',
      _ => due.toDDMMYYYY('.'),
    };
  }

  @override
  int compareTo(Task other) {
    final a = dueDate;
    final b = other.dueDate;
    if (a == null && b == null) return name.compareTo(other.name);
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}
