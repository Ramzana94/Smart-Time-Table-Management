// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:smart_timetable_managment/models/teacher_model.dart';

// class TeacherService {
//  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Future<void> addTeacher(TeacherModel model) async {
//   //   await _firestore.collection('teachers').add(model.toJson());
//   // }
//   Future<void> addTeacher(TeacherModel model) async {
//   final docRef = _firestore.collection('teachers').doc(); // unique ID generate

//   final teacherWithId = model.copyWith(id: docRef.id); // ID model mein daali

//   await docRef.set(teacherWithId.toJson()); // save with ID
// }

//   Future<void> updateTeacher(String id, TeacherModel model) async {
//     await _firestore.collection('teachers').doc(id).update(model.toJson());
//   }

//   Stream<List<TeacherModel>> getTeachers() {
//     return _firestore
//         .collection('teachers')
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map((doc) => TeacherModel.fromJson(doc.data(), id: doc.id))
//               .toList(),
//         );
//   }

//   Future<void> deleteTeacher(String id) async {
//     await _firestore.collection('teachers').doc(id).delete();
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ADD TEACHER (admin-specific)
  Future<void> addTeacher(TeacherModel model) async {
    final user = FirebaseAuth.instance.currentUser;

    final docRef = _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('teachers')
        .doc();

    final teacherWithId = model.copyWith(id: docRef.id);

    await docRef.set(teacherWithId.toJson());
  }

  // UPDATE TEACHER
  Future<void> updateTeacher(String id, TeacherModel model) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('teachers')
        .doc(id)
        .update(model.toJson());
  }

  // GET TEACHERS (admin-wise)
  Stream<List<TeacherModel>> getTeachers() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('teachers')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  TeacherModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // DELETE TEACHER
  Future<void> deleteTeacher(String id) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('teachers')
        .doc(id)
        .delete();
  }
}