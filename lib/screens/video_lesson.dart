import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/components/youtube_player_widget.dart';
import 'package:lms_app/services/app_service.dart';
import 'package:lms_app/services/content_security_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/video_player_widget.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import 'lesson_content_page.dart';

class VideoLesson extends ConsumerStatefulWidget {
  const VideoLesson({super.key, required this.course, required this.lesson});

  final Course course;
  final Lesson lesson;

  @override
  ConsumerState<VideoLesson> createState() => _VideoLessonState();
}

class _VideoLessonState extends ConsumerState<VideoLesson> {
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    ContentSecurityService().initContentSecurity(ref);
    if (widget.lesson.contentType == 'iframe' &&
        (widget.lesson.videoUrl?.trim().isNotEmpty ?? false)) {
      _initIframe();
    }
  }

  void _initIframe() {
    final source = widget.lesson.videoUrl!.trim();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black);
    final uri = Uri.tryParse(source);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      _webViewController!.loadRequest(uri);
      return;
    }
    String htmlContent = """
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            body { margin: 0; padding: 0; background-color: black; overflow: hidden; }
            .container { position: absolute; width: 100%; height: 100%; top: 0; left: 0; }
            iframe { width: 100%; height: 100%; border: 0; }
          </style>
        </head>
        <body>
          <div class="container">
            ${widget.lesson.videoUrl} 
          </div>
        </body>
      </html>
    """;

    _webViewController!
        .loadHtmlString(htmlContent, baseUrl: 'https://kinescope.io/');
  }

  @override
  void dispose() {
    ContentSecurityService().disposeContentSecurity();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = widget.lesson.videoUrl?.trim() ?? '';
    if (rawUrl.isEmpty) return _page(null);

    final url = AppService.cleanVideoUrl(rawUrl);

    // 1. YouTube-ты бірінші тексеру керек, тіпті contentType 'iframe' болса да
    if (AppService.getVideoType(url) == 'youtube') {
      return YoutubePlayerWidget(
        videoUrl: url,
        autoPlay: false,
        pageBuilder: (context, player) => _page(player),
      );
    }

    // 2. Егер YouTube емес болса және iframe болса, WebView қолданамыз
    if (widget.lesson.contentType == 'iframe' && _webViewController != null) {
      return _page(ColoredBox(
          color: Colors.black,
          child: WebViewWidget(controller: _webViewController!)));
    }

    // 3. Басқа жағдайда қарапайым VideoPlayer
    return _page(VideoPlayerWidget(videoUrl: url));
  }

  Widget _page(Widget? player) => LessonContentPage(
        course: widget.course,
        lesson: widget.lesson,
        player: player,
      );
}
