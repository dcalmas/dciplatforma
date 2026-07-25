import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/ads/ad_manager.dart';
import 'package:lms_app/components/mark_complete_button.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/screens/quiz_lesson/quiz_screen.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/theme/theme_provider.dart';

class QuizComplete extends ConsumerWidget {
  const QuizComplete({super.key, required this.lesson, required this.course});

  final Lesson lesson;
  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correctAnswerCount = ref.watch(correctAnswerCountProvider);
    final totalQuestions = lesson.questions!.length;
    final double percentage = (correctAnswerCount / totalQuestions) * 100;
    final bool isPassed = percentage >= 50;
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = ref.watch(themeProvider).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        title: Text(lesson.name),
      ),
      bottomNavigationBar: isPassed
          ? MarkCompleteButton(course: course, lesson: lesson)
          : Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
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
                      onPressed: () {
                        AdManager.initInterstitailAds(ref);
                        NextScreen.replaceAnimation(context, QuizLesson(course: course, lesson: lesson));
                      },
                      child: Text(
                        'try-again'.tr(),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score Circle
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 12,
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPassed ? Colors.green : Colors.redAccent,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: isPassed ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$correctAnswerCount/$totalQuestions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPassed
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.redAccent.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPassed ? Colors.green : Colors.redAccent).withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (isPassed ? Colors.green : Colors.redAccent).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPassed ? Icons.celebration_rounded : Icons.refresh_rounded,
                        color: isPassed ? Colors.green : Colors.redAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'your-score',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ).tr(),
                    const SizedBox(height: 8),
                    Text(
                      isPassed ? 'passed-test' : 'failed-test',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isPassed ? Colors.green : Colors.redAccent,
                      ),
                    ).tr(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
