import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/providers/habit_form_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/forms/habit_form.dart';
import 'package:cadence/widgets/reusables/cadence_new_screen_container.dart';

class HabitFormScreen extends ConsumerWidget {
  const HabitFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(habitFormNotifierProvider.notifier);

    return CadenceNewScreenContainer(
      children: [
        Text(
          'NEW HABIT',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.otherAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(height: 32),
        HabitForm(onSubmit: notifier.submit),
      ],
    );
  }
}
