import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/services/timetable_service.dart';
import 'package:smart_timetable_managment/models/timetable_grid_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';

class TimetableController extends GetxController {
  final TimetableService _timetableService = TimetableService();

  static const String allDepartmentsLabel = 'All Departments';
  static const String allSemestersLabel = 'All Semesters';
  static const String allShiftsLabel = 'All Shifts';

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

  Future<void> deleteTimetable(String id) async {
    try {
      await _timetableService.deleteTimetable(id);
      Get.snackbar(
        'Deleted',
        'Timetable deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Failed to delete timetable',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  void setFilters({String? department, String? semester, String? shift}) {
    selectedDepartment.value = department;
    selectedSemester.value = semester;
    selectedShift.value = shift;
  }

  void resetFilters() {
    selectedDepartment.value = null;
    selectedSemester.value = null;
    selectedShift.value = null;
  }

  bool get hasActiveFilters =>
      selectedDepartment.value != null ||
      selectedSemester.value != null ||
      selectedShift.value != null;

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
    if (currentValue != null && options.contains(currentValue)) {
      return currentValue;
    }
    return null;
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

  // TimetableGridData buildGrid(List<TimetableModel> entries) {
  //   if (entries.isEmpty) {
  //     return const TimetableGridData(days: _weekDayOrder, rows: []);
  //   }

  //   final normalizedDays = _orderedDays(entries);
  //   final expandedBoundaries = _expandedTimeBoundaries(entries);

  //   if (expandedBoundaries.length < 2) {
  //     return const TimetableGridData(days: _weekDayOrder, rows: []);
  //   }

  //   final rows = <TimetableGridRow>[];

  //   for (var index = 0; index < expandedBoundaries.length - 1; index++) {
  //     final slotStart = expandedBoundaries[index];
  //     final slotEnd = expandedBoundaries[index + 1];
  //     final entriesByDay = <String, List<TimetableModel>>{};

  //     for (final day in normalizedDays) {
  //       final matchingEntries =
  //           entries
  //               .where(
  //                 (entry) =>
  //                     _normalizeDay(entry.day) == day &&
  //                     _entryCoversSlot(entry, slotStart, slotEnd),
  //               )
  //               .toList()
  //             ..sort(
  //               (a, b) =>
  //                   a.courseTitle.toLowerCase().compareTo(b.courseTitle.toLowerCase()),
  //             );
  //       entriesByDay[day] = matchingEntries;
  //     }

  //     rows.add(
  //       TimetableGridRow(
  //         timeLabel: _formatTimeRange(slotStart, slotEnd),
  //         entriesByDay: entriesByDay,
  //       ),
  //     );
  //   }

  //   return TimetableGridData(days: normalizedDays, rows: rows);
  // }

TimetableGridData buildGrid(List<TimetableModel> entries) {
  if (entries.isEmpty) {
    return const TimetableGridData(days: _weekDayOrder, rows: []);
  }

  final normalizedDays = _orderedDays(entries);

  // 👉 Group entries by exact time (NO splitting)
  final Map<String, Map<String, List<TimetableModel>>> gridMap = {};

  for (final entry in entries) {
    final day = _normalizeDay(entry.day);
    final time = entry.time.trim();

    if (!gridMap.containsKey(time)) {
      gridMap[time] = {};
    }

    if (!gridMap[time]!.containsKey(day)) {
      gridMap[time]![day] = [];
    }

    gridMap[time]![day]!.add(entry);
  }

  // 👉 Sort time slots properly
  final sortedTimes = gridMap.keys.toList()
    ..sort((a, b) {
      final aRange = _parseTimeRange(a);
      final bRange = _parseTimeRange(b);

      if (aRange == null || bRange == null) return 0;
      return aRange.start.compareTo(bRange.start);
    });

  final rows = sortedTimes.map((time) {
    final entriesByDay = <String, List<TimetableModel>>{};

    for (final day in normalizedDays) {
      entriesByDay[day] = gridMap[time]?[day] ?? [];
    }

    return TimetableGridRow(
      timeLabel: time, // 👉 EXACT same time (no formatting)
      entriesByDay: entriesByDay,
    );
  }).toList();

  return TimetableGridData(days: normalizedDays, rows: rows);
}




  int totalSessions(List<TimetableModel> entries) {
    return entries.length;
  }

  List<String> _orderedDays(List<TimetableModel> entries) {
    final availableDays =
        entries
            .map((entry) => _normalizeDay(entry.day))
            .where((value) => value.isNotEmpty)
            .toSet();

    final extraDays =
        availableDays.where((day) => !_weekDayOrder.contains(day)).toList()
          ..sort();

    return [..._weekDayOrder, ...extraDays];
  }

  // List<int> _expandedTimeBoundaries(List<TimetableModel> entries) {
  //   final parsedRanges =
  //       entries
  //           .map((entry) => _parseTimeRange(entry.time))
  //           .whereType<({int start, int end})>()
  //           .where((range) => range.end > range.start)
  //           .toList();

  //   if (parsedRanges.isEmpty) {
  //     return const <int>[];
  //   }

  //   final sortedBoundaries =
  //       <int>{
  //           for (final range in parsedRanges) range.start,
  //           for (final range in parsedRanges) range.end,
  //         }.toList()
  //         ..sort();

  //   final slotStep = _slotStepMinutes(parsedRanges);
  //   if (slotStep == null || sortedBoundaries.length < 2) {
  //     return sortedBoundaries;
  //   }

  //   final expanded = <int>[sortedBoundaries.first];

  //   for (var index = 0; index < sortedBoundaries.length - 1; index++) {
  //     final current = sortedBoundaries[index];
  //     final next = sortedBoundaries[index + 1];

  //     var cursor = current + slotStep;
  //     while (cursor < next) {
  //       expanded.add(cursor);
  //       cursor += slotStep;
  //     }

  //     expanded.add(next);
  //   }

  //   return expanded.toSet().toList()..sort();
  // }



// ignore: unused_element
List<int> _getAllTimeBoundaries(List<TimetableModel> entries) {
  final boundaries = <int>{};

  for (final entry in entries) {
    final range = _parseTimeRange(entry.time);
    if (range != null && range.end > range.start) {
      boundaries.add(range.start);
      boundaries.add(range.end);
    }
  }

  final sorted = boundaries.toList()..sort();
  return sorted;
}

  // int? _slotStepMinutes(List<({int start, int end})> ranges) {
  //   int? shortestDuration;

  //   for (final range in ranges) {
  //     final duration = range.end - range.start;
  //     if (duration <= 0) {
  //       continue;
  //     }

  //     if (shortestDuration == null || duration < shortestDuration) {
  //       shortestDuration = duration;
  //     }
  //   }

  //   return shortestDuration;
  // }



  // bool _entryCoversSlot(TimetableModel entry, int slotStart, int slotEnd) {
  //   final range = _parseTimeRange(entry.time);
  //   if (range == null) {
  //     return false;
  //   }

  //   return range.start <= slotStart && range.end >= slotEnd;
  // }



  String _normalizeDay(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final lower = trimmed.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
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

  ({int start, int end})? _parseTimeRange(String timeRange) {
    final trimmed = timeRange.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final parts =
        trimmed
            .split('-')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();

    if (parts.length < 2) {
      return null;
    }

    final startMinutes = _parseClockValue(parts.first);
    final endMinutes = _parseClockValue(parts.sublist(1).join(' - '));

    if (startMinutes == 9999 ||
        endMinutes == 9999 ||
        endMinutes <= startMinutes) {
      return null;
    }

    return (start: startMinutes, end: endMinutes);
  }

  // String _formatTimeRange(int startMinutes, int endMinutes) {
  //   return '${_formatMinutes(startMinutes)} - ${_formatMinutes(endMinutes)}';
  // }



  // String _formatMinutes(int totalMinutes) {
  //   final hour24 = totalMinutes ~/ 60;
  //   final minute = totalMinutes % 60;
  //   final suffix = hour24 >= 12 ? 'PM' : 'AM';
  //   var hour12 = hour24 % 12;
  //   if (hour12 == 0) {
  //     hour12 = 12;
  //   }

  //   final minuteLabel = minute.toString().padLeft(2, '0');
  //   return '$hour12:$minuteLabel $suffix';
  // }



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

