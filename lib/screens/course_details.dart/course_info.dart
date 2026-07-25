import 'package:easy_localization/easy_localization.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/screens/author_profie/author_profile.dart';
import 'package:lms_app/services/app_service.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';

class CourseInfo extends StatelessWidget {
  const CourseInfo({super.key, required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
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
                : Colors.indigo.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          GestureDetector(
            onTap: () => _onTapAuthor(context),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LineIcons.user, size: 20, color: primaryColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'created-by'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                      Text(
                        course.author.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(LineIcons.chevron_right, size: 18, color: Colors.grey[400]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Info Badges
          _buildInfoRow(
            context,
            icon: LineIcons.calendar_alt,
            title: 'last-updated-'.tr(args: [AppService.getDate(course.updatedAt ?? course.createdAt)]),
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: LineIcons.globe,
            title: 'language-'.tr(args: [course.courseMeta.language.toString()]),
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: LineIcons.clock,
            title: 'duration-'.tr(args: [course.courseMeta.duration.toString()]),
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: LineIcons.book_open,
            title: 'count-lesson'.tr(args: [course.lessonsCount.toString()]),
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[300] : const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  void _onTapAuthor(BuildContext context) async {
    final UserModel? author = await FirebaseService().getAuthorData(course.author.id);
    if (!context.mounted) return;
    if (author != null) {
      NextScreen.popup(context, AuthorProfile(user: author));
    } else {
      openSnackbar(context, 'Error on getting author profile');
    }
  }
}

