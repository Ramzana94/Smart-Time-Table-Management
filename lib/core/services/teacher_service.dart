import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTeacher(TeacherModel model) async {
    await _firestore.collection('teachers').add(model.toJson());
  }

  Future<void> updateTeacher(String id, TeacherModel model) async {
    await _firestore.collection('teachers').doc(id).update(model.toJson());
  }

  Stream<List<TeacherModel>> getTeachers() {
    return _firestore
        .collection('teachers')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TeacherModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> deleteTeacher(String id) async {
    await _firestore.collection('teachers').doc(id).delete();
  }
}