import 'package:isar/isar.dart';

part 'achievement_unlock.g.dart';

/// Marker sentinel written on first sync so that already-earned badges do not
/// fire unlock notifications retroactively.
const String achievementBackfillKey = '__backfilled__';

/// Records that an achievement tier has already been announced to the user.
/// Progress itself is always derived from task and habit history, never stored here.
@collection
class AchievementUnlock {
  AchievementUnlock({required this.key, required this.unlockedAt});

  Id id = Isar.autoIncrement;

  /// Either [achievementBackfillKey] or `achievementId:tier`.
  final String key;

  final DateTime unlockedAt;
}
