import 'home_course_cards.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/category.dart';
import 'package:lms_app/screens/course_details.dart/details_view.dart';
import 'package:lms_app/screens/notifications/notifications.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/screens/profile_page.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/custom_cached_image.dart';
import 'package:lms_app/utils/loading_widget.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/providers/user_data_provider.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/constants/app_constants.dart';
import 'package:lms_app/models/notification_model.dart';

final allCoursesProvider = FutureProvider<List<Course>>((ref) async {
  return await FirebaseService().getAllCourses();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return await FirebaseService().getAllCategories();
});

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with UserMixin, SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryId = 'all';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _restartAnimations() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(allCoursesProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final bgColor =
        isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Top Header with gradient background and subtle divider
          Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF7F6FB)],
                    ),
              color: isDarkMode ? const Color(0xFF0F111A) : null,
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0x0F000000),
                  width: 1,
                ),
              ),
              boxShadow: isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 8, 16, 10),
            child: _buildTopHeader(context, user, isDarkMode, primaryColor),
          ),
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () async {
                ref.invalidate(allCoursesProvider);
                ref.invalidate(categoriesProvider);
                _restartAnimations();
              },
              child: coursesState.when(
                loading: () => const Center(child: LoadingIndicatorWidget()),
                error: (error, stack) => Center(
                  child: Text(
                    'error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                data: (courses) {
                  final List<Course> filteredCourses = courses.where((course) {
                    final matchesCategory = _selectedCategoryId == 'all' ||
                        course.categoryId == _selectedCategoryId;
                    final matchesSearch = _searchQuery.isEmpty ||
                        course.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        course.author.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                    return matchesCategory && matchesSearch;
                  }).toList();

                  Course? activeCourse;
                  if (courses.isNotEmpty) {
                    if (user?.enrolledCourses != null &&
                        user!.enrolledCourses!.isNotEmpty) {
                      final enrolledId = user.enrolledCourses!.last;
                      activeCourse = courses.firstWhere(
                        (c) => c.id == enrolledId,
                        orElse: () => courses.first,
                      );
                    } else {
                      activeCourse = courses.first;
                    }
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 10, bottom: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Course Card ("Continue Learning")
                        if (_searchQuery.isEmpty && activeCourse != null) ...[
                          _buildActiveCourseCard(context, activeCourse, user,
                              primaryColor, isDarkMode),
                          const SizedBox(height: 14),
                        ],

                        // Search & Filter input
                        _buildSearchBar(context, isDarkMode, primaryColor),
                        const SizedBox(height: 16),

                        // Categories Horizontal Selector
                        if (_searchQuery.isEmpty)
                          categoriesState.when(
                            loading: () => const SizedBox(height: 44),
                            error: (err, stack) => _buildCategoryList(
                                [], isDarkMode, primaryColor),
                            data: (categories) => _buildCategoryList(
                                categories, isDarkMode, primaryColor),
                          ),

                        // Header for Search Results or Section Title
                        if (_searchQuery.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              '${"search".tr()}: "$_searchQuery"',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'courses'.tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  '${filteredCourses.length} ${"courses".tr().toLowerCase()}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Staggered Course List
                        if (filteredCourses.isNotEmpty)
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = filteredCourses[index];
                              return StaggeredListItem(
                                index: index,
                                controller: _animationController,
                                child: _BouncingCard(
                                  onTap: () {
                                    NextScreen.iOS(
                                      context,
                                      CourseDetailsView(
                                          course: course, heroTag: UniqueKey()),
                                    );
                                  },
                                  child: _buildCourseCard(context, course,
                                      isDarkMode, cardBgColor, primaryColor),
                                ),
                              );
                            },
                          ),

                        // Empty State
                        if (filteredCourses.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              child: Column(
                                children: [
                                  Icon(FeatherIcons.inbox,
                                      size: 48, color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'no-course'.tr(),
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(
      BuildContext context, dynamic user, bool isDarkMode, Color primaryColor) {
    final now = DateTime.now();
    final monthName =
        DateFormat('d MMM', context.locale.languageCode).format(now);

    return Row(
      children: [
        // Profile Avatar
        GestureDetector(
          onTap: () {
            final currentUser = ref.read(userDataProvider);
            if (currentUser == null) {
              NextScreen.normal(
                  context, const LoginScreen(popUpScreen: true));
            } else {
              NextScreen.iOS(context, const ProfilePage());
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.1),
              border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                  ? CustomCacheImage(imageUrl: user.imageUrl, radius: 24)
                  : Icon(FeatherIcons.user, color: primaryColor, size: 24),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user?.name ?? 'student'.tr()} 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'home-continue-learning'.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),

        // Date Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(FeatherIcons.calendar, size: 15, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                monthName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color:
                      isDarkMode ? Colors.grey[300] : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Notification Bell
        _NotificationBell(isDarkMode: isDarkMode, primaryColor: primaryColor),
      ],
    );
  }

  Widget _buildActiveCourseCard(BuildContext context, Course course,
      dynamic user, Color primaryColor, bool isDarkMode) {
    return _BouncingCard(
      onTap: () => NextScreen.iOS(context, CourseDetailsView(course: course)),
      child: HomeCourseBanner(course: course, user: user),
    );
  }

  Widget _buildSearchBar(
      BuildContext context, bool isDarkMode, Color primaryColor) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
          _restartAnimations();
        },
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'search-placeholder'.tr(),
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            fontSize: 13,
          ),
          icon: Icon(
            FeatherIcons.search,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            size: 21,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  IconData _categoryIcon(String name) {
    final label = name.toLowerCase();
    if (RegExp(r'design|дизайн|ui/ux|граф').hasMatch(label)) {
      return Icons.palette_outlined;
    }
    if (RegExp(r'business|бизнес|маркет|қаржы|финанс').hasMatch(label)) {
      return Icons.bar_chart_rounded;
    }
    if (RegExp(r'code|program|програм|web|веб|it|технолог').hasMatch(label)) {
      return Icons.laptop_mac_rounded;
    }
    if (RegExp(r'язык|тіл|language').hasMatch(label)) {
      return Icons.language_rounded;
    }
    if (RegExp(r'текст|копирайт|writing').hasMatch(label)) {
      return Icons.edit_note_rounded;
    }
    return Icons.auto_stories_outlined;
  }

  Widget _buildCategoryList(
      List<Category> categories, bool isDarkMode, Color primaryColor) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 18),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final categoryId = isAll ? 'all' : categories[index - 1].id;
          final name = isAll ? 'home-all'.tr() : categories[index - 1].name;
          final selected = _selectedCategoryId == categoryId;
          final color = selected
              ? primaryColor
              : (isDarkMode ? Colors.grey.shade300 : const Color(0xFF686B82));
          return ActionChip(
            onPressed: () {
              setState(() => _selectedCategoryId = categoryId);
              _restartAnimations();
            },
            avatar: Icon(isAll ? Icons.grid_view_rounded : _categoryIcon(name),
                size: 18, color: color),
            label: Text(name,
                style: TextStyle(
                    fontSize: 12, color: color, fontWeight: FontWeight.w600)),
            backgroundColor: selected
                ? primaryColor.withValues(alpha: .12)
                : (isDarkMode ? const Color(0xFF1E202C) : Colors.white),
            side: BorderSide.none,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course, bool isDarkMode,
      Color cardBgColor, Color primaryColor) {
    final categories =
        ref.watch(categoriesProvider).asData?.value ?? <Category>[];
    String? categoryName;
    for (final category in categories) {
      if (category.id == course.categoryId) {
        categoryName = category.name;
        break;
      }
    }
    return HomeCourseCard(
        course: course,
        user: ref.watch(userDataProvider),
        categoryName: categoryName);
  }
}

// Staggered Entry Animation Wrapper
class StaggeredListItem extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double start = (index * 0.1).clamp(0.0, 0.7);
    final double end = (start + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * 35),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor;

  const _NotificationBell(
      {required this.isDarkMode, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final notificationList = Hive.box(notificationTag);

    return ValueListenableBuilder(
      valueListenable: notificationList.listenable(),
      builder: (context, value, child) {
        List items = notificationList.values.toList();
        List<NotificationModel> notifications =
            items.map((e) => NotificationModel.fromHive(e)).toList();
        final hasUnread = notifications.any((n) => n.read != true);

        return GestureDetector(
          onTap: () => NextScreen.iOS(context, const Notifications()),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasUnread
                  ? primaryColor.withValues(alpha: 0.12)
                  : (isDarkMode ? const Color(0xFF1E202C) : Colors.white),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  hasUnread ? FeatherIcons.bell : FeatherIcons.bell,
                  size: 20,
                  color: hasUnread
                      ? primaryColor
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
                if (hasUnread)
                  Positioned(
                    top: 8,
                    right: 9,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Bouncing Card Touch Micro-interaction
class _BouncingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncingCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_BouncingCard> createState() => _BouncingCardState();
}

class _BouncingCardState extends State<_BouncingCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.97);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
