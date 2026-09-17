import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:last_pod_player/last_pod_player.dart';
import 'package:lms_app/services/app_service.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  final String videoUrl;
  final String? thumbnailUrl;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final PodPlayerController controller;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _initController(widget.videoUrl);
  }

  void _initController(String videoUrl) {
    try {
      final cleanUrl = AppService.cleanVideoUrl(videoUrl);
      final String videoType = AppService.getVideoType(cleanUrl);
      controller = PodPlayerController(
          playVideoFrom: videoType == 'network'
              ? PlayVideoFrom.network(cleanUrl)
              : videoType == 'vimeo'
                  ? PlayVideoFrom.vimeo(cleanUrl)
                  : PlayVideoFrom.youtube(cleanUrl),
          podPlayerConfig: const PodPlayerConfig(
            autoPlay: false,
            isLooping: false,
          ))
        ..initialise().catchError((e) {
          debugPrint('video init error: $e');
          if (mounted) setState(() => _initFailed = true);
        });
    } catch (e) {
      debugPrint('video init error: $e');
      _initFailed = true;
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      try {
        controller.dispose();
      } catch (_) {}
      setState(() => _initFailed = false);
      _initController(widget.videoUrl);
    }
  }


  @override
  void dispose() {

    // temporary fix to solve status bar issue on iOS
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    }
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initFailed || widget.videoUrl.trim().isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.grey),
      );
    }
    return PodVideoPlayer(
      controller: controller,
      alwaysShowProgressBar: true,
      videoThumbnail: widget.thumbnailUrl == null
          ? null
          : DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
                widget.thumbnailUrl.toString(),
              ),
            ),
    );
  }
}
