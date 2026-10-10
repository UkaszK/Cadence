import 'package:cadence/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cadence/data/analytics_metrics.dart';
import 'package:cadence/providers/analytics_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_overview_tiles.dart';
import 'package:cadence/widgets/analytics_screen/category_breakdown.dart';
import 'package:cadence/widgets/analytics_screen/daily_completion_chart.dart';
import 'package:cadence/widgets/analytics_screen/habit_consistency.dart';
import 'package:cadence/widgets/analytics_screen/schedule_distribution.dart';
import 'package:cadence/widgets/analytics_screen/weekday_performance_chart.dart';
import 'package:cadence/widgets/cadence_loading_screen.dart';
import 'package:cadence/widgets/reusables/cadence_choice_chip_bar.dart';
import 'package:cadence/widgets/reusables/cadence_screen_container.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsStateProvider);

    return analyticsAsync.when(
      data: (metrics) => CadenceScreenContainer(
        spacing: 25,
        children: [
          FadeInTransition(
            delay: Duration.zero,
            child: _Header(
              range: metrics.range,
              startDate: metrics.startDate,
              endDate: metrics.endDate,
              onRangeChange: ref.read(analyticsRangeProvider.notifier).select,
            ),
          ),
          FadeInTransition(
            delay: const Duration(milliseconds: 100),
            child: AnalyticsOverviewTiles(metrics: metrics),
          ),
          FadeInTransition(
            delay: const Duration(milliseconds: 150),
            child: DailyCompletionChart(metrics: metrics),
          ),
          FadeInTransition(
            delay: const Duration(milliseconds: 200),
            child: WeekdayPerformanceChart(metrics: metrics),
          ),
          FadeInTransition(
            delay: const Duration(milliseconds: 250),
            child: CategoryBreakdown(metrics: metrics),
          ),
          FadeInTransition(
            delay: const Duration(milliseconds: 300),
            child: HabitConsistency(metrics: metrics),
          ),
          FadeInTransition(
            delay: const Duration(milliseconds: 350),
            child: ScheduleDistribution(metrics: metrics),
          ),
        ],
      ),
      error: (error, stack) => Center(child: Text('Error loading: $error')),
      loading: () => const CadenceLoadingScreen(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.onRangeChange,
  });

  final AnalyticsRange range;
  final DateTime startDate;
  final DateTime endDate;
  final void Function(AnalyticsRange) onRangeChange;

  static final _rangeFormat = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ANALYTICS',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_rangeFormat.format(startDate)}'
                ' - ${_rangeFormat.format(endDate)}',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 160,
          child: CadenceChoiceChipBar<AnalyticsRange>(
            options: AnalyticsRange.values,
            selection: range,
            onChange: onRangeChange,
            labelOf: (r) => r.label,
            style: CadenceChoiceChipBarStyle.outlined,
          ),
        ),
      ],
    );
  }
}
