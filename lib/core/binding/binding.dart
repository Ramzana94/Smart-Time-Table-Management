import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/controllers/splash_controller.dart';

class InitialBinding extends Bindings{
  @override
  void dependencies(){
    Get.put(AuthController(), permanent: true);
    Get.put(SplashController(), permanent: true);
    Get.put(AdminDashboardController());
  }
}