import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/views/dashboard/department/department_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/department/teacher_screen.dart';
import 'package:smart_timetable_managment/widgets/app_cards.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

class AdminDasboard extends StatelessWidget {
 AdminDasboard({super.key});
final adminCtrl = Get.find<AdminDashboardController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
          
                  gradient: const LinearGradient(
                    colors: [Color(0xFF356899), Color(0xFF5A8FBE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        AppIcons.person,
                        color: AppColors.white,
                        size: AppSizes.s30,
                      ),
                    ),
                    10.horizontalSpace,
                    Column(
                      children: [
                        CustomText(
                          text: AppStrings.adminDashboard,
                          color: AppColors.white,
                          fontSize: AppSizes.s20,
                          fontWeight: AppWeights.bold,
                        ),
          
                        CustomText(
                          text: AppStrings.adminAccessControl,
                          color: AppColors.white,
                          fontSize: AppSizes.s14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              20.verticalSpace,
          
              Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      title: AppStrings.totalClasses,
                      icon: AppIcons.room,
                    ),
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: CustomCard(
                      title: AppStrings.teachers,
                      icon: AppIcons.school,
                    ),
                  ),
                ],
              ),
              16.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      title: AppStrings.departments,
                      icon: AppIcons.apartment,
                    ),
                  ),
                  8.horizontalSpace,
                  Expanded(
                    child: CustomCard(
                      title: AppStrings.rooms,
                      icon: AppIcons.home,
                    ),
                  ),
                ],
              ),
          
              30.verticalSpace,
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                          
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        onTap: (index){
                          adminCtrl.currentTabIndex.value=index;
                        },
                        dividerColor: AppColors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: AppColors.white,
                        unselectedLabelColor: AppColors.primary,
                        tabs: const [
                          Tab(text: "Department"),
                          Tab(text: "Teachers"),
                          Tab(text: "Analytics"),
                        ],
                      ),
                    ),
                          
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 400.h,
                      child: TabBarView(
                        children: [
                          // 🏫 Department
                          // Center(child: CustomText(text: "Department Screen")),
                      DepartmentScreen(),
                          // 🧑‍🏫 Teachers
                          // Center(child: CustomText(text: "Teachers Screen")),
                      TeacherScreen(),
                          // 📊 Analytics
                          Center(child: CustomText(text: "Analytics Screen")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}









//                   // ➕ button
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       // your action
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: const Color(0xFF5B5FFF),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     icon: const Icon(Icons.add),
//                     label: const Text("Add Entry"),
//                   ),
//                 ],
//               ),
//             ),