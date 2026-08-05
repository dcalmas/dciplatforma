import 'dart:io';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/configs/app_config.dart';
import 'package:lms_app/models/course.dart';
import 'package:share_plus/share_plus.dart';

class CourseShareButton extends StatelessWidget {
  const CourseShareButton({super.key, required this.course, this.compact = false});

  final Course course;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final icon = Icon(LineIcons.share, size: 20, color: iconColor);

    if (compact) {
      return GestureDetector(
        onTap: _handleShare,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: icon,
        ),
      );
    }

    return IconButton(onPressed: _handleShare, icon: icon);
  }

  void _handleShare() {
    final String shareTextAndroid =
        "${course.name}\nExplore this course on ${AppConfig.appName} App: https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}";
    final String shareTextiOS =
        "${course.name}\nExplore this course on ${AppConfig.appName} App: https://play.google.com/store/apps/details?id=${AppConfig.iosAppID}";
    final String shareText = Platform.isAndroid ? shareTextAndroid : shareTextiOS;
    Share.share(shareText);
  }
}
