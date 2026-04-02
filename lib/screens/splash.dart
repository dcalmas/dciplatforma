import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_assets.dart';
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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isDotMoved = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  // Анимацияны бастау және деректерді жүктеу
  _startAnimation() async {
    // 1. Азғантай кідірістен кейін нүктені жылжыту
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isDotMoved = true;
        });
      }
    });

    // 2. Деректерді жүктеу (Анимация жүріп жатқанда)
    final user = FirebaseAuth.instance.currentUser;
    if (ref.read(appSettingsProvider) == null) {
      await ref.read(appSettingsProvider.notifier).getData();
    }
    if (user != null) {
      await ref.read(userDataProvider.notifier).fetchUserData();
      ref.read(userDataProvider.notifier).getData();
    }

    // 3. Анимация толық біткенше күту (жалпы 2.5 секунд)
    Timer(const Duration(milliseconds: 2500), () {
      _navigateToNext();
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Логотип
            Image.asset(
              splash, // configs/app_assets.dart-тан алынады
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 20),
            
            // 2. Жылжымалы нүкте (JUZO стилінде)
            SizedBox(
              width: 100, // Нүкте қозғалатын жолдың ені
              height: 10,
              child: AnimatedAlign(
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                alignment: _isDotMoved ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent, // Нүктенің түсін қалауыңызша өзгертіңіз
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
