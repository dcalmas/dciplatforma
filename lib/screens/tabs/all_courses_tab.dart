import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms_app/models/category.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/screens/all_courses.dart/courses_view.dart';
import 'package:lms_app/screens/all_courses.dart/grid_course_tile.dart';
import 'package:lms_app/screens/all_courses.dart/grid_list_course_tile.dart';
import 'package:lms_app/screens/tabs/home_tab/home_tab.dart';
import 'package:lms_app/theme/theme_provider.dart';
import 'package:lms_app/utils/loading_widget.dart';
import 'package:lms_app/utils/next_screen.dart';

final allCoursesViewStyleProvider = StateProvider<bool>((ref) => false);

enum CourseSortOption { none, popular, rating, newest }

/// «Курсы» беті — скриншот дизайны:
/// тақырып + қолжазба-промо, іздеу жолағы,
/// санат/сұрыптау фильтрлері, тізім/тор ауыстырғыш.
class AllCoursesTab extends ConsumerStatefulWidget {
  const AllCoursesTab({super.key});

  @override
  ConsumerState<AllCoursesTab> createState() => _AllCoursesTabState();
}

class _AllCoursesTabState extends ConsumerState<AllCoursesTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _categoryId;
  CourseSortOption _sort = CourseSortOption.none;

  static const _pink = Color(0xFFF50078);
  static const _navy = Color(0xFF0F172A);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Course> _applyFilters(List<Course> courses) {
    final q = _query.toLowerCase();
    final filtered = courses.where((c) {
      if (_categoryId != null && c.categoryId != _categoryId) return false;
      if (q.isNotEmpty &&
          !c.name.toLowerCase().contains(q) &&
          !c.author.name.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();

    switch (_sort) {
      case CourseSortOption.popular:
        filtered.sort((a, b) => b.studentsCount.compareTo(a.studentsCount));
        break;
      case CourseSortOption.rating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case CourseSortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case CourseSortOption.none:
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(allCoursesProvider);
    final isGrid = ref.watch(allCoursesViewStyleProvider);
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final bgColor =
        isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFFFF8FC);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? <Category>[];
    final categoryName = _categoryId == null
        ? null
        : categories
            .where((c) => c.id == _categoryId)
            .map((c) => c.name)
            .firstOrNull;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header: title + promo
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'courses'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            letterSpacing: -0.5,
                            color: isDarkMode ? Colors.white : _navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'courses-subtitle'.tr(),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(
                        FeatherIcons.heart,
                        size: 15,
                        color: _pink,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'invest-in-yourself'.tr(),
                        textAlign: TextAlign.right,
                        style: GoogleFonts.caveat(
                          fontSize: 17,
                          height: 1.05,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: _pink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : _navy,
                ),
                decoration: InputDecoration(
                  hintText: 'search-course-hint'.tr(),
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? Colors.grey[500]
                        : const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: Icon(
                    FeatherIcons.search,
                    size: 19,
                    color: isDarkMode
                        ? Colors.grey[500]
                        : const Color(0xFF9CA3AF),
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: const Color(0xFF9CA3AF),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor:
                      isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: _pink, width: 1.5),
                  ),
                ),
              ),
            ),

            // Filters row: category + sort + view toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  _FilterChip(
                    icon: Icons.filter_list_rounded,
                    label: categoryName ?? 'all-categories'.tr(),
                    isDarkMode: isDarkMode,
                    onTap: () => NextScreen.openBottomSheet(
                      context,
                      _CategorySheet(
                        categories: categories,
                        selectedId: _categoryId,
                        onPick: (id) =>
                            setState(() => _categoryId = id),
                      ),
                      maxHeight: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    icon: Icons.swap_vert_rounded,
                    label: _sort == CourseSortOption.none
                        ? 'sort-by'.tr()
                        : _sortLabel(_sort),
                    isDarkMode: isDarkMode,
                    onTap: () => NextScreen.openBottomSheet(
                      context,
                      _SortSheet(
                        selected: _sort,
                        onPick: (s) => setState(() => _sort = s),
                      ),
                      maxHeight: 0.55,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E202C)
                          : const Color(0xFFF1F2F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleBtn(
                          icon: Icons.view_list_rounded,
                          isActive: !isGrid,
                          onTap: () => ref
                              .read(allCoursesViewStyleProvider.notifier)
                              .state = false,
                          isDarkMode: isDarkMode,
                        ),
                        _buildToggleBtn(
                          icon: Icons.grid_view_rounded,
                          isActive: isGrid,
                          onTap: () => ref
                              .read(allCoursesViewStyleProvider.notifier)
                              .state = true,
                          isDarkMode: isDarkMode,
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
                  loading: () =>
                      const Center(child: LoadingIndicatorWidget()),
                  error: (error, stack) => Center(
                    child: Text('error: $error',
                        style: const TextStyle(color: Colors.red)),
                  ),
                  data: (courses) {
                    final list = _applyFilters(courses);
                    if (list.isEmpty) {
                      return ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.25),
                          Center(
                            child: Icon(FeatherIcons.bookOpen,
                                size: 56, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'no-course'.tr(),
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 15),
                            ),
                          ),
                        ],
                      );
                    }

                    if (isGrid) {
                      return GridView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(14, 4, 14, 90),
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) => GridCourseTile(
                            course: list[index],
                            gridStyle: GridStyle.grid),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      itemCount: list.length,
                      itemBuilder: (context, index) =>
                          GridListCourseTile(course: list[index]),
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

  String _sortLabel(CourseSortOption s) {
    switch (s) {
      case CourseSortOption.popular:
        return 'sort-popular'.tr();
      case CourseSortOption.rating:
        return 'sort-rating'.tr();
      case CourseSortOption.newest:
        return 'sort-newest'.tr();
      case CourseSortOption.none:
        return 'sort-by'.tr();
    }
  }

  Widget _buildToggleBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? _pink : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isActive
              ? Colors.white
              : (isDarkMode ? Colors.grey[500] : Colors.grey[400]),
        ),
      ),
    );
  }
}

