import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/l10n_helpers.dart';
import '../../providers/providers.dart';
import '../../widgets/charts/monthly_bar_chart.dart';
import '../../widgets/charts/weekly_heatmap.dart';
import '../../widgets/charts/wind_rose.dart';
import '../../widgets/charts/hourly_heatmap.dart';
import '../../widgets/charts/kpi_cards.dart';
import '../../widgets/charts/sail_recommendations.dart';
import 'analysis_controls.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Auto-select first spot if none selected
    Future.microtask(() {
      final spot = ref.read(selectedSpotProvider);
      if (spot == null) {
        final spotsAsync = ref.read(spotsProvider);
        spotsAsync.whenData((spots) {
          if (spots.isNotEmpty) {
            ref.read(selectedSpotProvider.notifier).state = spots.first;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spot = ref.watch(selectedSpotProvider);
    final params = ref.watch(analysisParamsProvider);
    final resultAsync = ref.watch(analysisResultProvider);
    final isWide = MediaQuery.sizeOf(context).width > 1024;

    final sidebar = SizedBox(
      width: 320,
      child: Card(
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(),
        child: const AnalysisControls(),
      ),
    );

    final content = Column(
      children: [
        // KPI row
        resultAsync.when(
          data: (result) => Padding(
            padding: const EdgeInsets.all(16),
            child: KpiCards(
              result: result,
              startYear: params.startYear,
              endYear: params.endYear,
            ),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.loadError),
          ),
        ),

        // Tab bar
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.tabMonthly),
            Tab(text: l10n.tabWeeklyHeatmap),
            Tab(text: l10n.tabWindRose),
            Tab(text: l10n.tabHourlyHeatmap),
            Tab(text: l10n.tabSailRecs),
          ],
        ),

        // Tab content
        Expanded(
          child: resultAsync.when(
            data: (result) => TabBarView(
              controller: _tabController,
              children: [
                MonthlyBarChart(
                  data: result.monthlyAvg,
                  startYear: params.startYear,
                  endYear: params.endYear,
                ),
                WeeklyHeatmap(data: result.weeklyHeatmap),
                WindRoseChart(
                  data: result.windRose,
                  spotName: spot != null
                      ? spotLocalizedName(l10n, spot.id, spot.name)
                      : '',
                  startHour: params.startHour,
                  endHour: params.endHour,
                ),
                HourlyHeatmap(data: result.hourlyHeatmap),
                SailRecommendations(glidingDays: result.glidingDays),
              ],
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.loadError)),
          ),
        ),

        // Attribution
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(l10n.dataAttribution,
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            sidebar,
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    // Mobile: drawer
    return Scaffold(
      appBar: AppBar(
        title: Text(spot != null
            ? spotLocalizedName(l10n, spot.id, spot.name)
            : l10n.appTitle),
      ),
      drawer: Drawer(child: SafeArea(child: const AnalysisControls())),
      body: content,
    );
  }
}
