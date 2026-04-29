import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:smart_timetable_managment/views/auth/register_screen.dart';

class OnboardingController extends GetxController{
  static OnboardingController get instance => Get.find();
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;
  void updatePageIndicator(int index) => currentPageIndex.value = index;
  void dotNavigationClick(int index){
    currentPageIndex.value = index; 
    pageController.jumpToPage(index);
  }
void nextPage(int index){
  if(currentPageIndex.value == 2){
    Get.to(MyRegistrationScreen());
  }else{
    int page = currentPageIndex.value  +1;
    pageController.jumpToPage(page);
  }
}
void skipPage(){
   currentPageIndex.value = 2; 
    pageController.jumpToPage(2);
}

}