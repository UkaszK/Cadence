import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/data/task_categories.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key, required this.metrics});

  final AnalyticsMetrics metrics;

  IconData _iconFor(String categoryName) {
    return taskCategories
            .firstWhereOrNull((c) => c.name == categoryName)
            ?.icon ??
        Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final categories = metrics.categories;

    return AnalyticsSection(
      title: 'CATEGORY BREAKDOWN',
      icon: Icons.pie_chart_outline,
      isEmpty: categories.isEmpty,
      rightSide: Text('SHARE OF COMPLETED', style: analyticsCaptionStyle()),
      child: Column(
        spacing: 14,
        children: [
          for (final category in categories)
            AnalyticsBarRow(
              leading: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: CadenceColors.border),
                  color: CadenceColors.accentLessOpacity,
                ),
                child: Icon(
                  _iconFor(category.categoryName),
                  size: 14,
                  color: CadenceColors.accent,
                ),
              ),
              label: category.categoryName.toUpperCase(),
              value: category.share,
              trailing: '${(category.share * 100).round()}%',
              subLabel: '${category.done} / ${category.planned} COMPLETED',
            ),
        ],
      ),
    );
  }
}
