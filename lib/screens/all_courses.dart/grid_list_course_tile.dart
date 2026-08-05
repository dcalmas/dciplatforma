import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/components/price_tag.dart';
import 'package:lms_app/components/rating_bar.dart';
import 'package:lms_app/screens/course_details.dart/details_view.dart';
import 'package:lms_app/utils/custom_cached_image.dart';
import 'package:lms_app/utils/next_screen.dart';
import '../../models/course.dart';

class GridListCourseTile extends StatelessWidget {
  const GridListCourseTile({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final heroTag = UniqueKey();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => NextScreen.iOS(context, CourseDetailsView(course: course, heroTag: heroTag)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 105,
                    width: 105,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Hero(tag: heroTag, child: CustomCacheImage(imageUrl: course.thumbnailUrl, radius: 14)),
                  ),
                  PremiumTag(course: course),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    const SizedBox(height: 6),
                    Text(
                      'By ${course.author.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('count-students', style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.grey[400] : Colors.blueGrey)).tr(args: [
                      course.studentsCount.toString(),
                    ]),
                    const SizedBox(height: 6),
                    RatingViewer(rating: course.rating),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
