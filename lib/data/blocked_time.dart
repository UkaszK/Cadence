import 'package:isar/isar.dart';
import 'package:cadence/utils/get_time_text.dart';

part 'blocked_time.g.dart';

/// Time reserved in the Planner for something that isn't tracked as work,
/// like eating or commuting. Not part of the Library, has no sub tasks or
/// category and is never completed.
@collection
class BlockedTime implements Comparable<BlockedTime> {
  BlockedTime({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  BlockedTime copyWith({String? name, DateTime? startTime, DateTime? endTime}) {
    return BlockedTime(
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    )..id = id;
  }

  Id id = Isar.autoIncrement;

  final String name;
  final DateTime startTime;
  final DateTime endTime;

  @ignore
  int get durationInMinutes => endTime.difference(startTime).inMinutes;

  @ignore
  String get timeText => getTimeText(startTime, endTime);

  @ignore
  String get timeTextOneLine => getTimeText(startTime, endTime, false);

  @override
  int compareTo(BlockedTime other) => startTime.compareTo(other.startTime);
}
