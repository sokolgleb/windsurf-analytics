import 'package:flutter/material.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

class WeeklyHeatmap extends StatelessWidget {
  /// {year: {week: glidingDaysCount}}
  final Map<int, Map<int, int>> data;

  const WeeklyHeatmap({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return Center(child: Text(l10n.chartNoData));
    }

    final years = data.keys.toList()..sort();
    final maxVal =
        data.values.expand((m) => m.values).fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.chartWeeklyTitle,
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
                    // Header row: week numbers
                    Row(
                      children: [
                        const SizedBox(width: 50), // year label space
                        for (int w = 1; w <= 52; w++)
                          SizedBox(
                            width: 18,
                            child: Text(
                              w % 4 == 0 ? '$w' : '',
                              style: theme.textTheme.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                    // Data rows
                    for (final year in years)
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text('$year',
                                style: theme.textTheme.bodySmall),
                          ),
                          for (int w = 1; w <= 52; w++)
                            Container(
                              width: 16,
                              height: 20,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: _cellColor(
                                    data[year]?[w] ?? 0, maxVal, theme),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Tooltip(
                                message: '$year, W$w: ${data[year]?[w] ?? 0} d.',
                                child: const SizedBox.expand(),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(l10n.chartWeeklyHint,
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

  Color _cellColor(int value, int maxVal, ThemeData theme) {
    if (value == 0 || maxVal == 0) {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }
    final t = value / maxVal;
    // YlGnBu-inspired: light yellow → teal → dark blue
    return Color.lerp(
      const Color(0xFFE0F7FA),
      const Color(0xFF006064),
      t,
    )!;
  }
}
