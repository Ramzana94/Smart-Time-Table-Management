import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_timetable_managment/core/services/admin_scope_service.dart';

abstract class AdminScopedFirestoreService {
  AdminScopedFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AdminScopeService? adminScopeService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _adminScopeService =
           adminScopeService ??
           AdminScopeService(
             auth: auth ?? FirebaseAuth.instance,
             firestore: firestore ?? FirebaseFirestore.instance,
           );

  static const String adminsCollection = 'admins_data';

  final FirebaseFirestore _firestore;
  final AdminScopeService _adminScopeService;

  CollectionReference<Map<String, dynamic>> adminSubcollectionById(
    String adminId,
    String collectionName,
  ) {
    return _firestore
        .collection(adminsCollection)
        .doc(adminId)
        .collection(collectionName);
  }

  Future<CollectionReference<Map<String, dynamic>>> adminSubcollection(
    String collectionName,
  ) async {
    final adminId = await _adminScopeService.requireAdminId();
    return adminSubcollectionById(adminId, collectionName);
  }

  Stream<List<T>> watchAdminSubcollectionById<T>({
    required String adminId,
    required String collectionName,
    required T Function(QueryDocumentSnapshot<Map<String, dynamic>> document)
    fromDocument,
  }) {
    return adminSubcollectionById(adminId, collectionName).snapshots().map(
      (snapshot) => snapshot.docs.map(fromDocument).toList(growable: false),
    );
  }

  Stream<List<T>> watchAdminSubcollection<T>({
    required String collectionName,
    required T Function(QueryDocumentSnapshot<Map<String, dynamic>> document)
    fromDocument,
  }) {
    late final StreamController<List<T>> controller;
    StreamSubscription<String?>? adminIdSubscription;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    collectionSubscription;

    controller = StreamController<List<T>>(
      onListen: () {
        adminIdSubscription = _adminScopeService.watchAdminId().listen(
          (adminId) {
            collectionSubscription?.cancel();
            collectionSubscription = null;

            if (adminId == null || adminId.isEmpty) {
              controller.add(<T>[]);
              return;
            }

            collectionSubscription = _firestore
                .collection(adminsCollection)
                .doc(adminId)
                .collection(collectionName)
                .snapshots()
                .listen(
                  (snapshot) {
                    controller.add(
                      snapshot.docs.map(fromDocument).toList(growable: false),
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
        await collectionSubscription?.cancel();
        await adminIdSubscription?.cancel();
      },
    );

    return controller.stream;
  }
}