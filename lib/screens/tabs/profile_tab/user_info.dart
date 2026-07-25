import 'package:easy_localization/easy_localization.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/iAP/iap_config.dart';
import 'package:lms_app/iAP/iap_screen.dart';
import 'package:lms_app/models/app_settings_model.dart';
import 'package:lms_app/providers/app_settings_provider.dart';
import '../../../components/user_avatar.dart';
import '../../../mixins/user_mixin.dart';
import '../../../models/user_model.dart';
import '../../edit_profile.dart';
import '../../../utils/next_screen.dart';

class UserInfo extends StatelessWidget with UserMixin {
  const UserInfo({super.key, required this.user, required this.ref});

  final UserModel user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Column(
      children: [
        // Main User Card
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
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
          child: Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 2),
                ),
                child: UserAvatar(imageUrl: user.imageUrl, radius: 52, iconSize: 26),
              ),
              const SizedBox(width: 16),

              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Button
              GestureDetector(
                onTap: () => NextScreen.openBottomSheet(context, EditProfile(user: user), maxHeight: 0.80),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LineIcons.edit,
                    size: 18,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Subscription Banner
        Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(appSettingsProvider);
            if (IAPConfig.iAPEnabled && settings?.license == LicenseType.extended) {
              return InkWell(
                onTap: () => NextScreen.openBottomSheet(context, const IAPScreen(), isDismissable: false),
                child: user.subscription == null
                    ? _noSubscriptionContainer(context, isDarkMode, primaryColor, cardBgColor)
                    : _subscriptionContainer(context, isDarkMode, primaryColor),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _subscriptionContainer(BuildContext context, bool isDarkMode, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Image.asset(premiumImage, height: 22, width: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.subscription!.plan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                UserMixin.isExpired(user)
                    ? const Text(
                        'expired',
                        style: TextStyle(color: Colors.yellowAccent, fontSize: 12),
                      ).tr()
                    : Text(
                        'expire-in-days'.tr(args: [remainingDays(user).toString()]),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
              ],
            ),
          ),
          const Icon(LineIcons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }

  Widget _noSubscriptionContainer(
      BuildContext context, bool isDarkMode, Color primaryColor, Color cardBgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(premiumImage, height: 22, width: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'subscribe-to-access-features',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ).tr(),
          ),
          Icon(LineIcons.chevron_right, color: primaryColor),
        ],
      ),
    );
  }
}

