import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/components/price_tag.dart';
import 'package:lms_app/components/rating_bar.dart';
import 'package:lms_app/screens/all_courses.dart/courses_view.dart';
import 'package:lms_app/screens/course_details.dart/details_view.dart';
import 'package:lms_app/utils/custom_cached_image.dart';
import 'package:lms_app/utils/next_screen.dart';

import '../../models/course.dart';

class GridCourseTile extends StatelessWidget {
  const GridCourseTile({super.key, required this.course, required this.gridStyle});

  final Course course;
  final GridStyle gridStyle;

  @override
  Widget build(BuildContext context) {
    final heroTag = UniqueKey();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => NextScreen.iOS(
          context,
          CourseDetailsView(
            course: course,
            heroTag: heroTag,
          )),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.indigo.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: gridStyle == GridStyle.grid ? 130 : 180,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: Hero(tag: heroTag, child: CustomCacheImage(imageUrl: course.thumbnailUrl, radius: 0)),
                ),
                PremiumTag(course: course)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'count-students',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.blueGrey,
                    ),
                  ).tr(args: [course.studentsCount.toString()]),
                  const SizedBox(height: 6),
                  RatingViewer(rating: course.rating),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
