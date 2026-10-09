import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/quick_note.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';

class IsarDataStore {
  IsarDataStore._();

  static late final Isar instance;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    instance = await Isar.open([
      TaskSchema,
      HabitSchema,
      ScheduledTaskSchema,
      HabitOccurrenceSchema,
      QuickNoteSchema,
    ], directory: dir.path);
  }

  // Task
  static List<Task> getAllTasksIncludingArchived() =>
      instance.tasks.where().findAllSync();

  static Task? getTask(int id) => instance.tasks.getSync(id);

  static Stream<List<Task>> watchAllTasks() => instance.tasks
      .filter()
      .archivedEqualTo(false)
      .watch(fireImmediately: true);

  static Stream<List<Task>> watchAllTasksIncludingArchived() =>
      instance.tasks.where().watch(fireImmediately: true);

  static void addTask(Task task) {
    instance.writeTxnSync(() => instance.tasks.putSync(task));
  }

  static void archiveTask(Task task) => _setTaskArchived(task, true);

  static void unarchiveTask(Task task) => _setTaskArchived(task, false);

  static void _setTaskArchived(Task task, bool archived) {
    final updated = task.copyWith(archived: archived);
    instance.writeTxnSync(() => instance.tasks.putSync(updated));
  }

  static void updateTask(int id, Task task) {
    task.id = id;
    instance.writeTxnSync(() => instance.tasks.putSync(task));
  }

  // Habit
  static List<Habit> getAllHabitsIncludingArchived() =>
      instance.habits.where().findAllSync();

  static Stream<List<Habit>> watchAllHabits() => instance.habits
      .filter()
      .archivedEqualTo(false)
      .watch(fireImmediately: true);

  static Stream<List<Habit>> watchAllHabitsIncludingArchived() =>
      instance.habits.where().watch(fireImmediately: true);

  static void addHabit(Habit habit) {
    instance.writeTxnSync(() => instance.habits.putSync(habit));
  }

  static void archiveHabit(Habit habit) => _setHabitArchived(habit, true);

  static void unarchiveHabit(Habit habit) => _setHabitArchived(habit, false);

  static void _setHabitArchived(Habit habit, bool archived) {
    final updated = habit.copyWith(archived: archived);
    instance.writeTxnSync(() => instance.habits.putSync(updated));
  }

  static void updateHabit(int id, Habit habit) {
    habit.id = id;
    instance.writeTxnSync(() => instance.habits.putSync(habit));
  }

  // ScheduledTask
  static List<ScheduledTask> getAllScheduledTasks() =>
      instance.scheduledTasks.where().findAllSync();

  static Stream<List<ScheduledTask>> watchAllScheduledTasks() =>
      instance.scheduledTasks.where().watch(fireImmediately: true);

  static void addScheduledTask(ScheduledTask scheduledTask) {
    instance.writeTxnSync(() => instance.scheduledTasks.putSync(scheduledTask));
  }

  static void updateScheduledTask(int id, ScheduledTask scheduledTask) {
    scheduledTask.id = id;
    instance.writeTxnSync(() => instance.scheduledTasks.putSync(scheduledTask));
  }

  static void deleteScheduledTask(ScheduledTask scheduledTask) {
    instance.writeTxnSync(
      () => instance.scheduledTasks.deleteSync(scheduledTask.id),
    );
  }

  // HabitOccurrence
  static List<HabitOccurrence> getAllHabitOccurrences() =>
      instance.habitOccurrences.where().findAllSync();

  static Stream<List<HabitOccurrence>> watchAllHabitOccurrences() =>
      instance.habitOccurrences.where().watch(fireImmediately: true);

  static void addHabitOccurrence(HabitOccurrence occurrence) {
    instance.writeTxnSync(() => instance.habitOccurrences.putSync(occurrence));
  }

  static void updateHabitOccurrence(int id, HabitOccurrence occurrence) {
    occurrence.id = id;
    instance.writeTxnSync(() => instance.habitOccurrences.putSync(occurrence));
  }

  static void deleteHabitOccurrence(HabitOccurrence occurrence) {
    instance.writeTxnSync(
      () => instance.habitOccurrences.deleteSync(occurrence.id),
    );
  }

  // QuickNote
  static Stream<List<QuickNote>> watchQuickNotes() => instance.quickNotes
      .where()
      .sortByCreatedAt()
      .watch(fireImmediately: true);

  static void addQuickNote(QuickNote note) {
    instance.writeTxnSync(() => instance.quickNotes.putSync(note));
  }

  static void updateQuickNote(QuickNote note) {
    instance.writeTxnSync(() => instance.quickNotes.putSync(note));
  }

  static void deleteQuickNote(int id) {
    instance.writeTxnSync(() => instance.quickNotes.deleteSync(id));
  }

  static void deleteCompletedQuickNotes(DateTime date) {
    instance.writeTxnSync(
      () => instance.quickNotes
          .filter()
          .dateEqualTo(date.dateOnly)
          .completedEqualTo(true)
          .deleteAllSync(),
    );
  }
}
