import 'package:cadence/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/data/task_filter_option.dart';
import 'package:cadence/providers/library_providers.dart';
import 'package:cadence/providers/navigation_bar_providers.dart';
import 'package:cadence/providers/planner_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/cadence_loading_screen.dart';
import 'package:cadence/widgets/forms/fields/cadence_switch.dart';
import 'package:cadence/widgets/library_screen/category_header.dart';
import 'package:cadence/widgets/library_screen/habit_block.dart';
import 'package:cadence/widgets/library_screen/item_actions.dart';
import 'package:cadence/widgets/library_screen/library_empty_note.dart';
import 'package:cadence/widgets/library_screen/task_block.dart';
import 'package:cadence/widgets/reusables/cadence_button.dart';
import 'package:cadence/widgets/reusables/cadence_dropdown.dart';
import 'package:cadence/widgets/reusables/cadence_screen_container.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryStateProvider);
    final tab = ref.watch(libraryTabProvider);
    final filterState = ref.watch(libraryFilterProvider);
    final filterNotifier = ref.read(libraryFilterProvider.notifier);

    return libraryAsync.when(
      data: (state) {
        final count = switch (tab) {
          LibraryTab.tasks => state.taskCount,
          LibraryTab.habits => state.habitCount,
        };

        return CadenceScreenContainer(
          spacing: 20,
          children: [
            FadeInTransition(
              delay: Duration.zero,
              child: _Header(
                subtitle: switch (tab) {
                  LibraryTab.tasks => '$count TASKS IN LIBRARY',
                  LibraryTab.habits => '$count HABITS IN LIBRARY',
                },
                rightSide: tab == LibraryTab.tasks
                    ? CadenceDropdown(
                        options: TaskFilterOption.values,
                        selection: filterState.filter,
                        onChange: filterNotifier.setFilter,
                        labelOf: (filter) => filter.label,
                        primaryColorOf: (filter) => filter.color,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            FadeInTransition(
              delay: const Duration(milliseconds: 100),
              child: CadenceSwitch<LibraryTab>(
                options: LibraryTab.values,
                selection: tab,
                labelOf: (t) => switch (t) {
                  LibraryTab.tasks => 'TASKS',
                  LibraryTab.habits => 'HABITS',
                },
                primaryColorOf: (t) => switch (t) {
                  LibraryTab.tasks => CadenceColors.accent,
                  LibraryTab.habits => CadenceColors.otherAccent,
                },
                onChange: ref.read(libraryTabProvider.notifier).select,
              ),
            ),
            FadeInTransition(
              delay: const Duration(milliseconds: 150),
              child: Row(
                mainAxisAlignment: .end,
                children: [
                  Text(
                    'SHOW ARCHIVED',
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.textSecondary,
                      fontSize: 10,
                      fontWeight: .bold,
                    ),
                  ),
                  Switch(
                    value: filterState.showArchived,
                    onChanged: filterNotifier.toggleShowArchived,
                    activeThumbColor: CadenceColors.accent,
                    materialTapTargetSize: .shrinkWrap,
                  ),
                ],
              ),
            ),
            FadeInTransition(
              delay: const Duration(milliseconds: 200),
              child: switch (tab) {
                LibraryTab.tasks => _TaskList(
                  tasksByCategory: state.tasksByCategory,
                ),
                LibraryTab.habits => _HabitList(
                  habitsByCategory: state.habitsByCategory,
                ),
              },
            ),
          ],
        );
      },
      error: (error, stack) => Center(child: Text('Error loading: $error')),
      loading: () => CadenceLoadingScreen(),
    );
  }
}

