import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_timetable_managment/models/department_model.dart';

class DepartmentService {
  DepartmentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _collectionName = 'departments';
  final FirebaseFirestore _firestore;

  Future<void> addDepartment(DepartmentModel model) async {
    final docRef = _firestore.collection(_collectionName).doc();

    final deptWithId = model.copyWith(id: docRef.id);

    await docRef.set(deptWithId.toJson());
  }

  Future<void> updateDepartment(String id, DepartmentModel model) async {
    await _firestore.collection(_collectionName).doc(id).update(model.toJson());
  }

  Stream<List<DepartmentModel>> getDepartments() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      final departments = snapshot.docs
          .map(
            (document) =>
                DepartmentModel.fromJson(document.data(), id: document.id),
          )
          .toList(growable: false);

      departments.sort((first, second) {
        final nameComparison = first.depName.toLowerCase().compareTo(
          second.depName.toLowerCase(),
        );
        if (nameComparison != 0) {
          return nameComparison;
        }

        return first.depCode.toLowerCase().compareTo(
          second.depCode.toLowerCase(),
        );
      });

      return departments;
    });
  }

  Stream<List<DepartmentModel>> getDiscoverableDepartments() {
    return getDepartments();
  }

  Future<void> deleteDepartment(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}