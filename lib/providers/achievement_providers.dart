import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/achievement.dart';
import 'package:cadence/data/achievement_catalog.dart';
import 'package:cadence/data/achievement_unlock.dart';
import 'package:cadence/data/gamification_metrics.dart';
import 'package:cadence/data/isar_data_store.dart';
import 'package:cadence/providers/habit_providers.dart';
import 'package:cadence/providers/schedule_providers.dart';

final gamificationStateProvider = Provider<AsyncValue<GamificationMetrics>>((
  ref,
) {
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
    computeGamification(
      today: DateTime.now(),
      scheduledTasks: tasksAsync.requireValue,
      habitOccurrences: occurrencesAsync.requireValue,
      habits: habitsAsync.requireValue,
    ),
  );
});

final achievementUnlockControllerProvider =
    NotifierProvider<AchievementUnlockController, void>(
      () => AchievementUnlockController(),
    );

/// Compares freshly computed progress against the tiers already announced and
/// persists the difference. Returns the tiers that are newly unlocked, so the
/// caller can celebrate them once.
class AchievementUnlockController extends Notifier<void> {
  @override
  void build() {}

  List<({AchievementDefinition definition, AchievementTier tier})> sync(
    GamificationMetrics metrics,
  ) {
    final announced = IsarDataStore.getAnnouncedAchievementKeys();
    final earned = metrics.earnedTierKeys;

    // First run: adopt everything already earned without celebrating it.
    if (!announced.contains(achievementBackfillKey)) {
      IsarDataStore.addAchievementUnlocks({achievementBackfillKey, ...earned});
      return const [];
    }

    final newKeys = earned.difference(announced);
    if (newKeys.isEmpty) return const [];

    IsarDataStore.addAchievementUnlocks(newKeys);

    return [
      for (final definition in achievementCatalog)
        for (final tier in AchievementTier.values)
          if (newKeys.contains(achievementTierKey(definition.id, tier)))
            (definition: definition, tier: tier),
    ];
  }
}
