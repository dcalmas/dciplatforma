import 'package:easy_localization/easy_localization.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/category.dart';
import 'package:lms_app/screens/course_details.dart/details_view.dart';
import 'package:lms_app/screens/notifications/notifications.dart';
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

class _HomeTabState extends ConsumerState<HomeTab> with UserMixin, SingleTickerProviderStateMixin {
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

    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
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
                final matchesCategory =
                    _selectedCategoryId == 'all' || course.categoryId == _selectedCategoryId;
                final matchesSearch = _searchQuery.isEmpty ||
                    course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    course.author.name.toLowerCase().contains(_searchQuery.toLowerCase());
                return matchesCategory && matchesSearch;
              }).toList();

              Course? activeCourse;
              if (courses.isNotEmpty) {
                if (user?.enrolledCourses != null && user!.enrolledCourses!.isNotEmpty) {
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
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header
                    _buildTopHeader(context, user, isDarkMode, primaryColor),
                    const SizedBox(height: 20),

                    // Active Course Card ("Continue Learning")
                    if (_searchQuery.isEmpty && activeCourse != null) ...[
                      _buildActiveCourseCard(context, activeCourse, user, primaryColor, isDarkMode),
                      const SizedBox(height: 24),
                    ],

                    // Search & Filter input
                    _buildSearchBar(context, isDarkMode, primaryColor),
                    const SizedBox(height: 18),

                    // Categories Horizontal Selector
                    if (_searchQuery.isEmpty)
                      categoriesState.when(
                        loading: () => const SizedBox(height: 40),
                        error: (err, stack) => const SizedBox(height: 40),
                        data: (categories) => _buildCategoryList(categories, isDarkMode, primaryColor),
                      ),

                    // Header for Search Results or Section Title
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        '${"search".tr()}: "$_searchQuery"',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'courses'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${filteredCourses.length} ${"courses".tr().toLowerCase()}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Staggered Course List
                    if (filteredCourses.isNotEmpty)
                      ListView.builder(
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
                                  CourseDetailsView(course: course, heroTag: UniqueKey()),
                                );
                              },
                              child: _buildCourseCard(context, course, isDarkMode, cardBgColor, primaryColor),
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
                              Icon(LineIcons.inbox, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'no-course'.tr(),
                                style: TextStyle(color: Colors.grey[500], fontSize: 15),
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
    );
  }

  Widget _buildTopHeader(BuildContext context, dynamic user, bool isDarkMode, Color primaryColor) {
    final now = DateTime.now();
    final monthName = DateFormat('d MMM', context.locale.languageCode).format(now);

    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withValues(alpha: 0.1),
            border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 2),
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
                : Icon(LineIcons.user, color: primaryColor, size: 24),
          ),
        ),
        const SizedBox(width: 14),

        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user?.name ?? "Оқушы"} 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'courses'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),

        // Date Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(LineIcons.calendar_alt, size: 14, color: primaryColor),
              const SizedBox(width: 6),
              Text(
                monthName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[300] : const Color(0xFF334155),
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

  Widget _buildActiveCourseCard(
      BuildContext context, Course course, dynamic user, Color primaryColor, bool isDarkMode) {
    final heroTag = UniqueKey();
    final completedCount = user?.completedLessons?.length ?? 0;
    final totalLessons = course.lessonsCount > 0 ? course.lessonsCount : 10;
    final progressRatio = (completedCount / totalLessons).clamp(0.0, 1.0);

    return _BouncingCard(
      onTap: () {
        NextScreen.iOS(context, CourseDetailsView(course: course, heroTag: heroTag));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.85),
              const Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
            topRight: Radius.circular(64),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Soft background circle design element
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge: "Оқуды жалғастыру"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'my-courses'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course Title
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Bottom Row: Duration/Progress + Circular Play Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LineIcons.clock, color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${course.lessonsCount} сабақ',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 140,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressRatio > 0 ? progressRatio : 0.25,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Prominent Circular Play Button
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: primaryColor,
                          size: 32,
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
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDarkMode, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'search-placeholder'.tr(),
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            fontSize: 14,
          ),
          icon: Icon(
            LineIcons.search,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            size: 20,
          ),
          border: InputBorder.none,
          suffixIcon: Icon(
            LineIcons.sliders_h,
            color: primaryColor,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, bool isDarkMode, Color primaryColor) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final categoryId = isAll ? 'all' : categories[index - 1].id;
          final categoryName = isAll ? 'all-categories'.tr() : categories[index - 1].name;
          final isSelected = _selectedCategoryId == categoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryId = categoryId;
                });
                _restartAnimations();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : (isDarkMode ? const Color(0xFF1E202C) : Colors.white),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.grey[300] : const Color(0xFF475569)),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(
      BuildContext context, Course course, bool isDarkMode, Color cardBgColor, Color primaryColor) {
    final heroTag = UniqueKey();
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.indigo.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header Image with Overlay Badges
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Hero(
                  tag: heroTag,
                  child: CustomCacheImage(
                    imageUrl: course.thumbnailUrl,
                    radius: 0,
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.priceStatus == 'free' ? 'free'.tr() : 'premium'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    height: 1.3,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                // Author & Rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.author.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${course.studentsCount})',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  const _NotificationBell({required this.isDarkMode, required this.primaryColor});

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasUnread
                  ? primaryColor.withValues(alpha: 0.12)
                  : (isDarkMode ? const Color(0xFF1E202C) : Colors.white),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  hasUnread ? LineIcons.bell : LineIcons.bell,
                  size: 19,
                  color: hasUnread ? primaryColor : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                ),
                if (hasUnread)
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
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