List<TaskCategory> _sortedByCount<T>(Map<TaskCategory, List<T>> byCategory) {
  return byCategory.keys.toList()
    ..sort((a, b) => byCategory[b]!.length.compareTo(byCategory[a]!.length));
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasksByCategory});

  final Map<TaskCategory, List<Task>> tasksByCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(libraryControllerProvider.notifier);
    final navigationNotifier = ref.read(navigationProvider.notifier);
    final plannerNotifier = ref.read(plannerViewStateNotifierProvider.notifier);

    if (tasksByCategory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 96),
        child: LibraryEmptyNote(
          title: 'NO TASKS',
          subtitle: 'YOUR TASK LIBRARY IS EMPTY',
          hint: 'ADD YOUR FIRST TASK',
        ),
      );
    }

    return Column(
      children: [
        for (final category in _sortedByCount(tasksByCategory)) ...[
          CategoryHeader(
            label: category.name,
            count: tasksByCategory[category]!.length,
          ),

          const SizedBox(height: 10),

          Column(
            spacing: 10,
            children: [
              for (final task in tasksByCategory[category]!)
                TaskBlock(
                  task: task,
                  footer: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          ItemIconButton(
                            icon: Icons.edit,
                            onPress: () =>
                                controller.onClickEditTask(context, task),
                          ),
                          if (task.archived)
                            ItemIconButton(
                              icon: Icons.unarchive,
                              onPress: () => controller.unarchiveTask(task),
                            )
                          else
                            ItemIconButton(
                              icon: Icons.archive,
                              onPress: () async {
                                final confirmed = await confirmArchive(
                                  context,
                                  name: task.name,
                                  kind: 'task',
                                );
                                if (confirmed) controller.archiveTask(task);
                              },
                            ),
                        ],
                      ),
                      if (!task.archived)
                        CadenceButton(
                          primaryColor: CadenceColors.accent,
                          onPress: () {
                            plannerNotifier.updateSelectedDay(DateTime.now());
                            plannerNotifier.handleAddTaskToPlan(task);
                            navigationNotifier.setIndex(1);
                          },
                          label: 'PLAN TODAY',
                          fontSize: 10,
                          prefixIcon: Icons.add_circle_outline,
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

class _HabitList extends ConsumerWidget {
  const _HabitList({required this.habitsByCategory});

  final Map<TaskCategory, List<Habit>> habitsByCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(libraryControllerProvider.notifier);

    if (habitsByCategory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 96),
        child: LibraryEmptyNote(
          title: 'NO HABITS',
          subtitle: 'YOUR HABIT LIBRARY IS EMPTY',
          hint: 'ADD YOUR FIRST HABIT',
        ),
      );
    }

    return Column(
      children: [
        for (final category in _sortedByCount(habitsByCategory)) ...[
          CategoryHeader(
            label: category.name,
            count: habitsByCategory[category]!.length,
            singular: 'HABIT',
            plural: 'HABITS',
          ),

          const SizedBox(height: 10),

          Column(
            spacing: 10,
            children: [
              for (final habit in habitsByCategory[category]!)
                HabitBlock(
                  habit: habit,
                  footer: Row(
                    spacing: 10,
                    children: [
                      ItemIconButton(
                        icon: Icons.edit,
                        onPress: () =>
                            controller.onClickEditHabit(context, habit),
                      ),
                      if (habit.archived)
                        ItemIconButton(
                          icon: Icons.unarchive,
                          onPress: () => controller.unarchiveHabit(habit),
                        )
                      else
                        ItemIconButton(
                          icon: Icons.archive,
                          onPress: () async {
                            final confirmed = await confirmArchive(
                              context,
                              name: habit.name,
                              kind: 'habit',
                            );
                            if (confirmed) controller.archiveHabit(habit);
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.subtitle, required this.rightSide});

  final String subtitle;
  final Widget rightSide;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'LIBRARY',
              style: GoogleFonts.jetBrainsMono(
                color: CadenceColors.textPrimary,
                fontSize: 16,
                fontWeight: .w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.jetBrainsMono(
                color: CadenceColors.textSecondary,
                fontSize: 10,
                fontWeight: .bold,
              ),
            ),
          ],
        ),

        rightSide,
      ],
    );
  }
}
