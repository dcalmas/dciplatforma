import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/components/youtube_player_widget.dart';
import 'package:lms_app/services/app_service.dart';
import 'package:lms_app/services/content_security_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/mark_complete_button.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import 'video_player_screen.dart';

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
    ContentSecurityService().initContentSecurity(ref);
    if (widget.lesson.contentType == 'iframe') {
      _initIframe();
    }
    super.initState();
  }

  void _initIframe() {
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

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36")
      ..loadHtmlString(htmlContent, baseUrl: 'https://kinescope.io/');
  }

  @override
  void dispose() {
    ContentSecurityService().disposeContentSecurity();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Iframe жағдайы
    if (widget.lesson.contentType == 'iframe' && _webViewController != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.name), elevation: 0),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: WebViewWidget(controller: _webViewController!),
              ),
            ),
            Expanded(child: _button()),
          ],
        ),
      );
    }

    // YouTube жағдайы
    final String videoType = AppService.getVideoType(widget.lesson.videoUrl.toString());
    if (videoType == 'youtube') {
      return YoutubePlayerWidget(
        videoUrl: widget.lesson.videoUrl.toString(),
        body: _button(),
      );
    }

    // Басқа видеолар (Vimeo, т.б.)
    return Scaffold(
      body: Stack(
        children: [
          VideoPlayerScreen(videoUrl: widget.lesson.videoUrl.toString()),
          _button(),
        ],
      ),
    );
  }

  Widget _button() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 1)),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MarkCompleteButton(course: widget.course, lesson: widget.lesson);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
