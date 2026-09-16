import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_app/components/html_body.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/screens/lesson_content_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_firebase_regression_test.dart' show testCourse;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('web text lesson is recognized as an article and preserves HTML',
      () async {
    final db = FakeFirebaseFirestore();
    final doc = db.doc('courses/course-1/sections/section-1/lessons/text-1');
    await doc.set({
      'name': 'Text lesson',
      'order': 1,
      'content_type': 'text',
      'description': '<p>Lesson content</p>'
    });
    final lesson = Lesson.fromFiresore(await doc.get());
    expect(lesson.contentType, 'article');
    expect(lesson.description, '<p>Lesson content</p>');
    expect(lesson.questions, isEmpty);
  });

  testWidgets('video page shows player above readable lesson text',
      (tester) async {
    final lesson = Lesson(
        id: 'video',
        name: 'Video lesson title',
        order: 1,
        contentType: 'video',
        description: '<p>Lesson explanation</p>');
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: LessonContentPage(
      course: testCourse(),
      lesson: lesson,
      player: const ColoredBox(key: ValueKey('player'), color: Colors.black),
    ))));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.text('Video lesson title'), findsOneWidget);
    expect(find.byType(HtmlBody), findsOneWidget);
    expect(
        tester.getTopLeft(find.byType(HtmlBody)).dy,
        greaterThan(
            tester.getBottomLeft(find.byKey(const ValueKey('player'))).dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('article page renders HTML without a player or null placeholder',
      (tester) async {
    final lesson = Lesson(
        id: 'text',
        name: 'Text lesson',
        order: 1,
        contentType: 'article',
        description: '<h2>Chapter</h2><p>Body text</p>');
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: LessonContentPage(course: testCourse(), lesson: lesson))));
    await tester.pumpAndSettle();
    expect(tester.widget<HtmlBody>(find.byType(HtmlBody)).description,
        lesson.description);
    expect(find.byType(AspectRatio), findsNothing);
    expect(find.text('null'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
