import 'package:smart_timetable_managment/models/timetable_model.dart';

class TimetableGridData {
  final List<String> days;
  final List<TimetableGridRow> rows;

  const TimetableGridData({required this.days, required this.rows});

  bool get isEmpty => rows.isEmpty;
}

class TimetableGridRow {
  final String timeLabel;
  final Map<String, List<TimetableModel>> entriesByDay;

  const TimetableGridRow({required this.timeLabel, required this.entriesByDay});

  List<TimetableModel> entriesForDay(String day) {
    return entriesByDay[day] ?? const <TimetableModel>[];
  }
}