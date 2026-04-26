import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';

class SplashController extends GetxController {
  
  @override
  void onInit() {
    super.onInit();
    checkUser();
  }

  void checkUser() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    // 🔴 USER NOT LOGGED IN
    if (user == null) {
      Get.offAllNamed(RoutesName.onboardingScreen);
      return;
    }

    // 🟢 USER LOGGED IN → Verify they still have a valid Firestore profile
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // If the account was deleted from the database but the auth token is still active, sign them out.
    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(RoutesName.onboardingScreen);
      return;
    }

    // ✅ USER VALIDATED → GO TO DASHBOARD
    Get.offAllNamed(RoutesName.navigationScreen);
  }
}