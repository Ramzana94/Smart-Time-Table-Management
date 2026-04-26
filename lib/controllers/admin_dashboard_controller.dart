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
import 'package:smart_timetable_managment/core/utils/app_snack_bar.dart';
import 'package:smart_timetable_managment/models/department_model.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_dropdown.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';

class AdminDashboardController extends GetxController {
  final DepartmentService _departmentService = DepartmentService();
  final TeacherService _teacherService = TeacherService();
  // Dropdown values
  final ValueNotifier<String?> dayNotifier = ValueNotifier(null);
  final ValueNotifier<String?> departmentNotifier = ValueNotifier(null);
  final ValueNotifier<String?> semesterNotifier = ValueNotifier(null);
  final ValueNotifier<String?> shiftNotifier = ValueNotifier(null);
  final ValueNotifier<String?> teachertNotifier = ValueNotifier(null);
  // Time range
  var startTime = ''.obs;
  var endTime = ''.obs;
  var currentTabIndex = 0.obs;
  // Timetable controller
  final subjectController = TextEditingController();
  final roomController = TextEditingController();

  // Department
  final deptController = TextEditingController();
  final deptCodeController = TextEditingController();
  final descriptionController = TextEditingController();
  //Teachers
  final teacherNameController = TextEditingController();
  final teacherEmailController = TextEditingController();
  final teacherPhoneController = TextEditingController();
  final teacherDepartmentController = TextEditingController();
  final teacherSpecializationController = TextEditingController();

