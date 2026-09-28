import 'package:flutter/material.dart';

class AppTheme {
  static const _teal = Color(0xFF008080);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _teal,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _teal,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      );
}
