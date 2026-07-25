import 'package:easy_localization/easy_localization.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/screens/all_courses.dart/courses_view.dart';
import 'package:lms_app/screens/all_courses.dart/grid_course_tile.dart';
import 'package:lms_app/screens/all_courses.dart/grid_list_course_tile.dart';
import 'package:lms_app/screens/tabs/home_tab/home_tab.dart';
import 'package:lms_app/theme/theme_provider.dart';
import 'package:lms_app/utils/loading_widget.dart';

final allCoursesViewStyleProvider = StateProvider<bool>((ref) => false);

class AllCoursesTab extends ConsumerWidget {
  const AllCoursesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesState = ref.watch(allCoursesProvider);
    final isGrid = ref.watch(allCoursesViewStyleProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'courses'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  // Grid/List toggle
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleBtn(
                          context,
                          icon: LineIcons.list,
                          isActive: !isGrid,
                          onTap: () => ref.read(allCoursesViewStyleProvider.notifier).state = false,
                          primaryColor: primaryColor,
                          isDarkMode: isDarkMode,
                        ),
                        _buildToggleBtn(
                          context,
                          icon: LineIcons.th_large,
                          isActive: isGrid,
                          onTap: () => ref.read(allCoursesViewStyleProvider.notifier).state = true,
                          primaryColor: primaryColor,
                          isDarkMode: isDarkMode,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Course list
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: () async => ref.invalidate(allCoursesProvider),
                child: coursesState.when(
                  loading: () => const Center(child: LoadingIndicatorWidget()),
                  error: (error, stack) => Center(
                    child: Text('error: $error', style: const TextStyle(color: Colors.red)),
                  ),
                  data: (courses) {
                    if (courses.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(
                            child: Icon(LineIcons.book_open, size: 56, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'no-course'.tr(),
                              style: TextStyle(color: Colors.grey[500], fontSize: 15),
                            ),
                          ),
                        ],
                      );
                    }

                    if (isGrid) {
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 250,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: courses.length,
                        itemBuilder: (context, index) => GridCourseTile(course: courses[index], gridStyle: GridStyle.grid),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: courses.length,
                      itemBuilder: (context, index) => GridListCourseTile(course: courses[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDarkMode,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            right: isLast ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
        ),
      ),
    );
  }
}
