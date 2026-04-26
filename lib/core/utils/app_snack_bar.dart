import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';


class AppSnackbar {
  AppSnackbar._();

  //  Success Snackbar
  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.green,
      colorText: AppColors.white,
      // snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  //  Error Snackbar
  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.red,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  //  Warning Snackbar
  static void warning(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  // ℹ️ Info Snackbar
  static void info(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }
}