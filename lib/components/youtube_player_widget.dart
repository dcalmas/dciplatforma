import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  const YoutubePlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.body,
    this.pageBuilder,
    this.autoPlay = true,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final Widget? body;
  final Widget Function(BuildContext context, Widget player)? pageBuilder;
  final bool autoPlay;

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    final String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        loop: false,
        forceHD: true, // HD сапасына басымдық беру
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        bottomActions: const [
          SizedBox(width: 14.0),
          CurrentPosition(),
          SizedBox(width: 8.0),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          PlaybackSpeedButton(),
          FullScreenButton(),
        ],
        onReady: () {
          debugPrint('Player is ready.');
        },
      ),
      builder: (context, player) {
        if (widget.pageBuilder != null) {
          return widget.pageBuilder!(context, player);
        }
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade900,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                FeatherIcons.chevronLeft,
                color: Colors.white,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: kToolbarHeight),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  player,
                  widget.body ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
