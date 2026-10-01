import 'package:flutter/material.dart';
import 'package:cadence/theme/cadence_colors.dart';

enum TaskStatus {
  open(label: 'Upcoming', color: CadenceColors.textSecondary),
  completed(label: 'Done', color: CadenceColors.success),
  active(label: 'Active', color: CadenceColors.accent),
  pending(label: 'Overdue', color: CadenceColors.warning);

  const TaskStatus({required this.label, required this.color});

  final String label;
  final Color color;
}

TaskStatus computeTaskStatus({
  required DateTime startTime,
  required DateTime endTime,
  required bool completed,
}) {
  if (completed) return TaskStatus.completed;

  final now = DateTime.now();
  if (startTime.isBefore(now) && endTime.isAfter(now)) {
    return TaskStatus.active;
  }
  if (endTime.isBefore(now)) return TaskStatus.pending;
  return TaskStatus.open;
}
