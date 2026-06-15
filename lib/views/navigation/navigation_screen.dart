import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/home_dashboard_controller.dart';
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
import 'package:smart_timetable_managment/views/profile_screen.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_dropdown.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';


class NavigationScreen extends StatelessWidget {
  NavigationScreen({super.key});

  final NavigationController navigationController =
      Get.find<NavigationController>();
  final HomeDashboardController homeCtrl = Get.find<HomeDashboardController>();
  final TimetableController timetableCtrl = Get.find<TimetableController>();

  //  AppBar title
  String _getAppBarTitle(String role, int index) {
    switch (index) {
      case 0:
        return role == 'Admin' ? AppStrings.dashboard : AppStrings.home;

      case 1:
        return AppStrings.timetable;

      case 2:
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
      ProfileScreen(),
    ];
    return Obx(() {
      final isLoadingRole = navigationController.isLoadingRole.value;
      final role = navigationController.userRole.value.trim();
      final effectiveRole = role.isEmpty ? 'Student' : role;
      final isAdmin = effectiveRole == 'Admin';

      return Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(
              effectiveRole,
              navigationController.currentIndex.value,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          actions: [
            if (!isLoadingRole && navigationController.currentIndex.value == 1)
              IconButton(
                icon: const Icon(AppIcons.tune_outlined),
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

          onTap: isLoadingRole
              ? null
              : (index) {
                  navigationController.changeIndex(index);
                },

          items: [
            BottomNavigationBarItem(
              icon: Icon(
                isAdmin
                    ? AppIcons
                          .dashboard // Admin icon
                    : AppIcons.home, // Teacher/Student icon
              ),
              label: isAdmin ? AppStrings.dashboard : AppStrings.home,
            ),

            BottomNavigationBarItem(
              icon: Icon(AppIcons.timetable),
              label: AppStrings.timetable,
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
            final role = navigationController.userRole.value.trim();
            final isAdmin = role == 'Admin';
            final baseEntries = isAdmin
                ? allEntries
                : homeCtrl.visibleTimetableEntries(allEntries);

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 52.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomText(
                      text: AppStrings.filterTimeTable,
                      fontSize: AppSizes.s20,
                      fontWeight: AppWeights.w700,
                    ),
                    20.verticalSpace,
                    Obx(() {
                      final departmentOptions = timetableCtrl.departmentOptions(
                        baseEntries,
                      );
                      final activeDepartment = timetableCtrl
                          .validSelectionOrNull(
                            timetableCtrl.selectedDepartment.value,
                            departmentOptions,
                          );
                      if (deptNotifier.value != activeDepartment) {
                        deptNotifier.value = activeDepartment;
                      }

                      final semesterOptions = timetableCtrl.semesterOptions(
                        baseEntries,
                        department: activeDepartment,
                      );
                      final activeSemester = timetableCtrl.validSelectionOrNull(
                        timetableCtrl.selectedSemester.value,
                        semesterOptions,
                      );
                      if (semesterNotifier.value != activeSemester) {
                        semesterNotifier.value = activeSemester;
                      }

                      final shiftOptions = timetableCtrl.shiftOptions(
                        baseEntries,
                        department: activeDepartment,
                        semester: activeSemester,
                      );
                      final activeShift = timetableCtrl.validSelectionOrNull(
                        timetableCtrl.selectedShift.value,
                        shiftOptions,
                      );
                      if (shiftNotifier.value != activeShift) {
                        shiftNotifier.value = activeShift;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: AppStrings.departments,
                            fontSize: AppSizes.s14,
                            fontWeight: AppWeights.bold,
                          ),
                          5.verticalSpace,
                          CustomDropdown<String>(
                            items: departmentOptions,
                            itemLabel: (e) => e,
                            hintText: AppStrings.departments,
                            valueListenable: deptNotifier,
                            onChanged: (value) {
                              timetableCtrl.updateDepartment(value);
                            },
                          ),
                          16.verticalSpace,
                          CustomText(
                            text: AppStrings.semester,
                            fontSize: AppSizes.s14,
                            fontWeight: AppWeights.bold,
                          ),
                          5.verticalSpace,
                          CustomDropdown<String>(
                            items: semesterOptions,
                            itemLabel: (e) => e,
                            hintText: AppStrings.semester,
                            valueListenable: semesterNotifier,
                            onChanged: (value) {
                              timetableCtrl.updateSemester(value);
                            },
                          ),
                          16.verticalSpace,
                          CustomText(
                            text: AppStrings.shift,
                            fontSize: AppSizes.s14,
                            fontWeight: AppWeights.bold,
                          ),
                          5.verticalSpace,
                          CustomDropdown<String>(
                            items: shiftOptions,
                            itemLabel: (e) => e,
                            hintText: AppStrings.shift,
                            valueListenable: shiftNotifier,
                            onChanged: (value) {
                              timetableCtrl.updateShift(value);
                            },
                          ),
                          24.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  borderColor: AppColors.primary,
                                  onPressed: () {
                                    timetableCtrl.selectedDepartment.value =
                                        null;
                                    timetableCtrl.selectedSemester.value = null;
                                    timetableCtrl.selectedShift.value = null;
                                    Get.back();
                                  },
                                  text: AppStrings.reset,
                                  color: AppColors.white,
                                  borderRadius: 10.r,
                                  height: 57.h,
                                  textColor: AppColors.primary,
                                ),
                              ),
                              12.horizontalSpace,
                              Expanded(
                                child: CustomButton(
                                  onPressed: () {
                                    timetableCtrl.update();
                                    Get.back();
                                  },
                                  text: AppStrings.applyFilter,
                                  color: AppColors.primary,
                                  borderRadius: 10.r,
                                  height: 57.h,
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