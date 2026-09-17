import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/screens/article_lesson.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/screens/quiz_lesson/quiz_screen.dart';
import 'package:lms_app/screens/video_lesson.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/services/homework_service.dart';
import 'package:lms_app/utils/loading_widget.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/lesson.dart';
import '../../providers/user_data_provider.dart';
import '../../services/lesson_access_service.dart';

class Lessons extends ConsumerWidget with CourseMixin {
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
            final LessonBlocker? blocker = _getBlocker(ref, course, lesson, user);

            return GestureDetector(
              onTap: () => _onTap(context, lesson, course, user, ref),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: completed
                      ? Border.all(
                          color: Colors.green.withValues(alpha: 0.45),
                          width: 1.5)
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lesson.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (lesson.homeworkRequired) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                          alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'homework_badge'.tr(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _contentTypeIcon(
                                    lesson,
                                    isDarkMode
                                        ? Colors.grey[400]!
                                        : Colors.grey[500]!),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    _contentTypeLabel(lesson),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _trailingIcon(lesson, user, primaryColor, locked: blocker != null),
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

  /// Вебтегі getLessonBlocker: sequential_unlock + міндетті ДЗ.
  /// [watch] true болса build ішінде (watch), false болса callback ішінде (read).
  LessonBlocker? _getBlocker(
      WidgetRef ref, Course course, Lesson lesson, UserModel? user,
      {bool watch = true}) {
    if (user == null || isAdminUser(user)) return null;
    final flat = watch
        ? ref.watch(courseFlatLessonsProvider(course.id)).valueOrNull
        : ref.read(courseFlatLessonsProvider(course.id)).valueOrNull;
    if (flat == null || flat.isEmpty) return null;
    final submissions = watch
        ? ref.watch(homeworkSubmissionsProvider(course.id)).valueOrNull ??
            const {}
        : ref.read(homeworkSubmissionsProvider(course.id)).valueOrNull ??
            const {};
    return LessonAccessService.getLessonBlocker(
      course: course,
      flatLessons: flat,
      lessonId: lesson.id,
      user: user,
      submissions: submissions,
    );
  }

  void _onTap(BuildContext context, Lesson lesson, Course course,
      UserModel? user, WidgetRef ref) {
    if (user != null) {
      final bool enrolled =
          user.enrolledCourses?.contains(course.id) ?? false;
      // Платный курсқа тек админ жазған оқушы кіреді, тегін курс бәріне ашық.
      if (course.priceStatus != 'free' && !enrolled) {
        openSnackbar(context, 'enroll-to-view-curriculum'.tr());
        return;
      }
      final blocker = _getBlocker(ref, course, lesson, user, watch: false);
      if (blocker != null) {
        openSnackbar(context, blocker.isHomework
            ? 'homework_blocked'.tr()
            : 'sequential_blocked'.tr());
        return;
      }
      _openLesson(context, lesson);
    } else {
      NextScreen.normal(context, const LoginScreen());
    }
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    if (lesson.contentType == 'document' && lesson.attachmentUrl != null) {
      launchUrl(Uri.parse(lesson.attachmentUrl!),
          mode: LaunchMode.externalApplication);
    } else if ((lesson.contentType == 'video' && lesson.videoUrl != null) ||
        lesson.contentType == 'iframe') {
      NextScreen.iOS(context, VideoLesson(course: course, lesson: lesson));
    } else if (lesson.contentType == 'article') {
      NextScreen.iOS(context, ArticleLesson(lesson: lesson, course: course));
    } else {
      NextScreen.iOS(context, QuizLesson(course: course, lesson: lesson));
    }
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

  Widget _trailingIcon(Lesson lesson, UserModel? user, Color primaryColor,
      {bool locked = false}) {
    if (locked) {
      return const Icon(FeatherIcons.lock, color: Colors.grey, size: 22);
    }
    if (isLessonCompleted(lesson, user, course.id)) {
      return const Icon(Icons.check_circle_rounded,
          color: Colors.green, size: 22);
    } else {
      if (lesson.contentType == 'video' || lesson.contentType == 'iframe') {
        return Icon(FeatherIcons.playCircle, color: primaryColor, size: 22);
      } else if (lesson.contentType == 'article') {
        return Icon(LineIcons.stickyNote, color: primaryColor, size: 22);
      } else if (lesson.contentType == 'document') {
        return const Icon(Icons.picture_as_pdf,
            color: Colors.redAccent, size: 22);
      } else {
        return Icon(LineIcons.lightbulb, color: primaryColor, size: 22);
      }
    }
  }
}
