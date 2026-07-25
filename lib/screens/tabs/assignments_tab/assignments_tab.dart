import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/providers/user_data_provider.dart';
import 'package:lms_app/screens/course_details.dart/details_view.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/loading_widget.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentItem {
  final Course course;
  final Lesson lesson;
  AssignmentItem({required this.course, required this.lesson});
}

final allAssignmentsProvider = FutureProvider<List<AssignmentItem>>((ref) async {
  final List<Course> courses = await FirebaseService().getAllCourses();
  final List<AssignmentItem> assignments = [];

  // Fetch sections and lessons in parallel
  await Future.wait(courses.map((course) async {
    try {
      final sections = await FirebaseService().getSections(course.id);
      await Future.wait(sections.map((section) async {
        try {
          final lessons = await FirebaseService().getLessons(course.id, section.id);
          for (var lesson in lessons) {
            if (lesson.contentType == 'document' || (lesson.attachmentUrl != null && lesson.attachmentUrl!.isNotEmpty)) {
              assignments.add(AssignmentItem(course: course, lesson: lesson));
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
  assignments.sort((a, b) {
    int comp = a.course.name.compareTo(b.course.name);
    if (comp != 0) return comp;
    return a.lesson.order.compareTo(b.lesson.order);
  });

  return assignments;
});

class AssignmentsTab extends ConsumerWidget with UserMixin {
  const AssignmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsState = ref.watch(allAssignmentsProvider);
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);

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
        onRefresh: () async => await ref.refresh(allAssignmentsProvider.future),
        child: assignmentsState.when(
          loading: () => const Center(child: LoadingIndicatorWidget()),
          error: (error, stack) => Center(
            child: Text(
              'error: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (assignments) {
            if (assignments.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Icon(
                      FeatherIcons.checkSquare,
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
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = assignments[index];
                final course = item.course;
                final lesson = item.lesson;

                final isCompleted = user?.completedLessons?.contains(lesson.id) ?? false;
                final enrolled = hasEnrolled(user, course);
                final isPremium = course.priceStatus != 'free';
                final isPremiumUser = UserMixin.isUserPremium(user);
                final hasAccess = !isPremium || enrolled || isPremiumUser;

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        FeatherIcons.fileText,
                        color: Theme.of(context).primaryColor,
                        size: 24,
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
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    subtitle: lesson.description != null && lesson.description!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              lesson.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          )
                        : null,
                    trailing: _buildTrailingWidget(context, isCompleted, hasAccess, isDarkMode),
                    onTap: () async {
                      if (hasAccess) {
                        if (lesson.attachmentUrl != null && lesson.attachmentUrl!.isNotEmpty) {
                          final uri = Uri.parse(lesson.attachmentUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              openSnackbar(context, 'Could not open task URL');
                            }
                          }
                        } else {
                          openSnackbar(context, 'No attachment file for this task');
                        }
                      } else {
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
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    } else if (!hasAccess) {
      return Icon(
        FeatherIcons.lock,
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        size: 20,
      );
    } else {
      return Icon(
        FeatherIcons.download,
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        size: 20,
      );
    }
  }
}
