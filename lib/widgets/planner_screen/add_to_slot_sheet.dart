import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/providers/planner_providers.dart';
import 'package:cadence/providers/schedule_providers.dart';
import 'package:cadence/providers/task_providers.dart';
import 'package:cadence/screens/task_form_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/forms/fields/cadence_switch.dart';
import 'package:cadence/widgets/library_screen/task_block.dart';
import 'package:cadence/widgets/reusables/cadence_badge.dart';
import 'package:cadence/widgets/reusables/cadence_button.dart';

enum _SheetTab { task, habit }

/// Opens a bottom sheet to choose a task or habit for the active planner slot.
Future<void> showAddToSlotSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddToSlotSheet(),
  );
}

class AddToSlotSheet extends ConsumerStatefulWidget {
  const AddToSlotSheet({super.key});

  @override
  ConsumerState<AddToSlotSheet> createState() => _AddToSlotSheetState();
}

class _AddToSlotSheetState extends ConsumerState<AddToSlotSheet> {
  _SheetTab _tab = _SheetTab.task;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(plannerViewStateNotifierProvider.notifier);
    final selectedDay = ref.watch(
      plannerViewStateNotifierProvider.select((s) => s.selectedDay),
    );
    final color = switch (_tab) {
      _SheetTab.task => CadenceColors.accent,
      _SheetTab.habit => CadenceColors.otherAccent,
    };

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: CadenceColors.surface,
        border: Border(top: BorderSide(width: 1, color: color)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'ADD TO SLOT',
                    style: GoogleFonts.jetBrainsMono(
                      color: color,
                      fontSize: 12,
                      fontWeight: .bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: CadenceColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              CadenceSwitch<_SheetTab>(
                options: _SheetTab.values,
                selection: _tab,
                labelOf: (t) => switch (t) {
                  _SheetTab.task => 'TASK',
                  _SheetTab.habit => 'HABIT',
                },
                primaryColorOf: (t) => switch (t) {
                  _SheetTab.task => CadenceColors.accent,
                  _SheetTab.habit => CadenceColors.otherAccent,
                },
                onChange: (t) => setState(() => _tab = t),
              ),

              const SizedBox(height: 12),

              Flexible(
                child: switch (_tab) {
                  _SheetTab.task => _TaskPicker(
                    onPick: (task) {
                      notifier.handleAddTaskToPlan(task);
                      Navigator.of(context).pop();
                    },
                    onCreateNew: () {
                      final rootNavigator = Navigator.of(
                        context,
                        rootNavigator: true,
                      );
                      Navigator.of(context).pop();
                      rootNavigator.push(
                        MaterialPageRoute(
                          builder: (_) => TaskFormScreen(
                            onCreated: notifier.handleAddTaskToPlan,
                          ),
                        ),
                      );
                    },
                  ),
                  _SheetTab.habit => _HabitPicker(
                    day: selectedDay,
                    onPick: (habit) {
                      notifier.handleAddHabitToPlan(habit);
                      Navigator.of(context).pop();
                    },
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskPicker extends ConsumerWidget {
  const _TaskPicker({required this.onPick, required this.onCreateNew});

  final void Function(Task) onPick;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        CadenceButton(
          primaryColor: CadenceColors.accent,
          label: 'CREATE NEW TASK',
          prefixIcon: Icons.add,
          expandHorizontally: true,
          onPress: onCreateNew,
        ),

        const SizedBox(height: 12),

        Flexible(
          child: tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return _EmptyHint(
                  text: 'NO TASKS IN LIBRARY',
                  color: CadenceColors.accent,
                );
              }
              final sorted = List.of(tasks)..sort();
              return ListView.separated(
                shrinkWrap: true,
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final task = sorted[index];
                  return _PickerRow(
                    color: CadenceColors.accent,
                    title: task.name,
                    badges: [
                      CadenceBadge(
                        label: task.categoryName.toUpperCase(),
                        primaryColor: CadenceColors.accent,
                        prefixIcon: task.category.icon,
                      ),
                      CadenceBadge(
                        label: formatDurationLabel(task.durationMinutes),
                        primaryColor: CadenceColors.textSecondary,
                        prefixIcon: Icons.timer_outlined,
                      ),
                      if (task.oneOff)
                        CadenceBadge(
                          label: 'DUE: ${task.dueText}',
                          primaryColor: CadenceColors.warning,
                        ),
                    ],
                    onTap: () => onPick(task),
                  );
                },
              );
            },
            error: (e, _) => Text('Error loading: $e'),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }
}

class _HabitPicker extends ConsumerWidget {
  const _HabitPicker({required this.day, required this.onPick});

  final DateTime day;
  final void Function(Habit) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expectedAsync = ref.watch(expectedHabitsForDayProvider(day));
    final placedAsync = ref.watch(placedHabitOccurrencesForDayProvider(day));

    if (expectedAsync.isLoading || placedAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (expectedAsync.hasError || placedAsync.hasError) {
      return Text('Error loading: ${expectedAsync.error ?? placedAsync.error}');
    }

    final placedIds = placedAsync.requireValue.map((o) => o.habitId).toSet();
    final habits = expectedAsync.requireValue
        .where((h) => !placedIds.contains(h.id))
        .toList();

    if (habits.isEmpty) {
      return _EmptyHint(
        text: 'NO UNPLACED HABITS FOR THIS DAY',
        color: CadenceColors.otherAccent,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: habits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final habit = habits[index];
        return _PickerRow(
          color: CadenceColors.otherAccent,
          title: habit.name,
          isHabit: true,
          badges: [
            CadenceBadge(
              label: habit.categoryName.toUpperCase(),
              primaryColor: CadenceColors.otherAccent,
              prefixIcon: habit.category.icon,
            ),
            CadenceBadge(
              label: formatDurationLabel(habit.durationMinutes),
              primaryColor: CadenceColors.textSecondary,
              prefixIcon: Icons.timer_outlined,
            ),
          ],
          onTap: () => onPick(habit),
        );
      },
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.color,
    required this.title,
    required this.badges,
    required this.onTap,
    this.isHabit = false,
  });

  final Color color;
  final String title;
  final List<Widget> badges;
  final VoidCallback onTap;
  final bool isHabit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CadenceColors.surfaceOnSurface,
          border: Border(left: BorderSide(color: color, width: 3)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: .start,
          spacing: 6,
          children: [
            Row(
              spacing: 6,
              children: [
                if (isHabit) Icon(Icons.repeat, size: 14, color: color),
                Expanded(
                  child: Text(
                    title,
                    overflow: .ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textPrimary,
                      fontSize: 13,
                      fontWeight: .bold,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: color),
              ],
            ),
            Wrap(spacing: 5, runSpacing: 5, children: badges),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.jetBrainsMono(
            color: color,
            fontSize: 11,
            fontWeight: .bold,
          ),
        ),
      ),
    );
  }
}
