# Cadence – Projektübersicht

## Zweck

Cadence ist eine mobile Flutter-App für die Planung des Tages und die Auswertung von Routinen. Arbeit wird in einer Bibliothek aus **Tasks** (Aufgaben) und **Habits** (Gewohnheiten) verwaltet. Pro Tag entsteht daraus ein **Plan** auf einer Zeitleiste.

Die App arbeitet lokal auf dem Gerät. Aufgaben, Gewohnheiten, Tagesplanung und Notizen werden in einer lokalen Isar-Datenbank gespeichert.

## Technischer Aufbau

| Bereich | Umsetzung |
| --- | --- |
| UI | Flutter mit Material Widgets |
| Programmiersprache | Dart |
| State Management | Riverpod (`flutter_riverpod`) |
| Persistenz | Isar (`isar`, `isar_flutter_libs`) |
| Statistiken | `fl_chart` |
| Typografie | `google_fonts`, unter anderem JetBrains Mono |
| App-Version | `package_info_plus` |
| Icons und Assets | Material Icons und SVGs in `assets/icons/` |

## Einstiegspunkt und App-Lifecycle

1. `lib/main.dart` stellt sicher, dass Flutter initialisiert ist.
2. `IsarDataStore.init()` öffnet die lokale Datenbank und registriert die Isar-Schemas.
3. `ProviderScope` stellt Riverpod für den Widget-Baum bereit.
4. `App` erzeugt das dunkle Material-Theme und öffnet `MainHomeScreen`.
5. `MainHomeScreen` verwaltet die Hauptnavigation und hält die vier Hauptbereiche in einem `IndexedStack`.

## Benutzeroberfläche

### Primär genutzte Farben

Die zentralen Farbwerte sind in `lib/theme/cadence_colors.dart` definiert:

| Farbe | Hex-Wert | Verwendung |
| --- | --- | --- |
| Cyan | `#6FEEFC` | Primärer Akzent, Hervorhebungen und interaktive Elemente |
| Rosa | `#F3B0E5` | Sekundärer Akzent, etwa für Habits und ergänzende Hervorhebungen |
| Dunkler Hintergrund | `#141218` | Globaler App-Hintergrund |
| Oberfläche | `#1D1C1C` | Karten und weitere UI-Flächen |
| Rand | `#353534` | Trennlinien und Umrandungen |
| Primärtext | `#FFFFFF` | Haupttexte und Icons |
| Sekundärtext | `#B3FFFFFF` | Zurückhaltende Texte und Beschriftungen |

### App-Icon

Das Icon visualisiert „Cadence“ als Rhythmus und die Strukturierung des Tages:

- Die durchgehende Wellenlinie steht für den fortlaufenden Rhythmus von Routinen und die Zeitleiste des Tagesplans.
- Knotenpunkte markieren konkrete Tasks und Habits, die im Planner Zeitfenstern zugeordnet werden.
- Der Farbverlauf verbindet das Akzent-Cyan mit dem Habit-Rosa und symbolisiert, wie einmalige Aufgaben und feste Gewohnheiten auf der täglichen Zeitleiste ineinandergreifen.

### Hauptnavigation

- **Dashboard:** Tagesansicht mit Datumsauswahl, täglichem Fortschritt, dem Plan des Tages (geplante Tasks und platzierte Habits in zeitlicher Reihenfolge) sowie einer Habit-Checkliste aller an diesem Tag erwarteten Gewohnheiten. Tasks mit Fälligkeitsdatum werden nach Abschluss automatisch archiviert (mit Undo).
- **Planner:** Visuelle Tagesplanung über Zeitblöcke. Tasks und erwartete Habits können einem Zeitfenster zugeordnet, verschoben oder entfernt werden. Überschneidungen werden erkannt. Eine optionale geplante Schlafenszeit wird als rein visuelles Band auf der Zeitleiste angezeigt.
- **Analytics:** Auswertungen für einen wählbaren Zeitraum mit Kennzahlen und Diagrammen.
- **Library:** Tasks und Habits in getrennten Tabs, gruppiert nach Kategorien. Tasks sind filterbar (alle, hohe Priorität, heute fällig, einmalig); archivierte Einträge lassen sich einblenden und wiederherstellen.

### Weitere Screens und UI-Bausteine

- **Task-Formular:** Titel, Kategorie, Dauer, optionales Fälligkeitsdatum, Priorität und Unteraufgaben.
- **Habit-Formular:** Titel, Kategorie, Dauer und Zeitplan – entweder an ausgewählten Wochentagen oder alle N Tage ab einem Startdatum.
- **Settings:** Über das Zahnrad-Icon in der oberen App-Bar erreichbar. Geplante Schlafens- und Aufwachzeit sowie deren Anzeige im Planner; unten wird die installierte Cadence-Version angezeigt.
- Wiederverwendbare Komponenten für App-Bar, Navigation, FAB, Buttons, Dropdowns, Choice Chips, Switches, Badges, Ladezustände und Screen-Container.

