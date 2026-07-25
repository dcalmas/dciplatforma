import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/ads/ad_manager.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/screens/article_lesson.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/screens/quiz_lesson/quiz_screen.dart';
import 'package:lms_app/screens/video_lesson.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/loading_widget.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/lesson.dart';
import '../../providers/user_data_provider.dart';

class Lessons extends ConsumerWidget with CourseMixin, UserMixin {
  const Lessons({super.key, required this.course, required this.sectionId});

  final Course course;
  final String sectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return FutureBuilder(
      future: FirebaseService().getLessons(course.id, sectionId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicatorWidget();
        }
        if (!snapshot.hasData) return const SizedBox.shrink();
        List<Lesson> lessons = snapshot.data;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final Lesson lesson = lessons[index];
            final bool completed = isLessonCompleted(lesson, user);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.indigo.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () => _onTap(context, lesson, course, user, ref),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                leading: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green.withValues(alpha: 0.12)
                        : primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: completed ? Colors.green : primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  lesson.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Text(
                  lesson.contentType == 'document' ? 'document' : lesson.contentType,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ).tr(),
                trailing: _trailingIcon(lesson, user, primaryColor),
              ),
            );
          },
        );
      },
    );
  }

  void _onTap(BuildContext context, Lesson lesson, Course course, UserModel? user, WidgetRef ref) {
    if (user != null) {
      bool enrolled = hasEnrolled(user, course);
      bool isPremium = course.priceStatus != 'free';
      bool isPremiumUser = UserMixin.isUserPremium(user);

      if (!isPremium || enrolled || isPremiumUser) {
        _openLesson(context, lesson, ref);
      } else {
        openSnackbar(context, 'subscribe-to-access-features'.tr());
      }
    } else {
      NextScreen.openBottomSheet(context, const LoginScreen());
    }
  }

  void _openLesson(BuildContext context, Lesson lesson, WidgetRef ref) {
    if (lesson.contentType == 'document' && lesson.attachmentUrl != null) {
      launchUrl(Uri.parse(lesson.attachmentUrl!), mode: LaunchMode.externalApplication);
    } else if ((lesson.contentType == 'video' && lesson.videoUrl != null) || lesson.contentType == 'iframe') {
      NextScreen.iOS(context, VideoLesson(course: course, lesson: lesson));
    } else if (lesson.contentType == 'article') {
      NextScreen.iOS(context, ArticleLesson(lesson: lesson, course: course));
    } else {
      NextScreen.popup(context, QuizLesson(course: course, lesson: lesson));
    }
    AdManager.initInterstitailAds(ref);
  }

  Widget _trailingIcon(Lesson lesson, UserModel? user, Color primaryColor) {
    if (isLessonCompleted(lesson, user)) {
      return const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22);
    } else {
      if (lesson.contentType == 'video' || lesson.contentType == 'iframe') {
        return Icon(LineIcons.play_circle, color: primaryColor, size: 20);
      } else if (lesson.contentType == 'article') {
        return Icon(LineIcons.stickyNote, color: primaryColor, size: 20);
      } else if (lesson.contentType == 'document') {
        return const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20);
      } else {
        return Icon(LineIcons.lightbulb, color: primaryColor, size: 20);
      }
    }
  }
}

