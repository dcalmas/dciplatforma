import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/screens/course_details.dart/course_reviews.dart';
import 'package:lms_app/screens/course_details.dart/enroll_button.dart';
import 'course_firebase_regression_test.dart' show testCourse;

class ControlledEnrollButton extends EnrollButton {
  const ControlledEnrollButton(
      {super.key, required super.course, required this.action});
  final Future<void> Function() action;

  @override
  Future handleEnrollment(BuildContext context,
          {required UserModel? user,
          required Course course,
          required WidgetRef ref}) =>
      action();
}

void main() {
  testWidgets(
      'permission-denied in reviews shows retry instead of a build exception',
      (tester) async {
    var attempts = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        courseReviewProvider('course-1').overrideWith((ref) async {
          attempts++;
          if (attempts == 1) {
            throw FirebaseException(
                plugin: 'cloud_firestore', code: 'permission-denied');
          }
          return [];
        })
      ],
      child: MaterialApp(
          home: Scaffold(body: CourseReviews(course: testCourse()))),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('reviews-load-error'), findsOneWidget);
    await tester.tap(find.text('try-again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('reviews-load-error'), findsNothing);
  });

  testWidgets('failed enrollment clears spinner and blocks duplicate taps',
      (tester) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Scaffold(
      body: ControlledEnrollButton(
          course: testCourse(),
          action: () {
            calls++;
            return pending.future;
          }),
    ))));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
    await tester.tap(find.byType(ElevatedButton));
    expect(calls, 1);
    pending.completeError(FirebaseException(
        plugin: 'cloud_firestore', code: 'permission-denied'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull);
    expect(find.text('enrollment-error'), findsOneWidget);
  });

  testWidgets('enrollment timeout makes button usable again', (tester) async {
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Scaffold(
      body: ControlledEnrollButton(
          course: testCourse(), action: () => Completer<void>().future),
    ))));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(seconds: 31));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
