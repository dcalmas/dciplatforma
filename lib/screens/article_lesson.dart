import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/components/html_body.dart';
import 'package:lms_app/components/mark_complete_button.dart';
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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : primaryColor.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: Icon(FeatherIcons.chevronLeft, size: 20, color: primaryColor),
          ),
        ),
        title: Text(widget.lesson.name),
        titleSpacing: 0,
        backgroundColor: bgColor,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      bottomNavigationBar: MarkCompleteButton(course: widget.course, lesson: widget.lesson),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.06)
                  : primaryColor.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : primaryColor.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: HtmlBody(description: widget.lesson.description.toString()),
        ),
      ),
    );
  }
}
