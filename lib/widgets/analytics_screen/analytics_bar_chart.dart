import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/analytics_screen/analytics_shared.dart';

class AnalyticsBar {
  const AnalyticsBar({
    required this.value,
    required this.tooltip,
    this.label = '',
    this.color = CadenceColors.accent,
  });

  /// Bar height in 0..1 (percentage).
  final double value;
  final String tooltip;

  /// Bottom axis label; empty string hides the label for this bar.
  final String label;
  final Color color;
}

/// Percentage bar chart in the Cadence style (0-100 on the Y axis).
class AnalyticsBarChart extends StatelessWidget {
  const AnalyticsBarChart({
    super.key,
    required this.bars,
    this.height = 160,
    this.barWidth,
  });

  final List<AnalyticsBar> bars;
  final double height;
  final double? barWidth;

  double _resolveBarWidth() {
    if (barWidth != null) return barWidth!;
    if (bars.length <= 7) return 18;
    if (bars.length <= 14) return 12;
    if (bars.length <= 31) return 6;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final width = _resolveBarWidth();

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 100,
          alignment: BarChartAlignment.spaceBetween,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: CadenceColors.border,
              strokeWidth: 1,
              dashArray: [3, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  if (value % 50 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      '${value.toInt()}%',
                      style: analyticsCaptionStyle(),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= bars.length) {
                    return const SizedBox.shrink();
                  }
                  final label = bars[index].label;
                  if (label.isEmpty) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(label, style: analyticsCaptionStyle()),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => CadenceColors.surfaceOnSurface,
              tooltipBorderRadius: BorderRadius.zero,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  bars[group.x].tooltip,
                  GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          barGroups: [
            for (var i = 0; i < bars.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: (bars[i].value * 100).clamp(0.0, 100.0),
                    color: bars[i].color,
                    width: width,
                    borderRadius: BorderRadius.zero,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: CadenceColors.border.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
