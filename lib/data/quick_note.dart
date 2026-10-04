import 'package:isar/isar.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';

part 'quick_note.g.dart';

/// A lightweight checklist entry shown on the dashboard for a single day —
/// a personal scratchpad that is not tied to any task or habit.
@collection
class QuickNote {
  QuickNote({
    required this.text,
    required DateTime date,
    this.completed = false,
    required this.createdAt,
  }) : date = date.dateOnly;

  Id id = Isar.autoIncrement;

  final String text;

  /// The day (midnight-normalized) this note belongs to.
  @Index()
  final DateTime date;

  final bool completed;

  final DateTime createdAt;

  QuickNote copyWith({String? text, bool? completed}) {
    return QuickNote(
        text: text ?? this.text,
        date: date,
        completed: completed ?? this.completed,
        createdAt: createdAt,
      )
      ..id = id;
  }
}
