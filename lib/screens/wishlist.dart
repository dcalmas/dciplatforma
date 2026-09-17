import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/components/loading_list_tile.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/mixins/course_mixin.dart';
import 'package:lms_app/utils/empty_animation.dart';
import 'package:quiver/iterables.dart';

import '../components/course_tile.dart';
import '../models/course.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';

final wishlistProvider = FutureProvider<List<Course>>((ref) async {
  final List<Course> courses = [];
  final user = ref.watch(userDataProvider);
  if (user == null) return courses;
  final courseIds = user.wishList ?? [];
  if (courseIds.isEmpty) return courses;
  final chunks = partition(courseIds, 10);

  final querySnapshots = await Future.wait(chunks.map((chunk) => FirebaseService().getCoursesQuery(chunk)).toList());
  for (var element in querySnapshots) {
    courses.addAll(element.docs.map((e) => Course.fromFirestore(e)).toList());
  }

  return courses;
});

class Wishlist extends ConsumerWidget with CourseMixin {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final wishlist = ref.watch(wishlistProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('wishlist').tr(),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(FeatherIcons.chevronLeft)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(wishlistProvider),
        child: user == null || user.wishList == null || user.wishList!.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: EmptyAnimation(animationString: emptyAnimation, title: 'no-course'.tr()),
                ),
              )
            : wishlist.when(
                skipLoadingOnRefresh: false,
                loading: () => const LoadingListTile(height: 160),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('error'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.refresh(wishlistProvider),
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (data) {
                  if (data.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: EmptyAnimation(animationString: emptyAnimation, title: 'no-course'.tr()),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: data.length,
                    separatorBuilder: (context, index) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final Course course = data[index];
                      return CourseTile(course: course);
                    },
                  );
                },
              ),
      ),
    );
  }
}
