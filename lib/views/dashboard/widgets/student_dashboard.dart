import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/carousal_controller.dart';
import 'package:smart_timetable_managment/controllers/home_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/controllers/user_session_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

class StudentDashboard extends StatelessWidget {
  StudentDashboard({super.key});

  final HomeDashboardController homeCtrl = Get.find<HomeDashboardController>();
  final UserSessionController userSessionCtrl =
      Get.find<UserSessionController>();
  final FeatureCarouselController carouselCtrl =
      Get.find<FeatureCarouselController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (homeCtrl.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final userProfile = userSessionCtrl.currentUser.value;
        final userName = userProfile?.name ?? 'Student';

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.verticalSpace,
                // Greeting Section
                _GreetingSection(userName: userName),
                20.verticalSpace,

                // Smart Timetable Banner
                _SmartTimetableBanner(),
                15.verticalSpace,

                // Timetable Summary Cards
                // Row(
                //   children: [
                //     Expanded(
                //       child: CustomCard(
                //         title: AppStrings.totalClasses,
                //         value: '${homeCtrl.totalClasses}',
                //         icon: AppIcons.event_note,
                //         height: 60,
                //         accentColor: AppColors.primary,
                //       ),
                //     ),
                //     10.horizontalSpace,
                //     Expanded(
                //       child: CustomCard(
                //         title: "Today's Lectures",
                //         value: '${homeCtrl.todayLectures.length}',
                //         icon: AppIcons.timer,
                //         height: 72,
                //         accentColor: AppColors.primary,
                //       ),
                //     ),
                //   ],
                // ),
                // if (homeCtrl.homeNotice != null) ...[
                //   18.verticalSpace,
                //   DashboardMessageCard(message: homeCtrl.homeNotice!),
                // ],
                // 20.verticalSpace,
                // Card(
                //   elevation: 8,
                //   child: Padding(
                //     padding: const EdgeInsets.all(12),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.stretch,
                //       children: [
                //         CustomText(
                //           text: AppStrings.upComingLecture,
                //           fontSize: AppSizes.s18,
                //           fontWeight: AppWeights.bold,
                //         ),
                //         12.verticalSpace,
                //         if (homeCtrl.upcomingLectures.take(5).isEmpty)
                //           const Padding(
                //             padding: EdgeInsets.all(12),
                //             child: Text('No upcoming lectures found'),
                //           )
                //         else
                //           Column(
                //             children: homeCtrl.upcomingLectures.take(5).map((
                //               lecture,
                //             ) {
                //               return LectureCard(
                //                 title: lecture.courseTitle,
                //                 dayTime: '${lecture.day} • ${lecture.time}',
                //                 room: 'Room ${lecture.room}',
                //                 department:
                //                     '${lecture.department} • Semester ${lecture.semester}',
                //               );
                //             }).toList(),
                //           ),
                //       ],
                //     ),
                //   ),
                // ),
                // 15.verticalSpace,

                // Quick Access Section
                _QuickAccessSection(),
                15.verticalSpace,

                _FeatureCarouselSlider(),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Greeting Section with Avatar
class _GreetingSection extends StatelessWidget {
  final String userName;

  const _GreetingSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: AppStrings.goodMorning,
              fontSize: 26.sp,
              fontWeight: AppWeights.bold,
              color: AppColors.black,
            ),
            5.verticalSpace,
            CustomText(
              text: 'Welcome back, $userName',
              fontSize: 16.sp,
              fontWeight: AppWeights.w400,
              color: AppColors.grey,
            ),
          ],
        ),
        // Profile Avatar
        Container(
          width: 70.w,
          height: 70.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(AppIcons.person, size: 40.sp, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

// Smart Timetable Banner Card
class _SmartTimetableBanner extends StatelessWidget {
  const _SmartTimetableBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF5B7FFF), const Color(0xFF7B68EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B7FFF).withValues(alpha: .3),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle background
          Positioned(
            right: -30.w,
            bottom: -30.h,
            child: Container(
              width: 150.w,
              height: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Timetable',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      12.verticalSpace,
                      Text(
                        'Your schedule, simplified.\nStay organized and\nachieve more.',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: .95),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: Center(child: _GraduationCapIcon())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Graduation Cap Icon
class _GraduationCapIcon extends StatelessWidget {
  const _GraduationCapIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.school,
      size: 80.sp,
      color: AppColors.black,
      //  Colors.white.withValues(alpha: .3),
    );
  }
}

// Quick Access Section
class _QuickAccessSection extends StatelessWidget {
  _QuickAccessSection();

  final NavigationController navCtrl = Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        16.verticalSpace,
        Row(
          children: [
            // Timetable Card
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.calendar_today,
                iconBackgroundColor: const Color(0xFFE8F0FF),
                iconColor: AppColors.primary,
                title: 'Timetable',
                subtitle: 'View full timetable',
                onTap: () => navCtrl.changeIndex(1),
              ),
            ),
            12.horizontalSpace,
            // Profile Card
            Expanded(
              child: _QuickAccessCard(
                icon: AppIcons.person_outline,
                iconBackgroundColor: const Color(0xFFE8F8F0),
                iconColor: const Color(0xFF26B890),
                title: 'Profile',
                subtitle: 'Manage your account',
                onTap: () => navCtrl.changeIndex(2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Individual Quick Access Card
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          child: Column(
            children: [
              // Icon Container
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36.sp, color: iconColor),
              ),
              16.verticalSpace,
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              6.verticalSpace,
              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Feature Carousel Slider with Auto-scroll
class _FeatureCarouselSlider extends StatelessWidget {
  const _FeatureCarouselSlider();

  @override
  Widget build(BuildContext context) {
    final carouselCtrl = Get.find<FeatureCarouselController>();

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: carouselCtrl.carouselController,
          itemCount: carouselCtrl.features.length,
          itemBuilder: (context, index, realIndex) {
            final feature = carouselCtrl.features[index];

            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                // boxShadow: [
                //   // BoxShadow(
                //   //   color: Colors.black.withValues(alpha: .08),
                //   //   blurRadius: 12,
                //   //   offset: const Offset(0, 4),
                //   // ),
                // ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FF),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        _getIcon(feature['icon'] ?? ''),
                        size: 40.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            feature['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          6.verticalSpace,
                          Text(
                            feature['description'] ?? '',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF888888),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 180.h,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              carouselCtrl.updateIndex(index);
            },
          ),
        ),
        12.verticalSpace,
        // Obx(() {
        //   return Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: List.generate(
        //       carouselCtrl.features.length,
        //       (dotIndex) => GestureDetector(
        //         onTap: () => carouselCtrl.goToPage(dotIndex),
        //         child: AnimatedContainer(
        //           duration: const Duration(milliseconds: 250),
        //           width: carouselCtrl.currentIndex.value == dotIndex
        //               ? 28.w
        //               : 10.w,
        //           height: 8.h,
        //           margin: EdgeInsets.symmetric(horizontal: 3.w),
        //           decoration: BoxDecoration(
        //             color: carouselCtrl.currentIndex.value == dotIndex
        //                 ? AppColors.primary
        //                 : const Color(0xFFD9D9D9),
        //             borderRadius: BorderRadius.circular(4.r),
        //           ),
        //         ),
        //       ),
        //     ),
        //   );
        // }),
      ],
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'checklist_rtl':
        return Icons.checklist_rtl;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'calendar_month':
        return Icons.calendar_month;
      default:
        return Icons.info;
    }
  }
}