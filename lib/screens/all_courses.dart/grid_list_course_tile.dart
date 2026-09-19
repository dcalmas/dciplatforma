import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/components/rating_bar.dart';
import 'package:lms_app/models/category.dart';
import 'package:lms_app/providers/user_data_provider.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/screens/course_details.dart/details_view.dart';
import 'package:lms_app/screens/tabs/home_tab/home_tab.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/custom_cached_image.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';
import '../../models/course.dart';

/// «Курсы» тізім-карточкасы — скриншот дизайны:
/// сурет + санат-бейдж, атау, автор, статистика,
/// жұлдыз + «Бастау» батырмасы, бетбелгі.
class GridListCourseTile extends ConsumerWidget {
  const GridListCourseTile({super.key, required this.course});

  final Course course;

  static const _pink = Color(0xFFF50078);
  static const _navy = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroTag = UniqueKey();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? <Category>[];
    final categoryName = categories
        .where((c) => c.id == course.categoryId)
        .map((c) => c.name)
        .firstOrNull;

    final user = ref.watch(userDataProvider);
    final isSaved =
        user?.wishList?.contains(course.id) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.25)
                : _pink.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => NextScreen.iOS(
            context, CourseDetailsView(course: course, heroTag: heroTag)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail + category badge
              Stack(
                children: [
                  Container(
                    height: 118,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Hero(
                      tag: heroTag,
                      child: CustomCacheImage(
                          imageUrl: course.thumbnailUrl, radius: 14),
                    ),
                  ),
                  if (categoryName != null &&
                      categoryName.trim().isNotEmpty)
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.2,
                              color: isDarkMode ? Colors.white : _navy,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _toggleBookmark(context, ref, isSaved),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 6, bottom: 4),
                            child: Icon(
                              isSaved
                                  ? LineIcons.heartAlt
                                  : FeatherIcons.bookmark,
                              size: 19,
                              color: isSaved
                                  ? _pink
                                  : (isDarkMode
                                      ? Colors.grey[500]
                                      : const Color(0xFF9CA3AF)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By ${course.author.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 7),
                    // Stats row - Wrapped in FittedBox to scale down and prevent overflow on all devices
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _stat(
                            context,
                            icon: Icons.person_outline_rounded,
                            text:
                                '${course.studentsCount} ${_studentsWord(context, course.studentsCount)}',
                            isDarkMode: isDarkMode,
                          ),
                          _dot(isDarkMode),
                          _stat(
                            context,
                            icon: Icons.menu_book_outlined,
                            text:
                                '${course.lessonsCount} ${_lessonsWord(context, course.lessonsCount)}',
                            isDarkMode: isDarkMode,
                          ),
                          if ((course.courseMeta.duration ?? '')
                              .trim()
                              .isNotEmpty) ...[
                            _dot(isDarkMode),
                            _stat(
                              context,
                              icon: Icons.access_time_rounded,
                              text:
                                  course.courseMeta.duration!.trim(),
                              isDarkMode: isDarkMode,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        RatingViewer(rating: course.rating),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => NextScreen.iOS(context,
                              CourseDetailsView(
                                  course: course, heroTag: heroTag)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _pink.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'start-short'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _pink,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 14, color: _pink),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleBookmark(
      BuildContext context, WidgetRef ref, bool isSaved) async {
    final user = ref.read(userDataProvider);
    if (user == null) {
      NextScreen.normal(context, const LoginScreen(popUpScreen: true));
      return;
    }
    openSnackbar(
        context, isSaved ? 'removed-wishlist'.tr() : 'added-wishlist'.tr());
    await FirebaseService().updateWishList(user, course);
    ref.read(userDataProvider.notifier).getData();
  }

  Widget _stat(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool isDarkMode,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDarkMode ? Colors.grey[500] : const Color(0xFF9CA3AF),
        ),
        const SizedBox(width: 3),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _dot(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? Colors.grey[600] : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }

  String _studentsWord(BuildContext context, int n) {
    switch (context.locale.languageCode) {
      case 'ru':
        final m10 = n % 10;
        final m100 = n % 100;
        if (m10 == 1 && m100 != 11) return 'студент';
        if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) {
          return 'студента';
        }
        return 'студентов';
      case 'en':
        return n == 1 ? 'student' : 'students';
      default:
        return 'students-short'.tr();
    }
  }

  String _lessonsWord(BuildContext context, int n) {
    switch (context.locale.languageCode) {
      case 'ru':
        final m10 = n % 10;
        final m100 = n % 100;
        if (m10 == 1 && m100 != 11) return 'урок';
        if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) {
          return 'урока';
        }
        return 'уроков';
      case 'en':
        return n == 1 ? 'lesson' : 'lessons';
      default:
        return 'lessons-short'.tr();
    }
  }
}
