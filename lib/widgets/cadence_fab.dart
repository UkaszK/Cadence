import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/providers/library_providers.dart';
import 'package:cadence/providers/navigation_bar_providers.dart';
import 'package:cadence/screens/habit_form_screen.dart';
import 'package:cadence/screens/task_form_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';

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
          mainAxisSize: .min,
          children: [
            const SizedBox(height: 8),
            _ChooserTile(
              icon: Icons.task_alt,
              color: CadenceColors.accent,
              title: 'New Task',
              subtitle: 'One-off or repeatable work you plan into a slot',
              onTap: () {
                Navigator.pop(sheetContext);
                _openTaskForm(context);
              },
            ),
            _ChooserTile(
              icon: Icons.repeat,
              color: CadenceColors.otherAccent,
              title: 'New Habit',
              subtitle: 'Recurs on weekdays or every N days',
              onTap: () {
                Navigator.pop(sheetContext);
                _openHabitForm(context);
              },
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

    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'main_center_fab',
        onPressed: () {
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
        backgroundColor: color,
        shape: CircleBorder(
          side: BorderSide(
            color: CadenceColors.black.withValues(alpha: 0.8),
            width: 3,
          ),
        ),
        elevation: 2,
        child: Icon(Icons.add, color: CadenceColors.black, size: 32),
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
        alignment: .center,
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
          fontWeight: .bold,
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
