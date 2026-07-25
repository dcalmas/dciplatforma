import 'package:easy_localization/easy_localization.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/configs/app_assets.dart';
import 'package:lms_app/configs/features_config.dart';
import 'package:lms_app/components/languages.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/screens/splash.dart';
import 'package:lms_app/services/sp_service.dart';
import 'package:lms_app/utils/next_screen.dart';
import '../providers/app_settings_provider.dart';

final introPageController = Provider.autoDispose((ref) => PageController(initialPage: 0));

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  int _currentPage = 0;

  @override
  void dispose() {
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(introPageController);
    final settings = ref.watch(appSettingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);

    final List<_IntroPage> pages = [
      _IntroPage(image: introImage1),
      _IntroPage(image: introImage2),
      _IntroPage(image: introImage3),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: Skip + Language
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (settings?.skipLogin == true)
                    GestureDetector(
                      onTap: () => _onSkipPressed(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'skip'.tr(),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  if (isMultilanguageEnbled) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => NextScreen.openBottomSheet(context, const Languages()),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E202C) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          LineIcons.globe,
                          size: 20,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return _IntroPageView(
                    page: page,
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                  );
                },
              ),
            ),

            // Bottom section: indicator + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Animated page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? primaryColor
                              : primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < pages.length - 1) {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          NextScreen.openBottomSheet(context, const LoginScreen());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                        shadowColor: primaryColor.withValues(alpha: 0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage < pages.length - 1 ? 'next'.tr() : 'get-started'.tr(),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage < pages.length - 1
                                ? LineIcons.arrow_right
                                : LineIcons.arrow_right_circle,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSkipPressed(BuildContext context) async {
    await SPService().setGuestUser().then((value) {
      if (!context.mounted) return;
      NextScreen.replaceAnimation(context, const SplashScreen());
    });
  }
}

class _IntroPage {
  final String image;

  const _IntroPage({required this.image});
}

class _IntroPageView extends StatelessWidget {
  final _IntroPage page;
  final bool isDarkMode;
  final Color primaryColor;

  const _IntroPageView({
    required this.page,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Image.asset(
            page.image,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
