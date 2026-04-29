import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/models/admin_analytics_model.dart';
import 'package:smart_timetable_managment/models/department_model.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';


class AdminAnalyticsController extends GetxController {
  static const String allDaysLabel = 'All Days';
  static const String allShiftsLabel = 'All Shifts';

  final AdminDashboardController _adminDashboardController =
      Get.find<AdminDashboardController>();

  final selectedDay = allDaysLabel.obs;
  final selectedShift = allShiftsLabel.obs;

  List<String> get dayOptions => <String>[
    allDaysLabel,
    ..._adminDashboardController.days,
  ];

  List<String> get shiftOptions => <String>[
    allShiftsLabel,
    ..._adminDashboardController.shifts,
  ];

  bool get isReady =>
      _adminDashboardController.isDepartmentsReady.value &&
      _adminDashboardController.isTeachersReady.value &&
      _adminDashboardController.isTimetableReady.value;

  int get overallTeachers => _adminDashboardController.teachers.length;

  int get overallDepartments => _adminDashboardController.departments.length;

  List<TimetableModel> get filteredEntries {
    return _adminDashboardController.timetableEntries.where((entry) {
      final matchesDay =
          selectedDay.value == allDaysLabel ||
          _normalize(entry.day) == _normalize(selectedDay.value);
      final matchesShift =
          selectedShift.value == allShiftsLabel ||
          _normalize(entry.shift) == _normalize(selectedShift.value);
      return matchesDay && matchesShift;
    }).toList();
  }

  int get totalClasses => filteredEntries.length;

  int get activeTeachers =>
      teacherWorkloads.where((item) => item.sessionCount > 0).length;

  int get activeDepartments =>
      departmentAnalytics.where((item) => item.sessionCount > 0).length;

  int get totalRooms => filteredEntries
      .map((entry) => entry.room.trim())
      .where((room) => room.isNotEmpty)
      .toSet()
      .length;

  int get activeDaysCount => filteredEntries
      .map((entry) => entry.day.trim())
      .where((day) => day.isNotEmpty)
      .toSet()
      .length;

  int get unassignedRoomCount =>
      filteredEntries.where((entry) => entry.room.trim().isEmpty).length;

  double get roomAssignmentRate {
    if (filteredEntries.isEmpty) {
      return 0;
    }

    final assignedRooms = filteredEntries
        .where((entry) => entry.room.trim().isNotEmpty)
        .length;
    return assignedRooms / filteredEntries.length;
  }

