import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/screens/tabs/profile_tab/settings.dart';
import '../../../providers/user_data_provider.dart';
import 'guest_user.dart';
import 'user_info.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('profile').tr(),
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            user == null ? const GuestUser() : UserInfo(user: user, ref: ref),
            const AppSettings(),
          ],
        ),
      ),
    );
  }
}

