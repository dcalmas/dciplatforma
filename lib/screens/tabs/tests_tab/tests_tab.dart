import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/providers/user_data_provider.dart';
import 'package:lms_app/screens/course_details.dart/details_view.dart';
import 'package:lms_app/screens/quiz_lesson/quiz_screen.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/loading_widget.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';

class QuizItem {
  final Course course;
  final Lesson lesson;
  QuizItem({required this.course, required this.lesson});
}

final allQuizzesProvider = FutureProvider<List<QuizItem>>((ref) async {
  final List<Course> courses = await FirebaseService().getAllCourses();
  final List<QuizItem> quizzes = [];

  // Fetch sections and lessons in parallel
  await Future.wait(courses.map((course) async {
    try {
      final sections = await FirebaseService().getSections(course.id);
      await Future.wait(sections.map((section) async {
        try {
          final lessons = await FirebaseService().getLessons(course.id, section.id);
          for (var lesson in lessons) {
            if (lesson.contentType == 'quiz') {
              quizzes.add(QuizItem(course: course, lesson: lesson));
            }
          }
        } catch (e) {
          debugPrint('Error loading lessons for course ${course.id}: $e');
        }
      }));
    } catch (e) {
      debugPrint('Error loading sections for course ${course.id}: $e');
    }
  }));

  // Sort by course name and then by lesson order
  quizzes.sort((a, b) {
    int comp = a.course.name.compareTo(b.course.name);
    if (comp != 0) return comp;
    return a.lesson.order.compareTo(b.lesson.order);
  });

  return quizzes;
});

class TestsTab extends ConsumerWidget with UserMixin {
  const TestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesState = ref.watch(allQuizzesProvider);
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('tests').tr(),
        backgroundColor: isDarkMode ? const Color(0xFF0F111A) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async => await ref.refresh(allQuizzesProvider.future),
        child: quizzesState.when(
          loading: () => const Center(child: LoadingIndicatorWidget()),
          error: (error, stack) => Center(
            child: Text(
              'error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (quizzes) {
            if (quizzes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Icon(
                      LineIcons.lightbulb,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'no-course'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: quizzes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final quizItem = quizzes[index];
                final course = quizItem.course;
                final lesson = quizItem.lesson;

                final isCompleted = user?.completedLessons?.contains('${course.id}_${lesson.id}') ?? false;
                final enrolled = hasEnrolled(user, course);
                final isPremium = course.priceStatus != 'free';
                final isPremiumUser = UserMixin.isUserPremium(user);
                final hasAccess = !isPremium || enrolled || isPremiumUser;

                return Card(
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LineIcons.lightbulb,
                        color: Theme.of(context).primaryColor,
                        size: 26,
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lesson.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'count-questions',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ).tr(args: [
                        '1',
                        (lesson.questions?.length ?? 0).toString(),
                      ]),
                    ),
                    trailing: _buildTrailingWidget(context, isCompleted, hasAccess, isDarkMode),
                    onTap: () {
                      if (hasAccess) {
                        NextScreen.popup(context, QuizLesson(course: course, lesson: lesson));
                      } else {
                        // Open dialog/snackbar or redirect to course detail to enroll
                        openSnackbar(context, 'subscribe-to-access-features'.tr());
                        NextScreen.iOS(context, CourseDetailsView(course: course, heroTag: UniqueKey()));
                      }
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

  Widget _buildTrailingWidget(BuildContext context, bool isCompleted, bool hasAccess, bool isDarkMode) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 18,
        ),
      );
    } else if (!hasAccess) {
      return Icon(
        FeatherIcons.lock,
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        size: 22,
      );
    } else {
      return Icon(
        FeatherIcons.chevronRight,
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        size: 22,
      );
    }
  }
}
