import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_fonts.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_images.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';
import 'package:smart_timetable_managment/core/utils/app_validations.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_dropdown.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';
import 'package:get/get.dart';

class MyRegistrationScreen extends StatelessWidget {
  MyRegistrationScreen({super.key});
  // final ValueNotifier<String?> selectedRole = ValueNotifier(null);
   final AuthController authController = Get.find();
  final signUpFormKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: signUpFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    AppStrings.register,
                    style: TextStyle(fontSize: AppSizes.s24, fontWeight: FontWeight.w600),
                  ),
                  10.verticalSpace,
                  Text(
                    AppStrings.registerSubTitle,
                    style: TextStyle(fontSize: AppSizes.s14, fontWeight: FontWeight.w400),
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.fullName,
                    validator: AppValidators.validateName,

                    controller: authController.signupNameController,
                    obscureText: false,
                    prefixIcon: Icon(AppIcons.profile), borderRadius: BorderRadius.circular(10),
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.email,
                    controller: authController.signupEmailController,
                    obscureText: false,
                    prefixIcon: Icon(AppIcons.email),
                   validator: AppValidators.validateEmail, borderRadius: BorderRadius.circular(10), 
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.password,
                    controller: authController.signupPasswordController,
                    obscureText: true,
                    prefixIcon: Icon(AppIcons.key),
                    isVisible: authController.isPasswordVisible,
                    onToggle: authController.togglePasswordVisibility,
                    validator: AppValidators.validatePassword, borderRadius: BorderRadius.circular(10),
                  ),
                  10.verticalSpace,
                  CustomTextFormField(
                    hintText: AppStrings.confirmPassword,
                    controller: authController.signupConfirmPasswordController,
                    obscureText: true,
                    prefixIcon: Icon(AppIcons.key),
                    isVisible: authController.isPasswordVisible,
                    onToggle: authController.toggleConfirmPasswordVisibility,
                    validator: AppValidators.validatePassword, borderRadius: BorderRadius.circular(10),),

                  16.verticalSpace,
                CustomDropdown(
                    items: authController.roles,
                    itemLabel: (role) => role,
                    // valueListenable: selectedRole,
                      valueListenable: authController.roleNotifier,
                    onChanged: (value) {
                      // selectedRole.value = value;
                          authController.updateSelectedRole(value);
                    },
                    hintText: AppStrings.selectRole,
                  ),
                  16.verticalSpace,
                  Obx(
                    () => CustomButton(
                      borderRadius: AppSizes.r10,
                      height: 57.h,
                      minWidth: 1.sw,
                      text: AppStrings.registerButton,
                      isLoading: authController.isSignupLoading.value,
                      color: AppColors.primary,
                      onPressed: (){
                        authController.signUp();
                      },
                      textColor: AppColors.white,
                     
                    ),
                  ),
                  16.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: AppColors.grey),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          AppStrings.orCotinueWith,
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: AppSizes.s13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Divider(thickness: 1, color: AppColors.grey),
                      ),
                    ],
                  ),
                  16.verticalSpace,
                 Obx(()=>
                  CustomButton(
                    height: 57,
                    borderRadius: AppSizes.r10,
                    isLoading: authController.isGoogleLoading.value,
                    text: AppStrings.google,
                    textColor: AppColors.black,
                    color: AppColors.white,
                   loaderColor: AppColors.primary,
                    imagePath: AppImages.googleImage,
                    minWidth: 1.sw,
                    
                    onPressed: () {
                      authController.continueWithGoogle();
                    },
                  ),),
                  16.verticalSpace,
                  Center(
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(RoutesName.loginScreen);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: AppStrings.haveAccount,
                          style: TextStyle(fontSize: AppSizes.s14, color: AppColors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: AppStrings.login,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: AppSizes.s14,
                                fontWeight: FontWeight.w600,
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
