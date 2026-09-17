import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/utils/loading_widget.dart';
import 'package:lms_app/utils/snackbars.dart';
import '../../providers/user_data_provider.dart';

final _isLoadingEnrollmentProvider =
    StateProvider.autoDispose.family<bool, String>((ref, courseId) => false);

class EnrollButton extends ConsumerWidget with UserMixin {
  const EnrollButton({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final bool isLoading = ref.watch(_isLoadingEnrollmentProvider(course.id));
    final String text = CourseMixin.enrollButtonText(course, user);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.indigo.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                    shadowColor: primaryColor.withValues(alpha: 0.4),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final loading = ref.read(
                              _isLoadingEnrollmentProvider(course.id).notifier);
                          if (loading.state) return;
                          loading.state = true;
                          try {
                            await handleEnrollment(context,
                                    user: user, course: course, ref: ref)
                                .timeout(const Duration(seconds: 30));
                          } catch (error, stackTrace) {
                            debugPrint(
                                'Enrollment failed: $error\n$stackTrace');
                            if (context.mounted) {
                              openSnackbarFailure(
                                  context, 'enrollment-error'.tr());
                            }
                          } finally {
                            if (loading.mounted) loading.state = false;
                          }
                        },
                  child: isLoading
                      ? const LoadingIndicatorWidget(color: Colors.white)
                      : Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
