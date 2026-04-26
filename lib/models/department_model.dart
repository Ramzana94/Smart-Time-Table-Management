class DepartmentModel {
  final String depName;
  final String depCode;
  final String description;

  const DepartmentModel({
    required this.depName,
    required this.depCode,
    required this.description,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      depName: json['depName'] ?? '',
      depCode: json['depCode'] ?? '',
      description: json['description'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'depName': depName,
      'depCode': depCode,
      'description': description,
    };
  }
}