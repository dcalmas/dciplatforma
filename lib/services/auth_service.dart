import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lms_app/utils/snackbars.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<User?> userSteam = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  static const String phoneEmailDomain = 'phone.lms.kz';

  static bool isEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  }

  static String normalizePhoneToE164(String input) {
    String digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('8') && digits.length == 11) {
      digits = '7${digits.substring(1)}';
    }
    if (digits.isEmpty) return '';
    return '+$digits';
  }

  static String syntheticEmailForPhone(String phoneE164) {
    final digits = phoneE164.replaceAll(RegExp(r'\D'), '');
    return '$digits@$phoneEmailDomain';
  }

  static Map<String, String>? normalizeIdentifier(String input) {
    final value = input.trim();
    if (value.isEmpty) return null;
    if (isEmail(value)) return {'type': 'email', 'value': value.toLowerCase()};
    final phone = normalizePhoneToE164(value);
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8 || digits.length > 15) return null;
    return {'type': 'phone', 'value': phone};
  }

  Future<UserCredential?> loginWithEmailOrPhone(BuildContext context, String identifier, String password) async {
    final norm = normalizeIdentifier(identifier);
    if (norm == null) {
      openSnackbarFailure(context, 'Дұрыс email немесе телефон нөмірін енгізіңіз');
      return null;
    }

    String targetEmail = '';
    if (norm['type'] == 'email') {
      targetEmail = norm['value']!;
    } else {
      final phone = norm['value']!;
      final digits = phone.replaceAll(RegExp(r'\D'), '');

      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          final data = snap.docs.first.data();
          targetEmail = data['email'] ?? syntheticEmailForPhone(phone);
        } else {
          final altPhone = digits.startsWith('7') ? '8${digits.substring(1)}' : '7${digits.substring(1)}';
          final altSnap = await FirebaseFirestore.instance
              .collection('users')
              .where('phone', isEqualTo: altPhone)
              .limit(1)
              .get();
          if (altSnap.docs.isNotEmpty) {
            targetEmail = altSnap.docs.first.data()['email'] ?? syntheticEmailForPhone(phone);
          } else {
            targetEmail = syntheticEmailForPhone(phone);
          }
        }
      } catch (e) {
        debugPrint('Phone lookup error: $e');
        targetEmail = syntheticEmailForPhone(phone);
      }
    }

    return await loginWithEmailPassword(context, targetEmail, password);
  }

  Future<UserCredential?> signUpWithEmailOrPhone(BuildContext context, String identifier, String password) async {
    final norm = normalizeIdentifier(identifier);
    if (norm == null) {
      openSnackbarFailure(context, 'Дұрыс email немесе телефон нөмірін енгізіңіз');
      return null;
    }

    final email = norm['type'] == 'email'
        ? norm['value']!
        : syntheticEmailForPhone(norm['value']!);

    return await signUpWithEmailPassword(context, email, password);
  }

  Future<UserCredential?> loginWithEmailPassword(BuildContext context, String email, String password) async {
    UserCredential? user;
    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint('error: $e');
      if (!context.mounted) return null;
      openSnackbarFailure(context, e.message);
    }
    return user;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.status != LoginStatus.success || loginResult.accessToken == null) return null;
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);
    return await _firebaseAuth.signInWithCredential(facebookAuthCredential);
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
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
    final bool isSignedIn = await googleSignIn.isSignedIn();
    if (isSignedIn) {
      await googleSignIn.signOut();
    }
  }

  Future<UserCredential?> signUpWithEmailPassword(BuildContext context, String email, String password) async {
    UserCredential? user;
    try {
      user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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
    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser!.sendEmailVerification().catchError((e) => debugPrint('Email sending failed'));
    }
  }

  Future sendPasswordRestEmail(BuildContext context, String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      openSnackbar(context, 'An email has been sent to $email. Go to that link & reset your password.');
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      openSnackbarFailure(context, error.message);
    }
  }

  Future<bool> changePassword(BuildContext context, String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error changing password: $e');
      if (!context.mounted) return false;
      openSnackbarFailure(context, e.message);
      return false;
    }
  }
}
