import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/core/services/department_service.dart';
import 'package:smart_timetable_managment/core/services/notification_service.dart';
import 'package:smart_timetable_managment/core/services/teacher_service.dart';
import 'package:smart_timetable_managment/core/services/timetable_service.dart';
import 'package:smart_timetable_managment/core/utils/app_snack_bar.dart';
import 'package:smart_timetable_managment/core/utils/class_section_identity.dart';
import 'package:smart_timetable_managment/models/department_model.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/widgets/app_button.dart';
import 'package:smart_timetable_managment/widgets/app_dropdown.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';
import 'package:smart_timetable_managment/widgets/app_textfield.dart';

class AdminDashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  AdminDashboardController({
    FirebaseAuth? auth,
    DepartmentService? departmentService,
    TeacherService? teacherService,
    TimetableService? timetableService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _departmentService = departmentService ?? DepartmentService(),
       _teacherService = teacherService ?? TeacherService(),
       _timetableService = timetableService ?? TimetableService();

  final FirebaseAuth _auth;
  final DepartmentService _departmentService;
  final TeacherService _teacherService;
  final TimetableService _timetableService;

  final departments = <DepartmentModel>[].obs;
  final teachers = <TeacherModel>[].obs;
  final allTimetableEntries = <TimetableModel>[].obs;
  final timetableEntries = <TimetableModel>[].obs;

  final isDepartmentsReady = false.obs;
  final isTeachersReady = false.obs;
  final isTimetableReady = false.obs;

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
  final editingTimetableId = RxnString();
  final currentTabIndex = 0.obs;

  final courseTitleController = TextEditingController();
  final courseCodeController = TextEditingController();
  final roomController = TextEditingController();
  final deptController = TextEditingController();
  final deptCodeController = TextEditingController();
  final descriptionController = TextEditingController();
  final teacherNameController = TextEditingController();
  final teacherEmailController = TextEditingController();
  final teacherPhoneController = TextEditingController();
  final teacherSpecializationController = TextEditingController();

  final days = const ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
  final semesters = const ["1", "2", "3", "4", "5", "6", "7", "8"];
  final shifts = const ["Morning", "Evening"];
  late final TabController tabController;

  StreamSubscription<List<DepartmentModel>>? _departmentSubscription;
  StreamSubscription<List<TeacherModel>>? _teacherSubscription;
  StreamSubscription<List<TimetableModel>>? _timetableSubscription;
  StreamSubscription<User?>? _authSubscription;
  String _activeUserId = '';

  Stream<List<DepartmentModel>> get departmentsStream =>
      _departmentService.getDepartments();

  Stream<List<TeacherModel>> get teachersStream =>
      _teacherService.getTeachers();

  Stream<List<TimetableModel>> get timetableStream =>
      _timetableService.getTimetable();

  int get totalClassCount => timetableEntries.length;

  int get totalTeacherCount => teachers.length;

  int get totalDepartmentCount => departments.length;

  int get totalRoomCount => timetableEntries
      .map((entry) => entry.room.trim())
      .where((room) => room.isNotEmpty)
      .toSet()
      .length;

  List<String> get knownRooms {
    final rooms =
        timetableEntries
            .map((entry) => entry.room.trim())
            .where((room) => room.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return rooms;
  }

  bool get canCheckRoomAvailability =>
      dayNotifier.value != null &&
      startTime.value.isNotEmpty &&
      endTime.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: currentTabIndex.value,
    );
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthChanged,
      onError: (_) => _handleAuthChanged(null),
    );
    _handleAuthChanged(_auth.currentUser);
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _departmentSubscription?.cancel();
    _teacherSubscription?.cancel();
    _timetableSubscription?.cancel();
    tabController.dispose();
    dayNotifier.dispose();
    timetableTeacherNotifier.dispose();
    timetableDepartmentNotifier.dispose();
    teacherDepartmentNotifier.dispose();
    semesterNotifier.dispose();
    shiftNotifier.dispose();
    courseTitleController.dispose();
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

  void _handleAuthChanged(User? user) {
    final nextUserId = user?.uid ?? '';
    if (_activeUserId == nextUserId) {
      return;
    }

    _activeUserId = nextUserId;
    _cancelAdminSubscriptions();
    _resetAdminState();

    if (user == null) {
      return;
    }

    _bindAdminStreams();
  }

  void _cancelAdminSubscriptions() {
    _departmentSubscription?.cancel();
    _teacherSubscription?.cancel();
    _timetableSubscription?.cancel();
    _departmentSubscription = null;
    _teacherSubscription = null;
    _timetableSubscription = null;
  }

  void _resetAdminState() {
    departments.clear();
    teachers.clear();
    allTimetableEntries.clear();
    timetableEntries.clear();

    isDepartmentsReady.value = false;
    isTeachersReady.value = false;
    isTimetableReady.value = false;

    currentTabIndex.value = 0;
    if (tabController.index != 0) {
      tabController.animateTo(0);
    }

    resetDepartmentForm();
    resetTeacherForm();
    resetTimetableForm();
  }

  void _bindAdminStreams() {
    _departmentSubscription = departmentsStream.listen(
      (items) {
        departments.assignAll(items);
        isDepartmentsReady.value = true;
        _syncSelectedDepartment(timetableDepartmentNotifier, items);
        _syncSelectedDepartment(teacherDepartmentNotifier, items);
        _syncAdminTimetableEntries();
      },
      onError: (_) {
        isDepartmentsReady.value = true;
      },
    );

    _teacherSubscription = teachersStream.listen(
      (items) {
        teachers.assignAll(items);
        isTeachersReady.value = true;
        _syncSelectedTeacher(items);
        _syncAdminTimetableEntries();
      },
      onError: (_) {
        isTeachersReady.value = true;
      },
    );

    _timetableSubscription = timetableStream.listen(
      (items) {
        allTimetableEntries.assignAll(items);
        _syncAdminTimetableEntries();
        isTimetableReady.value = true;
      },
      onError: (_) {
        isTimetableReady.value = true;
      },
    );
  }

  void _syncAdminTimetableEntries() {
    if (allTimetableEntries.isEmpty) {
      timetableEntries.clear();
      return;
    }

    final departmentIds = departments
        .map((department) => _normalize(department.id))
        .where((value) => value.isNotEmpty)
        .toSet();
    final departmentNames = departments
        .map((department) => _normalize(department.depName))
        .where((value) => value.isNotEmpty)
        .toSet();
    final teacherIds = teachers
        .map((teacher) => _normalize(teacher.uid))
        .where((value) => value.isNotEmpty)
        .toSet();
    final teacherNames = teachers
        .map((teacher) => _normalize(teacher.teacherName))
        .where((value) => value.isNotEmpty)
        .toSet();

    final hasDepartmentScope =
        departmentIds.isNotEmpty || departmentNames.isNotEmpty;
    final hasTeacherScope = teacherIds.isNotEmpty || teacherNames.isNotEmpty;

    if (!hasDepartmentScope && !hasTeacherScope) {
      timetableEntries.clear();
      return;
    }

    final visibleEntries = allTimetableEntries
        .where((entry) {
          final matchesDepartment =
              (departmentIds.isNotEmpty &&
                  departmentIds.contains(_normalize(entry.departmentId))) ||
              (departmentNames.isNotEmpty &&
                  departmentNames.contains(_normalize(entry.department)));

          final matchesTeacher =
              (teacherIds.isNotEmpty &&
                  teacherIds.contains(_normalize(entry.teacherId))) ||
              (teacherNames.isNotEmpty &&
                  teacherNames.contains(_normalize(entry.teacher)));

          return matchesDepartment || matchesTeacher;
        })
        .toList(growable: false);

    timetableEntries.assignAll(visibleEntries);
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  int departmentClassCount(DepartmentModel department) {
    return timetableEntries
        .where((entry) => _isSameDepartmentEntry(entry, department))
        .length;
  }

  int teacherClassCount(TeacherModel teacher) {
    return timetableEntries
        .where((entry) => _isSameTeacherEntry(entry, teacher))
        .length;
  }

  Future<void> deleteTeacher(String id) async {
    await _teacherService.deleteTeacher(id);
  }

  Future<void> deleteDepartment(String id) async {
    await _departmentService.deleteDepartment(id);
  }

  void resetTimetableForm() {
    courseTitleController.clear();
    courseCodeController.clear();
    roomController.clear();
    startTime.value = '';
    endTime.value = '';
    editingTimetableId.value = null;
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

  bool _isSameDepartmentEntry(
    TimetableModel entry,
    DepartmentModel department,
  ) {
    if (department.id.isNotEmpty && entry.departmentId.isNotEmpty) {
      return entry.departmentId == department.id;
    }

    return _normalize(entry.department) == _normalize(department.depName);
  }

  bool _isSameTeacherEntry(TimetableModel entry, TeacherModel teacher) {
    if (teacher.uid.isNotEmpty && entry.teacherId.isNotEmpty) {
      return entry.teacherId == teacher.uid;
    }

    return _normalize(entry.teacher) == _normalize(teacher.teacherName);
  }

  String _normalize(String value) => value.trim().toLowerCase();

  void _syncSelectedTeacher(List<TeacherModel> teacherItems) {
    final selectedTeacher = timetableTeacherNotifier.value;
    if (selectedTeacher != null && !teacherItems.contains(selectedTeacher)) {
      timetableTeacherNotifier.value = null;
    }
  }

  void _syncSelectedDepartment(
    ValueNotifier<DepartmentModel?> notifier,
    List<DepartmentModel> departmentItems,
  ) {
    final selectedDepartment = notifier.value;
    if (selectedDepartment != null &&
        !departmentItems.contains(selectedDepartment)) {
      notifier.value = null;
    }
  }

  DepartmentModel? _findDepartmentByIdOrName(
    List<DepartmentModel> departmentItems, {
    String? departmentId,
    String? departmentName,
  }) {
    for (final department in departmentItems) {
      if (departmentId != null &&
          departmentId.isNotEmpty &&
          department.id == departmentId) {
        return department;
      }
    }

    final normalizedName = _normalize(departmentName ?? '');
    for (final department in departmentItems) {
      if (normalizedName.isNotEmpty &&
          _normalize(department.depName) == normalizedName) {
        return department;
      }
    }

    return null;
  }

  TeacherModel? _findTeacherByIdOrName(
    List<TeacherModel> teacherItems, {
    String? teacherId,
    String? teacherName,
  }) {
    for (final teacher in teacherItems) {
      if (teacherId != null &&
          teacherId.isNotEmpty &&
          teacher.uid == teacherId) {
        return teacher;
      }
    }

    final normalizedName = _normalize(teacherName ?? '');
    for (final teacher in teacherItems) {
      if (normalizedName.isNotEmpty &&
          _normalize(teacher.teacherName) == normalizedName) {
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

  List<String> occupiedRoomsForCurrentSelection({String? excludeTimetableId}) {
    if (!canCheckRoomAvailability) {
      return const <String>[];
    }

    final day = dayNotifier.value ?? '';
    final occupiedRooms =
        timetableEntries
            .where(
              (entry) =>
                  entry.id != excludeTimetableId &&
                  entry.room.trim().isNotEmpty &&
                  _normalize(entry.day) == _normalize(day) &&
                  _timeRangesOverlap(
                    startTime.value,
                    endTime.value,
                    entry.time.trim(),
                  ),
            )
            .map((entry) => entry.room.trim())
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return occupiedRooms;
  }

  List<String> availableRoomsForCurrentSelection({String? excludeTimetableId}) {
    if (!canCheckRoomAvailability) {
      return const <String>[];
    }

    final busyRooms = occupiedRoomsForCurrentSelection(
      excludeTimetableId: excludeTimetableId,
    ).map(_normalize).toSet();

    return knownRooms
        .where((room) => !busyRooms.contains(_normalize(room)))
        .toList(growable: false);
  }

  List<TimetableModel> roomConflictsForCurrentSelection(
    String roomName, {
    String? excludeTimetableId,
  }) {
    final normalizedRoom = _normalize(roomName);
    if (!canCheckRoomAvailability || normalizedRoom.isEmpty) {
      return const <TimetableModel>[];
    }

    final day = dayNotifier.value ?? '';

    return timetableEntries
        .where((entry) {
          if (entry.id == excludeTimetableId) {
            return false;
          }

          if (_normalize(entry.room) != normalizedRoom) {
            return false;
          }

          if (_normalize(entry.day) != _normalize(day)) {
            return false;
          }

          return _timeRangesOverlap(startTime.value, endTime.value, entry.time);
        })
        .toList(growable: false);
  }

  String? currentRoomConflictMessage({String? excludeTimetableId}) {
    final roomName = roomController.text.trim();
    if (roomName.isEmpty) {
      return null;
    }

    final conflicts = roomConflictsForCurrentSelection(
      roomName,
      excludeTimetableId: excludeTimetableId,
    );

    if (conflicts.isEmpty) {
      return null;
    }

    final firstConflict = conflicts.first;
    return 'Room ${roomName.trim()} is already booked for ${firstConflict.courseTitle} on ${firstConflict.day} at ${firstConflict.time}.';
  }

  bool _timeRangesOverlap(
    String selectedStart,
    String selectedEnd,
    String existingRange,
  ) {
    final selectedRange = _parseTimeRange('$selectedStart - $selectedEnd');
    final currentRange = _parseTimeRange(existingRange);

    if (selectedRange == null || currentRange == null) {
      return false;
    }

    return selectedRange.start < currentRange.end &&
        currentRange.start < selectedRange.end;
  }

  ({int start, int end})? _parseTimeRange(String value) {
    final parts = value
        .split('-')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length < 2) {
      return null;
    }

    final startMinutes = _parseClockValue(parts.first);
    final endMinutes = _parseClockValue(parts.sublist(1).join(' - '));

    if (startMinutes == null || endMinutes == null) {
      return null;
    }

    return (start: startMinutes, end: endMinutes);
  }

  int? _parseClockValue(String raw) {
    final value = raw.toUpperCase().replaceAll('.', '').trim();
    final twelveHourMatch = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AP]M)$',
    ).firstMatch(value);

    if (twelveHourMatch != null) {
      var hour = int.parse(twelveHourMatch.group(1)!);
      final minute = int.parse(twelveHourMatch.group(2)!);
      final meridiem = twelveHourMatch.group(3)!;

      if (meridiem == 'PM' && hour != 12) {
        hour += 12;
      } else if (meridiem == 'AM' && hour == 12) {
        hour = 0;
      }

      return (hour * 60) + minute;
    }

    final twentyFourHourMatch = RegExp(
      r'^(\d{1,2}):(\d{2})$',
    ).firstMatch(value);

    if (twentyFourHourMatch != null) {
      final hour = int.parse(twentyFourHourMatch.group(1)!);
      final minute = int.parse(twentyFourHourMatch.group(2)!);
      return (hour * 60) + minute;
    }

    return null;
  }

  Future<List<DepartmentModel>> _resolveDepartments() async {
    if (isDepartmentsReady.value) {
      return departments.toList(growable: false);
    }

    final items = await departmentsStream.first;
    departments.assignAll(items);
    isDepartmentsReady.value = true;
    return items;
  }

  Future<List<TeacherModel>> _resolveTeachers() async {
    if (isTeachersReady.value) {
      return teachers.toList(growable: false);
    }

    final items = await teachersStream.first;
    teachers.assignAll(items);
    isTeachersReady.value = true;
    return items;
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
      courseTitle: courseTitleController.text.trim(),
      courseCode: courseCodeController.text.trim(),
      teacher: selectedTeacher.teacherName,
      teacherId: selectedTeacher.uid,
      room: roomController.text.trim(),
      department: selectedDepartment.depName,
      departmentId: selectedDepartment.id,
      classSectionId: ClassSectionIdentity.build(
        departmentId: selectedDepartment.id,
        departmentName: selectedDepartment.depName,
        semester: selectedSemester,
        shift: selectedShift,
      ),
      semester: selectedSemester,
      shift: selectedShift,
    );
  }

  Widget _buildBottomSheetContainer({
    required Widget child,
    double radius = 20,
  }) {
    final context = Get.context!;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBottomSheetHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD6DEEC),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        18.verticalSpace,
        CustomText(
          text: title,
          fontSize: AppSizes.s20,
          fontWeight: AppWeights.bold,
        ),
        6.verticalSpace,
        CustomText(
          text: subtitle,
          color: const Color(0xFF61748E),
          fontSize: AppSizes.s14,
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text, {bool isRequired = false}) {
    return CustomText(
      isRequired: isRequired,
      text: text,
      fontSize: AppSizes.s14,
      fontWeight: AppWeights.bold,
    );
  }

  Widget _buildSelectionPlaceholder({
    required String message,
    IconData icon = AppIcons.info_outline_rounded,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE6F2)),
      ),
      child: Row(
        children: [
          Container(
            height: 34.h,
            width: 34.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: AppSizes.s18),
          ),
          12.horizontalSpace,
          Expanded(
            child: CustomText(
              text: message,
              color: const Color(0xFF496483),
              fontSize: AppSizes.s13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherSelector() {
    return Obx(() {
      if (teachers.isEmpty) {
        return _buildSelectionPlaceholder(
          message: isTeachersReady.value
              ? 'Add a teacher first to assign timetable entries.'
              : 'Teacher list is syncing and will appear here shortly.',
          icon: AppIcons.school_outlined,
        );
      }

      return CustomDropdown<TeacherModel>(
        items: teachers.toList(growable: false),
        itemLabel: (item) => item.teacherName,
        valueListenable: timetableTeacherNotifier,
        hintText: AppStrings.teacherNameHint,
        onChanged: (value) {
          timetableTeacherNotifier.value = value;
        },
      );
    });
  }

  Widget _buildDepartmentSelector({
    required ValueNotifier<DepartmentModel?> notifier,
    required String hintText,
    required String emptyMessage,
  }) {
    return Obx(() {
      if (departments.isEmpty) {
        return _buildSelectionPlaceholder(
          message: isDepartmentsReady.value
              ? emptyMessage
              : 'Department list is syncing and will appear here shortly.',
          icon: AppIcons.apartment_outlined,
        );
      }

      return CustomDropdown<DepartmentModel>(
        items: departments.toList(growable: false),
        itemLabel: (item) => item.depName,
        valueListenable: notifier,
        onChanged: (value) {
          notifier.value = value;
        },
        hintText: hintText,
      );
    });
  }

  Widget _buildRoomFieldSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextFormField(
          hintText: AppStrings.roomHint,
          controller: roomController,
        ),
        10.verticalSpace,
        _buildRoomAvailabilityPanel(),
      ],
    );
  }

  Widget _buildRoomAvailabilityPanel() {
    return AnimatedBuilder(
      animation: Listenable.merge([dayNotifier, shiftNotifier, roomController]),
      builder: (context, _) {
        return Obx(() {
          final busyRooms = occupiedRoomsForCurrentSelection(
            excludeTimetableId: editingTimetableId.value,
          );
          final availableRooms = availableRoomsForCurrentSelection(
            excludeTimetableId: editingTimetableId.value,
          );
          final roomConflictMessage = currentRoomConflictMessage(
            excludeTimetableId: editingTimetableId.value,
          );

          if (!canCheckRoomAvailability) {
            return _buildSelectionPlaceholder(
              message:
                  'Select the day and time first to check which rooms are free.',
              icon: AppIcons.event_available_outlined,
            );
          }

          if (knownRooms.isEmpty) {
            return _buildSelectionPlaceholder(
              message:
                  'No scheduled rooms found yet. Save the first room to build room availability.',
              icon: AppIcons.meeting_room_outlined,
            );
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDE6F2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      AppIcons.meeting_room_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: CustomText(
                        text: 'Room availability for this slot',
                        fontWeight: AppWeights.bold,
                        fontSize: AppSizes.s14,
                        color: const Color(0xFF193252),
                      ),
                    ),
                  ],
                ),
                10.verticalSpace,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildRoomStatusPill(
                      label: '${availableRooms.length} available',
                      backgroundColor: const Color(0xFFE7F6EF),
                      textColor: const Color(0xFF157347),
                    ),
                    _buildRoomStatusPill(
                      label: '${busyRooms.length} occupied',
                      backgroundColor: const Color(0xFFFFF1F1),
                      textColor: AppColors.red,
                      // const Color(0xFFC23B3B),
                    ),
                  ],
                ),
                if (availableRooms.isNotEmpty) ...[
                  12.verticalSpace,
                  CustomText(
                    text: 'Tap a free room',
                    fontSize: AppSizes.s12,
                    fontWeight: AppWeights.w600,
                    color: const Color(0xFF61748E),
                  ),
                  8.verticalSpace,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableRooms
                        .map(
                          (room) => InkWell(
                            onTap: () {
                              roomController.text = room;
                              roomController.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(offset: room.length),
                                  );
                            },
                            borderRadius: BorderRadius.circular(999),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFCFE0D5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 14,
                                    color: Color(0xFF157347),
                                  ),
                                  6.horizontalSpace,
                                  Text(
                                    room,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF157347),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (busyRooms.isNotEmpty) ...[
                  12.verticalSpace,
                  CustomText(
                    text: 'Already occupied',
                    fontSize: AppSizes.s12,
                    fontWeight: AppWeights.w600,
                    color: const Color(0xFF61748E),
                  ),
                  8.verticalSpace,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: busyRooms
                        .map(
                          (room) => _buildRoomStatusPill(
                            label: room,
                            backgroundColor: const Color(0xFFFFF1F1),
                            textColor: AppColors.red,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (roomConflictMessage != null) ...[
                  12.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF2C5C5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          AppIcons.warning_amber_rounded,
                          color: Color(0xFFC23B3B),
                          size: AppSizes.s18,
                        ),
                        8.horizontalSpace,
                        Expanded(
                          child: CustomText(
                            text: roomConflictMessage,
                            color: const Color(0xFFA23A3A),
                            fontSize: AppSizes.s12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildRoomStatusPill({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppSizes.s12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
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
          child: CustomButton(
            borderColor: AppColors.primary,
            onPressed: () {
              Get.back();
            },
            text: AppStrings.cancel,
            color: AppColors.white,
            borderRadius: 14,
            height: 57.h,
            textColor: AppColors.primary,
          ),
        ),
        10.horizontalSpace,
        Expanded(
          child: CustomButton(
            onPressed: onConfirm,
            text: confirmText,
            color: AppColors.primary,
            borderRadius: 14.r,
            height: 57.h,
            textColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  void _showAdminBottomSheet({required Widget child, double radius = 25}) {
    Get.bottomSheet(
      _buildBottomSheetContainer(radius: radius, child: child),
      isScrollControlled: true,
    );
  }

  void openCreateBottomSheet() {
    resetTimetableForm();
    _showTimetableBottomSheet(
      title: AppStrings.addTimetableEntry,
      subtitle: AppStrings.CreateTimetableEntry,
      confirmText: AppStrings.save,
      onSubmit: saveData,
    );
  }

  Future<void> openEditTimetableBottomSheet(TimetableModel timetable) async {
    resetTimetableForm();
    editingTimetableId.value = timetable.id;
    courseTitleController.text = timetable.courseTitle;
    courseCodeController.text = timetable.courseCode;
    roomController.text = timetable.room;
    dayNotifier.value = timetable.day;
    semesterNotifier.value = timetable.semester;
    shiftNotifier.value = timetable.shift;
    _setTimeRangeFromValue(timetable.time);

    final teacherItems = await _resolveTeachers();
    final departmentItems = await _resolveDepartments();

    timetableTeacherNotifier.value = _findTeacherByIdOrName(
      teacherItems,
      teacherId: timetable.teacherId,
      teacherName: timetable.teacher,
    );
    timetableDepartmentNotifier.value = _findDepartmentByIdOrName(
      departmentItems,
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
    _showAdminBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottomSheetHeader(title: title, subtitle: subtitle),
          22.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel(AppStrings.day, isRequired: true),
                    6.verticalSpace,
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
                    _buildSectionLabel(AppStrings.time, isRequired: true),
                    6.verticalSpace,
                    buildTimeRange(),
                  ],
                ),
              ),
            ],
          ),
          10.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: AppStrings.CourseTitle,
                      isRequired: true,
                      fontSize: AppSizes.s14,
                      fontWeight: AppWeights.bold,
                    ),
                    5.verticalSpace,
                    CustomTextFormField(
                      hintText: AppStrings.courseTitleHint,
                      controller: courseTitleController,
                    ),
                  ],
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: AppStrings.courseCode,
                      isRequired: true,
                      fontSize: AppSizes.s14,
                      fontWeight: AppWeights.bold,
                    ),
                    5.verticalSpace,
                    CustomTextFormField(
                      hintText: AppStrings.courseCodeHint,
                      controller: courseCodeController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.verticalSpace,
          CustomText(
            text: AppStrings.teacher,
            isRequired: true,
            fontSize: AppSizes.s14,
            fontWeight: AppWeights.bold,
          ),
          8.verticalSpace,
          _buildTeacherSelector(),
          10.verticalSpace,
          CustomText(
            text: AppStrings.room,
            isRequired: true,
            fontSize: AppSizes.s14,
            fontWeight: AppWeights.bold,
          ),
          8.verticalSpace,
          _buildRoomFieldSection(),
          14.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: AppStrings.dept,
                      isRequired: true,
                      fontSize: AppSizes.s14,
                      fontWeight: AppWeights.bold,
                    ),
                    6.verticalSpace,
                    CustomDropdown(
                      items: departments,
                      itemLabel: (item) => item.depName,
                      valueListenable: timetableDepartmentNotifier,
                      onChanged: (value) {
                        timetableDepartmentNotifier.value = value;
                      },
                      hintText: AppStrings.depNameHint,
                    ),
                  ],
                ),
              ),
              10.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel(AppStrings.semester, isRequired: true),
                    6.verticalSpace,
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
          12.verticalSpace,
          _buildSectionLabel(AppStrings.shift, isRequired: true),
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
          22.verticalSpace,
          _buildBottomSheetActions(
            confirmText: confirmText,
            onConfirm: onSubmit,
          ),
        ],
      ),
    );
  }

  Widget buildTimeRange() {
    return Obx(
      () => GestureDetector(
        onTap: pickTimeRange,
        child: Container(
          height: 57.h,
          width: double.infinity,
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
              const Icon(AppIcons.timer, size: AppSizes.s22),
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
    if (courseTitleController.text.trim().isEmpty) errors.add("Course Title");
    if (courseCodeController.text.trim().isEmpty) errors.add("Course Code");
    if (timetableTeacherNotifier.value == null) errors.add("Teacher");
    if (roomController.text.trim().isEmpty) errors.add("Room");
    if (timetableDepartmentNotifier.value == null) errors.add("Department");
    if (semesterNotifier.value == null) errors.add("Semester");
    if (shiftNotifier.value == null) errors.add("Shift");

    if (errors.isNotEmpty) {
      AppSnackbar.error("Missing Fields", "Please fill: ${errors.join(", ")}");
      return false;
    }

    if (_parseTimeRange("${startTime.value} - ${endTime.value}") == null) {
      AppSnackbar.error(
        "Invalid Time",
        "Please select a valid time range where the end time is after the start time.",
      );
      return false;
    }

    final roomConflictMessage = currentRoomConflictMessage(
      excludeTimetableId: editingTimetableId.value,
    );
    if (roomConflictMessage != null) {
      AppSnackbar.error("Room Unavailable", roomConflictMessage);
      return false;
    }

    return true;
  }

  Future<void> saveData() async {
    if (!validate()) return;

    final timetableModel = _buildTimetableModel();

    if (timetableModel == null) return;

    try {
      // SAVE TIMETABLE
      await _timetableService.addTimetable(timetableModel);

      // SEND NOTIFICATION
      await NotificationService.sendNotification(
        title: "New Timetable Added",
        message:
            "Timetable added of Department ${timetableModel.department} Semester ${timetableModel.semester} Shift ${timetableModel.shift} Time${timetableModel.time}",
      );

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

    // OLD DATA
    final oldEntry = timetableEntries.firstWhere((e) => e.id == id);

    String message = "Timetable updated";

    // DAY
    if (oldEntry.day != timetableModel.day) {
      message =
          "Department ${timetableModel.department} Semester ${timetableModel.semester} day changed from ${oldEntry.day} to ${timetableModel.day}";
    }
    // TIME
    else if (oldEntry.time != timetableModel.time) {
      message =
          "Time changed from ${oldEntry.time} to ${timetableModel.time} Department ${timetableModel.department} Semester ${timetableModel.semester}";
    }
    // COURSE TITLE
    else if (oldEntry.courseTitle != timetableModel.courseTitle) {
      message =
          "Course title changed from ${oldEntry.courseTitle} to ${timetableModel.courseTitle} for Semester ${timetableModel.semester}";
    }
    // COURSE CODE
    else if (oldEntry.courseCode != timetableModel.courseCode) {
      message =
          "Course code changed from ${oldEntry.courseCode} to ${timetableModel.courseCode} for Department ${timetableModel.department}";
    }
    // TEACHER
    else if (oldEntry.teacher != timetableModel.teacher) {
      message =
          "Teacher changed from ${oldEntry.teacher} to ${timetableModel.teacher} for ${timetableModel.courseTitle} of Semester ${timetableModel.semester}";
    }
    // ROOM
    else if (oldEntry.room != timetableModel.room) {
      message =
          "Room changed from ${oldEntry.room} to ${timetableModel.room} for Semester ${timetableModel.semester} Department ${timetableModel.department}";
    }
    // DEPARTMENT
    else if (oldEntry.department != timetableModel.department) {
      message =
          "Department changed from ${oldEntry.department} to ${timetableModel.department} Semester ${timetableModel.semester} Shift ${timetableModel.shift}";
    }
    // SHIFT
    else if (oldEntry.shift != timetableModel.shift) {
      message =
          "Shift changed from ${oldEntry.shift} to ${timetableModel.shift} Department ${timetableModel.department} Semester ${timetableModel.semester}";
    }

    try {
      // UPDATE FIRESTORE
      await _timetableService.updateTimetable(id, timetableModel);

      // SEND NOTIFICATION
      await NotificationService.sendNotification(
        title: "Timetable Updated",
        message: message,
      );

      Get.back();

      AppSnackbar.success("Updated", "Timetable Updated Successfully");

      resetTimetableForm();
    } catch (e) {
      AppSnackbar.error("Error", e.toString());
    }
  }

  void openDepartmentBottomSheet() {
    resetDepartmentForm();

    _showAdminBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomSheetHeader(
            title: AppStrings.addDept,
            subtitle: AppStrings.addNewDept,
          ),
          22.verticalSpace,
          _buildSectionLabel(AppStrings.deptName, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            hintText: AppStrings.deptName,
            controller: deptController,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.deptCode, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            hintText: AppStrings.deptHint,
            controller: deptCodeController,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.deptDescription),
          6.verticalSpace,
          CustomTextFormField(
            maxLines: 3,
            hintText: AppStrings.deptDescription,
            controller: descriptionController,
          ),
          18.verticalSpace,
          _buildBottomSheetActions(
            confirmText: AppStrings.save,
            onConfirm: saveDepartment,
          ),
        ],
      ),
    );
  }

  bool validateDept() {
    final errors = <String>[];

    if (deptController.text.trim().isEmpty) errors.add("Department Name");
    if (deptCodeController.text.trim().isEmpty) errors.add("Department Code");

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
        adminId: _activeUserId,
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

    _showAdminBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomSheetHeader(
            title: AppStrings.addNewTeacher,
            subtitle: AppStrings.AddTeacherToSystem,
          ),
          22.verticalSpace,
          _buildSectionLabel(AppStrings.teacherName, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            hintText: AppStrings.teacherNameHint,
            controller: teacherNameController,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.email, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            hintText: AppStrings.teacherEmailHint,
            controller: teacherEmailController,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.teacherPhone),
          6.verticalSpace,
          CustomTextFormField(
            hintText: AppStrings.teacherPhoneHit,
            controller: teacherPhoneController,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.teacherDept, isRequired: true),
          6.verticalSpace,
          _buildDepartmentSelector(
            notifier: teacherDepartmentNotifier,
            hintText: AppStrings.teacherDeptHint,
            emptyMessage: 'Create a department first to assign teachers.',
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.teacherSpecialization),
          6.verticalSpace,
          CustomTextFormField(
            hintText: AppStrings.teacherSpecializationHint,
            controller: teacherSpecializationController,
          ),
          18.verticalSpace,
          _buildBottomSheetActions(
            confirmText: AppStrings.save,
            onConfirm: saveTeacher,
          ),
        ],
      ),
    );
  }

  bool validateTeacher() {
    final errors = <String>[];

    if (teacherNameController.text.trim().isEmpty) errors.add("Teacher Name");
    if (teacherEmailController.text.trim().isEmpty) errors.add("Email");
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
        adminId: _activeUserId,
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

  Future<void> openEditTeacherSheet(TeacherModel teacher) async {
    resetTeacherForm();

    teacherNameController.text = teacher.teacherName;
    teacherEmailController.text = teacher.teacherEmail;
    teacherPhoneController.text = teacher.teacherPhoneNo;
    teacherSpecializationController.text = teacher.teacherSpecialization;

    final departmentItems = await _resolveDepartments();
    teacherDepartmentNotifier.value = _findDepartmentByIdOrName(
      departmentItems,
      departmentId: teacher.teacherDeptId,
      departmentName: teacher.teacherDept,
    );

    _showAdminBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottomSheetHeader(
            title: AppStrings.editTeacher,
            subtitle: 'Update the teacher profile and save your changes.',
          ),
          22.verticalSpace,
          _buildSectionLabel(AppStrings.fullName, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            controller: teacherNameController,
            hintText: AppStrings.fullName,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.email, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            controller: teacherEmailController,
            hintText: AppStrings.email,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.teacherPhone),
          6.verticalSpace,
          CustomTextFormField(
            controller: teacherPhoneController,
            hintText: AppStrings.teacherPhoneHit,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.departments, isRequired: true),
          6.verticalSpace,
          _buildDepartmentSelector(
            notifier: teacherDepartmentNotifier,
            hintText: AppStrings.departments,
            emptyMessage: 'Create a department first to assign teachers.',
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.teacherSpecialization),
          6.verticalSpace,
          CustomTextFormField(
            controller: teacherSpecializationController,
            hintText: AppStrings.teacherSpecializationHint,
          ),
          18.verticalSpace,
          _buildBottomSheetActions(
            confirmText: AppStrings.update,
            onConfirm: () => updateTeacher(teacher.uid),
          ),
        ],
      ),
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
      final model = TeacherModel(
        adminId: _activeUserId,
        uid: id,
        teacherName: teacherNameController.text.trim(),
        teacherEmail: teacherEmailController.text.trim(),
        teacherPhoneNo: teacherPhoneController.text.trim(),
        teacherDept: selectedDepartment.depName,
        teacherDeptId: selectedDepartment.id,
        teacherSpecialization: teacherSpecializationController.text.trim(),
      );

      await _teacherService.updateTeacher(id, model);

      Get.back();
      AppSnackbar.success("Updated", "Teacher Updated Successfully");
      resetTeacherForm();
    } catch (_) {
      AppSnackbar.error("Error", "Update failed");
    }
  }

  void openEditDepartmentSheet(DepartmentModel department) {
    resetDepartmentForm();
    deptController.text = department.depName;
    deptCodeController.text = department.depCode;
    descriptionController.text = department.description;

    _showAdminBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBottomSheetHeader(
            title: AppStrings.editDept,
            subtitle: 'Refresh department details and keep records aligned.',
          ),
          22.verticalSpace,
          _buildSectionLabel(AppStrings.deptName, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            controller: deptController,
            hintText: AppStrings.depNameHint,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.deptCode, isRequired: true),
          6.verticalSpace,
          CustomTextFormField(
            controller: deptCodeController,
            hintText: AppStrings.deptHint,
          ),
          10.verticalSpace,
          _buildSectionLabel(AppStrings.deptDescription),
          6.verticalSpace,
          CustomTextFormField(
            controller: descriptionController,
            hintText: AppStrings.deptDescription,
            maxLines: 3,
          ),
          18.verticalSpace,
          _buildBottomSheetActions(
            confirmText: AppStrings.update,
            onConfirm: () => updateDepartment(department.id),
          ),
        ],
      ),
    );
  }

  Future<void> updateDepartment(String id) async {
    if (!validateDept()) return;

    try {
      final model = DepartmentModel(
        adminId: _activeUserId,
        id: id,
        depName: deptController.text.trim(),
        depCode: deptCodeController.text.trim(),
        description: descriptionController.text.trim(),
      );

      await _departmentService.updateDepartment(id, model);

      Get.back();
      AppSnackbar.success("Updated", "Department Updated Successfully");
      resetDepartmentForm();
    } catch (_) {
      AppSnackbar.error("Error", "Update failed");
    }
  }
}