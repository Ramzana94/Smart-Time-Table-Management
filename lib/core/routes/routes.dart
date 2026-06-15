import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';
import 'package:smart_timetable_managment/views/auth/forgot_password.dart';
import 'package:smart_timetable_managment/views/auth/login_screen.dart';
import 'package:smart_timetable_managment/views/auth/register_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/dashboard_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/timetable/timetable_screen.dart';
import 'package:smart_timetable_managment/views/navigation/navigation_screen.dart';
import 'package:smart_timetable_managment/views/onboarding/onboarding_one.dart';
import 'package:smart_timetable_managment/views/profile_screen.dart';
import 'package:smart_timetable_managment/views/splash/splashscreen.dart';


class AppRoutes {
  static List<GetPage<dynamic>> appRoutes() => [
    GetPage(
      name: RoutesName.splashScreen,
      page: () => SplashScreen(),
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.rightToLeftWithFade,
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: RoutesName.onBoardingScreen,
      page: () => OnbroadingScreen(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: RoutesName.registerScreen,
      page: () => RegisterScreen(),
      transitionDuration: Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade,
      curve: Curves.easeInOut,
    ),
    GetPage(
      name: RoutesName.loginScreen,
      page: () => LoginScreen(),
      transition: Transition.noTransition,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 250),
    ),
    GetPage(
      name: RoutesName.forgotPassword,
      page: () => ForgotPassword(),
      transition: Transition.leftToRightWithFade,
      curve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 250),
    ),
    GetPage(
      name: RoutesName.navigationScreen,
      page: () => NavigationScreen(),
      curve: Curves.easeInOut,
    ),
    GetPage(name: RoutesName.dashboardScreen, page: () => DashboardScreen()),
    GetPage(name: RoutesName.timeTableScreen, page: () => TimeTableScreen()),
    
    GetPage(name: RoutesName.profileScreen, page: () => ProfileScreen()),
  ];
}