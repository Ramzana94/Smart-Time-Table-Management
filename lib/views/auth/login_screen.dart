import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_fonts.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_images.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';
import 'package:smart_timetable_managment/core/utils/app_validations.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authController = Get.put(AuthController());
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: SingleChildScrollView(
            child: Form(
              key:loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: AppStrings.appSubtitle,
                  fontSize: AppSizes.s24,
                  fontWeight: AppWeights.w600,
                  fontFamily: AppFonts.poppins,
                  color: AppColors.primary,
                  ),
                  10.verticalSpace,
                  CustomText(text: AppStrings.welcomeBack,
                  fontSize: AppSizes.s24,
                  fontWeight: AppWeights.w600,
                  ),
                  10.verticalSpace,
                  CustomText(text: AppStrings.loginSubtitle),
                  30.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.email,
                    controller: authController.loginEmailController,
                    validator: AppValidators.validateEmail,
                    borderRadius: BorderRadius.circular(10),
                    prefixIcon: Icon(AppIcons.email),
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.password,
                    controller: authController.loginPasswordController,
                    validator: AppValidators.validatePassword,
                    borderRadius: BorderRadius.circular(10),
                    obscureText: true,
                    prefixIcon: Icon(AppIcons.key),
                    isVisible: authController.isPasswordVisible,
                    onToggle: authController.togglePasswordVisibility,
                  ),
                  10.verticalSpace,
                  InkWell(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CustomText(text: AppStrings.forgotPassword,
                      fontSize: AppSizes.s15,
                      fontWeight: AppWeights.w400,
                      color: AppColors.primary,
                      )
                    ),
                    onTap: () {
                      Get.toNamed(RoutesName.forgotPasswordScreen);
                    },
                  ),
        
                  30.verticalSpace,
                  Obx(()=>CustomButton(
                    isLoading: authController.isLoginLoading.value,
                    onPressed: () {
                      authController.login();
                    },
                    text: AppStrings.loginButton,
                    color: AppColors.primary,
                    borderRadius: 10.r,
                    minWidth: 327.w,
                    height: 56.h,
                    textColor: AppColors.white,
                  ),),
                  20.verticalSpace,
        
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.grey,
                          thickness: 1,
                          indent: 10,
                          endIndent: 10,
                        ),
                      ),
                      CustomText(text: AppStrings.orCotinueWith),
                      Expanded(
                        child: Divider(
                          color: AppColors.grey,
                          thickness: 1,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),
                  20.verticalSpace,
                  Obx(()=>CustomButton(
                    isLoading: authController.isGoogleLoading.value,
                    loaderColor: AppColors.primary,
                    onPressed: () {
                      authController.continueWithGoogle();
                    },
                    text: AppStrings.google,
                    color: AppColors.white,
                    borderRadius: 10.r,
                    height: 56.h,
                    minWidth: 1.sw,
                    textColor: AppColors.primary,
                    imagePath: AppImages.googleImage,
                    borderColor: AppColors.grey,
                  ),),
                  20.verticalSpace,
                  Center(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(RoutesName.registrationScreen);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: AppStrings.havenotAccount,
                          style: TextStyle(
                            fontWeight: AppWeights.w400,
                            fontSize: AppSizes.s14,
                            color: AppColors.grey,
                          ),
                          children: [
                            TextSpan(
                              text: AppStrings.registerButton,
                              style: TextStyle(
                                fontSize: AppSizes.s14,
                                fontWeight: AppWeights.w400,
                                color: AppColors.primary,
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