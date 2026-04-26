import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  var currentIndex = 0.obs;
  
  // Role management
  var userRole = ''.obs;
  var isLoadingRole = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserRole();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  // Fetch role from Firestore
  Future<void> fetchUserRole() async {
    try {
      isLoadingRole.value = true;
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          // Store the role, default to 'Student' if missing
          userRole.value = doc['role'] ?? 'Student'; 
        }
      }
    } catch (e) {
      print("Error fetching role: $e");
      userRole.value = 'Student'; // Safe fallback
    } finally {
      isLoadingRole.value = false;
    }
  }
}