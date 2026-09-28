class WeatherHour {
  final String spotId;
  final DateTime time;
  final double windSpeedKn;
  final double? windGustKn;
  final int windDirection;

  const WeatherHour({
    required this.spotId,
    required this.time,
    required this.windSpeedKn,
    this.windGustKn,
    required this.windDirection,
  });

  factory WeatherHour.fromJson(Map<String, dynamic> json) => WeatherHour(
        spotId: json['spot_id'] as String,
        time: DateTime.parse(json['time'] as String),
        windSpeedKn: (json['wind_speed_kn'] as num).toDouble(),
        windGustKn: json['wind_gust_kn'] != null
            ? (json['wind_gust_kn'] as num).toDouble()
            : null,
        windDirection: json['wind_direction'] as int,
      );
}
