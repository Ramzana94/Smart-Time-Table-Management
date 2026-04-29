import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/user_session_controller.dart';
import 'package:smart_timetable_managment/models/user_profile_model.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final UserSessionController _userSessionController =
      Get.find<UserSessionController>();
  final userRole = 'Student'.obs;

  RxBool get isLoadingRole => _userSessionController.isLoading;

  @override
  void onInit() {
    super.onInit();
    userRole.value = _userSessionController.userRole;

    ever<UserProfileModel?>(_userSessionController.currentUser, (profile) {
      final role = profile?.role.trim() ?? '';
      userRole.value = role.isEmpty ? 'Student' : role;
    });
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}