import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/question.dart';
import 'package:lms_app/screens/quiz_lesson/option_tile.dart';
import 'package:lms_app/theme/theme_provider.dart';

class QuestionTile extends StatelessWidget {
  const QuestionTile({
    super.key,
    required this.ref,
    required this.questions,
    required this.currentPageIndex,
    required this.question,
    this.selectedOption,
    required this.questionIndex,
  });

  final WidgetRef ref;
  final List<Question> questions;
  final int currentPageIndex;
  final Question question;
  final int? selectedOption;
  final int questionIndex;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final progress = (currentPageIndex + 1) / questions.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'count-questions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ).tr(args: ['${currentPageIndex + 1}', questions.length.toString()]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Question number badge
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              'Q${currentPageIndex + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),

          // Question text
          Text(
            question.questionTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 19,
              height: 1.4,
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 28),

          // Options
          ListView.builder(
            shrinkWrap: true,
            itemCount: question.options.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return OptionTile(
                ref: ref,
                question: question,
                questionIndex: questionIndex,
                optionIndex: index,
                selectedOption: selectedOption,
              );
            },
          ),
        ],
      ),
    );
  }
}
