import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/carousal_controller.dart';
import 'package:smart_timetable_managment/controllers/home_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';

class StudentDashboard extends StatelessWidget {
  StudentDashboard({super.key});

  final HomeDashboardController homeCtrl = Get.find<HomeDashboardController>();
  final NavigationController navCtrl = Get.find<NavigationController>();
  final FeatureCarouselController carouselController = Get.find<FeatureCarouselController>();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8F9FF),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 380;
            final horizontalPadding = isCompact ? 20.0 : 24.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28,
                horizontalPadding,
                24,
              ),
              child: Obx(() {
                final profileImageUrl = homeCtrl.userProfile?.image.trim();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingHeader(profileImageUrl: profileImageUrl),
                    const SizedBox(height: 30),

                    const _SmartTimetableBanner(),
                    const SizedBox(height: 30),

                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        color: Color(0xFF1C1C27),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _QuickAccessCard(
                            icon: AppIcons.event_note,
                            iconColor: AppColors.primary,
                            bubbleColor: const Color(0xFFECEFFF),
                            title: 'Timetable',
                            subtitle: 'View your timetable',
                            onTap: () => navCtrl.changeIndex(1),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _QuickAccessCard(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF27C49A),
                            bubbleColor: const Color(0xFFE0F9EF),
                            title: 'Profile',
                            subtitle: 'Manage your account',
                            onTap: () => navCtrl.changeIndex(3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const _FeatureCarouselSlider(),
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/* ---------------- HEADER ---------------- */

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.profileImageUrl});
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171724),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome back, Student',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF737381),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ProfileAvatar(imageUrl: profileImageUrl),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E4EF)),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(imageUrl!, fit: BoxFit.cover)
            : const Icon(Icons.person, size: 40, color: AppColors.primary),
      ),
    );
  }
}

/* ---------------- BANNER ---------------- */

class _SmartTimetableBanner extends StatelessWidget {
  const _SmartTimetableBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4974F3), Color(0xFF7362E9)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 40,
            child: Icon(
              Icons.school,
              size: 80,
              color: Colors.black,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 120, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Timetable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Your schedule, simplified.\nStay organized and achieve more.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- QUICK ACCESS ---------------- */

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.iconColor,
    required this.bubbleColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color bubbleColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: bubbleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 34),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- FEATURE CAROUSEL (FIXED) ---------------- */
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselCtrl.features.length,
              (dotIndex) => GestureDetector(
                onTap: () => carouselCtrl.goToPage(dotIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: carouselCtrl.currentIndex.value == dotIndex
                      ? 28.w
                      : 10.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: carouselCtrl.currentIndex.value == dotIndex
                        ? AppColors.primary
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          );
        }),
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