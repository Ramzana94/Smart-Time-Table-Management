import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/user_session_controller.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/models/user_profile_model.dart';

class HomeDashboardController extends GetxController {
  final UserSessionController _userSessionController =
      Get.find<UserSessionController>();
  final AdminDashboardController _adminDashboardController =
      Get.find<AdminDashboardController>();

  UserProfileModel? get userProfile => _userSessionController.currentUser.value;

  String get userRole => _userSessionController.userRole;

  bool get isTeacher => _userSessionController.isTeacher;

  bool get isStudent => _userSessionController.isStudent;

  bool get isAdmin => _userSessionController.isAdmin;

  bool get isLoading {
    final isTeacherDataLoading =
        isTeacher && !_adminDashboardController.isTeachersReady.value;

    return _userSessionController.isLoading.value ||
        !_adminDashboardController.isTimetableReady.value ||
        isTeacherDataLoading;
  }

  TeacherModel? get linkedTeacher {
    final profile = userProfile;
    if (profile == null) {
      return null;
    }

    final explicitTeacherId = _normalize(profile.teacherId);
    final normalizedEmail = _normalize(profile.email);
    final normalizedName = _normalize(profile.name);

    for (final teacher in _adminDashboardController.teachers) {
      if (explicitTeacherId.isNotEmpty &&
          _normalize(teacher.uid) == explicitTeacherId) {
        return teacher;
      }
    }

    for (final teacher in _adminDashboardController.teachers) {
      if (normalizedEmail.isNotEmpty &&
          _normalize(teacher.teacherEmail) == normalizedEmail) {
        return teacher;
      }
    }

    for (final teacher in _adminDashboardController.teachers) {
      if (normalizedName.isNotEmpty &&
          _normalize(teacher.teacherName) == normalizedName) {
        return teacher;
      }
    }

    return null;
  }

  bool get hasStudentScheduleContext =>
      userProfile?.hasStudentScheduleContext ?? false;

  List<TimetableModel> get homeTimetable {
    return filterEntriesForCurrentUser(
      _adminDashboardController.timetableEntries,
    );
  }

  List<TimetableModel> get todayLectures {
    final today = _weekdayName(DateTime.now().weekday);
    final items = homeTimetable
        .where((entry) => _normalize(entry.day) == _normalize(today))
        .toList();
    items.sort(_compareByTime);
    return items;
  }

  List<TimetableModel> get upcomingLectures {
    final items = List<TimetableModel>.from(homeTimetable);
    final now = DateTime.now();
    items.sort((a, b) {
      final rankResult = _nextOccurrenceRank(
        a,
        now,
      ).compareTo(_nextOccurrenceRank(b, now));
      if (rankResult != 0) {
        return rankResult;
      }

      return a.subject.toLowerCase().compareTo(b.subject.toLowerCase());
    });
    return items;
  }

  int get totalClasses => homeTimetable.length;

  String get headerSubtitle {
    if (isTeacher) {
      final teacher = linkedTeacher;
      final name =
          teacher?.teacherName.trim() ?? userProfile?.name.trim() ?? '';
      if (name.isNotEmpty) {
        return '$name • Teaching schedule';
      }
      return 'Teaching schedule';
    }

    if (isStudent) {
      final profile = userProfile;
      if (profile == null) {
        return 'Student schedule';
      }

      final parts = <String>[];
      if (profile.department.trim().isNotEmpty) {
        parts.add(profile.department.trim());
      }
      if (profile.semester.trim().isNotEmpty) {
        parts.add('Semester ${profile.semester.trim()}');
      }
      if (profile.shift.trim().isNotEmpty) {
        parts.add(profile.shift.trim());
      }

      return parts.isEmpty ? 'Student schedule' : parts.join(' • ');
    }

    return 'Weekly timetable';
  }

  String? get homeNotice {
    if (isLoading) {
      return null;
    }

    if (isTeacher) {
      final profile = userProfile;
      final hasTeacherLink =
          linkedTeacher != null ||
          (profile?.teacherId.trim().isNotEmpty ?? false);

      if (!hasTeacherLink) {
        return 'This teacher account is not linked with a teacher record yet.';
      }

      if (homeTimetable.isEmpty) {
        return 'No timetable entries found for this teacher.';
      }
    }

    if (isStudent) {
      if (!hasStudentScheduleContext) {
        return 'Add department, semester, and shift in the user profile to show the student timetable.';
      }

      if (homeTimetable.isEmpty) {
        return 'No timetable entries found for this student schedule.';
      }
    }

    return null;
  }

