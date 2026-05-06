import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_timetable_managment/core/services/admin_scope_service.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/models/user_profile_model.dart';
class TimetableService {
  TimetableService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AdminScopeService? adminScopeService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _adminScopeService =
           adminScopeService ??
           AdminScopeService(
             auth: auth ?? FirebaseAuth.instance,
             firestore: firestore ?? FirebaseFirestore.instance,
           );

  static const String _adminCollectionName = 'admin_timetable';
  static const String _teacherCollectionName = 'timetable';
  static const String _teachersCollection = 'teachers';
  static const String _usersCollection = 'users';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AdminScopeService _adminScopeService;
  CollectionReference<Map<String, dynamic>> get _adminTimetableCollection =>
      _firestore.collection(_adminCollectionName);
  CollectionReference<Map<String, dynamic>> get _teacherTimetableCollection =>
      _firestore.collection(_teacherCollectionName);

  Future<String> _resolveWriteAdminId({String? adminId}) async {
    final explicitAdminId = adminId?.trim() ?? '';
    if (explicitAdminId.isNotEmpty) {
      return explicitAdminId;
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return '';
    }

    final profileSnapshot = await _firestore
        .collection(_usersCollection)
        .doc(currentUser.uid)
        .get();

    final profile = UserProfileModel.fromJson(
      profileSnapshot.data() ?? const <String, dynamic>{},
      id: currentUser.uid,
    );

    return _resolveAdminId(profile);
  }

  Future<void> addTimetable(TimetableModel model, {String? adminId}) async {
    final effectiveAdminId = await _resolveWriteAdminId(adminId: adminId);
    final adminRef = _adminTimetableCollection.doc();
    final teacherRef = _teacherTimetableCollection.doc(adminRef.id);
    final newModel = model.copyWith(id: adminRef.id);
    final payload = _buildTimetablePayload(
      newModel,
      adminId: effectiveAdminId,
      includeCreatedAt: true,
    );

    final batch = _firestore.batch();
    batch.set(adminRef, payload);
    batch.set(teacherRef, payload);
    await batch.commit();
  }

  Future<void> updateTimetable(
    String id,
    TimetableModel model, {
    String? adminId,
  }) async {
    final effectiveAdminId = await _resolveWriteAdminId(adminId: adminId);
    final payload = _buildTimetablePayload(
      model.copyWith(id: id),
      adminId: effectiveAdminId,
      includeCreatedAt: false,
    );

    final batch = _firestore.batch();
    batch.set(
      _adminTimetableCollection.doc(id),
      payload,
      SetOptions(merge: true),
    );
    batch.set(
      _teacherTimetableCollection.doc(id),
      payload,
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Stream<List<TimetableModel>> getTimetable({String? adminId}) {
    final normalizedAdminId = adminId?.trim() ?? '';
    if (normalizedAdminId.isNotEmpty) {
      return _watchAdminTimetable(normalizedAdminId);
    }

    return _watchCurrentUserTimetable();
  }

  Stream<List<TimetableModel>> getTimetableByAdminId(String adminId) {
    return getTimetable(adminId: adminId);
  }

  Future<void> deleteTimetable(String id, {String? adminId}) async {
    final batch = _firestore.batch();
    batch.delete(_adminTimetableCollection.doc(id));
    batch.delete(_teacherTimetableCollection.doc(id));
    await batch.commit();
  }

  Stream<List<TimetableModel>> _watchAdminTimetable(String adminId) {
    final normalizedAdminId = adminId.trim();
    return _adminTimetableCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .where(
            (document) =>
                _matchesAdminScope(document.data(), normalizedAdminId),
          )
          .map(_mapDocument)
          .toList(growable: false);
    });
  }

