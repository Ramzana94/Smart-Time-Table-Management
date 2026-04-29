import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/onboarding_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_images.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';
import 'package:smart_timetable_managment/views/onboarding/onboarding_dot_navigation.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';

class OnbroadingScreen extends StatelessWidget {
  const OnbroadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: [
              PageView(
                controller: controller.pageController,
                onPageChanged: controller.updatePageIndicator,
                children: [
                  OnBoardingPage(
                    image: AppImages.onboardingOne,
                    title: AppStrings.titleOnboardingOne,
                    description: AppStrings.descriptionOnbaordingOne,
                  ),
                  OnBoardingPage(
                    image: AppImages.onboardingTwo,
                    title: AppStrings.titleOnboardigTwo,
                    description: AppStrings.descriptionOnBoardingTwo,
                  ),
                  OnBoardingPage(
                    image: AppImages.onboardingThree,
                    title: AppStrings.titleOnboardingThree,
                    description: AppStrings.descriptionOnboardingThree,
                  ),
                ],
              ),
              Obx(() {
                if (controller.currentPageIndex.value == 0) {
                  return SizedBox();
                } else {
                  return Positioned(
                    bottom: 50,

                    child: TextButton(
                      onPressed: () => OnboardingController.instance.skipPage(),
                      child: Text(AppStrings.skip),
                    ),
                  );
                }
              }),
              OnBoardingDotNavigation(),

              Obx(() {
                if (controller.currentPageIndex.value == 0) {
                  return SizedBox();
                } else {
                  return Positioned(
                    bottom: 50,
                    right: 0,
                    child: CustomButton(
                      onPressed: () {
                        Get.offAllNamed(RoutesName.loginScreen);
                        OnboardingController.instance.nextPage(
                          controller.currentPageIndex.value,
                        );
                      },
                      text: AppStrings.next,
                      color: AppColors.primary,
                      borderRadius: AppSizes.r10,
                      height: 56.h,
                    //  width: 158.w,.
                    minWidth: 158.w,
                      textColor: AppColors.white,
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });
  final String image, title, description;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(height: 284.h, width: 284.w, image: AssetImage(image)),
        // 5.verticalSpace,
        Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.s28,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        10.verticalSpace,
        Center(
          child: Text(
            description,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: AppSizes.s15),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