// ─── Filter chip ───
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
            Icon(icon,
                size: 16,
                color: isDarkMode
                    ? Colors.grey[400]
                    : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? Colors.grey[200]
                      : const Color(0xFF374151),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 17, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

// ─── Category bottom sheet ───
class _CategorySheet extends StatelessWidget {
  const _CategorySheet({
    required this.categories,
    required this.selectedId,
    required this.onPick,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onPick;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[700]
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'all-categories'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _sheetOption(
                  context,
                  title: 'all-categories'.tr(),
                  selected: selectedId == null,
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    onPick(null);
                  },
                ),
                for (final c in categories)
                  _sheetOption(
                    context,
                    title: c.name,
                    selected: selectedId == c.id,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.pop(context);
                      onPick(c.id);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sort bottom sheet ───
class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selected, required this.onPick});

  final CourseSortOption selected;
  final ValueChanged<CourseSortOption> onPick;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final options = [
      CourseSortOption.popular,
      CourseSortOption.rating,
      CourseSortOption.newest,
    ];
    String label(CourseSortOption s) {
      switch (s) {
        case CourseSortOption.popular:
          return 'sort-popular'.tr();
        case CourseSortOption.rating:
          return 'sort-rating'.tr();
        case CourseSortOption.newest:
          return 'sort-newest'.tr();
        case CourseSortOption.none:
          return 'sort-by'.tr();
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[700]
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'sort-by'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          for (final o in options)
            _sheetOption(
              context,
              title: label(o),
              selected: selected == o,
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pop(context);
                onPick(o);
              },
            ),
        ],
      ),
    );
  }
}

Widget _sheetOption(
  BuildContext context, {
  required String title,
  required bool selected,
  required bool isDarkMode,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight:
                    selected ? FontWeight.w800 : FontWeight.w500,
                color: selected
                    ? const Color(0xFFF50078)
                    : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_rounded,
                size: 20, color: Color(0xFFF50078)),
        ],
      ),
    ),
  );
}
