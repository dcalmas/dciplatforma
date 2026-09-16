import 'package:flutter/material.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/screens/course_details.dart/sections.dart';

class CurriculamScreen extends StatelessWidget {
  const CurriculamScreen({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final foreground = dark ? Colors.white : const Color(0xFF0F172A);
    return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          leading: const BackButton(),
          toolbarHeight: 64,
          centerTitle: false,
          titleSpacing: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          title: Text(
            course.name,
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: foreground),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Sections(
                course: course,
                isInitialSectionOpen: false,
              )
            ],
          ),
        ));
  }
}
