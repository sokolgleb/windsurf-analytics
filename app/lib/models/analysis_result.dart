import 'gliding_day.dart';

class MonthlyAvg {
  final int month;
  final double avgDays;
  const MonthlyAvg({required this.month, required this.avgDays});
}

class WindRoseEntry {
  final String direction;
  final String speedBin;
  final int count;
  const WindRoseEntry({
    required this.direction,
    required this.speedBin,
    required this.count,
  });
}

class AnalysisResult {
  final List<GlidingDay> dailyStats;
  final List<MonthlyAvg> monthlyAvg;

  /// Rows = years, Cols = weeks (1..52). Values = gliding days count.
  final Map<int, Map<int, int>> weeklyHeatmap;

  /// Rows = months, Cols = hours. Values = avg wind speed.
  final Map<int, Map<int, double>> hourlyHeatmap;

  final List<WindRoseEntry> windRose;

  const AnalysisResult({
    required this.dailyStats,
    required this.monthlyAvg,
    required this.weeklyHeatmap,
    required this.hourlyHeatmap,
    required this.windRose,
  });

  int get totalGlidingDays =>
      dailyStats.where((d) => d.isGliding).length;

  List<GlidingDay> get glidingDays =>
      dailyStats.where((d) => d.isGliding).toList();
}
