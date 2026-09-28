import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../core/l10n_helpers.dart';
import '../../models/spot.dart';
import '../../providers/providers.dart';

class AnalysisControls extends ConsumerWidget {
  const AnalysisControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final params = ref.watch(analysisParamsProvider);
    final notifier = ref.read(analysisParamsProvider.notifier);
    final spot = ref.watch(selectedSpotProvider);
    final spotsAsync = ref.watch(spotsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Spot selector
        spotsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (spots) => DropdownButtonFormField<Spot>(
            initialValue: spot,
            decoration: InputDecoration(
              labelText: l10n.appTitle,
              border: const OutlineInputBorder(),
            ),
            isExpanded: true,
            items: spots
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        spotLocalizedName(l10n, s.id, s.name),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (s) {
              if (s == null) return;
              ref.read(selectedSpotProvider.notifier).state = s;
              notifier.update((p) => p.copyWith(
                    allowedDirections: s.defaultDirections.toSet(),
                  ));
            },
          ),
        ),
        if (spot != null && spot.description != null) ...[
          const SizedBox(height: 4),
          Text(spot.description!,
              style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 16),

        // Year range
        Text(l10n.yearRange),
        RangeSlider(
          values: RangeValues(
              params.startYear.toDouble(), params.endYear.toDouble()),
          min: 2010,
          max: DateTime.now().year.toDouble(),
          divisions: DateTime.now().year - 2010,
          labels: RangeLabels('${params.startYear}', '${params.endYear}'),
          onChanged: (v) => notifier.update((p) => p.copyWith(
                startYear: v.start.round(),
                endYear: v.end.round(),
              )),
        ),
        const SizedBox(height: 8),

        // Time window
        Text(l10n.timeWindow),
        RangeSlider(
          values: RangeValues(
              params.startHour.toDouble(), params.endHour.toDouble()),
          min: 0,
          max: 23,
          divisions: 23,
          labels: RangeLabels(
              '${params.startHour}:00', '${params.endHour}:00'),
          onChanged: (v) => notifier.update((p) => p.copyWith(
                startHour: v.start.round(),
                endHour: v.end.round(),
              )),
        ),
        const SizedBox(height: 8),

        // Wind metric toggle
        Text(l10n.windMetric),
        const SizedBox(height: 4),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(l10n.avgWind)),
            ButtonSegment(value: true, label: Text(l10n.gusts)),
          ],
          selected: {params.useGusts},
          onSelectionChanged: (v) =>
              notifier.update((p) => p.copyWith(useGusts: v.first)),
        ),
        const SizedBox(height: 12),

        // Min wind speed
        Text('${l10n.minWindSpeed}: ${params.minWind.round()}'),
        Slider(
          value: params.minWind,
          min: 10,
          max: 35,
          divisions: 25,
          label: '${params.minWind.round()} kn',
          onChanged: (v) =>
              notifier.update((p) => p.copyWith(minWind: v)),
        ),

        // Min duration
        Text('${l10n.minDuration}: ${params.minDuration}'),
        Slider(
          value: params.minDuration.toDouble(),
          min: 1,
          max: 6,
          divisions: 5,
          label: '${params.minDuration} h',
          onChanged: (v) =>
              notifier.update((p) => p.copyWith(minDuration: v.round())),
        ),

        // Min density
        Text('${l10n.minDensity}: ${params.minPct.round()}%'),
        Slider(
          value: params.minPct,
          min: 10,
          max: 100,
          divisions: 18,
          label: '${params.minPct.round()}%',
          onChanged: (v) =>
              notifier.update((p) => p.copyWith(minPct: v)),
        ),
        const SizedBox(height: 8),

        // Allowed directions
        Text(l10n.allowedDirections),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: compassPoints.map((dir) {
            final selected = params.allowedDirections.contains(dir);
            return FilterChip(
              label: Text(dir),
              selected: selected,
              onSelected: (v) {
                final dirs = Set<String>.from(params.allowedDirections);
                v ? dirs.add(dir) : dirs.remove(dir);
                if (dirs.isNotEmpty) {
                  notifier.update(
                      (p) => p.copyWith(allowedDirections: dirs));
                }
              },
            );
          }).toList(),
        ),

        const Divider(height: 32),

        // Language selector
        Text(l10n.language),
        const SizedBox(height: 8),
        SegmentedButton<Locale>(
          segments: [
            ButtonSegment(
                value: const Locale('en'), label: Text(l10n.english)),
            ButtonSegment(
                value: const Locale('ru'), label: Text(l10n.russian)),
          ],
          selected: {ref.watch(localeProvider)},
          onSelectionChanged: (v) =>
              ref.read(localeProvider.notifier).setLocale(v.first),
        ),

        const SizedBox(height: 16),

        // Auth / My spots links
        _AuthSection(),
      ],
    );
  }
}

class _AuthSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.login),
        label: Text(l10n.authForCustomSpots),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.place),
          label: Text(l10n.mySpotsTitle),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            await ref.read(supabaseProvider).auth.signOut();
          },
          child: Text(l10n.authSignOut),
        ),
      ],
    );
  }
}
