import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/services/user_profile_service.dart';
import 'package:smart_timetable_managment/models/user_profile_model.dart';

class UserSessionController extends GetxController {
  UserSessionController({
    FirebaseAuth? auth,
    UserProfileService? userProfileService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _userProfileService = userProfileService ?? UserProfileService();

  final FirebaseAuth _auth;
  final UserProfileService _userProfileService;

  final currentUser = Rxn<UserProfileModel>();
  final isLoading = true.obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserProfileModel?>? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChanged,
      onError: (_) {
        currentUser.value = null;
        isLoading.value = false;
      },
    );
  }

  String get userRole {
    final role = currentUser.value?.role.trim() ?? '';
    return role.isEmpty ? 'Student' : role;
  }

  String get normalizedRole => userRole.toLowerCase();

  bool get isAdmin => normalizedRole == 'admin';

  bool get isTeacher => normalizedRole == 'teacher';

  bool get isStudent => normalizedRole == 'student';

  void _handleAuthChanged(User? firebaseUser) {
    _profileSubscription?.cancel();

    if (firebaseUser == null) {
      currentUser.value = null;
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _profileSubscription = _userProfileService
        .watchProfile(firebaseUser.uid)
        .listen(
          (profile) {
            currentUser.value = profile ?? _fallbackProfile(firebaseUser);
            isLoading.value = false;
          },
          onError: (_) {
            currentUser.value = _fallbackProfile(firebaseUser);
            isLoading.value = false;
          },
        );
  }

  UserProfileModel _fallbackProfile(User firebaseUser) {
    return UserProfileModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : 'User',
      email: firebaseUser.email ?? '',
      image: firebaseUser.photoURL ?? '',
    );
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.onClose();
  }

  Future<void> updateUserProfile(UserProfileModel profile) async {
    await _userProfileService.updateProfile(profile);
    currentUser.value = profile;
  }
}