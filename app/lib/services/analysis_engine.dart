import 'dart:math' as math;

import '../core/constants.dart';
import '../models/analysis_result.dart';
import '../models/gliding_day.dart';
import '../models/weather_hour.dart';

/// Convert wind direction in degrees (0-360) to 8-point compass label.
String degreesToCompass(double deg) {
  final idx = ((deg + 22.5) / 45).floor() % 8;
  return compassPoints[idx];
}

/// Return sail size recommendation string for a given average wind speed.
String recommendSail(double avgWindKnots) {
  for (final (low, high, sail, _) in sailRecommendations) {
    if (avgWindKnots >= low && avgWindKnots < high) return sail;
  }
  if (avgWindKnots < 14) return '< 14 kn';
  return '3.7 m²';
}

/// Tagged hourly record after filtering.
class TaggedHour {
  final DateTime time;
  final DateTime date; // date-only (midnight)
  final int hour;
  final int month;
  final int year;
  final int isoWeek;
  final double windSpeed;
  final double? windGust;
  final String direction;
  final double validSpeed;
  final bool isWindy;

  const TaggedHour({
    required this.time,
    required this.date,
    required this.hour,
    required this.month,
    required this.year,
    required this.isoWeek,
    required this.windSpeed,
    this.windGust,
    required this.direction,
    required this.validSpeed,
    required this.isWindy,
  });
}

/// ISO week number (1-53). Matches Python's isocalendar().week.
int isoWeekNumber(DateTime date) {
  // Algorithm: ISO 8601 week date
  final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
  final jan4 = DateTime(thursday.year, 1, 4);
  final dayOfYear =
      thursday.difference(DateTime(thursday.year, 1, 1)).inDays + 1;
  return ((dayOfYear - jan4.weekday + 10) / 7).floor();
}

/// From raw hourly data, produce a daytime-only list with:
///   - validSpeed: wind metric (avg or gust) if direction is allowed, else 0
///   - isWindy: validSpeed >= minWind
List<TaggedHour> filterAndTag(
  List<WeatherHour> data,
  int startHour,
  int endHour,
  Set<String> allowedDirs,
  double minWind, {
  bool useGusts = false,
}) {
  final result = <TaggedHour>[];

  for (final w in data) {
    final hour = w.time.hour;
    if (hour < startHour || hour > endHour) continue;

    final direction = degreesToCompass(w.windDirection.toDouble());
    final speed = useGusts && w.windGustKn != null ? w.windGustKn! : w.windSpeedKn;
    final dirOk = allowedDirs.contains(direction);
    final validSpeed = dirOk ? speed : 0.0;
    final isWindy = validSpeed >= minWind;

    result.add(TaggedHour(
      time: w.time,
      date: DateTime(w.time.year, w.time.month, w.time.day),
      hour: hour,
      month: w.time.month,
      year: w.time.year,
      isoWeek: isoWeekNumber(w.time),
      windSpeed: w.windSpeedKn,
      windGust: w.windGustKn,
      direction: direction,
      validSpeed: validSpeed,
      isWindy: isWindy,
    ));
  }

  return result;
}

/// Return the length of the longest run of true values in a boolean list.
int maxConsecutiveTrue(List<bool> arr) {
  if (arr.isEmpty) return 0;

  int maxRun = 0;
  int currentRun = 0;
  for (final v in arr) {
    if (v) {
      currentRun++;
      if (currentRun > maxRun) maxRun = currentRun;
    } else {
      currentRun = 0;
    }
  }
  return maxRun;
}

/// For each calendar day, determine if it qualifies as a gliding day.
List<GlidingDay> evaluateDays(
  List<TaggedHour> daytime,
  double minWind,
  int minDuration,
  double minPct,
  int windowHours,
) {
  // Group by date
  final byDate = <DateTime, List<TaggedHour>>{};
  for (final h in daytime) {
    (byDate[h.date] ??= []).add(h);
  }

  final sortedDates = byDate.keys.toList()..sort();
  final results = <GlidingDay>[];

  for (final date in sortedDates) {
    final group = byDate[date]!;
    final windyArr = group.map((h) => h.isWindy).toList();
    final maxChain = maxConsecutiveTrue(windyArr);

    final nWindy = windyArr.where((v) => v).length;
    final actualHours = group.length;
    final denom =
        actualHours > 0 ? math.min(actualHours, windowHours) : windowHours;
    final density = (nWindy / denom) * 100;

    final isGliding = maxChain >= minDuration && density >= minPct;

    // Average wind speed on windy hours only
    final windySpeeds =
        group.where((h) => h.isWindy).map((h) => h.validSpeed).toList();
    final avgWind = windySpeeds.isNotEmpty
        ? windySpeeds.reduce((a, b) => a + b) / windySpeeds.length
        : 0.0;

    final first = group.first;
    results.add(GlidingDay(
      date: date,
      year: first.year,
      month: first.month,
      isoWeek: first.isoWeek,
      isGliding: isGliding,
      maxChain: maxChain,
      densityPct: _round1(density),
      avgWind: _round1(avgWind),
    ));
  }

  return results;
}

