import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_images.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/utils/app_dialogbox.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                maxRadius: 60,
                minRadius: 60,
                backgroundImage: AssetImage(AppImages.splashLogo),
              ),
              Text('Ramzana Talib'),
              10.verticalSpace,
              CustomMaterialButton(
                borderRadius: AppSizes.r10,
                height: 57,
                color: AppColors.primary,
                text: 'Change Password',
                onPressed: () {
                  authController.showChangePasswordBottomSheet();
                },
                textColor: AppColors.white,
              ),
              10.verticalSpace,
              CustomMaterialButton(
                borderRadius: AppSizes.r10,
                height: 57,
                text: 'Logout',
                onPressed: () {
                  AppDialogs.showLogoutDialog((){
                       authController.logout();
                  }
                    
                  );
                },
                textColor: AppColors.white,
                color: AppColors.red,
                icon: Icon(AppIcons.logout, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
