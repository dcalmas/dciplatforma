import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/utils/custom_cached_image.dart';

double homeCourseProgress(Course course, UserModel? user) {
  if (course.lessonsCount <= 0) return 0;
  final completed = (user?.completedLessons ?? [])
      .where((id) => id.toString().startsWith('${course.id}_'))
      .toSet()
      .length;
  return (completed / course.lessonsCount).clamp(0.0, 1.0);
}

class HomeCourseBanner extends StatelessWidget {
  const HomeCourseBanner({super.key, required this.course, required this.user});
  final Course course;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final progress = homeCourseProgress(course, user);
    final enrolled = user?.enrolledCourses?.contains(course.id) ?? false;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: primary.withValues(alpha: .2),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return Stack(children: [
          Positioned.fill(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                      width: constraints.maxWidth * .62,
                      child: CustomCacheImage(
                          imageUrl: course.thumbnailUrl, radius: 0)))),
          Positioned.fill(
              child: DecoratedBox(
                  decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              primary,
              primary.withValues(alpha: .94),
              primary.withValues(alpha: .08)
            ], stops: const [
              0,
              .4,
              1
            ]),
          ))),
          Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text((enrolled ? 'my-courses' : 'courses').tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                  width: constraints.maxWidth * .62,
                  child: Text(course.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 1.2,
                          fontWeight: FontWeight.w800))),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('count-lesson'.tr(args: ['${course.lessonsCount}']),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 9),
                      Row(children: [
                        Expanded(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 7,
                                    color: Colors.white,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: .28)))),
                        const SizedBox(width: 8),
                        Text('${(progress * 100).round()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ])),
                const SizedBox(width: 16),
                Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.play_arrow_rounded,
                        size: 30, color: primary)),
              ]),
            ]),
          ),
        ]);
      }),
    );
  }
}

class HomeCourseCard extends StatelessWidget {
  const HomeCourseCard(
      {super.key, required this.course, required this.user, this.categoryName});
  final Course course;
  final UserModel? user;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final muted = dark ? Colors.grey.shade400 : const Color(0xFF777B8F);
    final progress = homeCourseProgress(course, user);
    final duration = course.courseMeta.duration;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E202C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
              color: primary.withValues(alpha: .04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final coverWidth = (constraints.maxWidth * .27).clamp(72.0, 120.0);
        return Stack(children: [
          PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: coverWidth,
              child:
                  CustomCacheImage(imageUrl: course.thumbnailUrl, radius: 12)),
          Padding(
              padding: EdgeInsetsDirectional.only(start: coverWidth + 12),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 104),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: primary.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(9)),
                            child: Text(
                                categoryName ??
                                    (course.priceStatus == 'free'
                                            ? 'free'
                                            : 'premium')
                                        .tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(height: 4),
                        Row(children: [
                          Expanded(
                              child: Text(course.name,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: dark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2))),
                          const SizedBox(width: 6),
                          Container(
                              width: 26,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: primary.withValues(alpha: .08),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.chevron_right_rounded,
                                  color: primary, size: 22)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      color: primary,
                                      backgroundColor:
                                          primary.withValues(alpha: .07)))),
                          const SizedBox(width: 8),
                          Text('${(progress * 100).round()}%',
                              style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 6),
                        Wrap(spacing: 10, runSpacing: 4, children: [
                          _metadata(
                              Icons.play_circle_outline,
                              'count-lesson'
                                  .tr(args: ['${course.lessonsCount}']),
                              muted),
                          if (duration != null && duration.trim().isNotEmpty)
                            _metadata(Icons.schedule, duration, muted),
                        ]),
                      ]))),
        ]);
      }),
    );
  }

  Widget _metadata(IconData icon, String label, Color color) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
            child: Text(label, style: TextStyle(color: color, fontSize: 10))),
      ]);
}