  String get busiestDayLabel {
    if (filteredEntries.isEmpty) {
      return 'No active day';
    }

    final counts = <String, int>{};
    for (final entry in filteredEntries) {
      final day = entry.day.trim();
      if (day.isEmpty) continue;
      counts.update(day, (value) => value + 1, ifAbsent: () => 1);
    }

    if (counts.isEmpty) {
      return 'No active day';
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final busiest = sortedEntries.first;
    return '${busiest.key} (${busiest.value})';
  }

  String get peakDepartmentLabel {
    final items = departmentAnalytics;
    if (items.isEmpty || items.first.sessionCount == 0) {
      return 'No department load';
    }

    final leading = items.first;
    return '${leading.department.depName} (${leading.sessionCount})';
  }

  void updateDay(String value) {
    selectedDay.value = value;
  }

  void updateShift(String value) {
    selectedShift.value = value;
  }

  List<DepartmentAnalyticsItem> get departmentAnalytics {
    final entries = filteredEntries;
    final departments = _adminDashboardController.departments;
    final teachers = _adminDashboardController.teachers;
    final totalSessions = entries.length;

    final items =
        departments.map((department) {
          final departmentEntries = entries
              .where((entry) => _matchesDepartment(entry, department))
              .toList();

          final teacherCount = teachers
              .where(
                (teacher) => _normalize(teacher.teacherDeptId).isNotEmpty
                    ? teacher.teacherDeptId == department.id
                    : _normalize(teacher.teacherDept) ==
                          _normalize(department.depName),
              )
              .length;

          final roomCount = departmentEntries
              .map((entry) => entry.room.trim())
              .where((room) => room.isNotEmpty)
              .toSet()
              .length;

          return DepartmentAnalyticsItem(
            department: department,
            sessionCount: departmentEntries.length,
            teacherCount: teacherCount,
            roomCount: roomCount,
            share: totalSessions == 0
                ? 0
                : departmentEntries.length / totalSessions,
          );
        }).toList()..sort((a, b) {
          final sessionCompare = b.sessionCount.compareTo(a.sessionCount);
          if (sessionCompare != 0) {
            return sessionCompare;
          }
          return a.department.depName.toLowerCase().compareTo(
            b.department.depName.toLowerCase(),
          );
        });

    return items;
  }

  List<TeacherWorkloadItem> get teacherWorkloads {
    final entries = filteredEntries;

    final items =
        _adminDashboardController.teachers.map((teacher) {
          final teacherEntries = entries
              .where((entry) => _matchesTeacher(entry, teacher))
              .toList();

          return TeacherWorkloadItem(
            teacher: teacher,
            sessionCount: teacherEntries.length,
            activeDays: teacherEntries
                .map((entry) => entry.day.trim())
                .where((day) => day.isNotEmpty)
                .toSet()
                .length,
            assignedRooms: teacherEntries
                .map((entry) => entry.room.trim())
                .where((room) => room.isNotEmpty)
                .toSet()
                .length,
            loadLabel: _loadLabel(teacherEntries.length),
          );
        }).toList()..sort((a, b) {
          final sessionCompare = b.sessionCount.compareTo(a.sessionCount);
          if (sessionCompare != 0) {
            return sessionCompare;
          }
          return a.teacher.teacherName.toLowerCase().compareTo(
            b.teacher.teacherName.toLowerCase(),
          );
        });

    return items;
  }

  List<RoomAvailabilityItem> get roomAvailability {
    final entriesWithRooms = filteredEntries
        .where((entry) => entry.room.trim().isNotEmpty)
        .toList();

    final allSlots = filteredEntries
        .map((entry) => _slotKey(entry))
        .where((slot) => slot.isNotEmpty)
        .toSet();
    final totalSlots = allSlots.length;

    final rooms = _adminDashboardController.knownRooms;

    final items =
        rooms.map((room) {
          final roomEntries = entriesWithRooms
              .where((entry) => _normalize(entry.room) == _normalize(room))
              .toList();
          final bookedSlots = roomEntries.map(_slotKey).toSet().length;
          final availableSlots = totalSlots > bookedSlots
              ? totalSlots - bookedSlots
              : 0;

          return RoomAvailabilityItem(
            roomName: room,
            bookedSlots: bookedSlots,
            availableSlots: availableSlots,
            activeDays: roomEntries
                .map((entry) => entry.day.trim())
                .where((day) => day.isNotEmpty)
                .toSet()
                .length,
            utilizationRate: totalSlots == 0 ? 0 : bookedSlots / totalSlots,
          );
        }).toList()..sort((a, b) {
          final availabilityCompare = b.availableSlots.compareTo(
            a.availableSlots,
          );
          if (availabilityCompare != 0) {
            return availabilityCompare;
          }
          return a.roomName.toLowerCase().compareTo(b.roomName.toLowerCase());
        });

    return items;
  }

  bool _matchesDepartment(TimetableModel entry, DepartmentModel department) {
    if (department.id.isNotEmpty && entry.departmentId.isNotEmpty) {
      return entry.departmentId == department.id;
    }

    return _normalize(entry.department) == _normalize(department.depName);
  }

  bool _matchesTeacher(TimetableModel entry, TeacherModel teacher) {
    if (teacher.uid.isNotEmpty && entry.teacherId.isNotEmpty) {
      return entry.teacherId == teacher.uid;
    }

    return _normalize(entry.teacher) == _normalize(teacher.teacherName);
  }

  String _normalize(String value) => value.trim().toLowerCase();

  String _slotKey(TimetableModel entry) {
    final day = entry.day.trim();
    final time = entry.time.trim();
    if (day.isEmpty || time.isEmpty) {
      return '';
    }
    return '$day|$time';
  }

  String _loadLabel(int sessions) {
    if (sessions >= 6) {
      return 'High load';
    }
    if (sessions >= 3) {
      return 'Balanced';
    }
    if (sessions > 0) {
      return 'Light load';
    }
    return 'Available';
  }
}