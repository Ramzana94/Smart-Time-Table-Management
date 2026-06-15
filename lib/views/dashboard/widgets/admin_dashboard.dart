import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_analytics_controller.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/views/dashboard/analytics/admin_analytics_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/department/department_screen.dart';
import 'package:smart_timetable_managment/views/dashboard/department/teacher_screen.dart';
import 'package:smart_timetable_managment/widgets/app_cards.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

class AdminDasboard extends StatelessWidget {
  AdminDasboard({super.key});

  final adminCtrl = Get.find<AdminDashboardController>();
  final analyticsCtrl = Get.find<AdminAnalyticsController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            20.verticalSpace,
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: _cardWidth(context),
                    child: CustomCard(
                      title: AppStrings.totalClasses,
                      subtitle: 'Live timetable sessions',
                      value: '${adminCtrl.totalClassCount}',
                      icon: AppIcons.event_note,
                      height: 72.h,
                      accentColor: const Color(0xFF0F8A83),
                    ),
                  ),
                  SizedBox(
                    width: _cardWidth(context),
                    child: CustomCard(
                      title: AppStrings.teachers,
                      subtitle: 'Faculty profiles available',
                      value: '${adminCtrl.totalTeacherCount}',
                      icon: AppIcons.school,
                      height: 72.h,
                      accentColor: const Color(0xFFCE7B1D),
                    ),
                  ),
                  SizedBox(
                    width: _cardWidth(context),
                    child: CustomCard(
                      title: AppStrings.departments,
                      subtitle: 'Academic units configured',
                      value: '${adminCtrl.totalDepartmentCount}',
                      icon: AppIcons.apartment,
                      height: 72.h,
                      accentColor: const Color(0xFF6B5AED),
                    ),
                  ),
                  SizedBox(
                    width: _cardWidth(context),
                    child: CustomCard(
                      title: AppStrings.rooms,
                      subtitle: 'Distinct scheduled rooms',
                      value: '${adminCtrl.totalRoomCount}',
                      icon: AppIcons.class_,
                      height: 72,
                      accentColor: const Color(0xFFDB4E62),
                    ),
                  ),
                ],
              ),
            ),
            24.verticalSpace,
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7E0EE)),
              ),
              child: TabBar(
                controller: adminCtrl.tabController,
                onTap: adminCtrl.changeTab,
                dividerColor: AppColors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F356899),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                labelColor: AppColors.white,
                unselectedLabelColor: const Color(0xFF4A6280),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: "Department"),
                  Tab(text: "Teachers"),
                  Tab(text: "Analytics"),
                ],
              ),
            ),
            12.verticalSpace,
            Obx(() => _buildCurrentTab()),
          ],
        ),
      ),
    );
  }

  double _cardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 40;
    if (availableWidth < 420) {
      return (availableWidth - 12) / 2;
    }
    return (availableWidth - 24) / 3;
  }

  Widget _buildHeroCard() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2942), Color(0xFF356899), Color(0xFF69A7B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24142F4D),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 56.h,
                  width: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    AppIcons.person,
                    color: AppColors.white,
                    size: AppSizes.s28,
                  ),
                ),
                14.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: AppStrings.adminDashboard,
                        color: AppColors.white,
                        fontSize: AppSizes.s22,
                        fontWeight: AppWeights.bold,
                      ),
                      4.verticalSpace,
                      CustomText(
                        text: AppStrings.adminAccessControl,
                        color: const Color(0xFFD5E7F4),
                        fontSize: AppSizes.s14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            18.verticalSpace,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insights_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: Text(
                      '${adminCtrl.totalClassCount} classes are being monitored across ${adminCtrl.totalDepartmentCount} departments, while analytics keeps teacher load and room availability live.',
                      style: const TextStyle(
                        color: Color(0xFFE3F0F6),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (analyticsCtrl.isReady) ...[
              16.verticalSpace,
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeroPill(
                    icon: Icons.calendar_view_week_outlined,
                    label: '${adminCtrl.totalClassCount} sessions',
                  ),
                  _HeroPill(
                    icon: Icons.groups_2_outlined,
                    label: '${adminCtrl.totalTeacherCount} teachers',
                  ),
                  _HeroPill(
                    icon: Icons.meeting_room_outlined,
                    label: '${adminCtrl.totalRoomCount} rooms',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (adminCtrl.currentTabIndex.value) {
      case 1:
        return const TeacherScreen();
      case 2:
        return const AdminAnalyticsScreen();
      default:
        return const DepartmentScreen();
    }
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}