import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/weather_hour.dart';

class WeatherRepository {
  final SupabaseClient _client;

  WeatherRepository(this._client);

  /// Fetch cached weather hours for a spot within a date range.
  Future<List<WeatherHour>> getWeatherHours(
    String spotId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final data = await _client
        .from('weather_hours')
        .select()
        .eq('spot_id', spotId)
        .gte('time', startDate.toIso8601String())
        .lte('time', endDate.toIso8601String())
        .order('time');
    return data.map((json) => WeatherHour.fromJson(json)).toList();
  }

  /// Get sync status for a spot.
  Future<Map<String, dynamic>?> getSyncStatus(String spotId) async {
    final data = await _client
        .from('weather_sync_status')
        .select()
        .eq('spot_id', spotId)
        .maybeSingle();
    return data;
  }

  /// Trigger backfill via Edge Function.
  Future<void> triggerBackfill(
    String spotId,
    String startDate,
    String endDate,
  ) async {
    await _client.functions.invoke(
      'fetch-weather',
      body: {
        'spot_id': spotId,
        'start_date': startDate,
        'end_date': endDate,
      },
    );
  }
}
