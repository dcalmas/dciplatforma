import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/services/homework_service.dart';
import 'package:lms_app/utils/snackbars.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';

class MarkCompleteButton extends ConsumerWidget with CourseMixin {
  const MarkCompleteButton({super.key, required this.course, required this.lesson});

  final Course course;
  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final bool isCompleted = isLessonCompleted(lesson, user, course.id);
    final IconData icon = isCompleted ? Icons.clear : Icons.done;
    final String buttonText = isCompleted ? 'unmark-complete' : 'mark-complete';

    return BottomAppBar(
      elevation: 0,
      color: Colors.transparent,
      child: Center(
        child: TextButton.icon(
          style: TextButton.styleFrom(backgroundColor: Colors.black38),
          icon: Icon(icon),
          label: Text(buttonText).tr(),
          onPressed: () async {
            // Вебтегідей: міндетті ДЗ тапсырылмай сабақты аяқтауға болмайды.
            if (!isCompleted &&
                lesson.homeworkRequired &&
                user != null &&
                !isAdminUser(user)) {
              final submissions = ref
                      .read(homeworkSubmissionsProvider(course.id))
                      .valueOrNull ??
                  const {};
              if (!HomeworkService.hasSubmittedHomework(
                  submissions[lesson.id])) {
                openSnackbar(context, 'homework_hint'.tr());
                return;
              }
            }
            final navigator = Navigator.of(context);
            await FirebaseService().updateLessonMarkComplete(user!, course, lesson);
            await ref.read(userDataProvider.notifier).getData();
            navigator.pop();
          },
        ),
      ),
    );
  }
}
