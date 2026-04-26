import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_timetable_managment/controllers/onboarding_controoler.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller=OnboardingController.instance;
    bool dark=Theme.of(context).brightness==Brightness.light;
    return Positioned(
      right: 100,
      bottom: 130,
      child: SmoothPageIndicator(
        effect: ExpandingDotsEffect(
          activeDotColor: dark?AppColors.primary:AppColors.light,
          dotHeight: 5.h
        ),
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
         count: 3));
  }
}