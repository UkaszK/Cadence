import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/providers/library_providers.dart';
import 'package:cadence/providers/navigation_bar_providers.dart';
import 'package:cadence/screens/habit_form_screen.dart';
import 'package:cadence/screens/task_form_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';

/// Central "+" button. On the Library tab it opens the form matching the
/// active segment; elsewhere it asks whether to create a task or a habit.
class CadenceFAB extends ConsumerWidget {
  const CadenceFAB({super.key});

  static const _libraryTabIndex = 3;

  void _openTaskForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
  }

  void _openHabitForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HabitFormScreen()),
    );
  }

  Future<void> _showChooser(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: CadenceColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            FadeInTransition(
              child: _ChooserTile(
                icon: Icons.task_alt,
                color: CadenceColors.accent,
                title: 'New Task',
                subtitle: 'One-off or repeatable work you plan into a slot',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openTaskForm(context);
                },
              ),
            ),
            FadeInTransition(
              delay: const Duration(milliseconds: 50),
              child: _ChooserTile(
                icon: Icons.repeat,
                color: CadenceColors.otherAccent,
                title: 'New Habit',
                subtitle: 'Recurs on weekdays or every N days',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openHabitForm(context);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final libraryTab = ref.watch(libraryTabProvider);

    final isLibrary = currentIndex == _libraryTabIndex;
    final color = isLibrary && libraryTab == LibraryTab.habits
        ? CadenceColors.otherAccent
        : CadenceColors.accent;

    return PressScale(
      scale: 0.92,
      child: Semantics(
        button: true,
        label: isLibrary && libraryTab == LibraryTab.habits
            ? 'New habit'
            : 'Add',
        child: GestureDetector(
          onTap: () {
            if (!isLibrary) {
              _showChooser(context);
              return;
            }
            switch (libraryTab) {
              case LibraryTab.tasks:
                _openTaskForm(context);
              case LibraryTab.habits:
                _openHabitForm(context);
            }
          },
          child: AnimatedContainer(
            duration: CadenceMotion.of(context, AnimationDurations.fast),
            curve: CadenceMotion.enter,
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: CadenceColors.black.withValues(alpha: 0.8),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.add, color: CadenceColors.black, size: 32),
          ),
        ),
      ),
    );
  }
}

class _ChooserTile extends StatelessWidget {
  const _ChooserTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color),
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          color: CadenceColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.jetBrainsMono(
          color: CadenceColors.textSecondary,
          fontSize: 11,
        ),
      ),
      onTap: onTap,
    );
  }
}
