import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/screens/search/recent_searches.dart';
import 'package:lms_app/screens/search/search_bar.dart';
import 'package:lms_app/screens/search/searched_courses.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/empty_icon.dart';

final searchTextCtlrProvider = Provider.autoDispose((ref) {
  final ctlr = TextEditingController();
  ref.onDispose(() => ctlr.dispose());
  return ctlr;
});
final searchStartedProvider = StateProvider.autoDispose<bool>((ref) => false);
final recentSearchDataProvider = StateProvider<List<String>>((ref) => []);

final searchedCoursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final value = ref.watch(searchTextCtlrProvider).text.trim();
  if (value.isEmpty || value.length < 2) return [];
  final allCourses = await FirebaseService().getAllCourses();
  final q = value.toLowerCase();
  final List<Course> filteredCourses = allCourses
      .where((course) =>
          course.name.toLowerCase().contains(q) ||
          course.courseMeta.description.toString().toLowerCase().contains(q) ||
          course.courseMeta.learnings.toString().toLowerCase().contains(q) ||
          course.courseMeta.summary.toString().toLowerCase().contains(q) ||
          course.courseMeta.requirements.toString().toLowerCase().contains(q))
      .take(50)
      .toList();

  return filteredCourses;
});

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchFieldCtrl = ref.watch(searchTextCtlrProvider);
    final bool searchStarted = ref.watch(searchStartedProvider);
    final recentSearchList = ref.watch(recentSearchDataProvider);

    Widget buildView() {
      if (searchStarted) {
        return const SearchedCourses();
      } else {
        if (recentSearchList.isNotEmpty) {
          return const RecentSearches();
        } else {
          return EmptyPageWithIcon(icon: FeatherIcons.search, title: 'search-course'.tr());
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: SearchAppBar(searchTextCtlr: searchFieldCtrl),
        leading: IconButton(
          icon: const Icon(FeatherIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 5),
          Expanded(child: buildView()),
        ],
      ),
    );
  }
}
