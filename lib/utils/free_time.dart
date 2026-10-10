import 'dart:math';

import 'package:cadence/utils/planner_time_scale.dart';
import 'package:cadence/utils/sleep_time.dart';

/// Minutes of a day not covered by any of [occupied]. Overlapping ranges are
/// only counted once.
int freeMinutesInDay(Iterable<MinuteRange> occupied) {
  final ranges =
      [
          for (final r in occupied)
            (
              start: r.start.clamp(0, minutesPerDay),
              end: r.end.clamp(0, minutesPerDay),
            ),
        ].where((r) => r.end > r.start).toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  var occupiedMinutes = 0;
  int? currentStart;
  var currentEnd = 0;
  for (final r in ranges) {
    if (currentStart == null || r.start > currentEnd) {
      if (currentStart != null) occupiedMinutes += currentEnd - currentStart;
      currentStart = r.start;
      currentEnd = r.end;
    } else {
      currentEnd = max(currentEnd, r.end);
    }
  }
  if (currentStart != null) occupiedMinutes += currentEnd - currentStart;

  return minutesPerDay - occupiedMinutes;
}
