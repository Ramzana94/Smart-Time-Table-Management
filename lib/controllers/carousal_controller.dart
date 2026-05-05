import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeatureCarouselController extends GetxController {
  final Rx<int> currentIndex = 0.obs;
  final CarouselSliderController carouselController =
      CarouselSliderController();

  final List<Map<String, String>> features = const [
    {
      'title': 'Stay Organized',
      'description':
          'Your timetable is designed to help you plan better and stay on track every day.',
      'icon': 'checklist_rtl',
    },
    {
      'title': 'Never Miss a Class',
      'description':
          'Get timely notifications and reminders for all your scheduled classes and events.',
      'icon': 'notifications_active',
    },
    {
      'title': 'Plan Your Week',
      'description':
          'View your complete weekly schedule and plan your study sessions with confidence.',
      'icon': 'calendar_month',
    },
  ];

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  void goToPage(int index) {
    carouselController.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }
}