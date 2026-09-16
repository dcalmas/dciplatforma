import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/screens/home/home_view.dart';
import 'package:lms_app/theme/theme_provider.dart';

const List<Map<String, dynamic>> homeTabItems = [
  {'key': 'courses', 'icon': FeatherIcons.home, 'label': 'home'},
  {'key': 'all-courses', 'icon': FeatherIcons.bookOpen, 'label': 'all-courses'},
  {'key': 'my-courses', 'icon': LineIcons.graduationCap, 'label': 'my-courses'},
  {'key': 'profile', 'icon': FeatherIcons.user, 'label': 'menu'},
];

final navBarIndexProvider = StateProvider<int>((ref) => 0);

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navBarIndexProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    const pink = Color(0xFFF00080);
    const pinkSoft = Color(0xFFFCDCE9);
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        width: screenWidth * 0.92,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.4)
                  : pink.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 10),
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
                final controller = ref.read(homeTabControllerProvider);
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
                  horizontal: isSelected ? 16 : 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDarkMode ? pink.withValues(alpha: 0.2) : pinkSoft)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isSelected
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item['icon'] as IconData, size: 22, color: pink),
                          const SizedBox(width: 6),
                          Text(
                            (item['label'] as String).tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 22,
                            color: isDarkMode ? Colors.grey[500] : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            (item['label'] as String).tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[500] : const Color(0xFF9CA3AF),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
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
