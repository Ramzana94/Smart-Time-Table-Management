
import 'package:smart_timetable_managment/models/department_model.dart';
import 'package:smart_timetable_managment/models/teacher_model.dart';

class DepartmentAnalyticsItem {
  final DepartmentModel department;
  final int sessionCount;
  final int teacherCount;
  final int roomCount;
  final double share;

  const DepartmentAnalyticsItem({
    required this.department,
    required this.sessionCount,
    required this.teacherCount,
    required this.roomCount,
    required this.share,
  });
}

class TeacherWorkloadItem {
  final TeacherModel teacher;
  final int sessionCount;
  final int activeDays;
  final int assignedRooms;
  final String loadLabel;

  const TeacherWorkloadItem({
    required this.teacher,
    required this.sessionCount,
    required this.activeDays,
    required this.assignedRooms,
    required this.loadLabel,
  });
}

class RoomAvailabilityItem {
  final String roomName;
  final int bookedSlots;
  final int availableSlots;
  final int activeDays;
  final double utilizationRate;

  const RoomAvailabilityItem({
    required this.roomName,
    required this.bookedSlots,
    required this.availableSlots,
    required this.activeDays,
    required this.utilizationRate,
  });
}