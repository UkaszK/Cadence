import 'package:cadence/data/day.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/habit_occurrence.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/utils/habit_schedule.dart';

enum AnalyticsRange {
  week(days: 7, label: '7D'),
  month(days: 30, label: '30D'),
  quarter(days: 90, label: '90D');

  const AnalyticsRange({required this.days, required this.label});

  final int days;
  final String label;
}

enum DayWindow {
  morning(label: 'MORNING', hint: '05-12'),
  afternoon(label: 'AFTERNOON', hint: '12-17'),
  evening(label: 'EVENING', hint: '17-22'),
  night(label: 'NIGHT', hint: '22-05');

  const DayWindow({required this.label, required this.hint});

  final String label;
  final String hint;

  static DayWindow fromDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 5 && hour < 12) return DayWindow.morning;
    if (hour >= 12 && hour < 17) return DayWindow.afternoon;
    if (hour >= 17 && hour < 22) return DayWindow.evening;
    return DayWindow.night;
  }
}

double _rate(int done, int planned) =>
    planned == 0 ? 0 : (done / planned).clamp(0.0, 1.0);

class DailyStat {
  const DailyStat({
    required this.date,
    required this.done,
    required this.planned,
    required this.focusMinutes,
  });

  final DateTime date;
  final int done;
  final int planned;
  final int focusMinutes;

  double get rate => _rate(done, planned);
  int get ratePercent => (rate * 100).round();
}

class CategoryStat {
  const CategoryStat({
    required this.categoryName,
    required this.done,
    required this.planned,
    required this.share,
  });

  final String categoryName;
  final int done;
  final int planned;

  /// Share of all completed objectives in range (0..1).
  final double share;

  double get rate => _rate(done, planned);
}

class HabitStat {
  const HabitStat({
    required this.habit,
    required this.done,
    required this.scheduled,
  });

  final Habit habit;
  final int done;
  final int scheduled;

  double get rate => _rate(done, scheduled);
  int get ratePercent => (rate * 100).round();
}

class WeekdayStat {
  const WeekdayStat({
    required this.day,
    required this.done,
    required this.planned,
  });

  final Day day;
  final int done;
  final int planned;

  double get rate => _rate(done, planned);
  int get ratePercent => (rate * 100).round();
}

class WindowStat {
  const WindowStat({
    required this.window,
    required this.done,
    required this.planned,
  });

  final DayWindow window;
  final int done;
  final int planned;

  double get rate => _rate(done, planned);
  int get ratePercent => (rate * 100).round();
}

class AnalyticsMetrics {
  const AnalyticsMetrics({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.daily,
    required this.objectivesDone,
    required this.objectivesPlanned,
    required this.focusMinutes,
    required this.categories,
    required this.habits,
    required this.weekdays,
    required this.windows,
  });

  final AnalyticsRange range;
  final DateTime startDate;
  final DateTime endDate;

  /// One entry per day in range, oldest first.
  final List<DailyStat> daily;

  final int objectivesDone;
  final int objectivesPlanned;
  final int focusMinutes;

  /// Sorted by completed count, descending. Only categories with activity.
  final List<CategoryStat> categories;

  /// Sorted by rate, ascending (weakest habit first).
  final List<HabitStat> habits;

  /// Monday..Sunday.
  final List<WeekdayStat> weekdays;

  /// Morning..Night.
  final List<WindowStat> windows;

  double get completionRate => _rate(objectivesDone, objectivesPlanned);
  int get completionPercent => (completionRate * 100).round();

  bool get hasData => objectivesPlanned > 0;
}

DateTime _dateOnly(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);

class _Counter {
  int done = 0;
  int planned = 0;
}

