// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:smart_timetable_managment/models/department_model.dart';

// class DepartmentService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> addDepartment(DepartmentModel model) async {
//     await _firestore.collection('departments').add(model.toJson());
//   }

//   Future<void> updateDepartment(String id, DepartmentModel model) async {
//     await _firestore.collection('departments').doc(id).update(model.toJson());
//   }

//   Stream<List<DepartmentModel>> getDepartments() {
//     return _firestore
//         .collection('departments')
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map((doc) => DepartmentModel.fromJson(doc.data(), id: doc.id))
//               .toList(),
//         );
//   }

//   Future<void> deleteDepartment(String id) async {
//     await _firestore.collection('departments').doc(id).delete();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_timetable_managment/models/department_model.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<void> addDepartment(DepartmentModel model) async {
  //   await _firestore.collection('departments').add(model.toJson());
  // }
Future<void> addDepartment(DepartmentModel model) async {
  final user = FirebaseAuth.instance.currentUser;

  final docRef = _firestore
      .collection('admins_data')
      .doc(user!.uid)
      .collection('departments')
      .doc();

  final deptWithId = model.copyWith(id: docRef.id);

  await docRef.set(deptWithId.toJson());
}
  // Future<void> updateDepartment(String id, DepartmentModel model) async {
  //   await _firestore.collection('departments').doc(id).update(model.toJson());
  // }
  Future<void> updateDepartment(String id, DepartmentModel model) async {
  final user = FirebaseAuth.instance.currentUser;

  await _firestore
      .collection('admins_data')
      .doc(user!.uid)
      .collection('departments')
      .doc(id)
      .update(model.toJson());
}

  // Stream<List<DepartmentModel>> getDepartments() {
  //   return _firestore
  //       .collection('departments')
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => DepartmentModel.fromJson(doc.data(), id: doc.id))
  //             .toList(),
  //       );
  // }
  Stream<List<DepartmentModel>> getDepartments() {
  final user = FirebaseAuth.instance.currentUser;

  return _firestore
      .collection('admins_data')
      .doc(user!.uid)
      .collection('departments')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => DepartmentModel.fromJson(doc.data(), id: doc.id))
            .toList(),
      );
}

  // Future<void> deleteDepartment(String id) async {
  //   await _firestore.collection('departments').doc(id).delete();
  // }
  Future<void> deleteDepartment(String id) async {
  final user = FirebaseAuth.instance.currentUser;

  await _firestore
      .collection('admins_data')
      .doc(user!.uid)
      .collection('departments')
      .doc(id)
      .delete();
}
}