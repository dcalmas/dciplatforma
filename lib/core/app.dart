import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_config.dart';
import 'package:lms_app/screens/splash.dart';
import 'package:lms_app/services/notification_service.dart';
import 'package:lms_app/theme/dark_theme.dart';
import 'package:lms_app/theme/light_theme.dart';
import 'package:lms_app/theme/theme_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver firebaseObserver =  FirebaseAnalyticsObserver(analytics: firebaseAnalytics);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      await NotificationService().initFirebasePushNotification();
      // nProvider-ды SP-мен синхрондау + topic күйін қолдану
      await NotificationService().checkNotificationSubscription(ref);
      // Cold start-та оқылмаған хабарламаларды экранға шығару
      await NotificationService().checkUnreadNotificationsOnStart();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Апп фоннан қайта ашылғанда оқылмаған хабарламаларды тексереміз
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed - checking unread notifications');
      Future.microtask(() => NotificationService().checkUnreadNotificationsOnStart());
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeRef = ref.watch(themeProvider);
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      navigatorObservers: [firebaseObserver],
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      themeMode: themeRef.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const SplashScreen(),
    );
  }
}
