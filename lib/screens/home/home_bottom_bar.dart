import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/screens/home/home_view.dart';
import 'package:lms_app/theme/theme_provider.dart';

const List<Map<String, dynamic>> homeTabItems = [
  {'key': 'courses', 'icon': LineIcons.home, 'label': 'home'},
  {'key': 'all-courses', 'icon': LineIcons.book_open, 'label': 'all-courses'},
  {'key': 'my-courses', 'icon': LineIcons.graduationCap, 'label': 'my-courses'},
  {'key': 'tests', 'icon': LineIcons.bar_chart, 'label': 'tests'},
  {'key': 'profile', 'icon': LineIcons.user, 'label': 'menu'},
];

final navBarIndexProvider = StateProvider<int>((ref) => 0);

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navBarIndexProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return SafeArea(
      child: Container(
        height: 72,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.indigo.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(homeTabItems.length, (index) {
            final item = homeTabItems[index];
            final isSelected = currentIndex == index;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(navBarIndexProvider.notifier).state = index;
                final controller = ref.read(homeTabControllerProvider.notifier).state;
                if (_shouldAnimate(currentIndex, index)) {
                  controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                } else {
                  controller.jumpToPage(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.15),
                            primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: isSelected ? 22 : 21,
                      color: isSelected
                          ? primaryColor
                          : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: isSelected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                (item['label'] as String).tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  bool _shouldAnimate(int currentIndex, int newIndex) {
    int dif = currentIndex - newIndex;
    return dif >= -1 && dif <= 1;
  }
}
