import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/services/homework_service.dart';

/// Веб-клиенттегі (lms_web) `src/utils/lessonAccess.js` логикасының
/// толық Dart көшірмесі: sequential unlock + homework gating біріктірілген.
class LessonAccessService {
  /// Вебтегі `isLessonComplete`: курс id НЕМЕСЕ slug кілті бойынша тексеріледі.
  static bool isLessonComplete(
      Course course, Lesson lesson, UserModel? user) {
    final completed = (user?.completedLessons ?? [])
        .map((e) => e.toString())
        .toSet();
    final keys = [course.id, course.slug];
    return keys
        .where((k) => k != null && k.isNotEmpty)
        .any((k) => completed.contains('${k}_${lesson.id}'));
  }

  /// Вебтегі `hasSubmittedHomework`.
  static bool hasSubmittedHomework(Map<String, dynamic>? submission) =>
      HomeworkService.hasSubmittedHomework(submission);

  /// Вебтегі `getLessonBlocker` дәл көшірмесі.
  ///
  /// Күрсетілген сабақты ашу/өтуге кедергі бар ма — сол кедергіні қайтарады.
  /// Кедергі жоқ болса null. Админ үшін әрқашан null.
  static LessonBlocker? getLessonBlocker({
    required Course course,
    required List<Lesson> flatLessons,
    required String lessonId,
    required UserModel? user,
    required Map<String, Map<String, dynamic>> submissions,
  }) {
    final index = flatLessons.indexWhere((l) => l.id == lessonId);
    if (index < 0) return LessonBlocker(reason: LessonBlockReason.missing, lessonId: lessonId);
    if (user?.role?.contains('admin') ?? false) return null;
    for (final lesson in flatLessons.sublist(0, index)) {
      if (course.sequentialUnlock && !isLessonComplete(course, lesson, user)) {
        return LessonBlocker(
            reason: LessonBlockReason.complete, lessonId: lesson.id);
      }
      if (lesson.homeworkRequired &&
          !hasSubmittedHomework(submissions[lesson.id])) {
        return LessonBlocker(
            reason: LessonBlockReason.homework, lessonId: lesson.id);
      }
    }
    return null;
  }

  /// Барлық сабақ вебтегідей «біткен» болып есептеле ме (сертификат үшін).
  static bool isCourseCompleted({
    required Course course,
    required List<Lesson> flatLessons,
    required UserModel? user,
  }) {
    if (flatLessons.isEmpty) return false;
    final completed = (user?.completedLessons ?? [])
        .map((e) => e.toString())
        .toSet();
    final keys = [course.id, course.slug].where((k) => k != null && k.isNotEmpty);
    return flatLessons.every((lesson) => keys.any(
        (k) => completed.contains('${k}_${lesson.id}')));
  }
}

enum LessonBlockReason { complete, homework, missing }

class LessonBlocker {
  const LessonBlocker({required this.reason, required this.lessonId});

  final LessonBlockReason reason;
  final String lessonId;

  bool get isSequential => reason == LessonBlockReason.complete;
  bool get isHomework => reason == LessonBlockReason.homework;
}