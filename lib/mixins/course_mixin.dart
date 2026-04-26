import 'package:lms_app/models/course.dart';
import 'package:lms_app/models/lesson.dart';
import 'package:lms_app/models/user_model.dart';

mixin CourseMixin {

  bool isLessonCompleted(Lesson lesson, UserModel? user) {
    if (user != null && user.completedLessons != null && user.completedLessons!.any((element) => element.toString().contains(lesson.id))) {
      return true;
    } else {
      return false;
    }
  }

  static String enrollButtonText(Course course, UserModel? user) {
    if (user == null) return 'enroll-now';
    
    // Егер оқушы тіркелген болса (enrolledCourses ішінде бар ма)
    bool isEnrolled = user.enrolledCourses != null && user.enrolledCourses!.contains(course.id);
    
    if (!isEnrolled) {
      return 'enroll-now';
    } else {
      if (user.completedLessons == null || user.completedLessons!.isEmpty) return 'start-course';
      
      List validIds = user.completedLessons!.where((element) => element.toString().contains(course.id)).toList();
      final double courseProgess = validIds.isEmpty ? 0 : (validIds.length / (course.lessonsCount != 0 ? course.lessonsCount : 1));
      
      if (courseProgess == 0) {
        return 'start-course';
      } else if (courseProgess > 0 && courseProgess < 1) {
        return 'continue-course';
      } else {
        return 'restart-course';
      }
    }
  }
}
