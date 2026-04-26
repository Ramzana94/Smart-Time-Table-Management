import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/views/dashboard/dashboard_screen.dart';
import 'package:smart_timetable_managment/views/notification_screen.dart';
import 'package:smart_timetable_managment/views/profile_screen.dart';
import 'package:smart_timetable_managment/views/timetable_screen.dart';

class NavigationScreen extends StatelessWidget {
  NavigationScreen({super.key});

  final NavigationController navigationController = Get.put(
    NavigationController(),
  );
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(),
      TimeTableScreen(),
      NotificationScreen(),
      ProfileScreen(),
    ];

    final List<String> titles = [
      AppStrings.dashboard,
      AppStrings.timetable,
      AppStrings.notifications,
      AppStrings.profile,
    ];

    return Obx(() {
      if (navigationController.isLoadingRole.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(titles[navigationController.currentIndex.value]),
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
          selectedLabelStyle: TextStyle(
            color: AppColors.white
          ),
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            navigationController.changeIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.home),
              label: AppStrings.dashboard,
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.timer),
              label: AppStrings.timetable,
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.notifications),
              label: AppStrings.notifications,
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.person),
              label: AppStrings.profile,
            ),
          ],
        ),
      );
    });
  }
}