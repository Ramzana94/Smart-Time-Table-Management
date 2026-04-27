import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/controllers/timetable_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/widgets/timetable_filter_bar.dart';
import 'package:smart_timetable_managment/widgets/timetable_schedule_board.dart';


class TimeTableScreen extends StatelessWidget {
  TimeTableScreen({super.key});

  final NavigationController navCtrl = Get.find<NavigationController>();
  final AdminDashboardController adminCtrl =
      Get.find<AdminDashboardController>();
  final TimetableController timetableCtrl = Get.put(TimetableController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      body: SafeArea(
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

              if (allEntries.isEmpty) {
                return _TimetableStateCard(
                  icon: AppIcons.timetable,
                  title: 'No timetable entries yet',
                  subtitle:
                      'Your weekly schedule will appear here once classes are added.',
                  actionLabel: canManage ? 'Add Entry' : null,
                  onPressed: canManage ? adminCtrl.openCreateBottomSheet : null,
                );
              }

              final departmentOptions = timetableCtrl.departmentOptions(
                allEntries,
              );
              final selectedDepartment = timetableCtrl.resolveSelection(
                timetableCtrl.selectedDepartment.value,
                departmentOptions,
              );

              final semesterOptions = timetableCtrl.semesterOptions(
                allEntries,
                department: selectedDepartment,
              );
              final selectedSemester = timetableCtrl.resolveSelection(
                timetableCtrl.selectedSemester.value,
                semesterOptions,
              );

              final shiftOptions = timetableCtrl.shiftOptions(
                allEntries,
                department: selectedDepartment,
                semester: selectedSemester,
              );
              final selectedShift = timetableCtrl.resolveSelection(
                timetableCtrl.selectedShift.value,
                shiftOptions,
              );

              final filteredEntries = timetableCtrl.filterEntries(
                allEntries,
                department: selectedDepartment,
                semester: selectedSemester,
                shift: selectedShift,
              );

              final gridData = timetableCtrl.buildGrid(filteredEntries);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Timetable',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF12284A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${selectedDepartment ?? 'Department'} | Semester ${selectedSemester ?? '--'} | ${selectedShift ?? '--'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF61748E),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TimetableFilterBar(
                      departmentOptions: departmentOptions,
                      semesterOptions: semesterOptions,
                      shiftOptions: shiftOptions,
                      selectedDepartment: selectedDepartment,
                      selectedSemester: selectedSemester,
                      selectedShift: selectedShift,
                      onDepartmentChanged: timetableCtrl.updateDepartment,
                      onSemesterChanged: timetableCtrl.updateSemester,
                      onShiftChanged: timetableCtrl.updateShift,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _SummaryChip(
                          icon: Icons.calendar_view_week_outlined,
                          label:
                              '${timetableCtrl.totalSessions(filteredEntries)} sessions',
                        ),
                        _SummaryChip(
                          icon: Icons.apartment_outlined,
                          label: selectedDepartment ?? 'Department',
                        ),
                        _SummaryChip(
                          icon: Icons.school_outlined,
                          label: 'Semester ${selectedSemester ?? '--'}',
                        ),
                        _SummaryChip(
                          icon: Icons.schedule_outlined,
                          label: selectedShift ?? '--',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (gridData.isEmpty)
                      _TimetableStateCard(
                        icon: Icons.event_busy_outlined,
                        title: 'No classes found for this view',
                        subtitle: 'Try another department, semester, or shift.',
                        actionLabel: canManage ? 'Add Entry' : null,
                        onPressed: canManage
                            ? adminCtrl.openCreateBottomSheet
                            : null,
                      )
                    else
                      TimetableScheduleBoard(
                        gridData: gridData,
                        canManage: canManage,
                        onSlotTap: (entries) {
                          _showSlotDetails(entries, canManage);
                        },
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

        if (role == 'Teacher') {
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () {
              Get.snackbar('Teacher', 'Edit Timetable feature');
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          );
        }

        return const SizedBox.shrink();
      }),
    );
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
                    width: 52,
                    height: 4,
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
                                ? firstEntry.subject
                                : '${entries.length} sessions',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF12284A),
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DEEC),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFEF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
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
                      entry.subject,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        timetableCtrl.deleteTimetable(entry.id);
                        Get.back();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text(AppStrings.delete),
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

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E2F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF28415F),
            ),
          ),
        ],
      ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD8E2F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF12284A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF61748E),
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
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
          Text(
            entry.subject,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF12284A),
            ),
          ),
          const SizedBox(height: 10),
          _DetailRow(icon: Icons.person_outline_rounded, text: entry.teacher),
          _DetailRow(
            icon: Icons.meeting_room_outlined,
            text: entry.room.trim().isEmpty ? 'Room not assigned' : entry.room,
          ),
          _DetailRow(
            icon: Icons.apartment_outlined,
            text:
                '${entry.department} | Semester ${entry.semester} | ${entry.shift}',
          ),
          if (canManage && (onEdit != null || onDelete != null)) ...[
            const SizedBox(height: 12),
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
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 10),
                if (onDelete != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onDelete,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEFEF),
                        foregroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
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
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF324A67),
              ),
            ),
          ),
        ],
      ),
    );
  }
}