import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/screens/course_details.dart/course_share_button.dart';
import 'bookmark_button.dart';
import '../../models/course.dart';
import 'course_description.dart';
import 'course_info.dart';
import 'course_reviews.dart';
import 'course_tags.dart';
import 'curriculam.dart';
import 'enroll_button.dart';
import 'learnings.dart';
import 'preview_box.dart';
import 'related_courses.dart';
import 'requirements.dart';
import 'review_button.dart';
import 'title_info.dart';

class CourseDetailsView extends ConsumerWidget {
  const CourseDetailsView({super.key, required this.course, this.heroTag});

  final Course course;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;
    final primaryColor = Theme.of(context).primaryColor;
    final tagIds = course.tagIDs;
    final hasTags = tagIds != null &&
        tagIds.isNotEmpty &&
        (ref.watch(courseTagsProvider(tagIds)).asData?.value.isNotEmpty ??
            false);
    final hasRelatedCourses =
        ref.watch(relatedCoursesProvider(course)).asData?.value.isNotEmpty ??
            false;
    final reviews = ref.watch(courseReviewProvider(course.id));
    final showReviews =
        reviews.hasError || (reviews.asData?.value.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0F111A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            EnrollButton(course: course),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                FeatherIcons.chevronLeft,
                size: 22,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: 48,
                        height: 48,
                        child: BookmarkButton(course: course, compact: true)),
                    SizedBox(
                        width: 48,
                        height: 48,
                        child: ReviewButton(course: course, compact: true)),
                    SizedBox(
                        width: 48,
                        height: 48,
                        child:
                            CourseShareButton(course: course, compact: true)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
        child: Column(
          children: [
            PreviewBox(course: course, heroTag: heroTag),
            const SizedBox(height: 14),
            TitleInfo(course: course),
            const SizedBox(height: 14),
            CourseInfo(course: course),
            Learnings(course: course),
            _buildSectionCard(
              isDarkMode: isDarkMode,
              cardBgColor: cardBgColor,
              primaryColor: primaryColor,
              child: Curriculam(course: course),
            ),
            Requirements(course: course),
            CourseDescription(course: course),
            if (hasTags)
              _buildSectionCard(
                isDarkMode: isDarkMode,
                cardBgColor: cardBgColor,
                primaryColor: primaryColor,
                child: CourseTags(course: course),
              ),
            if (hasRelatedCourses)
              _buildSectionCard(
                isDarkMode: isDarkMode,
                cardBgColor: cardBgColor,
                primaryColor: primaryColor,
                child: RelatedCourses(course: course),
              ),
            if (showReviews)
              _buildSectionCard(
                isDarkMode: isDarkMode,
                cardBgColor: cardBgColor,
                primaryColor: primaryColor,
                child: CourseReviews(course: course),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSectionCard({
    required bool isDarkMode,
    required Color cardBgColor,
    required Color primaryColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : primaryColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
