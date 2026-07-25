import 'package:line_icons/line_icons.dart';
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

    return Scaffold(
      backgroundColor: bgColor,
      bottomNavigationBar: Wrap(
        alignment: WrapAlignment.center,
        children: [
          AdManager.isBannerEnbaled(ref) ? const BannerAdWidget() : Container(),
          EnrollButton(course: course),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: false,
            floating: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(LineIcons.chevron_left),
            ),
            actions: [
              BookmarkButton(course: course),
              ReviewButton(course: course),
              CourseShareButton(course: course),
              const SizedBox(width: 10),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PreviewBox(course: course, heroTag: heroTag),
                    const SizedBox(height: 20),
                    TitleInfo(course: course),
                    CourseInfo(course: course),
                    Learnings(course: course),
                    const SizedBox(height: 30),
                    Curriculam(course: course),
                    Requirements(course: course),
                    CourseDescription(course: course),
                    CourseTags(course: course),
                    RelatedCourses(course: course),
                    CourseReviews(course: course),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

