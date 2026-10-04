import 'package:cadence/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/providers/planner_providers.dart';
import 'package:cadence/providers/schedule_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/widgets/planner_screen/active_time_slot_bar.dart';
import 'package:cadence/widgets/planner_screen/day_picker.dart';
import 'package:cadence/widgets/planner_screen/edit_scheduled_task_sheet.dart';
import 'package:cadence/widgets/planner_screen/planner.dart';
import 'package:cadence/widgets/cadence_loading_screen.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  bool _hasOverlap(
    List<ScheduledTask> scheduledTasks,
    List<HabitOccurrence> placedHabits,
    TimeSlot? slot,
    EditingPlannerItem? editing,
  ) {
    if (slot == null) return false;

    bool overlaps(DateTime start, DateTime end) =>
        slot.startTime.isBefore(end) && slot.endTime.isAfter(start);

    final editingTaskId = switch (editing) {
      EditingScheduledTask(:final scheduledTask) => scheduledTask.id,
      _ => null,
    };
    final editingOccurrenceId = switch (editing) {
      EditingHabitOccurrence(:final occurrence) => occurrence.id,
      _ => null,
    };

    return scheduledTasks.any(
          (t) => t.id != editingTaskId && overlaps(t.startTime, t.endTime),
        ) ||
        placedHabits.any(
          (h) =>
              h.id != editingOccurrenceId && overlaps(h.startTime!, h.endTime!),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(plannerViewStateNotifierProvider.notifier);
    final viewState = ref.watch(plannerViewStateNotifierProvider);
    final selectedDay = viewState.selectedDay;
    final plannerStateAsync = ref.watch(plannerStateProvider(selectedDay));
    final dayOccurrencesAsync = ref.watch(
      habitOccurrencesForDayProvider(selectedDay),
    );

    final DateTime baseDate = selectedDay.dateOnly;
    final TimeSlot? selectedTimeSlot = viewState.selectedTimeSlot;
    final EditingPlannerItem? editingItem = viewState.editingItem;
    final PendingPlannerItem? pendingItem = viewState.pendingItem;
    final bool hasTimeSlot = selectedTimeSlot != null;
    final String pendingItemName = pendingItem?.name ?? editingItem?.name ?? '';

    Future<void> editTaskDetails(ScheduledTask scheduledTask) async {
      final details = await showEditScheduledTaskSheet(context, scheduledTask);
      if (details == null) return;
      notifier.handleUpdateScheduledTaskDetails(
        name: details.name,
        subTasks: details.subTasks,
      );
    }

    return plannerStateAsync.when(
      data: (state) {
        final hasOverlap = _hasOverlap(
          state.scheduledTasks,
          state.placedHabits,
          selectedTimeSlot,
          editingItem,
        );
        return Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: 20,
                      left: 16,
                      right: 16,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInTransition(
                          delay: Duration.zero,
                          child: DayPicker(
                            selectedDay: selectedDay,
                            onDaySelected: notifier.updateSelectedDay,
                          ),
                        ),
                        FadeInTransition(
                          delay: const Duration(milliseconds: 100),
                          child: _PlannerTitle(
                            rightSide: Text(
                              selectedDay.toDDMMYYYY('-'),
                              style: GoogleFonts.jetBrainsMono(
                                color: CadenceColors.accent,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        FadeInTransition(
                          delay: const Duration(milliseconds: 150),
                          child: Planner(
                            baseDate: baseDate,
                            scheduledTasks: state.scheduledTasks,
                            placedHabits: state.placedHabits,
                            canCreateSlot: !hasTimeSlot,
                            hasOverlap: hasOverlap,
                            selectedTimeSlot: selectedTimeSlot,
                            editingItem: editingItem,
                            onSelectTimeSlot: notifier.updateSelectedTimeSlot,
                            onUpdateTimeSlot: notifier.updateSelectedTimeSlot,
                            onSelectExistingTask:
                                notifier.handleSelectExistingScheduledTask,
                            onSelectExistingHabit:
                                notifier.handleSelectExistingHabitOccurrence,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: CadenceMotion.enter,
                        reverseCurve: CadenceMotion.exit,
                      );
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -1),
                          end: Offset.zero,
                        ).animate(curved),
                        child: FadeTransition(opacity: curved, child: child),
                      );
                    },
                    child: hasTimeSlot
                        ? ActiveTimeSlotBar(
                            key: const ValueKey('active-slot-bar'),
                            timeSlot: selectedTimeSlot,
                            onReset: notifier.resetTimeSlot,
                            pendingItemName: pendingItemName,
                            onSave: () {
                              if (editingItem != null) {
                                notifier.handleUpdatePlannerItem();
                                return;
                              }
                              notifier.handleCreatePlannerItem(
                                dayOccurrences:
                                    dayOccurrencesAsync.value ?? const [],
                              );
                            },
                            onClearItem: notifier.handleItemCleared,
                            hasOverlap: hasOverlap,
                            isEditingExistingItem: editingItem != null,
                            onDelete: notifier.handleDeleteEditedItem,
                            onUpdateTimeSlot: notifier.updateSelectedTimeSlot,
                            onClickAddItem: () =>
                                notifier.onClickAddItem(context),
                            onEditDetails: () {
                              if (editingItem is! EditingScheduledTask) return;
                              editTaskDetails(editingItem.scheduledTask);
                            },
                            canEditDetails: editingItem is EditingScheduledTask,
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('slot-bar-empty'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stack) => Center(child: Text('Error loading: $error')),
      loading: () => CadenceLoadingScreen(),
    );
  }
}

class _PlannerTitle extends StatelessWidget {
  const _PlannerTitle({required this.rightSide});

  final Widget rightSide;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'PLANNER',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),

        rightSide,
      ],
    );
  }
}
