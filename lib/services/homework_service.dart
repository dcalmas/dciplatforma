import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/services/firebase_service.dart';

/// Веб-клиенттегі (lms_web) үй тапсырмасы логикасының Dart көшірмесі.
///
/// Firestore: `homework_submissions` коллекциясы,
/// құжат ID = `userId~courseId~lessonId` (URI-encode, `~` -> `%7E`).
/// Өрістер: userId, courseId, lessonId, text, status
/// (pending/approved/rejected), createdAt, updatedAt.
class HomeworkService {
  HomeworkService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static const String collectionName = 'homework_submissions';

  /// Вебтегі `homeworkDocumentId` дәл көшірмесі.
  static String homeworkDocumentId(String userId, String courseId, String lessonId) {
    return [userId, courseId, lessonId]
        .map((v) => Uri.encodeComponent(v).replaceAll('~', '%7E'))
        .join('~');
  }

  /// Вебтегі `hasSubmittedHomework` дәл көшірмесі.
  static bool hasSubmittedHomework(Map<String, dynamic>? submission) {
    if (submission == null) return false;
    final text = (submission['text'] as String?)?.trim() ?? '';
    if (text.isEmpty) return false;
    return ['pending', 'approved'].contains(submission['status']);
  }

  /// Вебтегі `mapHomeworkSubmissions` дәл көшірмесі:
  /// әр сабаққа ең соңғы жазбаны қайтарады.
  static Map<String, Map<String, dynamic>> mapHomeworkSubmissions(
      List<Map<String, dynamic>> rows, String courseId) {
    final Map<String, Map<String, dynamic>> submissions = {};
    int timestamp(dynamic value) {
      if (value is Timestamp) return value.millisecondsSinceEpoch;
      if (value is DateTime) return value.millisecondsSinceEpoch;
      if (value is Map && value['seconds'] is num) {
        return (value['seconds'] as num).toInt() * 1000;
      }
      return DateTime.tryParse(value?.toString() ?? '')?.millisecondsSinceEpoch ?? 0;
    }

    for (final row in rows) {
      if (row['courseId'] != courseId || row['lessonId'] == null) continue;
      final lessonId = row['lessonId'] as String;
      final existing = submissions[lessonId];
      if (existing == null ||
          timestamp(row['updatedAt'] ?? row['createdAt']) >=
              timestamp(existing['updatedAt'] ?? existing['createdAt'])) {
        submissions[lessonId] = row;
      }
    }
    return submissions;
  }

  /// Вебтегі `getLessonBlocker` (тек homework бөлігі;
  /// аппта sequential_unlock жоқ): алдыңғы сабақтардың
  /// міндетті ДЗ-сы тапсырылмаса, сол сабақтың id-ін қайтарады.
  /// Блок жоқ болса null.
  static String? blockingHomeworkLessonId({
    required List<Lesson> flatLessons,
    required String lessonId,
    required Set<String> completedLessonKeys,
    required String courseId,
    required Map<String, Map<String, dynamic>> submissions,
  }) {
    final index = flatLessons.indexWhere((l) => l.id == lessonId);
    if (index < 0) return lessonId;
    for (final lesson in flatLessons.sublist(0, index)) {
      if (lesson.homeworkRequired &&
          !hasSubmittedHomework(submissions[lesson.id])) {
        return lesson.id;
      }
    }
    return null;
  }

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection(collectionName);

  /// Ағымдағы қолданушының барлық ДЗ жазбаларының стримі (вебтегі useLearningData).
  Stream<List<Map<String, dynamic>>> watchMySubmissions() {
    final uid = _uid;
    if (uid == null) return Stream.value(const []);
    return _collection.where('userId', isEqualTo: uid).snapshots().map(
        (snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  /// Бір курстың ДЗ жазбаларын бір рет оқу (гейтинг үшін).
  Future<Map<String, Map<String, dynamic>>> fetchCourseSubmissions(
      String courseId) async {
    final uid = _uid;
    if (uid == null) return {};
    try {
      final snap = await _collection
          .where('userId', isEqualTo: uid)
          .where('courseId', isEqualTo: courseId)
          .get()
          .timeout(const Duration(seconds: 15));
      final rows =
          snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      return mapHomeworkSubmissions(rows, courseId);
    } catch (e) {
      debugPrint('homework fetch failed: $e');
      rethrow;
    }
  }

  /// Вебтегі `submitHomework` дәл көшірмесі (транзакциямен).
  /// Бос текстке лақтырмайды — false қайтарады, қалған қатеде throw.
  Future<bool> submitHomework({
    required String courseId,
    required String lessonId,
    required String text,
    String? existingDocId,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not signed in');
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final docId =
        existingDocId ?? homeworkDocumentId(uid, courseId, lessonId);
    final ref = _collection.doc(docId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final existing = snapshot.exists ? snapshot.data() : null;
      transaction.set(
          ref,
          {
            'userId': uid,
            'courseId': courseId,
            'lessonId': lessonId,
            'text': trimmed,
            'status': 'pending',
            'updatedAt': FieldValue.serverTimestamp(),
            'createdAt': existing?['createdAt'] ?? FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    }).timeout(const Duration(seconds: 20));
    return true;
  }
}

/// Курстың ДЗ жазбалары (сабақ тізіміндегі бейдж/құлып үшін).
final homeworkSubmissionsProvider = StreamProvider.autoDispose
    .family<Map<String, Map<String, dynamic>>, String>((ref, courseId) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(const {});
  return FirebaseFirestore.instance
      .collection(HomeworkService.collectionName)
      .where('userId', isEqualTo: uid)
      .where('courseId', isEqualTo: courseId)
      .snapshots()
      .map((snap) {
    final rows = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    return HomeworkService.mapHomeworkSubmissions(rows, courseId);
  });
});

/// Курстың барлық сабақтары (секциялар бойынша, order ретімен) —
/// вебтегі flatLessons, ДЗ гейтингі үшін.
final courseFlatLessonsProvider =
    FutureProvider.autoDispose.family<List<Lesson>, String>((ref, courseId) async {
  final service = FirebaseService();
  final sections = await service.getSections(courseId);
  final List<Lesson> flat = [];
  await Future.wait(sections.map((section) async {
    try {
      flat.addAll(await service.getLessons(courseId, section.id));
    } catch (e) {
      debugPrint('flat lessons load failed: $e');
    }
  }));
  flat.sort((a, b) => a.order.compareTo(b.order));
  return flat;
});

/// Админ/автор тексерісі (вебтегідей гейтинг оларға қолданылмайды).
bool isAdminUser(dynamic user) {
  final role = user?.role as List?;
  return role?.contains('admin') ?? false;
}
