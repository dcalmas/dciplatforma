import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_app/models/author_info.dart';

class UserModel {
  final String id, email, name;
  final String? phone;
  DateTime? createdAt;
  DateTime? updatedAt;
  final String? imageUrl;
  List? role;
  List? enrolledCourses;
  List? wishList;
  bool? isDisbaled;
  AuthorInfo? authorInfo;
  List? completedLessons;
  String? platform;
  List? reviews;

  // ── Геймификация (вебтегі users/{uid} өрістері) ──
  int? xp;
  List? badges;
  int? dailyStreak;
  DateTime? lastLoginDate;
  List? passedQuizzes;
  List? rewardedCourses;
  Map<String, dynamic>? enrolledExpirations;
  Map<String, dynamic>? lastLesson;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    this.imageUrl,
    required this.name,
    this.role,
    this.wishList,
    this.enrolledCourses,
    this.isDisbaled,
    this.createdAt,
    this.updatedAt,
    this.authorInfo,
    this.completedLessons,
    this.platform,
    this.reviews,
    this.xp,
    this.badges,
    this.dailyStreak,
    this.lastLoginDate,
    this.passedQuizzes,
    this.rewardedCourses,
    this.enrolledExpirations,
    this.lastLesson,
  });

  factory UserModel.fromFirebase(DocumentSnapshot snap) {
    final rawData = snap.data();
    if (rawData == null) {
      return UserModel(
        id: snap.id,
        email: '',
        name: '',
      );
    }
    Map<String, dynamic> d = rawData as Map<String, dynamic>;
    return UserModel(
      id: snap.id,
      email: d['email'] ?? '',
      phone: d['phone'],
      imageUrl: d['image_url'],
      name: d['name'] ?? '',
      role: d['role'] ?? [],
      isDisbaled: d['disabled'] == true || d['deleted'] == true,
      createdAt: d['created_at'] != null ? (d['created_at'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: d['updated_at'] == null ? null : (d['updated_at'] as Timestamp).toDate(),
      authorInfo: d['author_info'] == null ? null : AuthorInfo.fromMap(d['author_info']),
      enrolledCourses: d['enrolled'] ?? [],
      wishList: d['wishlist'] ?? [],
      completedLessons: d['completed_lessons'] ?? [],
      platform: d['platform'],
      reviews: d['reviews'] ?? [],
      xp: (d['xp'] as num?)?.toInt() ?? 0,
      badges: d['badges'] ?? [],
      dailyStreak: (d['daily_streak'] as num?)?.toInt() ?? 0,
      lastLoginDate: _toDate(d['last_login_date']),
      passedQuizzes: d['passed_quizzes'] ?? [],
      rewardedCourses: d['rewarded_courses'] ?? [],
      enrolledExpirations: d['enrolled_expirations'] == null
          ? null
          : Map<String, dynamic>.from(d['enrolled_expirations'] as Map),
      lastLesson: d['last_lesson'] == null
          ? null
          : Map<String, dynamic>.from(d['last_lesson'] as Map),
    );
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Map<String, dynamic> getMap(UserModel user) {
    return {
      'email': user.email,
      'phone': user.phone,
      'name': user.name,
      'image_url': user.imageUrl,
      'created_at': user.createdAt,
      'platform': user.platform,
    };
  }
}
