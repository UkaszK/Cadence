import 'package:cadence/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/app_settings.dart';
import 'package:cadence/data/blocked_time.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/providers/planner_providers.dart';
import 'package:cadence/providers/schedule_providers.dart';
import 'package:cadence/providers/settings_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/utils/free_time.dart';
import 'package:cadence/utils/planner_time_scale.dart';
import 'package:cadence/utils/sleep_time.dart';
import 'package:cadence/widgets/planner_screen/active_time_slot_bar.dart';
import 'package:cadence/widgets/planner_screen/day_picker.dart';
import 'package:cadence/widgets/planner_screen/edit_blocked_time_sheet.dart';
import 'package:cadence/widgets/planner_screen/edit_scheduled_task_sheet.dart';
import 'package:cadence/widgets/planner_screen/planner.dart';
import 'package:cadence/widgets/cadence_loading_screen.dart';
import 'package:cadence/widgets/library_screen/task_block.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _hasOverlap(
    List<ScheduledTask> scheduledTasks,
    List<HabitOccurrence> placedHabits,
    List<BlockedTime> blockedTimes,
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
    final editingBlockedTimeId = switch (editing) {
      EditingBlockedTime(:final blockedTime) => blockedTime.id,
      _ => null,
    };

    return scheduledTasks.any(
          (t) => t.id != editingTaskId && overlaps(t.startTime, t.endTime),
        ) ||
        placedHabits.any(
          (h) =>
              h.id != editingOccurrenceId && overlaps(h.startTime!, h.endTime!),
        ) ||
        blockedTimes.any(
          (b) =>
              b.id != editingBlockedTimeId && overlaps(b.startTime, b.endTime),
        );
  }

  /// Minutes of [day] not taken by planned sleep or any planner block.
  int _freeMinutes(DateTime day, PlannerState state, List<SleepRange> sleep) {
    MinuteRange rangeOf(DateTime start, DateTime end) => (
      start: start.difference(day).inMinutes,
      end: end.difference(day).inMinutes,
    );

    return freeMinutesInDay([
      ...sleep,
      for (final t in state.scheduledTasks) rangeOf(t.startTime, t.endTime),
      for (final h in state.placedHabits) rangeOf(h.startTime!, h.endTime!),
      for (final b in state.blockedTimes) rangeOf(b.startTime, b.endTime),
    ]);
  }

  @override
  Widget build(BuildContext context) {
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
    final settings = ref.watch(settingsProvider).value;
    final sleepEnabled = settings != null && settings.sleepEnabled;
    final sleepRanges = sleepEnabled
        ? sleepRangesForDay(settings.bedtimeMinutes, settings.wakeUpMinutes)
        : const <SleepRange>[];
    // Night hours are compressed even when sleep isn't shown in the planner.
    final nightRanges = sleepEnabled
        ? sleepRanges
        : sleepRangesForDay(defaultBedtimeMinutes, defaultWakeUpMinutes);

    Future<void> editTaskDetails(ScheduledTask scheduledTask) async {
      final details = await showEditScheduledTaskSheet(context, scheduledTask);
      if (details == null) return;
      notifier.handleUpdateScheduledTaskDetails(
        name: details.name,
        subTasks: details.subTasks,
      );
    }

    Future<void> editBlockedTimeName(BlockedTime blockedTime) async {
      final name = await showEditBlockedTimeSheet(context, blockedTime.name);
      if (name == null) return;
      notifier.handleRenameBlockedTime(name);
    }

    return plannerStateAsync.when(
      data: (state) {
        final hasOverlap = _hasOverlap(
          state.scheduledTasks,
          state.placedHabits,
          state.blockedTimes,
          selectedTimeSlot,
          editingItem,
        );
        final freeMinutes = _freeMinutes(baseDate, state, sleepRanges);
        return Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _scrollController,
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
                            rightSide: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 2,
                              children: [
                                _FreeTimeLabel(minutes: freeMinutes),
                                Text(
                                  selectedDay.toDDMMYYYY('-'),
                                  style: GoogleFonts.jetBrainsMono(
                                    color: CadenceColors.accent,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        FadeInTransition(
                          delay: const Duration(milliseconds: 150),
                          child: Planner(
                            scrollController: _scrollController,
                            baseDate: baseDate,
                            scheduledTasks: state.scheduledTasks,
                            placedHabits: state.placedHabits,
                            blockedTimes: state.blockedTimes,
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
                            onSelectExistingBlockedTime:
                                notifier.handleSelectExistingBlockedTime,
                            sleepRanges: sleepRanges,
                            compressedRanges: nightRanges,
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
                              switch (editingItem) {
                                case EditingScheduledTask(:final scheduledTask):
                                  editTaskDetails(scheduledTask);
                                case EditingBlockedTime(:final blockedTime):
                                  editBlockedTimeName(blockedTime);
                                default:
                                  return;
                              }
                            },
                            canEditDetails:
                                editingItem is EditingScheduledTask ||
                                editingItem is EditingBlockedTime,
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

class _FreeTimeLabel extends StatelessWidget {
  const _FreeTimeLabel({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final color = minutes == 0
        ? CadenceColors.warning
        : CadenceColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(Icons.hourglass_empty, size: 11, color: color),
        Text(
          'FREE: ${formatDurationLabel(minutes)}',
          style: GoogleFonts.jetBrainsMono(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
