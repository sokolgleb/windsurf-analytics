import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/spot.dart';

class SpotsRepository {
  final SupabaseClient _client;

  SpotsRepository(this._client);

  Future<List<Spot>> getPresetSpots() async {
    final data = await _client
        .from('spots')
        .select()
        .eq('is_preset', true)
        .order('name');
    return data.map((json) => Spot.fromJson(json)).toList();
  }

  Future<List<Spot>> getUserSpots(String userId) async {
    final data = await _client
        .from('spots')
        .select()
        .eq('user_id', userId)
        .order('name');
    return data.map((json) => Spot.fromJson(json)).toList();
  }

  Future<List<Spot>> getAllAvailableSpots(String? userId) async {
    final presets = await getPresetSpots();
    if (userId == null) return presets;
    final userSpots = await getUserSpots(userId);
    return [...presets, ...userSpots];
  }

  Future<Spot> createSpot({
    required String userId,
    required String name,
    required double latitude,
    required double longitude,
    required String timezone,
    String? description,
    required List<String> defaultDirections,
  }) async {
    final data = await _client
        .from('spots')
        .insert({
          'user_id': userId,
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
          'description': description,
          'default_directions': defaultDirections,
          'is_preset': false,
        })
        .select()
        .single();
    return Spot.fromJson(data);
  }

  Future<void> updateSpot(Spot spot) async {
    await _client
        .from('spots')
        .update(spot.toJson())
        .eq('id', spot.id);
  }

  Future<void> deleteSpot(String spotId) async {
    await _client.from('spots').delete().eq('id', spotId);
  }
}
