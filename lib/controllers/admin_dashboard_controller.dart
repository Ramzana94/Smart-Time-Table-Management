import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/services/department_service.dart';
import 'package:smart_timetable_managment/core/services/teacher_service.dart';
import 'package:smart_timetable_managment/core/services/timetable_service.dart';
import 'package:smart_timetable_managment/core/utils/app_snack_bar.dart';
import 'package:smart_timetable_managment/models/department_model.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_dropdown.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';


class AdminDashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final DepartmentService _departmentService = DepartmentService();
  final TeacherService _teacherService = TeacherService();
  final TimetableService _timetableService = TimetableService();

  final ValueNotifier<String?> dayNotifier = ValueNotifier(null);
  final ValueNotifier<TeacherModel?> timetableTeacherNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<DepartmentModel?> timetableDepartmentNotifier =
      ValueNotifier(null);
  final ValueNotifier<DepartmentModel?> teacherDepartmentNotifier =
      ValueNotifier(null);
  final ValueNotifier<String?> semesterNotifier = ValueNotifier(null);
  final ValueNotifier<String?> shiftNotifier = ValueNotifier(null);

  final startTime = ''.obs;
  final endTime = ''.obs;
  final currentTabIndex = 0.obs;

  final subjectController = TextEditingController();
  final roomController = TextEditingController();
  final deptController = TextEditingController();
  final deptCodeController = TextEditingController();
  final descriptionController = TextEditingController();
  final teacherNameController = TextEditingController();
  final teacherEmailController = TextEditingController();
  final teacherPhoneController = TextEditingController();
  final teacherSpecializationController = TextEditingController();

  final days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];
  final shifts = ["Morning", "Evening"];

  late final TabController tabController;

  Stream<List<DepartmentModel>> get departmentsStream =>
      _departmentService.getDepartments();

  Stream<List<TeacherModel>> get teachersStream =>
      _teacherService.getTeachers();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: currentTabIndex.value,
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    dayNotifier.dispose();
    timetableTeacherNotifier.dispose();
    timetableDepartmentNotifier.dispose();
    teacherDepartmentNotifier.dispose();
    semesterNotifier.dispose();
    shiftNotifier.dispose();
    subjectController.dispose();
    roomController.dispose();
    deptController.dispose();
    deptCodeController.dispose();
    descriptionController.dispose();
    teacherNameController.dispose();
    teacherEmailController.dispose();
    teacherPhoneController.dispose();
    teacherSpecializationController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> deleteTeacher(String id) async {
    await _teacherService.deleteTeacher(id);
  }

  Future<void> deleteDepartment(String id) async {
    await _departmentService.deleteDepartment(id);
  }

  void resetTimetableForm() {
    subjectController.clear();
    roomController.clear();
    startTime.value = '';
    endTime.value = '';
    dayNotifier.value = null;
    timetableTeacherNotifier.value = null;
    timetableDepartmentNotifier.value = null;
    semesterNotifier.value = null;
    shiftNotifier.value = null;
  }

  void resetDepartmentForm() {
    deptController.clear();
    deptCodeController.clear();
    descriptionController.clear();
  }

  void resetTeacherForm() {
    teacherNameController.clear();
    teacherEmailController.clear();
    teacherPhoneController.clear();
    teacherSpecializationController.clear();
    teacherDepartmentNotifier.value = null;
  }

  void _syncSelectedTeacher(List<TeacherModel> teachers) {
    final selectedTeacher = timetableTeacherNotifier.value;
    if (selectedTeacher != null && !teachers.contains(selectedTeacher)) {
      timetableTeacherNotifier.value = null;
    }
  }

  void _syncSelectedDepartment(
    ValueNotifier<DepartmentModel?> notifier,
    List<DepartmentModel> departments,
  ) {
    final selectedDepartment = notifier.value;
    if (selectedDepartment != null &&
        !departments.contains(selectedDepartment)) {
      notifier.value = null;
    }
  }

  DepartmentModel? _findDepartmentByIdOrName(
    List<DepartmentModel> departments, {
    String? departmentId,
    String? departmentName,
  }) {
    for (final department in departments) {
      if (departmentId != null &&
          departmentId.isNotEmpty &&
          department.id == departmentId) {
        return department;
      }
    }

    for (final department in departments) {
      if (departmentName != null &&
          departmentName.isNotEmpty &&
          department.depName == departmentName) {
        return department;
      }
    }

    return null;
  }

  TeacherModel? _findTeacherByIdOrName(
    List<TeacherModel> teachers, {
    String? teacherId,
    String? teacherName,
  }) {
    for (final teacher in teachers) {
      if (teacherId != null &&
          teacherId.isNotEmpty &&
          teacher.id == teacherId) {
        return teacher;
      }
    }

    for (final teacher in teachers) {
      if (teacherName != null &&
          teacherName.isNotEmpty &&
          teacher.teacherName == teacherName) {
        return teacher;
      }
    }

    return null;
  }

  void _setTimeRangeFromValue(String timeRange) {
    final parts = timeRange
        .split('-')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      startTime.value = parts.first;
      endTime.value = parts.sublist(1).join(' - ');
      return;
    }

    startTime.value = '';
    endTime.value = '';
  }

  TimetableModel? _buildTimetableModel() {
    final selectedTeacher = timetableTeacherNotifier.value;
    final selectedDepartment = timetableDepartmentNotifier.value;
    final selectedDay = dayNotifier.value;
    final selectedSemester = semesterNotifier.value;
    final selectedShift = shiftNotifier.value;

    if (selectedTeacher == null ||
        selectedDepartment == null ||
        selectedDay == null ||
        selectedSemester == null ||
        selectedShift == null) {
      AppSnackbar.error("Error", "Please complete the timetable details");
      return null;
    }

    return TimetableModel(
      day: selectedDay,
      time: "${startTime.value} - ${endTime.value}",
      subject: subjectController.text.trim(),
      teacher: selectedTeacher.teacherName,
      teacherId: selectedTeacher.id,
      room: roomController.text.trim(),
      department: selectedDepartment.depName,
      departmentId: selectedDepartment.id,
      semester: selectedSemester,
      shift: selectedShift,
    );
  }

  Widget _buildBottomSheetContainer({
    required Widget child,
    double radius = 20,
  }) {
    final context = Get.context!;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildBottomSheetActions({
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomMaterialButton(
            borderColor: AppColors.primary,
            onPressed: () {
              Get.back();
            },
            text: AppStrings.cancel,
            color: AppColors.white,
            borderRadius: 10,
            height: 57.h,
            textColor: AppColors.primary,
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: CustomMaterialButton(
            onPressed: onConfirm,
            text: confirmText,
            color: AppColors.primary,
            borderRadius: 10,
            height: 57.h,
            textColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  void openCreateBottomSheet() {
    resetTimetableForm();
    _showTimetableBottomSheet(
      title: AppStrings.addTimetableEntry,
      subtitle: AppStrings.CreateTimetableEntry,
      confirmText: AppStrings.save,
      onSubmit: () {
        saveData();
      },
    );
  }

  Future<void> openEditTimetableBottomSheet(TimetableModel timetable) async {
    resetTimetableForm();
    subjectController.text = timetable.subject;
    roomController.text = timetable.room;
    dayNotifier.value = timetable.day;
    semesterNotifier.value = timetable.semester;
    shiftNotifier.value = timetable.shift;
    _setTimeRangeFromValue(timetable.time);

    final teachers = await teachersStream.first;
    final departments = await departmentsStream.first;

    timetableTeacherNotifier.value = _findTeacherByIdOrName(
      teachers,
      teacherId: timetable.teacherId,
      teacherName: timetable.teacher,
    );
    timetableDepartmentNotifier.value = _findDepartmentByIdOrName(
      departments,
      departmentId: timetable.departmentId,
      departmentName: timetable.department,
    );

    _showTimetableBottomSheet(
      title: AppStrings.editTimetableEntry,
      subtitle: AppStrings.updateTimetableEntry,
      confirmText: AppStrings.saveChanges,
      onSubmit: () {
        updateTimetable(timetable.id);
      },
    );
  }

  void _showTimetableBottomSheet({
    required String title,
    required String subtitle,
    required String confirmText,
    required VoidCallback onSubmit,
  }) {
    Get.bottomSheet(
      _buildBottomSheetContainer(
        radius: 25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: title,
              fontSize: AppSizes.s20,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomText(text: subtitle, color: AppColors.grey),
            20.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        isRequired: true,
                        text: AppStrings.day,
                        fontSize: AppSizes.s14,
                        fontWeight: AppWeights.bold,
                      ),
                      5.verticalSpace,
                      CustomDropdown<String>(
                        items: days,
                        valueListenable: dayNotifier,
                        hintText: AppStrings.dayHint,
                        itemLabel: (item) => item,
                        onChanged: (value) {
                          dayNotifier.value = value;
                        },
                      ),
                    ],
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        isRequired: true,
                        text: AppStrings.time,
                        fontSize: AppSizes.s14,
                        fontWeight: AppWeights.bold,
                      ),
                      5.verticalSpace,
                      buildTimeRange(),
                    ],
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.subject,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            8.verticalSpace,
            CustomTextFormField(
              borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.subjectHint,
              controller: subjectController,
            ),
            8.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.teacher,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            8.verticalSpace,
            StreamBuilder<List<TeacherModel>>(
              stream: teachersStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final teacherList = snapshot.data!;
                _syncSelectedTeacher(teacherList);

                return CustomDropdown<TeacherModel>(
                  items: teacherList,
                  itemLabel: (item) => item.teacherName,
                  valueListenable: timetableTeacherNotifier,
                  hintText: AppStrings.teacherNameHint,
                  onChanged: (value) {
                    timetableTeacherNotifier.value = value;
                  },
                );
              },
            ),
            8.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.room,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            8.verticalSpace,
            CustomTextFormField(
              borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.roomHint,
              controller: roomController,
            ),
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        isRequired: true,
                        text: AppStrings.dept,
                        fontSize: AppSizes.s14,
                        fontWeight: AppWeights.bold,
                      ),
                      5.verticalSpace,
                      StreamBuilder<List<DepartmentModel>>(
                        stream: departmentsStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final departmentList = snapshot.data!;
                          _syncSelectedDepartment(
                            timetableDepartmentNotifier,
                            departmentList,
                          );

                          return CustomDropdown<DepartmentModel>(
                            items: departmentList,
                            itemLabel: (item) => item.depName,
                            valueListenable: timetableDepartmentNotifier,
                            onChanged: (value) {
                              timetableDepartmentNotifier.value = value;
                            },
                            hintText: AppStrings.teacherDeptHint,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        isRequired: true,
                        text: AppStrings.semester,
                        fontSize: AppSizes.s14,
                        fontWeight: AppWeights.bold,
                      ),
                      5.verticalSpace,
                      CustomDropdown<String>(
                        items: semesters,
                        valueListenable: semesterNotifier,
                        hintText: AppStrings.semesterHint,
                        itemLabel: (item) => item,
                        onChanged: (value) {
                          semesterNotifier.value = value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            10.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.shift,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            8.verticalSpace,
            CustomDropdown<String>(
              width: double.infinity,
              items: shifts,
              valueListenable: shiftNotifier,
              hintText: AppStrings.shiftHint,
              itemLabel: (item) => item,
              onChanged: (value) {
                shiftNotifier.value = value;
              },
            ),
            20.verticalSpace,
            _buildBottomSheetActions(
              confirmText: confirmText,
              onConfirm: onSubmit,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget buildTimeRange() {
    return Obx(
      () => GestureDetector(
        onTap: pickTimeRange,
        child: Container(
          height: 57.h,
          width: 400.w,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(color: AppColors.grey, width: 1.w),
            ),
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                startTime.value.isEmpty
                    ? AppStrings.selectTime
                    : "${startTime.value} - ${endTime.value}",
                style: TextStyle(fontSize: 12.sp, fontWeight: AppWeights.w600),
              ),
              Icon(AppIcons.timer, size: AppSizes.s22),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickTimeRange() async {
    final start = await showTimePicker(
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.save,
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (start == null) return;

    final end = await showTimePicker(
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.save,
      context: Get.context!,
      initialTime: start,
    );

    if (end == null) return;

    startTime.value = start.format(Get.context!);
    endTime.value = end.format(Get.context!);
  }

  bool validate() {
    final errors = <String>[];

    if (dayNotifier.value == null) errors.add("Day");
    if (startTime.value.isEmpty) errors.add("Time");
    if (subjectController.text.isEmpty) errors.add("Subject");
    if (timetableTeacherNotifier.value == null) errors.add("Teacher");
    if (roomController.text.isEmpty) errors.add("Room");
    if (timetableDepartmentNotifier.value == null) errors.add("Department");
    if (semesterNotifier.value == null) errors.add("Semester");
    if (shiftNotifier.value == null) errors.add("Shift");

    if (errors.isNotEmpty) {
      AppSnackbar.error("Missing Fields", "Please fill: ${errors.join(", ")}");
      return false;
    }

    return true;
  }

  Future<void> saveData() async {
    if (!validate()) return;
    final timetableModel = _buildTimetableModel();
    if (timetableModel == null) return;

    try {
      await _timetableService.addTimetable(timetableModel);

      Get.back();
      AppSnackbar.success("Success", "Timetable Saved Successfully");
      resetTimetableForm();
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
    }
  }

  Future<void> updateTimetable(String id) async {
    if (!validate()) return;
    final timetableModel = _buildTimetableModel();
    if (timetableModel == null) return;

    try {
      await _timetableService.updateTimetable(id, timetableModel);

      Get.back();
      AppSnackbar.success("Updated", "Timetable Updated Successfully");
      resetTimetableForm();
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
    }
  }

  void openDepartmentBottomSheet() {
    resetDepartmentForm();

    Get.bottomSheet(
      _buildBottomSheetContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.addDept,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            8.verticalSpace,
            CustomText(text: AppStrings.addNewDept),
            30.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.deptName,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
              borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.deptName,
              controller: deptController,
            ),
            8.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.deptCode,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                            borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.deptHint,
              controller: deptCodeController,
            ),
            8.verticalSpace,
            CustomText(
              text: AppStrings.deptDescription,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
              borderRadius: BorderRadius.circular(10),
              maxLines: 3,
              hintText: AppStrings.deptDescription,
              controller: descriptionController,
            ),
            15.verticalSpace,
            _buildBottomSheetActions(
              confirmText: AppStrings.save,
              onConfirm: saveDepartment,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  bool validateDept() {
    final errors = <String>[];

    if (deptController.text.isEmpty) errors.add("Department Name");
    if (deptCodeController.text.isEmpty) errors.add("Department Code");

    if (errors.isNotEmpty) {
      AppSnackbar.error("Missing Fields", "Please fill: ${errors.join(", ")}");
      return false;
    }

    return true;
  }

  Future<void> saveDepartment() async {
    if (!validateDept()) return;

    try {
      final model = DepartmentModel(
        depName: deptController.text.trim(),
        depCode: deptCodeController.text.trim(),
        description: descriptionController.text.trim(),
      );

      await _departmentService.addDepartment(model);

      Get.back();
      AppSnackbar.success("Success", "Department Added Successfully");
      resetDepartmentForm();
    } catch (_) {
      AppSnackbar.error("Error", "Something went wrong");
    }
  }

  void openTeacherBottomSheet() {
    resetTeacherForm();

    Get.bottomSheet(
      _buildBottomSheetContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: AppStrings.addNewTeacher,
              fontSize: AppSizes.s18,
              fontWeight: AppWeights.bold,
            ),
            8.verticalSpace,
            CustomText(text: AppStrings.AddTeacherToSystem),
            30.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.teacherName,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
              borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.teacherNameHint,
              controller: teacherNameController,
            ),
            8.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.email,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.teacherEmailHint,
              controller: teacherEmailController,
            ),
            8.verticalSpace,
            CustomText(
              text: AppStrings.teacherPhone,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.teacherPhoneHit,
              controller: teacherPhoneController,
            ),
            8.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.teacherDept,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            StreamBuilder<List<DepartmentModel>>(
              stream: departmentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final departmentList = snapshot.data!;
                _syncSelectedDepartment(
                  teacherDepartmentNotifier,
                  departmentList,
                );

                return CustomDropdown<DepartmentModel>(
                  items: departmentList,
                  itemLabel: (item) => item.depName,
                  valueListenable: teacherDepartmentNotifier,
                  onChanged: (value) {
                    teacherDepartmentNotifier.value = value;
                  },
                  hintText: AppStrings.teacherDeptHint,
                );
              },
            ),
            8.verticalSpace,
            CustomText(
              text: AppStrings.teacherSpecialization,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              hintText: AppStrings.teacherSpecializationHint,
              controller: teacherSpecializationController,
            ),
            15.verticalSpace,
            _buildBottomSheetActions(
              confirmText: AppStrings.save,
              onConfirm: saveTeacher,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  bool validateTeacher() {
    final errors = <String>[];

    if (teacherNameController.text.isEmpty) errors.add("Teacher Name");
    if (teacherEmailController.text.isEmpty) errors.add("Email");
    if (teacherDepartmentNotifier.value == null) errors.add("Department");

    if (errors.isNotEmpty) {
      AppSnackbar.error("Missing Fields", "Please fill: ${errors.join(", ")}");
      return false;
    }

    return true;
  }

  Future<void> saveTeacher() async {
    if (!validateTeacher()) return;

    final selectedDepartment = teacherDepartmentNotifier.value;
    if (selectedDepartment == null) {
      AppSnackbar.error("Error", "Please select department");
      return;
    }

    try {
      final model = TeacherModel(
        teacherName: teacherNameController.text.trim(),
        teacherEmail: teacherEmailController.text.trim(),
        teacherPhoneNo: teacherPhoneController.text.trim(),
        teacherDept: selectedDepartment.depName,
        teacherDeptId: selectedDepartment.id,
        teacherSpecialization: teacherSpecializationController.text.trim(),
      );

      await _teacherService.addTeacher(model);

      Get.back();
      AppSnackbar.success("Success", "Teacher Added Successfully");
      resetTeacherForm();
    } catch (_) {
      AppSnackbar.error("Error", "Something went wrong");
    }
  }

  Future<void> openEditTeacherSheet(
    String id,
    Map<String, dynamic> data,
  ) async {
    resetTeacherForm();

    teacherNameController.text = data['teacherName'] ?? '';
    teacherEmailController.text = data['teacherEmail'] ?? '';
    teacherPhoneController.text = data['teacherPhoneNo'] ?? '';
    teacherSpecializationController.text = data['teacherSpecialization'] ?? '';

    final departments = await departmentsStream.first;
    teacherDepartmentNotifier.value = _findDepartmentByIdOrName(
      departments,
      departmentId: data['teacherDeptId']?.toString(),
      departmentName: data['teacherDept']?.toString(),
    );

    Get.bottomSheet(
      _buildBottomSheetContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: AppStrings.editTeacher,
              fontSize: AppSizes.s18,
              fontWeight: AppWeights.bold,
            ),
            20.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.fullName,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              controller: teacherNameController,
              hintText: AppStrings.fullName,
            ),
            10.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.email,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              controller: teacherEmailController,
              hintText: AppStrings.email,
            ),
            10.verticalSpace,
            CustomText(
              text: AppStrings.teacherPhone,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              controller: teacherPhoneController,
              hintText: AppStrings.teacherPhoneHit,
            ),
            10.verticalSpace,
            CustomText(
              isRequired: true,
              text: AppStrings.departments,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            StreamBuilder<List<DepartmentModel>>(
              stream: departmentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final departmentList = snapshot.data!;
                _syncSelectedDepartment(
                  teacherDepartmentNotifier,
                  departmentList,
                );

                return CustomDropdown<DepartmentModel>(
                  items: departmentList,
                  itemLabel: (item) => item.depName,
                  valueListenable: teacherDepartmentNotifier,
                  onChanged: (value) {
                    teacherDepartmentNotifier.value = value;
                  },
                  hintText: AppStrings.departments,
                );
              },
            ),
            10.verticalSpace,
            CustomText(
              text: AppStrings.teacherSpecialization,
              fontSize: AppSizes.s14,
              fontWeight: AppWeights.bold,
            ),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              controller: teacherSpecializationController,
              hintText: AppStrings.teacherSpecializationHint,
            ),
            20.verticalSpace,
            _buildBottomSheetActions(
              confirmText: AppStrings.update,
              onConfirm: () => updateTeacher(id),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> updateTeacher(String id) async {
    if (!validateTeacher()) return;

    final selectedDepartment = teacherDepartmentNotifier.value;
    if (selectedDepartment == null) {
      AppSnackbar.error("Error", "Please select department");
      return;
    }

    try {
      final data = {
        "teacherName": teacherNameController.text.trim(),
        "teacherEmail": teacherEmailController.text.trim(),
        "teacherPhoneNo": teacherPhoneController.text.trim(),
        "teacherDept": selectedDepartment.depName,
        "teacherDeptId": selectedDepartment.id,
        "teacherSpecialization": teacherSpecializationController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(id)
          .update(data);

      Get.back();
      AppSnackbar.success("Updated", "Teacher Updated Successfully");
    } catch (_) {
      AppSnackbar.error("Error", "Update failed");
    }
  }

  void openEditDepartmentSheet(String id, Map<String, dynamic> data) {
    resetDepartmentForm();
    deptController.text = data['depName'] ?? '';
    deptCodeController.text = data['depCode'] ?? '';
    descriptionController.text = data['description'] ?? '';

    Get.bottomSheet(
      _buildBottomSheetContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: AppStrings.editDept,
              fontSize: AppSizes.s18,
              fontWeight: AppWeights.bold,
            ),
            20.verticalSpace,
            CustomText(isRequired: true, text: AppStrings.deptName),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              controller: deptController,
              hintText: AppStrings.depNameHint,
            ),
            10.verticalSpace,
            CustomText(isRequired: true, text: AppStrings.deptCode),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              controller: deptCodeController,
              hintText: AppStrings.deptHint,
            ),
            10.verticalSpace,
            CustomText(text: AppStrings.deptDescription),
            5.verticalSpace,
            CustomTextFormField(
                     borderRadius: BorderRadius.circular(10),
              controller: descriptionController,
              hintText: AppStrings.deptDescription,
              maxLines: 3,
            ),
            20.verticalSpace,
            _buildBottomSheetActions(
              confirmText: AppStrings.update,
              onConfirm: () => updateDepartment(id),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> updateDepartment(String id) async {
    if (!validateDept()) return;

    try {
      final data = {
        "depName": deptController.text.trim(),
        "depCode": deptCodeController.text.trim(),
        "description": descriptionController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('departments')
          .doc(id)
          .update(data);

      Get.back();
      AppSnackbar.success("Updated", "Department Updated Successfully");
      resetDepartmentForm();
    } catch (_) {
      AppSnackbar.error("Error", "Update failed");
    }
  }
}