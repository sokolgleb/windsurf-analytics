import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/analysis_params.dart';
import '../models/analysis_result.dart';
import '../models/spot.dart';
import '../models/weather_hour.dart';
import '../repositories/spots_repository.dart';
import '../repositories/weather_repository.dart';
import '../services/analysis_engine.dart';

// -- Supabase client --
final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// -- Repositories --
final spotsRepositoryProvider = Provider<SpotsRepository>(
  (ref) => SpotsRepository(ref.watch(supabaseProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepository(ref.watch(supabaseProvider)),
);

// -- Auth --
final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange,
);

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseProvider).auth.currentUser;
});

// -- Spots --
final spotsProvider = FutureProvider<List<Spot>>((ref) async {
  final repo = ref.watch(spotsRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repo.getAllAvailableSpots(user?.id);
});

final selectedSpotProvider = StateProvider<Spot?>((ref) => null);

// -- Analysis params --
final analysisParamsProvider =
    StateNotifierProvider<AnalysisParamsNotifier, AnalysisParams>(
  (ref) {
    final spot = ref.watch(selectedSpotProvider);
    return AnalysisParamsNotifier(spot);
  },
);

class AnalysisParamsNotifier extends StateNotifier<AnalysisParams> {
  AnalysisParamsNotifier(Spot? spot)
      : super(AnalysisParams(
          startYear: DateTime.now().year - 2,
          endYear: DateTime.now().year,
          allowedDirections: spot?.defaultDirections.toSet() ??
              {'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'},
        ));

  void update(AnalysisParams Function(AnalysisParams) updater) {
    state = updater(state);
  }
}

// -- Weather data --
final weatherDataProvider = FutureProvider<List<WeatherHour>>((ref) async {
  final spot = ref.watch(selectedSpotProvider);
  final params = ref.watch(analysisParamsProvider);
  if (spot == null) return [];

  final repo = ref.watch(weatherRepositoryProvider);
  final startDate = DateTime(params.startYear);
  final endDate = DateTime(params.endYear, 12, 31, 23, 59, 59);

  return repo.getWeatherHours(spot.id, startDate, endDate);
});

// -- Analysis result --
final analysisResultProvider = Provider<AsyncValue<AnalysisResult>>((ref) {
  final weatherAsync = ref.watch(weatherDataProvider);
  final params = ref.watch(analysisParamsProvider);

  return weatherAsync.when(
    data: (weatherData) {
      if (weatherData.isEmpty) {
        return AsyncValue.data(AnalysisResult(
          dailyStats: [],
          monthlyAvg: [],
          weeklyHeatmap: {},
          hourlyHeatmap: {},
          windRose: [],
        ));
      }
      final result = analyze(
        weatherData,
        params.startHour,
        params.endHour,
        params.allowedDirections,
        params.minWind,
        params.minDuration,
        params.minPct,
        useGusts: params.useGusts,
      );
      return AsyncValue.data(result);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// -- Locale --
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }
}
