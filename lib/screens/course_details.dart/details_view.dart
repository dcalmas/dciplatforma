import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/ads/ad_manager.dart';
import 'package:lms_app/ads/banner_ad.dart';
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
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0F111A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              spreadRadius: -2,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            AdManager.isBannerEnbaled(ref) ? const BannerAdWidget() : Container(),
            EnrollButton(course: course),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            expandedHeight: 320,
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(FeatherIcons.chevronLeft),
            ),
            actions: [
              BookmarkButton(course: course),
              ReviewButton(course: course),
              CourseShareButton(course: course),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: bgColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: PreviewBox(course: course, heroTag: heroTag),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TitleInfo(course: course),
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
                _buildSectionCard(
                  isDarkMode: isDarkMode,
                  cardBgColor: cardBgColor,
                  primaryColor: primaryColor,
                  child: CourseTags(course: course),
                ),
                _buildSectionCard(
                  isDarkMode: isDarkMode,
                  cardBgColor: cardBgColor,
                  primaryColor: primaryColor,
                  child: RelatedCourses(course: course),
                ),
                _buildSectionCard(
                  isDarkMode: isDarkMode,
                  cardBgColor: cardBgColor,
                  primaryColor: primaryColor,
                  child: CourseReviews(course: course),
                ),
              ]),
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
