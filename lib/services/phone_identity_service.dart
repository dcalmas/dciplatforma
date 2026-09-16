import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Uses the web client's server-side resolver, never a pre-auth users query.
class PhoneIdentityService {
  PhoneIdentityService({Future<Map<String, dynamic>> Function(String)? lookup})
      : _lookup = lookup ?? _lookupRemote;
  final Future<Map<String, dynamic>> Function(String) _lookup;
  static const phoneEmailDomain = 'phone.lms.kz';

  static Future<Map<String, dynamic>> _lookupRemote(String phone) async {
    final result = await FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable('resolvePhoneEmail',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 20)))
        .call({'phone': phone.replaceAll(RegExp(r'\D'), '')});
    if (result.data is! Map) {
      throw FirebaseFunctionsException(
          code: 'internal', message: 'Invalid phone resolver response');
    }
    return Map<String, dynamic>.from(result.data as Map);
  }

  static bool isEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

  static String normalizePhone(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length == 11 && digits.startsWith('8')) {
      digits = '7${digits.substring(1)}';
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = '7${digits.substring(1)}';
    } else if (digits.length == 10) {
      digits = '7$digits';
    }
    return '+$digits';
  }

  static Map<String, String>? normalize(String input) {
    final value = input.trim();
    if (isEmail(value)) return {'type': 'email', 'value': value.toLowerCase()};
    if (!RegExp(r'^\+?[0-9()\s-]+$').hasMatch(value)) return null;
    final phone = normalizePhone(value);
    if (phone.length < 9 || phone.length > 16) return null;
    return {'type': 'phone', 'value': phone};
  }

  static String syntheticEmail(String phone) =>
      '${phone.replaceAll(RegExp(r'\D'), '')}@$phoneEmailDomain';
  static bool isSyntheticEmail(String email) =>
      email.toLowerCase().endsWith('@$phoneEmailDomain');

  Future<String> resolve(String identifier,
      {bool registration = false, bool passwordReset = false}) async {
    final normalized = normalize(identifier);
    if (normalized == null) throw FirebaseAuthException(code: 'invalid-email');
    String email;
    if (normalized['type'] == 'email') {
      email = normalized['value']!;
    } else {
      final phone = normalized['value']!;
      final result = await _lookup(phone);
      if (result['found'] is! bool) {
        throw FirebaseFunctionsException(
            code: 'internal', message: 'Invalid phone resolver response');
      }
      if (registration && result['found'] == true) {
        throw FirebaseAuthException(code: 'email-already-in-use');
      }
      if (result['found'] == true) {
        final storedEmail = result['email'];
        if (storedEmail is! String || !isEmail(storedEmail)) {
          throw FirebaseAuthException(code: 'account-email-missing');
        }
        email = storedEmail.trim().toLowerCase();
      } else {
        email = syntheticEmail(phone);
      }
    }
    if (passwordReset && isSyntheticEmail(email)) {
      throw FirebaseAuthException(code: 'phone-recovery-unavailable');
    }
    return email;
  }
}
