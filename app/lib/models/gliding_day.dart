class GlidingDay {
  final DateTime date;
  final int year;
  final int month;
  final int isoWeek;
  final bool isGliding;
  final int maxChain;
  final double densityPct;
  final double avgWind;

  const GlidingDay({
    required this.date,
    required this.year,
    required this.month,
    required this.isoWeek,
    required this.isGliding,
    required this.maxChain,
    required this.densityPct,
    required this.avgWind,
  });
}
