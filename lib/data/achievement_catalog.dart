import 'package:flutter/material.dart';
import 'package:cadence/data/achievement.dart';

/// Hour before which a completion counts as "early".
const int earlyBirdHour = 9;

/// Hour from which a completion counts as "late".
const int nightOwlHour = 22;

/// Items needed in a single day for it to count toward Focus Master.
const int focusMasterDailyTarget = 10;

/// All achievement tracks, in display order.
const List<AchievementDefinition> achievementCatalog = [
  AchievementDefinition(
    id: AchievementId.streakKeeper,
    title: 'STREAK KEEPER',
    description:
        'Longest run of consecutive days with at least one item completed.',
    icon: Icons.local_fire_department,
    unit: AchievementUnit.days,
    bronze: 7,
    silver: 30,
    gold: 100,
  ),
  AchievementDefinition(
    id: AchievementId.earlyBird,
    title: 'EARLY BIRD',
    description: 'Tasks and habits completed before 09:00.',
    icon: Icons.wb_twilight,
    unit: AchievementUnit.objectives,
    bronze: 10,
    silver: 50,
    gold: 150,
  ),
  AchievementDefinition(
    id: AchievementId.nightOwl,
    title: 'NIGHT OWL',
    description: 'Tasks and habits completed after 22:00.',
    icon: Icons.nightlight_round,
    unit: AchievementUnit.objectives,
    bronze: 10,
    silver: 50,
    gold: 150,
  ),
  AchievementDefinition(
    id: AchievementId.focusMaster,
    title: 'FOCUS MASTER',
    description: 'Days with $focusMasterDailyTarget or more items completed.',
    icon: Icons.bolt,
    unit: AchievementUnit.days,
    bronze: 1,
    silver: 5,
    gold: 20,
  ),
  AchievementDefinition(
    id: AchievementId.perfectDay,
    title: 'PERFECT DAY',
    description: 'Days where everything planned was completed.',
    icon: Icons.verified,
    unit: AchievementUnit.days,
    bronze: 1,
    silver: 10,
    gold: 50,
  ),
  AchievementDefinition(
    id: AchievementId.deepWork,
    title: 'DEEP WORK',
    description: 'Total focus time from completed tasks.',
    icon: Icons.timer,
    unit: AchievementUnit.minutes,
    bronze: 600,
    silver: 3000,
    gold: 12000,
  ),
  AchievementDefinition(
    id: AchievementId.taskFinisher,
    title: 'TASK FINISHER',
    description: 'Tasks completed.',
    icon: Icons.local_police,
    unit: AchievementUnit.objectives,
    bronze: 25,
    silver: 100,
    gold: 500,
  ),
  AchievementDefinition(
    id: AchievementId.habitHero,
    title: 'HABIT HERO',
    description: 'Habits completed.',
    icon: Icons.repeat,
    unit: AchievementUnit.objectives,
    bronze: 50,
    silver: 250,
    gold: 1000,
  ),
  AchievementDefinition(
    id: AchievementId.weekendWarrior,
    title: 'WEEKEND WARRIOR',
    description: 'Tasks and habits completed on Saturdays and Sundays.',
    icon: Icons.weekend,
    unit: AchievementUnit.objectives,
    bronze: 20,
    silver: 100,
    gold: 300,
  ),
];

/// Total number of badges across all tracks and tiers.
final int achievementBadgeCount =
    achievementCatalog.length * AchievementTier.values.length;
