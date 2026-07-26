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
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.indigo.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Course Thumbnail with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Hero(
                    tag: heroTag,
                    child: CustomCacheImage(imageUrl: widget.course.thumbnailUrl, radius: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),

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
                        fontSize: 16,
                        height: 1.3,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.course.author.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: courseProgress,
                        minHeight: 6,
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          courseProgress > 0 ? primaryColor : Colors.grey[300]!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bottom Row: Percent & Action Button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$courseProgressString% ${"percent-completed".tr(args: [""])}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => handleOpenCourse(context, user: widget.user, course: widget.course),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                fontSize: 13,
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
