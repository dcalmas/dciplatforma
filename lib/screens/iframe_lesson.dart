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
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { margin: 0; padding: 0; background-color: black; }
            .container { position: relative; padding-top: 56.25%; width: 100%; }
            iframe { position: absolute; width: 100%; height: 100%; top: 0; left: 0; border: 0; }
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadHtmlString(htmlContent); // HTML кодын тікелей жүктейді
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
            child: WebViewWidget(controller: _controller),
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
