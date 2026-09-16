import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/components/html_body.dart';
import 'package:lms_app/models/course.dart';

class CourseDescription extends StatelessWidget {
  const CourseDescription({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Visibility(
      visible: course.courseMeta.description != null &&
          course.courseMeta.description!.isNotEmpty,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.06)
                : primaryColor.withValues(alpha: 0.1),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(FeatherIcons.fileText,
                      size: 18, color: primaryColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                  'course-details'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 16),
            HtmlBody(
              description: course.courseMeta.description ?? '',
              fontSize: 15,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}
