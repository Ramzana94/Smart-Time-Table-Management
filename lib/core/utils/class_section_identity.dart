class ClassSectionIdentity {
  const ClassSectionIdentity._();

  static String build({
    String explicitId = '',
    String departmentId = '',
    String departmentName = '',
    String semester = '',
    String shift = '',
  }) {
    final normalizedExplicitId = normalize(explicitId);
    if (normalizedExplicitId.isNotEmpty) {
      return normalizedExplicitId;
    }

    final normalizedDepartment = normalize(
      departmentId.trim().isNotEmpty ? departmentId : departmentName,
    );
    final normalizedSemester = normalize(semester);
    final normalizedShift = normalize(shift);

    if (normalizedDepartment.isEmpty ||
        normalizedSemester.isEmpty ||
        normalizedShift.isEmpty) {
      return '';
    }

    return '$normalizedDepartment|$normalizedSemester|$normalizedShift';
  }

  static String normalize(String value) {
    return value.trim().toLowerCase();
  }
}