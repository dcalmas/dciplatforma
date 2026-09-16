import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/services/homework_service.dart';

Lesson lesson(String id, {bool required = false, String? homework}) {
  return Lesson(
    id: id,
    name: id,
    order: 0,
    contentType: 'article',
    homework: homework,
    homeworkRequired: required,
  );
}

void main() {
  test('document id matches web homeworkDocumentId encoding', () {
    expect(HomeworkService.homeworkDocumentId('u1', 'c1', 'l1'),
        'u1~c1~l1');
    // encodeURIComponent behavior + ~ escaping, like the web client
    expect(HomeworkService.homeworkDocumentId('a/b', 'c d', 'e~f'),
        'a%2Fb~c%20d~e%7Ef');
  });

  test('hasSubmittedHomework mirrors web rules', () {
    expect(HomeworkService.hasSubmittedHomework(null), isFalse);
    expect(HomeworkService.hasSubmittedHomework(
        {'text': '  ', 'status': 'pending'}), isFalse);
    expect(HomeworkService.hasSubmittedHomework(
        {'text': 'answer', 'status': 'pending'}), isTrue);
    expect(HomeworkService.hasSubmittedHomework(
        {'text': 'answer', 'status': 'approved'}), isTrue);
    expect(HomeworkService.hasSubmittedHomework(
        {'text': 'answer', 'status': 'rejected'}), isFalse);
  });

  test('mapHomeworkSubmissions keeps latest per lesson, filters course', () {
    final rows = [
      {
        'courseId': 'c1',
        'lessonId': 'l1',
        'text': 'old',
        'status': 'pending',
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(1000),
      },
      {
        'courseId': 'c1',
        'lessonId': 'l1',
        'text': 'new',
        'status': 'pending',
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(2000),
      },
      {
        'courseId': 'c2',
        'lessonId': 'l9',
        'text': 'other course',
        'status': 'pending',
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(3000),
      },
    ];
    final mapped = HomeworkService.mapHomeworkSubmissions(rows, 'c1');
    expect(mapped.keys, ['l1']);
    expect(mapped['l1']!['text'], 'new');
  });

  test('blocker mirrors web getLessonBlocker homework rule', () {
    final flat = [
      lesson('l1', required: true, homework: 'do it'),
      lesson('l2'),
      lesson('l3'),
    ];
    String? blocker(String lessonId,
            Map<String, Map<String, dynamic>> submissions) =>
        HomeworkService.blockingHomeworkLessonId(
          flatLessons: flat,
          lessonId: lessonId,
          completedLessonKeys: const {},
          courseId: 'c1',
          submissions: submissions,
        );

    // Nothing submitted: l2 and l3 blocked by l1, l1 itself open.
    expect(blocker('l1', {}), isNull);
    expect(blocker('l2', {}), 'l1');
    expect(blocker('l3', {}), 'l1');

    // Submitted (pending): everything open.
    final subs = {
      'l1': {'text': 'answer', 'status': 'pending'}
    };
    expect(blocker('l2', subs), isNull);
    expect(blocker('l3', subs), isNull);

    // Rejected counts as not submitted (web rule).
    final rejected = {
      'l1': {'text': 'answer', 'status': 'rejected'}
    };
    expect(blocker('l2', rejected), 'l1');
  });
}
