import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/providers/habit_providers.dart';

final habitFormNotifierProvider = NotifierProvider<HabitFormNotifier, void>(
  () => HabitFormNotifier(),
);

class HabitFormNotifier extends Notifier<void> {
  @override
  void build() {}

  void submit(Habit habit) => HabitService.add(habit);
}
