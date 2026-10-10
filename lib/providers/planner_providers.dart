import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/blocked_time.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/isar_data_store.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/sub_task.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/providers/schedule_providers.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/widgets/planner_screen/add_to_slot_sheet.dart';

/// Something that can be placed into a planner slot but is not yet saved.
sealed class PendingPlannerItem {
  const PendingPlannerItem();

  String get name;
}

class PendingTask extends PendingPlannerItem {
  const PendingTask(this.task);

  final Task task;

  @override
  String get name => task.name;

  int get durationMinutes => task.durationMinutes;
}

class PendingHabit extends PendingPlannerItem {
  const PendingHabit(this.habit);

  final Habit habit;

  @override
  String get name => habit.name;

  int get durationMinutes => habit.durationMinutes;
}

/// Blocked time takes over the selected slot as is.
class PendingBlockedTime extends PendingPlannerItem {
  const PendingBlockedTime(this.name);

  @override
  final String name;
}

/// A block already saved in the planner that is being edited.
sealed class EditingPlannerItem {
  const EditingPlannerItem();

  String get name;
  DateTime get startTime;
  DateTime get endTime;
}

class EditingScheduledTask extends EditingPlannerItem {
  const EditingScheduledTask(this.scheduledTask);

  final ScheduledTask scheduledTask;

  @override
  String get name => scheduledTask.name;

  @override
  DateTime get startTime => scheduledTask.startTime;

  @override
  DateTime get endTime => scheduledTask.endTime;
}

class EditingHabitOccurrence extends EditingPlannerItem {
  const EditingHabitOccurrence(this.occurrence);

  final HabitOccurrence occurrence;

  @override
  String get name => occurrence.name;

  @override
  DateTime get startTime => occurrence.startTime!;

  @override
  DateTime get endTime => occurrence.endTime!;
}

class EditingBlockedTime extends EditingPlannerItem {
  const EditingBlockedTime(this.blockedTime);

  final BlockedTime blockedTime;

  @override
  String get name => blockedTime.name;

  @override
  DateTime get startTime => blockedTime.startTime;

  @override
  DateTime get endTime => blockedTime.endTime;
}

typedef PlannerState = ({
  List<ScheduledTask> scheduledTasks,
  List<HabitOccurrence> placedHabits,
  List<BlockedTime> blockedTimes,
});

typedef PlannerViewState = ({
  DateTime selectedDay,
  TimeSlot? selectedTimeSlot,
  PendingPlannerItem? pendingItem,
  EditingPlannerItem? editingItem,
});

final plannerStateProvider =
    Provider.family<AsyncValue<PlannerState>, DateTime>((ref, date) {
      final tasksAsync = ref.watch(scheduledTasksForDayProvider(date));
      final habitsAsync = ref.watch(placedHabitOccurrencesForDayProvider(date));
      final blockedAsync = ref.watch(blockedTimesForDayProvider(date));

      if (tasksAsync.isLoading ||
          habitsAsync.isLoading ||
          blockedAsync.isLoading) {
        return const AsyncLoading();
      }
      if (tasksAsync.hasError) {
        return AsyncError(tasksAsync.error!, tasksAsync.stackTrace!);
      }
      if (habitsAsync.hasError) {
        return AsyncError(habitsAsync.error!, habitsAsync.stackTrace!);
      }
      if (blockedAsync.hasError) {
        return AsyncError(blockedAsync.error!, blockedAsync.stackTrace!);
      }

      return AsyncData((
        scheduledTasks: tasksAsync.requireValue,
        placedHabits: habitsAsync.requireValue,
        blockedTimes: blockedAsync.requireValue,
      ));
    });

final plannerViewStateNotifierProvider =
    NotifierProvider<PlannerViewStateNotifier, PlannerViewState>(
      () => PlannerViewStateNotifier(),
    );

class PlannerViewStateNotifier extends Notifier<PlannerViewState> {
  @override
  PlannerViewState build() => (
    selectedDay: DateTime.now().dateOnly,
    selectedTimeSlot: null,
    pendingItem: null,
    editingItem: null,
  );

