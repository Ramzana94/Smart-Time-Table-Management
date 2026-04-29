import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/admin_dashboard.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/student_dashboard.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/teacher_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final navCtrl = Get.find<NavigationController>();
final adminCtrl=Get.find<AdminDashboardController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final role = navCtrl.userRole.value.trim();

        return getRoleDashboard(role);
      }),

floatingActionButton: Obx(() {
  final role = navCtrl.userRole.value.trim();
final tabIndex = adminCtrl.currentTabIndex.value;
  if (role == 'Admin') {
    if(tabIndex==2){
      return SizedBox.shrink();
    }
    return FloatingActionButton(
      shape: CircleBorder(),
      backgroundColor: AppColors.primary,
      onPressed: () {
        // 🔵 TAB 0 = Timetable
        if (tabIndex == 0) {
          adminCtrl.openDepartmentBottomSheet();
          
        }

        // 🏫 TAB 1 = Department
        else if (tabIndex == 1) {
          
           adminCtrl.openTeacherBottomSheet();
         
        }

        // 🧑‍🏫 TAB 2 = Teachers
        else if (tabIndex == 2) {
          Get.snackbar("Teachers", "Add Teacher");
        }

        // 📊 TAB 3 = Analytics
        else {
          Get.snackbar("Analytics", "No action");
        }
        // adminCtrl.openCreateBottomSheet();
      },
      child: const Icon(Icons.add, color: AppColors.white,),
    );
  }

  // if (role == 'Teacher') {
  //   return FloatingActionButton.extended(
  //     backgroundColor: AppColors.primary,
  //     onPressed: () {
  //       Get.snackbar("Teacher", "Edit Timetable");
  //     },
  //     icon: const Icon(Icons.edit),
  //     label: const Text("Edit"),
  //   );
  // }

  // 👇 Student (or default)
  return const SizedBox.shrink();
}),
      
    );
  }

  Widget getRoleDashboard(String role) {
    switch (role) {
      case 'Admin':
        return AdminDasboard();

      case 'Teacher':
        return 
        // const 
        TeacherDashboard();

      default:
        return  StudentDashboard();
    }
  }
}