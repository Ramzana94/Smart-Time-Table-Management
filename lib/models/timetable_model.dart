import 'package:smart_timetable_managment/core/utils/class_section_identity.dart';
class TimetableModel {
  final String id;
  final String day;
  final String time;
  final String courseTitle;
  final String courseCode;
  final String teacher;
  final String teacherId;
  final String room;
  final String department;
  final String departmentId;
  final String classSectionId;
  final String semester;
  final String shift;

  const TimetableModel({
    this.id = '',
    required this.day,
    required this.time,
    required this.courseTitle,
    required this.courseCode,
    required this.teacher,
    this.teacherId = '',
    required this.room,
    required this.department,
    this.departmentId = '',
    this.classSectionId = '',
    required this.semester,
    required this.shift,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json, {String id = ''}) {
    final department = (json['department'] ?? '').toString();
    final departmentId = (json['departmentId'] ?? '').toString();
    final semester = (json['semester'] ?? '').toString();
    final shift = (json['shift'] ?? '').toString();

    return TimetableModel(
      id: id,
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      courseTitle: json['courseTitle'] ?? '',
      courseCode: json['courseCode'] ?? '',
      teacher: json['teacher'] ?? '',
      teacherId: json['teacherId'] ?? '',
      room: json['room'] ?? '',
      department: department,
      departmentId: departmentId,
      classSectionId: ClassSectionIdentity.build(
        explicitId:
            (json['classSectionId'] ??
                    json['sectionId'] ??
                    json['classId'] ??
                    '')
                .toString(),
        departmentId: departmentId,
        departmentName: department,
        semester: semester,
        shift: shift,
      ),
      semester: semester,
      shift: shift,
    );
  }

  String get effectiveClassSectionId {
    return ClassSectionIdentity.build(
      explicitId: classSectionId,
      departmentId: departmentId,
      departmentName: department,
      semester: semester,
      shift: shift,
    );
  }

  TimetableModel copyWith({
    String? id,
    String? day,
    String? time,
    String? courseTitle,
    String? courseCode,
    String? teacher,
    String? teacherId,
    String? room,
    String? department,
    String? departmentId,
    String? classSectionId,
    String? semester,
    String? shift,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      day: day ?? this.day,
      time: time ?? this.time,
      courseTitle: courseTitle ?? this.courseTitle,
      courseCode: courseCode ?? this.courseCode,
      teacher: teacher ?? this.teacher,
      teacherId: teacherId ?? this.teacherId,
      room: room ?? this.room,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      classSectionId: classSectionId ?? this.classSectionId,
      semester: semester ?? this.semester,
      shift: shift ?? this.shift,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'time': time,
      'courseTitle': courseTitle,
      'courseCode': courseCode,
      'teacher': teacher,
      'teacherId': teacherId,
      'room': room,
      'department': department,
      'departmentId': departmentId,
      'classSectionId': effectiveClassSectionId,
      'semester': semester,
      'shift': shift,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TimetableModel) return false;

    if (id.isNotEmpty && other.id.isNotEmpty) {
      return other.id == id;
    }

    return other.day == day &&
        other.time == time &&
        other.courseTitle == courseTitle &&
        other.courseCode == courseCode &&
        other.teacher == teacher &&
        other.room == room &&
        other.department == department &&
        other.effectiveClassSectionId == effectiveClassSectionId &&
        other.semester == semester &&
        other.shift == shift;
  }

  @override
  int get hashCode {
    if (id.isNotEmpty) {
      return id.hashCode;
    }

    return Object.hash(
      day,
      time,
      courseTitle,
      courseCode,
      teacher,
      room,
      department,
      effectiveClassSectionId,
      semester,
      shift,
    );
  }
}