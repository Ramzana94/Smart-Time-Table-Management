// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:smart_timetable_managment/models/timetable_model.dart';

// class TimetableService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> addTimetable(TimetableModel model) async {
//     await _firestore.collection('timetable').add({
//       ...model.toJson(),
//       'createdAt': FieldValue.serverTimestamp(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> updateTimetable(String id, TimetableModel model) async {
//     await _firestore.collection('timetable').doc(id).update({
//       ...model.toJson(),
//       'updatedAt': FieldValue.serverTimestamp(),
//     });
//   }

//   Stream<List<TimetableModel>> getTimetable() {
//     return _firestore
//         .collection('timetable')
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.docs
//               .map((doc) => TimetableModel.fromJson(doc.data(), id: doc.id))
//               .toList(),
//         );
//   }

//   Future<void> deleteTimetable(String id) async {
//     await _firestore.collection('timetable').doc(id).delete();
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ADD TIMETABLE
  Future<void> addTimetable(TimetableModel model) async {
    final user = FirebaseAuth.instance.currentUser;

    final docRef = _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('timetable')
        .doc();

    final timetableWithId = model.copyWith(id: docRef.id);

    await docRef.set({
      ...timetableWithId.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE TIMETABLE
  Future<void> updateTimetable(String id, TimetableModel model) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('timetable')
        .doc(id)
        .update({
      ...model.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // GET TIMETABLE (admin-wise)
  Stream<List<TimetableModel>> getTimetable() {
    final user = FirebaseAuth.instance.currentUser;

    return _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('timetable')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  TimetableModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // DELETE TIMETABLE
  Future<void> deleteTimetable(String id) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection('admins_data')
        .doc(user!.uid)
        .collection('timetable')
        .doc(id)
        .delete();
  }
}