import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/home_dashboard_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/dashboard_message_card.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/lecture_card.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/welcome_header.dart';
import 'package:smart_timetable_managment/widgets/app_cards.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';


class TeacherDashboard extends StatelessWidget {
  TeacherDashboard({super.key});

  final HomeDashboardController homeCtrl = Get.find<HomeDashboardController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Obx(() {
          if (homeCtrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final lectures = homeCtrl.upcomingLectures.take(5).toList();
          final notice = homeCtrl.homeNotice;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WelcomeHeader(),
                _ContextStrip(text: homeCtrl.headerSubtitle),
                12.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        title: AppStrings.totalClasses,
                        value: '${homeCtrl.totalClasses}',
                        icon: AppIcons.event_note,
                        height: 60,
                        accentColor: AppColors.primary,
                      ),
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: CustomCard(
                        title: "Today's Lectures",
                        value: '${homeCtrl.todayLectures.length}',
                        icon: AppIcons.timer,
                        height: 72,
                        accentColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (notice != null) ...[
                  18.verticalSpace,
                  DashboardMessageCard(message: notice),
                ],
                20.verticalSpace,
                Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: AppStrings.upComingLecture,
                          fontSize: AppSizes.s18,
                          fontWeight: AppWeights.bold,
                        ),
                        12.verticalSpace,
                        if (lectures.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No upcoming lectures found'),
                          )
                        else
                          Column(
                            children: lectures.map((lecture) {
                              return LectureCard(
                                title: lecture.subject,
                                dayTime: '${lecture.day} • ${lecture.time}',
                                room: 'Room ${lecture.room}',
                                department:
                                    '${lecture.department} • Semester ${lecture.semester}',
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ContextStrip extends StatelessWidget {
  const _ContextStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF28415F),
        ),
      ),
    );
  }
}