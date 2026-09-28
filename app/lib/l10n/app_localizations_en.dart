// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Windsurf Gliding Analytics';

  @override
  String get spotIstanbul => 'Istanbul (Mimarsinan)';

  @override
  String get spotCesme => 'Cesme (Alacati)';

  @override
  String get spotDahab => 'Dahab';

  @override
  String get spotStPetersburg => 'St. Petersburg';

  @override
  String get spotTbilisi => 'Tbilisi';

  @override
  String get spotDescIstanbul => 'Sea of Marmara. Northern wind \"Poyraz\".';

  @override
  String get spotDescCesme => 'Iconic spot. Strong thermal wind \"Meltemi\".';

  @override
  String get spotDescDahab =>
      'Red Sea. Stable steady wind along the mountains.';

  @override
  String get spotDescStPetersburg => 'Gulf of Finland, Sestroretsk / Dyuny.';

  @override
  String get spotDescTbilisi => 'Tbilisi reservoir. Gusty local wind.';

  @override
  String get analysisParams => 'Analysis Parameters';

  @override
  String get yearRange => 'Year Range';

  @override
  String get timeWindow => 'Time on Water (local)';

  @override
  String get windMetric => 'Wind Metric';

  @override
  String get avgWind => 'Average wind';

  @override
  String get gusts => 'Gusts';

  @override
  String get gustsHelp =>
      'Gusts feel closer to reality on the water, especially for gusty spots (Tbilisi).';

  @override
  String get minWindSpeed => 'Min. wind speed (kn)';

  @override
  String get minDuration => 'Min. continuous hours';

  @override
  String get minDensity => 'Min. wind density (%)';

  @override
  String get allowedDirections => 'Allowed wind directions';

  @override
  String get compareSpots => 'Compare Spots';

  @override
  String get compareWith => 'Compare with';

  @override
  String get kpiTotalDays => 'Total Gliding Days';

  @override
  String get kpiAvgPerYear => 'Avg Days / Year';

  @override
  String get kpiBestMonth => 'Best Month';

  @override
  String get kpiAvgWind => 'Avg Wind (gliding)';

  @override
  String get kpiNoData => 'No data';

  @override
  String kpiKnots(String value) {
    return '$value kn';
  }

  @override
  String kpiBestMonthValue(String month, String year, String days) {
    return '$month $year ($days d.)';
  }

  @override
  String get tabMonthly => 'Monthly';

  @override
  String get tabWeeklyHeatmap => 'Weekly Heatmap';

  @override
  String get tabWindRose => 'Wind Rose';

  @override
  String get tabHourlyHeatmap => 'Hourly Wind';

  @override
  String get tabSailRecs => 'Sail Recs';

  @override
  String get tabComparison => 'Comparison';

  @override
  String get tabRawData => 'Raw Data';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get monthFullJan => 'January';

  @override
  String get monthFullFeb => 'February';

  @override
  String get monthFullMar => 'March';

  @override
  String get monthFullApr => 'April';

  @override
  String get monthFullMay => 'May';

  @override
  String get monthFullJun => 'June';

  @override
  String get monthFullJul => 'July';

  @override
  String get monthFullAug => 'August';

  @override
  String get monthFullSep => 'September';

  @override
  String get monthFullOct => 'October';

  @override
  String get monthFullNov => 'November';

  @override
  String get monthFullDec => 'December';

  @override
  String chartMonthlyTitle(String start, String end) {
    return 'Avg Gliding Days by Month ($start–$end)';
  }

  @override
  String get chartMonthlyYAxis => 'Days';

  @override
  String get chartWeeklyTitle => 'Gliding Days Distribution by Week';

  @override
  String get chartWeeklyXAxis => 'Week of Year';

  @override
  String get chartWeeklyYAxis => 'Year';

  @override
  String get chartWeeklyHint =>
      'Dark areas = weeks with maximum wind density. Use for trip planning.';

  @override
  String chartWindRoseTitle(String spot, String startH, String endH) {
    return 'Wind Rose: $spot ($startH:00–$endH:00)';
  }

  @override
  String get chartWindRoseHint =>
      'Shows wind direction and speed distribution during the selected time window across all years.';

  @override
  String get chartHourlyTitle => 'Avg Wind Speed: Month x Hour';

  @override
  String get chartHourlyXAxis => 'Hour';

  @override
  String get chartHourlyYAxis => 'Month';

  @override
  String get chartHourlyHint =>
      'Helps identify peak wind hours in each month. Thermal wind (Alacati) typically strengthens by 14:00–17:00.';

  @override
  String get chartNoData => 'No data for selected directions.';

  @override
  String get chartCompareTitle => 'Comparison: Avg Gliding Days';

  @override
  String get sailRecsTitle => 'Sail Size Recommendations';

  @override
  String get sailRecsHint =>
      'Approximate, for a 75-80 kg rider on a freeride board.';

  @override
  String get sailMonth => 'Month';

  @override
  String get sailAvgWind => 'Avg Wind (kn)';

  @override
  String get sailRecommendation => 'Recommendation';

  @override
  String get sailLight => 'Light planing';

  @override
  String get sailComfort => 'Comfortable wind';

  @override
  String get sailStrong => 'Strong wind';

  @override
  String get sailStorm => 'Storm / extreme';

  @override
  String get sailNoPlaning => 'No planing (< 14 kn)';

  @override
  String get sailExtreme => '3.7 m² or less (extreme)';

  @override
  String get exportTitle => 'Data Export';

  @override
  String get exportDate => 'Date';

  @override
  String get exportMonth => 'Month';

  @override
  String get exportAvgWind => 'Avg Wind (kn)';

  @override
  String get exportMaxChain => 'Max Chain (h)';

  @override
  String get exportDensity => 'Density (%)';

  @override
  String get exportDownloadCsv => 'Download CSV';

  @override
  String get noGlidingDays => 'No gliding days for analysis.';

  @override
  String get loadError =>
      'Failed to load data. Check your internet connection or change the year range.';

  @override
  String get selectDirection => 'Select at least one wind direction.';

  @override
  String get authSignIn => 'Sign In';

  @override
  String authSignInWith(String provider) {
    return 'Sign in with $provider';
  }

  @override
  String get authSignOut => 'Sign Out';

  @override
  String get authForCustomSpots => 'Sign in to create custom spots';

  @override
  String get mySpotsTitle => 'My Spots';

  @override
  String get mySpotsAdd => 'Add Spot';

  @override
  String get mySpotsEmpty => 'No custom spots yet.';

  @override
  String get mySpotsLimitReached => 'Maximum 5 custom spots.';

  @override
  String get spotName => 'Spot Name';

  @override
  String get spotLatitude => 'Latitude';

  @override
  String get spotLongitude => 'Longitude';

  @override
  String get spotTimezone => 'Timezone';

  @override
  String get spotDefaultDirections => 'Default Directions';

  @override
  String get spotSave => 'Save';

  @override
  String get spotDelete => 'Delete';

  @override
  String get spotCancel => 'Cancel';

  @override
  String get rawDataTitle => 'Raw Hourly Data';

  @override
  String get rawDataDateRange => 'Date Range';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get russian => 'Russian';

  @override
  String get dataAttribution => 'Weather data by Open-Meteo.com';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get hours => 'h';
}
