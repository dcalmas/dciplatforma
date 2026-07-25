import 'package:easy_localization/easy_localization.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_app/screens/notifications/custom_notification_tile.dart';
import 'package:lms_app/constants/app_constants.dart';
import 'package:lms_app/models/notification_model.dart';
import 'package:lms_app/screens/notifications/clear_notifications_dialog.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationList = Hive.box(notificationTag);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : primaryColor.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: Icon(LineIcons.chevron_left, size: 20, color: primaryColor),
          ),
        ),
        title: const Text('notifications').tr(),
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: notificationList.listenable(),
            builder: (context, value, child) {
              if (notificationList.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => openClearAllDialog(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_sweep_outlined, size: 20, color: Colors.redAccent),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: notificationList.listenable(),
        builder: (BuildContext context, dynamic value, Widget? child) {
          List items = notificationList.values.toList();
          List<NotificationModel> notifications =
              items.map((e) => NotificationModel.fromHive(e)).toList();
          notifications.sort((a, b) => b.recievedAt.compareTo(a.recievedAt));

          if (notifications.isEmpty) {
            return _buildEmptyState(context, isDarkMode, primaryColor);
          }

          final int unreadCount = notifications.where((n) => n.read != true).length;

          return Column(
            children: [
              if (unreadCount > 0)
                _buildCountBanner(context, unreadCount, isDarkMode, primaryColor, cardBgColor),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (BuildContext context, int index) {
                    final NotificationModel notification = notifications[index];
                    return CustomNotificationTile(notificationModel: notification);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountBanner(
    BuildContext context,
    int unreadCount,
    bool isDarkMode,
    Color primaryColor,
    Color cardBgColor,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.12),
            primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(LineIcons.bell, size: 16, color: primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '$unreadCount ${'unread-notifications'.tr()}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LineIcons.bell_slash,
                size: 44,
                color: primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'no-notification'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'no-notification-subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
