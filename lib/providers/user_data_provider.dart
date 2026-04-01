import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

final userDataProvider = StateNotifierProvider<UserData, UserModel?>((ref) {
  return UserData();
});

class UserData extends StateNotifier<UserModel?> {
  UserData() : super(null);
  StreamSubscription? _subscription;

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