  // Dropdown lists
  final days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  // final departments = ["CS", "SE", "IT"];
  final semesters = ["1", "2", "3", "4", "5", "6", "7", "8"];
  final shifts = ["Morning", "Evening"];
  // final teachers = ["Mr. Waqas", "Mr. Shoib", "Mr. Talha Bajwa"];
  // 🔥 Bottom Sheet
  void openCreateBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: AppStrings.addTimetableEntry,
                fontSize: AppSizes.s20,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomText(
                text: AppStrings.CreateTimetableEntry,
                color: AppColors.grey,
              ),
              20.verticalSpace,
              //  Day + Time Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: AppStrings.day,
                          isRequired: true,
                          fontWeight: AppWeights.bold,
                        ),
                        5.verticalSpace,
                        CustomDropdown<String>(
                          items: days,
                          valueListenable: dayNotifier,
                          hintText: AppStrings.dayExp,
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
                          text: AppStrings.time,
                          isRequired: true,
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
                text: AppStrings.subject,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                borderRadius: BorderRadius.circular(10),
                hintText: AppStrings.subjectExp,
                controller: subjectController,
              ),

              8.verticalSpace,
              CustomText(
                text: AppStrings.teachers,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              // CustomDropdown<String>(
              //   items: teachers,
              //   valueListenable: teachertNotifier,
              //   hintText: AppStrings.teachersExp,
              //   itemLabel: (item) => item,
              //   onChanged: (value) {
              //     teachertNotifier.value = value;
              //   },
              // ),
              StreamBuilder<List<TeacherModel>>(
                  stream: _teacherService.getTeachers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final teacherList = snapshot.data!;

                    return CustomDropdown<String>(
                      items: teacherList.map((e) => e.teacherName).toList(),
                      itemLabel: (item) => item,
                      valueListenable: teachertNotifier,
                      hintText: AppStrings.teacherName,
                      onChanged: (value) {
                        teachertNotifier.value = value;
                      },
                    );
                  },
                ),
              8.verticalSpace,
              CustomText(
                text: AppStrings.rooms,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                borderRadius: BorderRadius.circular(10),
                hintText: AppStrings.roomsExp,
                controller: roomController,
              ),
              12.verticalSpace,
              //  Department + Semester Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: AppStrings.department,
                          isRequired: true,
                          fontWeight: AppWeights.bold,
                        ),
                        5.verticalSpace,
                        // CustomDropdown<String>(
                        //   items: departments,
                        //   valueListenable: departmentNotifier,
                        //   hintText: AppStrings.deptExp,
                        //   itemLabel: (item) => item,
                        //   onChanged: (value) {
                        //     departmentNotifier.value = value;
                        //   },
                        // ),
                        StreamBuilder<List<DepartmentModel>>(
                          stream: _departmentService.getDepartments(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final deptList = snapshot.data!;

                            return CustomDropdown<String>(
                              items: deptList.map((e) => e.depName).toList(),
                              itemLabel: (item) => item,
                              valueListenable: departmentNotifier,
                              onChanged: (value) {
                                departmentNotifier.value = value;
                              },
                              hintText: AppStrings.deptNameHint,
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
                          text: AppStrings.semester,
                          isRequired: true,
                          fontWeight: AppWeights.bold,
                        ),
                        5.verticalSpace,
                        CustomDropdown<String>(
                          items: semesters,
                          valueListenable: semesterNotifier,
                          hintText: AppStrings.semester,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: AppStrings.shift,
                    isRequired: true,
                    fontWeight: AppWeights.bold,
                  ),
                  5.verticalSpace,
                  CustomDropdown<String>(
                    width: double.infinity,
                    items: shifts,
                    valueListenable: shiftNotifier,
                    hintText: AppStrings.shift,
                    itemLabel: (item) => item,
                    onChanged: (value) {
                      shiftNotifier.value = value;
                    },
                  ),
                ],
              ),
              20.verticalSpace,
              Row(
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
                      onPressed: saveData,
                      text: AppStrings.save,
                      color: AppColors.primary,
                      borderRadius: 10,
                      height: 57.h,
                      textColor: AppColors.white,
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

  // 🔥 TIME RANGE PICKER
  Widget buildTimeRange() {
    return Obx(
      () => GestureDetector(
        onTap: pickTimeRange,
        child: Container(
          height: 57.h,
          width: 400.w,

          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: BoxBorder.fromBorderSide(
              BorderSide(color: AppColors.grey, width: 1),
            ),
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                style: TextStyle(fontSize: 12.sp, fontWeight: AppWeights.w600),
                startTime.value.isEmpty
                    ? AppStrings.selectTime
                    : "${startTime.value} - ${endTime.value}",
              ),
              Icon(AppIcons.watch),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 PICK TIME RANGE
  Future<void> pickTimeRange() async {
    TimeOfDay? start = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (start == null) return;

    TimeOfDay? end = await showTimePicker(
      context: Get.context!,
      initialTime: start,
    );

    if (end == null) return;

    startTime.value = start.format(Get.context!);
    endTime.value = end.format(Get.context!);
  }

  // 🔥 VALIDATION
  //  VALIDATION
  bool validate() {
    List<String> errors = [];

    if (dayNotifier.value == null) errors.add("Day");
    if (startTime.value.isEmpty) errors.add("Time");
    if (subjectController.text.isEmpty) errors.add("Subject");
    if (teachertNotifier.value == null) errors.add("Teacher");
    if (roomController.text.isEmpty) errors.add("Room");
    if (departmentNotifier.value == null) errors.add("Department");
    if (semesterNotifier.value == null) errors.add("Semester");
    if (shiftNotifier.value == null) errors.add("Shift");

    if (errors.isNotEmpty) {
      AppSnackbar.error("Missing Fields", "Please fill: ${errors.join(", ")}");
      return false;
    }

    return true;
  }

  // 🔥 SAVE
  Future<void> saveData() async {
    if (!validate()) return;

    try {
      final data = {
        "day": dayNotifier.value,
        "time": "${startTime.value} - ${endTime.value}",
        "subject": subjectController.text.trim(),
        "teacher": teachertNotifier.value,
        "room": roomController.text.trim(),
        "department": departmentNotifier.value,
        "semester": semesterNotifier.value,
        "shift": shiftNotifier.value,
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection("timetable").add(data);

      Get.back();

      AppSnackbar.success("Success", "Timetable Saved Successfully");

      // clear fields (optional but good)
      subjectController.clear();
      roomController.clear();
      startTime.value = "";
      endTime.value = "";
      dayNotifier.value = null;
      teachertNotifier.value = null;
      departmentNotifier.value = null;
      semesterNotifier.value = null;
      shiftNotifier.value = null;
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
    }
  }
  // bool validate() {

  //   List<String> errors = [];

  //   if (dayNotifier.value == null) errors.add("Day");
  //   if (startTime.value.isEmpty) errors.add("Time");
  //   if (subjectController.text.isEmpty) errors.add("Subject");
  //   if (teachertNotifier.value == null) errors.add("Teacher");
  //   if (roomController.text.isEmpty) errors.add("Room");
  //   if (departmentNotifier.value == null) errors.add("Department");
  //   if (semesterNotifier.value == null) errors.add("Semester");
  //   if (shiftNotifier.value == null) errors.add("Shift");

  //   if (errors.isNotEmpty) {
  //     Get.snackbar(
  //       "Missing Fields",
  //       "Please fill: ${errors.join(", ")}",
  //       backgroundColor: Colors.red.shade100,
  //     );
  //     return false;
  //   }

  //   return true;
  // }

  // // 🔥 SAVE
  // void saveData() {
  //   if (!validate()) return;

  //   final data = {
  //     "day": dayNotifier.value,
  //     "time": "${startTime.value} - ${endTime.value}",
  //     "subject": subjectController.text,
  //     "teacher": teachertNotifier.value,
  //     "room": roomController.text,
  //     "department": departmentNotifier.value,
  //     "semester": semesterNotifier.value,
  //     "shift": shiftNotifier.value,
  //   };

  //   debugPrint("DATA: $data");

  //   Get.back();

  //   Get.snackbar(
  //     "Success",
  //     "Timetable Entry Added",
  //     backgroundColor: Colors.green.shade100,
  //   );
  // }


  // department sheet
  void openDepartmentBottomSheet() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              15.verticalSpace,

              /// 🔹 Title
              CustomText(
                text: AppStrings.addDepartment,
                fontSize: AppSizes.s20,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,

              /// 🔹 Subtitle
              CustomText(
                text: AppStrings.departmentDescription,
                color: AppColors.grey,
              ),
              20.verticalSpace,
              CustomText(
                text: AppStrings.departmentName,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.deptNameHint,
                controller: deptController,
                borderRadius: BorderRadius.circular(10),
              ),
              15.verticalSpace,

              /// 🔹 Department Code
              CustomText(
                text: AppStrings.departmentCode,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.deptCodeHint,
                controller: deptCodeController,
                borderRadius: BorderRadius.circular(10),
              ),
              15.verticalSpace,

              /// 🔹 Description
              CustomText(
                text: AppStrings.description,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.deptDescriptionHint,
                controller: descriptionController,
                borderRadius: BorderRadius.circular(10),
                maxLines: 3,
              ),
              25.verticalSpace,

              SizedBox(height: 15),
              Row(
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
                      onPressed: saveDepartment,

                      text: AppStrings.save,
                      color: AppColors.primary,
                      borderRadius: 10,
                      height: 57.h,
                      textColor: AppColors.white,
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

  bool validateDept() {
    List<String> errors = [];

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
      deptController.clear();
      deptCodeController.clear();
      descriptionController.clear();
    } catch (e) {
      AppSnackbar.error("Error", "Something went wrong");
    }
  }

  void openTeacherBottomSheet() {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Title
              CustomText(
                text: "Add New Teacher",
                fontSize: AppSizes.s20,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,

              /// 🔹 Subtitle
              CustomText(
                text: "Enter teacher details to add into system",
                color: AppColors.grey,
              ),
              20.verticalSpace,

              /// 🔹 Name
              CustomText(
                text: AppStrings.teacherName,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.teachersExp,
                controller: teacherNameController,
                borderRadius: BorderRadius.circular(10),
              ),
              15.verticalSpace,

              /// 🔹 Email
              CustomText(
                text: AppStrings.email,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.teacheremailHint,
                controller: teacherEmailController,
                borderRadius: BorderRadius.circular(10),
              ),
              15.verticalSpace,

              /// 🔹 Phone (optional)
              CustomText(text: AppStrings.phone, fontWeight: AppWeights.bold),
              5.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.teacherPhoneHint,
                controller: teacherPhoneController,
                borderRadius: BorderRadius.circular(10),
              ),
              15.verticalSpace,

              /// 🔹 Department
              CustomText(
                text: AppStrings.department,
                isRequired: true,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              // CustomDropdown<String>(
              //   items: departments,
              //   itemLabel: (item) => item,
              //   valueListenable: departmentNotifier,
              //   onChanged: (value) {
              //     departmentNotifier.value = value;
              //   },
              //   hintText: AppStrings.deptNameHint,
              // ),
              StreamBuilder<List<DepartmentModel>>(
                stream: _departmentService.getDepartments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final deptList = snapshot.data!;

                  return CustomDropdown<String>(
                    items: deptList.map((e) => e.depName).toList(),
                    itemLabel: (item) => item,
                    valueListenable: departmentNotifier,
                    onChanged: (value) {
                      departmentNotifier.value = value;
                    },
                    hintText: AppStrings.deptNameHint,
                  );
                },
              ),
              15.verticalSpace,

              /// 🔹 Specialization (optional)
              CustomText(
                text: AppStrings.Specialization,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              CustomTextFormField(
                hintText: AppStrings.teacherSpecialization,
                controller: teacherSpecializationController,
                borderRadius: BorderRadius.circular(10),
              ),
              25.verticalSpace,

              /// 🔹 Buttons
              Row(
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
                      onPressed:
                          //  () {
                          //   Get.back();
                          //   AppSnackbar.success(
                          //     "Success",
                          //     "Teacher added successfully",
                          //   );
                          // },
                          saveTeacher,
                      text: AppStrings.addTeacher,
                      color: AppColors.primary,
                      borderRadius: 10,
                      height: 57.h,
                      textColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool validateTeacher() {
    List<String> errors = [];

    if (teacherNameController.text.isEmpty) errors.add("Name");
    if (teacherEmailController.text.isEmpty) errors.add("Email");
    if (departmentNotifier.value == null) errors.add("Department");

    if (errors.isNotEmpty) {
      AppSnackbar.error("Missing Fields", "Please fill: ${errors.join(", ")}");
      return false;
    }
    return true;
  }

  Future<void> saveTeacher() async {
    if (!validateTeacher()) return;

    try {
      final model = TeacherModel(
        teacherName: teacherNameController.text.trim(),
        teacherEmail: teacherEmailController.text.trim(),
        teacherPhoneNo: teacherPhoneController.text.trim(),
        teacherDept: departmentNotifier.value ?? "",
        teacherSpecialization: teacherSpecializationController.text.trim(),
      );

      await _teacherService.addTeacher(model);

      Get.back();
      AppSnackbar.success("Success", "Teacher Added Successfully");

      // clear fields
      teacherNameController.clear();
      teacherEmailController.clear();
      teacherPhoneController.clear();
      teacherSpecializationController.clear();
      departmentNotifier.value = null;
    } catch (e) {
      AppSnackbar.error("Error", "Something went wrong");
    }
  }
  void openEditDepartmentSheet(String id, Map<String, dynamic> data) {
    deptController.clear();
    deptCodeController.clear();
    descriptionController.clear();
    // 🔥 Pre-fill fields
    deptController.text = data['depName'] ?? '';
    deptCodeController.text = data['depCode'] ?? '';
    descriptionController.text = data['description'] ?? '';

    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: AppStrings.editDept,
                fontSize: AppSizes.s18,
                fontWeight: AppWeights.bold,
              ),

              20.verticalSpace,

              // Name
              CustomText(isRequired: true, text: AppStrings.departmentName),
              5.verticalSpace,
              CustomTextFormField(
                borderRadius: BorderRadius.circular(10),
                controller: deptController,
                hintText:AppStrings.deptNameHint,
              ),

              10.verticalSpace,

              // Code
              CustomText(isRequired: true, text: AppStrings.departmentCode),
              5.verticalSpace,
              CustomTextFormField(
                borderRadius: BorderRadius.circular(10),
                controller: deptCodeController,
                hintText: AppStrings.deptCodeHint,
              ),

              10.verticalSpace,

              // Description
              CustomText(text: AppStrings.departmentDescription),
              5.verticalSpace,
              CustomTextFormField(
                borderRadius: BorderRadius.circular(10),
                controller: descriptionController,
                hintText: AppStrings.deptDescriptionHint,
                maxLines: 3,
              ),

              20.verticalSpace,

              Row(
                children: [
                  Expanded(
                    child: CustomMaterialButton(
                      onPressed: () => Get.back(),
                      text:AppStrings.cancel,
                      color: AppColors.white,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      borderRadius: 10.r,
                      height: 57.h,
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: CustomMaterialButton(
                      onPressed: () => updateDepartment(id),
                      text:AppStrings.update,
                      color: AppColors.primary,
                      textColor: AppColors.white,
                      borderRadius: 10,
                      height: 57.h,
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

      deptController.clear();
      deptCodeController.clear();
      descriptionController.clear();
    } catch (e) {
      AppSnackbar.error("Error", "Update failed");
    }
  }
 void openEditTeacherSheet(String id, Map<String, dynamic> data) {
    teacherNameController.clear();
    teacherEmailController.clear();
    teacherPhoneController.clear();
    teacherSpecializationController.clear();
    departmentNotifier.value = null;

    teacherNameController.text = data['teacherName'] ?? '';
    teacherEmailController.text = data['teacherEmail'] ?? '';
    teacherPhoneController.text = data['teacherPhoneNo'] ?? '';
    teacherSpecializationController.text = data['teacherSpecialization'] ?? '';

    departmentNotifier.value = data['teacherDept'];

    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                hintText: AppStrings.teacherPhoneHint,
              ),
              10.verticalSpace,
              CustomText(
                isRequired: true,
                text: AppStrings.departments,
                fontSize: AppSizes.s14,
                fontWeight: AppWeights.bold,
              ),
              5.verticalSpace,
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('departments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final docs = snapshot.data!.docs;
                  final deptList = docs
                      .map((e) => e['depName'].toString())
                      .toList();

                  // 👇 IMPORTANT FIX
                  if (!deptList.contains(departmentNotifier.value)) {
                    departmentNotifier.value = null;
                  }

                  return CustomDropdown(
                    items: deptList,
                    itemLabel: (item) => item,
                    valueListenable: departmentNotifier,
                    onChanged: (val) {
                      departmentNotifier.value = val;
                    },
                    hintText: AppStrings.departments,
                  );
                },
              ),
              // StreamBuilder(
              //   stream: FirebaseFirestore.instance.collection('departments').snapshots(),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return const CircularProgressIndicator();
              //     }

              //     final docs = snapshot.data!.docs;

              //     final deptList =
              //         docs.map((e) => e['depName'].toString()).toList();

              //     return CustomDropdown(
              //       items: deptList,
              //       itemLabel: (item) => item,
              //       valueListenable: departmentNotifier,
              //       onChanged: (val) {
              //         departmentNotifier.value = val;
              //       },
              //       hintText: AppStrings.departments,
              //     );
              //   },
              // ),
              // CustomDropdown(
              //   items: departments,
              //   itemLabel: (item) => item,
              //   valueListenable: departmentNotifier,
              //   onChanged: (val) => departmentNotifier.value = val,
              //   hintText: "Department",
              // ),
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
                hintText: AppStrings.teacherSpecialization,
              ),

              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomMaterialButton(
                      onPressed: () => Get.back(),
                      text: AppStrings.cancel,
                      color: AppColors.white,
                      textColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      borderRadius: 10.r,
                      height: 57.h,
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: CustomMaterialButton(
                      onPressed: () => updateTeacher(id),
                      text: AppStrings.update,
                      color: AppColors.primary,
                      textColor: AppColors.white,
                      borderRadius: 10.r,
                      height: 57.h,
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

  Future<void> updateTeacher(String id) async {
    if (!validateTeacher()) return;

    try {
      final data = {
        "teacherName": teacherNameController.text.trim(),
        "teacherEmail": teacherEmailController.text.trim(),
        "teacherPhoneNo": teacherPhoneController.text.trim(),
        "teacherDept": departmentNotifier.value,
        "teacherSpecialization": teacherSpecializationController.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(id)
          .update(data);

      Get.back();

      AppSnackbar.success("Updated", "Teacher Updated Successfully");
    } catch (e) {
      AppSnackbar.error("Error", "Update failed");
    }
  }
}
