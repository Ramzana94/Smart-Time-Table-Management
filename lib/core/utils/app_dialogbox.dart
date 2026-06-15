import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';


class AppDialogs {
  static void showLogoutDialog({
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: "",
      content: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundColor: AppColors.primary.withValues(alpha: .1),
              child: Icon(
                // Icons.warning,
                AppIcons.question_mark,
                color: AppColors.primary,
                size: AppSizes.s40,
              ),
            ),
            20.verticalSpace,
            CustomText(
              text: AppStrings.areYouSure,
              fontWeight: AppWeights.bold,
              fontSize: AppSizes.s18,
            ),
            10.verticalSpace,
            CustomText(text: message, textAlign: TextAlign.center),
            25.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //  NO button
                CustomButton(
                  minWidth: 100,
                  borderColor: AppColors.primary,
                  onPressed: () {
                    Get.back();
                  },
                  text: AppStrings.no,
                  color: AppColors.white,
                  borderRadius: 10,
                  height: 45,
                  textColor: AppColors.primary,
                ),
                // YES button
                CustomButton(
                  minWidth: 100,
                  onPressed: () {
                    onConfirm();
                    Get.back();
                  },
                  text: AppStrings.yes,
                  color: AppColors.primary,
                  borderRadius: 10,
                  height: 45,
                  textColor: AppColors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}