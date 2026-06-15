import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/app_info_controller.dart';
import 'package:smart_timetable_managment/controllers/auth_controller.dart';
import 'package:smart_timetable_managment/controllers/user_session_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/utils/app_dialogbox.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';


class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  final UserSessionController userSessionController =
      Get.find<UserSessionController>();
  final appInfo = Get.find<AppInfoController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final profile = userSessionController.currentUser.value;

        final name = profile?.name.trim().isNotEmpty == true
            ? profile!.name.trim()
            : 'User';

        final email = profile?.email ?? '';

        final role = profile?.role.trim().isNotEmpty == true
            ? profile!.role.trim()
            : 'Student';

        final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'U';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          body: Column(
            children: [
              //  PROFILE CARD
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(20.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10.r,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// PROFILE IMAGE
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: .15,
                          ),
                          child: CustomText(
                            text: firstLetter,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        // EDIT BUTTON
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              authController.showEditProfileBottomSheet(
                                name,
                                email,
                              );
                            },

                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                AppIcons.edit,
                                size: 14,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    14.verticalSpace,
                    // NAME
                    CustomText(
                      text: name,
                      fontSize: 20.sp,
                      fontWeight: AppWeights.w700,
                    ),

                    6.verticalSpace,

                    /// ROLE
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        text: role,
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: AppWeights.w500,
                      ),
                    ),

                    10.verticalSpace,

                    /// EMAIL
                    CustomText(
                      text: email,
                      fontSize: 15.sp,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),

              //  MENU
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),

                  children: [
                    _buildTile(
                      leading: const Icon(
                        AppIcons.lock_outline,
                        color: AppColors.primary,
                      ),
                      title: AppStrings.changePassword,
                      onTap: authController.showChangePasswordBottomSheet,
                    ),

                    _buildTile(
                      leading: const Icon(
                        AppIcons.info_outline,
                        color: AppColors.primary,
                      ),
                      title: AppStrings.aboutApp,
                      onTap: () {
                        Get.defaultDialog(
                          title: AppStrings.aboutApp,
                          radius: 20.r,
                          content: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Column(
                              children: [
                                Icon(
                                  AppIcons.degree,
                                  size: 60.sp,
                                  color: AppColors.primary,
                                ),

                                15.verticalSpace,
                                CustomText(
                                  text: AppStrings.appName,
                                  fontSize: 18.sp,
                                  fontWeight: AppWeights.w600,
                                  textAlign: TextAlign.center,
                                ),

                                10.verticalSpace,
                                CustomText(
                                  text: AppStrings.aboutAppTitle,
                                  fontSize: 14.sp,
                                  color: AppColors.grey,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    _buildTile(
                      leading: const Icon(
                        AppIcons.history,
                        color: AppColors.primary,
                      ),
                      title: AppStrings.appVersion,
                      trailing: Obx(
                        () => CustomText(
                          text: appInfo.appVersion.value,
                          fontSize: 12.sp,
                          fontWeight: AppWeights.w600,
                        ),
                      ),
                    ),

                    30.verticalSpace,

                    /// LOGOUT
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        color: AppColors.red.withValues(alpha: .08),
                      ),

                      child: ListTile(
                        leading: const Icon(
                          AppIcons.logout,
                          color: AppColors.red,
                        ),
                        title: CustomText(
                          text: AppStrings.logout,
                          color: AppColors.red,
                          fontWeight: AppWeights.w600,
                        ),

                        onTap: () {
                          AppDialogs.showLogoutDialog(
                            message: AppStrings.confirmLogout,
                            onConfirm: authController.logout,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  //  TILE

  Widget _buildTile({
    Widget? leading,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .04),
            blurRadius: 8.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ListTile(
        leading: leading,
        title: CustomText(
          text: title,
          fontSize: 14.sp,
          fontWeight: AppWeights.w500,
        ),
        trailing: trailing ?? const Icon(AppIcons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}