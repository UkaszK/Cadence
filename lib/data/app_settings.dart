import 'package:isar/isar.dart';

part 'app_settings.g.dart';

// Top-level because the generated Isar code references defaults unqualified.
const int defaultBedtimeMinutes = 23 * 60;
const int defaultWakeUpMinutes = 7 * 60;

/// User preferences. Stored as a single record with [singletonId].
@collection
class AppSettings {
  AppSettings({
    this.sleepEnabled = false,
    this.bedtimeMinutes = defaultBedtimeMinutes,
    this.wakeUpMinutes = defaultWakeUpMinutes,
  });

  static const int singletonId = 0;

  Id id = singletonId;

  /// Whether the planned sleep time is shown in the Planner.
  final bool sleepEnabled;

  /// Minutes after midnight at which the user plans to go to bed.
  final int bedtimeMinutes;

  /// Minutes after midnight at which the user plans to wake up.
  final int wakeUpMinutes;

  AppSettings copyWith({
    bool? sleepEnabled,
    int? bedtimeMinutes,
    int? wakeUpMinutes,
  }) {
    return AppSettings(
      sleepEnabled: sleepEnabled ?? this.sleepEnabled,
      bedtimeMinutes: bedtimeMinutes ?? this.bedtimeMinutes,
      wakeUpMinutes: wakeUpMinutes ?? this.wakeUpMinutes,
    );
  }
}
