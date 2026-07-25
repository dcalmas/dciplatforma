import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_assets.dart';

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
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _initDone = false;
  bool _animDone = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

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
    _initDone = true;
    _tryNavigate();
  }

  void _onAnimComplete() {
    _animDone = true;
    HapticFeedback.heavyImpact();
    _tryNavigate();
  }

  void _tryNavigate() {
    if (!_initDone || !_animDone || !mounted || _navigating) return;
    _navigating = true;
    _navigateToNext();
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
    } else if (user != null && userData == null) {
      NextScreen.replaceSlideAnimation(context, const Home());
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
      statusBarIconBrightness: Brightness.light,
    ));

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.85),
              const Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Center content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          logo,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Lottie.asset(
                        splashAnimation,
                        controller: _controller,
                        width: 160,
                        fit: BoxFit.contain,
                        onLoaded: (composition) {
                          _controller
                            ..duration = composition.duration
                            ..forward().whenComplete(() {
                              _onAnimComplete();
                            });

                          HapticFeedback.mediumImpact();
                          Timer(
                            Duration(milliseconds: (composition.duration.inMilliseconds * 0.5).toInt()),
                            () => HapticFeedback.heavyImpact(),
                          );
                        },
                      ),
                    ],
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
