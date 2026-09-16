import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/services/homework_service.dart';
import 'package:lms_app/utils/snackbars.dart';

/// Сабақ бетіндегі үй тапсырмасы блогы.
/// Вебтегі (LessonWorkspace) логика: тапсырма мәтіні + статус бейджі +
/// жауап өрісі + жіберу/қайта жіберу. Статус әрқашан `pending` болып
/// сақталады, бұрынғы жазба болса merge арқылы жаңартылады.
class HomeworkCard extends ConsumerStatefulWidget {
  const HomeworkCard({super.key, required this.course, required this.lesson});

  final Course course;
  final Lesson lesson;

  @override
  ConsumerState<HomeworkCard> createState() => _HomeworkCardState();
}

class _HomeworkCardState extends ConsumerState<HomeworkCard> {
  final _controller = TextEditingController();
  bool _sending = false;
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    if (!lesson.hasHomework) return const SizedBox.shrink();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;
    final submissions =
        ref.watch(homeworkSubmissionsProvider(widget.course.id));
    final submission = submissions.valueOrNull?[lesson.id];
    final hasSubmission =
        HomeworkService.hasSubmittedHomework(submission);
    final status = submission?['status'] as String?;
    final isPending = status == null || status == 'pending';

    if (!_initialized && submission != null) {
      _initialized = true;
      _controller.text = (submission['text'] as String?) ?? '';
    }

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: primaryColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : primaryColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined,
                    size: 20, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'homework'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (lesson.homeworkRequired)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'homework_required'.tr(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                if (hasSubmission) ...[
                  const SizedBox(width: 6),
                  _StatusBadge(status: submission!['status'] as String?),
                ],
              ],
            ),
            if (lesson.homework != null) ...[
              const SizedBox(height: 10),
              Text(
                lesson.homework!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDarkMode ? Colors.grey[300] : const Color(0xFF334155),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 3,
              enabled: !_sending && !hasSubmission,
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14),
              decoration: InputDecoration(
                hintText: 'homework_text_placeholder'.tr(),
                hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF0F111A)
                    : const Color(0xFFF8F9FE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            if (!hasSubmission)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _sending
                      ? null
                      : () => _submit(submission?['id'] as String?),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _sending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          'homework_submit'.tr(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(String? existingDocId) async {
    if (!mounted) return;
    if (existingDocId != null) return; // Қауіпсіздік пен спамнан қорғау: егер бұрын жіберілген болса, қайта жіберуді бұғаттау
    if (_controller.text.trim().isEmpty) {
      openSnackbarFailure(context, 'homework_empty'.tr());
      return;
    }
    setState(() => _sending = true);
    try {
      final ok = await HomeworkService().submitHomework(
        courseId: widget.course.id,
        lessonId: widget.lesson.id,
        text: _controller.text,
        existingDocId: existingDocId,
      );
      if (!mounted) return;
      if (ok) {
        openSnackbar(context, 'homework_submission_success'.tr());
        ref.invalidate(homeworkSubmissionsProvider(widget.course.id));
      } else {
        openSnackbarFailure(context, 'homework_empty'.tr());
      }
    } catch (e) {
      if (mounted) openSnackbarFailure(context, 'homework_submit_error'.tr());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;
    switch (status) {
      case 'approved':
        bg = Colors.green.withValues(alpha: 0.12);
        fg = Colors.green;
        icon = Icons.check;
        label = 'homework_status_approved'.tr();
        break;
      case 'rejected':
        bg = Colors.red.withValues(alpha: 0.12);
        fg = Colors.red;
        icon = Icons.close;
        label = 'homework_status_rejected'.tr();
        break;
      default:
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber.shade700;
        icon = Icons.schedule;
        label = 'homework_status_pending'.tr();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
        ],
      ),
    );
  }
}
