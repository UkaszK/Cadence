import 'package:cadence/data/achievement.dart';
import 'package:cadence/data/achievement_catalog.dart';
import 'package:cadence/data/day.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/utils/habit_schedule.dart';

/// One day of the recent activity strip shown next to the streak.
class StreakDay {
  const StreakDay({required this.date, required this.done});

  final DateTime date;
  final int done;

  bool get active => done > 0;
}

class GamificationMetrics {
  const GamificationMetrics({
    required this.currentStreak,
    required this.bestStreak,
    required this.recentDays,
    required this.achievements,
  });

  /// Consecutive days (ending today or yesterday) with at least one completion.
  final int currentStreak;
  final int bestStreak;

  /// The last 7 days, oldest first.
  final List<StreakDay> recentDays;

  /// One entry per catalog definition, in catalog order.
  final List<AchievementProgress> achievements;

  int get earnedBadges =>
      achievements.fold(0, (sum, a) => sum + a.earnedTiers.length);

  int get totalBadges => achievementBadgeCount;

  List<AchievementProgress> get unlocked =>
      achievements.where((a) => a.isUnlocked).toList();

  /// Closest achievements to their next tier, unmaxed ones only.
  List<AchievementProgress> get nearestToNextTier {
    final candidates = achievements.where((a) => !a.isMaxed).toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
    return candidates;
  }

  /// Keys identifying every tier earned so far, e.g. "earlyBird:gold".
  Set<String> get earnedTierKeys => {
    for (final achievement in achievements)
      for (final tier in achievement.earnedTiers)
        achievementTierKey(achievement.definition.id, tier),
  };
}

String achievementTierKey(AchievementId id, AchievementTier tier) =>
    '${id.name}:${tier.name}';

DateTime _dateOnly(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);

GamificationMetrics computeGamification({
  required DateTime today,
  required List<ScheduledTask> scheduledTasks,
  required List<HabitOccurrence> habitOccurrences,
  required List<Habit> habits,
}) {
  final endDate = _dateOnly(today);

  final tasksByDay = <DateTime, List<ScheduledTask>>{};
  for (final task in scheduledTasks) {
    tasksByDay.putIfAbsent(_dateOnly(task.startTime), () => []).add(task);
  }

  final habitCompletionsByDay = <DateTime, List<HabitOccurrence>>{};
  for (final occurrence in habitOccurrences) {
    if (!occurrence.completed) continue;
    habitCompletionsByDay
        .putIfAbsent(_dateOnly(occurrence.occurrenceDate), () => [])
        .add(occurrence);
  }

  // Walk from the first day with any data up to today. The strip always needs
  // the last 7 days, so never start later than that.
  final knownDays = <DateTime>{
    ...tasksByDay.keys,
    ...habitCompletionsByDay.keys,
  };
  final stripStart = endDate.subtract(const Duration(days: 6));
  var startDate = stripStart;
  for (final day in knownDays) {
    if (day.isBefore(startDate)) startDate = day;
  }

  final activeDays = <DateTime>{};
  final recentDays = <StreakDay>[];

  var perfectDays = 0;
  var focusMasterDays = 0;
  var weekendCompletions = 0;

  final totalDays = endDate.difference(startDate).inDays + 1;
  for (var i = 0; i < totalDays; i++) {
    final date = startDate.add(Duration(days: i));
    final weekday = Day.fromDateTime(date);
    final dayTasks = tasksByDay[date] ?? const [];
    final dayCompletions = habitCompletionsByDay[date] ?? const [];

    var dayDone = 0;
    var dayPlanned = 0;

    for (final task in dayTasks) {
      dayPlanned++;
      if (task.completed) dayDone++;
    }

    final completedHabitIds = dayCompletions.map((c) => c.habitId).toSet();
    final expectedIds = <int>{};

    for (final habit in habits) {
      if (!isHabitExpectedOn(habit, date)) continue;
      expectedIds.add(habit.id);
      dayPlanned++;
      if (completedHabitIds.contains(habit.id)) dayDone++;
    }

    // Completions for habits not expected that day still count as work done.
    for (final completion in dayCompletions) {
      if (expectedIds.contains(completion.habitId)) continue;
      dayDone++;
      dayPlanned++;
    }

    if (dayDone > 0) activeDays.add(date);
    if (dayPlanned > 0 && dayDone == dayPlanned) perfectDays++;
    if (dayDone >= focusMasterDailyTarget) focusMasterDays++;
    if (weekday == Day.saturday || weekday == Day.sunday) {
      weekendCompletions += dayDone;
    }

    if (!date.isBefore(stripStart)) {
      recentDays.add(StreakDay(date: date, done: dayDone));
    }
  }

  final (currentStreak, bestStreak) = _computeStreaks(activeDays, endDate);

  var tasksCompleted = 0;
  var focusMinutes = 0;
  var earlyBird = 0;
  var nightOwl = 0;

  for (final task in scheduledTasks) {
    if (!task.completed) continue;
    tasksCompleted++;
    focusMinutes += task.durationInMinutes;
    _countTimeOfDay(task.completedAt, () => earlyBird++, () => nightOwl++);
  }

  var habitsCompleted = 0;
  for (final occurrence in habitOccurrences) {
    if (!occurrence.completed) continue;
    habitsCompleted++;
    _countTimeOfDay(
      occurrence.completedAt,
      () => earlyBird++,
      () => nightOwl++,
    );
  }

  final values = <AchievementId, int>{
    AchievementId.streakKeeper: bestStreak,
    AchievementId.earlyBird: earlyBird,
    AchievementId.nightOwl: nightOwl,
    AchievementId.focusMaster: focusMasterDays,
    AchievementId.perfectDay: perfectDays,
    AchievementId.deepWork: focusMinutes,
    AchievementId.taskFinisher: tasksCompleted,
    AchievementId.habitHero: habitsCompleted,
    AchievementId.weekendWarrior: weekendCompletions,
  };

  return GamificationMetrics(
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    recentDays: recentDays,
    achievements: achievementCatalog
        .map(
          (definition) => AchievementProgress(
            definition: definition,
            value: values[definition.id] ?? 0,
          ),
        )
        .toList(),
  );
}

void _countTimeOfDay(
  DateTime? completedAt,
  void Function() onEarly,
  void Function() onLate,
) {
  if (completedAt == null) return;
  if (completedAt.hour < earlyBirdHour) onEarly();
  if (completedAt.hour >= nightOwlHour) onLate();
}

(int current, int best) _computeStreaks(
  Set<DateTime> activeDays,
  DateTime today,
) {
  if (activeDays.isEmpty) return (0, 0);

  // Current streak: walk backwards from today; allow today to be pending.
  var cursor = activeDays.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  var current = 0;
  while (activeDays.contains(cursor)) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  // Best streak: longest run of consecutive active days.
  final sorted = activeDays.toList()..sort();
  var best = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final gap = sorted[i].difference(sorted[i - 1]).inDays;
    if (gap == 1) {
      run++;
      if (run > best) best = run;
    } else if (gap > 1) {
      run = 1;
    }
  }

  return (current, best < current ? current : best);
}
