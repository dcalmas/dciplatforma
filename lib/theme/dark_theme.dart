import 'dart:io';
import 'package:flutter/material.dart';
import '../configs/app_config.dart';
import '../configs/font_config.dart';
import 'text_themes.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: fontFamily,
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
  scaffoldBackgroundColor: const Color(0xFF0F111A),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppConfig.appThemeColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E202C),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 0,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1E202C),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E202C),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E202C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppConfig.appThemeColor, width: 1.5),
    ),
  ),
);
