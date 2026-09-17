import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:lms_app/models/app_settings_model.dart';
import 'package:lms_app/models/category.dart';
import 'package:lms_app/models/chart_model.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/models/review.dart';
import 'package:lms_app/models/section.dart';
import 'package:lms_app/models/tag.dart';
import 'package:lms_app/services/app_service.dart';
import 'package:lms_app/utils/toasts.dart';

import '../models/user_model.dart';

class FirebaseService {
  FirebaseService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> _courseReviews(String courseId) =>
      firestore.collection('courses').doc(courseId).collection('reviews');

  static String getUID(String collectionName) =>
      FirebaseFirestore.instance.collection(collectionName).doc().id;

  Future updateStudentCountsOnCourse(bool isIncrement, String courseId) async {
    final DocumentReference docRef =
        firestore.collection('courses').doc(courseId);
    await firestore.runTransaction((transaction) {
      return transaction.get(docRef).then((DocumentSnapshot snapshot) {
        final Course course = Course.fromFirestore(snapshot);
        final int count = course.studentsCount;
        final int newCount = isIncrement ? (count + 1) : (count - 1);
        transaction.set(
            docRef, {'students': newCount}, SetOptions(merge: true));
      });
    }).then((value) => debugPrint('new count: $value'));
  }

  Future updateStudentCountsOnAuthor(bool isIncrement, String authorId) async {
    final DocumentReference docRef =
        firestore.collection('users').doc(authorId);
    await firestore.runTransaction((transaction) {
      return transaction.get(docRef).then((DocumentSnapshot snapshot) {
        final UserModel author = UserModel.fromFirebase(snapshot);
        final int count = author.authorInfo?.students ?? 0;
        final int newCount = isIncrement ? (count + 1) : (count - 1);
        final newData = {
          'author_info': {'students': newCount}
        };

        transaction.set(docRef, newData, SetOptions(merge: true));
      });
    }).then((value) => debugPrint('new count: $value'));
  }

