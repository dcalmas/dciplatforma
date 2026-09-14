import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/constants/app_constants.dart';
import 'package:lms_app/screens/notifications/custom_notification_details.dart';
import 'package:lms_app/services/hive_service.dart';
import 'package:lms_app/services/sp_service.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/screens/notifications/notification_dialog.dart';
import 'package:lms_app/utils/snackbars.dart';
import '../core/app.dart';
import '../models/notification_model.dart';
import '../screens/notifications/notification_permisson_dialog.dart';

final nProvider = StateProvider<bool>((ref) => false);

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  bool _listenersRegistered = false;

  Future<void> updateBadgeCount() async {
    try {
      final int unreadCount = HiveService().getUnreadCount();
      await FlutterAppBadgeControl.updateBadgeCount(unreadCount)
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('FCM: Error updating badge count: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _localNotifications.initialize(
      settings: initializationSettings,
    );

    // Create high importance channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _localNotifications.show(
      id: message.messageId?.hashCode ?? message.hashCode,
      title: message.notification?.title ?? message.data['title'] ?? message.data['headline'] ?? 'Notification',
      body: message.notification?.body ?? message.data['description'] ?? message.data['body'] ?? message.data['text'] ?? '',
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<bool?> _checkPermisson() async {
    bool? accepted;
    await _fcm.getNotificationSettings().then((NotificationSettings settings) async {
      if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional) {
        accepted = true;
      } else {
        accepted = false;
      }
    });
    return accepted;
  }

  Future _subscribe() async {
    await _fcm.subscribeToTopic(notificationTopicForAll);
  }

  Future _unsubscribe() async {
    await _fcm.unsubscribeFromTopic(notificationTopicForAll);
  }

  Future checkNotificationSubscription(WidgetRef ref) async {
    final bool value = await SPService().getNotificationSubscription();
    if (value) {
      await _subscribe();
      ref.read(nProvider.notifier).update((state) => true);
    } else {
      await _unsubscribe();
      ref.read(nProvider.notifier).update((state) => false);
    }
  }

  void handleSubscription(context, bool newValue, WidgetRef ref) async {
    if (newValue) {
      final bool? accepted = await _checkPermisson();
      if (accepted != null && accepted) {
        ref.read(nProvider.notifier).update((state) => true);
        openSnackbar(context, 'notifications-enabled'.tr());
        await _subscribe();
        await SPService().setNotificationSubscription(newValue);
      } else {
        openNotificationPermissionDialog(context);
      }
    } else {
      ref.read(nProvider.notifier).update((state) => false);
      openSnackbar(context, 'notifications-disabled'.tr());
      await _unsubscribe();
      await SPService().setNotificationSubscription(newValue);
    }
  }

  Future _handleNotificationPermission() async {
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      // iOS foreground-та жүйе автоматты көрсетпейді — хабарламаны app өзі
      // _showLocalNotification арқылы көрсетеді (алert-payload-да қосарланбау үшін).
      // Android бұл опцияға әсер етпейді.
await _fcm.setForegroundNotificationPresentationOptions(
         alert: true,
         badge: true,
         sound: true,
       );

      if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('FCM: User granted permission');
        // Егер пайдаланушы баптаулардан өшірген болса (SP=false) — subscribe етпейміз.
        // Алғашқы іске қосылымда pref жоқ болса — автоматты түрде қосамыз.
        final bool hasPref = await SPService().hasNotificationSubscriptionPref();
        final bool saved = await SPService().getNotificationSubscription();
        if (!hasPref || saved) {
          await SPService().setNotificationSubscription(true);
          await _subscribe();
        }
        await _logToken();
      } else {
        debugPrint('FCM: User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('FCM: Error requesting permission: $e');
    }
  }

  Future _logToken() async {
    try {
      final token = await _fcm.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
    }
  }

  BuildContext? get _context => navigatorKey.currentContext;

  Future initFirebasePushNotification() async {
    try {
      if (_listenersRegistered) {
        debugPrint('FCM: Listeners already registered, skipping');
        return;
      }

      // Listeners бірінші регистрацияланады — badge/notification init
      // кезінде қандай да бір қате/hang болса да push жұмысы бұзылмайды.
      _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint('FCM onMessage: ${message.messageId}');
        debugPrint('FCM onMessage title: ${message.notification?.title}');
        try {
          await HiveService().saveNotificationData(message);
          await updateBadgeCount();
          await _showLocalNotification(message);
        } catch (e) {
          debugPrint('FCM: Error processing message: $e');
        }

        final ctx = _context;
        debugPrint('FCM: context available: ${ctx != null}, mounted: ${ctx?.mounted}');
        if (ctx != null && ctx.mounted) {
          final NotificationModel model = NotificationModel.fromRemoteMessage(message);
          // Диалогпен көрсетілген соң — оқылды деп белгілейміз,
          // келесі ашқанда қайта шықпау үшін.
          await HiveService().setNotificationRead(model);
          await updateBadgeCount();
          if (!ctx.mounted) return;
          _openNotificationDialog(ctx, model);
        }
      });

      _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        debugPrint('FCM onMessageOpenedApp: ${message.messageId}');
        await HiveService().saveNotificationData(message);
        await updateBadgeCount();
        final ctx = _context;
        if (ctx != null && ctx.mounted) {
          _navigateToDetailsScreen(ctx, message);
        }
      });

      _onTokenRefreshSub = _fcm.onTokenRefresh.listen((String token) {
        debugPrint('FCM Token refreshed: $token');
      });

      _listenersRegistered = true;
      debugPrint('FCM: Listeners registered successfully');