AnalyticsMetrics computeAnalytics({
  required AnalyticsRange range,
  required DateTime today,
  required List<ScheduledTask> scheduledTasks,
  required List<HabitOccurrence> habitOccurrences,
  required List<Habit> habits,
}) {
  final endDate = _dateOnly(today);
  final startDate = endDate.subtract(Duration(days: range.days - 1));

  // Index source data by day.
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

  // Range aggregation.
  final daily = <DailyStat>[];
  var objectivesDone = 0;
  var objectivesPlanned = 0;
  var focusMinutes = 0;

  final categoryCounters = <String, _Counter>{};
  final habitCounters = <int, _Counter>{
    for (final habit in habits) habit.id: _Counter(),
  };
  final weekdayCounters = <Day, _Counter>{
    for (final d in Day.values) d: _Counter(),
  };
  final windowCounters = <DayWindow, _Counter>{
    for (final w in DayWindow.values) w: _Counter(),
  };

  for (var i = 0; i < range.days; i++) {
    final date = startDate.add(Duration(days: i));
    final weekday = Day.fromDateTime(date);
    final dayTasks = tasksByDay[date] ?? const [];
    final dayCompletions = habitCompletionsByDay[date] ?? const [];

    var dayDone = 0;
    var dayPlanned = 0;
    var dayFocus = 0;

    for (final task in dayTasks) {
      dayPlanned++;
      final category = categoryCounters.putIfAbsent(
        task.categoryName,
        () => _Counter(),
      );
      category.planned++;
      final window = windowCounters[DayWindow.fromDateTime(task.startTime)]!;
      window.planned++;

      if (task.completed) {
        dayDone++;
        dayFocus += task.durationInMinutes;
        category.done++;
        window.done++;
      }
    }

    final completedHabitIds = dayCompletions.map((c) => c.habitId).toSet();
    final expectedIds = <int>{};

    for (final habit in habits) {
      if (!isHabitExpectedOn(habit, date)) continue;
      expectedIds.add(habit.id);
      dayPlanned++;
      habitCounters[habit.id]!.planned++;
      final category = categoryCounters.putIfAbsent(
        habit.categoryName,
        () => _Counter(),
      );
      category.planned++;

      if (completedHabitIds.contains(habit.id)) {
        dayDone++;
        habitCounters[habit.id]!.done++;
        category.done++;
      }
    }

    // Completions for habits not expected that day (or since archived)
    // still count as done work; count them as planned too so rate <= 100%.
    for (final completion in dayCompletions) {
      if (expectedIds.contains(completion.habitId)) continue;
      dayDone++;
      dayPlanned++;
      final category = categoryCounters.putIfAbsent(
        completion.categoryName,
        () => _Counter(),
      );
      category.planned++;
      category.done++;
      final habit = habitCounters[completion.habitId];
      if (habit != null) {
        habit.planned++;
        habit.done++;
      }
    }

    final weekdayCounter = weekdayCounters[weekday]!;
    weekdayCounter.done += dayDone;
    weekdayCounter.planned += dayPlanned;

    objectivesDone += dayDone;
    objectivesPlanned += dayPlanned;
    focusMinutes += dayFocus;

    daily.add(
      DailyStat(
        date: date,
        done: dayDone,
        planned: dayPlanned,
        focusMinutes: dayFocus,
      ),
    );
  }

  final categories =
      categoryCounters.entries
          .map(
            (entry) => CategoryStat(
              categoryName: entry.key,
              done: entry.value.done,
              planned: entry.value.planned,
              share: objectivesDone == 0
                  ? 0
                  : entry.value.done / objectivesDone,
            ),
          )
          .toList()
        ..sort((a, b) {
          final byDone = b.done.compareTo(a.done);
          return byDone != 0 ? byDone : b.planned.compareTo(a.planned);
        });

  final habitStats =
      habits
          .map(
            (habit) => HabitStat(
              habit: habit,
              done: habitCounters[habit.id]!.done,
              scheduled: habitCounters[habit.id]!.planned,
            ),
          )
          .where((habit) => habit.scheduled > 0)
          .toList()
        ..sort((a, b) => a.rate.compareTo(b.rate));

  final weekdays = Day.values
      .map(
        (day) => WeekdayStat(
          day: day,
          done: weekdayCounters[day]!.done,
          planned: weekdayCounters[day]!.planned,
        ),
      )
      .toList();

  final windows = DayWindow.values
      .map(
        (window) => WindowStat(
          window: window,
          done: windowCounters[window]!.done,
          planned: windowCounters[window]!.planned,
        ),
      )
      .toList();

  return AnalyticsMetrics(
    range: range,
    startDate: startDate,
    endDate: endDate,
    daily: daily,
    objectivesDone: objectivesDone,
    objectivesPlanned: objectivesPlanned,
    focusMinutes: focusMinutes,
    categories: categories,
    habits: habitStats,
    weekdays: weekdays,
    windows: windows,
  );
}
