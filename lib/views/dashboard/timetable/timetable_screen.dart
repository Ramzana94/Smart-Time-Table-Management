import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/home_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/controllers/timetable_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/services/pdf_service.dart';
import 'package:smart_timetable_managment/core/utils/app_snack_bar.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/views/dashboard/timetable/components/summary_chip.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/timetable_schedule_board.dart';
class TimeTableScreen extends StatelessWidget {
  TimeTableScreen({super.key});

  final NavigationController navCtrl = Get.find<NavigationController>();
  final AdminDashboardController adminCtrl =
      Get.find<AdminDashboardController>();
  final HomeDashboardController homeCtrl = Get.find<HomeDashboardController>();
  final TimetableController timetableCtrl = Get.find<TimetableController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<TimetableModel>>(
          stream: timetableCtrl.getTimetable(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const _TimetableStateCard(
                icon: Icons.error_outline_rounded,
                title: 'Unable to load timetable',
                subtitle: 'Please try again in a moment.',
              );
            }

            final allEntries = snapshot.data ?? const <TimetableModel>[];

            return Obx(() {
              final role = navCtrl.userRole.value.trim();
              final canManage = role == 'Admin';
              final baseEntries = canManage
                  ? allEntries
                  : homeCtrl.visibleTimetableEntries(allEntries);

              final departmentOptions = timetableCtrl.departmentOptions(
                baseEntries,
              );
              final activeDepartment = timetableCtrl.validSelectionOrNull(
                timetableCtrl.selectedDepartment.value,
                departmentOptions,
              );
              final semesterOptions = timetableCtrl.semesterOptions(
                baseEntries,
                department: activeDepartment,
              );
              final activeSemester = timetableCtrl.validSelectionOrNull(
                timetableCtrl.selectedSemester.value,
                semesterOptions,
              );
              final shiftOptions = timetableCtrl.shiftOptions(
                baseEntries,
                department: activeDepartment,
                semester: activeSemester,
              );
              final activeShift = timetableCtrl.validSelectionOrNull(
                timetableCtrl.selectedShift.value,
                shiftOptions,
              );

              final filteredEntries = timetableCtrl.filterEntries(
                baseEntries,
                department: activeDepartment,
                semester: activeSemester,
                shift: activeShift,
              );
              if (!canManage && homeCtrl.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (allEntries.isEmpty) {
                return _TimetableStateCard(
                  icon: AppIcons.timetable,
                  title: 'Timetable not found',
                  subtitle: canManage
                      ? 'No timetable has been added yet.'
                      : 'No timetable was found for this account.',
                  actionLabel: canManage ? 'Add Entry' : null,
                  onPressed: canManage ? adminCtrl.openCreateBottomSheet : null,
                );
              }

              if (role == 'Teacher' || role == 'Student') {
                final gridData = timetableCtrl.buildGrid(filteredEntries);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: role == 'Teacher'
                            ? 'Teaching Timetable'
                            : 'Student Timetable',
                        fontSize: AppSizes.s26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      CustomText(
                        text: homeCtrl.headerSubtitle,
                        fontSize: AppSizes.s14,
                        color: Color(0xFF61748E),
                      ),
                      4.verticalSpace,
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SummaryChip(
                            icon: AppIcons.calendar_view_week_outlined,
                            label:
                                '${timetableCtrl.totalSessions(filteredEntries)} sessions',
                          ),

                          SummaryChip(
                            icon: AppIcons.apartment_outlined,
                            label: activeDepartment ?? 'Department',
                          ),
                          SummaryChip(
                            icon: AppIcons.school_outlined,
                            label: activeSemester != null
                                ? 'Semester $activeSemester'
                                : 'Semester',
                          ),
                          SummaryChip(
                            icon: AppIcons.schedule_outlined,
                            label: activeShift ?? 'Shift',
                          ),
                        ],
                      ),

                      20.verticalSpace,
                      if (gridData.isEmpty)
                        _TimetableStateCard(
                          icon: AppIcons.event_busy_outlined,
                          title: 'Timetable not found',
                          subtitle: role == 'Student'
                              ? 'No timetable was found for students.'
                              : homeCtrl.homeNotice ??
                                    'No timetable was found for this teacher.',
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () async {
                              _downloadTimetablePdf(
                                gridData: gridData,
                                department: activeDepartment,
                                semester: activeSemester,
                                shift: activeShift,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Color(0xFF10B981),
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: Icon(AppIcons.download_outlined),
                            label: CustomText(
                              text: AppStrings.downloadPdf,
                              color: AppColors.white,
                              fontSize: AppSizes.s14,
                              fontWeight: AppWeights.w500,
                            ),
                          ),
                        ),
                      10.verticalSpace,
                      TimetableScheduleBoard(
                        gridData: gridData,
                        canManage: false,
                        onSlotTap: (entries) {
                          _showSlotDetails(entries, false);
                        },
                      ),
                    ],
                  ),
                );
              }

