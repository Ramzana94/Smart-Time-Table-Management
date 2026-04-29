import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/user_session_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin Dashboard';
      case 'teacher':
        return 'Teacher Dashboard';
      case 'student':
      default:
        return 'Student Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSessionController = Get.find<UserSessionController>();

    return Obx(() {
      final profile = userSessionController.currentUser.value;
      final name = profile?.name.trim().isNotEmpty == true
          ? profile!.name.trim()
          : 'User';
      final role = profile?.role.trim().isNotEmpty == true
          ? profile!.role.trim()
          : 'Student';
      final firstLetter = name[0].toUpperCase();

      return Container(
        width: double.infinity,
        height: 100.h,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.white,
              child: CustomText(
                text: firstLetter,
                fontSize: AppSizes.s20,
                fontWeight: AppWeights.bold,
                color: AppColors.primary,
              ),
            ),
            18.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Welcome $name',
                  fontSize: AppSizes.s18,
                  fontWeight: AppWeights.bold,
                  color: AppColors.white,
                ),
                8.verticalSpace,
                CustomText(
                  text: _getRoleText(role),
                  color: AppColors.white,
                  fontSize: AppSizes.s14,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}