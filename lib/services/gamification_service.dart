import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Веб-клиенттегі (lms_web) `src/utils/gamification.js` логикасының
/// Dart көшірмесі. DB схемасы мен транзакция/идемпотенттілік
/// тәртібі вебпен толық үйлесімді.
class GamificationService {
  GamificationService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const Map<String, dynamic> defaults = {
    'enabled': true,
    'xpPerLesson': 100,
    'xpPerQuizPass': 50,
    'xpPerCourseComplete': 500,
    'xpPerDailyLogin': 20,
    'levels': [
      {'level': 1, 'xpRequired': 0, 'nameKk': 'Жаңа бастаушы', 'nameRu': 'Новичок', 'nameEn': 'Beginner'},
      {'level': 2, 'xpRequired': 100, 'nameKk': 'Оқушы', 'nameRu': 'Ученик', 'nameEn': 'Student'},
      {'level': 3, 'xpRequired': 400, 'nameKk': 'Белсенді', 'nameRu': 'Активный', 'nameEn': 'Active'},
      {'level': 4, 'xpRequired': 1000, 'nameKk': 'Сарапшы', 'nameRu': 'Эксперт', 'nameEn': 'Expert'},
      {'level': 5, 'xpRequired': 2000, 'nameKk': 'Шебер', 'nameRu': 'Мастер', 'nameEn': 'Master'},
    ],
    'badges': [
      {'id': 'first_lesson', 'icon': '⭐', 'nameKk': 'Бірінші сабақ', 'nameRu': 'Первый урок', 'nameEn': 'First Lesson'},
      {'id': 'five_lessons', 'icon': '🌟', 'nameKk': '5 сабақ', 'nameRu': '5 уроков', 'nameEn': '5 Lessons'},
      {'id': 'ten_lessons', 'icon': '💫', 'nameKk': '10 сабақ', 'nameRu': '10 уроков', 'nameEn': '10 Lessons'},
      {'id': 'course_complete', 'icon': '🏆', 'nameKk': 'Курс аяқталды', 'nameRu': 'Курс завершен', 'nameEn': 'Course Complete'},
      {'id': 'quiz_master', 'icon': '🧠', 'nameKk': 'Тест шебері', 'nameRu': 'Мастер тестов', 'nameEn': 'Quiz Master'},
    ],
  };

