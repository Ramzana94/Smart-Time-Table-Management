import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_timetable_managment/models/user_profile_model.dart';

class AdminScopeService {
  AdminScopeService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<String?> watchAdminId() {
    late final StreamController<String?> controller;
    StreamSubscription<User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    profileSubscription;
    String? lastEmittedAdminId;

    Future<void> emitResolvedAdminId(
      String userId,
      Map<String, dynamic> profileData,
    ) async {
      try {
        final adminId = await _resolveAdminIdForUser(
          userId: userId,
          profileData: profileData,
        );

        if (controller.isClosed || lastEmittedAdminId == adminId) {
          return;
        }

        lastEmittedAdminId = adminId;
        controller.add(adminId);
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller = StreamController<String?>(
      onListen: () {
        authSubscription = _auth.authStateChanges().listen(
          (user) {
            profileSubscription?.cancel();
            profileSubscription = null;

            if (user == null) {
              lastEmittedAdminId = null;
              controller.add(null);
              return;
            }

            profileSubscription = _firestore
                .collection(_usersCollection)
                .doc(user.uid)
                .snapshots()
                .listen(
                  (snapshot) {
                    emitResolvedAdminId(
                      user.uid,
                      snapshot.data() ?? const <String, dynamic>{},
                    );
                  },
                  onError: (error, stackTrace) {
                    if (!controller.isClosed) {
                      controller.addError(error, stackTrace);
                    }
                  },
                );
          },
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        );
      },
      onCancel: () async {
        await profileSubscription?.cancel();
        await authSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<String?> resolveAdminId() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .get();

    return _resolveAdminIdForUser(
      userId: user.uid,
      profileData: snapshot.data() ?? const <String, dynamic>{},
    );
  }

  Future<String> requireAdminId() async {
    final adminId = await resolveAdminId();
    if (adminId == null || adminId.isEmpty) {
      throw StateError('No admin link found for the current user.');
    }

    return adminId;
  }

  Future<String?> _resolveAdminIdForUser({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    final profile = UserProfileModel.fromJson(profileData, id: userId);

    if (profile.isAdmin) {
      await _persistAdminIdIfNeeded(
        userId: userId,
        currentAdminId: profile.adminId,
        resolvedAdminId: userId,
      );
      return userId;
    }

    if (profile.adminId.trim().isNotEmpty) {
      return profile.adminId.trim();
    }

    final resolvedAdminId =
        await _resolveFromTeacherProfile(profile) ??
        await _resolveFromStudentProfile(profile);

    if (resolvedAdminId == null || resolvedAdminId.isEmpty) {
      return null;
    }

    await _persistAdminIdIfNeeded(
      userId: userId,
      currentAdminId: profile.adminId,
      resolvedAdminId: resolvedAdminId,
    );

    return resolvedAdminId;
  }

  Future<String?> _resolveFromTeacherProfile(UserProfileModel profile) async {
    final teacherId = profile.effectiveTeacherId;
    if (teacherId.isNotEmpty) {
      final byUid = await _findAdminId(
        _firestore
            .collectionGroup('teachers')
            .where('uid', isEqualTo: teacherId)
            .limit(1),
      );
      if (byUid != null) {
        return byUid;
      }

      final byDocumentId = await _findAdminId(
        _firestore
            .collectionGroup('teachers')
            .where(FieldPath.documentId, isEqualTo: teacherId)
            .limit(1),
      );
      if (byDocumentId != null) {
        return byDocumentId;
      }

      final legacyByFieldId = await _findAdminId(
        _firestore
            .collectionGroup('teachers')
            .where('id', isEqualTo: teacherId)
            .limit(1),
      );
      if (legacyByFieldId != null) {
        return legacyByFieldId;
      }
    }

    final email = profile.email.trim();
    if (email.isNotEmpty) {
      final byEmail = await _findAdminId(
        _firestore
            .collectionGroup('teachers')
            .where('teacherEmail', isEqualTo: email)
            .limit(1),
      );
      if (byEmail != null) {
        return byEmail;
      }
    }

    final name = profile.name.trim();
    if (name.isNotEmpty) {
      return _findAdminId(
        _firestore
            .collectionGroup('teachers')
            .where('teacherName', isEqualTo: name)
            .limit(1),
      );
    }

    return null;
  }

  Future<String?> _resolveFromStudentProfile(UserProfileModel profile) async {
    final departmentId = profile.departmentId.trim();
    if (departmentId.isNotEmpty) {
      final byDocumentId = await _findAdminId(
        _firestore
            .collectionGroup('departments')
            .where(FieldPath.documentId, isEqualTo: departmentId)
            .limit(1),
      );
      if (byDocumentId != null) {
        return byDocumentId;
      }
    }

    final departmentName = profile.department.trim();
    if (departmentName.isNotEmpty) {
      return _findAdminId(
        _firestore
            .collectionGroup('departments')
            .where('depName', isEqualTo: departmentName)
            .limit(1),
      );
    }

    return null;
  }

  Future<String?> _findAdminId(Query<Map<String, dynamic>> query) async {
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.reference.parent.parent?.id;
  }

  Future<void> _persistAdminIdIfNeeded({
    required String userId,
    required String currentAdminId,
    required String resolvedAdminId,
  }) async {
    final normalizedCurrentAdminId = currentAdminId.trim();
    final normalizedResolvedAdminId = resolvedAdminId.trim();

    if (normalizedResolvedAdminId.isEmpty ||
        normalizedCurrentAdminId == normalizedResolvedAdminId) {
      return;
    }

    await _firestore.collection(_usersCollection).doc(userId).set({
      'adminId': normalizedResolvedAdminId,
    }, SetOptions(merge: true));
  }
}