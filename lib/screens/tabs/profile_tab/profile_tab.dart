import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/components/user_avatar.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/providers/app_settings_provider.dart';
import 'package:lms_app/screens/certificates/my_certificates.dart';
import 'package:lms_app/screens/profile_page.dart';
import 'package:lms_app/screens/tabs/assignments_tab/assignments_tab.dart';
import 'package:lms_app/screens/tabs/my_courses_tab/my_courses_tab.dart';
import 'package:lms_app/screens/tabs/profile_tab/settings_page.dart';
import 'package:lms_app/services/app_service.dart';
import 'package:lms_app/services/gamification_service.dart';
import 'package:lms_app/utils/logout_dialog.dart';
import '../../../providers/user_data_provider.dart';
import '../../../utils/next_screen.dart';
import '../../../utils/snackbars.dart';
import 'guest_user.dart';

/// Профиль беті — скриншот дизайны:
/// hero-карта (корона-сурет + деңгей прогресі),
/// «Курс завершен» картасы, «Мои разделы» 6 плиткасы,
/// төменде «Продолжайте обучение» баннері (колпак-сурет).
class ProfileTab extends ConsumerWidget with UserMixin {
  const ProfileTab({super.key});

  static const _pink = Color(0xFFF50078);
  static const _violet = Color(0xFFA855F7);
  static const _lightBg = Color(0xFFFFF8FC);
  static const _navy = Color(0xFF1B1E2E);
  static const _darkBg = Color(0xFF0F111A);
  static const _darkCard = Color(0xFF1E202C);