  Stream<List<TimetableModel>> _watchCurrentUserTimetable() {
    late final StreamController<List<TimetableModel>> controller;
    StreamSubscription<User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    profileSubscription;
    StreamSubscription<List<TimetableModel>>? timetableSubscription;

    Future<void> bindProfile(User user) async {
      await profileSubscription?.cancel();
      profileSubscription = _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .snapshots()
          .listen(
            (snapshot) async {
              final profile = UserProfileModel.fromJson(
                snapshot.data() ?? const <String, dynamic>{},
                id: user.uid,
              );

              final adminId = profile.isAdmin
                  ? await _resolveAdminId(profile)
                  : '';
              final nextStream = await _resolveUserTimetableStream(
                profile: profile,
                adminId: adminId,
              );

              await timetableSubscription?.cancel();
              timetableSubscription = nextStream.listen(
                (items) {
                  if (!controller.isClosed) {
                    controller.add(items);
                  }
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
    }

    controller = StreamController<List<TimetableModel>>(
      onListen: () {
        authSubscription = _auth.authStateChanges().listen(
          (user) async {
            await profileSubscription?.cancel();
            profileSubscription = null;

            await timetableSubscription?.cancel();
            timetableSubscription = null;

            if (user == null) {
              controller.add(const <TimetableModel>[]);
              return;
            }

            await bindProfile(user);
          },
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        );
      },
      onCancel: () async {
        await timetableSubscription?.cancel();
        await profileSubscription?.cancel();
        await authSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Future<String> _resolveAdminId(UserProfileModel profile) async {
    if (profile.isAdmin && profile.uid.trim().isNotEmpty) {
      return profile.uid.trim();
    }

    if (profile.adminId.trim().isNotEmpty) {
      return profile.adminId.trim();
    }

    return await _adminScopeService.resolveAdminId() ?? '';
  }

  Future<Stream<List<TimetableModel>>> _resolveUserTimetableStream({
    required UserProfileModel profile,
    required String adminId,
  }) async {
    if (profile.isAdmin) {
      await _syncAdminMirror(adminId);
      return _watchAdminTimetable(adminId);
    }

    if (profile.isTeacher) {
      return _watchTeacherTimetable(profile: profile);
    }

    if (profile.isStudent) {
      return _watchStudentTimetable();
    }

    return Stream<List<TimetableModel>>.value(const <TimetableModel>[]);
  }

  Future<Stream<List<TimetableModel>>> _watchTeacherTimetable({
    required UserProfileModel profile,
  }) async {
    final teacherScope = await _resolveTeacherScope(profile: profile);
    final teacherIds = teacherScope.ids;
    final teacherNames = teacherScope.names;

    if (teacherIds.isEmpty && teacherNames.isEmpty) {
      return Stream<List<TimetableModel>>.value(const <TimetableModel>[]);
    }

    final collection = _teacherTimetableCollection;
    if (teacherIds.isNotEmpty) {
      final ids = teacherIds.toList(growable: false);
      final query = ids.length == 1
          ? collection.where('teacherId', isEqualTo: ids.first)
          : collection.where('teacherId', whereIn: ids);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map(_mapDocument).toList(growable: false);
      });
    }

    if (teacherNames.isNotEmpty) {
      return collection.snapshots().map((snapshot) {
        return snapshot.docs
            .map(_mapDocument)
            .where((entry) => teacherNames.contains(_normalize(entry.teacher)))
            .toList(growable: false);
      });
    }

    return Stream<List<TimetableModel>>.value(const <TimetableModel>[]);
  }

  Future<({Set<String> ids, Set<String> names})> _resolveTeacherScope({
    required UserProfileModel profile,
  }) async {
    final teacherIds = <String>{};
    final teacherNames = <String>{};
    final explicitTeacherId = profile.effectiveTeacherId;
    if (explicitTeacherId.isNotEmpty) {
      teacherIds.add(explicitTeacherId);
    }
    final profileName = _normalize(profile.name);
    if (profileName.isNotEmpty) {
      teacherNames.add(profileName);
    }

    final teachersQuery = _firestore.collection(_teachersCollection);

    final email = profile.email.trim();
    if (email.isNotEmpty) {
      final emailMatch = await teachersQuery
          .where('teacherEmail', isEqualTo: email)
          .limit(1)
          .get();
      if (emailMatch.docs.isNotEmpty) {
        final teacherDocument = emailMatch.docs.first;
        final teacherName = _normalize(
          (teacherDocument.data()['teacherName'] ?? '').toString(),
        );
        if (teacherName.isNotEmpty) {
          teacherNames.add(teacherName);
        }
        final teacherUid = (teacherDocument.data()['uid'] ?? '')
            .toString()
            .trim();
        if (teacherUid.isNotEmpty) {
          teacherIds.add(teacherUid);
        } else if (explicitTeacherId.isNotEmpty) {
          teacherIds.add(explicitTeacherId);
          await teacherDocument.reference.set({
            'uid': explicitTeacherId,
          }, SetOptions(merge: true));
        }
        teacherIds.add(teacherDocument.id);
      }
    }

    if (teacherIds.length <= (explicitTeacherId.isNotEmpty ? 1 : 0)) {
      final name = profile.name.trim();
      if (name.isNotEmpty) {
        final nameMatch = await teachersQuery
            .where('teacherName', isEqualTo: name)
            .limit(1)
            .get();
        if (nameMatch.docs.isNotEmpty) {
          final teacherDocument = nameMatch.docs.first;
          final teacherName = _normalize(
            (teacherDocument.data()['teacherName'] ?? '').toString(),
          );
          if (teacherName.isNotEmpty) {
            teacherNames.add(teacherName);
          }
          final teacherUid = (teacherDocument.data()['uid'] ?? '')
              .toString()
              .trim();
          if (teacherUid.isNotEmpty) {
            teacherIds.add(teacherUid);
          } else if (explicitTeacherId.isNotEmpty) {
            teacherIds.add(explicitTeacherId);
            await teacherDocument.reference.set({
              'uid': explicitTeacherId,
            }, SetOptions(merge: true));
          }
          teacherIds.add(teacherDocument.id);
        }
      }
    }

    if (teacherIds.isNotEmpty && explicitTeacherId.isEmpty) {
      await _persistUserField(
        userId: profile.uid,
        field: 'teacherId',
        value: teacherIds.first,
      );
    }

    return (ids: teacherIds, names: teacherNames);
  }

  Future<Stream<List<TimetableModel>>> _watchStudentTimetable() async {
    return _watchTimetableQuery(_teacherTimetableCollection);
  }

  Stream<List<TimetableModel>> _watchTimetableQuery(
    Query<Map<String, dynamic>> query, {
    String adminId = '',
  }) {
    final normalizedAdminId = adminId.trim();
    return query.snapshots().map((snapshot) {
      final docs = normalizedAdminId.isEmpty
          ? snapshot.docs
          : snapshot.docs
                .where(
                  (document) =>
                      _matchesAdminScope(document.data(), normalizedAdminId),
                )
                .toList(growable: false);

      return docs.map(_mapDocument).toList(growable: false);
    });
  }

  TimetableModel _mapDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return TimetableModel.fromJson(document.data(), id: document.id);
  }

  Future<void> _persistUserField({
    required String userId,
    required String field,
    required String value,
  }) async {
    if (userId.trim().isEmpty || value.trim().isEmpty) {
      return;
    }

    await _firestore.collection(_usersCollection).doc(userId).set({
      field: value.trim(),
    }, SetOptions(merge: true));
  }

  Future<void> _syncAdminMirror(String adminId) async {
    final normalizedAdminId = adminId.trim();
    final snapshot = await _adminTimetableCollection.get();
    final documents = snapshot.docs
        .where(
          (document) => _matchesAdminScope(document.data(), normalizedAdminId),
        )
        .toList(growable: false);

    if (documents.isEmpty) {
      return;
    }

    const chunkSize = 400;
    for (var index = 0; index < documents.length; index += chunkSize) {
      final batch = _firestore.batch();
      final end = (index + chunkSize) > documents.length
          ? documents.length
          : index + chunkSize;

      for (final document in documents.sublist(index, end)) {
        final payload = Map<String, dynamic>.from(document.data());
        if (normalizedAdminId.isNotEmpty &&
            (payload['adminId'] ?? '').toString().trim().isEmpty) {
          payload['adminId'] = normalizedAdminId;
        }

        batch.set(
          _teacherTimetableCollection.doc(document.id),
          payload,
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    }
  }

  Map<String, dynamic> _buildTimetablePayload(
    TimetableModel model, {
    required String adminId,
    required bool includeCreatedAt,
  }) {
    return {
      ...model.toJson(),
      if (adminId.trim().isNotEmpty) 'adminId': adminId.trim(),
      if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool _matchesAdminScope(Map<String, dynamic> json, String normalizedAdminId) {
    if (normalizedAdminId.isEmpty) {
      return true;
    }

    final entryAdminId = (json['adminId'] ?? '').toString().trim();
    return entryAdminId == normalizedAdminId;
  }

  String _normalize(String value) => value.trim().toLowerCase();
}