import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Вебтегі `mintCertificate` callable + `certificates` коллекциясын оқу.
class CertificateInfo {
  const CertificateInfo({
    required this.code,
    required this.courseId,
    required this.courseName,
    required this.userName,
    this.issuedAt,
  });

  final String code;
  final String courseId;
  final String courseName;
  final String userName;
  final DateTime? issuedAt;

  factory CertificateInfo.fromMap(String id, Map<String, dynamic> d) {
    return CertificateInfo(
      code: d['code']?.toString() ?? id,
      courseId: d['courseId']?.toString() ?? '',
      courseName: d['courseName']?.toString() ?? '',
      userName: d['userName']?.toString() ?? '',
      issuedAt: d['issuedAt'] is Timestamp
          ? (d['issuedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

class CertificateService {
  CertificateService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static const String fallbackSiteUrl = 'https://tatti-til.vercel.app';

  /// Веб VerifyCertificate бетіне сілтеме.
  static String verifyUrl(String siteUrl, String code) =>
      '${siteUrl.replaceAll(RegExp(r'/+$'), '')}/verify/$code';

  /// admin-дегідей siteUrl (settings/general) немесе fallback.
  Future<String> siteUrl() async {
    try {
      final snap = await _db.doc('settings/general').get();
      final url = snap.data()?['siteUrl']?.toString();
      if (url != null && url.isNotEmpty) return url;
    } catch (e) {
      debugPrint('siteUrl load error: $e');
    }
    return fallbackSiteUrl;
  }

  /// Вебтегі mintCertificate дәл шақыруы: курс толық біткені server-side
  /// тексеріледі. Идемпотентті: бір курсқа бір сертификат (existed=true қайтады).
  Future<CertificateInfo?> mint({
    required String courseId,
    required String courseName,
    required String userName,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'mintCertificate',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 60)));
      final result = await callable.call<Map<String, dynamic>>(
          {'courseId': courseId});
      final data = result.data as Map;
      final code = data['code']?.toString();
      if (code == null) return null;
      return CertificateInfo(
        code: code,
        courseId: courseId,
        courseName: courseName,
        userName: userName,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('mintCertificate error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('mintCertificate error: $e');
      return null;
    }
  }

  /// Пайдаланушының сертификаттары (My Certificates).
  Stream<List<CertificateInfo>> watchMyCertificates() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _db
        .collection('certificates')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CertificateInfo.fromMap(d.id, d.data()))
            .toList());
  }

  Future<List<CertificateInfo>> fetchMyCertificates() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    try {
      final snap = await _db
          .collection('certificates')
          .where('userId', isEqualTo: uid)
          .get()
          .timeout(const Duration(seconds: 15));
      return snap.docs
          .map((d) => CertificateInfo.fromMap(d.id, d.data()))
          .toList();
    } catch (e) {
      debugPrint('certificates fetch error: $e');
      return [];
    }
  }
}

final myCertificatesProvider = StreamProvider.autoDispose
    .family<List<CertificateInfo>, String>((ref, userId) {
  return CertificateService().watchMyCertificates();
});

final certificateSiteUrlProvider =
    FutureProvider.autoDispose<String>((ref) {
  return CertificateService().siteUrl();
});