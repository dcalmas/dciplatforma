import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_app/models/author.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/course_meta.dart';
import 'package:lms_app/models/review.dart';
import 'package:lms_app/models/review_user.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/services/firebase_service.dart';

Course testCourse() => Course(
      name: 'Test course',
      id: 'course-1',
      thumbnailUrl: '',
      createdAt: DateTime(2026),
      categoryId: null,
      status: 'live',
      author: Author(id: 'author-1', name: 'Author', imageUrl: null),
      studentsCount: 4,
      rating: 0,
      priceStatus: 'free',
      courseMeta: CourseMeta(),
      lessonsCount: 2,
    );

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseService service;
  final user = UserModel(
      id: 'student-1', email: '', name: 'Student', enrolledCourses: []);

  setUp(() async {
    db = FakeFirebaseFirestore();
    service = FirebaseService(firestore: db);
    await db.doc('users/student-1').set({
      'name': 'Student',
      'enrolled': [],
      'wishlist': ['other']
    });
    await db
        .doc('courses/course-1')
        .set({'students': 4, 'price_status': 'free'});
    await db.doc('users/author-1').set({
      'author_info': {'students': 12}
    });
  });

  test('recommendations fill from other categories and exclude current, draft and duplicates', () async {
    Future<void> saveCourse(String id, String category, String status) =>
        db.doc('courses/$id').set({
          'name': id,
          'image_url': '',
          'created_at': Timestamp.fromDate(DateTime(2026)),
          'cat_id': category,
          'status': status,
          'author': {'id': 'author-1', 'name': 'Author', 'image_url': null},
          'price_status': 'free',
          'rating': 0,
          'students': 0,
          'meta': <String, dynamic>{},
          'lessons_count': 1,
        });
    await saveCourse('course-1', 'speech', 'live');
    await saveCourse('course-2', 'speech', 'live');
    await saveCourse('course-3', 'design', 'live');
    await saveCourse('course-4', 'design', 'draft');
    final current = testCourse()..categoryId = 'speech';
    final recommendations = await service.getRelatedCoursesByCategory(current, 5);
    expect(recommendations.map((course) => course.id), ['course-2', 'course-3']);
    expect(await service.getRelatedCoursesByCategory(current, 0), isEmpty);
    final limited = await service.getRelatedCoursesByCategory(current, 1);
    expect(limited.single.id, 'course-2');
    current.categoryId = null;
    expect((await service.getRelatedCoursesByCategory(current, 5)).map((course) => course.id),
        ['course-2', 'course-3']);
  });

  test('auth profile creation sets student defaults and never overwrites existing access', () async {
    final profile = UserModel(id: 'new-student', email: 'student@example.com', name: 'Student');
    await service.saveUserData(profile);
    final created = (await db.doc('users/new-student').get()).data()!;
    expect(created['role'], ['student']);
    expect(created['disabled'], false);
    expect(created['enrolled'], isEmpty);
    await db.doc('users/new-student').update({'enrolled': ['paid-course'], 'disabled': true});
    await service.saveUserData(profile);
    final existing = (await db.doc('users/new-student').get()).data()!;
    expect(existing['enrolled'], ['paid-course']);
    expect(existing['disabled'], true);
  });

  test('repeated enrollment is idempotent and preserves author and user data',
      () async {
    final result = await service.updateEnrollment(user, testCourse());
    await service.updateEnrollment(user, testCourse()); // stale caller / retry
    final saved = (await db.doc('users/student-1').get()).data()!;
    expect(result.enrolledCourses, ['course-1']);
    expect(user.enrolledCourses, isEmpty);
    expect(saved['enrolled'], ['course-1']);
    expect(saved['wishlist'], ['other']);
    expect(saved['enrolled_at']['course-1'], isA<Timestamp>());
    expect((await db.doc('courses/course-1').get()).data()!['students'], 5);
    expect(
        (await db.doc('users/author-1').get()).data()!['author_info']
            ['students'],
        12);
  });

  test('missing course or disabled user cannot leave partial enrollment',
      () async {
    await db.doc('courses/course-1').delete();
    await expectLater(
        service.updateEnrollment(user, testCourse()), throwsStateError);
    expect(
        (await db.doc('users/student-1').get()).data()!['enrolled'], isEmpty);
    await db.doc('courses/course-1').set({'students': 4});
    await db.doc('users/student-1').update({'disabled': true});
    await expectLater(
        service.updateEnrollment(user, testCourse()), throwsStateError);
    expect((await db.doc('courses/course-1').get()).data()!['students'], 4);
  });

  test('web reviews load with web fields and remain scoped to the course',
      () async {
    await db.doc('courses/course-1/reviews/web-review').set({
      'userId': user.id,
      'userName': 'Student',
      'userImage': '',
      'rating': 5,
      'text': 'Web review',
      'createdAt': Timestamp.fromDate(DateTime(2026)),
    });
    await db.doc('courses/other/reviews/other-review').set({
      'rating': 1,
      'createdAt': Timestamp.fromDate(DateTime(2026)),
    });
    final reviews = await service.getLimitedReviews('course-1', 3);
    expect(reviews.single.courseId, 'course-1');
    expect(reviews.single.review, 'Web review');
    expect(reviews.single.reviewUser.id, user.id);
    expect(
        (await service.getUserReview('course-1', user.id))!.id, 'web-review');
    expect((await service.getReviewsSnapshot(courseId: 'course-1')).size, 1);
    expect(await service.getCourseAverageRating('course-1'), 5);
  });

  test('mobile review writes the fields required by web and Firestore rules',
      () async {
    final review = Review(
        id: 'mobile-review',
        courseId: 'course-1',
        courseAuthorId: 'author-1',
        courseTitle: 'Test course',
        rating: 4,
        review: 'Mobile review',
        reviewUser: ReviewUser(id: user.id, name: user.name),
        createdAt: DateTime(2026));
    await service.saveReview('course-1', review);
    final saved =
        (await db.doc('courses/course-1/reviews/mobile-review').get()).data()!;
    expect(saved['userId'], user.id);
    expect(saved['text'], 'Mobile review');
    expect(saved['createdAt'], isA<Timestamp>());
    expect((await db.collection('reviews').get()).docs, isEmpty);
  });
}