  static const crownAsset = 'assets/images/crown_3d.png';
  static const gradCapAsset = 'assets/images/grad_cap_3d.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? _darkBg : _lightBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F111A),
              Color(0xFF12141E),
              Color(0xFF19131B),
            ],
            stops: [0.0, 0.58, 1.0],
          )
              : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFBFD),
              Color(0xFFFFF8FB),
              Color(0xFFFFEAF4),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 4,
              bottom: 86,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(isDarkMode: isDarkMode),
                const SizedBox(height: 10),
                if (user != null) ...[
                  const _HeroCard(),
                  const SizedBox(height: 8),
                  _CourseCompletedCard(isDarkMode: isDarkMode),
                  const SizedBox(height: 10),
                  _SectionsGrid(isDarkMode: isDarkMode),
                  const SizedBox(height: 10),
                  _ContinueBanner(isDarkMode: isDarkMode),
                ] else
                  const GuestUser(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header: Title + Subtitle + Settings icon ───
class _Header extends StatelessWidget {
  const _Header({required this.isDarkMode});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 27,
                  letterSpacing: -0.5,
                  color: isDarkMode ? Colors.white : ProfileTab._navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'profile-subtitle'.tr(),
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDarkMode ? Colors.grey[400] : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => NextScreen.iOS(context, const SettingsPage()),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDarkMode ? ProfileTab._darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.2)
                      : ProfileTab._pink.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.settings_outlined,
              size: 21,
              color: isDarkMode ? Colors.grey[300] : ProfileTab._navy,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Card: avatar + name + level + crown image + XP progress ───
class _HeroCard extends ConsumerWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    if (user == null) return const SizedBox.shrink();

    final settingsAsync = ref.watch(gamificationSettingsProvider);
    final settings = settingsAsync.valueOrNull ?? GamificationService.defaults;
    final service = GamificationService()..setCachedSettings(settings);
    final gamEnabled =
        settings['enabled'] != false && service.enabled;

    final xp = user.xp ?? 0;
    final level = service.getLevel(xp);
    final nextLevel = service.getNextLevel(xp);
    final cur = (level['xpRequired'] as num?)?.toInt() ?? 0;
    final next = nextLevel?['xpRequired'] as num?;
    final double progress = next == null
        ? 1.0
        : (((xp - cur) / (next.toInt() - cur)).clamp(0.0, 1.0)).toDouble();
    final levelName = service.levelName(
      context.locale.languageCode,
      level,
    );
    final nextName = nextLevel == null
        ? null
        : service.levelName(context.locale.languageCode, nextLevel);
    final levelNum = level['level']?.toString() ?? '1';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF50078),
            Color(0xFFFF5CA8),
            ProfileTab._violet,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ProfileTab._pink.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          NextScreen.iOS(context, const ProfilePage()),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                Colors.white.withValues(alpha: 0.95),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 88,
                              height: 88,
                              child: UserAvatar(
                                imageUrl: user.imageUrl,
                                radius: 54,
                                iconSize: 42,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ProfileTab._pink.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: ProfileTab._pink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 92),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                height: 1.1,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (gamEnabled) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: 0.22,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  levelName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (gamEnabled) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showStatisticsModal(
                      context,
                      ref,
                      Theme.of(context).brightness == Brightness.dark,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$levelNum ${'level'.tr()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color:
                                Colors.white.withValues(alpha: 0.7),
                              ),
                              const Spacer(),
                              Text(
                                next == null
                                    ? '$xp XP'
                                    : '$xp / ${next.toInt()} XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 7,
                              backgroundColor:
                              Colors.white.withValues(alpha: 0.25),
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nextName == null
                                ? 'max-level'.tr()
                                : 'level-progress'.tr(
                              namedArgs: {'level': nextName},
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                              Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 4,
            top: 2,
            child: Image.asset(
              ProfileTab.crownAsset,
              width: 118,
              height: 118,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Padding(
                padding: EdgeInsets.all(22),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── «Курс завершен» картасы ───
class _CourseCompletedCard extends StatelessWidget {
  const _CourseCompletedCard({required this.isDarkMode});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDarkMode ? Colors.white : ProfileTab._navy;
    final mutedColor =
    isDarkMode ? Colors.grey[400]! : const Color(0xFF8B92A1);

    return GestureDetector(
      onTap: () => NextScreen.iOS(context, const MyCoursesTab()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? ProfileTab._darkCard
              : const Color(0xFFFFF2F7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDarkMode ? 0.18 : 0.035,
              ),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ProfileTab._pink.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 22,
                color: ProfileTab._pink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'course-completed'.tr(),
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'course-completed-subtitle'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ProfileTab._pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── «Мои разделы»: 6 плитка ───
class _SectionsGrid extends ConsumerWidget with UserMixin {
  const _SectionsGrid({required this.isDarkMode});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final enrolled = user?.enrolledCourses?.length ?? 0;
    final settings = ref.watch(appSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'my-sections'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
            color: isDarkMode ? Colors.white : ProfileTab._navy,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.03,
          children: [
            _SectionTile(
              icon: Icons.menu_book_rounded,
              color: const Color(0xFFF50078),
              title: 'my-courses'.tr(),
              subtitle: _coursesCount(context, enrolled),
              isDarkMode: isDarkMode,
              onTap: () =>
                  NextScreen.iOS(context, const MyCoursesTab()),
            ),
            _SectionTile(
              icon: Icons.assignment_rounded,
              color: const Color(0xFF3B82F6),
              title: 'my-assignments'.tr(),
              subtitle: 'check-and-results'.tr(),
              isDarkMode: isDarkMode,
              onTap: () =>
                  NextScreen.iOS(context, const AssignmentsTab()),
            ),
            _SectionTile(
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFF59E0B),
              title: 'certificates'.tr(),
              subtitle: 'your-achievements'.tr(),
              isDarkMode: isDarkMode,
              onTap: () =>
                  NextScreen.iOS(context, const MyCertificates()),
            ),
            _SectionTile(
              icon: Icons.settings_rounded,
              color: const Color(0xFF8B5CF6),
              title: 'settings'.tr(),
              subtitle: 'settings-subtitle'.tr(),
              isDarkMode: isDarkMode,
              onTap: () =>
                  NextScreen.iOS(context, const SettingsPage()),
            ),
            _SectionTile(
              icon: Icons.help_rounded,
              color: const Color(0xFF10B981),
              title: 'help-support'.tr(),
              subtitle: 'help-subtitle'.tr(),
              isDarkMode: isDarkMode,
              onTap: () {
                final email = settings?.supportEmail ?? '';
                if (email.isEmpty) {
                  openSnackbarFailure(context, 'error'.tr());
                  return;
                }
                AppService().openEmailSupport(email);
              },
            ),
            _SectionTile(
              icon: Icons.exit_to_app_rounded,
              color: const Color(0xFFEF4444),
              title: 'logout'.tr(),
              subtitle: 'finish-session'.tr(),
              isDarkMode: isDarkMode,
              onTap: () => openLogoutDialog(
                context,
                    () => handleLogout(context, ref: ref),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDarkMode
              ? color.withValues(alpha: 0.13)
              : color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 25, color: color),
                Container(
                  width: 23,
                  height: 23,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.2,
                color: isDarkMode ? Colors.white : ProfileTab._navy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode
                    ? Colors.grey[400]
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Төменгі баннер: «Продолжайте обучение» + колпак-сурет ───
class _ContinueBanner extends StatelessWidget {
  const _ContinueBanner({required this.isDarkMode});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NextScreen.iOS(context, const MyCoursesTab()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF1E202C),
              Color(0xFF252132),
              Color(0xFF30223A),
            ],
          )
              : const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFF3F8),
              Color(0xFFFFDDEB),
              Color(0xFFFFB9D8),
            ],
            stops: [0.0, 0.52, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.12)
                  : ProfileTab._pink.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'keep-learning'.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDarkMode
                          ? Colors.grey[400]
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'knowledge-today'.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color:
                      isDarkMode ? Colors.white : ProfileTab._navy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Image.asset(
              ProfileTab.gradCapAsset,
              width: 66,
              height: 66,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school_rounded,
                size: 60,
                color: ProfileTab._pink,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 23,
                color: ProfileTab._pink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Statistics Modal (деңгей қатарын басқанда ашылады) ───
void _showStatisticsModal(
    BuildContext context, WidgetRef ref, bool isDarkMode) {
  final user = ref.read(userDataProvider);
  if (user == null) return;

  final xp = user.xp ?? 0;
  final streak = user.dailyStreak ?? 0;
  final enrolled = user.enrolledCourses?.length ?? 0;
  final rawCompleted = user.completedLessons ?? [];
  final uniqueLessons = rawCompleted
      .map((e) {
    final s = e.toString();
    final idx = s.indexOf('_');
    return idx == -1 ? s : s.substring(idx + 1);
  })
      .toSet()
      .length;
  final badges = user.badges?.length ?? 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[700]
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'my-statistics'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                color: isDarkMode ? Colors.white : ProfileTab._navy,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.85,
              children: [
                _StatTile(
                  value: '$xp XP',
                  label: 'XP',
                  icon: Icons.bolt_rounded,
                  color: ProfileTab._pink,
                  isDarkMode: isDarkMode,
                ),
                _StatTile(
                  value: '$streak',
                  label: 'days-short'.tr(),
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.deepOrange,
                  isDarkMode: isDarkMode,
                ),
                _StatTile(
                  value: '$enrolled',
                  label: 'enrolled-courses'.tr(),
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF3B82F6),
                  isDarkMode: isDarkMode,
                ),
                _StatTile(
                  value: '$uniqueLessons',
                  label: 'completed-lessons'.tr(),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  isDarkMode: isDarkMode,
                ),
                _StatTile(
                  value: '$badges',
                  label: 'total-badges'.tr(),
                  icon: Icons.emoji_events_rounded,
                  color: Colors.amber,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.04)
            : color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : ProfileTab._navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

String _coursesCount(BuildContext context, int n) {
  switch (context.locale.languageCode) {
    case 'ru':
      final mod10 = n % 10;
      final mod100 = n % 100;
      String word;
      if (mod10 == 1 && mod100 != 11) {
        word = 'курс';
      } else if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
        word = 'курса';
      } else {
        word = 'курсов';
      }
      return '$n $word';
    case 'kk':
      return '$n курс';
    default:
      return n == 1 ? '$n course' : '$n courses';
  }
}

