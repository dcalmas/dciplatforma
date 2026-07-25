import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/components/loading_list_tile.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/empty_animation.dart';
import 'package:quiver/iterables.dart';
import 'my_course_tile.dart';
import '../../../providers/user_data_provider.dart';
import '../home_tab/home_tab.dart'; // For StaggeredListItem

final myCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final List<Course> courses = [];
  final user = ref.watch(userDataProvider);
  final courseIds = user?.enrolledCourses ?? [];
  if (courseIds.isEmpty) return [];
  final chunks = partition(courseIds, 10);

  final querySnapshots = await Future.wait(chunks.map((chunk) => FirebaseService().getCoursesQuery(chunk)).toList());
  for (var element in querySnapshots) {
    courses.addAll(element.docs.map((e) => Course.fromFirestore(e)).toList());
  }
  return courses;
});

class MyCoursesTab extends ConsumerStatefulWidget {
  const MyCoursesTab({super.key});

  @override
  ConsumerState<MyCoursesTab> createState() => _MyCoursesTabState();
}

class _MyCoursesTabState extends ConsumerState<MyCoursesTab> with CourseMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDataProvider);
    final courses = ref.watch(myCoursesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('my-courses').tr(),
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(myCoursesProvider);
          _animationController.reset();
          _animationController.forward();
        },
        child: user == null || user.enrolledCourses == null || user.enrolledCourses!.isEmpty
            ? const EmptyAnimation(animationString: emptyAnimation, title: 'No courses found')
            : courses.when(
                skipLoadingOnRefresh: false,
                loading: () => const LoadingListTile(height: 200),
                error: (error, stackTrace) => Center(
                  child: Text(error.toString()),
                ),
                data: (data) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90, top: 16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final Course course = data[index];
                      return StaggeredListItem(
                        index: index,
                        controller: _animationController,
                        child: MyCourseTile(course: course, user: user),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

