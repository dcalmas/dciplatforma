import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/gamification_service.dart';

final userDataProvider = StateNotifierProvider<UserData, UserModel?>((ref) {
  return UserData();
});

class UserData extends StateNotifier<UserModel?> {
  UserData() : super(null);
  StreamSubscription? _subscription;

  void applyEnrollment(UserModel user) {
    if (mounted && state?.id == user.id) state = user;
  }

  // Деректерді бір рет алу (Сплеш-скрин үшін)
  Future<UserModel?> fetchUserData() async {
    final user = await FirebaseService().getUserData();
    state = user;
    if (user != null) {
      // Вебтегі AuthContext.handleDailyLogin сол логикамен streak/XP.
      unawaited(GamificationService().handleDailyLogin(user.id));
    }
    return user;
  }

  // Реалды уақытта жаңарту (Стрим)
  Future getData() async {
    _subscription?.cancel();
    _subscription = FirebaseService().userDataStream().listen((user) {
      state = user;
      debugPrint('User Data Updated (Real-time)');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
