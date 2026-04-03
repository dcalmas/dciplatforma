import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/configs/features_config.dart';
import 'package:lms_app/models/app_settings_model.dart';
import 'package:lms_app/services/sp_service.dart';
import 'package:lottie/lottie.dart';
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
    _startInitialization();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _startInitialization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (ref.read(appSettingsProvider) == null) {
      await ref.read(appSettingsProvider.notifier).getData();
    }
    if (user != null) {
      await ref.read(userDataProvider.notifier).fetchUserData();
      ref.read(userDataProvider.notifier).getData();
    }
  }

  _navigateToNext() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    final settings = ref.read(appSettingsProvider);
    final userData = ref.read(userDataProvider);

    if (user != null && userData != null) {
      if (settings?.license != LicenseType.none) {
        NextScreen.replaceSlideAnimation(context, const Home());
      } else {
        NextScreen.openBottomSheet(context, const NoLicenseFound());
      }
    } else {
      final bool isGuestUser = await SPService().isGuestUser();
      if (settings?.license != LicenseType.none) {
        if (isGuestUser || settings?.onBoarding == false) {
          NextScreen.replaceSlideAnimation(context, const Home());
        } else {
          NextScreen.replaceSlideAnimation(context, const IntroScreen());
        }
      } else {
        NextScreen.openBottomSheet(context, const NoLicenseFound());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          splashAnimation,
          controller: _controller,
          width: MediaQuery.of(context).size.width * 0.7,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() {
                // 3. Анимация аяқталғанда күшті соққы
                HapticFeedback.heavyImpact(); 
                _navigateToNext();
              });

            // 1. Анимация басталғанда (Орташа күшті соққы)
            HapticFeedback.mediumImpact();

            // 2. Анимацияның 50%-ында (Ең күшті соққы)
            Timer(Duration(milliseconds: (composition.duration.inMilliseconds * 0.5).toInt()), () {
              HapticFeedback.heavyImpact();
            });
          },
        ),
      ),
    );
  }
}
