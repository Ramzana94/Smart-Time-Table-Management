// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:smart_timetable_management/controllers/navigation_controller.dart';
// import 'package:smart_timetable_management/core/constants/app_colors.dart';
// import 'package:smart_timetable_management/core/constants/app_icons.dart';
// import 'package:smart_timetable_management/core/constants/app_sizes.dart';
// import 'package:smart_timetable_management/core/constants/app_strings.dart';
// import 'package:smart_timetable_management/core/constants/app_weights.dart';
// import 'package:smart_timetable_management/views/dashboard/dashboard_screen.dart';
// import 'package:smart_timetable_management/views/notification_screen.dart';
// import 'package:smart_timetable_management/views/profile_screen.dart';
// import 'package:smart_timetable_management/views/dashboard/timetable/time_table_screen.dart';

// class NavigationScreen extends StatelessWidget {
//   NavigationScreen({super.key});

//   final NavigationController navigationController = Get.put(
//     NavigationController(),
//   );

//   @override
//   Widget build(BuildContext context) {
//     final role = navigationController.userRole.value.trim();
//     final isAdmin = navigationController.userRole.value.trim() == 'Admin';

//     final List<Widget> screens = [
//       DashboardScreen(),
//       TimeTableScreen(),
//       NotificationScreen(),
//       ProfileScreen(),
//     ];

//     String _getAppBarTitle(String role, int index) {
//       switch (index) {
//         case 0:
//           if (role == 'Admin') return AppStrings.dashboard;
//           return AppStrings.home; // Teacher + Student

//         case 1:
//           return AppStrings.timetable;

//         case 2:
//           return AppStrings.notifications;

//         case 3:
//           return AppStrings.profile;

//         default:
//           return AppStrings.home;
//       }
//     }

//     return Obx(() {
//       if (navigationController.isLoadingRole.value) {
//         return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       }

//       return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             _getAppBarTitle(role, navigationController.currentIndex.value),
//           ),
//           centerTitle: true,
//           backgroundColor: AppColors.primary,
//           foregroundColor: AppColors.white,
//         ),
//         body: screens[navigationController.currentIndex.value],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: navigationController.currentIndex.value,
//           selectedItemColor: AppColors.primary,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           selectedFontSize: AppSizes.s14,
//           selectedLabelStyle: TextStyle(fontWeight: AppWeights.w500),
//           backgroundColor: AppColors.white,

//           type: BottomNavigationBarType.fixed,
//           onTap: (index) {
//             navigationController.changeIndex(index);
//           },
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(isAdmin ? AppIcons.apartment : AppIcons.home),
//               label: isAdmin ? AppStrings.dashboard : AppStrings.home,
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(AppIcons.timetable),
//               label: AppStrings.timetable,
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(AppIcons.notificationsActive),
//               label: AppStrings.notifications,
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(AppIcons.profile),
//               label: AppStrings.profile,
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/views/dashboard/dashboard_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/timetable/timetable_screen.dart';
import 'package:smart_timetable_managment/views/notification_screen.dart';
import 'package:smart_timetable_managment/views/profile_screen.dart';

class NavigationScreen extends StatelessWidget {
  NavigationScreen({super.key});

  final NavigationController navigationController = Get.put(
    NavigationController(),
  );

  //  AppBar title 
  String _getAppBarTitle(String role, int index) {
    switch (index) {
      case 0:
        return role == 'Admin'
            ? AppStrings.dashboard
            : AppStrings.home;

      case 1:
        return AppStrings.timetable;

      case 2:
        return AppStrings.notifications;

      case 3:
        return AppStrings.profile;

      default:
        return AppStrings.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(),
      TimeTableScreen(),
      NotificationScreen(),
      ProfileScreen(),
    ];
    return Obx(() {
      if (navigationController.isLoadingRole.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      final role = navigationController.userRole.value.trim();
      final isAdmin = role == 'Admin';

      return Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(
              role,
              navigationController.currentIndex.value,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),

        body: screens[navigationController.currentIndex.value],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navigationController.currentIndex.value,
          selectedItemColor: AppColors.primary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: AppSizes.s14,
          selectedLabelStyle: TextStyle(fontWeight: AppWeights.w500),
          backgroundColor: AppColors.white,
          type: BottomNavigationBarType.fixed,

          onTap: (index) {
            navigationController.changeIndex(index);
          },

          items: [
            BottomNavigationBarItem(
              icon: Icon(
                isAdmin
                    ? AppIcons.apartment   // Admin icon
                    : AppIcons.home,       // Teacher/Student icon
              ),
              label: isAdmin
                  ? AppStrings.dashboard
                  : AppStrings.home,
            ),

            BottomNavigationBarItem(
              icon: Icon(AppIcons.timetable),
              label: AppStrings.timetable,
            ),

            BottomNavigationBarItem(
              icon: Icon(AppIcons.notificationsActive),
              label: AppStrings.notifications,
            ),

            BottomNavigationBarItem(
              icon: Icon(AppIcons.profile),
              label: AppStrings.profile,
            ),
          ],
        ),
      );
    });
  }
}