import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/controllers/user_session_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/utils/app_dialogbox.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final UserSessionController userSessionController =
      Get.find<UserSessionController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Obx(() {
          final profile = userSessionController.currentUser.value;
          final name = profile?.name.trim().isNotEmpty == true
              ? profile!.name.trim()
              : 'User';
          final email = profile?.email.trim() ?? '';
          final role = profile?.role.trim().isNotEmpty == true
              ? profile!.role.trim()
              : 'Student';
          final firstLetter = name[0].toUpperCase();

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                14.verticalSpace,
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                6.verticalSpace,
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF61748E),
                  ),
                ),
                if (email.isNotEmpty) ...[
                  4.verticalSpace,
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF61748E),
                    ),
                  ),
                ],
                30.verticalSpace,
                CustomButton(
                  onPressed: () {
                    authController.showChangePasswordBottomSheet();
                  },
                  text: AppStrings.changePassword,
                  color: AppColors.primary,
                  borderRadius: 10,
                  height: 57,
                  textColor: AppColors.white,
                ),
                20.verticalSpace,
                CustomButton(
                  onPressed: () {
                    AppDialogs.showLogoutDialog(() {
                      authController.logout();
                    });
                  },
                  text: AppStrings.logout,
                  color: AppColors.red,
                  borderRadius: 10.r,
                  height: 57.h,
                  textColor: AppColors.white,
                  icon: const Icon(AppIcons.logout, color: AppColors.white),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:smart_timetable_managment/controllers/auth_controller.dart';
// import 'package:smart_timetable_managment/controllers/user_session_controller.dart';
// import 'package:smart_timetable_managment/core/constants/app_colors.dart';
// import 'package:smart_timetable_managment/core/constants/app_icons.dart';
// import 'package:smart_timetable_managment/core/constants/app_strings.dart';
// import 'package:smart_timetable_managment/core/utils/app_dialogbox.dart';
// import 'package:smart_timetable_managment/widgets/app_button.dart';

// class ProfileScreen extends StatelessWidget {
//   ProfileScreen({super.key});

//   final AuthController authController = Get.find<AuthController>();
//   final UserSessionController userSessionController =
//       Get.find<UserSessionController>();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Obx(() {
//           final profile = userSessionController.currentUser.value;

//           final name = profile?.name.trim().isNotEmpty == true
//               ? profile!.name.trim()
//               : 'User';

//           final email = profile?.email.trim() ?? '';

//           final role = profile?.role.trim().isNotEmpty == true
//               ? profile!.role.trim()
//               : 'Student';

//           final firstLetter = name[0].toUpperCase();

//           final department = profile?.department ?? '';
//           final semester = profile?.semester ?? '';
//           final shift = profile?.shift ?? '';

//           return SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 /// Avatar
//                 CircleAvatar(
//                   radius: 60.r,
//                   backgroundColor: AppColors.primary.withValues(alpha: 0.12),
//                   child: Text(
//                     firstLetter,
//                     style: TextStyle(
//                       fontSize: 34.sp,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),

//                 14.verticalSpace,

//                 /// Name
//                 Text(
//                   name,
//                   style: TextStyle(
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),

//                 6.verticalSpace,

//                 /// Role
//                 Text(
//                   role,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: const Color(0xFF61748E),
//                   ),
//                 ),

//                 /// Email
//                 if (email.isNotEmpty) ...[
//                   4.verticalSpace,
//                   Text(
//                     email,
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color: const Color(0xFF61748E),
//                     ),
//                   ),
//                 ],

//                 /// 🎯 Student Info (IMPORTANT)
//                 if (role == 'Student') ...[
//                   20.verticalSpace,
//                   _infoTile("Department", department),
//                   _infoTile("Semester", semester),
//                   _infoTile("Shift", shift),
//                 ],

//                 30.verticalSpace,

//                 /// Change Password
//                 CustomButton(
//                   onPressed: () {
//                     authController.showChangePasswordBottomSheet();
//                   },
//                   text: AppStrings.changePassword,
//                   color: AppColors.primary,
//                   borderRadius: 10,
//                   height: 57,
//                   textColor: AppColors.white,
//                 ),

//                 20.verticalSpace,

//                 /// Logout
//                 CustomButton(
//                   onPressed: () {
//                     AppDialogs.showLogoutDialog(() {
//                       authController.logout();
//                     });
//                   },
//                   text: AppStrings.logout,
//                   color: AppColors.red,
//                   borderRadius: 10,
//                   height: 57,
//                   textColor: AppColors.white,
//                   icon: const Icon(AppIcons.logout, color: AppColors.white),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   /// 🔹 Info Tile
//   Widget _infoTile(String title, String value) {
//     if (value.isEmpty) return const SizedBox();

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F8FC),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Text(
//             "$title: ",
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF12284A),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Color(0xFF61748E)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }