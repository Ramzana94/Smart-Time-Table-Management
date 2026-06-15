import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_fonts.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/utils/app_validations.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';


class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final AuthController authController = Get.find();
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(AppIcons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: forgotPasswordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(text: AppStrings.appSubtitle,
              fontSize: AppSizes.s24,
              fontWeight: AppWeights.w600,
              fontFamily: AppFonts.poppins,
              color: AppColors.primary,
              ),
              20.verticalSpace,
              CustomText(text: AppStrings.forgotPasswordTitle,
              fontSize: AppSizes.s24,
              fontWeight: AppWeights.w600,
              ),
              10.verticalSpace,
              Container(
                height: 44.h,
                width: 311.w,
                decoration: BoxDecoration(),
                child: Opacity(
                  opacity: 0.4,
                  child: CustomText(text: AppStrings.verficationMethod,
                  fontSize: AppSizes.s14,
                  fontWeight: AppWeights.w400,
                  textAlign: TextAlign.center,
                  )
                ),
              ),
              50.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.email,
                controller: authController.forgotEmailController,
                validator: AppValidators.validateEmail,
                borderRadius: BorderRadius.circular(20),
                prefixIcon: Icon(AppIcons.email),
              ),
              30.verticalSpace,
              Obx(
                () => CustomButton(
                  isLoading: authController.isForgotLoading.value,
                  onPressed: () {
                    authController.forgotPassword();
                  },
                  text: AppStrings.sendLink,
                  color: AppColors.primary,
                  borderRadius: 10.r,
                  minWidth: 327.w,
                  height: 56.h,
                  textColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}