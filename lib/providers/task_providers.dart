import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/isar_data_store.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/data/task_category.dart';

/// Active (non-archived) tasks.
final tasksProvider = StreamProvider<List<Task>>((ref) {
  return IsarDataStore.watchAllTasks();
});

/// Every task, including archived ones.
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return IsarDataStore.watchAllTasksIncludingArchived();
});

final tasksByCategoryProvider =
    Provider<AsyncValue<Map<TaskCategory, List<Task>>>>((ref) {
      final tasksAsync = ref.watch(tasksProvider);

      return tasksAsync.whenData((tasks) {
        final collection = <TaskCategory, List<Task>>{};
        for (final task in tasks) {
          collection.putIfAbsent(task.category, () => []).add(task);
        }
        return collection;
      });
    });

class TaskService {
  static void add(Task task) => IsarDataStore.addTask(task);

  static void update(int id, Task task) => IsarDataStore.updateTask(id, task);

  static void archive(Task task) => IsarDataStore.archiveTask(task);

  static void unarchive(Task task) => IsarDataStore.unarchiveTask(task);
}
