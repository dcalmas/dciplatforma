import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/screens/tabs/assignments_tab/assignments_tab.dart';
import '../../../configs/features_config.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/user_data_provider.dart';
import '../../auth/delete_account.dart';
import '../../../components/languages.dart';
import '../../../services/app_service.dart';
import '../../../services/notification_service.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/logout_dialog.dart';
import '../../../utils/next_screen.dart';

class AppSettings extends ConsumerWidget with UserMixin {
  const AppSettings({super.key});

  static const _pink = Color(0xFFF00080);
  static const _iconBg = Color(0xFFFCDCE9);
  static const _navy = Color(0xFF1B1E2E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool notificationEnabled = ref.watch(nProvider);
    final settings = ref.watch(appSettingsProvider);
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Настройки', isDarkMode),
        _buildCardContainer(
          cardBgColor,
          isDarkMode,
          [
            _buildSettingTile(
              icon: notificationEnabled ? LineIcons.bell : LineIcons.bellSlash,
              title: 'notifications'.tr(),
              isDarkMode: isDarkMode,
              trailing: Switch.adaptive(
                value: notificationEnabled,
                activeThumbColor: _pink,
                activeTrackColor: _pink.withValues(alpha: 0.4),
                onChanged: (value) => NotificationService().handleSubscription(context, value, ref),
              ),
            ),
            _divider(),
            _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'dark-mode'.tr(),
              isDarkMode: isDarkMode,
              trailing: Switch.adaptive(
                value: ref.watch(themeProvider).isDarkMode,
                activeThumbColor: _pink,
                activeTrackColor: _pink.withValues(alpha: 0.4),
                onChanged: (value) => ref.read(themeProvider.notifier).changeTheme(value),
              ),
            ),
            if (isMultilanguageEnbled) ...[
              _divider(),
              _buildSettingTile(
                icon: LineIcons.language,
                title: 'language'.tr(),
                isDarkMode: isDarkMode,
                onTap: () => NextScreen.openBottomSheet(context, const Languages()),
              ),
            ],
            _divider(),
            _buildSettingTile(
              icon: LineIcons.lock,
              title: 'privacy-policy'.tr(),
              isDarkMode: isDarkMode,
              onTap: () => AppService().openLinkWithCustomTab(settings?.privacyUrl ?? ''),
            ),
            _divider(),
            _buildSettingTile(
              icon: LineIcons.envelope,
              title: 'contact-us'.tr(),
              isDarkMode: isDarkMode,
              onTap: () => AppService().openEmailSupport(settings?.supportEmail ?? ''),
            ),
            _divider(),
            _buildSettingTile(
              icon: LineIcons.star,
              title: 'rate-app'.tr(),
              isDarkMode: isDarkMode,
              onTap: () => AppService().launchAppReview(context),
            ),
          ],
        ),

        if (user != null) ...[
          const SizedBox(height: 14),
          _buildCardContainer(
            cardBgColor,
            isDarkMode,
            [
              _buildSettingTile(
                icon: FeatherIcons.fileText,
                title: 'assignments'.tr(),
                isDarkMode: isDarkMode,
                onTap: () => NextScreen.iOS(context, const AssignmentsTab()),
              ),
              _divider(),
              _buildSettingTile(
                icon: LineIcons.userCog,
                title: 'account-control'.tr(),
                isDarkMode: isDarkMode,
                onTap: () => NextScreen.iOS(context, const DeleteAccount()),
              ),
              _divider(),
              _buildSettingTile(
                icon: FeatherIcons.logOut,
                title: 'logout'.tr(),
                isDarkMode: isDarkMode,
                iconColor: Colors.redAccent,
                onTap: () => openLogoutDialog(context, () => handleLogout(context, ref: ref)),
              ),
            ],
          ),
        ],

        if (_hasSocial(settings)) ...[
          const SizedBox(height: 14),
          _buildSectionHeader('social'.tr(), isDarkMode),
          _buildCardContainer(
            cardBgColor,
            isDarkMode,
            [
              if (settings?.social?.fb != null)
                _buildSettingTile(
                  icon: LineIcons.facebook,
                  title: 'facebook'.tr(),
                  isDarkMode: isDarkMode,
                  onTap: () => AppService().openLink(settings!.social!.fb!),
                ),
              if (settings?.social?.youtube != null) ...[
                _divider(),
                _buildSettingTile(
                  icon: LineIcons.youtube,
                  title: 'youtube'.tr(),
                  isDarkMode: isDarkMode,
                  onTap: () => AppService().openLink(settings!.social!.youtube!),
                ),
              ],
              if (settings?.social?.twitter != null) ...[
                _divider(),
                _buildSettingTile(
                  icon: FeatherIcons.twitter,
                  title: 'twitter'.tr(),
                  isDarkMode: isDarkMode,
                  onTap: () => AppService().openLink(settings!.social!.twitter!),
                ),
              ],
              if (settings?.social?.instagram != null) ...[
                _divider(),
                _buildSettingTile(
                  icon: FeatherIcons.instagram,
                  title: 'instagram'.tr(),
                  isDarkMode: isDarkMode,
                  onTap: () => AppService().openLink(settings!.social!.instagram!),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  bool _hasSocial(dynamic settings) {
    final social = settings?.social;
    if (social == null) return false;
    return social.fb != null ||
        social.youtube != null ||
        social.twitter != null ||
        social.instagram != null;
  }

  Widget _divider() => const Divider(height: 1, indent: 66, endIndent: 16, color: Color(0xFFF1F2F6));

  Widget _buildSectionHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDarkMode ? Colors.grey[400] : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildCardContainer(Color cardBgColor, bool isDarkMode, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : _pink.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool isDarkMode,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final iconFg = iconColor ?? _pink;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDarkMode ? iconFg.withValues(alpha: 0.15) : _iconBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: iconFg),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15.5,
          color: isDarkMode ? Colors.white : _navy,
        ),
      ),
      trailing: trailing ??
          Icon(FeatherIcons.chevronRight, size: 20, color: Colors.grey[400]),
    );
  }
}
