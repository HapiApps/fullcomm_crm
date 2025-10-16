class RoleModel {
  final String id;
  final String cosId;
  final String uId;
  final String roleName;
  final String description;
  final String permission;

  RoleModel({
    required this.id,
    required this.cosId,
    required this.uId,
    required this.roleName,
    required this.description,
    required this.permission
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] ?? '',
      cosId: json['cos_id'] ?? '',
      uId: json['u_id'] ?? '',
      roleName: json['role_name'] ?? '',
      description: json['description'] ?? '',
      permission: json['permission'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cos_id': cosId,
      'u_id': uId,
      'role_name': roleName,
      'description': description,
      'permission': permission
    };
  }
}
