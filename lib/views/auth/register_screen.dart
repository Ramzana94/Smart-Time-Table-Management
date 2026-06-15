import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_fonts.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_images.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/utils/app_validations.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_dropdown.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final ValueNotifier<String?> selectedRole = ValueNotifier(null);
  final AuthController authController = Get.find();
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Form(
              key: signUpFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: AppStrings.appSubtitle,
                    fontSize: AppSizes.s24,
                    fontWeight: AppWeights.w600,
                    color: AppColors.primary,
                    fontFamily: AppFonts.poppins,
                  ),
                  CustomText(
                    text: AppStrings.register,
                    fontSize: AppSizes.s24,
                    fontWeight: AppWeights.w600,
                    color: AppColors.black,
                  ),

                  10.verticalSpace,
                  CustomText(
                    text: AppStrings.registerSubTitle,
                    fontSize: AppSizes.s14,
                    fontWeight: AppWeights.w400,
                    color: AppColors.black,
                  ),

                  20.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.fullName,
                    validator: AppValidators.validateName,
                    controller: authController.signupNameController,
                    borderRadius: BorderRadius.circular(10),
                    prefixIcon: Icon(AppIcons.person),
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.email,
                    validator: AppValidators.validateEmail,
                    controller: authController.signupEmailController,
                    borderRadius: BorderRadius.circular(10),
                    prefixIcon: Icon(AppIcons.email),
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.password,
                    validator: AppValidators.validatePassword,
                    controller: authController.signupPasswordController,
                    borderRadius: BorderRadius.circular(10),
                    obsecureText: true,
                    prefixIcon: Icon(AppIcons.key),
                    isVisible: authController.isPasswordVisible,
                    onToggle: authController.togglePasswordVisibility,
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.confirmPassword,
                    validator: (value) {
                      return AppValidators.validateConfirmPassword(
                        value,
                        authController.signupPasswordController.text,
                      );
                    },
                    controller: authController.signupConfirmPasswordController,
                    borderRadius: BorderRadius.circular(10),
                    obsecureText: true,
                    prefixIcon: Icon(Icons.key),
                    isVisible: authController.isConfirmPasswordVisible,
                    onToggle: authController.toggleConfirmPasswordVisibility,
                  ),
                  10.verticalSpace,
                  CustomDropdown(
                    items: authController.googleRoles,
                    itemLabel: (role) => role,
                    valueListenable: authController.roleNotifier,
                    onChanged: (value) {
                      authController.updateSelectedRole(value);
                    },
                    hintText: AppStrings.selectRole,
                  ),
                  30.verticalSpace,
                  Obx(
                    () => CustomButton(
                      isLoading: authController.isSignupLoading.value,
                      onPressed: () {
                        authController.signUp();
                      },
                      text: AppStrings.registerButton,
                      color: AppColors.primary,
                      borderRadius: 10.r,
                      minWidth: 327.w,
                      height: 56.h,
                      textColor: AppColors.white,
                    ),
                  ),
                  20.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.grey,
                          thickness: 1,
                          endIndent: 10,
                          indent: 10,
                        ),
                      ),
                      CustomText(text: AppStrings.orCotinueWith),
                      Expanded(
                        child: Divider(
                          color: AppColors.grey,
                          thickness: 1,
                          indent: 10,
                          endIndent: 10,
                        ),
                      ),
                    ],
                  ),
                  20.verticalSpace,
                  Obx(
                    () => CustomButton(
                      isLoading: authController.isGoogleLoading.value,
                      loaderColor: AppColors.primary,
                      onPressed: () {
                        authController.continueWithGoogle();
                      },
                      text: AppStrings.google,
                      color: AppColors.white,
                      borderRadius: 10.r,
                      minWidth: 400.w,
                      height: 56.h,
                      textColor: AppColors.primary,
                      borderColor: AppColors.grey,
                      imagePath: AppImages.googleImage,
                    ),
                  ),
                  20.verticalSpace,
                  Center(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: AppStrings.haveAccount,
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: AppSizes.s14,
                            fontWeight: AppWeights.w400,
                          ),
                          children: [
                            TextSpan(
                              text: AppStrings.login,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: AppWeights.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}