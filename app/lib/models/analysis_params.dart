class AnalysisParams {
  final int startYear;
  final int endYear;
  final int startHour;
  final int endHour;
  final Set<String> allowedDirections;
  final double minWind;
  final bool useGusts;
  final int minDuration;
  final double minPct;

  const AnalysisParams({
    required this.startYear,
    required this.endYear,
    this.startHour = 10,
    this.endHour = 19,
    required this.allowedDirections,
    this.minWind = 14,
    this.useGusts = false,
    this.minDuration = 2,
    this.minPct = 70,
  });

  int get windowHours => (endHour - startHour) + 1;

  AnalysisParams copyWith({
    int? startYear,
    int? endYear,
    int? startHour,
    int? endHour,
    Set<String>? allowedDirections,
    double? minWind,
    bool? useGusts,
    int? minDuration,
    double? minPct,
  }) =>
      AnalysisParams(
        startYear: startYear ?? this.startYear,
        endYear: endYear ?? this.endYear,
        startHour: startHour ?? this.startHour,
        endHour: endHour ?? this.endHour,
        allowedDirections: allowedDirections ?? this.allowedDirections,
        minWind: minWind ?? this.minWind,
        useGusts: useGusts ?? this.useGusts,
        minDuration: minDuration ?? this.minDuration,
        minPct: minPct ?? this.minPct,
      );
}
