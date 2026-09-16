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
    List validIds = completedList.where((element) {
      final id = element.toString();
      return id.startsWith('${courseId}_');
    }).toList();
    final int totalLessons =
        widget.course.lessonsCount > 0 ? widget.course.lessonsCount : 1;
    final double courseProgress = validIds.isEmpty
        ? 0.0
        : (validIds.length / totalLessons).clamp(0.0, 1.0);
    final String courseProgressString =
        (courseProgress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        NextScreen.iOS(context,
            CourseDetailsView(course: widget.course, heroTag: heroTag));
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: primaryColor.withValues(alpha: isDarkMode ? 0.4 : 0.25)),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final coverWidth = (constraints.maxWidth * 0.4).clamp(0.0, 180.0);
              return Stack(
                children: [
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: coverWidth,
                    child: Hero(
                      tag: heroTag,
                      child: CustomCacheImage(
                        imageUrl: widget.course.thumbnailUrl,
                        radius: 14,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: coverWidth + 14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 150),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              height: 1.3,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.course.author.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: courseProgress,
                              minHeight: 7,
                              backgroundColor: isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Keep progress readable when the action needs its own line.
                          Wrap(
                            spacing: 10,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'percent-completed'
                                    .tr(args: [courseProgressString]),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : const Color(0xFF686B82),
                                ),
                              ),
                              TextButton(
                                onPressed: () => handleOpenCourse(
                                  context,
                                  user: widget.user,
                                  course: widget.course,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  backgroundColor:
                                      primaryColor.withValues(alpha: 0.08),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  CourseMixin.enrollButtonText(
                                          widget.course, widget.user)
                                      .tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
