import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/providers/user_data_provider.dart';
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

class HomeworkTaskItem {
  final Course course;
  final Lesson lesson;
  final Map<String, dynamic>? submission;
  HomeworkTaskItem(
      {required this.course, required this.lesson, this.submission});
}

final homeworkTasksProvider =
    FutureProvider<List<HomeworkTaskItem>>((ref) async {
  final user = ref.watch(userDataProvider);
  if (user == null) return [];
  final service = FirebaseService();
  final List<Course> courses = await service.getAllCourses();
  final enrolledIds = user.enrolledCourses?.map((e) => e.toString()).toSet() ?? {};
  final enrolled =
      courses.where((c) => enrolledIds.contains(c.id)).toList();
  final List<HomeworkTaskItem> tasks = [];

  await Future.wait(enrolled.map((course) async {
    try {
      final sections = await service.getSections(course.id);
      Map<String, Map<String, dynamic>> submissions = {};
      try {
        submissions =
            await HomeworkService().fetchCourseSubmissions(course.id);
      } catch (e) {
        debugPrint('homework submissions load failed: $e');
      }
      await Future.wait(sections.map((section) async {
        try {
          final lessons = await service.getLessons(course.id, section.id);
          for (final lesson in lessons) {
            if (lesson.hasHomework) {
              tasks.add(HomeworkTaskItem(
                course: course,
                lesson: lesson,
                submission: submissions[lesson.id],
              ));
            }
          }
        } catch (e) {
          debugPrint('homework lessons load failed: $e');
        }
      }));
    } catch (e) {
      debugPrint('homework sections load failed: $e');
    }
  }));

  tasks.sort((a, b) {
    final comp = a.course.name.compareTo(b.course.name);
    if (comp != 0) return comp;
    return a.lesson.order.compareTo(b.lesson.order);
  });
  return tasks;
});

class AssignmentsTab extends ConsumerWidget {
  const AssignmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(homeworkTasksProvider);
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor =
        isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(FeatherIcons.chevronLeft),
        ),
        title: const Text('assignments').tr(),
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => ref.invalidate(homeworkTasksProvider),
        child: tasksState.when(
          loading: () => const Center(child: LoadingIndicatorWidget()),
          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.35),
              Center(child: Text('error: $error')),
            ],
          ),
          data: (tasks) {
            if (user == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                      child: Icon(FeatherIcons.user,
                          size: 64, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => NextScreen.normal(
                          context, const LoginScreen(popUpScreen: true)),
                      child: const Text('login').tr(),
                    ),
                  ),
                ],
              );
            }
            if (tasks.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Icon(FeatherIcons.checkSquare,
                        size: 64, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'homework_empty_list'.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = tasks[index];
                final course = item.course;
                final lesson = item.lesson;
                final submitted = HomeworkService.hasSubmittedHomework(
                    item.submission);
                final enrolled =
                    user.enrolledCourses?.contains(course.id) ?? false;
                final hasAccess =
                    course.priceStatus == 'free' || enrolled;

                return Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(FeatherIcons.fileText,
                          color: primaryColor, size: 22),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lesson.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (lesson.homeworkRequired) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      primaryColor.withValues(alpha: 0.12),
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
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _StatusLine(
                          submission: item.submission,
                          submitted: submitted,
                          isDarkMode: isDarkMode),
                    ),
                    trailing: Icon(
                      !hasAccess
                          ? FeatherIcons.lock
                          : submitted
                              ? Icons.check_circle_rounded
                              : FeatherIcons.chevronRight,
                      color: submitted
                          ? Colors.green
                          : (isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[400]),
                      size: 22,
                    ),
                    onTap: () {
                      if (!hasAccess) {
                        openSnackbar(context,
                            'enroll-to-view-curriculum'.tr());
                        return;
                      }
                      _openLesson(context, course, lesson);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, Course course, Lesson lesson) {
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
}

class _StatusLine extends StatelessWidget {
  const _StatusLine(
      {required this.submission,
      required this.submitted,
      required this.isDarkMode});

  final Map<String, dynamic>? submission;
  final bool submitted;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final String status = submission?['status'] as String? ?? 'none';
    Color fg;
    String label;
    switch (status) {
      case 'approved':
        fg = Colors.green;
        label = 'homework_status_approved'.tr();
        break;
      case 'rejected':
        fg = Colors.red;
        label = 'homework_status_rejected'.tr();
        break;
      case 'pending':
        fg = Colors.amber.shade700;
        label = 'homework_status_pending'.tr();
        break;
      default:
        fg = isDarkMode ? Colors.grey[400]! : Colors.grey[500]!;
        label = 'homework_hint'.tr();
    }
    return Text(
      label,
      style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: fg),
    );
  }
}
