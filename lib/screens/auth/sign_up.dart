import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_app/components/privacy_info.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/core/home.dart';
import 'package:lms_app/services/auth_service.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/next_screen.dart';
import '../../providers/user_data_provider.dart';
import 'social_logins.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, this.popUpScreen});

  final bool? popUpScreen;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  var formKey = GlobalKey<FormState>();
  var nameCtlr = TextEditingController();
  var emailCtlr = TextEditingController();
  var passwordCtrl = TextEditingController();
  bool isLoading = false;

  bool offsecureText = true;
  IconData lockIcon = LineIcons.lock;

  UserModel _userModel(UserCredential userCredential) {
    return UserModel(
      id: userCredential.user!.uid,
      email: userCredential.user!.email ?? emailCtlr.text,
      name: userCredential.user!.displayName ?? nameCtlr.text,
      createdAt: DateTime.now().toUtc(),
      imageUrl: userCredential.user?.photoURL,
      platform: Platform.isAndroid ? 'Android' : 'iOS',
    );
  }

  Future _handleSignUpWithUsernamePassword() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() => isLoading = true);
      final UserCredential? userCredential =
          await AuthService().signUpWithEmailPassword(context, emailCtlr.text.trim(), passwordCtrl.text.trim()).onError((error, stackTrace) {
        if (mounted) setState(() => isLoading = false);
        return null;
      });
      if (userCredential != null && userCredential.user != null) {
        await FirebaseService().saveUserData(_userModel(userCredential));
        await FirebaseService().updateUserStats();
        if (mounted) setState(() => isLoading = false);
        await AuthService().sendEmailVerification();
        afterSignIn();
      } else {
        if (mounted) setState(() => isLoading = false);
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
    final bgColor = isDarkMode ? const Color(0xFF0F111A) : const Color(0xFFF8F9FE);
    final cardBgColor = isDarkMode ? const Color(0xFF1E202C) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LineIcons.times, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'create-account',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                ),
              ).tr(),
              const SizedBox(height: 6),
              Text(
                'follow-simple-steps',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ).tr(),
              const SizedBox(height: 20),

              // Form Container Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.indigo.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SocialLogins(afterSignIn: afterSignIn),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        '------ OR ------',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),

                    // Name input
                    TextFormField(
                      controller: nameCtlr,
                      keyboardType: TextInputType.name,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        hintText: 'enter-name'.tr(),
                        labelText: 'name'.tr(),
                        filled: true,
                        fillColor: isDarkMode ? const Color(0xFF141622) : const Color(0xFFF8F9FE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(LineIcons.times_circle, size: 18, color: Colors.grey[400]),
                          onPressed: () => nameCtlr.clear(),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

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
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
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
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(lockIcon, size: 18, color: primaryColor),
                          onPressed: _onlockPressed,
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Password is required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                          shadowColor: primaryColor.withValues(alpha: 0.4),
                        ),
                        onPressed: isLoading ? null : _handleSignUpWithUsernamePassword,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(
                                'create-account',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).tr(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "already-have-account",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ).tr(),
                        TextButton(
                          child: Text(
                            'login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: primaryColor,
                            ),
                          ).tr(),
                          onPressed: () => NextScreen.replace(context, const LoginScreen()),
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
    );
  }
}

