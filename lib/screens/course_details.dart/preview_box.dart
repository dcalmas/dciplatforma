import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/utils/cache_image_filter.dart';
import '../../models/course.dart';
import '../../utils/custom_cached_image.dart';
import '../../utils/next_screen.dart';
import '../video_player_screen.dart';

class PreviewBox extends StatelessWidget {
  const PreviewBox({
    super.key,
    required this.course,
    required this.heroTag,
  });
  final Course course;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final bool hasVideoPreview = course.videoUrl != null && course.videoUrl!.isNotEmpty;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (hasVideoPreview) {
              NextScreen.iOS(context, VideoPlayerScreen(videoUrl: course.videoUrl!));
            }
          },
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.indigo.withValues(alpha: 0.1),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: HeroMode(
                enabled: heroTag != null,
                child: Hero(
                  tag: heroTag ?? '',
                  child: hasVideoPreview
                      ? CustomCacheImageWithDarkFilterFull(imageUrl: course.thumbnailUrl, radius: 20)
                      : CustomCacheImage(imageUrl: course.thumbnailUrl, radius: 20),
                ),
              ),
            ),
          ),
        ),
        if (hasVideoPreview)
          IgnorePointer(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.play_fill,
                size: 26,
                color: primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}

