import 'package:flutter/material.dart';

class LanguageConfig {
  //Initial Language (Орысша)
  static const Locale startLocale = Locale('ru');

  //Language if any error happens
  static const Locale fallbackLocale = Locale('ru');

  // Languages
  static const Map<String, List<String>> languages = {
    // Тек тіл кодын қалдырамыз, сонда файлдарды ru.json, kk.json деп іздейді
    "Русский": ['ru'],
    "Қазақша": ['kk'],
    "English": ['en'],
  };

  // Don't edit this
  static List<Locale> supportedLocales = languages.values.map((e) => Locale(e.first)).toList();
}
