import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

class AppDialogs {
  static void showLogoutDialog(VoidCallback onConfirm) {
    Get.defaultDialog(
      title: "",
      content: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: .1),
            child: Icon(
              // Icons.warning,
              AppIcons.question_mark,
              color: AppColors.primary,
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          Text(
           AppStrings.areYouSure,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            AppStrings.confirmLogout,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ❌ NO button
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.back();
                },
                child: CustomText(text: AppStrings.no),
              ),

              // YES button
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  onConfirm();
                  Get.back();
                },
                child: CustomText(text: AppStrings.yes,color: AppColors.white,),
               
              ),
            ],
          ),
        ],
      ),
    );
  }
}