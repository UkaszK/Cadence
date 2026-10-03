import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/providers/task_providers.dart';

final taskFormNotifierProvider = NotifierProvider<TaskFormNotifier, void>(
  () => TaskFormNotifier(),
);

class TaskFormNotifier extends Notifier<void> {
  @override
  void build() {}

  void submit(Task task) => TaskService.add(task);
}
