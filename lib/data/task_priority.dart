import 'package:flutter/material.dart';
import 'package:cadence/theme/cadence_colors.dart';

enum TaskPriority {
  low(label: 'Low', color: CadenceColors.success, icon: Icons.low_priority),
  normal(label: 'Normal', color: CadenceColors.info, icon: Icons.check),
  high(label: 'High', color: CadenceColors.warning, icon: Icons.priority_high);

  const TaskPriority({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
