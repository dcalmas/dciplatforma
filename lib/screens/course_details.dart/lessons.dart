import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/ads/ad_manager.dart';
import 'package:lms_app/constants/app_constants.dart';
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
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final Lesson lesson = lessons[index];
            return ListTile(
                onTap: () => _onTap(context, lesson, course, user, ref),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                horizontalTitleGap: 10,
                title: Text(
                  lesson.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 18),
                ),
                subtitle: Text(lesson.contentType == 'document' ? 'document' : lesson.contentType).tr(),
                leading: Text(
                  '${index + 1}.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                trailing: _trailingIcon(lesson, user));
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
        openSnackbar(context, 'Пікір қалдыру үшін курсқа тіркеліңіз'.tr());
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

  Icon _trailingIcon(Lesson lesson, UserModel? user) {
    if (isLessonCompleted(lesson, user)) {
      return const Icon(Icons.check_box, color: Colors.orange);
    } else {
      if (lesson.contentType == 'video' || lesson.contentType == 'iframe') {
        return const Icon(FeatherIcons.playCircle);
      } else if (lesson.contentType == 'article') {
        return const Icon(LineIcons.stickyNote);
      } else if (lesson.contentType == 'document') {
        return const Icon(Icons.picture_as_pdf); // Қате түзетілді: LineIcons-тың орнына Icons қолданылды
      } else {
        return const Icon(LineIcons.lightbulb);
      }
    }
  }
}
