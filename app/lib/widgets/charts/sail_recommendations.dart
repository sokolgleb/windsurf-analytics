import 'package:flutter/material.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/l10n_helpers.dart';
import '../../models/gliding_day.dart';
import '../../services/analysis_engine.dart';

class SailRecommendations extends StatelessWidget {
  final List<GlidingDay> glidingDays;

  const SailRecommendations({super.key, required this.glidingDays});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (glidingDays.isEmpty) {
      return Center(child: Text(l10n.noGlidingDays));
    }

    // Group by month -> average wind
    final byMonth = <int, List<double>>{};
    for (final d in glidingDays) {
      (byMonth[d.month] ??= []).add(d.avgWind);
    }

    final months = byMonth.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.sailRecsTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.sailRecsHint, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.sailMonth)),
                DataColumn(label: Text(l10n.sailAvgWind), numeric: true),
                DataColumn(label: Text(l10n.sailRecommendation)),
              ],
              rows: months.map((m) {
                final winds = byMonth[m]!;
                final avg =
                    (winds.reduce((a, b) => a + b) / winds.length * 10)
                        .round() /
                        10;
                return DataRow(cells: [
                  DataCell(Text(monthFull(l10n, m))),
                  DataCell(Text(avg.toStringAsFixed(1))),
                  DataCell(Text(recommendSail(avg))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
