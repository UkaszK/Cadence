import 'package:cadence/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cadence/constants/app_constants.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/providers/dashboard_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/dashboard_screen/daily_progress/dashboard_daily_progress.dart';
import 'package:cadence/widgets/dashboard_screen/habits/dashboard_habits.dart';
import 'package:cadence/widgets/dashboard_screen/plan/dashboard_plan.dart';
import 'package:cadence/widgets/cadence_loading_screen.dart';
import 'package:cadence/widgets/planner_screen/edit_scheduled_task_sheet.dart';
import 'package:cadence/widgets/reusables/cadence_screen_container.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _selectDate(
    BuildContext context,
    DateTime selectedDay,
    void Function(DateTime) onChange,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: CadenceColors.accent,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChange(picked);
    }
  }

  void _showAutoArchiveSnackBar(
    BuildContext context,
    Task task,
    void Function(Task) onUndo,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: CadenceColors.surface,
          behavior: SnackBarBehavior.floating,
          duration: AppConstants.snackBarDuration,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: CadenceColors.accent, width: 1),
          ),
          content: Row(
            children: [
              const Icon(Icons.archive, size: 18, color: CadenceColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPLETED & ARCHIVED',
                      style: GoogleFonts.jetBrainsMono(
                        color: CadenceColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        color: CadenceColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: CadenceColors.accent,
            onPressed: () => onUndo(task),
          ),
        ),
      );
  }

  Future<void> _editScheduledTaskDetails(
    BuildContext context,
    ScheduledTask scheduledTask,
    DashboardViewStateNotifier notifier,
  ) async {
    final details = await showEditScheduledTaskSheet(context, scheduledTask);
    if (details == null) return;
    notifier.updateScheduledTaskDetails(
      scheduledTask,
      name: details.name,
      subTasks: details.subTasks,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dashboardViewStateNotifierProvider.notifier);
    final dashboardViewState = ref.watch(dashboardViewStateNotifierProvider);
    final selectedDay = dashboardViewState.selectedDay;
    final dashboardStateAsync = ref.watch(dashboardStateProvider(selectedDay));

    return dashboardStateAsync.when(
      data: (state) {
        return CadenceScreenContainer(
          spacing: 25,
          children: [
            FadeInTransition(
              delay: Duration.zero,
              child: _Header(
                selectedDay: selectedDay,
                leftAction: () => notifier.shiftDay(-1),
                rightAction: () => notifier.shiftDay(1),
                onClickDate: () =>
                    _selectDate(context, selectedDay, notifier.setDay),
              ),
            ),
            FadeInTransition(
              delay: const Duration(milliseconds: 100),
              child: DashboardDailyProgress(progress: state.progress),
            ),
            FadeInTransition(
              delay: const Duration(milliseconds: 150),
              child: CadenceValueSwitcher(
                value: DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                ),
                directionOf: (previous, next) =>
                    next.isAfter(previous) ? 1 : -1,
                slideFraction: 0.03,
                builder: (_) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 25,
                  children: [
                    DashboardPlan(
                      scheduledTasks: state.scheduledTasks,
                      placedHabits: state.placedHabits,
                      onCheckScheduledTask: (scheduledTask, newValue) {
                        final archived = notifier.checkScheduledTask(
                          scheduledTask,
                          newValue,
                        );
                        if (archived != null) {
                          _showAutoArchiveSnackBar(
                            context,
                            archived,
                            notifier.undoAutoArchive,
                          );
                        }
                      },
                      onCheckSubTask: (scheduledTask, subTask, newValue) {
                        final archived = notifier.checkSubTask(
                          scheduledTask,
                          subTask,
                          newValue,
                        );
                        if (archived != null) {
                          _showAutoArchiveSnackBar(
                            context,
                            archived,
                            notifier.undoAutoArchive,
                          );
                        }
                      },
                      onCheckHabitOccurrence: notifier.checkHabitOccurrence,
                      onEditScheduledTask: (scheduledTask) =>
                          _editScheduledTaskDetails(
                            context,
                            scheduledTask,
                            notifier,
                          ),
                    ),
                    DashboardHabits(
                      expectedHabits: state.expectedHabits,
                      completedHabitIds: state.completedHabitIds,
                      dayOccurrences: state.habitOccurrences,
                      onCheckHabit: (habit, newValue) => notifier.checkHabit(
                        habit,
                        newValue,
                        state.habitOccurrences,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      error: (error, stack) => Center(child: Text('Error loading: $error')),
      loading: () => CadenceLoadingScreen(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedDay,
    required this.leftAction,
    required this.rightAction,
    required this.onClickDate,
  });

  final DateTime selectedDay;
  final VoidCallback leftAction;
  final VoidCallback rightAction;
  final VoidCallback onClickDate;

  static final _dayFormat = DateFormat('EEE, d MMM');

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DASHBOARD',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DAILY OVERVIEW',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _DayNavButton(icon: Icons.chevron_left, onTap: leftAction),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClickDate,
              child: CadenceValueSwitcher(
                value: DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                ),
                directionOf: (previous, next) =>
                    next.isAfter(previous) ? 1 : -1,
                slideFraction: 0.35,
                builder: (day) => Text(
                  _dayFormat.format(day).toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _DayNavButton(icon: Icons.chevron_right, onTap: rightAction),
          ],
        ),
      ],
    );
  }
}

class _DayNavButton extends StatelessWidget {
  const _DayNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.all(6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: CadenceColors.border, width: 1),
          ),
          child: Icon(icon, size: 14, color: CadenceColors.textSecondary),
        ),
      ),
    );
  }
}
