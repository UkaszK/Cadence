import 'package:isar/isar.dart';
import 'package:cadence/data/task_status.dart';
import 'package:cadence/data/sub_task.dart';
import 'package:cadence/utils/get_time_text.dart';

part 'scheduled_task.g.dart';

/// A Task placed into a concrete time slot in the Planner.
@collection
class ScheduledTask implements Comparable<ScheduledTask> {
  ScheduledTask({
    required this.taskId,
    required this.name,
    required this.categoryName,
    required this.subTasks,
    required this.startTime,
    required this.endTime,
    this.completed = false,
    this.completedAt,
  });

  ScheduledTask copyWith({
    int? taskId,
    String? name,
    String? categoryName,
    List<SubTask>? subTasks,
    DateTime? startTime,
    DateTime? endTime,
    bool? completed,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return ScheduledTask(
        taskId: taskId ?? this.taskId,
        name: name ?? this.name,
        categoryName: categoryName ?? this.categoryName,
        subTasks: subTasks ?? this.subTasks,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        completed: completed ?? this.completed,
        completedAt: clearCompletedAt
            ? null
            : (completedAt ?? this.completedAt),
      )
      ..id = id;
  }

  Id id = Isar.autoIncrement;

  final int taskId;
  final String name;
  final String categoryName;
  final List<SubTask> subTasks;
  final DateTime startTime;
  final DateTime endTime;
  final bool completed;

  /// When the task was actually ticked off. Null if not completed.
  final DateTime? completedAt;

  @ignore
  TaskStatus get status => computeTaskStatus(
    startTime: startTime,
    endTime: endTime,
    completed: completed,
  );

  @ignore
  String get timeLabel {
    return switch (status) {
      TaskStatus.completed => 'COMPLETED',
      TaskStatus.pending => 'OVERDUE',
      _ => timeText,
    };
  }

  @ignore
  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  @ignore
  String get timeText => getTimeText(startTime, endTime);

  @ignore
  String get timeTextOneLine => getTimeText(startTime, endTime, false);

  @ignore
  bool get subTasksCompleted => subTasks.every((subTask) => subTask.completed);

  @ignore
  String get subTasksListed =>
      subTasks.map((subTask) => subTask.name).join(', ');

  int compareByDate(ScheduledTask other) {
    return startTime.compareTo(other.startTime);
  }

  @override
  int compareTo(ScheduledTask other) {
    return compareByDate(other);
  }
}
