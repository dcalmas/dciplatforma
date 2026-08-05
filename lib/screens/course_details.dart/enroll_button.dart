import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/constants/app_constants.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/utils/loading_widget.dart';
import '../../providers/user_data_provider.dart';

final _isLoadingEnrollmentProvider = StateProvider.autoDispose((ref) => false);

class EnrollButton extends ConsumerWidget with UserMixin {
  const EnrollButton({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final bool isLoading = ref.watch(_isLoadingEnrollmentProvider);
    final String text = CourseMixin.enrollButtonText(course, user);
    final bool isPremium = course.priceStatus != priceStatus.keys.first;
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
            if (!hasEnrolled(user, course)) ...[
              isPremium ? _PremiumTag(primaryColor: primaryColor) : _FreeTag(primaryColor: primaryColor),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                    shadowColor: primaryColor.withValues(alpha: 0.4),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    ref.read(_isLoadingEnrollmentProvider.notifier).state = true;
                    await handleEnrollment(context, user: user, course: course, ref: ref);
                    ref.read(_isLoadingEnrollmentProvider.notifier).state = false;
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

class _FreeTag extends StatelessWidget {
  final Color primaryColor;
  const _FreeTag({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priceStatus.values.first.toUpperCase(),
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PremiumTag extends StatelessWidget {
  final Color primaryColor;
  const _PremiumTag({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withValues(alpha: 0.1),
      ),
      child: Image.asset(premiumImage, fit: BoxFit.contain, height: 22, width: 22),
    );
  }
}

