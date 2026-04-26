import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_timetable_managment/models/department_model.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDepartment(DepartmentModel model) async {
    await _firestore.collection('departments').add(model.toJson());
  }

  Stream<List<DepartmentModel>> getDepartments() {
    return _firestore.collection('departments').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => DepartmentModel.fromJson(doc.data()))
          .toList(),
    );
  }

  Future<void> deleteDepartment(String id) async {
    await _firestore.collection('departments').doc(id).delete();
  }
}