import 'package:cadence/providers/habit_providers.dart';
import 'package:cadence/utils/habit_schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/constants/app_constants.dart';
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

enum _SheetTab { task, habit, blocked }

const _recentBlockedTimeNamesLimit = 8;

/// Opens a bottom sheet to choose a task, habit or blocked time for the active
/// planner slot.
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
    final color = _colorOf(_tab);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ADD TO SLOT',
                      style: GoogleFonts.jetBrainsMono(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                    _SheetTab.blocked => 'BLOCK',
                  },
                  primaryColorOf: _colorOf,
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
                    _SheetTab.blocked => _BlockedTimePicker(
                      onPick: (name) {
                        notifier.handleAddBlockedTimeToPlan(name);
                        Navigator.of(context).pop();
                      },
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _colorOf(_SheetTab tab) => switch (tab) {
    _SheetTab.task => CadenceColors.accent,
    _SheetTab.habit => CadenceColors.otherAccent,
    _SheetTab.blocked => CadenceColors.blocked,
  };
}

class _TaskPicker extends ConsumerWidget {
  const _TaskPicker({required this.onPick, required this.onCreateNew});

  final void Function(Task) onPick;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
    final expectedAsync = ref.watch(habitsProvider);
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
          icon: Icons.repeat,
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
            if (isHabitExpectedOn(habit, day))
              CadenceBadge(
                label: 'DUE: TODAY',
                primaryColor: CadenceColors.warning,
              ),
          ],
          onTap: () => onPick(habit),
        );
      },
    );
  }
}

/// Names blocked time for the slot, with recently used names as quick picks.
class _BlockedTimePicker extends ConsumerStatefulWidget {
  const _BlockedTimePicker({required this.onPick});

  final void Function(String) onPick;

  @override
  ConsumerState<_BlockedTimePicker> createState() => _BlockedTimePickerState();
}

class _BlockedTimePickerState extends ConsumerState<_BlockedTimePicker> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onPick(name);
  }

  @override
  Widget build(BuildContext context) {
    const color = CadenceColors.blocked;
    final query = _nameController.text.trim().toLowerCase();
    final recentNames =
        (ref.watch(recentBlockedTimeNamesProvider).value ?? const <String>[])
            .where((n) => n.toLowerCase().contains(query))
            .take(_recentBlockedTimeNamesLimit)
            .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'TIME THAT ISN\'T FREE, LIKE EATING OR COMMUTING',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CadenceColors.textSecondary.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: _nameController,
                  maxLength: AppConstants.blockedTimeNameMaxLength,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  cursorColor: CadenceColors.textSecondary,
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textPrimary,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    hintText: 'e.g. Lunch, Drive to work...',
                    hintStyle: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textSecondary,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            CadenceButton(
              primaryColor: color,
              label: 'BLOCK',
              prefixIcon: Icons.block,
              disabled: query.isEmpty,
              onPress: _submit,
            ),
          ],
        ),

        if (recentNames.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'RECENT',
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: recentNames.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final name = recentNames[index];
                return _PickerRow(
                  color: color,
                  title: name,
                  icon: Icons.block,
                  onTap: () => widget.onPick(name),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.color,
    required this.title,
    this.badges = const [],
    required this.onTap,
    this.icon,
  });

  final Color color;
  final String title;
  final List<Widget> badges;
  final VoidCallback onTap;
  final IconData? icon;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              spacing: 6,
              children: [
                if (icon != null) Icon(icon, size: 14, color: color),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, size: 16, color: color),
              ],
            ),
            if (badges.isNotEmpty) Row(spacing: 5, children: badges),
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
