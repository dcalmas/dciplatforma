import 'dart:io';
import 'package:flutter/material.dart';
import '../configs/app_config.dart';
import 'text_themes.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
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
    ),
  ),
);