// iOS foreground presentation options: false — хабарламаны app өзі
      // _showLocalNotification арқылы көрсетеді, қосарланбау үшін.
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _initLocalNotifications();
      await _handleNotificationPermission();
      await updateBadgeCount();

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      debugPrint('FCM: initial message: $initialMessage');
      if (initialMessage != null) {
        await HiveService().saveNotificationData(initialMessage);
        await updateBadgeCount();
        final ctx = _context;
        if (ctx != null && ctx.mounted) {
          _navigateToDetailsScreen(ctx, initialMessage);
        }
      }
    } catch (e) {
      debugPrint('FCM: Error initializing push notifications: $e');
    }
  }

  void _openNotificationDialog(BuildContext context, NotificationModel notificationModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        notificationDialog(context, notificationModel);
      }
    });
  }

  _navigateToDetailsScreen(context, RemoteMessage message) async {
    final NotificationModel notification = NotificationModel.fromRemoteMessage(message);
    await HiveService().setNotificationRead(notification);
    await updateBadgeCount();
    NextScreen.normal(context, CustomNotificationDeatils(notificationModel: notification));
  }

  /// Апп ашылғанда оқылмаған хабарламаларды тексеріп,
  /// егер болса — экранға диалог шығарады.
  DateTime? _lastUnreadDialogShown;

  Future<void> checkUnreadNotificationsOnStart() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final ctx = _context;
      if (ctx == null || !ctx.mounted) return;

      final List<NotificationModel> unread = HiveService().getUnreadNotifications();
      if (unread.isEmpty) return;

      // Cold start / resume бірге шақырылса бір ғана диалог көрсетіледі
      if (_lastUnreadDialogShown != null &&
          DateTime.now().difference(_lastUnreadDialogShown!) < const Duration(seconds: 10)) {
        return;
      }
      _lastUnreadDialogShown = DateTime.now();

      final NotificationModel notification = unread.first;
      debugPrint('FCM: Showing unread notification on start: ${notification.id}');
      // Оқылмаған хабарламаны оқылды деп белгілейміз —
      // диалог тек бір рет, қайта ашқанда қайталанбауы үшін.
      // Хабарламалар тізімінде оқылған күйінде қалады.
      await HiveService().setNotificationRead(notification);
      await updateBadgeCount();
      if (!ctx.mounted) return;
      _openNotificationDialog(ctx, notification);
    } catch (e) {
      debugPrint('FCM: Error checking unread notifications on start: $e');
    }
  }

  void dispose() {
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();
    _onTokenRefreshSub?.cancel();
    _listenersRegistered = false;
  }
}
