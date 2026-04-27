class TeacherModel {
  final String id;
  final String teacherName;
  final String teacherEmail;
  final String teacherPhoneNo;
  final String teacherDept;
  final String teacherDeptId;
  final String teacherSpecialization;

  const TeacherModel({
    this.id = '',
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherPhoneNo,
    required this.teacherDept,
    this.teacherDeptId = '',
    required this.teacherSpecialization,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return TeacherModel(
      id: id,
      teacherName: json['teacherName'] ?? '',
      teacherEmail: json['teacherEmail'] ?? '',
      teacherPhoneNo: json['teacherPhoneNo'] ?? '',
      teacherDept: json['teacherDept'] ?? '',
      teacherDeptId: json['teacherDeptId'] ?? '',
      teacherSpecialization: json['teacherSpecialization'] ?? '',
    );
  }

  TeacherModel copyWith({
    String? id,
    String? teacherName,
    String? teacherEmail,
    String? teacherPhoneNo,
    String? teacherDept,
    String? teacherDeptId,
    String? teacherSpecialization,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      teacherName: teacherName ?? this.teacherName,
      teacherEmail: teacherEmail ?? this.teacherEmail,
      teacherPhoneNo: teacherPhoneNo ?? this.teacherPhoneNo,
      teacherDept: teacherDept ?? this.teacherDept,
      teacherDeptId: teacherDeptId ?? this.teacherDeptId,
      teacherSpecialization:
          teacherSpecialization ?? this.teacherSpecialization,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherName': teacherName,
      'teacherEmail': teacherEmail,
      'teacherPhoneNo': teacherPhoneNo,
      'teacherDept': teacherDept,
      'teacherDeptId': teacherDeptId,
      'teacherSpecialization': teacherSpecialization,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TeacherModel) return false;
    if (id.isNotEmpty && other.id.isNotEmpty) {
      return other.id == id;
    }
    return other.teacherName == teacherName &&
        other.teacherEmail == teacherEmail &&
        other.teacherPhoneNo == teacherPhoneNo &&
        other.teacherDept == teacherDept &&
        other.teacherDeptId == teacherDeptId &&
        other.teacherSpecialization == teacherSpecialization;
  }

  @override
  int get hashCode {
    if (id.isNotEmpty) {
      return id.hashCode;
    }
    return Object.hash(
      teacherName,
      teacherEmail,
      teacherPhoneNo,
      teacherDept,
      teacherDeptId,
      teacherSpecialization,
    );
  }
}