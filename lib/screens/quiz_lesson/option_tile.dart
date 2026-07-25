import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/question.dart';
import 'quiz_screen.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.ref,
    required this.question,
    required this.questionIndex,
    this.selectedOption,
    required this.optionIndex,
  });

  final WidgetRef ref;
  final Question question;
  final int questionIndex;
  final int? selectedOption;
  final int optionIndex;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedOption == optionIndex;
    final bool isCorrectOption = optionIndex == question.correctAnswerIndex;
    final bool showResult = selectedOption != null;
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: showResult ? null : () => _onChanged(optionIndex, ref, questionIndex, isCorrectOption),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _tileColor(context, isSelected, isCorrectOption, showResult, isDarkMode),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _borderColor(context, isSelected, isCorrectOption, showResult, primaryColor, isDarkMode),
            width: isSelected || (showResult && isCorrectOption) ? 2 : 1.5,
          ),
          boxShadow: [
            if (isSelected || (showResult && isCorrectOption))
              BoxShadow(
                color: _shadowColor(isSelected, isCorrectOption).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            _buildOptionCircle(context, isSelected, isCorrectOption, showResult, primaryColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                question.options[optionIndex],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _textColor(context, isSelected, isCorrectOption, showResult, isDarkMode),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
              ),
            ),
            if (showResult && isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                isCorrectOption ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrectOption ? Colors.green : Colors.redAccent,
                size: 24,
              ),
            ] else if (showResult && isCorrectOption) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green.withValues(alpha: 0.6),
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCircle(
      BuildContext context, bool isSelected, bool isCorrectOption, bool showResult, Color primaryColor) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    final letter = optionIndex < letters.length ? letters[optionIndex] : '${optionIndex + 1}';

    Color bgColor;
    Color textColor;

    if (!showResult) {
      bgColor = isSelected ? primaryColor : primaryColor.withValues(alpha: 0.08);
      textColor = isSelected ? Colors.white : primaryColor;
    } else if (isSelected && isCorrectOption) {
      bgColor = Colors.green;
      textColor = Colors.white;
    } else if (isSelected && !isCorrectOption) {
      bgColor = Colors.redAccent;
      textColor = Colors.white;
    } else if (isCorrectOption) {
      bgColor = Colors.green.withValues(alpha: 0.15);
      textColor = Colors.green;
    } else {
      bgColor = Colors.grey.withValues(alpha: 0.1);
      textColor = Colors.grey;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: showResult && (isSelected || isCorrectOption)
            ? Icon(
                isCorrectOption ? Icons.check_rounded : Icons.close_rounded,
                color: textColor,
                size: 20,
              )
            : Text(
                letter,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  void _onChanged(int? value, WidgetRef ref, int questionIndex, bool isCorrectOption) {
    ref.read(selectedOptionProvider.notifier).update((state) => value);
    if (questionIndex == 0) {
      ref.invalidate(correctAnswerCountProvider);
    }
    if (isCorrectOption) {
      ref.read(correctAnswerCountProvider.notifier).update((state) => state + 1);
    }
  }

  Color _tileColor(BuildContext context, bool isSelected, bool isCorrectOption, bool showResult, bool isDarkMode) {
    if (!showResult) {
      return isDarkMode ? const Color(0xFF1E202C) : Colors.white;
    }
    if (isSelected && isCorrectOption) return Colors.green.withValues(alpha: 0.08);
    if (isSelected && !isCorrectOption) return Colors.redAccent.withValues(alpha: 0.08);
    if (isCorrectOption) return Colors.green.withValues(alpha: 0.05);
    return isDarkMode ? const Color(0xFF1E202C).withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.05);
  }

  Color _borderColor(
      BuildContext context, bool isSelected, bool isCorrectOption, bool showResult, Color primaryColor, bool isDarkMode) {
    if (!showResult) {
      return isSelected ? primaryColor : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!);
    }
    if (isSelected && isCorrectOption) return Colors.green;
    if (isSelected && !isCorrectOption) return Colors.redAccent;
    if (isCorrectOption) return Colors.green.withValues(alpha: 0.4);
    return isDarkMode ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[200]!;
  }

  Color _shadowColor(bool isSelected, bool isCorrectOption) {
    if (isSelected && isCorrectOption) return Colors.green;
    if (isSelected) return Colors.redAccent;
    return Colors.transparent;
  }

  Color _textColor(
      BuildContext context, bool isSelected, bool isCorrectOption, bool showResult, bool isDarkMode) {
    if (!showResult) {
      return isDarkMode ? Colors.white : const Color(0xFF1E293B);
    }
    if (isSelected && isCorrectOption) return Colors.green;
    if (isSelected && !isCorrectOption) return Colors.redAccent;
    if (isCorrectOption) return Colors.green;
    return isDarkMode ? Colors.grey[500]! : Colors.grey[400]!;
  }
}
