// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Windsurf Gliding Analytics';

  @override
  String get spotIstanbul => 'Стамбул (Мимарсинан)';

  @override
  String get spotCesme => 'Чешме (Алачати)';

  @override
  String get spotDahab => 'Дахаб';

  @override
  String get spotStPetersburg => 'Санкт-Петербург';

  @override
  String get spotTbilisi => 'Тбилиси';

  @override
  String get spotDescIstanbul => 'Мраморное море. Северный ветер «Пойраз».';

  @override
  String get spotDescCesme =>
      'Культовый спот. Сильный термический ветер «Мельтеми».';

  @override
  String get spotDescDahab =>
      'Красное море. Стабильный ровный ветер вдоль гор.';

  @override
  String get spotDescStPetersburg => 'Финский залив, Сестрорецк / Дюны.';

  @override
  String get spotDescTbilisi =>
      'Тбилисское водохранилище, порывистый локальный ветер.';

  @override
  String get analysisParams => 'Параметры анализа';

  @override
  String get yearRange => 'Диапазон лет';

  @override
  String get timeWindow => 'Время на воде (локальное)';

  @override
  String get windMetric => 'Метрика ветра';

  @override
  String get avgWind => 'Средний ветер';

  @override
  String get gusts => 'Порывы';

  @override
  String get gustsHelp =>
      'Порывы ближе к реальным ощущениям на воде, особенно для порывистых спотов (Тбилиси).';

  @override
  String get minWindSpeed => 'Мин. скорость ветра (уз.)';

  @override
  String get minDuration => 'Мин. непрерывность (часов)';

  @override
  String get minDensity => 'Мин. плотность ветра (%)';

  @override
  String get allowedDirections => 'Допустимые направления';

  @override
  String get compareSpots => 'Сравнение спотов';

  @override
  String get compareWith => 'Сравнить с';

  @override
  String get kpiTotalDays => 'Всего глиссирующих дней';

  @override
  String get kpiAvgPerYear => 'Дней / год (ср.)';

  @override
  String get kpiBestMonth => 'Лучший месяц';

  @override
  String get kpiAvgWind => 'Ср. ветер (глисс.)';

  @override
  String get kpiNoData => 'Нет данных';

  @override
  String kpiKnots(String value) {
    return '$value уз.';
  }

  @override
  String kpiBestMonthValue(String month, String year, String days) {
    return '$month $year г. ($days дн.)';
  }

  @override
  String get tabMonthly => 'По месяцам';

  @override
  String get tabWeeklyHeatmap => 'Тепловая карта';

  @override
  String get tabWindRose => 'Роза ветров';

  @override
  String get tabHourlyHeatmap => 'Ветер по часам';

  @override
  String get tabSailRecs => 'Рекомендации';

  @override
  String get tabComparison => 'Сравнение';

  @override
  String get tabRawData => 'Сырые данные';

  @override
  String get monthJan => 'Янв';

  @override
  String get monthFeb => 'Фев';

  @override
  String get monthMar => 'Мар';

  @override
  String get monthApr => 'Апр';

  @override
  String get monthMay => 'Май';

  @override
  String get monthJun => 'Июн';

  @override
  String get monthJul => 'Июл';

  @override
  String get monthAug => 'Авг';

  @override
  String get monthSep => 'Сен';

  @override
  String get monthOct => 'Окт';

  @override
  String get monthNov => 'Ноя';

  @override
  String get monthDec => 'Дек';

  @override
  String get monthFullJan => 'Январь';

  @override
  String get monthFullFeb => 'Февраль';

  @override
  String get monthFullMar => 'Март';

  @override
  String get monthFullApr => 'Апрель';

  @override
  String get monthFullMay => 'Май';

  @override
  String get monthFullJun => 'Июнь';

  @override
  String get monthFullJul => 'Июль';

  @override
  String get monthFullAug => 'Август';

  @override
  String get monthFullSep => 'Сентябрь';

  @override
  String get monthFullOct => 'Октябрь';

  @override
  String get monthFullNov => 'Ноябрь';

  @override
  String get monthFullDec => 'Декабрь';

  @override
  String chartMonthlyTitle(String start, String end) {
    return 'Среднее кол-во глиссирующих дней по месяцам ($start–$end)';
  }

  @override
  String get chartMonthlyYAxis => 'Дней';

  @override
  String get chartWeeklyTitle =>
      'Распределение глиссирующих дней по неделям года';

  @override
  String get chartWeeklyXAxis => 'Неделя года';

  @override
  String get chartWeeklyYAxis => 'Год';

  @override
  String get chartWeeklyHint =>
      'Тёмные области — недели с максимальной плотностью ветра. Используйте для планирования поездки.';

  @override
  String chartWindRoseTitle(String spot, String startH, String endH) {
    return 'Роза ветров: $spot ($startH:00–$endH:00)';
  }

  @override
  String get chartWindRoseHint =>
      'Показывает распределение направления и силы ветра в выбранном временном окне за все годы.';

  @override
  String get chartHourlyTitle => 'Средняя скорость ветра: месяц × час дня';

  @override
  String get chartHourlyXAxis => 'Час';

  @override
  String get chartHourlyYAxis => 'Месяц';

  @override
  String get chartHourlyHint =>
      'Помогает определить пиковые часы ветра в каждом месяце. Термический ветер (Алачати) обычно усиливается к 14:00–17:00.';

  @override
  String get chartNoData => 'Нет данных по выбранным направлениям.';

  @override
  String get chartCompareTitle => 'Сравнение: среднее кол-во глиссирующих дней';

  @override
  String get sailRecsTitle => 'Рекомендации по размеру паруса';

  @override
  String get sailRecsHint =>
      'Ориентировочно для райдера 75–80 кг на фрирайд-доске.';

  @override
  String get sailMonth => 'Месяц';

  @override
  String get sailAvgWind => 'Ср. ветер (уз.)';

  @override
  String get sailRecommendation => 'Рекомендация';

  @override
  String get sailLight => 'Лёгкий глиссинг';

  @override
  String get sailComfort => 'Комфортный ветер';

  @override
  String get sailStrong => 'Сильный ветер';

  @override
  String get sailStorm => 'Шторм / экстрим';

  @override
  String get sailNoPlaning => 'Нет глиссирования (< 14 уз.)';

  @override
  String get sailExtreme => '3.7 м² или меньше (экстрим)';

  @override
  String get exportTitle => 'Экспорт данных';

  @override
  String get exportDate => 'Дата';

  @override
  String get exportMonth => 'Месяц';

  @override
  String get exportAvgWind => 'Ср. ветер (уз.)';

  @override
  String get exportMaxChain => 'Макс. цепочка (ч)';

  @override
  String get exportDensity => 'Плотность (%)';

  @override
  String get exportDownloadCsv => 'Скачать CSV';

  @override
  String get noGlidingDays => 'Нет глиссирующих дней для анализа.';

  @override
  String get loadError =>
      'Не удалось загрузить данные. Проверьте подключение к интернету или измените диапазон лет.';

  @override
  String get selectDirection => 'Выберите хотя бы одно направление ветра.';

  @override
  String get authSignIn => 'Войти';

  @override
  String authSignInWith(String provider) {
    return 'Войти через $provider';
  }

  @override
  String get authSignOut => 'Выйти';

  @override
  String get authForCustomSpots => 'Войдите, чтобы создавать свои споты';

  @override
  String get mySpotsTitle => 'Мои споты';

  @override
  String get mySpotsAdd => 'Добавить спот';

  @override
  String get mySpotsEmpty => 'Нет пользовательских спотов.';

  @override
  String get mySpotsLimitReached => 'Максимум 5 пользовательских спотов.';

  @override
  String get spotName => 'Название';

  @override
  String get spotLatitude => 'Широта';

  @override
  String get spotLongitude => 'Долгота';

  @override
  String get spotTimezone => 'Часовой пояс';

  @override
  String get spotDefaultDirections => 'Направления по умолчанию';

  @override
  String get spotSave => 'Сохранить';

  @override
  String get spotDelete => 'Удалить';

  @override
  String get spotCancel => 'Отмена';

  @override
  String get rawDataTitle => 'Сырые почасовые данные';

  @override
  String get rawDataDateRange => 'Диапазон дат';

  @override
  String get language => 'Язык';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get dataAttribution => 'Данные о погоде: Open-Meteo.com';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '1 день',
      zero: '0 дней',
    );
    return '$_temp0';
  }

  @override
  String get hours => 'ч';
}
