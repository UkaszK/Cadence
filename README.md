# Cadence

Cadence is a mobile Flutter app for daily planning and routine tracking. Work lives in a **Library** of **Tasks** and **Habits**; each day you build a **Plan** on a timeline, check things off on the **Dashboard**, and review trends in **Analytics**.

The complete technical project overview is available in [SUMMARY.md](docs/SUMMARY.md). The migration from the earlier QuestLog concept is documented in [MIGRATION.md](docs/MIGRATION.md).

## AI Usage

In a few selected cases, AI-assisted tools supported the development and documentation of Cadence. All AI-generated contributions were reviewed and adapted by the project author.

## Features

- **Dashboard:** Daily view with date selection, daily progress, the day's Plan (scheduled tasks and placed habits in timeline order), and a Habits checklist of everything expected that day. Tasks with a due date are archived automatically once completed, with an Undo action.
- **Planner:** Time-based daily planning with editable time slots, overlap detection, and a sheet to drop a task or an expected habit into a slot.
- **Library:** Tasks and Habits in separate tabs, grouped by category. Tasks can be filtered (all, high priority, due today, one-off); archived items can be shown and restored. "Plan today" sends a task straight to the Planner.
- **Forms:** Create tasks with title, category, duration, optional due date, priority, and subtasks. Create habits with title, category, duration, and a schedule — either on chosen weekdays or every N days from a start date.
- **Analytics:** Progress metrics, daily completions, weekday comparisons, category breakdowns, habit consistency, and schedule distribution.
- **Offline-first:** The app stores its data locally and does not require a network connection for its core features.

## Technology

- [Flutter](https://flutter.dev) with Dart SDK `^3.11.4`
- [Riverpod](https://riverpod.dev/) for reactive state management
- [Isar](https://isar.dev/) as the local NoSQL database
- [`fl_chart`](https://pub.dev/packages/fl_chart) for analytics charts
- [`google_fonts`](https://pub.dev/packages/google_fonts) for UI typography

## Prerequisites

- Flutter SDK with Dart SDK `^3.11.4`
- A configured Android or iOS toolchain
- For iOS: macOS, Xcode, and CocoaPods
- For Android: Android Studio or the Android SDK

Check the installed Flutter version with:

```bash
flutter --version
```

## Installation and Usage

```bash
git clone <repository-url>
cd QuestLog
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Available target devices can be checked with `flutter devices`. The standard Flutter commands can be used to create release builds:

```bash
flutter build apk       # Android
flutter build ios       # iOS on macOS with Xcode
```

### App Icon and TestFlight Builds

Launcher icons are generated from [`assets/icons/app_icon.png`](assets/icons/app_icon.png) using the configuration in [`pubspec.yaml`](pubspec.yaml):

```bash
dart run flutter_launcher_icons
flutter build ipa --release
```

The `remove_alpha_ios: true` setting removes the alpha channel from generated iOS icons, as required by Apple. After changing or regenerating icons, build a new IPA; existing archives and IPAs still contain the old icons. Upload the newly generated IPA from `build/ios/ipa/`. Increase the build number in `pubspec.yaml` for subsequent uploads.

## Code Generation

The Isar models use annotated classes to generate files such as `task.g.dart`, `habit.g.dart`, `scheduled_task.g.dart`, and `habit_occurrence.g.dart`. Run code generation again after changing an annotated data model:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated `*.g.dart` files are not committed and should not be edited manually.

## Architecture

The entry point is [`lib/main.dart`](lib/main.dart). On startup, the local Isar database is opened and the app is then started inside a Riverpod `ProviderScope`.

```text
lib/
├── data/       Isar models, enums, and metrics
├── providers/  Riverpod providers and controllers
├── screens/    Dashboard, Planner, Analytics, Library, and forms
├── theme/      Cadence colors and theme constants
├── utils/      Date, time, and habit-schedule helpers
└── widgets/    Reusable UI components
```

The main layers are:

- `lib/data/` defines tasks, habits, the daily schedule (`ScheduledTask`, `HabitOccurrence`), and analytics metrics.
- `lib/data/isar_data_store.dart` encapsulates database initialization, reading, writing, updating, archiving, and deletion.
- `lib/providers/` connects Isar watchers to the screens and computes feature-specific state.
- `lib/screens/` contains the visible app areas.
- `lib/widgets/` contains forms, charts, task/habit blocks, and shared layout components.

## Data and Privacy

Cadence uses a local Isar database in the app documents directory. The current project does not include cloud synchronization or a server API. The data therefore does not leave the device through a network interface implemented by Cadence.

Use the following commands for a quick local check:

```bash
flutter analyze
flutter test
```

`flutter test` may complete successfully without any tests, but it will not provide meaningful test coverage.

## Project Context

Cadence was created as part of a Media Informatics project at HTW Berlin.
