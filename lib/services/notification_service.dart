import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<String>? _onTokenRefreshSub;
  bool _listenersRegistered = false;

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
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: User granted permission');
        await SPService().setNotificationSubscription(true);
        await _subscribe();
        await _logToken();
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('FCM: User granted provisional permission');
        await SPService().setNotificationSubscription(true);
        await _subscribe();
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

      await _handleNotificationPermission();

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      debugPrint('FCM: initial message: $initialMessage');
      if (initialMessage != null) {
        await HiveService().saveNotificationData(initialMessage);
        final ctx = _context;
        if (ctx != null && ctx.mounted) {
          _navigateToDetailsScreen(ctx, initialMessage);
        }
      }

      _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint('FCM onMessage: ${message.messageId}');
        debugPrint('FCM onMessage title: ${message.notification?.title}');
        await HiveService().saveNotificationData(message);
        final ctx = _context;
        debugPrint('FCM: context available: ${ctx != null}, mounted: ${ctx?.mounted}');
        if (ctx != null && ctx.mounted) {
          _openNotificationDialog(ctx, message);
        }
      });

      _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        debugPrint('FCM onMessageOpenedApp: ${message.messageId}');
        await HiveService().saveNotificationData(message);
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
    } catch (e) {
      debugPrint('FCM: Error initializing push notifications: $e');
    }
  }

  void _openNotificationDialog(context, RemoteMessage message) {
    final NotificationModel notificationModel = NotificationModel.fromRemoteMessage(message);
    notificationDialog(context, notificationModel);
  }

  _navigateToDetailsScreen(context, RemoteMessage message) async {
    final NotificationModel notification = NotificationModel.fromRemoteMessage(message);
    HiveService().setNotificationRead(notification);
    NextScreen.normal(context, CustomNotificationDeatils(notificationModel: notification));
  }

  void dispose() {
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();
    _onTokenRefreshSub?.cancel();
    _listenersRegistered = false;
  }
}
