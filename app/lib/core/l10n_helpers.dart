import 'package:windsurf_analytics/l10n/app_localizations.dart';

String monthShort(AppLocalizations l10n, int month) => switch (month) {
      1 => l10n.monthJan,
      2 => l10n.monthFeb,
      3 => l10n.monthMar,
      4 => l10n.monthApr,
      5 => l10n.monthMay,
      6 => l10n.monthJun,
      7 => l10n.monthJul,
      8 => l10n.monthAug,
      9 => l10n.monthSep,
      10 => l10n.monthOct,
      11 => l10n.monthNov,
      12 => l10n.monthDec,
      _ => '',
    };

String monthFull(AppLocalizations l10n, int month) => switch (month) {
      1 => l10n.monthFullJan,
      2 => l10n.monthFullFeb,
      3 => l10n.monthFullMar,
      4 => l10n.monthFullApr,
      5 => l10n.monthFullMay,
      6 => l10n.monthFullJun,
      7 => l10n.monthFullJul,
      8 => l10n.monthFullAug,
      9 => l10n.monthFullSep,
      10 => l10n.monthFullOct,
      11 => l10n.monthFullNov,
      12 => l10n.monthFullDec,
      _ => '',
    };

/// Map preset spot ID → i18n name.
String spotLocalizedName(AppLocalizations l10n, String spotId, String fallback) =>
    switch (spotId) {
      '00000000-0000-4000-a000-000000000001' => l10n.spotIstanbul,
      '00000000-0000-4000-a000-000000000002' => l10n.spotCesme,
      '00000000-0000-4000-a000-000000000003' => l10n.spotDahab,
      '00000000-0000-4000-a000-000000000004' => l10n.spotStPetersburg,
      '00000000-0000-4000-a000-000000000005' => l10n.spotTbilisi,
      _ => fallback,
    };
