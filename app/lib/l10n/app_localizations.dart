import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Windsurf Gliding Analytics'**
  String get appTitle;

  /// No description provided for @spotIstanbul.
  ///
  /// In en, this message translates to:
  /// **'Istanbul (Mimarsinan)'**
  String get spotIstanbul;

  /// No description provided for @spotCesme.
  ///
  /// In en, this message translates to:
  /// **'Cesme (Alacati)'**
  String get spotCesme;

  /// No description provided for @spotDahab.
  ///
  /// In en, this message translates to:
  /// **'Dahab'**
  String get spotDahab;

  /// No description provided for @spotStPetersburg.
  ///
  /// In en, this message translates to:
  /// **'St. Petersburg'**
  String get spotStPetersburg;

  /// No description provided for @spotTbilisi.
  ///
  /// In en, this message translates to:
  /// **'Tbilisi'**
  String get spotTbilisi;

  /// No description provided for @spotDescIstanbul.
  ///
  /// In en, this message translates to:
  /// **'Sea of Marmara. Northern wind \"Poyraz\".'**
  String get spotDescIstanbul;

  /// No description provided for @spotDescCesme.
  ///
  /// In en, this message translates to:
  /// **'Iconic spot. Strong thermal wind \"Meltemi\".'**
  String get spotDescCesme;

  /// No description provided for @spotDescDahab.
  ///
  /// In en, this message translates to:
  /// **'Red Sea. Stable steady wind along the mountains.'**
  String get spotDescDahab;

  /// No description provided for @spotDescStPetersburg.
  ///
  /// In en, this message translates to:
  /// **'Gulf of Finland, Sestroretsk / Dyuny.'**
  String get spotDescStPetersburg;

  /// No description provided for @spotDescTbilisi.
  ///
  /// In en, this message translates to:
  /// **'Tbilisi reservoir. Gusty local wind.'**
  String get spotDescTbilisi;

  /// No description provided for @analysisParams.
  ///
  /// In en, this message translates to:
  /// **'Analysis Parameters'**
  String get analysisParams;

  /// No description provided for @yearRange.
  ///
  /// In en, this message translates to:
  /// **'Year Range'**
  String get yearRange;

  /// No description provided for @timeWindow.
  ///
  /// In en, this message translates to:
  /// **'Time on Water (local)'**
  String get timeWindow;

  /// No description provided for @windMetric.
  ///
  /// In en, this message translates to:
  /// **'Wind Metric'**
  String get windMetric;

  /// No description provided for @avgWind.
  ///
  /// In en, this message translates to:
  /// **'Average wind'**
  String get avgWind;

  /// No description provided for @gusts.
  ///
  /// In en, this message translates to:
  /// **'Gusts'**
  String get gusts;

  /// No description provided for @gustsHelp.
  ///
  /// In en, this message translates to:
  /// **'Gusts feel closer to reality on the water, especially for gusty spots (Tbilisi).'**
  String get gustsHelp;

  /// No description provided for @minWindSpeed.
  ///
  /// In en, this message translates to:
  /// **'Min. wind speed (kn)'**
  String get minWindSpeed;

  /// No description provided for @minDuration.
  ///
  /// In en, this message translates to:
  /// **'Min. continuous hours'**
  String get minDuration;

  /// No description provided for @minDensity.
  ///
  /// In en, this message translates to:
  /// **'Min. wind density (%)'**
  String get minDensity;

  /// No description provided for @allowedDirections.
  ///
  /// In en, this message translates to:
  /// **'Allowed wind directions'**
  String get allowedDirections;

  /// No description provided for @compareSpots.
  ///
  /// In en, this message translates to:
  /// **'Compare Spots'**
  String get compareSpots;

  /// No description provided for @compareWith.
  ///
  /// In en, this message translates to:
  /// **'Compare with'**
  String get compareWith;

  /// No description provided for @kpiTotalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Gliding Days'**
  String get kpiTotalDays;

  /// No description provided for @kpiAvgPerYear.
  ///
  /// In en, this message translates to:
  /// **'Avg Days / Year'**
  String get kpiAvgPerYear;

  /// No description provided for @kpiBestMonth.
  ///
  /// In en, this message translates to:
  /// **'Best Month'**
  String get kpiBestMonth;

  /// No description provided for @kpiAvgWind.
  ///
  /// In en, this message translates to:
  /// **'Avg Wind (gliding)'**
  String get kpiAvgWind;

  /// No description provided for @kpiNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get kpiNoData;

  /// No description provided for @kpiKnots.
  ///
  /// In en, this message translates to:
  /// **'{value} kn'**
  String kpiKnots(String value);

  /// No description provided for @kpiBestMonthValue.
  ///
  /// In en, this message translates to:
  /// **'{month} {year} ({days} d.)'**
  String kpiBestMonthValue(String month, String year, String days);

  /// No description provided for @tabMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get tabMonthly;

  /// No description provided for @tabWeeklyHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Weekly Heatmap'**
  String get tabWeeklyHeatmap;

  /// No description provided for @tabWindRose.
  ///
  /// In en, this message translates to:
  /// **'Wind Rose'**
  String get tabWindRose;

  /// No description provided for @tabHourlyHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Hourly Wind'**
  String get tabHourlyHeatmap;

  /// No description provided for @tabSailRecs.
  ///
  /// In en, this message translates to:
  /// **'Sail Recs'**
  String get tabSailRecs;

  /// No description provided for @tabComparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get tabComparison;

  /// No description provided for @tabRawData.
  ///
  /// In en, this message translates to:
  /// **'Raw Data'**
  String get tabRawData;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @monthFullJan.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthFullJan;

  /// No description provided for @monthFullFeb.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFullFeb;

  /// No description provided for @monthFullMar.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthFullMar;

  /// No description provided for @monthFullApr.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthFullApr;

  /// No description provided for @monthFullMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthFullMay;

  /// No description provided for @monthFullJun.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthFullJun;

  /// No description provided for @monthFullJul.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthFullJul;

  /// No description provided for @monthFullAug.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthFullAug;

  /// No description provided for @monthFullSep.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthFullSep;

  /// No description provided for @monthFullOct.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthFullOct;

  /// No description provided for @monthFullNov.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthFullNov;

  /// No description provided for @monthFullDec.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthFullDec;

  /// No description provided for @chartMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Avg Gliding Days by Month ({start}–{end})'**
  String chartMonthlyTitle(String start, String end);

  /// No description provided for @chartMonthlyYAxis.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get chartMonthlyYAxis;

  /// No description provided for @chartWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Gliding Days Distribution by Week'**
  String get chartWeeklyTitle;

  /// No description provided for @chartWeeklyXAxis.
  ///
  /// In en, this message translates to:
  /// **'Week of Year'**
  String get chartWeeklyXAxis;

  /// No description provided for @chartWeeklyYAxis.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get chartWeeklyYAxis;

  /// No description provided for @chartWeeklyHint.
  ///
  /// In en, this message translates to:
  /// **'Dark areas = weeks with maximum wind density. Use for trip planning.'**
  String get chartWeeklyHint;

  /// No description provided for @chartWindRoseTitle.
  ///
  /// In en, this message translates to:
  /// **'Wind Rose: {spot} ({startH}:00–{endH}:00)'**
  String chartWindRoseTitle(String spot, String startH, String endH);

  /// No description provided for @chartWindRoseHint.
  ///
  /// In en, this message translates to:
  /// **'Shows wind direction and speed distribution during the selected time window across all years.'**
  String get chartWindRoseHint;

  /// No description provided for @chartHourlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Avg Wind Speed: Month x Hour'**
  String get chartHourlyTitle;

  /// No description provided for @chartHourlyXAxis.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get chartHourlyXAxis;

  /// No description provided for @chartHourlyYAxis.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get chartHourlyYAxis;

  /// No description provided for @chartHourlyHint.
  ///
  /// In en, this message translates to:
  /// **'Helps identify peak wind hours in each month. Thermal wind (Alacati) typically strengthens by 14:00–17:00.'**
  String get chartHourlyHint;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for selected directions.'**
  String get chartNoData;

  /// No description provided for @chartCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Comparison: Avg Gliding Days'**
  String get chartCompareTitle;

  /// No description provided for @sailRecsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sail Size Recommendations'**
  String get sailRecsTitle;

  /// No description provided for @sailRecsHint.
  ///
  /// In en, this message translates to:
  /// **'Approximate, for a 75-80 kg rider on a freeride board.'**
  String get sailRecsHint;

  /// No description provided for @sailMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get sailMonth;

  /// No description provided for @sailAvgWind.
  ///
  /// In en, this message translates to:
  /// **'Avg Wind (kn)'**
  String get sailAvgWind;

  /// No description provided for @sailRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get sailRecommendation;

  /// No description provided for @sailLight.
  ///
  /// In en, this message translates to:
  /// **'Light planing'**
  String get sailLight;

  /// No description provided for @sailComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfortable wind'**
  String get sailComfort;

  /// No description provided for @sailStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong wind'**
  String get sailStrong;

  /// No description provided for @sailStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm / extreme'**
  String get sailStorm;

  /// No description provided for @sailNoPlaning.
  ///
  /// In en, this message translates to:
  /// **'No planing (< 14 kn)'**
  String get sailNoPlaning;

  /// No description provided for @sailExtreme.
  ///
  /// In en, this message translates to:
  /// **'3.7 m² or less (extreme)'**
  String get sailExtreme;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get exportTitle;

  /// No description provided for @exportDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get exportDate;

  /// No description provided for @exportMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get exportMonth;

  /// No description provided for @exportAvgWind.
  ///
  /// In en, this message translates to:
  /// **'Avg Wind (kn)'**
  String get exportAvgWind;

  /// No description provided for @exportMaxChain.
  ///
  /// In en, this message translates to:
  /// **'Max Chain (h)'**
  String get exportMaxChain;

  /// No description provided for @exportDensity.
  ///
  /// In en, this message translates to:
  /// **'Density (%)'**
  String get exportDensity;

  /// No description provided for @exportDownloadCsv.
  ///
  /// In en, this message translates to:
  /// **'Download CSV'**
  String get exportDownloadCsv;

  /// No description provided for @noGlidingDays.
  ///
  /// In en, this message translates to:
  /// **'No gliding days for analysis.'**
  String get noGlidingDays;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data. Check your internet connection or change the year range.'**
  String get loadError;

  /// No description provided for @selectDirection.
  ///
  /// In en, this message translates to:
  /// **'Select at least one wind direction.'**
  String get selectDirection;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {provider}'**
  String authSignInWith(String provider);

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get authSignOut;

  /// No description provided for @authForCustomSpots.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create custom spots'**
  String get authForCustomSpots;

  /// No description provided for @mySpotsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Spots'**
  String get mySpotsTitle;

  /// No description provided for @mySpotsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Spot'**
  String get mySpotsAdd;

  /// No description provided for @mySpotsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No custom spots yet.'**
  String get mySpotsEmpty;

  /// No description provided for @mySpotsLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 custom spots.'**
  String get mySpotsLimitReached;

  /// No description provided for @spotName.
  ///
  /// In en, this message translates to:
  /// **'Spot Name'**
  String get spotName;

  /// No description provided for @spotLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get spotLatitude;

  /// No description provided for @spotLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get spotLongitude;

  /// No description provided for @spotTimezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get spotTimezone;

  /// No description provided for @spotDefaultDirections.
  ///
  /// In en, this message translates to:
  /// **'Default Directions'**
  String get spotDefaultDirections;

  /// No description provided for @spotSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get spotSave;

  /// No description provided for @spotDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get spotDelete;

  /// No description provided for @spotCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get spotCancel;

  /// No description provided for @rawDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Raw Hourly Data'**
  String get rawDataTitle;

  /// No description provided for @rawDataDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get rawDataDateRange;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @dataAttribution.
  ///
  /// In en, this message translates to:
  /// **'Weather data by Open-Meteo.com'**
  String get dataAttribution;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String days(int count);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hours;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
