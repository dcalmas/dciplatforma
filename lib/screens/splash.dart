import 'dart:async';
import 'dart:math';
import 'dart:ui';
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

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _mainController;
  late Animation<Alignment> _logoAlignment;
  late Animation<double> _contentOpacity;

  final List<Blob> _blobs = List.generate(6, (index) => Blob());

  @override
  void initState() {
    super.initState();

    // 1. Фондағы Liquid (Metaballs) анимациясы
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        for (var blob in _blobs) {
          blob.update();
        }
      })..repeat();

    // 2. Логотип пен контент анимациясы
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoAlignment = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0, -0.4),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOutCubic),
    ));

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));

    _startInitialization();
  }

  _startInitialization() async {
    // Деректерді жүктеуді бастау
    final user = FirebaseAuth.instance.currentUser;
    if (ref.read(appSettingsProvider) == null) {
      await ref.read(appSettingsProvider.notifier).getData();
    }
    if (user != null) {
      await ref.read(userDataProvider.notifier).fetchUserData();
      ref.read(userDataProvider.notifier).getData();
    }

    // Анимацияны бастау
    _mainController.forward();

    // Барлығы дайын болғанша күту (кемінде 3 секунд)
    Timer(const Duration(milliseconds: 3500), () {
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
  void dispose() {
    _bgController.dispose();
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Liquid Background Layer
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: LiquidPainter(blobs: _blobs),
                  child: Container(),
                );
              },
            ),
          ),

          // 2. Logo Animation Layer
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Align(
                alignment: _logoAlignment.value,
                child: Image.asset(
                  splash,
                  height: 120,
                  width: 120,
                ),
              );
            },
          ),

          // 3. Welcome Text / Loading Layer
          Align(
            alignment: const Alignment(0, 0.2),
            child: FadeTransition(
              opacity: _contentOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(strokeWidth: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter for Liquid Morphing Effect
class LiquidPainter extends CustomPainter {
  final List<Blob> blobs;
  LiquidPainter({required this.blobs});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blueAccent.withOpacity(0.6);

    // Metaballs effect magic: High Contrast + Heavy Blur
    final layerPaint = Paint()
      ..colorFilter = const ColorFilter.matrix([
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 60, -2000, 
      ])
      ..imageFilter = ImageFilter.blur(sigmaX: 40, sigmaY: 40);

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), layerPaint);

    for (var blob in blobs) {
      canvas.drawCircle(
        Offset(blob.x * size.width, blob.y * size.height),
        blob.radius,
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) => true;
}

// Moving Blob (Circle) logic
class Blob {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double speedX = (Random().nextDouble() - 0.5) * 0.003;
  double speedY = (Random().nextDouble() - 0.5) * 0.003;
  double radius = Random().nextDouble() * 60 + 40;

  void update() {
    x += speedX;
    y += speedY;

    if (x < 0 || x > 1) speedX *= -1;
    if (y < 0 || y > 1) speedY *= -1;
  }
}
