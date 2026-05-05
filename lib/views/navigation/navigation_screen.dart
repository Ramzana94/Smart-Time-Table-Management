import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/controllers/timetable_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/views/dashboard/dashboard_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/timetable/timetable_screen.dart';
import 'package:smart_timetable_managment/views/notification_screen.dart';
import 'package:smart_timetable_managment/views/profile_screen.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_dropdown.dart';

class NavigationScreen extends StatelessWidget {
  NavigationScreen({super.key});

  final NavigationController navigationController = Get.put(
    NavigationController(),
  );
  final TimetableController timetableCtrl = Get.find<TimetableController>();

  //  AppBar title
  String _getAppBarTitle(String role, int index) {
    switch (index) {
      case 0:
        return role == 'Admin' ? AppStrings.dashboard : AppStrings.home;

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
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final role = navigationController.userRole.value.trim();
      final isAdmin = role == 'Admin';

      return Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(role, navigationController.currentIndex.value),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            if (navigationController.currentIndex.value == 1)
              IconButton(
                icon: const Icon(Icons.tune_outlined),
                onPressed: () => _showFilterBottomSheet(context),
              ),
          ],
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
                    ? AppIcons
                          .apartment // Admin icon
                    : AppIcons.home, // Teacher/Student icon
              ),
              label: isAdmin ? AppStrings.dashboard : AppStrings.home,
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

  void _showFilterBottomSheet(BuildContext context) {
    final deptNotifier = ValueNotifier<String?>(
      timetableCtrl.selectedDepartment.value,
    );

    final semesterNotifier = ValueNotifier<String?>(
      timetableCtrl.selectedSemester.value,
    );

    final shiftNotifier = ValueNotifier<String?>(
      timetableCtrl.selectedShift.value,
    );
    ever(timetableCtrl.selectedDepartment, (value) {
      deptNotifier.value = value;
    });

    ever(timetableCtrl.selectedSemester, (value) {
      semesterNotifier.value = value;
    });

    ever(timetableCtrl.selectedShift, (value) {
      shiftNotifier.value = value;
    });
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: StreamBuilder<List<TimetableModel>>(
          stream: timetableCtrl.getTimetable(),
          builder: (context, snapshot) {
            final allEntries = snapshot.data ?? const <TimetableModel>[];

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 52,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6DEEC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filter Timetable',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF12284A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final departmentOptions = timetableCtrl.departmentOptions(
                        allEntries,
                      );
                      var semesterOptions = timetableCtrl.semesterOptions(
                        allEntries,
                        department: timetableCtrl.selectedDepartment.value,
                      );
    

                      final shiftOptions = timetableCtrl.shiftOptions(
                        allEntries,
                        department: timetableCtrl.selectedDepartment.value,
                        semester: timetableCtrl.selectedSemester.value,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomDropdown<String>(
                            items: departmentOptions,
                            itemLabel: (e) => e,
                            hintText: AppStrings.departments,
                            valueListenable: deptNotifier,
                            onChanged: (value) {
                              timetableCtrl.updateDepartment(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomDropdown<String>(
                            items: semesterOptions,
                            itemLabel: (e) => e,
                            hintText: AppStrings.semester,
                            valueListenable: semesterNotifier,
                            onChanged: (value) {
                              timetableCtrl.updateSemester(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomDropdown<String>(
                            items: shiftOptions,
                            itemLabel: (e) => e,
                            hintText: AppStrings.shift,
                            valueListenable: shiftNotifier,
                            onChanged: (value) {
                              timetableCtrl.updateShift(value);
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  onPressed: () {
                                    timetableCtrl.selectedDepartment.value =
                                        null;
                                    timetableCtrl.selectedSemester.value = null;
                                    timetableCtrl.selectedShift.value = null;
                                    Get.back();
                                  },
                                  text: 'Reset',
                                  color: AppColors.white,
                                  borderRadius: 10.r,
                                  height: 56.h,
                                  textColor: AppColors.primary,
                                  borderColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  onPressed: () {
                                    timetableCtrl.update();
                                    Get.back();
                                  },
                                  text: 'Apply Filter',
                                  color: AppColors.primary,
                                  borderRadius: 10.r,
                                  height: 56,
                                  textColor: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

}
