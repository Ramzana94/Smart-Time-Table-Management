import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/services/timetable_service.dart';
import 'package:smart_timetable_managment/core/utils/app_snack_bar.dart';
import 'package:smart_timetable_managment/models/timetable_grid_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';

class TimetableController extends GetxController {
  final TimetableService _timetableService = TimetableService();

  final RxnString selectedDepartment = RxnString();
  final RxnString selectedSemester = RxnString();
  final RxnString selectedShift = RxnString();

  static const List<String> _weekDayOrder = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static const List<String> _shiftOrder = <String>['Morning', 'Evening'];

  Stream<List<TimetableModel>> getTimetable() {
    return _timetableService.getTimetable();
  }

  Stream<List<TimetableModel>> getTimetableByAdminId(String adminId) {
    return _timetableService.getTimetableByAdminId(adminId);
  }

  Future<void> deleteTimetable(String id) async {
    try {
      await _timetableService.deleteTimetable(id);
      AppSnackbar.success('Deleted', 'Timetable deleted successfully');
    } catch (_) {
      AppSnackbar.error('Error', 'Failed to delete timetable');
    }
  }

  void updateDepartment(String? value) {
    selectedDepartment.value = value;
    selectedSemester.value = null;
    selectedShift.value = null;
  }

  void updateSemester(String? value) {
    selectedSemester.value = value;
    selectedShift.value = null;
  }

  void updateShift(String? value) {
    selectedShift.value = value;
  }

  List<String> departmentOptions(List<TimetableModel> entries) {
    final departments =
        entries
            .map((entry) => entry.department.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return departments;
  }

  List<String> semesterOptions(
    List<TimetableModel> entries, {
    String? department,
  }) {
    final semesters =
        entries
            .where(
              (entry) =>
                  department == null || entry.department.trim() == department,
            )
            .map((entry) => entry.semester.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => _semesterOrder(a).compareTo(_semesterOrder(b)));
    return semesters;
  }

  List<String> shiftOptions(
    List<TimetableModel> entries, {
    String? department,
    String? semester,
  }) {
    final shifts =
        entries
            .where(
              (entry) =>
                  (department == null ||
                      entry.department.trim() == department) &&
                  (semester == null || entry.semester.trim() == semester),
            )
            .map((entry) => entry.shift.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => _shiftOrderIndex(a).compareTo(_shiftOrderIndex(b)));
    return shifts;
  }

  String? resolveSelection(String? currentValue, List<String> options) {
    if (options.isEmpty) {
      return null;
    }
    if (currentValue != null && options.contains(currentValue)) {
      return currentValue;
    }
    return options.first;
  }

  String? validSelectionOrNull(String? currentValue, List<String> options) {
    if (currentValue == null) {
      return null;
    }

    return options.contains(currentValue) ? currentValue : null;
  }

  List<TimetableModel> filterEntries(
    List<TimetableModel> entries, {
    String? department,
    String? semester,
    String? shift,
  }) {
    return entries.where((entry) {
      final matchesDepartment =
          department == null || entry.department.trim() == department;
      final matchesSemester =
          semester == null || entry.semester.trim() == semester;
      final matchesShift = shift == null || entry.shift.trim() == shift;
      return matchesDepartment && matchesSemester && matchesShift;
    }).toList();
  }

  TimetableGridData buildGrid(List<TimetableModel> entries) {
    if (entries.isEmpty) {
      return const TimetableGridData(days: _weekDayOrder, rows: []);
    }

    final normalizedDays = _orderedDays(entries);

    // Get unique time ranges in order of appearance
    final uniqueTimeRanges = <String>[];
    final timeRangeOrder = <String, int>{};

    for (final entry in entries) {
      final timeRange = entry.time.trim();
      if (timeRange.isNotEmpty && !uniqueTimeRanges.contains(timeRange)) {
        timeRangeOrder[timeRange] = uniqueTimeRanges.length;
        uniqueTimeRanges.add(timeRange);
      }
    }

    if (uniqueTimeRanges.isEmpty) {
      return const TimetableGridData(days: _weekDayOrder, rows: []);
    }

    // Sort time ranges by start time in ascending order
    uniqueTimeRanges.sort((a, b) {
      final aStart = _getStartTimeMinutes(a);
      final bStart = _getStartTimeMinutes(b);
      return aStart.compareTo(bStart);
    });

    final rows = <TimetableGridRow>[];

    // Create one row per unique time range
    for (final timeRange in uniqueTimeRanges) {
      final entriesByDay = <String, List<TimetableModel>>{};

      for (final day in normalizedDays) {
        final matchingEntries =
            entries
                .where(
                  (entry) =>
                      _normalizeDay(entry.day) == day &&
                      entry.time.trim() == timeRange,
                )
                .toList()
              ..sort(
                (a, b) => a.courseTitle.toLowerCase().compareTo(
                  b.courseTitle.toLowerCase(),
                ),
              );
        entriesByDay[day] = matchingEntries;
      }

      rows.add(
        TimetableGridRow(timeLabel: timeRange, entriesByDay: entriesByDay),
      );
    }

    return TimetableGridData(days: normalizedDays, rows: rows);
  }

  int totalSessions(List<TimetableModel> entries) {
    return entries.length;
  }

  List<String> _orderedDays(List<TimetableModel> entries) {
    final availableDays = entries
        .map((entry) => _normalizeDay(entry.day))
        .where((value) => value.isNotEmpty)
        .toSet();

    final extraDays =
        availableDays.where((day) => !_weekDayOrder.contains(day)).toList()
          ..sort();

    return [..._weekDayOrder, ...extraDays];
  }

  String _normalizeDay(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final lower = trimmed.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  int _getStartTimeMinutes(String timeRange) {
    final trimmed = timeRange.trim();
    if (trimmed.isEmpty) {
      return 9999;
    }

    final parts = trimmed
        .split('-')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 9999;
    }

    return _parseClockValue(parts.first);
  }

  int _semesterOrder(String semester) {
    return int.tryParse(semester.replaceAll(RegExp(r'[^0-9]'), '')) ?? 999;
  }

  int _shiftOrderIndex(String shift) {
    final index = _shiftOrder.indexWhere(
      (item) => item.toLowerCase() == shift.toLowerCase(),
    );
    return index == -1 ? 999 : index;
  }

  int _parseClockValue(String raw) {
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

    return 9999;
  }
}