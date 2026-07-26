import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import '../../../models/course.dart';
import '../../../models/user_model.dart';
import '../../course_details.dart/details_view.dart';
import '../../../utils/custom_cached_image.dart';
import '../../../utils/next_screen.dart';

class MyCourseTile extends StatefulWidget {
  const MyCourseTile({super.key, required this.course, required this.user});

  final Course course;
  final UserModel user;

  @override
  State<MyCourseTile> createState() => _MyCourseTileState();
}

class _MyCourseTileState extends State<MyCourseTile> with UserMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final heroTag = UniqueKey();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final courseId = widget.course.id;
    final completedList = widget.user.completedLessons ?? [];
    List validIds = completedList
        .where((element) {
          final id = element.toString();
          return id.startsWith('${courseId}_');
        })
        .toList();
    final int totalLessons = widget.course.lessonsCount > 0 ? widget.course.lessonsCount : 1;
    final double courseProgress = validIds.isEmpty
        ? 0.0
        : (validIds.length / totalLessons).clamp(0.0, 1.0);
    final String courseProgressString = (courseProgress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        NextScreen.iOS(context, CourseDetailsView(course: widget.course, heroTag: heroTag));
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.indigo.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Course Thumbnail with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 95,
                  width: 95,
                  child: Hero(
                    tag: heroTag,
                    child: CustomCacheImage(imageUrl: widget.course.thumbnailUrl, radius: 18),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Course Details & Progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.25,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.course.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: courseProgress,
                        minHeight: 6,
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          courseProgress > 0 ? primaryColor : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Bottom Row: Percent & Action Button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$courseProgressString% ${"percent-completed".tr(args: [""])}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => handleOpenCourse(context, user: widget.user, course: widget.course),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              CourseMixin.enrollButtonText(widget.course, widget.user).tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

