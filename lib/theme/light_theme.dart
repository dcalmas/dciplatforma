import 'dart:io';
import 'package:flutter/material.dart';
import '../configs/app_config.dart';
import '../configs/font_config.dart';
import 'text_themes.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: fontFamily,
  primaryColor: AppConfig.appThemeColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppConfig.appThemeColor,
    primary: AppConfig.appThemeColor,
    secondary: AppConfig.appThemeColor,
  ),
  textTheme: Platform.isIOS ? textThemeiOS : textThemeDefault,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppConfig.appThemeColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: Colors.white,
  dividerTheme: DividerThemeData(color: Colors.blueGrey.shade100, thickness: 0.7),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppConfig.appThemeColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppConfig.appThemeColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 0,
  ),
  dialogTheme: DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8F9FE),
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
