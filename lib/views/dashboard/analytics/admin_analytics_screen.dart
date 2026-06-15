import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_analytics_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/models/admin_analytics_model.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminAnalyticsController>();
    final metricWidth = _metricCardWidth(context);

    return Obx(() {
      final departmentItems = controller.departmentAnalytics;
      final teacherItems = controller.teacherWorkloads;
      final roomItems = controller.roomAvailability;
      final hasNoRecords =
          controller.isReady &&
          controller.totalClasses == 0 &&
          controller.overallTeachers == 0 &&
          controller.overallDepartments == 0;
      final hasNoFilteredSessions =
          controller.isReady &&
          controller.totalClasses == 0 &&
          (controller.overallTeachers > 0 || controller.overallDepartments > 0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnalyticsHeroCard(
            totalClasses: controller.totalClasses,
            activeDays: controller.activeDaysCount,
            assignmentRate: controller.roomAssignmentRate,
            peakDepartment: controller.peakDepartmentLabel,
            busiestDay: controller.busiestDayLabel,
          ),
          const SizedBox(height: 18),
          _AnalyticsFilterCard(
            dayOptions: controller.dayOptions,
            shiftOptions: controller.shiftOptions,
            selectedDay: controller.selectedDay.value,
            selectedShift: controller.selectedShift.value,
            onDaySelected: controller.updateDay,
            onShiftSelected: controller.updateShift,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                width: metricWidth,
                title: 'Classes',
                value: '${controller.totalClasses}',
                subtitle: 'Live timetable entries',
                icon: Icons.calendar_month_outlined,
                accentColor: const Color(0xFF0F8A83),
              ),
              _MetricCard(
                width: metricWidth,
                title: 'Teachers',
                value: '${controller.activeTeachers}',
                subtitle: 'Active in current filter',
                icon: Icons.groups_2_outlined,
                accentColor: const Color(0xFFCE7B1D),
              ),
              _MetricCard(
                width: metricWidth,
                title: 'Departments',
                value: '${controller.activeDepartments}',
                subtitle: 'Departments in view',
                icon: Icons.apartment_outlined,
                accentColor: const Color(0xFF6B5AED),
              ),
              _MetricCard(
                width: metricWidth,
                title: 'Rooms',
                value: '${controller.totalRooms}',
                subtitle: '${controller.unassignedRoomCount} unassigned slots',
                icon: Icons.meeting_room_outlined,
                accentColor: const Color(0xFFDB4E62),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!controller.isReady)
            const _AnalyticsStateCard(
              title: 'Syncing analytics',
              subtitle:
                  'Live departments, teachers, rooms, and classes will appear here once Firestore data is ready.',
              icon: Icons.query_stats_outlined,
            )
          else if (hasNoRecords)
            const _AnalyticsStateCard(
              title: 'No analytics yet',
              subtitle:
                  'Add departments, teachers, and timetable entries to start tracking workload and room availability.',
              icon: Icons.insights_outlined,
            )
          else if (hasNoFilteredSessions)
            const _AnalyticsStateCard(
              title: 'No classes for this filter',
              subtitle:
                  'Try another day or shift to inspect class distribution, teacher workload, and room availability.',
              icon: Icons.filter_alt_off_outlined,
            )
          else ...[
            _SectionCard(
              title: 'Class Distribution',
              subtitle: 'Department-wise session load with teachers and rooms',
              child: Column(
                children: departmentItems
                    .take(6)
                    .map((item) => _DepartmentAnalyticsTile(item: item))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Teacher Workload',
              subtitle: 'Who is available, balanced, or carrying more classes',
              child: Column(
                children: teacherItems
                    .take(6)
                    .map((item) => _TeacherWorkloadTile(item: item))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Room Availability',
              subtitle:
                  'Availability is calculated from the active day/time slots in the current filter, including rooms with zero bookings',
              child: roomItems.isEmpty
                  ? const _InlineEmptyState(
                      title: 'No rooms assigned',
                      subtitle:
                          'Assign a room to timetable entries to monitor availability here.',
                    )
                  : Column(
                      children: roomItems
                          .take(6)
                          .map((item) => _RoomAvailabilityTile(item: item))
                          .toList(),
                    ),
            ),
          ],
        ],
      );
    });
  }

  double _metricCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 52;
    if (availableWidth < 420) {
      return (availableWidth - 12) / 2;
    }
    return (availableWidth - 24) / 3;
  }
}

class _AnalyticsHeroCard extends StatelessWidget {
  final int totalClasses;
  final int activeDays;
  final double assignmentRate;
  final String peakDepartment;
  final String busiestDay;

