class TimetableModel {
  final String day;
  final String time;
  final String subject;
  final String teacher;
  final String room;
  final String department;
  final String semester;
  final String shift;

  TimetableModel({
    required this.day,
    required this.time,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.department,
    required this.semester,
    required this.shift,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      subject: json['subject'] ?? '',
      teacher: json['teacher'] ?? '',
      room: json['room'] ?? '',
      department: json['department'] ?? '',
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
      'room': room,
      'department': department,
      'semester': semester,
      'shift': shift,
    };
  }
}
