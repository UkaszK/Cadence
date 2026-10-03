import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/daily_progress_metrics.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/isar_data_store.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/providers/habit_providers.dart';
import 'package:cadence/utils/habit_schedule.dart';

// ==========================================
// Base Stream Providers (Live DB Watchers)
// ==========================================

final scheduledTasksProvider = StreamProvider<List<ScheduledTask>>((ref) {
  return IsarDataStore.watchAllScheduledTasks();
});

final habitOccurrencesProvider = StreamProvider<List<HabitOccurrence>>((ref) {
  return IsarDataStore.watchAllHabitOccurrences();
});

// ------------------------------------------
// Date-parameterized Providers
// ------------------------------------------

/// Tasks scheduled for a specific date, sorted chronologically.
final scheduledTasksForDayProvider =
    Provider.family<AsyncValue<List<ScheduledTask>>, DateTime>((ref, date) {
      final asyncScheduledTasks = ref.watch(scheduledTasksProvider);

      return asyncScheduledTasks.whenData((scheduledTasks) {
        return scheduledTasks
            .where((t) => DateUtils.isSameDay(t.startTime, date))
            .sorted((a, b) => a.compareTo(b));
      });
    });

/// Habit occurrence records (completed and/or placed) for a specific date.
final habitOccurrencesForDayProvider =
    Provider.family<AsyncValue<List<HabitOccurrence>>, DateTime>((ref, date) {
      final asyncOccurrences = ref.watch(habitOccurrencesProvider);

      return asyncOccurrences.whenData((occurrences) {
        return occurrences
            .where((o) => DateUtils.isSameDay(o.occurrenceDate, date))
            .toList();
      });
    });

/// Habit occurrences placed into a planner slot on the given date, sorted.
final placedHabitOccurrencesForDayProvider =
    Provider.family<AsyncValue<List<HabitOccurrence>>, DateTime>((ref, date) {
      final asyncOccurrences = ref.watch(habitOccurrencesForDayProvider(date));

      return asyncOccurrences.whenData((occurrences) {
        return occurrences
            .where((o) => o.isPlaced)
            .sorted((a, b) => a.startTime!.compareTo(b.startTime!));
      });
    });

/// Habits expected on the given date according to their schedule rule.
final expectedHabitsForDayProvider =
    Provider.family<AsyncValue<List<Habit>>, DateTime>((ref, date) {
      final asyncHabits = ref.watch(habitsProvider);

      return asyncHabits.whenData((habits) {
        return habits.where((h) => isHabitExpectedOn(h, date)).toList();
      });
    });

/// Set of habit IDs that have been completed on a specific date.
final completedHabitIdsForDayProvider =
    Provider.family<AsyncValue<Set<int>>, DateTime>((ref, date) {
      final asyncOccurrences = ref.watch(habitOccurrencesForDayProvider(date));
      return asyncOccurrences.whenData((occurrences) {
        return occurrences
            .where((o) => o.completed)
            .map((o) => o.habitId)
            .toSet();
      });
    });

/// Daily progress (done vs planned) counting scheduled tasks and expected
/// habits for a specific date.
final dailyProgressForDayProvider =
    Provider.family<AsyncValue<DailyProgressMetrics>, DateTime>((ref, date) {
      final asyncTasks = ref.watch(scheduledTasksForDayProvider(date));
      final asyncExpectedHabits = ref.watch(expectedHabitsForDayProvider(date));
      final asyncCompletedHabitIds = ref.watch(
        completedHabitIdsForDayProvider(date),
      );

      if (asyncTasks.isLoading ||
          asyncExpectedHabits.isLoading ||
          asyncCompletedHabitIds.isLoading) {
        return const AsyncLoading();
      }

      final tasks = asyncTasks.requireValue;
      final expectedHabits = asyncExpectedHabits.requireValue;
      final completedHabitIds = asyncCompletedHabitIds.requireValue;

      final tasksDone = tasks.where((t) => t.completed).length;
      final habitsDone = expectedHabits
          .where((h) => completedHabitIds.contains(h.id))
          .length;

      return AsyncData(
        DailyProgressMetrics(
          tasksDone: tasksDone + habitsDone,
          tasksPlanned: tasks.length + expectedHabits.length,
        ),
      );
    });