  void _set({
    DateTime? selectedDay,
    TimeSlot? selectedTimeSlot,
    bool clearTimeSlot = false,
    PendingPlannerItem? pendingItem,
    bool clearPending = false,
    EditingPlannerItem? editingItem,
    bool clearEditing = false,
  }) {
    state = (
      selectedDay: selectedDay ?? state.selectedDay,
      selectedTimeSlot: clearTimeSlot
          ? null
          : (selectedTimeSlot ?? state.selectedTimeSlot),
      pendingItem: clearPending ? null : (pendingItem ?? state.pendingItem),
      editingItem: clearEditing ? null : (editingItem ?? state.editingItem),
    );
  }

  void resetTimeSlot() {
    _set(clearTimeSlot: true, clearPending: true, clearEditing: true);
  }

  void updateSelectedTimeSlot(TimeSlot timeSlot) {
    _set(selectedTimeSlot: timeSlot);
  }

  void handleSelectExistingScheduledTask(ScheduledTask scheduledTask) {
    _set(
      selectedTimeSlot: (
        startTime: scheduledTask.startTime,
        endTime: scheduledTask.endTime,
      ),
      clearPending: true,
      editingItem: EditingScheduledTask(scheduledTask),
    );
  }

  void handleSelectExistingHabitOccurrence(HabitOccurrence occurrence) {
    if (!occurrence.isPlaced) return;
    _set(
      selectedTimeSlot: (
        startTime: occurrence.startTime!,
        endTime: occurrence.endTime!,
      ),
      clearPending: true,
      editingItem: EditingHabitOccurrence(occurrence),
    );
  }

  void handleSelectExistingBlockedTime(BlockedTime blockedTime) {
    _set(
      selectedTimeSlot: (
        startTime: blockedTime.startTime,
        endTime: blockedTime.endTime,
      ),
      clearPending: true,
      editingItem: EditingBlockedTime(blockedTime),
    );
  }

  TimeSlot _defaultSlot(int durationMinutes) {
    final current = state.selectedTimeSlot;
    final start = current?.startTime ?? state.selectedDay;
    return (
      startTime: start,
      endTime: start.add(Duration(minutes: durationMinutes)),
    );
  }

  /// Picks a task for the active slot. If no slot is selected a slot sized to
  /// the task's duration starting at the day start is used. When a slot was
  /// opened by tapping free time the slot's end is adjusted to the duration.
  void handleAddTaskToPlan(Task task) {
    _set(
      selectedTimeSlot: _defaultSlot(task.durationMinutes),
      pendingItem: PendingTask(task),
    );
  }

  void handleAddHabitToPlan(Habit habit) {
    _set(
      selectedTimeSlot: _defaultSlot(habit.durationMinutes),
      pendingItem: PendingHabit(habit),
    );
  }

