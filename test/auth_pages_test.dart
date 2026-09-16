import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/screens/auth/sign_up.dart';
import 'package:lms_app/screens/auth/reset_password.dart';
import 'package:lms_app/screens/auth/social_logins.dart';

void main() {
  testWidgets('auth pages fit a narrow phone and social login follows the form', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final page in <Widget>[const LoginScreen(), const SignUpScreen(), const ResetPassword()]) {
      await tester.pumpWidget(ProviderScope(child: MaterialApp(home: page)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (page is! ResetPassword) {
        expect(tester.getTopLeft(find.byType(SocialLogins)).dy,
            greaterThan(tester.getBottomLeft(find.byType(ElevatedButton).first).dy));
        expect(find.text('Войти через Google'), findsOneWidget);
        await tester.ensureVisible(find.text('Политикой конфиденциальности'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
  });
}
