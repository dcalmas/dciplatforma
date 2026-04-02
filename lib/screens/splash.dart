import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:lms_app/configs/features_config.dart';
import 'package:lms_app/models/app_settings_model.dart';
import 'package:lms_app/screens/auth/no_user.dart';
import 'package:lms_app/services/auth_service.dart';
import 'package:lms_app/services/sp_service.dart';
import '../core/home.dart';
import '../providers/app_settings_provider.dart';
import '../providers/user_data_provider.dart';
import '../utils/next_screen.dart';
import '../utils/no_license.dart';
import 'intro.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Анимация аяқталған соң деректерді тексеріп, келесі экранға өту
  _navigateToNext(RemoteMessage? message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ref.read(userDataProvider.notifier).getData();
      final userData = ref.read(userDataProvider);
      if (userData != null) {
        if (ref.read(appSettingsProvider) == null) {
          await ref.read(appSettingsProvider.notifier).getData();
        }
        if (!mounted) return;
        if (ref.read(appSettingsProvider)?.license != LicenseType.none) {
          NextScreen.replaceSlideAnimation(context, const Home()); // Солдан оңға қарай
        } else {
          NextScreen.openBottomSheet(context, const NoLicenseFound());
        }
      } else {
        await AuthService().userLogOut();
        await AuthService().googleLogout();
        if (!mounted) return;
        NextScreen.replaceSlideAnimation(context, const NoUserFound());
      }
    } else {
      await ref.read(appSettingsProvider.notifier).getData();
      final settings = ref.read(appSettingsProvider);
      final bool isGuestUser = await SPService().isGuestUser();

      if (settings?.license != LicenseType.none) {
        if (isGuestUser || settings?.onBoarding == false) {
          if (!mounted) return;
          NextScreen.replaceSlideAnimation(context, const Home());
        } else {
          if (!mounted) return;
          NextScreen.replaceSlideAnimation(context, const IntroScreen());
        }
      } else {
        if (!mounted) return;
        NextScreen.openBottomSheet(context, const NoLicenseFound());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Фон түсін қалауыңызша өзгертіңіз
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash.json', // Лотти файлының жолы
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().then((value) => _navigateToNext(null));
          },
        ),
      ),
    );
  }
}
