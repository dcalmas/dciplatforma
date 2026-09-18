import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lms_app/screens/tabs/profile_tab/settings.dart';

const _pink = Color(0xFFF50078);
const _lightBg = Color(0xFFFFF8FC);
const _darkBg = Color(0xFF0F111A);

/// Баптаулардың бөлек беті. Құрамын бірдей [AppSettings] қамтамасыз етеді,
/// себебі барлық логика (токендер, өшіру, логоут, соцсети) сонда сақталған.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? _darkBg : _lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? _darkBg : _lightBg,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : _pink,
          ),
        ),
        title: Text(
          'settings'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1B1E2E),
          ),
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: AppSettings(),
        ),
      ),
    );
  }
}