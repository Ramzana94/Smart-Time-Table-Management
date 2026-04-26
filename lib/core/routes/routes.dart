// ignore_for_file: strict_top_level_inference

import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';
import 'package:smart_timetable_managment/views/auth/forgot_password.dart';
import 'package:smart_timetable_managment/views/auth/login_screen.dart';
import 'package:smart_timetable_managment/views/auth/register_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/dashboard_screen.dart';
import 'package:smart_timetable_managment/views/navigation/navigation_screen.dart';
import 'package:smart_timetable_managment/views/onboarding/onboarding_one.dart';
import 'package:smart_timetable_managment/views/splash/splashscreen.dart';


class AppRoutes {
  static appRoutes() => [
    GetPage(
      name: RoutesName.splashScreen,
      page: () => MySplashScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(microseconds: 300)
    ),
     GetPage(
      name: RoutesName.onboardingScreen,
      page: () => OnbroadingScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300)
    ),
     GetPage(
      name: RoutesName.loginScreen,
      page: () => LoginScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(microseconds: 300),
      binding: BindingsBuilder(() {
    Get.lazyPut<AuthController>(() => AuthController());
  }),
    ),
    GetPage(
      name: RoutesName.registrationScreen,
      page: () => MyRegistrationScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(microseconds: 300),
      binding: BindingsBuilder(() {
    Get.lazyPut<AuthController>(() => AuthController());
  }),
    ),
   
    GetPage(
      name: RoutesName.forgotPasswordScreen,
      page: () => MyForgotPasswordScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(microseconds: 300),
      binding: BindingsBuilder(() {
    Get.lazyPut<AuthController>(() => AuthController());
  }),
    ), 
     GetPage(
      name: RoutesName.dashBoardScreen,
      page: () => DashboardScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(microseconds: 300)
    ), 
     GetPage(
      name: RoutesName.navigationScreen,
      page: () => NavigationScreen(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(microseconds: 300)
    ), 
  ];
}
