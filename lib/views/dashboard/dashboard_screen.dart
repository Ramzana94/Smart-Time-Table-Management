import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/admin_dashboard.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/student_dashboard.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/teacher_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final navCtrl = Get.find<NavigationController>();
  final adminCtrl = Get.find<AdminDashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final role = navCtrl.userRole.value.trim();
        return _getRoleDashboard(role);
      }),
      floatingActionButton: Obx(() {
        final role = navCtrl.userRole.value.trim();
        final tabIndex = adminCtrl.currentTabIndex.value;

        if (role == 'Admin') {
          if (tabIndex == 2) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: AppColors.primary,
            onPressed: () {
              switch (tabIndex) {
                case 0:
                  adminCtrl.openDepartmentBottomSheet();
                  break;
                case 1:
                  adminCtrl.openTeacherBottomSheet();
                  break;
              }
            },
            child: const Icon(AppIcons.add, color: AppColors.white),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _getRoleDashboard(String role) {
    switch (role) {
      case 'Admin':
        return AdminDasboard();
      case 'Teacher':
        return  TeacherDashboard();
      default:
        return  StudentDashboard();
    }
  }
}