import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_timetable_managment/models/user_profile_model.dart';

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<UserProfileModel?> watchProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) {
        return null;
      }

      return UserProfileModel.fromJson(data, id: doc.id);
    });
  }
}