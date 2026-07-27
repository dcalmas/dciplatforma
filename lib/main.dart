import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/firebase_options.dart';
import 'package:lms_app/services/app_service.dart';
import 'package:lms_app/services/hive_service.dart'; 
import 'core/app.dart';
import 'configs/language_config.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  debugPrint('onBackgroundMessage: ${message.messageId}');
  // iOS-та background isolate бөлек жұмыс істейді — Firebase мен Hive қайта инициализацияланады
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveService.initHive();
  await HiveService().saveNotificationData(message);
}

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  await EasyLocalization.ensureInitialized();
  await HiveService.initHive();
  AppService.svgPrecacheImage();
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: LanguageConfig.supportedLocales,
        path: 'assets/translations',
        fallbackLocale: LanguageConfig.fallbackLocale,
        startLocale: LanguageConfig.startLocale,
        child: const MyApp(),
      ),
    ),
  );
}