  /// Picks blocked time with [name] for the active slot, keeping its times.
  void handleAddBlockedTimeToPlan(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.selectedTimeSlot == null) return;
    _set(pendingItem: PendingBlockedTime(trimmed));
  }

  void handleItemCleared() {
    _set(clearPending: true);
  }

  /// Persists the pending item into the selected slot. Returns the created
  /// pending item so callers can show feedback, or null if nothing was saved.
  PendingPlannerItem? handleCreatePlannerItem({
    required List<HabitOccurrence> dayOccurrences,
  }) {
    final slot = state.selectedTimeSlot;
    final pending = state.pendingItem;
    if (slot == null || pending == null) return null;

    switch (pending) {
      case PendingTask(:final task):
        IsarDataStore.addScheduledTask(
          ScheduledTask(
            taskId: task.id,
            name: task.name,
            categoryName: task.categoryName,
            subTasks: task.subTasks
                .map((subTask) => SubTask(name: subTask, completed: false))
                .toList(),
            startTime: slot.startTime,
            endTime: slot.endTime,
          ),
        );
      case PendingHabit(:final habit):
        final existing = dayOccurrences
            .where((o) => o.habitId == habit.id)
            .firstOrNull;
        if (existing != null) {
          IsarDataStore.updateHabitOccurrence(
            existing.id,
            existing.copyWith(startTime: slot.startTime, endTime: slot.endTime),
          );
        } else {
          IsarDataStore.addHabitOccurrence(
            HabitOccurrence.from(
              habit,
              state.selectedDay,
              startTime: slot.startTime,
              endTime: slot.endTime,
            ),
          );
        }
      case PendingBlockedTime(:final name):
        IsarDataStore.addBlockedTime(
          BlockedTime(
            name: name,
            startTime: slot.startTime,
            endTime: slot.endTime,
          ),
        );
    }

    resetTimeSlot();
    return pending;
  }

  void handleUpdatePlannerItem() {
    final slot = state.selectedTimeSlot;
    final editing = state.editingItem;
    if (slot == null || editing == null) return;

    switch (editing) {
      case EditingScheduledTask(:final scheduledTask):
        IsarDataStore.updateScheduledTask(
          scheduledTask.id,
          scheduledTask.copyWith(
            startTime: slot.startTime,
            endTime: slot.endTime,
          ),
        );
      case EditingHabitOccurrence(:final occurrence):
        IsarDataStore.updateHabitOccurrence(
          occurrence.id,
          occurrence.copyWith(startTime: slot.startTime, endTime: slot.endTime),
        );
      case EditingBlockedTime(:final blockedTime):
        IsarDataStore.updateBlockedTime(
          blockedTime.id,
          blockedTime.copyWith(
            startTime: slot.startTime,
            endTime: slot.endTime,
          ),
        );
    }

    resetTimeSlot();
  }

  void handleUpdateScheduledTaskDetails({
    required String name,
    required List<SubTask> subTasks,
  }) {
    final editing = state.editingItem;
    if (editing is! EditingScheduledTask) return;

    final updated = editing.scheduledTask.copyWith(
      name: name,
      subTasks: subTasks,
    );
    IsarDataStore.updateScheduledTask(editing.scheduledTask.id, updated);

    // Keep the bar open with the refreshed task so time slot edits still work.
    _set(editingItem: EditingScheduledTask(updated));
  }

  void handleRenameBlockedTime(String name) {
    final editing = state.editingItem;
    final trimmed = name.trim();
    if (editing is! EditingBlockedTime || trimmed.isEmpty) return;

    final updated = editing.blockedTime.copyWith(name: trimmed);
    IsarDataStore.updateBlockedTime(editing.blockedTime.id, updated);

    // Keep the bar open with the refreshed block so time slot edits still work.
    _set(editingItem: EditingBlockedTime(updated));
  }

  /// Removes the edited block from the planner. Scheduled tasks and blocked
  /// time are deleted; habit blocks keep their completion state but lose their
  /// time slot.
  void handleDeleteEditedItem() {
    final editing = state.editingItem;
    if (editing == null) return;

    switch (editing) {
      case EditingScheduledTask(:final scheduledTask):
        IsarDataStore.deleteScheduledTask(scheduledTask);
      case EditingHabitOccurrence(:final occurrence):
        if (occurrence.completed) {
          IsarDataStore.updateHabitOccurrence(
            occurrence.id,
            occurrence.copyWith(clearTimes: true),
          );
        } else {
          IsarDataStore.deleteHabitOccurrence(occurrence);
        }
      case EditingBlockedTime(:final blockedTime):
        IsarDataStore.deleteBlockedTime(blockedTime);
    }

    resetTimeSlot();
  }

  void onClickAddItem(BuildContext context) {
    showAddToSlotSheet(context);
  }

  void updateSelectedDay(DateTime date) {
    state = (
      selectedDay: date.dateOnly,
      selectedTimeSlot: null,
      pendingItem: null,
      editingItem: null,
    );
  }
}