## Domänenmodell

### Persistente Isar-Collections

- `Task`: Aufgabe mit Kategorie, Priorität, Dauer, optionaler Fälligkeit (einmalig), Unteraufgaben und Archivstatus. Ohne Fälligkeit ist eine Aufgabe wiederverwendbar.
- `Habit`: Gewohnheit mit Kategorie, Dauer, Zeitplan (`weekdays` mit Wochentagen oder `interval` mit N Tagen und Ankerdatum) und Archivstatus.
- `ScheduledTask`: Zeitblock einer Aufgabe im Plan eines Tages, inklusive Unteraufgaben-Fortschritt und Abschluss.
- `HabitOccurrence`: Vorkommen einer Gewohnheit an einem Tag; optional mit Zeitfenster im Plan und Abschlusszeitpunkt.
- `AppSettings`: Einzelner Datensatz mit Benutzereinstellungen, aktuell geplante Schlafens- und Aufwachzeit sowie deren Anzeige im Planner.

### Unterstützende Typen und Metriken

- Kategorien, Prioritäten, Statuswerte, Tage und Filteroptionen.
- `isHabitExpectedOn()` entscheidet, ob eine Gewohnheit an einem Datum erwartet wird.
- Tagesfortschritt und Analytics-Metriken.

Die zugehörigen `*.g.dart`-Dateien werden aus den Isar-Annotationsklassen generiert, sind nicht eingecheckt und sollten nicht manuell bearbeitet werden.

## State Management und Datenfluss

Die Provider liegen in `lib/providers/` und bilden die fachlichen Bereiche ab:

- Streams für Tasks, Habits, geplante Tasks und Habit-Vorkommen (`task_providers`, `habit_providers`, `schedule_providers`).
- Dashboard- und Planner-Zustand einschließlich ausgewähltem Tag, Zeitfenster und ausstehendem/bearbeitetem Element.
- Library-Zustand mit Tab, Filter und Archiv-Schalter.
- Analytics-Zeitraum und berechnete Statistiken.
- Navigation sowie Formularzustand.

Die Isar-Watcher liefern Änderungen reaktiv an Riverpod. Nicht archivierte Tasks und Habits werden standardmäßig über die jeweiligen Streams geladen.

## Analytics

Die Analytics-Ansicht enthält unter anderem:

- Übersichtskennzahlen zum Fortschritt.
- tägliche Abschlusszahlen.
- Leistungsvergleich nach Wochentagen.
- Aufschlüsselung nach Kategorien.
- Konsistenz von Gewohnheiten.
- Verteilung des Zeitplans.

## Verzeichnisstruktur

```text
.
├── assets/icons/          SVG-Icons für die Navigation
├── android/               Android-Plattformprojekt
├── ios/                   iOS-Plattformprojekt
├── docs/                  SUMMARY.md und MIGRATION.md
├── lib/
│   ├── data/              Isar-Modelle, Enums und Metriken
│   ├── providers/         Riverpod-Provider und Controller
│   ├── screens/           Vollständige Screens
│   ├── theme/             Cadence-Farben und Theme-Konstanten
│   ├── utils/             Datums-, Zeit- und Zeitplan-Hilfsfunktionen
│   ├── widgets/           Wiederverwendbare UI-Komponenten
│   ├── app.dart           Material-App und Root-Theme
│   └── main.dart          Initialisierung und App-Start
├── analysis_options.yaml  Dart- und Flutter-Linting
├── pubspec.yaml           Abhängigkeiten und Asset-Konfiguration
└── README.md              Ausführliche Projekt- und Setup-Dokumentation
```

## Entwicklungsstatus

Die Kernfunktionen für Task- und Habit-Verwaltung, Tagesplanung, Library und Analytics sind im Quellcode vorhanden. Die Anwendung ist als lokale, mobile Flutter-App ausgelegt. Im Repository ist aktuell kein `test/`-Verzeichnis vorhanden; automatisierte Unit- oder Widget-Tests sind daher noch nicht dokumentiert.

## Relevante Dateien

- `lib/main.dart` – App-Initialisierung.
- `lib/app.dart` – Material-App und globales Theme.
- `lib/data/isar_data_store.dart` – Öffnen der Datenbank und Persistenzoperationen.
- `lib/screens/main_home_screen.dart` – Hauptnavigation.
- `lib/providers/` – reaktiver Anwendungszustand.
- `pubspec.yaml` – Flutter-Version, Abhängigkeiten und Assets.
