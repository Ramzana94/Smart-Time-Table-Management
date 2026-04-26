import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/routes/routes_name.dart';
import 'package:smart_timetable_managment/core/services/auth_services.dart';
import 'package:smart_timetable_managment/core/utils/app_snack_bar.dart';
import 'package:smart_timetable_managment/core/utils/app_validations.dart';
import 'package:smart_timetable_managment/core/utils/firebase_error_handler.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';

class AuthController extends GetxController {
  final authServices = AuthServices();
  FirebaseAuth auth = FirebaseAuth.instance;

  var isLoginLoading = false.obs;
  var isSignupLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isGoogleLoading = false.obs;
  var isForgotLoading = false.obs;
  var isChangePasswordLoading = false.obs;

  var isNewPasswordVisible = false.obs;

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  final forgotEmailController = TextEditingController();

  final changeNewPassController = TextEditingController();
  final changeConfirmPassController = TextEditingController();

  final List<String> roles = ['Student', 'Teacher', 'Admin'];
  final roleNotifier = ValueNotifier<String?>(null);
  void updateSelectedRole(String? value) {
    roleNotifier.value = value;
  }

  // 🔥 CHECK USER (Splash)
  Future<void> checkUser() async {
    try {
      User? user = auth.currentUser;

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          await auth.signOut();
          Get.offAllNamed(RoutesName.onboardingScreen);
          return;
        }

        String role = doc['role'];
        navigateBasedOnRole(role);
      } else {
        Get.offAllNamed(RoutesName.onboardingScreen);
      }
    } catch (e) {
      AppSnackbar.error("Error", "Something went wrong");
    }
  }

  // 🔥 SIGN UP
  Future<void> signUp() async {
    if (roleNotifier.value == null) {
      AppSnackbar.error("Error", "Please select a role");
      return;
    }

    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text.trim();
    final confirmPassword = signupConfirmPasswordController.text.trim();

    if (password != confirmPassword) {
      AppSnackbar.error("Error", "Passwords do not match");
      return;
    }

    try {
      isSignupLoading.value = true;

      final user = await authServices.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          "name": signupNameController.text.trim(),
          "email": email,
          "role": roleNotifier.value,
          "uid": user.uid,
          "createdAt": DateTime.now(),
        });

        AppSnackbar.success("Success", "Account created successfully");

        navigateBasedOnRole(roleNotifier.value!);
      }
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error("Error", FirebaseErrorHandler.getAuthErrorMessage(e));
    } catch (e) {
      AppSnackbar.error("Error", "Signup failed");
    } finally {
      isSignupLoading.value = false;
    }
  }

  // 🔥 LOGIN
  Future<void> login() async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text.trim();

    try {
      isLoginLoading.value = true;

      final user = await authServices.loginUserWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String role = doc['role'];

        AppSnackbar.success("Success", "Login Successful");

        navigateBasedOnRole(role);
      }
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error("Error", FirebaseErrorHandler.getAuthErrorMessage(e));
    } catch (e) {
      AppSnackbar.error("Error", "Login failed");
    } finally {
      isLoginLoading.value = false;
    }
  }

  // 🔥 FORGOT PASSWORD
  Future<void> forgotPassword() async {
    final email = forgotEmailController.text.trim();

    try {
      isForgotLoading.value = true;

      await auth.sendPasswordResetEmail(email: email);

      AppSnackbar.success("Success", "Password reset email sent");
      Get.back();
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error("Error", FirebaseErrorHandler.getAuthErrorMessage(e));
    } catch (e) {
      AppSnackbar.error("Error", "Something went wrong");
    } finally {
      isForgotLoading.value = false;
    }
  }

  Future<void> continueWithGoogle() async {
    try {
      isGoogleLoading.value = true;

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId:
            "432036284021-v37d07mlvhs1utrss9ovpkt0fom46vdj.apps.googleusercontent.com",
      );

      final GoogleSignInAccount account = await googleSignIn.authenticate();

      final googleAuth = await account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid);

        final doc = await docRef.get();

        if (!doc.exists) {
          await docRef.set({
            "name": user.displayName,
            "email": user.email,
            "uid": user.uid,
            "image": user.photoURL,
            "createdAt": DateTime.now(),
          });

          Future.delayed(Duration(milliseconds: 100), () {
            showRoleSelectionBottomSheet(user);
          });
        } else {
          final data = doc.data();
          if (data != null && data.containsKey("role")) {
            navigateBasedOnRole(data["role"]);
          } else {
            showRoleSelectionBottomSheet(user);
          }
        }
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      AppSnackbar.error("Error", "Google sign-in failed");
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // 🔥 GOOGLE LOGIN

  // role select
  void showRoleSelectionBottomSheet(User user) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .1),
              blurRadius: 20.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Handle bar
            Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            20.verticalSpace,

            /// Title
            CustomText(
              text: AppStrings.selectYourRole,
              fontSize: AppSizes.s20,
              fontWeight: AppWeights.w600,
              color: AppColors.primary,
            ),
            8.verticalSpace,
            CustomText(
              text: AppStrings.chooseHowContiue,
              fontSize: AppSizes.s14,
              color: AppColors.grey,
            ),

            20.verticalSpace,

            /// Roles
            ...roles.map((role) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await updateUserRole(user, role);
                    Get.back();
                    navigateBasedOnRole(role);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: .1),
                          Colors.white,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: .2),
                      ),
                    ),
                    child: Row(
                      children: [
                        /// Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 15),

                        /// Role text
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> updateUserRole(User user, String role) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "role": role,
    }, SetOptions(merge: true));
  }

  // void navigateBasedOnRole(String role) {
  //   Get.offAllNamed(RoutesName.navigationScreen);
  // }

  // 🔥 NAVIGATION
  void navigateBasedOnRole(String role) {
    Get.offAllNamed(RoutesName.navigationScreen, arguments: role);
  }

  // change password
  void showChangePasswordBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                height: 5.h,
                width: 50.w,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              20.verticalSpace,
              CustomText(
                text: AppStrings.changePassword,
                fontSize: AppSizes.s20,
                fontWeight: AppWeights.w600,
              ),

              20.verticalSpace,

              /// New Password
              Obx(() {
                return CustomTextFormField(
                  isVisible: isNewPasswordVisible,
                  onToggle: toggleNewPasswordVisibility,
                  validator: AppValidators.validatePassword,
                  obscureText: isPasswordVisible.value,
                  hintText: AppStrings.newPass,
                  controller: changeNewPassController,
                  borderRadius: BorderRadius.circular(10),
                  prefixIcon: Icon(AppIcons.key),
                );
              }),

              10.verticalSpace,

              /// Confirm Password
              Obx(() {
                return CustomTextFormField(
                  isVisible: isConfirmPasswordVisible,
                  onToggle: toggleConfirmPasswordVisibility,
                  obscureText: isConfirmPasswordVisible.value,
                  validator: (value) {
                    return AppValidators.validateConfirmPassword(
                      value,
                      changeConfirmPassController.text,
                    );
                  },
                  hintText: AppStrings.ChangeconfirmPassword,
                  controller: changeConfirmPassController,
                  borderRadius: BorderRadius.circular(10),
                  prefixIcon: Icon(AppIcons.key),
                );
              }),

              20.verticalSpace,

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        backgroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: CustomText(text: AppStrings.cancel),
                    ),
                  ),

                  10.horizontalSpace,
                  Obx(
                    () => Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: isChangePasswordLoading.value
                            ? null
                            : () async {
                                String newPass = changeNewPassController.text
                                    .trim();
                                String confirmPass = changeConfirmPassController
                                    .text
                                    .trim();

                                if (newPass.isEmpty || confirmPass.isEmpty) {
                                  AppSnackbar.error(
                                    "Error",
                                    "Please fill all fields",
                                  );
                                  return;
                                }

                                if (newPass != confirmPass) {
                                  AppSnackbar.error(
                                    "Error",
                                    "Passwords do not match",
                                  );
                                  return;
                                }

                                try {
                                  isChangePasswordLoading.value = true;

                                  await FirebaseAuth.instance.currentUser!
                                      .updatePassword(newPass);

                                  Get.back();

                                  AppSnackbar.success(
                                    "Success",
                                    "Password updated successfully",
                                  );

                                  /// clear fields
                                  changeNewPassController.clear();
                                  changeConfirmPassController.clear();
                                } catch (e) {
                                  AppSnackbar.error("Error", e.toString());
                                } finally {
                                  isChangePasswordLoading.value = false;
                                }
                              },

                        child: isChangePasswordLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  backgroundColor: AppColors.primary,
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : Text(AppStrings.save),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // isScrollControlled: true,
    );
  }

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void clearLoginFields() {
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  void clearSignUpFields() {
    signupNameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
  }

  void clearForgotFields() {
    forgotEmailController.clear();
  }

  // 🔥 LOGOUT
  Future<void> logout() async {
    try {
      await auth.signOut();
      await GoogleSignIn.instance.disconnect();

      Get.offAllNamed(RoutesName.loginScreen);
    } catch (e) {
      AppSnackbar.error("Error", "Logout failed");
    }
  }

  // change password
  Future<void> changePassword(
    String newPassword,
    String currentPassword,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email!;

      // 🔐 Re-authentication
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 🔁 Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    forgotEmailController.dispose();
    changeConfirmPassController.dispose();
    changeNewPassController.dispose();
    roleNotifier.dispose();
    super.onClose();
  }
}
