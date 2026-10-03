import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/isar_data_store.dart';

/// Active (non-archived) habits.
final habitsProvider = StreamProvider<List<Habit>>((ref) {
  return IsarDataStore.watchAllHabits();
});

/// Every habit, including archived ones.
final allHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return IsarDataStore.watchAllHabitsIncludingArchived();
});

class HabitService {
  static void add(Habit habit) => IsarDataStore.addHabit(habit);

  static void update(int id, Habit habit) =>
      IsarDataStore.updateHabit(id, habit);

  static void archive(Habit habit) => IsarDataStore.archiveHabit(habit);

  static void unarchive(Habit habit) => IsarDataStore.unarchiveHabit(habit);
}
