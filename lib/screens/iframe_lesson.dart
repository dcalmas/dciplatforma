import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/lesson.dart';

class IFrameLesson extends StatelessWidget {
  final Lesson lesson;
  const IFrameLesson({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    // Iframe кодын дайындау
    String iframeHtml = """
      <iframe src="${lesson.videoUrl}" 
      width="100%" 
      height="100%" 
      frameborder="0" 
      allow="autoplay; fullscreen; picture-in-picture" 
      allowfullscreen></iframe>
    """;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.name),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Видео бөлімі
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Html(
                data: iframeHtml,
              ),
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
                    lesson.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (lesson.description != null)
                    Html(data: lesson.description!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