  List<TimetableModel> filterEntriesForCurrentUser(
    List<TimetableModel> entries,
  ) {
    if (isTeacher) {
      return _sortByUpcoming(_filterTeacherEntries(entries));
    }

    if (isStudent) {
      return _sortByUpcoming(_filterStudentEntries(entries));
    }

    return _sortByUpcoming(entries);
  }

  List<TimetableModel> _filterTeacherEntries(List<TimetableModel> entries) {
    final profile = userProfile;
    if (profile == null) {
      return const <TimetableModel>[];
    }

    final teacherIds = <String>{};
    if (profile.teacherId.trim().isNotEmpty) {
      teacherIds.add(profile.teacherId.trim());
    }

    final teacher = linkedTeacher;
    if (teacher != null && teacher.uid.trim().isNotEmpty) {
      teacherIds.add(teacher.uid.trim());
    }

    if (teacherIds.isNotEmpty) {
      return entries
          .where((entry) => teacherIds.contains(entry.teacherId.trim()))
          .toList();
    }

    final teacherName = _normalize(teacher?.teacherName ?? profile.name);
    if (teacherName.isEmpty) {
      return const <TimetableModel>[];
    }

    return entries
        .where((entry) => _normalize(entry.teacher) == teacherName)
        .toList();
  }

  List<TimetableModel> _filterStudentEntries(List<TimetableModel> entries) {
    final profile = userProfile;
    if (profile == null || !profile.hasStudentScheduleContext) {
      return const <TimetableModel>[];
    }

    final departmentId = _normalize(profile.departmentId);
    final departmentName = _normalize(profile.department);
    final semester = _normalize(profile.semester);
    final shift = _normalize(profile.shift);

    return entries.where((entry) {
      final matchesDepartment =
          (departmentId.isNotEmpty &&
              _normalize(entry.departmentId) == departmentId) ||
          (departmentName.isNotEmpty &&
              _normalize(entry.department) == departmentName);

      return matchesDepartment &&
          _normalize(entry.semester) == semester &&
          _normalize(entry.shift) == shift;
    }).toList();
  }

  List<TimetableModel> _sortByUpcoming(List<TimetableModel> items) {
    final sorted = List<TimetableModel>.from(items);
    final now = DateTime.now();
    sorted.sort((a, b) {
      final rankResult = _nextOccurrenceRank(
        a,
        now,
      ).compareTo(_nextOccurrenceRank(b, now));
      if (rankResult != 0) {
        return rankResult;
      }

      return _compareByTime(a, b);
    });
    return sorted;
  }

  int _compareByTime(TimetableModel first, TimetableModel second) {
    final firstRange = _parseTimeRange(first.time);
    final secondRange = _parseTimeRange(second.time);
    final firstStart = firstRange?.start ?? 9999;
    final secondStart = secondRange?.start ?? 9999;
    return firstStart.compareTo(secondStart);
  }

  int _nextOccurrenceRank(TimetableModel entry, DateTime now) {
    final weekday = _weekdayIndex(entry.day);
    final range = _parseTimeRange(entry.time);
    if (weekday == null || range == null) {
      return 1 << 20;
    }

    var dayOffset = weekday - now.weekday;
    if (dayOffset < 0) {
      dayOffset += 7;
    }

    final currentMinutes = (now.hour * 60) + now.minute;
    if (dayOffset == 0 && range.end < currentMinutes) {
      dayOffset = 7;
    }

    return (dayOffset * 1440) + range.start;
  }

  ({int start, int end})? _parseTimeRange(String timeRange) {
    final parts = timeRange
        .split('-')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length < 2) {
      return null;
    }

    final startMinutes = _parseClockValue(parts.first);
    final endMinutes = _parseClockValue(parts.sublist(1).join(' - '));

    if (startMinutes == null ||
        endMinutes == null ||
        endMinutes <= startMinutes) {
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

  int? _weekdayIndex(String day) {
    switch (_normalize(day)) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return null;
    }
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _normalize(String value) => value.trim().toLowerCase();
}