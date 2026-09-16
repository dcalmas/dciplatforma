import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_app/services/phone_identity_service.dart';

void main() {
  test('phone formats match web canonical form; malformed identifiers rejected',
      () {
    for (final phone in ['+77000000001', '8 (700) 000-00-01', '77000000001']) {
      expect(PhoneIdentityService.normalize(phone)?['value'], '+77000000001');
    }
    for (final invalid in [
      'abc77000000001',
      '77000000001@',
      '',
      '123',
      '++77000000001'
    ]) {
      expect(PhoneIdentityService.normalize(invalid), isNull);
    }
  });

  test('email never performs a phone lookup', () async {
    final service = PhoneIdentityService(
        lookup: (_) async => throw StateError('Unexpected lookup'));
    expect(await service.resolve(' Test@Example.com '), 'test@example.com');
  });

  test('phone login and recovery use mapped email, not a synthetic address',
      () async {
    final service = PhoneIdentityService(lookup: (phone) async {
      expect(phone, '+77000000001');
      return {'found': true, 'email': 'student@example.com'};
    });
    expect(await service.resolve('87000000001'), 'student@example.com');
    expect(await service.resolve('87000000001', passwordReset: true),
        'student@example.com');
    await expectLater(
        service.resolve('87000000001', registration: true),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'email-already-in-use')));
  });

  test('only a confirmed missing mapping permits synthetic login/registration',
      () async {
    final service = PhoneIdentityService(lookup: (_) async => {'found': false});
    expect(await service.resolve('87000000001'), '77000000001@phone.lms.kz');
    expect(await service.resolve('87000000001', registration: true),
        '77000000001@phone.lms.kz');
    await expectLater(
        service.resolve('87000000001', passwordReset: true),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'phone-recovery-unavailable')));
  });

  test('resolver failures and corrupt mappings do not silently change accounts',
      () async {
    final offline = PhoneIdentityService(
        lookup: (_) async =>
            throw FirebaseFunctionsException(code: 'unavailable', message: 'Offline'));
    await expectLater(offline.resolve('87000000001'),
        throwsA(isA<FirebaseFunctionsException>()));
    final corrupt =
        PhoneIdentityService(lookup: (_) async => {'found': true, 'email': ''});
    await expectLater(
        corrupt.resolve('87000000001'), throwsA(isA<FirebaseAuthException>()));
    final malformed = PhoneIdentityService(lookup: (_) async => {});
    await expectLater(malformed.resolve('87000000001'),
        throwsA(isA<FirebaseFunctionsException>()));
  });

  test('synthetic email recovery is blocked even when entered directly',
      () async {
    await expectLater(
        PhoneIdentityService()
            .resolve('77000000001@phone.lms.kz', passwordReset: true),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'phone-recovery-unavailable')));
  });
}
