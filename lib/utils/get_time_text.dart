import 'package:cadence/utils/DateTime/date_time_extension.dart';

String getTimeText(
  DateTime start,
  DateTime end, [
  bool automaticLineBreak = true,
]) {
  return '${start.toHHMM()} -${automaticLineBreak ? '\n' : ' '}${end.toHHMM()}';
}
