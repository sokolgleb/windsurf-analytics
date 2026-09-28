import 'package:flutter/material.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/l10n_helpers.dart';
import '../../models/analysis_result.dart';
import '../../models/gliding_day.dart';

class KpiCards extends StatelessWidget {
  final AnalysisResult result;
  final int startYear;
  final int endYear;

  const KpiCards({
    super.key,
    required this.result,
    required this.startYear,
    required this.endYear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final totalDays = result.totalGlidingDays;
    final numYears = (endYear - startYear) + 1;
    final avgPerYear =
        numYears > 0 ? (totalDays / numYears * 10).round() / 10 : 0.0;

    // Best month
    final bestMonth = _bestMonth(result.dailyStats, l10n);

    // Average wind on gliding days
    final glidingDays = result.glidingDays;
    final avgWind = glidingDays.isNotEmpty
        ? (glidingDays.map((d) => d.avgWind).reduce((a, b) => a + b) /
                glidingDays.length *
                10)
            .round() /
            10
        : 0.0;

    return Row(
      children: [
        _KpiCard(
          title: l10n.kpiTotalDays,
          value: '$totalDays',
        ),
        _KpiCard(
          title: l10n.kpiAvgPerYear,
          value: avgPerYear.toStringAsFixed(1),
        ),
        _KpiCard(
          title: l10n.kpiBestMonth,
          value: bestMonth,
        ),
        _KpiCard(
          title: l10n.kpiAvgWind,
          value: l10n.kpiKnots(avgWind.toStringAsFixed(1)),
        ),
      ].map((card) => Expanded(child: card)).toList(),
    );
  }

  String _bestMonth(List<GlidingDay> daily, AppLocalizations l10n) {
    if (daily.isEmpty) return l10n.kpiNoData;

    // Group by (year, month) -> count gliding days
    final counts = <(int, int), int>{};
    for (final d in daily) {
      if (!d.isGliding) continue;
      final key = (d.year, d.month);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return l10n.kpiNoData;

    final best = counts.entries.reduce(
        (a, b) => a.value >= b.value ? a : b);

    return l10n.kpiBestMonthValue(
      monthShort(l10n, best.key.$2),
      '${best.key.$1}',
      '${best.value}',
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
