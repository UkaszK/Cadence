import 'package:flutter/material.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_duration_hours_and_minutes.dart';

/// Identifies a single achievement track. Persisted by [name], so renaming a
/// value resets the unlock history for that achievement.
enum AchievementId {
  earlyBird,
  nightOwl,
  focusMaster,
  streakKeeper,
  perfectDay,
  deepWork,
  habitHero,
  taskFinisher,
  weekendWarrior,
}

enum AchievementTier {
  bronze(label: 'BRONZE', color: CadenceColors.bronze),
  silver(label: 'SILVER', color: CadenceColors.silver),
  gold(label: 'GOLD', color: CadenceColors.gold);

  const AchievementTier({required this.label, required this.color});

  final String label;
  final Color color;
}

/// How an achievement's raw metric value is rendered.
enum AchievementUnit {
  /// Plain count of objectives, e.g. "42".
  objectives,

  /// Count of days, e.g. "12 DAYS".
  days,

  /// Minutes rendered as hours, e.g. "50h".
  minutes;

  String format(int value) {
    return switch (this) {
      AchievementUnit.objectives => '$value',
      AchievementUnit.days => value == 1 ? '1 DAY' : '$value DAYS',
      AchievementUnit.minutes => _formatMinutes(value),
    };
  }

  static String _formatMinutes(int value) {
    final (hours, minutes) = getDurationHoursAndMinutes(value);
    if (hours == 0) return '${minutes}m';
    return '${hours}h';
  }
}

@immutable
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unit,
    required this.bronze,
    required this.silver,
    required this.gold,
  });

  final AchievementId id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementUnit unit;
  final int bronze;
  final int silver;
  final int gold;

  int thresholdOf(AchievementTier tier) {
    return switch (tier) {
      AchievementTier.bronze => bronze,
      AchievementTier.silver => silver,
      AchievementTier.gold => gold,
    };
  }
}

@immutable
class AchievementProgress {
  const AchievementProgress({required this.definition, required this.value});

  final AchievementDefinition definition;

  /// Raw metric value over the full history.
  final int value;

  /// Highest tier reached, or null while still locked.
  AchievementTier? get tier {
    AchievementTier? earned;
    for (final candidate in AchievementTier.values) {
      if (value >= definition.thresholdOf(candidate)) earned = candidate;
    }
    return earned;
  }

  AchievementTier? get nextTier {
    for (final candidate in AchievementTier.values) {
      if (value < definition.thresholdOf(candidate)) return candidate;
    }
    return null;
  }

  bool get isUnlocked => tier != null;
  bool get isMaxed => nextTier == null;

  /// All tiers earned so far, in ascending order.
  List<AchievementTier> get earnedTiers => AchievementTier.values
      .where((tier) => value >= definition.thresholdOf(tier))
      .toList();

  /// Progress from the current tier's threshold toward the next one (0..1).
  double get progress {
    final next = nextTier;
    if (next == null) return 1;

    final floor = tier == null ? 0 : definition.thresholdOf(tier!);
    final ceiling = definition.thresholdOf(next);
    if (ceiling <= floor) return 1;

    return ((value - floor) / (ceiling - floor)).clamp(0.0, 1.0);
  }

  Color get color => tier?.color ?? CadenceColors.textSecondary;

  String get valueLabel => definition.unit.format(value);

  /// e.g. "42 / 50" for the next tier, or "MAXED" once gold is reached.
  String get goalLabel {
    final next = nextTier;
    if (next == null) return 'MAXED';
    return '$value / ${definition.thresholdOf(next)}';
  }
}
