import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../providers/providers.dart';

class MySpotsScreen extends ConsumerWidget {
  const MySpotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.mySpotsTitle)),
        body: Center(child: Text(l10n.authForCustomSpots)),
      );
    }

    final spotsAsync = ref.watch(spotsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mySpotsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.mySpotsAdd),
      ),
      body: spotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (spots) {
          final userSpots = spots.where((s) => !s.isPreset).toList();
          if (userSpots.isEmpty) {
            return Center(child: Text(l10n.mySpotsEmpty));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userSpots.length,
            itemBuilder: (context, i) {
              final spot = userSpots[i];
              return Card(
                child: ListTile(
                  title: Text(spot.name),
                  subtitle: Text(
                    '${spot.latitude.toStringAsFixed(4)}, '
                    '${spot.longitude.toStringAsFixed(4)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final repo = ref.read(spotsRepositoryProvider);
                      await repo.deleteSpot(spot.id);
                      ref.invalidate(spotsProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lonCtrl = TextEditingController();
    final tzCtrl = TextEditingController(text: 'UTC');
    final selectedDirs = <String>{...compassPoints};

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mySpotsAdd),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l10n.spotName),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: latCtrl,
                decoration: InputDecoration(labelText: l10n.spotLatitude),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lonCtrl,
                decoration: InputDecoration(labelText: l10n.spotLongitude),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tzCtrl,
                decoration: InputDecoration(labelText: l10n.spotTimezone),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.spotCancel),
          ),
          FilledButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              final repo = ref.read(spotsRepositoryProvider);
              await repo.createSpot(
                userId: user.id,
                name: nameCtrl.text,
                latitude: double.tryParse(latCtrl.text) ?? 0,
                longitude: double.tryParse(lonCtrl.text) ?? 0,
                timezone: tzCtrl.text,
                defaultDirections: selectedDirs.toList(),
              );
              ref.invalidate(spotsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.spotSave),
          ),
        ],
      ),
    );
  }
}
