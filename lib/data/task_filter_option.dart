import 'package:flutter/painting.dart';
import 'package:cadence/theme/cadence_colors.dart';

enum TaskFilterOption {
  all(label: 'All', color: CadenceColors.accent),
  highPriority(label: 'High Priority', color: CadenceColors.warning),
  dueToday(label: 'Due Today', color: CadenceColors.accent),
  oneOff(label: 'One-off', color: CadenceColors.info);

  const TaskFilterOption({required this.label, required this.color});

  final String label;
  final Color color;
}
