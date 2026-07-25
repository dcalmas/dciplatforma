import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/services/hive_service.dart';
import 'package:lms_app/utils/string_extension.dart';
import '../../models/notification_model.dart';
import '../../utils/next_screen.dart';
import 'custom_notification_details.dart';

class CustomNotificationTile extends StatefulWidget {
  const CustomNotificationTile({super.key, required this.notificationModel});

  final NotificationModel notificationModel;

  @override
  State<CustomNotificationTile> createState() => _CustomNotificationTileState();
}

class _CustomNotificationTileState extends State<CustomNotificationTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final bool isRead = widget.notificationModel.read ?? false;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) async {
          setState(() => _scale = 1.0);
          if (widget.notificationModel.read == false) {
            await HiveService().setNotificationRead(widget.notificationModel);
          }
          if (!context.mounted) return;
          NextScreen.openBottomSheet(
            context,
            CustomNotificationDeatils(notificationModel: widget.notificationModel),
          );
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isRead
                    ? Colors.transparent
                    : primaryColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : primaryColor.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconBadge(isRead, primaryColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.notificationModel.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 15,
                                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.notificationModel.body.toNormalText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(FeatherIcons.clock, size: 13, color: Colors.grey[400]),
                            const SizedBox(width: 6),
                            Text(
                              _getDate(widget.notificationModel),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await HiveService().deleteNotificationData(widget.notificationModel.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(FeatherIcons.x, size: 14, color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildIconBadge(bool isRead, Color primaryColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isRead
            ? Colors.grey.withValues(alpha: 0.12)
            : primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        FeatherIcons.bell,
        size: 20,
        color: isRead ? Colors.grey : primaryColor,
      ),
    );
  }

  static String _getDate(NotificationModel notificationModel) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(notificationModel.recievedAt);
  }
}