  const _AnalyticsHeroCard({
    required this.totalClasses,
    required this.activeDays,
    required this.assignmentRate,
    required this.peakDepartment,
    required this.busiestDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF12304E), Color(0xFF1E6C7A), Color(0xFF5AA678)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E12304E),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_graph_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Live scheduling intelligence',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Analytics for classes, teachers, and room coverage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$totalClasses classes across $activeDays active days with ${(assignmentRate * 100).round()}% room assignment.',
            style: const TextStyle(
              color: Color(0xFFD7EBE8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroInfoPill(
                icon: Icons.local_fire_department_outlined,
                label: 'Peak dept',
                value: peakDepartment,
              ),
              _HeroInfoPill(
                icon: Icons.today_outlined,
                label: 'Busiest day',
                value: busiestDay,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroInfoPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFCCE2E2),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsFilterCard extends StatelessWidget {
  final List<String> dayOptions;
  final List<String> shiftOptions;
  final String selectedDay;
  final String selectedShift;
  final ValueChanged<String> onDaySelected;
  final ValueChanged<String> onShiftSelected;

  const _AnalyticsFilterCard({
    required this.dayOptions,
    required this.shiftOptions,
    required this.selectedDay,
    required this.selectedShift,
    required this.onDaySelected,
    required this.onShiftSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE4F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter analytics',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12284A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Switch day and shift views to inspect load patterns instantly.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF61748E),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _FilterGroup(
            title: 'Day',
            options: dayOptions,
            selectedValue: selectedDay,
            onSelected: onDaySelected,
          ),
          const SizedBox(height: 14),
          _FilterGroup(
            title: 'Shift',
            options: shiftOptions,
            selectedValue: selectedShift,
            onSelected: onShiftSelected,
          ),
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _FilterGroup({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF34506F),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;

            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFDCE4F1),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF46617F),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final double width;

  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE4F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12284A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243D5B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF61748E),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE4F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12284A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF61748E),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DepartmentAnalyticsTile extends StatelessWidget {
  final DepartmentAnalyticsItem item;

  const _DepartmentAnalyticsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E9F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.department.depName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF12284A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.department.depCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF61748E),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${item.sessionCount} classes',
                  style: const TextStyle(
                    color: Color(0xFF157347),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: item.share.clamp(0, 1),
              backgroundColor: const Color(0xFFE4EBF4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0F8A83),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniTag(
                icon: Icons.groups_outlined,
                label: '${item.teacherCount} teachers',
              ),
              _MiniTag(
                icon: Icons.meeting_room_outlined,
                label: '${item.roomCount} rooms',
              ),
              _MiniTag(
                icon: Icons.pie_chart_outline_rounded,
                label: '${(item.share * 100).round()}% share',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeacherWorkloadTile extends StatelessWidget {
  final TeacherWorkloadItem item;

  const _TeacherWorkloadTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final loadColor = switch (item.loadLabel) {
      'High load' => const Color(0xFFDB4E62),
      'Balanced' => const Color(0xFF0F8A83),
      'Light load' => const Color(0xFFCE7B1D),
      _ => const Color(0xFF57708E),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E9F4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FB),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              item.teacher.teacherName.isEmpty
                  ? '?'
                  : item.teacher.teacherName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.teacher.teacherName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF12284A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: loadColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.loadLabel,
                        style: TextStyle(
                          color: loadColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.teacher.teacherDept,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF61748E),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MiniTag(
                      icon: Icons.calendar_view_week_outlined,
                      label: '${item.sessionCount} classes',
                    ),
                    _MiniTag(
                      icon: Icons.today_outlined,
                      label: '${item.activeDays} active days',
                    ),
                    _MiniTag(
                      icon: Icons.meeting_room_outlined,
                      label: '${item.assignedRooms} rooms',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomAvailabilityTile extends StatelessWidget {
  final RoomAvailabilityItem item;

  const _RoomAvailabilityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final availabilityRate = 1 - item.utilizationRate;
    final statusLabel = item.bookedSlots == 0
        ? 'Fully free'
        : '${(availabilityRate * 100).round()}% available';
    final statusColor = item.bookedSlots == 0
        ? const Color(0xFF157347)
        : const Color(0xFF0F8A83);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E9F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.roomName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF12284A),
                  ),
                ),
              ),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: availabilityRate.clamp(0, 1),
              backgroundColor: const Color(0xFFE4EBF4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0F8A83),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniTag(
                icon: Icons.event_available_outlined,
                label: '${item.availableSlots} free slots',
              ),
              _MiniTag(
                icon: Icons.event_busy_outlined,
                label: '${item.bookedSlots} booked slots',
              ),
              _MiniTag(
                icon: Icons.today_outlined,
                label: '${item.activeDays} active days',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE4F1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF5C7694)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF38526F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AnalyticsStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE4F1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 18),
          CustomText(
            text: title,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF12284A),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: subtitle,
            fontSize: 14,
            color: const Color(0xFF61748E),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InlineEmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E9F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12284A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF61748E),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}