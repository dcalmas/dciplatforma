import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/user_model.dart';
import 'package:lms_app/screens/curricullam_screen.dart';
import 'package:lms_app/screens/home/home_bottom_bar.dart';
import 'package:lms_app/screens/home/home_view.dart';
import 'package:lms_app/screens/intro.dart';
import 'package:lms_app/screens/course_details.dart/sections.dart';
import 'package:lms_app/screens/auth/login.dart';
import 'package:lms_app/services/auth_service.dart';
import 'package:lms_app/services/firebase_service.dart';
import 'package:lms_app/utils/next_screen.dart';
import 'package:lms_app/utils/snackbars.dart';
import '../providers/user_data_provider.dart';

mixin UserMixin {
  void handleLogout(context, {required WidgetRef ref}) async {
    await AuthService()
        .userLogOut()
        .onError((error, stackTrace) => debugPrint('error: $error'));
    await AuthService()
        .googleLogout()
        .onError((error, stackTrace) => debugPrint('error1: $error'));
    ref.invalidate(userDataProvider);
    ref.invalidate(homeTabControllerProvider);
    ref.invalidate(navBarIndexProvider);
    NextScreen.closeOthersAnimation(context, const IntroScreen());
  }

  bool hasEnrolled(UserModel? user, Course course) {
    if (user != null &&
        user.enrolledCourses != null &&
        user.enrolledCourses!.contains(course.id)) {
      return true;
    } else {
      return false;
    }
  }

  Future handleEnrollment(
    BuildContext context, {
    required UserModel? user,
    required Course course,
    required WidgetRef ref,
  }) async {
    if (user != null) {
      if (course.priceStatus == 'free') {
        if (hasEnrolled(user, course)) {
          NextScreen.iOS(context, CurriculamScreen(course: course));
        } else {
          await _comfirmEnrollment(context, user, course, ref);
        }
      } else {
        // Платный курс: өздігінен жазылу жоқ, доступты админ береді.
        if (hasEnrolled(user, course)) {
          NextScreen.iOS(context, CurriculamScreen(course: course));
        } else {
          openSnackbar(context, 'enroll-to-view-curriculum'.tr());
        }
      }
    } else {
      NextScreen.normal(context, const LoginScreen(popUpScreen: true));
    }
  }

  Future _comfirmEnrollment(BuildContext context, UserModel user, Course course,
      WidgetRef ref) async {
    try {
      final updatedUser = await FirebaseService().updateEnrollment(user, course);
      if (!context.mounted) return;
      ref.read(userDataProvider.notifier).applyEnrollment(updatedUser);
      ref.invalidate(sectionsProvider(course.id));
      openSnackbar(context, 'Enrolled Succesfully');
    } catch (e) {
      debugPrint('enrollment error: $e');
      if (!context.mounted) return;
      openSnackbarFailure(context, e.toString());
    }
  }

  Future handleOpenCourse(
    BuildContext context, {
    required UserModel user,
    required Course course,
  }) async {
    // ТЕК ЖАҢАРТУ: Егер қолданушы осы функцияны шақырса (батырманы басса),
    // біз оған курсты ашуға рұқсат береміз, өйткені бұл функция тек MyCourses бөлімінде
    // немесе тіркелген қолданушылар үшін шақырылуы тиіс.
    NextScreen.iOS(context, CurriculamScreen(course: course));
  }
}
