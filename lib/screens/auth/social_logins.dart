import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/snackbars.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class SocialLogins extends StatefulWidget {
  const SocialLogins({super.key, required this.afterSignIn});
  final Future<void> Function() afterSignIn;

  @override
  State<SocialLogins> createState() => _SocialLoginsState();
}

class _SocialLoginsState extends State<SocialLogins> {
  final googleCtlr = RoundedLoadingButtonController();
  final appleController = RoundedLoadingButtonController();

  UserModel _userModel(UserCredential userCredential) {
    final UserModel user = UserModel(
      id: userCredential.user!.uid,
      email: userCredential.user?.email ?? 'No Email',
      name: userCredential.user!.displayName ?? 'No Name',
      createdAt: DateTime.now().toUtc(),
      imageUrl: userCredential.user?.photoURL,
      platform: Platform.isAndroid ? 'Android' : 'iOS',
    );
    return user;
  }

  bool _busy = false;

  Future<void> _handleSignIn(
    RoundedLoadingButtonController controller,
    Future<UserCredential?> Function() authenticate,
  ) async {
    if (_busy) return;
    _busy = true;
    controller.start();
    try {
      final credential = await authenticate();
      if (credential?.user == null) return;
      await FirebaseService().saveUserData(_userModel(credential!));
      if (mounted) await widget.afterSignIn();
    } catch (error) {
      if (mounted)
        openSnackbarFailure(context, AuthService.errorMessage(error));
    } finally {
      _busy = false;
      if (mounted) controller.reset();
    }
  }

  Future<void> _handleGoogleSignIn() =>
      _handleSignIn(googleCtlr, () => AuthService().signInWithGoogle());
  Future<void> _handleAppleSignIn() =>
      _handleSignIn(appleController, () => AuthService().signInWithApple());

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Column(
      children: [
        // Google Sign In
        _GradientBorderButton(
          controller: googleCtlr,
          onPressed: () => _handleGoogleSignIn(),
          isDarkMode: isDarkMode,
          primaryColor: primaryColor,
          cardBgColor: cardBgColor,
          gradientColors: const [
            Color(0xFF4285F4),
            Color(0xFFEA4335),
            Color(0xFFFBBC05),
            Color(0xFF34A853),
          ],
          icon: FontAwesomeIcons.google,
          iconColors: const [
            Color(0xFF4285F4),
            Color(0xFFEA4335),
            Color(0xFFFBBC05),
            Color(0xFF34A853),
          ],
          label: 'Google',
        ),

        // Apple
        if (Platform.isIOS) ...[
          const SizedBox(height: 12),
          _GradientBorderButton(
            controller: appleController,
            onPressed: () => _handleAppleSignIn(),
            isDarkMode: isDarkMode,
            primaryColor: primaryColor,
            cardBgColor: cardBgColor,
            gradientColors: const [
              Color(0xFF333333),
              Color(0xFF666666),
            ],
            icon: FontAwesomeIcons.apple,
            iconColors: const [Color(0xFF333333)],
            label: 'Apple',
          ),
        ],
      ],
    );
  }
}

class _GradientBorderButton extends StatelessWidget {
  final RoundedLoadingButtonController controller;
  final VoidCallback onPressed;
  final bool isDarkMode;
  final Color primaryColor;
  final Color cardBgColor;
  final List<Color> gradientColors;
  final FaIconData icon;
  final List<Color> iconColors;
  final String label;

  const _GradientBorderButton({
    required this.controller,
    required this.onPressed,
    required this.isDarkMode,
    required this.primaryColor,
    required this.cardBgColor,
    required this.gradientColors,
    required this.icon,
    required this.iconColors,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RoundedLoadingButton(
        width: MediaQuery.sizeOf(context).width,
        height: 56,
        controller: controller,
        animateOnTap: false,
        color: Colors.transparent,
        elevation: 0,
        borderRadius: 18,
        onPressed: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors:
                  gradientColors.map((c) => c.withValues(alpha: 0.08)).toList(),
            ),
            border: Border.all(
              color: gradientColors.first.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Colored gradient circle with icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors
                        .map((c) => c.withValues(alpha: 0.15))
                        .toList(),
                  ),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: iconColors.first, size: 18),
              ),
              const SizedBox(width: 14),
              Flexible(
                  child: Text(
                'Войти через $label',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
