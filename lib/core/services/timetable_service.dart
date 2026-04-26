import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTimetable(TimetableModel model) async {
    await _firestore.collection('timetable').add(model.toJson());
  }

  Stream<List<TimetableModel>> getTimetable() {
    return _firestore.collection('timetable').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => TimetableModel.fromJson(doc.data()))
          .toList(),
    );
  }
}