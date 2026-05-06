import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';

class TeacherService {
  TeacherService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'teachers';
  final FirebaseFirestore _firestore;

  Future<void> addTeacher(TeacherModel model) async {
    final docRef = _firestore.collection(_collectionName).doc();
    final teacherWithId = model.copyWith(id: docRef.id);
    await docRef.set(teacherWithId.toJson());
  }

  Future<void> updateTeacher(String id, TeacherModel model) async {
    await _firestore.collection(_collectionName).doc(id).update(model.toJson());
  }

  Stream<List<TeacherModel>> getTeachers() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (document) =>
                TeacherModel.fromJson(document.data(), id: document.id),
          )
          .toList(growable: false);
    });
  }

  Future<void> deleteTeacher(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}