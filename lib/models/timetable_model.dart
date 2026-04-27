class TimetableModel {
  final String id;
  final String day;
  final String time;
  final String subject;
  final String teacher;
  final String teacherId;
  final String room;
  final String department;
  final String departmentId;
  final String semester;
  final String shift;

  TimetableModel({
    this.id = '',
    required this.day,
    required this.time,
    required this.subject,
    required this.teacher,
    this.teacherId = '',
    required this.room,
    required this.department,
    this.departmentId = '',
    required this.semester,
    required this.shift,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return TimetableModel(
      id: id,
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      subject: json['subject'] ?? '',
      teacher: json['teacher'] ?? '',
      teacherId: json['teacherId'] ?? '',
      room: json['room'] ?? '',
      department: json['department'] ?? '',
      departmentId: json['departmentId'] ?? '',
      semester: json['semester'] ?? '',
      shift: json['shift'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'time': time,
      'subject': subject,
      'teacher': teacher,
      'teacherId': teacherId,
      'room': room,
      'department': department,
      'departmentId': departmentId,
      'semester': semester,
      'shift': shift,
    };
  }
}