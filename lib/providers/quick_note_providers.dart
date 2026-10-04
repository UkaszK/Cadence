import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/data/isar_data_store.dart';
import 'package:cadence/data/quick_note.dart';

/// Every quick note across all days, oldest first.
final quickNotesProvider = StreamProvider<List<QuickNote>>((ref) {
  return IsarDataStore.watchQuickNotes();
});

/// Quick notes belonging to a single day, oldest first.
final quickNotesForDayProvider =
    Provider.family<AsyncValue<List<QuickNote>>, DateTime>((ref, date) {
      final asyncNotes = ref.watch(quickNotesProvider);

      return asyncNotes.whenData(
        (notes) =>
            notes.where((n) => DateUtils.isSameDay(n.date, date)).toList(),
      );
    });

class QuickNoteService {
  static void add(String text, DateTime date) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    IsarDataStore.addQuickNote(
      QuickNote(text: trimmed, date: date, createdAt: DateTime.now()),
    );
  }

  static void setCompleted(QuickNote note, bool completed) =>
      IsarDataStore.updateQuickNote(note.copyWith(completed: completed));

  static void delete(QuickNote note) => IsarDataStore.deleteQuickNote(note.id);

  static void clearCompleted(DateTime date) =>
      IsarDataStore.deleteCompletedQuickNotes(date);
}
