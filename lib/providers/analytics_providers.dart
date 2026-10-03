import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/providers/habit_providers.dart';
import 'package:cadence/providers/schedule_providers.dart';

final analyticsRangeProvider =
    NotifierProvider<AnalyticsRangeNotifier, AnalyticsRange>(
      () => AnalyticsRangeNotifier(),
    );

class AnalyticsRangeNotifier extends Notifier<AnalyticsRange> {
  @override
  AnalyticsRange build() => AnalyticsRange.week;

  void select(AnalyticsRange range) => state = range;
}

final analyticsStateProvider = Provider<AsyncValue<AnalyticsMetrics>>((ref) {
  final range = ref.watch(analyticsRangeProvider);
  final tasksAsync = ref.watch(scheduledTasksProvider);
  final occurrencesAsync = ref.watch(habitOccurrencesProvider);
  final habitsAsync = ref.watch(habitsProvider);

  final states = [tasksAsync, occurrencesAsync, habitsAsync];

  if (states.any((state) => state.isLoading)) {
    return const AsyncLoading();
  }

  for (final state in states) {
    if (state.hasError) return AsyncError(state.error!, state.stackTrace!);
  }

  return AsyncData(
    computeAnalytics(
      range: range,
      today: DateTime.now(),
      scheduledTasks: tasksAsync.requireValue,
      habitOccurrences: occurrencesAsync.requireValue,
      habits: habitsAsync.requireValue,
    ),
  );
});
