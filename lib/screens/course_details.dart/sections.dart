import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/theme/theme_provider.dart';
import 'package:lms_app/utils/loading_widget.dart';
import '../../models/section.dart';
import '../../services/firebase_service.dart';
import 'lessons.dart';

final sectionsProvider = FutureProvider.family<List<Section>, String>((ref, courseId) async {
  final sections = await FirebaseService().getSections(courseId);
  return sections;
});

final isSectionExpnadedProvider = StateProvider.autoDispose.family<bool, String>((ref, sectionId) => false);

class Sections extends ConsumerWidget {
  const Sections({super.key, required this.course, required this.isInitialSectionOpen});

  final Course course;
  final bool isInitialSectionOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(sectionsProvider(course.id));
    final isDarkMode = ref.watch(themeProvider).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return sections.when(
      error: (e, x) => Container(),
      loading: () => const LoadingIndicatorWidget(),
      data: (sections) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sections.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final Section section = sections[index];
            final bool isExpanded = ref.watch(isSectionExpnadedProvider(section.id));
            return Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.indigo.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  maintainState: true,
                  trailing: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(FeatherIcons.chevronDown, color: isDarkMode ? Colors.grey[400] : const Color(0xFF64748B)),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFDE7F0),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          section.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isExpanded
                                ? primaryColor
                                : (isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  initiallyExpanded: index == 0 && isInitialSectionOpen,
                  children: [Lessons(course: course, sectionId: section.id)],
                  onExpansionChanged: (bool value) =>
                      ref.read(isSectionExpnadedProvider(section.id).notifier).update((state) => value),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