/// Average gliding days per month across all years.
List<MonthlyAvg> computeMonthlyAvg(List<GlidingDay> daily) {
  // Group by (month, year) -> count gliding days
  final byMonthYear = <(int, int), int>{};
  for (final d in daily) {
    final key = (d.month, d.year);
    byMonthYear[key] = (byMonthYear[key] ?? 0) + (d.isGliding ? 1 : 0);
  }

  // Group by month -> average across years
  final byMonth = <int, List<int>>{};
  for (final entry in byMonthYear.entries) {
    (byMonth[entry.key.$1] ??= []).add(entry.value);
  }

  final result = <MonthlyAvg>[];
  for (int m = 1; m <= 12; m++) {
    final counts = byMonth[m];
    if (counts == null) continue;
    final avg = counts.reduce((a, b) => a + b) / counts.length;
    result.add(MonthlyAvg(month: m, avgDays: _round1(avg)));
  }
  return result;
}

/// Pivot: rows=year, columns=iso_week (1-52), values=gliding days count.
/// Week 53 is merged into week 52.
Map<int, Map<int, int>> computeWeeklyHeatmap(List<GlidingDay> daily) {
  final data = <int, Map<int, int>>{}; // year -> {week -> count}

  for (final d in daily) {
    if (!d.isGliding) continue;
    final week = d.isoWeek == 53 ? 52 : d.isoWeek;
    final yearMap = data[d.year] ??= {};
    yearMap[week] = (yearMap[week] ?? 0) + 1;
  }

  // Ensure all weeks 1-52 are present for each year
  for (final yearMap in data.values) {
    for (int w = 1; w <= 52; w++) {
      yearMap.putIfAbsent(w, () => 0);
    }
  }

  return data;
}

/// Pivot: rows=month, columns=hour, values=avg wind speed
/// (only from allowed directions).
Map<int, Map<int, double>> computeHourlyHeatmap(
  List<TaggedHour> daytime,
  Set<String> allowedDirs,
) {
  // Group by (month, hour) -> list of wind speeds
  final groups = <(int, int), List<double>>{};

  for (final h in daytime) {
    if (!allowedDirs.contains(h.direction)) continue;
    final key = (h.month, h.hour);
    (groups[key] ??= []).add(h.windSpeed);
  }

  final result = <int, Map<int, double>>{};
  for (final entry in groups.entries) {
    final month = entry.key.$1;
    final hour = entry.key.$2;
    final speeds = entry.value;
    final avg = speeds.reduce((a, b) => a + b) / speeds.length;
    (result[month] ??= {})[hour] = _round1(avg);
  }

  return result;
}

/// Return data for a wind rose: direction, speed_bin, count.
/// Speed bins: 0-10, 10-14, 14-18, 18-22, 22-28, 28+ knots.
List<WindRoseEntry> computeWindRose(List<TaggedHour> daytime) {
  // Count by (direction, bin_index)
  final counts = <(String, int), int>{};

  for (final h in daytime) {
    final binIdx = _speedBinIndex(h.windSpeed);
    final key = (h.direction, binIdx);
    counts[key] = (counts[key] ?? 0) + 1;
  }

  // Build result with all combinations for compass order
  final result = <WindRoseEntry>[];
  for (final dir in compassPoints) {
    for (int i = 0; i < windSpeedBinLabels.length; i++) {
      result.add(WindRoseEntry(
        direction: dir,
        speedBin: windSpeedBinLabels[i],
        count: counts[(dir, i)] ?? 0,
      ));
    }
  }

  return result;
}

/// Run the complete analysis pipeline.
AnalysisResult analyze(
  List<WeatherHour> data,
  int startHour,
  int endHour,
  Set<String> allowedDirs,
  double minWind,
  int minDuration,
  double minPct, {
  bool useGusts = false,
}) {
  final windowHours = (endHour - startHour) + 1;

  final daytime = filterAndTag(
    data, startHour, endHour, allowedDirs, minWind,
    useGusts: useGusts,
  );
  final dailyStats =
      evaluateDays(daytime, minWind, minDuration, minPct, windowHours);
  final monthlyAvg = computeMonthlyAvg(dailyStats);
  final weeklyHeatmap = computeWeeklyHeatmap(dailyStats);
  final hourlyHeatmap = computeHourlyHeatmap(daytime, allowedDirs);
  final windRose = computeWindRose(daytime);

  return AnalysisResult(
    dailyStats: dailyStats,
    monthlyAvg: monthlyAvg,
    weeklyHeatmap: weeklyHeatmap,
    hourlyHeatmap: hourlyHeatmap,
    windRose: windRose,
  );
}

// -- helpers --

double _round1(double v) => (v * 10).roundToDouble() / 10;

int _speedBinIndex(double speed) {
  for (int i = 0; i < windSpeedBins.length - 1; i++) {
    if (speed >= windSpeedBins[i] && speed < windSpeedBins[i + 1]) return i;
  }
  return windSpeedBinLabels.length - 1;
}
