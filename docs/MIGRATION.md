# Migration: QuestLog → Cadence

Branch: `66-away-from-questlog`

Historical note: the streak and achievement features described below were
removed from the app after this migration.

## Motivation

The "Quest" metaphor (Main Quest / Side Quest / Assembler / Backlog) is not intuitive. The app is reframed around two plain concepts:

- **Tasks** – things you do, possibly many times, that you schedule into a day ("work", "project meeting", "file taxes").
- **Habits** – things you repeat on a fixed rule and want to keep a streak on ("creatine every day", "clean room every Sunday", "stretch Mon/Wed/Fri", "water plants every 3 days").

Gamification (streaks, achievements) stays as is; only wording changes.

## Decisions

| Topic | Decision |
| --- | --- |
| App name | **Cadence** (package `cadence`) |
| Existing data | No migration code – DB is wiped by the new schema names |
| Habit schedule rules | Weekday set **or** "Every N days" with N ≥ 2 |
| Habits on the planner | Optional; a habit can be placed into a time slot |
| Habit duration | Required (needed for planner placement, same as tasks) |
| One-off tasks | Auto-archived after completion, user is informed via snackbar with Undo |
| Gamification | Kept, copy reworded |

## Vocabulary mapping

| Old | New |
| --- | --- |
| QuestLog | Cadence |
| Main Quest | Task |
| Side Quest | Habit |
| Assembler | Planner |
| Backlog | Library |
| Quest Category / Priority / Status | Category / Priority / Status |
| Quest Type | *(removed)* |

## Target domain model

```
Category          (ex QuestCategory)   – unchanged
Priority          (ex QuestPriority)   – unchanged
Day                                    – unchanged

Task              (ex MainQuest)  @collection
  name, categoryName, priority, duration, dueDate?, subTasks[], archived
  → oneOff = dueDate != null            (derived, not stored)

ScheduledTask     (ex AssemblerMainQuest)  @collection
  taskId, name, categoryName, subTasks[], startTime, endTime, completed, completedAt?
  – unchanged apart from names

Habit             (ex SideQuest)  @collection
  name, categoryName, duration, archived
  scheduleType    : enum { weekdays, interval }
  repeatDays[]    : List<Day>           (weekdays mode)
  intervalDays    : int?                (interval mode, N ≥ 2)
  anchorDate      : DateTime?           (interval mode: first expected day)

HabitOccurrence   (ex AssemblerSideQuest)  @collection
  habitId, name, categoryName, occurrenceDate, completedAt?
  startTime?, endTime?                  (NEW – set only when placed on the planner)

AchievementUnlock – unchanged
```

Removed: `QuestType`. `QuestFilterOption` is reduced to priority / due filters.

### Habit scheduling rules

- **Weekdays**: expected on day `D` iff `Day.fromDateTime(D) ∈ repeatDays`. "Every day" is expressed as all seven weekdays.
- **Interval**: expected on day `D` iff `D ≥ anchorDate && (D − anchorDate).inDays % intervalDays == 0`. `intervalDays ≥ 2` is enforced in the form (picker starts at 2; validation message: *"Use the weekday schedule for daily habits"*). Changing N or the start date resets `anchorDate` to the chosen date (default: today).
- The two modes are mutually exclusive, chosen via a segmented control in the habit form.

### Occurrence lifecycle

- Expected-but-not-done occurrences are **derived** from the rule; no record exists yet.
- A `HabitOccurrence` record is created when the user either **checks it off** or **places it on the planner** (so it can hold `startTime`/`endTime`).
- Removing a habit block from the planner clears `startTime`/`endTime` but keeps completion state.
- Streak / consistency logic stays "expected days vs. completed records", now evaluated with both rules via a shared `isHabitExpectedOn(habit, date)` helper.

## Screen-by-screen behaviour

### Dashboard

- Header: date picker, daily progress (counts scheduled tasks and expected habits).
- **Plan** section: timeline blocks for `ScheduledTask` and placed `HabitOccurrence`, visually distinguished (habit accent colour, repeat icon).
- **Habits** section: checklist of all habits expected today, including those already placed on the timeline. Checking off works from either place (same record).

### Planner (ex Assembler)

- Same slot mechanics.
- "Add to slot" sheet with two tabs: **Task** (pick from library or create new) / **Habit** (only habits expected on that day and not yet placed). Habit block is pre-filled with `Habit.duration`, adjustable per occurrence.
- Overlap detection includes habit blocks.

### Library (ex Backlog)

- Segmented control **Tasks | Habits**.
- Tasks tab: grouped by category; filters Priority / Due; toggle "Show archived". One-off tasks show a due badge.
- Habits tab: grouped by category; subtitle shows rule text ("Every day", "Mon, Wed, Fri", "Every 3 days").
- FAB opens the form matching the active tab.

### Task form (ex Quest form)

- Name, category, priority, duration, due date (optional), subtasks.
- Helper text under due date: *"Tasks with a due date are archived automatically once completed."*

### Habit form (new, split from the quest form)

- Name, category, duration, schedule: **On weekdays** (day picker) | **Every N days** (N ≥ 2, start date).

### Auto-archive of one-off tasks

- On completing the `ScheduledTask` of a task with `dueDate`: archive the task and show a snackbar *"'<name>' completed and moved to archive"* with **Undo** (unarchives).
- Archived tasks remain reachable via "Show archived" in the Library.

### Analytics / Achievements

- Logic unchanged. Copy only: "Quests completed" → "Tasks completed", "Side Quest streak" → "Habit streak", "Habit consistency" stays. Achievement names/descriptions in `achievement_catalog.dart` reworded away from RPG terms.

### Settings

- Unchanged.

## Ordered change list

1. **Identity rename**: `pubspec.yaml` name → `cadence`; all `package:questlog/` imports; Android `applicationId` + label; iOS bundle id + display name; `QuestLogColors` → `CadenceColors`; README / SUMMARY.
2. **Data layer**: rename/reshape collections as above; delete `QuestType`; regenerate `*.g.dart`; update `IsarDataStore` (schemas, queries, habit-occurrence upsert for planner placement).
3. **Habit scheduling utility**: `isHabitExpectedOn(habit, date)` covering both rules; replace all `repeatDays.contains(...)` call sites (dashboard, analytics, gamification).
4. **Providers**: rename files/notifiers; split `quest_form_providers` into task-form and habit-form state; planner provider gains habit placement.
5. **Screens / widgets**: rename folders; Library segmented control; Planner add-sheet tabs; habit form; auto-archive snackbar; timeline rendering of habit blocks.
6. **Copy sweep**: search UI strings and the achievement catalog for `Quest`, `Assembler`, `Backlog`, `Side`, `Main`.
7. **Docs**: update `docs/SUMMARY.md` and `README.md` to the new vocabulary.
