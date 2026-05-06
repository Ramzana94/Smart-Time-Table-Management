
import 'package:smart_timetable_managment/core/utils/class_section_identity.dart';

class UserProfileModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String image;
  final String adminId;
  final String teacherId;
  final String studentId;
  final String department;
  final String departmentId;
  final String classSectionId;
  final String semester;
  final String shift;

  const UserProfileModel({
    this.uid = '',
    this.name = '',
    this.email = '',
    this.role = 'Student',
    this.image = '',
    this.adminId = '',
    this.teacherId = '',
    this.studentId = '',
    this.department = '',
    this.departmentId = '',
    this.classSectionId = '',
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

    final resolvedUid = id.isNotEmpty ? id : readFirst(const ['uid']);
    final resolvedRole = readFirst(const ['role']);
    final resolvedTeacherId = readFirst(const ['teacherId', 'linkedTeacherId']);
    final resolvedStudentId = readFirst(const ['studentId']);
    final normalizedRole = resolvedRole.trim().toLowerCase();

    return UserProfileModel(
      uid: resolvedUid,
      name: readFirst(const ['name', 'fullName']),
      email: readFirst(const ['email']),
      role: resolvedRole,
      image: readFirst(const ['image', 'photoUrl', 'photoURL']),
      adminId: readFirst(const [
        'adminId',
        'adminUid',
        'linkedAdminId',
        'ownerAdminId',
      ]),
      teacherId: resolvedTeacherId.isNotEmpty || normalizedRole != 'teacher'
          ? resolvedTeacherId
          : resolvedUid,
      studentId: resolvedStudentId.isNotEmpty || normalizedRole != 'student'
          ? resolvedStudentId
          : resolvedUid,
      department: readFirst(const ['department', 'dept', 'teacherDept']),
      departmentId: readFirst(const [
        'departmentId',
        'deptId',
        'teacherDeptId',
      ]),
      classSectionId: readFirst(const [
        'classSectionId',
        'sectionId',
        'classId',
        'classSection',
      ]),
      semester: readFirst(const ['semester']),
      shift: readFirst(const ['shift']),
    );
  }

  String get normalizedRole => role.trim().toLowerCase();

  bool get isAdmin => normalizedRole == 'admin';

  bool get isTeacher => normalizedRole == 'teacher';

  bool get isStudent => normalizedRole == 'student';

  String get effectiveTeacherId {
    if (teacherId.trim().isNotEmpty) {
      return teacherId.trim();
    }
    if (isTeacher && uid.trim().isNotEmpty) {
      return uid.trim();
    }
    return '';
  }

  String get effectiveStudentId {
    if (studentId.trim().isNotEmpty) {
      return studentId.trim();
    }
    if (isStudent && uid.trim().isNotEmpty) {
      return uid.trim();
    }
    return '';
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

  bool get hasStudentScheduleContext {
    return effectiveClassSectionId.isNotEmpty;
  }

  UserProfileModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? image,
    String? adminId,
    String? teacherId,
    String? studentId,
    String? department,
    String? departmentId,
    String? classSectionId,
    String? semester,
    String? shift,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      image: image ?? this.image,
      adminId: adminId ?? this.adminId,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      classSectionId: classSectionId ?? this.classSectionId,
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
      'adminId': adminId,
      // 'teacherId': effectiveTeacherId,
      // 'studentId': effectiveStudentId,
      'teacherId': isTeacher ? effectiveTeacherId : null,
      'studentId': isStudent ? effectiveStudentId : null,
      'department': department,
      'departmentId': departmentId,
      'classSectionId': effectiveClassSectionId,
      'semester': semester,
      'shift': shift,
    };
  }
}