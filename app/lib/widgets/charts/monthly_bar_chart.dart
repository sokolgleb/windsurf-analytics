import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/l10n_helpers.dart';
import '../../models/analysis_result.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyAvg> data;
  final int startYear;
  final int endYear;

  const MonthlyBarChart({
    super.key,
    required this.data,
    required this.startYear,
    required this.endYear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final teal = theme.colorScheme.primary;

    final maxY =
        data.fold<double>(0, (max, e) => e.avgDays > max ? e.avgDays : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.chartMonthlyTitle('$startYear', '$endYear'),
            style: theme.textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxY * 1.3).ceilToDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = data[group.x].month;
                      return BarTooltipItem(
                        '${monthShort(l10n, month)}: ${rod.toY.toStringAsFixed(1)}',
                        TextStyle(color: theme.colorScheme.onSurface),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            monthShort(l10n, data[idx].month),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(l10n.chartMonthlyYAxis,
                        style: theme.textTheme.bodySmall),
                    sideTitles: const SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.avgDays,
                        color: teal,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                    showingTooltipIndicators: [],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
