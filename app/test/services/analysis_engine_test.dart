import 'package:flutter_test/flutter_test.dart';

import 'package:windsurf_analytics/models/gliding_day.dart';
import 'package:windsurf_analytics/models/weather_hour.dart';
import 'package:windsurf_analytics/services/analysis_engine.dart';

/// Helper: build a list of WeatherHour similar to what data.py returns.
List<WeatherHour> makeHourlyData({
  required List<int> hours,
  required List<double> speeds,
  required List<double> directionsDeg,
  List<double?>? gusts,
  DateTime? baseDate,
}) {
  baseDate ??= DateTime(2024, 7, 15);
  return List.generate(hours.length, (i) {
    return WeatherHour(
      spotId: 'test',
      time: DateTime(
          baseDate!.year, baseDate.month, baseDate.day, hours[i]),
      windSpeedKn: speeds[i],
      windGustKn: gusts?[i],
      windDirection: directionsDeg[i].round(),
    );
  });
}

// ---------------------------------------------------------------------------
// degreesToCompass
// ---------------------------------------------------------------------------

void main() {
  group('degreesToCompass', () {
    final testCases = <(double, String)>[
      (0, 'N'), (10, 'N'), (22.4, 'N'), (337.6, 'N'), (360, 'N'),
      (22.5, 'NE'), (45, 'NE'), (67.4, 'NE'),
      (67.5, 'E'), (90, 'E'), (112.4, 'E'),
      (112.5, 'SE'), (135, 'SE'), (157.4, 'SE'),
      (157.5, 'S'), (180, 'S'), (202.4, 'S'),
      (202.5, 'SW'), (225, 'SW'), (247.4, 'SW'),
      (247.5, 'W'), (270, 'W'), (292.4, 'W'),
      (292.5, 'NW'), (315, 'NW'), (337.4, 'NW'),
    ];

    for (final (deg, expected) in testCases) {
      test('$deg° → $expected', () {
        expect(degreesToCompass(deg), expected);
      });
    }

    test('exact 360 → N', () {
      expect(degreesToCompass(360), 'N');
    });
  });

  // ---------------------------------------------------------------------------
  // maxConsecutiveTrue
  // ---------------------------------------------------------------------------

  group('maxConsecutiveTrue', () {
    test('empty', () {
      expect(maxConsecutiveTrue([]), 0);
    });

    test('all false', () {
      expect(maxConsecutiveTrue([false, false, false]), 0);
    });

    test('all true', () {
      expect(maxConsecutiveTrue([true, true, true]), 3);
    });

    test('single true', () {
      expect(maxConsecutiveTrue([false, true, false]), 1);
    });

    test('multiple runs', () {
      expect(
          maxConsecutiveTrue(
              [true, true, false, true, true, true, false, true]),
          3);
    });

    test('leading run', () {
      expect(maxConsecutiveTrue([true, true, true, false, true]), 3);
    });

    test('trailing run', () {
      expect(maxConsecutiveTrue([true, false, true, true, true]), 3);
    });
  });

  // ---------------------------------------------------------------------------
  // filterAndTag
  // ---------------------------------------------------------------------------

  group('filterAndTag', () {
    test('hour window filters correctly', () {
      final data = makeHourlyData(
        hours: List.generate(24, (i) => i),
        speeds: List.filled(24, 15.0),
        directionsDeg: List.filled(24, 0), // N
      );
      final result = filterAndTag(data, 10, 18, {'N'}, 14);
      expect(result.length, 9); // hours 10..18 inclusive
    });

    test('direction filter zeroes speed', () {
      final data = makeHourlyData(
        hours: [10, 11, 12],
        speeds: [20, 20, 20],
        directionsDeg: [0, 180, 0], // N, S, N
      );
      final result = filterAndTag(data, 10, 12, {'N'}, 14);
      // Hour 11 is S -> zeroed out
      expect(result[1].validSpeed, 0.0);
      expect(result[0].validSpeed, 20.0);
    });

    test('does not mutate input', () {
      final data = makeHourlyData(
        hours: [10, 11],
        speeds: [20, 20],
        directionsDeg: [0, 0],
      );
      final originalLength = data.length;
      filterAndTag(data, 10, 11, {'N'}, 14);
      expect(data.length, originalLength);
    });
  });

  // ---------------------------------------------------------------------------
  // evaluateDays
  // ---------------------------------------------------------------------------

  group('evaluateDays', () {
    test('perfect gliding day', () {
      final data = makeHourlyData(
        hours: List.generate(10, (i) => i + 10),
        speeds: List.filled(10, 18.0),
        directionsDeg: List.filled(10, 0),
      );
      final tagged = filterAndTag(data, 10, 19, {'N'}, 14);
      final daily = evaluateDays(tagged, 14, 2, 70, 10);
      expect(daily.length, 1);
      expect(daily.first.isGliding, true);
    });

    test('insufficient duration', () {
      final speeds = [18.0, ...List.filled(9, 5.0)];
      final data = makeHourlyData(
        hours: List.generate(10, (i) => i + 10),
        speeds: speeds,
        directionsDeg: List.filled(10, 0),
      );
      final tagged = filterAndTag(data, 10, 19, {'N'}, 14);
      final daily = evaluateDays(tagged, 14, 2, 10, 10);
      expect(daily.first.isGliding, false);
    });

    test('insufficient density', () {
      final speeds = [18.0, 18.0, 18.0, ...List.filled(7, 5.0)];
      final data = makeHourlyData(
        hours: List.generate(10, (i) => i + 10),
        speeds: speeds,
        directionsDeg: List.filled(10, 0),
      );
      final tagged = filterAndTag(data, 10, 19, {'N'}, 14);
      final daily = evaluateDays(tagged, 14, 2, 70, 10);
      expect(daily.first.isGliding, false);
    });

    test('boundary wind speed (exactly at threshold)', () {
      final data = makeHourlyData(
        hours: List.generate(10, (i) => i + 10),
        speeds: List.filled(10, 14.0),
        directionsDeg: List.filled(10, 0),
      );
      final tagged = filterAndTag(data, 10, 19, {'N'}, 14);
      final daily = evaluateDays(tagged, 14, 2, 70, 10);
      expect(daily.first.isGliding, true);
    });

    test('just below threshold', () {
      final data = makeHourlyData(
        hours: List.generate(10, (i) => i + 10),
        speeds: List.filled(10, 13.9),
        directionsDeg: List.filled(10, 0),
      );
      final tagged = filterAndTag(data, 10, 19, {'N'}, 14);
      final daily = evaluateDays(tagged, 14, 2, 70, 10);
      expect(daily.first.isGliding, false);
    });

    test('avg wind calculated correctly (windy hours only)', () {
      final speeds = [20.0, 22.0, 5.0, 5.0, 5.0, 24.0, 20.0, 18.0, 5.0, 5.0];
      final data = makeHourlyData(
        hours: List.generate(10, (i) => i + 10),
        speeds: speeds,
        directionsDeg: List.filled(10, 0),
      );
      final tagged = filterAndTag(data, 10, 19, {'N'}, 14);
      final daily = evaluateDays(tagged, 14, 1, 10, 10);
      // Windy hours: 20, 22, 24, 20, 18 -> avg = 20.8
      expect(daily.first.avgWind, 20.8);
    });
  });

  // ---------------------------------------------------------------------------
  // computeWeeklyHeatmap
  // ---------------------------------------------------------------------------

  group('computeWeeklyHeatmap', () {
    test('week 53 merged into week 52', () {
      final data = makeHourlyData(
        hours: [12],
        speeds: [18.0],
        directionsDeg: [0],
        baseDate: DateTime(2023, 1, 1),
      );
      final tagged = filterAndTag(data, 10, 19, {'N'}, 14);
      final daily = evaluateDays(tagged, 14, 1, 10, 10);
      // Force iso_week to 53 for testing (Jan 1 2023 is ISO week 52)
      // We'll manually create a GlidingDay with week 53
      final dailyWith53 = [
        ...daily,
        daily.first.copyWithWeek(53),
      ];
      final heatmap = computeWeeklyHeatmap(dailyWith53);
      // 53 should not appear as key
      for (final yearMap in heatmap.values) {
        expect(yearMap.containsKey(53), false);
        expect(yearMap.keys.toSet(), containsAll(List.generate(52, (i) => i + 1)));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // computeWindRose
  // ---------------------------------------------------------------------------

  group('computeWindRose', () {
    test('returns all directions', () {
      final data = makeHourlyData(
        hours: List.generate(8, (i) => i + 10),
        speeds: [15, 20, 10, 25, 8, 18, 30, 12],
        directionsDeg: [0, 45, 90, 135, 180, 225, 270, 315],
      );
      final tagged = filterAndTag(
        data, 10, 17,
        {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'}, 0,
      );
      final rose = computeWindRose(tagged);
      final dirs = rose.where((e) => e.count > 0).map((e) => e.direction).toSet();
      expect(dirs, {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'});
    });
  });
}

// Extension to help with week 53 test
extension on GlidingDay {
  GlidingDay copyWithWeek(int week) => GlidingDay(
        date: date,
        year: year,
        month: month,
        isoWeek: week,
        isGliding: isGliding,
        maxChain: maxChain,
        densityPct: densityPct,
        avgWind: avgWind,
      );
}
