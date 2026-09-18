import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/mixins/user_mixin.dart';
import 'package:lms_app/screens/tabs/assignments_tab/assignments_tab.dart';

import '../../../components/languages.dart';
import '../../../configs/features_config.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/user_data_provider.dart';
import '../../../services/app_service.dart';
import '../../../services/notification_service.dart';
import '../../../theme/theme_provider.dart';
import '../../../utils/logout_dialog.dart';
import '../../../utils/next_screen.dart';
import '../../../utils/snackbars.dart';
import '../../auth/delete_account.dart';

class AppSettings extends ConsumerWidget with UserMixin {
  const AppSettings({super.key});

  static const _pink = Color(0xFFF50078);
  static const _navy = Color(0xFF1B1E2E);
  static const _muted = Color(0xFF8D95A8);
  static const _darkCard = Color(0xFF1E202C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationEnabled = ref.watch(nProvider);
    final settings = ref.watch(appSettingsProvider);
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsIntro(isDarkMode: isDarkMode),
        const SizedBox(height: 22),

        _SectionTitle(
          title: _localText(
            context,
            kk: 'Қолданба',
            ru: 'Приложение',
            en: 'Application',
          ),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 10),
        _SettingsCard(
          isDarkMode: isDarkMode,
          children: [
            _SettingsTile(
              icon: notificationEnabled ? LineIcons.bell : LineIcons.bellSlash,
              iconColor: _pink,
              title: 'notifications'.tr(),
              subtitle: 'notifications-subtitle'.tr(),
              isDarkMode: isDarkMode,
              trailing: _PinkSwitch(
                value: notificationEnabled,
                onChanged: (value) =>
                    NotificationService().handleSubscription(context, value, ref),
              ),
            ),
            _Divider(isDarkMode: isDarkMode),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              iconColor: const Color(0xFF8B5CF6),
              title: 'dark-mode'.tr(),
              subtitle: 'dark-mode-subtitle'.tr(),
              isDarkMode: isDarkMode,
              trailing: _PinkSwitch(
                value: ref.watch(themeProvider).isDarkMode,
                onChanged: (value) =>
                    ref.read(themeProvider.notifier).changeTheme(value),
              ),
            ),
            if (isMultilanguageEnbled) ...[
              _Divider(isDarkMode: isDarkMode),
              _SettingsTile(
                icon: LineIcons.language,
                iconColor: const Color(0xFF3B82F6),
                title: 'language'.tr(),
                subtitle: _languageName(context),
                isDarkMode: isDarkMode,
                onTap: () =>
                    NextScreen.openBottomSheet(context, const Languages()),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),
        _SectionTitle(
          title: _localText(
            context,
            kk: 'Қолдау және ақпарат',
            ru: 'Поддержка и информация',
            en: 'Support & information',
          ),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 10),
        _SettingsCard(
          isDarkMode: isDarkMode,
          children: [
            _SettingsTile(
              icon: LineIcons.lock,
              iconColor: const Color(0xFFEC4899),
              title: 'privacy-policy'.tr(),
              subtitle: _localText(
                context,
                kk: 'Құпиялық және деректер',
                ru: 'Конфиденциальность и данные',
                en: 'Privacy and data',
              ),
              isDarkMode: isDarkMode,
              onTap: () {
                final url = settings?.privacyUrl ?? '';
                if (url.isEmpty) {
                  openSnackbarFailure(context, 'error'.tr());
                  return;
                }
                AppService().openLinkWithCustomTab(url);
              },
            ),
            _Divider(isDarkMode: isDarkMode),
            _SettingsTile(
              icon: LineIcons.envelope,
              iconColor: const Color(0xFF14B8A6),
              title: 'help-support'.tr(),
              subtitle: 'contact-us'.tr(),
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
            _Divider(isDarkMode: isDarkMode),
            _SettingsTile(
              icon: LineIcons.star,
              iconColor: const Color(0xFFF59E0B),
              title: 'rate-app'.tr(),
              subtitle: _localText(
                context,
                kk: 'Қолданбаны бағалау',
                ru: 'Оценить приложение',
                en: 'Rate the app',
              ),
              isDarkMode: isDarkMode,
              onTap: () => AppService().launchAppReview(context),
            ),
          ],
        ),

        if (user != null) ...[
          const SizedBox(height: 20),
          _SectionTitle(
            title: _localText(
              context,
              kk: 'Аккаунт',
              ru: 'Аккаунт',
              en: 'Account',
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            isDarkMode: isDarkMode,
            children: [
              _SettingsTile(
                icon: FeatherIcons.fileText,
                iconColor: const Color(0xFF6366F1),
                title: 'assignments'.tr(),
                subtitle: _localText(
                  context,
                  kk: 'Тапсырмаларыңыз',
                  ru: 'Ваши задания',
                  en: 'Your assignments',
                ),
                isDarkMode: isDarkMode,
                onTap: () => NextScreen.iOS(context, const AssignmentsTab()),
              ),
              _Divider(isDarkMode: isDarkMode),
              _SettingsTile(
                icon: LineIcons.userCog,
                iconColor: const Color(0xFF64748B),
                title: 'account-control'.tr(),
                subtitle: _localText(
                  context,
                  kk: 'Аккаунтты басқару',
                  ru: 'Управление аккаунтом',
                  en: 'Manage account',
                ),
                isDarkMode: isDarkMode,
                onTap: () => NextScreen.iOS(context, const DeleteAccount()),
              ),
              _Divider(isDarkMode: isDarkMode),
              _SettingsTile(
                icon: FeatherIcons.logOut,
                iconColor: const Color(0xFFEF4444),
                title: 'logout'.tr(),
                subtitle: _localText(
                  context,
                  kk: 'Аккаунттан шығу',
                  ru: 'Выйти из аккаунта',
                  en: 'Sign out of account',
                ),
                isDarkMode: isDarkMode,
                danger: true,
                onTap: () => openLogoutDialog(
                  context,
                      () => handleLogout(context, ref: ref),
                ),
              ),
            ],
          ),
        ],

        if (_hasSocial(settings)) ...[
          const SizedBox(height: 20),
          _SectionTitle(
            title: 'social'.tr(),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            isDarkMode: isDarkMode,
            children: _socialTiles(
              settings: settings,
              isDarkMode: isDarkMode,
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _socialTiles({
    required dynamic settings,
    required bool isDarkMode,
  }) {
    final items = <Widget>[];

    void addTile(Widget tile) {
      if (items.isNotEmpty) {
        items.add(_Divider(isDarkMode: isDarkMode));
      }
      items.add(tile);
    }

    if (settings?.social?.fb != null) {
      addTile(
        _SettingsTile(
          icon: LineIcons.facebook,
          iconColor: const Color(0xFF1877F2),
          title: 'facebook'.tr(),
          isDarkMode: isDarkMode,
          onTap: () => AppService().openLink(settings!.social!.fb!),
        ),
      );
    }

    if (settings?.social?.youtube != null) {
      addTile(
        _SettingsTile(
          icon: LineIcons.youtube,
          iconColor: const Color(0xFFFF0033),
          title: 'youtube'.tr(),
          isDarkMode: isDarkMode,
          onTap: () => AppService().openLink(settings!.social!.youtube!),
        ),
      );
    }

    if (settings?.social?.twitter != null) {
      addTile(
        _SettingsTile(
          icon: FeatherIcons.twitter,
          iconColor: const Color(0xFF1DA1F2),
          title: 'twitter'.tr(),
          isDarkMode: isDarkMode,
          onTap: () => AppService().openLink(settings!.social!.twitter!),
        ),
      );
    }

    if (settings?.social?.instagram != null) {
      addTile(
        _SettingsTile(
          icon: FeatherIcons.instagram,
          iconColor: const Color(0xFFE1306C),
          title: 'instagram'.tr(),
          isDarkMode: isDarkMode,
          onTap: () => AppService().openLink(settings!.social!.instagram!),
        ),
      );
    }

    return items;
  }

  bool _hasSocial(dynamic settings) {
    final social = settings?.social;
    if (social == null) return false;

    return social.fb != null ||
        social.youtube != null ||
        social.twitter != null ||
        social.instagram != null;
  }

  String _languageName(BuildContext context) {
    switch (context.locale.languageCode) {
      case 'kk':
        return 'Қазақша';
      case 'en':
        return 'English';
      case 'ru':
      default:
        return 'Русский';
    }
  }
}

class _SettingsIntro extends StatelessWidget {
  const _SettingsIntro({required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
          colors: [
            const Color(0xFF261421),
            const Color(0xFF211B29),
          ],
        )
            : const LinearGradient(
          colors: [Color(0xFFFFECF5), Color(0xFFFFF7FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white10
              : AppSettings._pink.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppSettings._pink,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppSettings._pink.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings'.tr(),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppSettings._navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _localText(
                    context,
                    kk: 'Қолданбаны өзіңізге ыңғайлаңыз',
                    ru: 'Настройте приложение под себя',
                    en: 'Make the app work your way',
                  ),
                  style: TextStyle(
                    color:
                    isDarkMode ? Colors.grey[400] : AppSettings._muted,
                    fontSize: 12.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.isDarkMode,
  });

  final String title;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
          color: isDarkMode ? Colors.grey[300] : AppSettings._navy,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isDarkMode,
    required this.children,
  });

  final bool isDarkMode;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppSettings._darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : const Color(0xFFF3EDF0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.24)
                : AppSettings._pink.withValues(alpha: 0.055),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDarkMode,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool isDarkMode;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 14, 13),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDarkMode ? 0.14 : 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 21, color: iconColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: danger
                          ? const Color(0xFFEF4444)
                          : (isDarkMode ? Colors.white : AppSettings._navy),
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : AppSettings._muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            trailing ??
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF8F5F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDarkMode
                        ? Colors.grey[500]
                        : const Color(0xFFA3A8B5),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 74,
      endIndent: 16,
      color: isDarkMode ? Colors.white10 : const Color(0xFFF3F4F6),
    );
  }
}

class _PinkSwitch extends StatelessWidget {
  const _PinkSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      activeThumbColor: AppSettings._pink,
      activeTrackColor: AppSettings._pink.withValues(alpha: 0.32),
      onChanged: onChanged,
    );
  }
}

String _localText(
    BuildContext context, {
      required String kk,
      required String ru,
      required String en,
    }) {
  switch (context.locale.languageCode) {
    case 'kk':
      return kk;
    case 'en':
      return en;
    case 'ru':
    default:
      return ru;
  }
}
