import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/providers/task_form_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/forms/task_form.dart';
import 'package:cadence/widgets/reusables/cadence_new_screen_container.dart';

class TaskFormScreen extends ConsumerWidget {
  const TaskFormScreen({super.key, this.onCreated});

  /// Called with the saved task after it has been persisted.
  final void Function(Task)? onCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(taskFormNotifierProvider.notifier);

    return CadenceNewScreenContainer(
      children: [
        Text(
          'NEW TASK',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.accent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(height: 32),
        TaskForm(
          onSubmit: (task) {
            notifier.submit(task);
            onCreated?.call(task);
          },
        ),
      ],
    );
  }
}
