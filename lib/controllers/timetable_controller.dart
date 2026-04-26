import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TimetableController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //  READ TIMETABLE
  Stream<QuerySnapshot> getTimetable() {
    return _firestore
        .collection("timetable")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // DELETE TIMETABLE (with error handling)
  Future<void> deleteTimetable(String id) async {
    try {
      await _firestore.collection("timetable").doc(id).delete();

      Get.snackbar(
        "Deleted",
        "Timetable deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete timetable",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  //  OPTIONAL (future use: create method here too)
  Future<void> addTimetable(Map<String, dynamic> data) async {
    try {
      await _firestore.collection("timetable").add(data);
    } catch (e) {
      Get.snackbar("Error", "Failed to add timetable");
    }
    
  }
}