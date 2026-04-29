class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String image;
  final String teacherId;
  final String studentId;
  final String department;
  final String departmentId;
  final String semester;
  final String shift;

  const UserProfileModel({
    this.uid = '',
    this.name = '',
    this.email = '',
    this.role = 'Student',
    this.image = '',
    this.teacherId = '',
    this.studentId = '',
    this.department = '',
    this.departmentId = '',
    this.semester = '',
    this.shift = '',
  });

  factory UserProfileModel.fromJson(
    Map<String, dynamic> json, {
    String id = '',
  }) {
    String readFirst(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) {
          continue;
        }

        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }

      return '';
    }

    return UserProfileModel(
      uid: id.isNotEmpty ? id : readFirst(const ['uid']),
      name: readFirst(const ['name', 'fullName']),
      email: readFirst(const ['email']),
      role: readFirst(const ['role']),
      image: readFirst(const ['image', 'photoUrl', 'photoURL']),
      teacherId: readFirst(const ['teacherId', 'linkedTeacherId']),
      studentId: readFirst(const ['studentId']),
      department: readFirst(const ['department', 'dept', 'teacherDept']),
      departmentId: readFirst(const [
        'departmentId',
        'deptId',
        'teacherDeptId',
      ]),
      semester: readFirst(const ['semester']),
      shift: readFirst(const ['shift']),
    );
  }

  String get normalizedRole => role.trim().toLowerCase();

  bool get isAdmin => normalizedRole == 'admin';

  bool get isTeacher => normalizedRole == 'teacher';

  bool get isStudent => normalizedRole == 'student';

  bool get hasStudentScheduleContext {
    final hasDepartment =
        departmentId.trim().isNotEmpty || department.trim().isNotEmpty;
    return hasDepartment &&
        semester.trim().isNotEmpty &&
        shift.trim().isNotEmpty;
  }

  UserProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? image,
    String? teacherId,
    String? studentId,
    String? department,
    String? departmentId,
    String? semester,
    String? shift,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      image: image ?? this.image,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      semester: semester ?? this.semester,
      shift: shift ?? this.shift,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'image': image,
      'teacherId': teacherId,
      'studentId': studentId,
      'department': department,
      'departmentId': departmentId,
      'semester': semester,
      'shift': shift,
    };
  }
}