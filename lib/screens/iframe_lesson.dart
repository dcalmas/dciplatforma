import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/lesson.dart';

class IFrameLesson extends StatefulWidget {
  final Lesson lesson;
  const IFrameLesson({super.key, required this.lesson});

  @override
  State<IFrameLesson> createState() => _IFrameLessonState();
}

class _IFrameLessonState extends State<IFrameLesson> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // HTML кодын дайындау (Kinescope және т.б. үшін)
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

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36") // User-Agent қосылды
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) => debugPrint('Loading: \$progress%'),
          onPageStarted: (String url) => debugPrint('Page started: \$url'),
          onPageFinished: (String url) => debugPrint('Page finished: \$url'),
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebResourceError: \${error.description}');
          },
        ),
      )
      ..loadHtmlString(htmlContent, baseUrl: 'https://kinescope.io/'); // baseUrl қосылды
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.name),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Видео бөлімі (WebView)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: WebViewWidget(controller: _controller),
            ),
          ),
          
          // Сипаттамасы
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (widget.lesson.description != null)
                    Html(data: widget.lesson.description!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
