import 'package:flutter/material.dart';

class LanguageConfig {
  //Initial Language (Орысша негізгі)
  static const Locale startLocale = Locale('ru', 'RU');

  //Language if any error happens
  static const Locale fallbackLocale = Locale('ru', 'RU');

  // Languages
  static const Map<String, List<String>> languages = {
    //language_name : [language_code, country_code(Capital format)]
    "Русский": ['ru', 'RU'],
    "Қазақша": ['kk', 'KZ'],
    "English": ['en', 'US'],
  };

  // Don't edit this
  static List<Locale> supportedLocales = languages.values.map((e) => Locale(e.first, e.last)).toList();
}
