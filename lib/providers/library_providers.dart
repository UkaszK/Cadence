import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/data/task_categories.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/data/task_filter_option.dart';
import 'package:cadence/providers/habit_providers.dart';
import 'package:cadence/providers/task_providers.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/widgets/forms/habit_form.dart';
import 'package:cadence/widgets/forms/task_form.dart';
import 'package:cadence/widgets/reusables/cadence_new_screen_container.dart';

enum LibraryTab { tasks, habits }

final libraryTabProvider = NotifierProvider<LibraryTabNotifier, LibraryTab>(
  () => LibraryTabNotifier(),
);

class LibraryTabNotifier extends Notifier<LibraryTab> {
  @override
  LibraryTab build() => LibraryTab.tasks;

  void select(LibraryTab tab) => state = tab;
}

typedef LibraryFilterState = ({TaskFilterOption filter, bool showArchived});

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilterState>(
      () => LibraryFilterNotifier(),
    );

class LibraryFilterNotifier extends Notifier<LibraryFilterState> {
  @override
  LibraryFilterState build() => (
    filter: TaskFilterOption.all,
    showArchived: false,
  );

  void setFilter(TaskFilterOption filter) {
    state = (filter: filter, showArchived: state.showArchived);
  }

  void toggleShowArchived(bool value) {
    state = (filter: state.filter, showArchived: value);
  }
}

typedef LibraryState = ({
  Map<TaskCategory, List<Task>> tasksByCategory,
  Map<TaskCategory, List<Habit>> habitsByCategory,
  int taskCount,
  int habitCount,
});

bool _matchesFilter(Task task, TaskFilterOption filter) {
  return switch (filter) {
    TaskFilterOption.all => true,
    TaskFilterOption.highPriority => task.priority.index >= 2,
    TaskFilterOption.dueToday =>
      task.dueDate != null &&
          DateUtils.isSameDay(task.dueDate!, DateTime.now().dateOnly),
    TaskFilterOption.oneOff => task.oneOff,
  };
}

final libraryStateProvider = Provider<AsyncValue<LibraryState>>((ref) {
  final filterState = ref.watch(libraryFilterProvider);
  final tasksAsync = ref.watch(
    filterState.showArchived ? allTasksProvider : tasksProvider,
  );
  final habitsAsync = ref.watch(
    filterState.showArchived ? allHabitsProvider : habitsProvider,
  );

  if (tasksAsync.isLoading || habitsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (tasksAsync.hasError) {
    return AsyncError(tasksAsync.error!, tasksAsync.stackTrace!);
  }
  if (habitsAsync.hasError) {
    return AsyncError(habitsAsync.error!, habitsAsync.stackTrace!);
  }

  final tasks = tasksAsync.requireValue
      .where((task) => _matchesFilter(task, filterState.filter))
      .toList();
  final habits = habitsAsync.requireValue;

  final tasksByCategory = <TaskCategory, List<Task>>{
    for (final category in taskCategories)
      category: tasks.where((t) => t.categoryName == category.name).toList()
        ..sort(),
  }..removeWhere((_, list) => list.isEmpty);

  final habitsByCategory = <TaskCategory, List<Habit>>{
    for (final category in taskCategories)
      category: habits.where((h) => h.categoryName == category.name).toList(),
  }..removeWhere((_, list) => list.isEmpty);

  return AsyncData((
    tasksByCategory: tasksByCategory,
    habitsByCategory: habitsByCategory,
    taskCount: tasks.length,
    habitCount: habits.length,
  ));
});

final libraryControllerProvider = NotifierProvider<LibraryController, void>(
  () => LibraryController(),
);

class LibraryController extends Notifier<void> {
  @override
  void build() {}

  void archiveTask(Task task) => TaskService.archive(task);

  void unarchiveTask(Task task) => TaskService.unarchive(task);

  void onClickEditTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadenceNewScreenContainer(
          children: [
            TaskForm(
              onSubmit: (updated) => TaskService.update(task.id, updated),
              editingTask: task,
            ),
          ],
        ),
      ),
    );
  }

  void archiveHabit(Habit habit) => HabitService.archive(habit);

  void unarchiveHabit(Habit habit) => HabitService.unarchive(habit);

  void onClickEditHabit(BuildContext context, Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadenceNewScreenContainer(
          children: [
            HabitForm(
              onSubmit: (updated) => HabitService.update(habit.id, updated),
              editingHabit: habit,
            ),
          ],
        ),
      ),
    );
  }
}
