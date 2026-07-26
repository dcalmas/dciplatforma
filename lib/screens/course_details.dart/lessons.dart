import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
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
            final bool completed = isLessonCompleted(lesson, user, course.id);

            return GestureDetector(
              onTap: () => _onTap(context, lesson, course, user, ref),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: completed
                      ? Border.all(color: Colors.green.withValues(alpha: 0.45), width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
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
                            fontSize: 15,
                            color: completed ? Colors.green : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _contentTypeIcon(lesson, isDarkMode ? Colors.grey[400]! : Colors.grey[500]!),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    _contentTypeLabel(lesson),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                                    ),
                                  ).tr(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _trailingIcon(lesson, user, primaryColor),
                    ],
                  ),
                ),
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

  String _contentTypeLabel(Lesson lesson) {
    switch (lesson.contentType) {
      case 'video':
        return 'Video';
      case 'article':
        return 'Article';
      case 'document':
        return 'Document';
      case 'iframe':
        return 'Video';
      default:
        return 'Quiz';
    }
  }

  Widget _contentTypeIcon(Lesson lesson, Color color) {
    switch (lesson.contentType) {
      case 'video':
      case 'iframe':
        return Icon(FeatherIcons.playCircle, size: 14, color: color);
      case 'article':
        return Icon(LineIcons.stickyNote, size: 14, color: color);
      case 'document':
        return Icon(Icons.picture_as_pdf_rounded, size: 14, color: color);
      default:
        return Icon(LineIcons.lightbulb, size: 14, color: color);
    }
  }

  Widget _trailingIcon(Lesson lesson, UserModel? user, Color primaryColor) {
    if (isLessonCompleted(lesson, user, course.id)) {
      return const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22);
    } else {
      if (lesson.contentType == 'video' || lesson.contentType == 'iframe') {
        return Icon(FeatherIcons.playCircle, color: primaryColor, size: 22);
      } else if (lesson.contentType == 'article') {
        return Icon(LineIcons.stickyNote, color: primaryColor, size: 22);
      } else if (lesson.contentType == 'document') {
        return const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 22);
      } else {
        return Icon(LineIcons.lightbulb, color: primaryColor, size: 22);
      }
    }
  }
}