              final gridData = timetableCtrl.buildGrid(filteredEntries);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: AppStrings.weeklyTimetable,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF12284A),
                    ),
                    18.verticalSpace,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SummaryChip(
                          icon: AppIcons.calendar_view_week_outlined,
                          label:
                              '${timetableCtrl.totalSessions(filteredEntries)} sessions',
                        ),
                        if (canManage) ...[
                          SummaryChip(
                            icon: AppIcons.apartment_outlined,
                            label: activeDepartment ?? 'Department',
                          ),
                          SummaryChip(
                            icon: AppIcons.school_outlined,

                            label: activeSemester != null
                                ? 'Semester $activeSemester'
                                : 'Semester',
                          ),
                          SummaryChip(
                            icon: AppIcons.schedule_outlined,
                            label: activeShift ?? 'Shift',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (gridData.isEmpty)
                      _TimetableStateCard(
                        icon: AppIcons.event_busy_outlined,
                        title: 'Timetable not found',
                        subtitle:
                            'No timetable matches the current department, semester, or shift.',
                        actionLabel: canManage ? 'Add Entry' : null,
                        onPressed: canManage
                            ? adminCtrl.openCreateBottomSheet
                            : null,
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () async {
                                _downloadTimetablePdf(
                                  gridData: gridData,
                                  department: activeDepartment,
                                  semester: activeSemester,
                                  shift: activeShift,
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Icon(AppIcons.download_outlined),
                              label: Text('Download as PDF'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TimetableScheduleBoard(
                            gridData: gridData,
                            canManage: canManage,
                            onSlotTap: (entries) {
                              _showSlotDetails(entries, canManage);
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              );
            });
          },
        ),
      ),
      floatingActionButton: Obx(() {
        final role = navCtrl.userRole.value.trim();

        if (role == 'Admin') {
          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: AppColors.primary,
            onPressed: adminCtrl.openCreateBottomSheet,
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _downloadTimetablePdf({
    required dynamic gridData,
    String? department,
    String? semester,
    String? shift,
  }) async {
    try {
      _showLoading();
      final pdfService = PdfService();
      final subtitle =
          '${department ?? 'All Departments'} | Semester ${semester ?? 'All'} | ${shift ?? 'All Shifts'}';

      await pdfService.generateAndDownloadTimetable(
        gridData: gridData,
        title: 'Weekly Timetable',
        subtitle: subtitle,
      );
      _hideLoading();
      AppSnackbar.success('Success', 'Timetable PDF downloaded successfully');
    } catch (e) {
      AppSnackbar.error('Error', 'Failed to download PDF: $e');
    } finally {
      _hideLoading();
    }
  }

  void _showSlotDetails(List<TimetableModel> entries, bool canManage) {
    final firstEntry = entries.first;

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6DEEC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entries.length == 1
                                ? firstEntry.courseTitle
                                : '${entries.length} sessions',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${firstEntry.day} | ${firstEntry.time}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF61748E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF2F6FC),
                        foregroundColor: const Color(0xFF496483),
                      ),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TimetableDetailCard(
                      entry: entry,
                      canManage: canManage,
                      onEdit: canManage
                          ? () {
                              _openTimetableEdit(entry);
                            }
                          : null,
                      onDelete: canManage
                          ? () {
                              _openDeletePrompt(entry);
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _openTimetableEdit(TimetableModel entry) {
    Get.back();
    Future.delayed(const Duration(milliseconds: 160), () {
      adminCtrl.openEditTimetableBottomSheet(entry);
    });
  }

  void _openDeletePrompt(TimetableModel entry) {
    Get.back();
    Future.delayed(const Duration(milliseconds: 160), () {
      _confirmDelete(entry);
    });
  }

  void _confirmDelete(TimetableModel entry) {
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DEEC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 56.h,
                width: 56.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFEF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  AppIcons.delete_outline_rounded,
                  color: AppColors.red,
                  size: 28,
                ),
              ),
              18.verticalSpace,
              const Text(
                AppStrings.deleteTimetableEntry,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF12284A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.deleteTimetableWarning,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF61748E),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1E9F5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.courseTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF12284A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${entry.day} | ${entry.time}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF61748E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        timetableCtrl.deleteTimetable(entry.id);
                        Get.back();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(AppIcons.delete_outline_rounded),
                      label: CustomText(text: AppStrings.delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _TimetableStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onPressed;

  const _TimetableStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD8E2F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60.h,
              width: 60.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            18.verticalSpace,
            CustomText(
              text: title,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12284A),
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            CustomText(
              text: subtitle,
              fontSize: AppSizes.s14,
              // height: 1.5,
              color: Color(0xFF61748E),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onPressed != null) ...[
              18.verticalSpace,
              FilledButton.icon(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(AppIcons.add_rounded),
                label: CustomText(text: actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimetableDetailCard extends StatelessWidget {
  final TimetableModel entry;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TimetableDetailCard({
    required this.entry,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E9F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: entry.courseTitle,
            fontSize: AppSizes.s16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            //  Color(0xFF12284A),
          ),
          10.verticalSpace,
          _DetailRow(icon: Icons.quiz, text: entry.courseCode),
          _DetailRow(
            icon: AppIcons.person_outline_rounded,
            text: entry.teacher,
          ),
          _DetailRow(
            icon: AppIcons.meeting_room_outlined,
            text: entry.room.trim().isEmpty ? 'Room not assigned' : entry.room,
          ),
          _DetailRow(
            icon: AppIcons.apartment_outlined,
            text:
                '${entry.department} | Semester ${entry.semester} | ${entry.shift}',
          ),
          if (canManage && (onEdit != null || onDelete != null)) ...[
            12.verticalSpace,
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0xFFD5E0F0)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(AppIcons.edit_outlined, size: AppSizes.s18),
                      label: CustomText(text: AppStrings.edit),
                    ),
                  ),
                if (onEdit != null && onDelete != null) 10.horizontalSpace,
                if (onDelete != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onDelete,
                      style: FilledButton.styleFrom(
                        backgroundColor: Color(0xFFFFEFEF),
                        foregroundColor: AppColors.red,
                        padding: EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        AppIcons.delete_outline_rounded,
                        size: AppSizes.s18,
                      ),
                      label: CustomText(text: AppStrings.delete),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF6B7D96)),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              text: text,
              fontSize: AppSizes.s14,
              color: AppColors.primary,
            ),
            // Text(
            //   text,
            //   style: const TextStyle(
            //     fontSize: 14,
            //     height: 1.45,
            //     color: Color(0xFF324A67),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}

void _showLoading() {
  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    // barrierDismissible: false,
  );
}

void _hideLoading() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
  }
}