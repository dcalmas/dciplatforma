import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/mixins/user_mixin.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool notificationEnabled = ref.watch(nProvider);
    final settings = ref.watch(appSettingsProvider);
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'settings'.tr(), isDarkMode),
        _buildCardContainer(
          cardBgColor,
          isDarkMode,
          [
            _buildSettingTile(
              icon: notificationEnabled ? LineIcons.bell : LineIcons.bellSlash,
              title: 'notifications'.tr(),
              primaryColor: primaryColor,
              isDarkMode: isDarkMode,
              trailing: Switch.adaptive(
                value: notificationEnabled,
                onChanged: (value) => NotificationService().handleSubscription(context, value, ref),
              ),
            ),
            const Divider(height: 1, indent: 58),
            _buildSettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'dark-mode'.tr(),
              primaryColor: primaryColor,
              isDarkMode: isDarkMode,
              trailing: Switch.adaptive(
                value: ref.watch(themeProvider).isDarkMode,
                onChanged: (value) => ref.read(themeProvider.notifier).changeTheme(value),
              ),
            ),
            if (isMultilanguageEnbled) ...[
              const Divider(height: 1, indent: 58),
              _buildSettingTile(
                icon: LineIcons.language,
                title: 'language'.tr(),
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                onTap: () => NextScreen.openBottomSheet(context, const Languages()),
              ),
            ],
            const Divider(height: 1, indent: 58),
            _buildSettingTile(
              icon: LineIcons.lock,
              title: 'privacy-policy'.tr(),
              primaryColor: primaryColor,
              isDarkMode: isDarkMode,
              onTap: () => AppService().openLinkWithCustomTab(settings?.privacyUrl ?? ''),
            ),
            const Divider(height: 1, indent: 58),
            _buildSettingTile(
              icon: LineIcons.envelope,
              title: 'contact-us'.tr(),
              primaryColor: primaryColor,
              isDarkMode: isDarkMode,
              onTap: () => AppService().openEmailSupport(settings?.supportEmail ?? ''),
            ),
            const Divider(height: 1, indent: 58),
            _buildSettingTile(
              icon: LineIcons.star,
              title: 'rate-app'.tr(),
              primaryColor: primaryColor,
              isDarkMode: isDarkMode,
              onTap: () => AppService().launchAppReview(context),
            ),
          ],
        ),

        if (user != null) ...[
          const SizedBox(height: 16),
          _buildCardContainer(
            cardBgColor,
            isDarkMode,
            [
              _buildSettingTile(
                icon: LineIcons.userCog,
                title: 'account-control'.tr(),
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                onTap: () => NextScreen.iOS(context, const DeleteAccount()),
              ),
              const Divider(height: 1, indent: 58),
              _buildSettingTile(
                icon: FeatherIcons.logOut,
                title: 'logout'.tr(),
                primaryColor: Colors.redAccent,
                isDarkMode: isDarkMode,
                iconColor: Colors.redAccent,
                onTap: () => openLogoutDialog(context, () => handleLogout(context, ref: ref)),
              ),
            ],
          ),
        ],

        const SizedBox(height: 28),
        _buildSectionHeader(context, 'social'.tr(), isDarkMode),
        _buildCardContainer(
          cardBgColor,
          isDarkMode,
          [
            if (settings?.social?.fb != null)
              _buildSettingTile(
                icon: LineIcons.facebook,
                title: 'facebook'.tr(),
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                onTap: () => AppService().openLink(settings!.social!.fb!),
              ),
            if (settings?.social?.youtube != null)
              _buildSettingTile(
                icon: LineIcons.youtube,
                title: 'youtube'.tr(),
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                onTap: () => AppService().openLink(settings!.social!.youtube!),
              ),
            if (settings?.social?.twitter != null)
              _buildSettingTile(
                icon: FeatherIcons.twitter,
                title: 'twitter'.tr(),
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                onTap: () => AppService().openLink(settings!.social!.twitter!),
              ),
            if (settings?.social?.instagram != null)
              _buildSettingTile(
                icon: FeatherIcons.instagram,
                title: 'instagram'.tr(),
                primaryColor: primaryColor,
                isDarkMode: isDarkMode,
                onTap: () => AppService().openLink(settings!.social!.instagram!),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 14),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.0,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCardContainer(Color cardBgColor, bool isDarkMode, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Color primaryColor,
    required bool isDarkMode,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? primaryColor).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: iconColor ?? primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      trailing: trailing ?? Icon(FeatherIcons.chevronRight, size: 20, color: Colors.grey[400]),
    );
  }
}
