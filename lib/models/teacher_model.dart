class TeacherModel {
  final String teacherName;
  final String teacherEmail;
  final String teacherPhoneNo;
  final String teacherDept;
  final String teacherSpecialization;

  const TeacherModel({
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherPhoneNo,
    required this.teacherDept,
    required this.teacherSpecialization,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      teacherName: json['teacherName'] ?? '',
      teacherEmail: json['teacherEmail'] ?? '',
      teacherPhoneNo: json['teacherPhoneNo'] ?? '',
      teacherDept: json['teacherDept'] ?? '',
      teacherSpecialization: json['teacherSpecialization'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherName': teacherName,
      'teacherEmail': teacherEmail,
      'teacherPhoneNo': teacherPhoneNo,
      'teacherDept': teacherDept,
      'teacherSpecialization': teacherSpecialization,
    };
  }
}