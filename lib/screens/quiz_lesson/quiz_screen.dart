import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/models/question.dart';
import 'package:lms_app/screens/quiz_lesson/question_tile.dart';
import 'package:lms_app/screens/quiz_lesson/quiz_complete.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';

import '../../services/content_security_service.dart';

final selectedOptionProvider = StateProvider.autoDispose<int?>((ref) => null);
final questionPageControllerProvider = Provider.autoDispose<PageController>((ref) {
  final controller = PageController(initialPage: 0);
  ref.onDispose(() => controller.dispose());
  return controller;
});
final correctAnswerCountProvider = StateProvider<int>((ref) => 0);
final currentPageIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class QuizLesson extends ConsumerStatefulWidget {
  const QuizLesson({super.key, required this.lesson, required this.course});

  final Course course;
  final Lesson lesson;

  @override
  ConsumerState<QuizLesson> createState() => _QuizLessonState();
}

class _QuizLessonState extends ConsumerState<QuizLesson> {
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
    final List<Question> questions = widget.lesson.questions ?? [];
    final pageController = ref.watch(questionPageControllerProvider);
    final selectedOption = ref.watch(selectedOptionProvider);
    final currentPageIndex = ref.watch(currentPageIndexProvider);
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.lesson.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentPageIndex + 1}/${questions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _onNextBtnPressed(context, selectedOption, currentPageIndex, questions, ref, pageController),
                child: Text(
                  (currentPageIndex + 1) >= questions.length ? 'finish'.tr() : 'next'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: questions.length,
        onPageChanged: (value) => ref.read(currentPageIndexProvider.notifier).update((state) => value),
        itemBuilder: (context, questionIndex) {
          final Question question = questions[questionIndex];
          return QuestionTile(
            ref: ref,
            questions: questions,
            currentPageIndex: currentPageIndex,
            question: question,
            questionIndex: questionIndex,
            selectedOption: selectedOption,
          );
        },
      ),
    );
  }

  void _onNextBtnPressed(
    BuildContext context,
    int? selectedOption,
    int currentPageIndex,
    List<Question> questions,
    WidgetRef ref,
    PageController pageController,
  ) {
    if (selectedOption != null) {
      if ((currentPageIndex + 1) >= questions.length) {
        NextScreen.replaceAnimation(context, QuizComplete(course: widget.course, lesson: widget.lesson));
      } else {
        ref.invalidate(selectedOptionProvider);
        pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
      }
    } else {
      openSnackbar(context, "choose-answer".tr());
    }
  }
}
