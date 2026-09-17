import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/screens/certificates/certificate_preview.dart';
import 'package:lms_app/services/certificate_service.dart';
import 'package:lms_app/services/gamification_service.dart';
import 'package:lms_app/services/homework_service.dart';
import 'package:lms_app/services/lesson_access_service.dart';
import 'package:lms_app/utils/next_screen.dart';
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
            final currentUser = user;
            if (currentUser == null) {
              if (context.mounted) openSnackbar(context, 'login-required'.tr());
              return;
            }
            // Вебтегідей: міндетті ДЗ тапсырылмай сабақты аяқтауға болмайды.
            if (!isCompleted &&
                lesson.homeworkRequired &&
                !isAdminUser(currentUser)) {
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
            try {
              final bool newlyCompleted = await FirebaseService()
                  .updateLessonMarkComplete(currentUser, course, lesson);
              await ref.read(userDataProvider.notifier).getData();
              if (!newlyCompleted) {
                if (context.mounted) Navigator.of(context).pop();
                return;
              }
              // Вебтегідей: жаңа аяқталған сабаққа XP.
              final gamification = GamificationService();
              await gamification.loadSettings();
              if (gamification.enabled) {
                await gamification.awardLessonXp(currentUser.id);
              }
              if (context.mounted) {
                await _handleCourseCompletion(context, ref, gamification);
              }
            } catch (e) {
              if (context.mounted) openSnackbar(context, 'error'.tr());
              return;
            }
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// Курс толық аяқталса: XP + badge + сертификат + құттықтау.
  Future<void> _handleCourseCompletion(BuildContext context, WidgetRef ref,
      GamificationService gamification) async {
    final currentUser = ref.read(userDataProvider);
    if (currentUser == null || !context.mounted) return;
    final freshUser = await FirebaseService().getUserData();
    if (freshUser == null) return;

    var flat =
        ref.read(courseFlatLessonsProvider(course.id)).valueOrNull ?? [];
    if (flat.isEmpty) {
      final service = FirebaseService();
      final sections = await service.getSections(course.id);
      final List<Lesson> all = [];
      await Future.wait(sections.map((s) async {
        try {
          all.addAll(await service.getLessons(course.id, s.id));
        } catch (_) {}
      }));
      all.sort((a, b) => a.order.compareTo(b.order));
      flat = all;
    }
    final completed = LessonAccessService.isCourseCompleted(
        course: course, flatLessons: flat, user: freshUser);
    if (!completed) return;

    final alreadyRewarded = (freshUser.rewardedCourses ?? [])
        .contains(course.id);
    if (!alreadyRewarded && gamification.enabled) {
      await gamification.awardCourseXp(currentUser.id, course.id);
    }

    CertificateInfo? cert;
    try {
      cert = await CertificateService()
          .mint(courseId: course.id, courseName: course.name, userName: currentUser.name);
    } catch (_) {}

    if (!context.mounted) return;
    _showCelebration(context, course, cert, showCertificate: cert != null);
  }

  void _showCelebration(BuildContext context, Course course,
      CertificateInfo? cert,
      {required bool showCertificate}) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor:
            dark ? const Color(0xFF1E202C) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 14),
              Text(
                'course-complete-congrats'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                course.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (showCertificate) ...[
                const SizedBox(height: 6),
                Text(
                  'certificate-earned'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: primaryColor),
                ),
              ],
              const SizedBox(height: 22),
              if (showCertificate && cert != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      NextScreen.iOS(context,
                          CertificatePreview(certificate: cert));
                    },
                    icon: const Icon(Icons.card_membership_rounded),
                    label: Text(
                      'view-certificate'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('later'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}