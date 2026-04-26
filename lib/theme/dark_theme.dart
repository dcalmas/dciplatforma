import 'dart:io';
import 'package:flutter/material.dart';
import '../configs/app_config.dart';
import 'text_themes.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  primaryColor: AppConfig.appThemeColor,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: AppConfig.appThemeColor,
    primary: AppConfig.appThemeColor,
    secondary: AppConfig.appThemeColor,
  ),
  textTheme: Platform.isIOS ? textThemeiOS : textThemeDefault,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212), // Түнгі режимде AppBar қара болып қалғаны дұрыс
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  dividerTheme: DividerThemeData(color: Colors.blueGrey.shade900),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppConfig.appThemeColor,
      foregroundColor: Colors.white,
    ),
  ),
);
