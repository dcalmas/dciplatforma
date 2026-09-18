import 'dart:convert';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'phone_identity_service.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lms_app/utils/snackbars.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<User?> userSteam = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;
  static bool _googleInitialized = false;

  static Future<void> _ensureGoogleInitialized() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }
  }

  static const String phoneEmailDomain = PhoneIdentityService.phoneEmailDomain;
  static bool isEmail(String value) => PhoneIdentityService.isEmail(value);
  static String normalizePhoneToE164(String input) =>
      PhoneIdentityService.normalizePhone(input);
  static String syntheticEmailForPhone(String phone) =>
      PhoneIdentityService.syntheticEmail(phone);
  static Map<String, String>? normalizeIdentifier(String input) =>
      PhoneIdentityService.normalize(input);

  static String errorMessage(Object error) {
    if (error is FirebaseFunctionsException) {
      return 'Не удалось проверить номер телефона. Попробуйте позже или войдите по email.';
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Неверный email, телефон или пароль.';
        case 'email-already-in-use':
          return 'Аккаунт уже существует. Войдите или восстановите пароль.';
        case 'phone-recovery-unavailable':
          return 'У этого аккаунта нет email для восстановления. Обратитесь к администратору для сброса пароля.';
        case 'account-email-missing':
          return 'К аккаунту не привязан email для входа. Обратитесь к администратору.';
        case 'invalid-email':
          return 'Введите корректный email или номер телефона с кодом страны.';
        case 'weak-password':
          return 'Пароль должен содержать не менее 6 символов.';
        case 'user-disabled':
          return 'Аккаунт заблокирован. Обратитесь к администратору.';
        case 'too-many-requests':
          return 'Слишком много попыток. Попробуйте позже.';
        case 'network-request-failed':
          return 'Проверьте подключение к интернету.';
      }
    }
    return 'Не удалось завершить авторизацию. Попробуйте ещё раз.';
  }

  Future<UserCredential?> loginWithEmailOrPhone(
      BuildContext context, String identifier, String password) async {
    try {
      final email = await PhoneIdentityService().resolve(identifier);
      return await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (error) {
      if (context.mounted) openSnackbarFailure(context, errorMessage(error));
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmailOrPhone(
      BuildContext context, String identifier, String password) async {
    try {
      final email =
          await PhoneIdentityService().resolve(identifier, registration: true);
      return await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (error) {
      if (context.mounted) openSnackbarFailure(context, errorMessage(error));
      return null;
    }
  }

  Future<UserCredential?> loginWithEmailPassword(
      BuildContext context, String email, String password) async {
    UserCredential? user;
    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint('error: $e');
      if (!context.mounted) return null;
      openSnackbarFailure(context, e.message);
    }
    return user;
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      // Пайдаланушы терезені жапса — бұл қате емес, жай шығамыз.
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return await _firebaseAuth.signInWithCredential(credential);
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future userLogOut() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await _firebaseAuth.signOut();
    } else {
      debugPrint('Not signed in');
    }
  }

  Future googleLogout() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('google logout: $e');
    }
  }

  Future<UserCredential?> signUpWithEmailPassword(
      BuildContext context, String email, String password) async {
    UserCredential? user;
    try {
      user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint('error: $e');
      if (!context.mounted) return null;
      openSnackbarFailure(context, e.message);
    }
    return user;
  }

  Future deleteUserAuth() async {
    await user?.delete().catchError((e) {
      debugPrint('error on deleting account');
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  Future sendEmailVerification() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null &&
        !PhoneIdentityService.isSyntheticEmail(
            currentUser.email ?? '')) {
      await currentUser
          .sendEmailVerification()
          .catchError((e) => debugPrint('Email sending failed'));
    }
  }

  Future sendPasswordRestEmail(BuildContext context, String email) async {
    try {
      final targetEmail =
          await PhoneIdentityService().resolve(email, passwordReset: true);
      await _firebaseAuth.sendPasswordResetEmail(email: targetEmail);
      if (!context.mounted) return;
      openSnackbar(context,
          'Если аккаунт существует, ссылка для сброса пароля отправлена на привязанный email.');
    } catch (error) {
      if (!context.mounted) return;
      openSnackbarFailure(context, errorMessage(error));
    }
  }

  Future<bool> changePassword(
      BuildContext context, String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      final email = user.email;
      if (email == null || email.isEmpty) {
        if (context.mounted) openSnackbarFailure(context, 'error'.tr());
        return false;
      }
      if (currentPassword.isEmpty || newPassword.isEmpty) return false;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error changing password: $e');
      if (!context.mounted) return false;
      openSnackbarFailure(context, e.message ?? 'error'.tr());
      return false;
    }
  }
}
