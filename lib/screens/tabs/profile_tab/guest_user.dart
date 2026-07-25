import 'package:easy_localization/easy_localization.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';

import '../../auth/login.dart';
import '../../../utils/next_screen.dart';

class GuestUser extends StatelessWidget {
  const GuestUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 0.3, color: Colors.blueGrey), borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: const Text('login').tr(),
        leading: const Icon(LineIcons.user_plus, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25),
        minVerticalPadding: 20,
        trailing: const Icon(LineIcons.chevron_right),
        onTap: () => NextScreen.openBottomSheet(context, const LoginScreen(popUpScreen: true)),
      ),
    );
  }
}
