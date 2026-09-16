import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:lms_app/components/homework_card.dart';
import 'package:lms_app/components/html_body.dart';
import 'package:lms_app/components/mark_complete_button.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';

/// Shared full-page layout for reading and watching a lesson.
class LessonContentPage extends StatelessWidget {
  const LessonContentPage(
      {super.key, required this.course, required this.lesson, this.player});

  final Course course;
  final Lesson lesson;
  final Widget? player;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final description = lesson.description?.trim() ?? '';
    final firstElement =
        html_parser.parse(description).body?.children.firstOrNull;
    final hasTitleInBody = firstElement != null &&
        RegExp(r'^h[1-6]$').hasMatch(firstElement.localName ?? '') &&
        firstElement.text.trim().replaceAll(RegExp(r'\s+'), ' ') ==
            lesson.name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final foreground = dark ? Colors.white : const Color(0xFF0F172A);
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: BackButton(
            color: foreground,
            style: IconButton.styleFrom(
              foregroundColor: foreground,
              backgroundColor: dark ? const Color(0xFF1E202C) : Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(course.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: dark ? Colors.white : const Color(0xFF0F172A)),
        backgroundColor:
            dark ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
        foregroundColor: dark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
          top: false,
          child: MarkCompleteButton(course: course, lesson: lesson)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (player != null) ...[
            ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(aspectRatio: 16 / 9, child: player)),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1E202C) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withValues(alpha: .12)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!hasTitleInBody)
                Text(lesson.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: dark ? Colors.white : const Color(0xFF0F172A))),
              if (description.isNotEmpty) ...[
                if (!hasTitleInBody) const SizedBox(height: 10),
                HtmlBody(description: description, fontSize: 15, compact: true),
              ],
            ]),
          ),
          if (lesson.hasHomework)
            HomeworkCard(course: course, lesson: lesson),
        ]),
      ),
    );
  }
}
