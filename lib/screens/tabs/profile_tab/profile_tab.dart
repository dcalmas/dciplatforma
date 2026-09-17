import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/screens/profile_page.dart';
import 'package:lms_app/components/user_avatar.dart';
import 'package:lms_app/screens/tabs/profile_tab/settings.dart';
import '../../../providers/user_data_provider.dart';
import '../../../utils/next_screen.dart';
import 'gamification_card.dart';
import 'guest_user.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  static const _pink = Color(0xFFF00080);
  static const _lightBg = Color(0xFFFDE9F1);
  static const _iconBg = Color(0xFFFCDCE9);
  static const _navy = Color(0xFF1B1E2E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F111A) : _lightBg,
      body: Stack(
        children: [
          if (!isDarkMode) ...[
            Positioned(
              top: -90,
              right: -70,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pink.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pink.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDarkMode),
                  const SizedBox(height: 16),
                  if (user != null)
                    GestureDetector(
                      onTap: () => NextScreen.iOS(context, const ProfilePage()),
                      child: _buildUserCard(context, user, isDarkMode),
                    )
                  else
                    const GuestUser(),
                  const SizedBox(height: 10),
                  if (user != null) ...[
                    const GamificationCard(),
                    const SizedBox(height: 10),
                  ],
                  const AppSettings(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                  color: isDarkMode ? Colors.white : _navy,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: _pink),
                  const SizedBox(width: 6),
                  Text(
                    'profile-subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isDarkMode)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'profile-tagline-1',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    color: _pink,
                    height: 1.1,
                  ),
                ).tr(),
                const Text(
                  'profile-tagline-2',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: _pink,
                    height: 1.1,
                  ),
                ).tr(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, dynamic user, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : _pink.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _iconBg,
            ),
            child: UserAvatar(
              imageUrl: user.imageUrl,
              radius: 24,
              iconSize: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: isDarkMode ? Colors.white : _navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 22,
            color: isDarkMode ? Colors.grey[500] : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}
