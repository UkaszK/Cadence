import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/daily_progress_metrics.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/isar_data_store.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/sub_task.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/providers/schedule_providers.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';

typedef DashboardState = ({
  List<ScheduledTask> scheduledTasks,
  List<HabitOccurrence> habitOccurrences,
  List<HabitOccurrence> placedHabits,
  List<Habit> expectedHabits,
  Set<int> completedHabitIds,
  DailyProgressMetrics progress,
});

final dashboardStateProvider =
    Provider.family<AsyncValue<DashboardState>, DateTime>((ref, date) {
      final normalizedDate = date.dateOnly;

      final states = [
        ref.watch(scheduledTasksForDayProvider(normalizedDate)),
        ref.watch(habitOccurrencesForDayProvider(normalizedDate)),
        ref.watch(placedHabitOccurrencesForDayProvider(normalizedDate)),
        ref.watch(expectedHabitsForDayProvider(normalizedDate)),
        ref.watch(completedHabitIdsForDayProvider(normalizedDate)),
        ref.watch(dailyProgressForDayProvider(normalizedDate)),
      ];

      if (states.any((state) => state.isLoading)) {
        return const AsyncLoading();
      }

      for (final state in states) {
        if (state.hasError) return AsyncError(state.error!, state.stackTrace!);
      }

      return AsyncData((
        scheduledTasks: states[0].requireValue as List<ScheduledTask>,
        habitOccurrences: states[1].requireValue as List<HabitOccurrence>,
        placedHabits: states[2].requireValue as List<HabitOccurrence>,
        expectedHabits: states[3].requireValue as List<Habit>,
        completedHabitIds: states[4].requireValue as Set<int>,
        progress: states[5].requireValue as DailyProgressMetrics,
      ));
    });

typedef DashboardViewState = ({DateTime selectedDay});

final dashboardViewStateNotifierProvider =
    NotifierProvider<DashboardViewStateNotifier, DashboardViewState>(
      () => DashboardViewStateNotifier(),
    );

class DashboardViewStateNotifier extends Notifier<DashboardViewState> {
  @override
  DashboardViewState build() => (selectedDay: DateTime.now().dateOnly);

  void shiftDay(int value) {
    setDay(state.selectedDay.add(Duration(days: value)));
  }

  void setDay(DateTime date) {
    state = (selectedDay: date.dateOnly);
  }

  /// Toggles completion of a scheduled task. When a one-off task (one with a
  /// due date) is completed, its library entry is archived automatically and
  /// returned so the caller can offer an undo.
  Task? checkScheduledTask(ScheduledTask scheduledTask, bool newValue) {
    final updatedSubTasks = scheduledTask.subTasks
        .map((subTask) => SubTask(name: subTask.name, completed: newValue))
        .toList();

    final updated = scheduledTask.copyWith(
      subTasks: updatedSubTasks,
      completed: newValue,
      completedAt: newValue ? DateTime.now() : null,
      clearCompletedAt: !newValue,
    );

    IsarDataStore.updateScheduledTask(scheduledTask.id, updated);

    return newValue ? _autoArchive(scheduledTask.taskId) : null;
  }

  Task? checkSubTask(
    ScheduledTask scheduledTask,
    SubTask subTask,
    bool newValue,
  ) {
    final subTaskIndex = scheduledTask.subTasks.indexWhere(
      (st) => st == subTask,
    );
    if (subTaskIndex == -1) return null;

    final updatedSubTasks = List<SubTask>.from(scheduledTask.subTasks);
    updatedSubTasks[subTaskIndex] = SubTask(
      name: subTask.name,
      completed: newValue,
    );

    final completed = newValue && updatedSubTasks.every((st) => st.completed)
        ? true
        : null;

    final updated = scheduledTask.copyWith(
      subTasks: updatedSubTasks,
      completed: completed,
      completedAt: completed == true ? DateTime.now() : null,
    );

    IsarDataStore.updateScheduledTask(scheduledTask.id, updated);

    return completed == true ? _autoArchive(scheduledTask.taskId) : null;
  }

  /// Updates the name and sub tasks of a scheduled task (quick dashboard edit).
  void updateScheduledTaskDetails(
    ScheduledTask scheduledTask, {
    required String name,
    required List<SubTask> subTasks,
  }) {
    IsarDataStore.updateScheduledTask(
      scheduledTask.id,
      scheduledTask.copyWith(name: name, subTasks: subTasks),
    );
  }

  Task? _autoArchive(int taskId) {
    final task = IsarDataStore.getTask(taskId);
    if (task == null || !task.oneOff || task.archived) return null;
    IsarDataStore.archiveTask(task);
    return task;
  }

  void undoAutoArchive(Task task) {
    IsarDataStore.unarchiveTask(task);
  }

  /// Marks a habit as done (or not) on the selected day. The record is kept
  /// when it is placed in the planner so the slot is not lost.
  void checkHabit(
    Habit habit,
    bool newValue,
    List<HabitOccurrence> dayOccurrences,
  ) {
    final existing = dayOccurrences.firstWhereOrNull(
      (occurrence) => occurrence.habitId == habit.id,
    );

    if (existing == null) {
      if (!newValue) return;
      IsarDataStore.addHabitOccurrence(
        HabitOccurrence.from(
          habit,
          state.selectedDay,
          completedAt: DateTime.now(),
        ),
      );
      return;
    }

    if (newValue) {
      if (existing.completed) return;
      IsarDataStore.updateHabitOccurrence(
        existing.id,
        existing.copyWith(completedAt: DateTime.now()),
      );
      return;
    }

    if (existing.isPlaced) {
      IsarDataStore.updateHabitOccurrence(
        existing.id,
        existing.copyWith(clearCompletedAt: true),
      );
    } else {
      IsarDataStore.deleteHabitOccurrence(existing);
    }
  }

  /// Toggles a habit block shown in the plan timeline.
  void checkHabitOccurrence(HabitOccurrence occurrence, bool newValue) {
    IsarDataStore.updateHabitOccurrence(
      occurrence.id,
      occurrence.copyWith(
        completedAt: newValue ? DateTime.now() : null,
        clearCompletedAt: !newValue,
      ),
    );
  }
}
