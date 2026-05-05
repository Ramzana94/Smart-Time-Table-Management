import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentDashboardController extends GetxController {
  static const int featureCount = 3;

  final PageController featurePageController = PageController();
  final currentFeatureIndex = 0.obs;

  Timer? _featureTimer;

  @override
  void onInit() {
    super.onInit();
    _startFeatureAutoSlide();
  }

  void updateFeatureIndex(int index) {
    currentFeatureIndex.value = index;
  }

  void _startFeatureAutoSlide() {
    _featureTimer?.cancel();
    _featureTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final nextIndex = (currentFeatureIndex.value + 1) % featureCount;
      currentFeatureIndex.value = nextIndex;

      if (!featurePageController.hasClients) {
        return;
      }

      featurePageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void onClose() {
    _featureTimer?.cancel();
    featurePageController.dispose();
    super.onClose();
  }
}
