import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_analytics_controller.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/controllers/carousal_controller.dart';
import 'package:smart_timetable_managment/controllers/home_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/splash_controller.dart';
import 'package:smart_timetable_managment/controllers/student_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/timetable_controller.dart';
import 'package:smart_timetable_managment/controllers/user_session_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(SplashController(), permanent: true);
    Get.put(UserSessionController(), permanent: true);
    Get.put(AdminDashboardController(), permanent: true);
    Get.put(AdminAnalyticsController(), permanent: true);
    Get.put(HomeDashboardController(), permanent: true);
    Get.put(StudentDashboardController(), permanent: true);
    Get.put(TimetableController(), permanent: true);
        Get.put(FeatureCarouselController(), permanent: true);
  }
}
