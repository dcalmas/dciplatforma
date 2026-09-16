import 'lesson_content_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';

import '../services/content_security_service.dart';

class ArticleLesson extends ConsumerStatefulWidget {
  const ArticleLesson({super.key, required this.lesson, required this.course});

  final Course course;
  final Lesson lesson;

  @override
  ConsumerState<ArticleLesson> createState() => _ArticleLessonState();
}

class _ArticleLessonState extends ConsumerState<ArticleLesson> {
  @override
  void initState() {
    ContentSecurityService().initContentSecurity(ref);
    super.initState();
  }

  @override
  void dispose() {
    ContentSecurityService().disposeContentSecurity();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LessonContentPage(course: widget.course, lesson: widget.lesson);
}
