class Spot {
  final String id;
  final String? userId;
  final String name;
  final double latitude;
  final double longitude;
  final String timezone;
  final String? description;
  final List<String> defaultDirections;
  final bool isPreset;

  const Spot({
    required this.id,
    this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.description,
    required this.defaultDirections,
    required this.isPreset,
  });

  factory Spot.fromJson(Map<String, dynamic> json) => Spot(
        id: json['id'] as String,
        userId: json['user_id'] as String?,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        timezone: json['timezone'] as String,
        description: json['description'] as String?,
        defaultDirections: (json['default_directions'] as List<dynamic>)
            .cast<String>(),
        isPreset: json['is_preset'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'timezone': timezone,
        'description': description,
        'default_directions': defaultDirections,
        'is_preset': isPreset,
      };
}
