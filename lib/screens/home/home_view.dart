import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/screens/home/home_bottom_bar.dart';
import 'package:lms_app/screens/tabs/home_tab/home_tab.dart';
import 'package:lms_app/screens/tabs/profile_tab/profile_tab.dart';
import 'package:lms_app/screens/tabs/tests_tab/tests_tab.dart';
import 'package:lms_app/screens/tabs/all_courses_tab.dart';
import '../tabs/my_courses_tab/my_courses_tab.dart';

final homeTabControllerProvider = StateProvider<PageController>((ref) => PageController(initialPage: 0));

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = ref.watch(homeTabControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE),
      extendBody: true,
      bottomNavigationBar: const BottomBar(),
      body: PageView(
        allowImplicitScrolling: false,
        controller: tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeTab(),
          AllCoursesTab(),
          MyCoursesTab(),
          TestsTab(),
          ProfileTab(),
        ],
      ),
    );
  }
}
