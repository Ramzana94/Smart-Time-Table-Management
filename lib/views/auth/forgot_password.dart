import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_fonts.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/utils/app_validations.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';

class MyForgotPasswordScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final forgotPasswordFormKey = GlobalKey<FormState>();

  MyForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.s20),
        child: Form(
          key: forgotPasswordFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: AppSizes.s22,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: AppColors.primary,
                  ),
                ),
                10.verticalSpace,
                Text(
                  AppStrings.forgotPasswordTitle,
                  style: TextStyle(
                    fontSize: AppSizes.s24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                10.verticalSpace,
                Container(
                  height: 44.h,
                  width: 311,
                  decoration: BoxDecoration(),
                  child: Opacity(
                    opacity: 0.4,
                    child: Text(
                      textAlign: TextAlign.center,
                      AppStrings.forgotPasswordTitle,
                    ),
                  ),
                ),
                10.verticalSpace,
                CustomTextFormField(
                  hintText: AppStrings.email,
                  controller: authController.forgotEmailController,
                  obscureText: false,
                  prefixIcon: Icon(AppIcons.key),
                  validator: AppValidators.validateEmail, borderRadius: BorderRadius.circular(10),
                ),
                50.verticalSpace,
                CustomMaterialButton(
                  borderRadius: AppSizes.r10,
                  height: 57,
                  color: AppColors.primary,

                  text: AppStrings.sendLink,
                  onPressed: () {
                    Get.back();
                    if (forgotPasswordFormKey.currentState
                            ?.validate() ??
                        false) {
                      authController.forgotPassword();
                    }
                  },
                  textColor: AppColors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