  Map<String, dynamic>? _cachedSettings;

  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final snap = await _db.doc('settings/gamification').get();
      if (snap.exists && snap.data()?['enabled'] != false) {
        _cachedSettings = snap.data();
        return _cachedSettings!;
      }
    } catch (e) {
      debugPrint('gamification settings load error: $e');
    }
    _cachedSettings = Map<String, dynamic>.from(defaults);
    return _cachedSettings!;
  }

  Map<String, dynamic> get settings =>
      _cachedSettings ?? Map<String, dynamic>.from(defaults);

  /// Provider-дан тікелей берілген баптауларды жаңартады (деңгей/бейдж атаулары).
  void setCachedSettings(Map<String, dynamic>? settings) {
    if (settings != null) _cachedSettings = settings;
  }

  String levelName(String lang, Map<String, dynamic> level) {
    if (lang == 'kk') return level['nameKk']?.toString() ?? '';
    if (lang == 'ru') return level['nameRu']?.toString() ?? '';
    return level['nameEn']?.toString() ?? '';
  }

  bool get enabled => settings['enabled'] != false;

  int get xpPerLesson => (settings['xpPerLesson'] as num?)?.toInt() ?? 100;
  int get xpPerQuizPass => (settings['xpPerQuizPass'] as num?)?.toInt() ?? 50;
  int get xpPerCourseComplete =>
      (settings['xpPerCourseComplete'] as num?)?.toInt() ?? 500;
  int get xpPerDailyLogin => (settings['xpPerDailyLogin'] as num?)?.toInt() ?? 20;

  List<Map<String, dynamic>> get levels => (settings['levels'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
      List<Map<String, dynamic>>.from(
          (defaults['levels'] as List).map((e) => Map<String, dynamic>.from(e)));

  List<Map<String, dynamic>> get badges =>
      (settings['badges'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];

  /// Вебтегі `getLevel`: xp-қа сәйкес ағымдағы деңгейді қайтарады.
  Map<String, dynamic> getLevel(int xp) {
    final current = levels.first;
    for (final l in levels) {
      if (xp >= (l['xpRequired'] as num).toInt()) return l;
    }
    return current;
  }

  /// Вебтегі `getNextLevel`: келесі деңгейді немесе null.
  Map<String, dynamic>? getNextLevel(int xp) {
    for (final l in levels) {
      if (xp < (l['xpRequired'] as num).toInt()) return l;
    }
    return null;
  }

  Future<void> awardXp(String userId, int amount) async {
    if (userId.isEmpty || amount <= 0) return;
    try {
      await _db.doc('users/$userId').update({
        'xp': FieldValue.increment(amount)
      });
    } catch (e) {
      debugPrint('Error awarding XP: $e');
    }
  }

  Future<void> awardLessonXp(String userId) async {
    await awardXp(userId, xpPerLesson);
  }

  Future<void> awardQuizXp(String userId) async {
    await awardXp(userId, xpPerQuizPass);
  }

  Future<void> awardBadge(String userId, String badgeId) async {
    if (userId.isEmpty || badgeId.isEmpty) return;
    try {
      await _db.doc('users/$userId').update({
        'badges': FieldValue.arrayUnion([badgeId])
      });
    } catch (e) {
      debugPrint('Error awarding badge: $e');
    }
  }

  /// Вебтегі `awardCourseXp`: бір курсқа бір рет XP + badge.
  Future<void> awardCourseXp(String userId, String courseId) async {
    if (userId.isEmpty || courseId.isEmpty) return;
    final userRef = _db.doc('users/$userId');
    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;
        final rewarded =
            List<String>.from(snapshot.data()?['rewarded_courses'] ?? []);
        if (rewarded.contains(courseId)) return;
        transaction.update(userRef, {
          'xp': FieldValue.increment(xpPerCourseComplete),
          'rewarded_courses': FieldValue.arrayUnion([courseId]),
        });
      });
      await awardBadge(userId, 'course_complete');
    } catch (e) {
      debugPrint('Error awarding course XP: $e');
    }
  }

  /// Вебтегі `completeQuiz`: тест өткенде бір рет XP береді.
  Future<bool> completeQuiz(String userId, String quizId) async {
    if (userId.isEmpty || quizId.isEmpty) return false;
    final userRef = _db.doc('users/$userId');
    try {
      await _db.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) return;
        final passed = List<String>.from(userSnap.data()?['passed_quizzes'] ?? []);
        if (passed.contains(quizId)) {
          throw StateError('ALREADY_PASSED');
        }
        transaction.update(userRef, {
          'xp': FieldValue.increment(xpPerQuizPass),
          'passed_quizzes': FieldValue.arrayUnion([quizId]),
        });
      });
      return true;
    } catch (e) {
      if (e is StateError && e.message == 'ALREADY_PASSED') return false;
      debugPrint('Error completing quiz: $e');
      return false;
    }
  }

  /// Вебтегі `handleDailyLogin`: күнделікті streak + XP (транзакциямен).
  Future<void> handleDailyLogin(String userId) async {
    if (userId.isEmpty) return;
    final userRef = _db.doc('users/$userId');
    try {
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;

        final data = snapshot.data() ?? {};
        final rawLast = data['last_login_date'];
        DateTime? lastLogin;
        if (rawLast is Timestamp) {
          lastLogin = rawLast.toDate();
        } else if (rawLast is String) {
          lastLogin = DateTime.tryParse(rawLast);
        }
        final now = DateTime.now();

        DateTime dateOnly(DateTime? dt) =>
            dt == null ? now : DateTime(dt.year, dt.month, dt.day);
        final today = dateOnly(now);
        final last = lastLogin == null ? null : dateOnly(lastLogin);

        final diffDays = last == null
            ? -1
            : today.difference(last).inDays;

        if (diffDays == 0) return;

        int newStreak = 1;
        if (diffDays == 1) {
          newStreak = ((data['daily_streak'] as num?)?.toInt() ?? 0) + 1;
        }

        transaction.update(userRef, {
          'last_login_date': Timestamp.now(),
          'daily_streak': newStreak,
          'xp': FieldValue.increment(xpPerDailyLogin),
        });
      });
    } catch (e) {
      debugPrint('Error handling daily login: $e');
    }
  }
}

/// `settings/gamification` құжатын оқитын provider (вебтегі loadGamificationSettings).
final gamificationSettingsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) {
  return GamificationService().loadSettings();
});