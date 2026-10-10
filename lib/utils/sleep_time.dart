import 'package:cadence/utils/get_duration_hours_and_minutes.dart';

const int minutesPerDay = 24 * 60;

/// Part of a single day covered by planned sleep, in minutes after midnight.
typedef SleepRange = ({int start, int end});

/// Splits planned sleep into the ranges it covers on one day. Sleep that
/// crosses midnight yields a morning range (until wake-up) and an evening
/// range (from bedtime).
List<SleepRange> sleepRangesForDay(int bedtimeMinutes, int wakeUpMinutes) {
  if (bedtimeMinutes == wakeUpMinutes) return const [];
  if (bedtimeMinutes < wakeUpMinutes) {
    return [(start: bedtimeMinutes, end: wakeUpMinutes)];
  }
  return [
    if (wakeUpMinutes > 0) (start: 0, end: wakeUpMinutes),
    (start: bedtimeMinutes, end: minutesPerDay),
  ];
}

int sleepDurationMinutes(int bedtimeMinutes, int wakeUpMinutes) =>
    (wakeUpMinutes - bedtimeMinutes) % minutesPerDay;

/// Formats minutes after midnight as HH:MM.
String formatMinutesOfDay(int minutes) {
  final (h, m) = getDurationHoursAndMinutes(minutes % minutesPerDay);
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}
