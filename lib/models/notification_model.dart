import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  final String id, title, body;
  final DateTime recievedAt;
  bool? read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.recievedAt,
    this.read,
  });

  factory NotificationModel.fromRemoteMessage(RemoteMessage d) {
    return NotificationModel(
      id: d.messageId.toString(),
      title: d.notification?.title ?? d.data['title'] ?? '',
      recievedAt: DateTime.now(),
      // iOS-та data['description'] болмауы мүмкін, notification.body fallback ретінде
      body: d.data['description'] ?? d.notification?.body ?? '',
    );
  }

  factory NotificationModel.fromHive(dynamic d) {
    return NotificationModel(
      id: d['id'],
      title: d['title'],
      recievedAt: d['recieved_at'],
      body: d['description'],
      read: d['read'] ?? false,
    );
  }

  static Map<String, dynamic> getMap(NotificationModel d) {
    return {
      'id': d.id,
      'title': d.title,
      'description': d.body,
      'recieved_at': d.recievedAt,
      'read': d.read,
    };
  }
}
