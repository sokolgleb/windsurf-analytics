import 'package:flutter/material.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/l10n_helpers.dart';

class HourlyHeatmap extends StatelessWidget {
  /// {month: {hour: avgWindSpeed}}
  final Map<int, Map<int, double>> data;

  const HourlyHeatmap({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return Center(child: Text(l10n.chartNoData));
    }

    final months = data.keys.toList()..sort();
    final allHours = data.values
        .expand((m) => m.keys)
        .toSet()
        .toList()
      ..sort();
    if (allHours.isEmpty) return Center(child: Text(l10n.chartNoData));

    final maxVal = data.values
        .expand((m) => m.values)
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.chartHourlyTitle,
              style: theme.textTheme.titleMedium),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: hours
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        for (final h in allHours)
                          SizedBox(
                            width: 36,
                            child: Text('$h:00',
                                style: theme.textTheme.labelSmall,
                                textAlign: TextAlign.center),
                          ),
                      ],
                    ),
                    // Data rows
                    for (final month in months)
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(monthShort(l10n, month),
                                style: theme.textTheme.bodySmall),
                          ),
                          for (final h in allHours)
                            Container(
                              width: 34,
                              height: 28,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: _cellColor(
                                    data[month]?[h] ?? 0, maxVal),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Tooltip(
                                message:
                                    '${monthShort(l10n, month)} $h:00 — ${(data[month]?[h] ?? 0).toStringAsFixed(1)} kn',
                                child: Center(
                                  child: Text(
                                    (data[month]?[h] ?? 0)
                                        .toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: (data[month]?[h] ?? 0) >
                                              maxVal * 0.6
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(l10n.chartHourlyHint,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _cellColor(double value, double maxVal) {
    if (value == 0 || maxVal == 0) return const Color(0xFFFFF9C4);
    final t = (value / maxVal).clamp(0.0, 1.0);
    // YlOrRd-inspired
    return Color.lerp(
      const Color(0xFFFFF9C4), // light yellow
      const Color(0xFFD32F2F), // dark red
      t,
    )!;
  }
}
