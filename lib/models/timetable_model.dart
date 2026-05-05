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
  final String semester;
  final String shift;

  TimetableModel({
    this.id = '',
    required this.day,
    required this.time,
    required this.courseTitle,
    required this.teacher,
    this.teacherId = '',
    required this.room,
    required this.department,
    this.departmentId = '',
    required this.semester,
    required this.shift, required this.courseCode,
  });

  // ✅ ADD THIS METHOD
  TimetableModel copyWith({
    String? id,
    String? day,
    String? time,
    String? courseTitle,
    String? teacher,
    String? teacherId,
    String? room,
    String? department,
    String? departmentId,
    String? semester,
    String? shift,
  String? courseCode,
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
      semester: semester ?? this.semester,
      shift: shift ?? this.shift, 
    
    );
  }

  factory TimetableModel.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return TimetableModel(
      id: id,
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      courseTitle: json['courseTitle'] ?? '',
      courseCode: json['courseCode'] ?? '',
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
      'courseTitle': courseTitle,
       'courseCode': courseCode,
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