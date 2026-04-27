class DepartmentModel {
  final String id;
  final String depName;
  final String depCode;
  final String description;

  const DepartmentModel({
    this.id = '',
    required this.depName,
    required this.depCode,
    required this.description,
  });

  factory DepartmentModel.fromJson(
    Map<String, dynamic> json, {
    String id = '',
  }) {
    return DepartmentModel(
      id: id,
      depName: json['depName'] ?? '',
      depCode: json['depCode'] ?? '',
      description: json['description'] ?? '',
    );
  }

  DepartmentModel copyWith({
    String? id,
    String? depName,
    String? depCode,
    String? description,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      depName: depName ?? this.depName,
      depCode: depCode ?? this.depCode,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {'depName': depName, 'depCode': depCode, 'description': description};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DepartmentModel) return false;
    if (id.isNotEmpty && other.id.isNotEmpty) {
      return other.id == id;
    }
    return other.depName == depName &&
        other.depCode == depCode &&
        other.description == description;
  }

  @override
  int get hashCode {
    if (id.isNotEmpty) {
      return id.hashCode;
    }
    return Object.hash(depName, depCode, description);
  }
}