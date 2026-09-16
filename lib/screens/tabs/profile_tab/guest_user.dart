import 'package:easy_localization/easy_localization.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

import '../../auth/login.dart';
import '../../../utils/next_screen.dart';

class GuestUser extends StatelessWidget {
  const GuestUser({super.key});

  static const _pink = Color(0xFFF00080);
  static const _iconBg = Color(0xFFFCDCE9);
  static const _navy = Color(0xFF1B1E2E);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        title: Text(
          'login'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15.5,
            color: isDarkMode ? Colors.white : _navy,
          ),
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDarkMode ? _pink.withValues(alpha: 0.15) : _iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(FeatherIcons.userPlus, size: 22, color: _pink),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        trailing: Icon(FeatherIcons.chevronRight, size: 20, color: Colors.grey[400]),
        onTap: () => NextScreen.normal(context, const LoginScreen(popUpScreen: true)),
      ),
    );
  }
}