  Future<List<Course>> getAllCourses() async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .where('status', isEqualTo: 'live')
        .orderBy('created_at', descending: true)
        .get()
        .then((QuerySnapshot? snapshot) {
      if (snapshot == null) return;
      data = snapshot.docs.map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getLatestCourses(int limit) async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .where('status', isEqualTo: 'live')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getRelatedCoursesByCategory(
      Course course, int limit) async {
    if (limit <= 0) return [];
    final courses = <String, Course>{};
    void addCourses(QuerySnapshot<Map<String, dynamic>> snapshot) {
      for (final doc in snapshot.docs) {
        if (doc.id != course.id && courses.length < limit) {
          courses.putIfAbsent(doc.id, () => Course.fromFirestore(doc));
        }
      }
    }

    if (course.categoryId != null) {
      try {
        addCourses(await firestore.collection('courses')
            .where('cat_id', isEqualTo: course.categoryId)
            .where('status', isEqualTo: 'live')
            .limit(limit + 1).get());
      } catch (error) {
        debugPrint('Related category courses: $error');
      }
    }
    if (courses.length < limit) {
      try {
        addCourses(await firestore.collection('courses')
            .where('status', isEqualTo: 'live')
            .limit(limit + 1).get());
      } catch (error) {
        if (courses.isEmpty) rethrow;
        debugPrint('Recommended courses: $error');
      }
    }
    return courses.values.toList();
  }

  Future<List<Course>> getFeaturedCourses() async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .where('featured', isEqualTo: true)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getFreeCourses() async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .where('price_status', isEqualTo: 'free')
        .where('status', isEqualTo: 'live')
        .limit(5)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getHomeCategoryCourses(
      String categoryId, int limit) async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .where('cat_id', isEqualTo: categoryId)
        .where('status', isEqualTo: 'live')
        .limit(5)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getCoursesByAuthorId(
      {int limit = 3, required String authorId}) async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .where('author.id', isEqualTo: authorId)
        .where('status', isEqualTo: 'live')
        .limit(3)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Category>> getHomeCategories(int limit) async {
    List<Category> data = [];
    await firestore
        .collection('categories')
        .orderBy('index', descending: false)
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Category.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Category>> getAllCategories() async {
    List<Category> data = [];
    await firestore
        .collection('categories')
        .orderBy('index', descending: false)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Category.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Tag>> getAllTags(int limit) async {
    List<Tag> data = [];
    await firestore
        .collection('tags')
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Tag.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Section>> getSections(String courseId) async {
    List<Section> data = [];
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .orderBy('order', descending: false)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Section.fromFiresore(e)).toList();
    });
    return data;
  }

  Future<List<Lesson>> getLessons(String courseId, String sectionId) async {
    List<Lesson> data = [];
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .orderBy('order', descending: false)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Lesson.fromFiresore(e)).toList();
    });
    return data;
  }

  Future<List<Review>> getLimitedReviews(String courseId, int limit) async {
    List<Review> data = [];
    await _courseReviews(courseId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = (snapshot?.docs ?? []).map((e) => Review.fromFirebase(e)).toList();
    });
    return data;
  }

  Future<QuerySnapshot?> getAllReviews(
      String courseId, DocumentSnapshot? lastDocument) async {
    QuerySnapshot? result;
    final CollectionReference ref = _courseReviews(courseId);
    if (lastDocument == null) {
      await ref
          .orderBy('createdAt', descending: false)
          .get()
          .then((QuerySnapshot? snap) {
        result = snap;
      });
    } else {
      await ref
          .orderBy('createdAt', descending: false)
          .startAfterDocument(lastDocument)
          .get()
          .then((QuerySnapshot? snap) {
        result = snap;
      });
    }

    return result;
  }

  Future<List<Tag>> getCourseTags(List tagIds) async {
    if (tagIds.isEmpty) return [];
    final List ids = tagIds.length > 10 ? tagIds.take(10).toList() : tagIds;
    List<Tag> data = [];
    await firestore
        .collection('tags')
        .where(FieldPath.documentId, whereIn: ids)
        .get()
        .then((QuerySnapshot? snapshot) {
      if (snapshot == null) return;
      data = snapshot.docs.map((e) => Tag.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<UserModel?> getUserData() async {
    UserModel? user;
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;
      final String userId = currentUser.uid;
      final DocumentSnapshot snap = await firestore
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 10));
      user = UserModel.fromFirebase(snap);
    } catch (e) {
      debugPrint('error on getting user data: $e');
    }

    return user;
  }

  Stream<UserModel?> userDataStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value(null);
    final String userId = currentUser.uid;
    return firestore.collection('users').doc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromFirebase(snap);
    });
  }

  Future<UserModel?> getAuthorData(String authorId) async {
    final DocumentSnapshot snap =
        await firestore.collection('users').doc(authorId).get();
    UserModel? user = UserModel.fromFirebase(snap);
    return user;
  }

  Future<AppSettingsModel?> getAppSettingsData() async {
    AppSettingsModel? settings;
    try {
      final DocumentSnapshot snap = await firestore
          .collection('settings')
          .doc('app')
          .get()
          .timeout(const Duration(seconds: 10));
      settings = AppSettingsModel.fromFirestore(snap);
    } catch (e) {
      debugPrint('error on getting app settings data: $e');
    }
    return settings;
  }

  Future updateWishList(UserModel user, Course course) async {
    final DocumentReference ref = firestore.collection('users').doc(user.id);
    final newCourseId = course.id;
    final List courses = user.wishList ?? [];

    if (courses.contains(newCourseId)) {
      await ref.update({
        'wishlist': FieldValue.arrayRemove([newCourseId])
      });
    } else {
      await ref.update({'wishlist': FieldValue.arrayUnion([newCourseId])});
    }
  }

  Future<UserModel> updateEnrollment(UserModel user, Course course) async {
    final userRef = firestore.collection('users').doc(user.id);
    // Жазылу server-side бекітіледі (promoteEnrollment триггері):
    // free курстар ғана, платный сұраныстар алынып тасталады.
    await userRef.update({
      'enroll_requests': FieldValue.arrayUnion([course.id]),
    });
    // Триггер бекіткенін күтеміз (әдетте 1-3 сек).
    for (int i = 0; i < 40; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      final snap = await userRef.get();
      if (!snap.exists) throw StateError('User no longer exists');
      final enrolled = List<String>.from(snap.data()?['enrolled'] ?? []);
      if (enrolled.contains(course.id)) {
        final updatedUser = UserModel.fromFirebase(snap);
        updatedUser.enrolledCourses = enrolled;
        return updatedUser;
      }
    }
    throw StateError('Enrollment not confirmed');
  }

  /// Вебтегі `markLessonComplete`: жасалған кілттер курсты id және slug
  /// бойынша жазылады (екі жүйеде де сабақтың өтуі бірдей көрінеді).
  /// Қайта шақылғанда белгі алынып тасталады (toggle).
  /// Сабақ жаңадан аяқталған болса true қайтарады.
  Future<bool> updateLessonMarkComplete(
      UserModel user, Course course, Lesson lesson) async {
    final DocumentReference ref = firestore.collection('users').doc(user.id);

    final List<String> aliases =
        [course.id, course.slug]
            .where((k) => k != null && k.isNotEmpty)
            .cast<String>()
            .toList();
    final List<String> completedKeys = aliases
        .map((key) => '${key}_${lesson.id}')
        .toSet()
        .toList();

    final List lessons = user.completedLessons ?? [];
    final bool alreadyComplete =
        completedKeys.any((key) => lessons.contains(key));

    if (alreadyComplete) {
      await ref.update({
        'completed_lessons': FieldValue.arrayRemove(completedKeys),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return false;
    } else {
      await ref.update({
        'completed_lessons': FieldValue.arrayUnion(completedKeys),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  Future<List<UserModel>> getTopAuthors({int limit = 5}) async {
    List<UserModel> data = [];
    await firestore
        .collection('users')
        .where('role', arrayContainsAny: ['author', 'admin'])
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
          data = (snapshot?.docs ?? []).map((e) => UserModel.fromFirebase(e)).toList();
        });
    return data;
  }

  Future<List<UserModel>> getAllAuthors() async {
    List<UserModel> data = [];
    await firestore
        .collection('users')
        .where('role', arrayContainsAny: ['author', 'admin'])
        .get()
        .then((QuerySnapshot? snapshot) {
          data = (snapshot?.docs ?? []).map((e) => UserModel.fromFirebase(e)).toList();
        });
    return data;
  }

  Future<void> saveUserData(UserModel user) async {
    final document = firestore.collection('users').doc(user.id);
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      if (!snapshot.exists) {
        transaction.set(document, {
          ...UserModel.getMap(user),
          'role': ['student'],
          'disabled': false,
          'enrolled': [],
          'wishlist': [],
          'completed_lessons': [],
          'reviews': [],
        });
      }
    });
  }

  Future updateUserProfile(UserModel user) async {
    try {
      await firestore
          .collection('users')
          .doc(user.id)
          .update({'name': user.name, 'image_url': user.imageUrl});
    } catch (e) {
      debugPrint('Error on updating user profile: $e');
      openToast('Failed to update data');
    }
  }

  Future<bool> isUserExists(String userId) async {
    DocumentSnapshot snap =
        await firestore.collection('users').doc(userId).get();
    if (snap.exists) {
      debugPrint('User Exists');
      return true;
    } else {
      debugPrint('New User');
      return false;
    }
  }

  //for wishlish and my courses
  Future<QuerySnapshot> getCoursesQuery(chunk) {
    Query itemsQuery = FirebaseFirestore.instance
        .collection('courses')
        .where(FieldPath.documentId, whereIn: chunk);
    return itemsQuery.get();
  }

  Future saveReview(String courseId, Review review) async {
    final Map<String, dynamic> data = Review.getMap(review);
    final DocumentReference ref = _courseReviews(courseId).doc(review.id);
    await ref.set(data, SetOptions(merge: true));
  }

  Future<Review?> getUserReview(String courseId, String userId) async {
    Review? review;
    final QuerySnapshot snap = await _courseReviews(courseId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.size != 0) {
      review = Review.fromFirebase(snap.docs.first);
    }
    return review;
  }

  Future<QuerySnapshot> getCoursesSnapshotByCategory(
      {required String categoryId, DocumentSnapshot? lastDocument}) async {
    QuerySnapshot snapshot;
    if (lastDocument == null) {
      snapshot = await firestore
          .collection('courses')
          .where('cat_id', isEqualTo: categoryId)
          .where('status', isEqualTo: 'live')
          .limit(10)
          .get();
    } else {
      snapshot = await firestore
          .collection('courses')
          .where('cat_id', isEqualTo: categoryId)
          .where('status', isEqualTo: 'live')
          .startAfterDocument(lastDocument)
          .limit(10)
          .get();
    }
    return snapshot;
  }

  Future<QuerySnapshot> getCoursesSnapshotByLatest(
      {DocumentSnapshot? lastDocument}) async {
    QuerySnapshot snapshot;
    if (lastDocument == null) {
      snapshot = await firestore
          .collection('courses')
          .where('status', isEqualTo: 'live')
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();
    } else {
      snapshot = await firestore
          .collection('courses')
          .where('status', isEqualTo: 'live')
          .orderBy('created_at', descending: true)
          .startAfterDocument(lastDocument)
          .limit(10)
          .get();
    }
    return snapshot;
  }

  Future<QuerySnapshot> getCoursesSnapshotByFreeCourses(
      {DocumentSnapshot? lastDocument}) async {
    QuerySnapshot snapshot;
    if (lastDocument == null) {
      snapshot = await firestore
          .collection('courses')
          .where('price_status', isEqualTo: 'free')
          .where('status', isEqualTo: 'live')
          .limit(10)
          .get();
    } else {
      snapshot = await firestore
          .collection('courses')
          .where('price_status', isEqualTo: 'free')
          .where('status', isEqualTo: 'live')
          .startAfterDocument(lastDocument)
          .limit(10)
          .get();
    }
    return snapshot;
  }

  Future<QuerySnapshot> getCoursesSnapshotByTag(
      {required String tagId, DocumentSnapshot? lastDocument}) async {
    QuerySnapshot snapshot;
    if (lastDocument == null) {
      snapshot = await firestore
          .collection('courses')
          .where('tag_ids', arrayContains: tagId)
          .where('status', isEqualTo: 'live')
          .limit(10)
          .get();
    } else {
      snapshot = await firestore
          .collection('courses')
          .where('tag_ids', arrayContains: tagId)
          .where('status', isEqualTo: 'live')
          .startAfterDocument(lastDocument)
          .limit(10)
          .get();
    }
    return snapshot;
  }

  Future<QuerySnapshot> getCoursesSnapshotByAuhtor(
      {required String authorId, DocumentSnapshot? lastDocument}) async {
    QuerySnapshot snapshot;
    if (lastDocument == null) {
      snapshot = await firestore
          .collection('courses')
          .where('author.id', isEqualTo: authorId)
          .where('status', isEqualTo: 'live')
          .limit(10)
          .get();
    } else {
      snapshot = await firestore
          .collection('courses')
          .where('author.id', isEqualTo: authorId)
          .where('status', isEqualTo: 'live')
          .startAfterDocument(lastDocument)
          .limit(10)
          .get();
    }
    return snapshot;
  }

  Future<QuerySnapshot> getReviewsSnapshot(
      {required String courseId, DocumentSnapshot? lastDocument}) async {
    QuerySnapshot snapshot;
    if (lastDocument == null) {
      snapshot = await _courseReviews(courseId)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
    } else {
      snapshot = await _courseReviews(courseId)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(10)
          .get();
    }
    return snapshot;
  }

  /// Аватарды жүктеу: <=2 МБ тексереді, WebP-ке түрлендіреді (max 512px),
  /// `user_images/{uid}/avatar.webp` тұрақты жолына жоғары-қойып жазады
  /// (ескі фото автоматты толығымен жойылады) және legacy avatar_* файлдарды тазалайды.
  Future<String?> uploadImageToHosting(
    XFile imageFile, {
    required String uid,
    String? oldImageUrl,
  }) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.length > 2 * 1024 * 1024) {
      throw const FormatException('image_too_large');
    }
    final webpBytes = await _encodeWebp(bytes);
    if (webpBytes == null) {
      throw const FormatException('invalid_image');
    }

    final Reference storageReference =
        FirebaseStorage.instance.ref().child('user_images/$uid/avatar.webp');
    await storageReference.putData(
      webpBytes,
      SettableMetadata(
        contentType: 'image/webp',
        cacheControl: 'public,max-age=31536000,immutable',
      ),
    );
    final imageUrl = await storageReference.getDownloadURL();

    await _cleanupOldAvatars(storageReference, oldImageUrl);
    return imageUrl;
  }

  /// Рұқсат етілген кескінді WebP-ке айналдырады (max ені/биіктігі 512px,
  /// quality 85, EXIF метадатасы алынып тасталады). Кескін емес болса null қайтарады.
  Future<Uint8List?> _encodeWebp(Uint8List bytes) async {
    try {
      final List<int> result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 512,
        minHeight: 512,
        quality: 85,
        format: CompressFormat.webp,
        keepExif: false,
      );
      return Uint8List.fromList(result);
    } catch (_) {
      return null;
    }
  }

  /// Мұралық (legacy) аватар файлдарын жою: uid папкасындағы avatar_*
  /// және ескі image_url көрсеткен файл. Қателерді елемейді (best-effort).
  Future<void> _cleanupOldAvatars(
      Reference newAvatarRef, String? oldImageUrl) async {
    try {
      final folder =
          FirebaseStorage.instance.ref().child('user_images/${newAvatarRef.parent!.name}');
      final results = await folder.listAll();
      for (final item in results.items) {
        if (item.name != 'avatar.webp') {
          try {
            await item.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
    if (oldImageUrl == null || oldImageUrl.isEmpty) return;
    try {
      final oldRef = FirebaseStorage.instance.refFromURL(oldImageUrl);
      if (oldRef.fullPath != newAvatarRef.fullPath) {
        await oldRef.delete();
      }
    } catch (_) {}
  }

  Future<int> getAuthorReviewsCount(String auhtorId) async {
    final CollectionReference collectionReference =
        firestore.collection('reviews');
    final AggregateQuerySnapshot snap = await collectionReference
        .where('course_author_id', isEqualTo: auhtorId)
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getAuthorCourseCount(String auhtorId) async {
    final CollectionReference collectionReference =
        firestore.collection('courses');
    final AggregateQuerySnapshot snap = await collectionReference
        .where('author.id', isEqualTo: auhtorId)
        .where('status', isEqualTo: 'live')
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future deleteUserDatafromDatabase(String userId) async {
    await firestore.collection('users').doc(userId).delete();
  }

  Future<double> getCourseAverageRating(String courseId) async {
    double averageRating = 0.0;
    final QuerySnapshot snapshot = await _courseReviews(courseId).limit(200).get();
    final List<Review> reviews =
        snapshot.docs.map((e) => Review.fromFirebase(e)).toList();

    if (reviews.isEmpty) {
      averageRating = 0.0;
    } else if (reviews.length <= 1) {
      averageRating = reviews.first.rating;
    } else {
      final int totalRatingCount = reviews.length;
      double totalRatingValue = 0;
      reviews.forEach(
          (element) => totalRatingValue = totalRatingValue + element.rating);
      averageRating = totalRatingValue / totalRatingCount;
    }

    return averageRating;
  }

  Future saveCourseRating(String courseId, double rating) async {
    final CollectionReference collectionReference =
        firestore.collection('courses');
    await collectionReference
        .doc(courseId)
        .update({'rating': rating}).catchError(
            (error) => openToast('Failed to update course rating'));
  }

  Future updateUserStats() async {
    final String id = AppService.getTodaysID();
    final DocumentReference docRef = firestore.collection('user_stats').doc(id);
    await firestore.runTransaction((transaction) {
      return transaction.get(docRef).then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          final ChartModel chartModel = ChartModel.fromFirestore(snapshot);
          final newChartModel = ChartModel(
              id: chartModel.id,
              count: chartModel.count + 1,
              timestamp: chartModel.timestamp);
          final Map<String, dynamic> data = ChartModel.getMap(newChartModel);
          transaction.set(docRef, data, SetOptions(merge: true));
        } else {
          final newChartModel =
              ChartModel(id: id, count: 1, timestamp: DateTime.now().toUtc());
          final Map<String, dynamic> data = ChartModel.getMap(newChartModel);
          transaction.set(docRef, data, SetOptions(merge: true));
        }
      });
    });
  }

  Future updateUserReviewList(UserModel user, Course course) async {
    final DocumentReference ref = firestore.collection('users').doc(user.id);
    final newCourseId = course.id;
    final List reviews = user.reviews ?? [];
    reviews.add(newCourseId);
    await ref.update({'reviews': FieldValue.arrayUnion(reviews)});
  }
}
