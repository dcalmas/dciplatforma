import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:lms_app/configs/features_config.dart';
import 'package:lms_app/models/app_settings_model.dart';
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

  _navigateToNext() async {
    final user = FirebaseAuth.instance.currentUser;
    
    // 1. Баптауларды жүктейміз
    if (ref.read(appSettingsProvider) == null) {
      await ref.read(appSettingsProvider.notifier).getData();
    }
    final settings = ref.read(appSettingsProvider);

    if (user != null) {
      // 2. Пайдаланушы деректерін МІНДЕТТІ ТҮРДЕ күтеміз (Future)
      final userData = await ref.read(userDataProvider.notifier).fetchUserData();
      
      // 3. Стримді іске қосамыз (артқы фонда жаңартып тұру үшін)
      ref.read(userDataProvider.notifier).getData();

      if (!mounted) return;
      if (settings?.license != LicenseType.none) {
        NextScreen.replaceSlideAnimation(context, const Home());
      } else {
        NextScreen.openBottomSheet(context, const NoLicenseFound());
      }
    } else {
      // Пайдаланушы жүйеден шыққан болса
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
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().then((value) => _navigateToNext());
          },
        ),
      ),
    );
  }
}
