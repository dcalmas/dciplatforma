import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/components/privacy_info.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/screens/auth/reset_password.dart';
import 'package:lms_app/screens/auth/sign_up.dart';
import 'package:lms_app/core/home.dart';
import 'package:lms_app/services/auth_service.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/next_screen.dart';
import '../../providers/user_data_provider.dart';
import 'social_logins.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.popUpScreen});

  final bool? popUpScreen;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  var emailCtlr = TextEditingController();
  var passwordCtrl = TextEditingController();
  bool isLoading = false;

  bool offsecureText = true;
  IconData lockIcon = LineIcons.lock;

  Future _handleLoginWithUsernamePassword() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() => isLoading = true);
      final UserCredential? user =
          await AuthService().loginWithEmailPassword(context, emailCtlr.text.trim(), passwordCtrl.text);
      if (mounted) setState(() => isLoading = false);
      if (user != null && user.user != null) {
        final bool userExists = await FirebaseService().isUserExists(user.user!.uid);
        if (!userExists) {
          final newUser = UserModel(
            id: user.user!.uid,
            email: user.user!.email ?? emailCtlr.text.trim(),
            name: user.user!.displayName ?? emailCtlr.text.trim().split('@').first,
            createdAt: DateTime.now().toUtc(),
            imageUrl: user.user?.photoURL,
            platform: Platform.isAndroid ? 'Android' : 'iOS',
          );
          await FirebaseService().saveUserData(newUser);
        }
        afterSignIn();
      }
    }
  }

  void _onlockPressed() {
    setState(() {
      offsecureText = !offsecureText;
      lockIcon = offsecureText ? LineIcons.lock : LineIcons.lockOpen;
    });
  }

  void afterSignIn() async {
    if (widget.popUpScreen == null || widget.popUpScreen == false) {
      await ref.read(userDataProvider.notifier).fetchUserData();
      ref.read(userDataProvider.notifier).getData();
      if (!mounted) return;
      NextScreen.closeOthers(context, const Home());
    } else {
      final navigator = Navigator.of(context);
      await ref.read(userDataProvider.notifier).getData();
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF0F111A), const Color(0xFF0F111A)]
                : [
                    primaryColor.withValues(alpha: 0.08),
                    const Color(0xFFF8F9FE),
                    const Color(0xFFF8F9FE),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: isDarkMode ? 0.08 : 0.12),
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: -80,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: isDarkMode ? 0.05 : 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: 40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(LineIcons.times, size: 20, color: isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 24, right: 24, top: 80, bottom: 40),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'login',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ).tr(),
                    const SizedBox(height: 6),
                    Text(
                      'login-to-access-features',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                        fontSize: 14,
                      ),
                    ).tr(),
                    const SizedBox(height: 28),

                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.06)
                              : primaryColor.withValues(alpha: 0.08),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withValues(alpha: 0.3)
                                : primaryColor.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Social logins
                          SocialLogins(afterSignIn: afterSignIn),

                          // OR divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Email input
                          TextFormField(
                            controller: emailCtlr,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              hintText: 'enter-email'.tr(),
                              labelText: 'email'.tr(),
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF141622) : const Color(0xFFF8F9FE),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : primaryColor.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(LineIcons.times_circle, size: 18, color: Colors.grey[400]),
                                onPressed: () => emailCtlr.clear(),
                              ),
                            ),
                            validator: (value) => value!.isEmpty ? 'Email is required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Password input
                          TextFormField(
                            controller: passwordCtrl,
                            obscureText: offsecureText,
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              hintText: 'enter-password'.tr(),
                              labelText: 'password'.tr(),
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF141622) : const Color(0xFFF8F9FE),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : primaryColor.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(lockIcon, size: 18, color: primaryColor),
                                onPressed: _onlockPressed,
                              ),
                            ),
                            validator: (value) => value!.isEmpty ? 'Password is required' : null,
                          ),
                          const SizedBox(height: 8),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              child: Text(
                                'forgot-password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: primaryColor,
                                ),
                              ).tr(),
                              onPressed: () => NextScreen.iOS(context, const ResetPassword()),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                elevation: 0,
                                shadowColor: primaryColor.withValues(alpha: 0.4),
                              ),
                              onPressed: isLoading ? null : _handleLoginWithUsernamePassword,
                               child: isLoading
                                   ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                   : Text(
                                       'login',
                                       style: TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                       ),
                                     ).tr(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Create Account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "no-account",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ).tr(),
                              TextButton(
                                child: Text(
                                  'create-account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: primaryColor,
                                  ),
                                ).tr(),
                                onPressed: () => NextScreen.replace(context, const SignUpScreen()),
                              ),
                            ],
                          ),
                          const PrivacyInfo(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
