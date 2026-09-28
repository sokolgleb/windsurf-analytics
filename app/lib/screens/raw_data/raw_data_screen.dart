import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/l10n_helpers.dart';
import '../../providers/providers.dart';

class RawDataScreen extends ConsumerWidget {
  const RawDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final resultAsync = ref.watch(analysisResultProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rawDataTitle),
        actions: [
          resultAsync.whenOrNull(
                data: (result) {
                  final glidingDays = result.glidingDays;
                  if (glidingDays.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: l10n.exportDownloadCsv,
                    onPressed: () => _downloadCsv(context, ref, l10n),
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (result) {
          final glidingDays = result.glidingDays;
          if (glidingDays.isEmpty) {
            return Center(child: Text(l10n.noGlidingDays));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(l10n.exportDate)),
                DataColumn(label: Text(l10n.exportMonth)),
                DataColumn(label: Text(l10n.exportAvgWind), numeric: true),
                DataColumn(label: Text(l10n.exportMaxChain), numeric: true),
                DataColumn(label: Text(l10n.exportDensity), numeric: true),
              ],
              rows: glidingDays
                  .map((d) => DataRow(cells: [
                        DataCell(Text(
                            '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}-${d.date.day.toString().padLeft(2, '0')}')),
                        DataCell(Text(monthFull(l10n, d.month))),
                        DataCell(Text(d.avgWind.toStringAsFixed(1))),
                        DataCell(Text('${d.maxChain}')),
                        DataCell(Text(d.densityPct.toStringAsFixed(1))),
                      ]))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  void _downloadCsv(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final result = ref.read(analysisResultProvider).value;
    if (result == null) return;

    final buf = StringBuffer();
    buf.writeln('Date,Month,Avg Wind (kn),Max Chain (h),Density (%)');
    for (final d in result.glidingDays) {
      buf.writeln(
          '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}-${d.date.day.toString().padLeft(2, '0')},'
          '${monthFull(l10n, d.month)},'
          '${d.avgWind},'
          '${d.maxChain},'
          '${d.densityPct}');
    }

    final bytes = utf8.encode(buf.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'gliding_days.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
