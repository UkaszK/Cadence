import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/reusables/cadence_badge.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    super.key,
    required this.label,
    required this.count,
    this.singular = 'TASK',
    this.plural = 'TASKS',
  });

  final String label;
  final int count;
  final String singular;
  final String plural;

  @override
  Widget build(BuildContext context) {
    return CadenceSectionHeader(
      title: label.toUpperCase(),
      rightSide: CadenceBadge(
        label: '$count ${Intl.plural(count, one: singular, other: plural)}',
        primaryColor: CadenceColors.textSecondary,
        backgroundColor: CadenceColors.surface,
        borderColor: CadenceColors.border,
      ),
      dividerStyle: (dividerDistance: 4),
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
