class CustomerField {
  final String id;
  final String systemField;
  final String userHeading;
  final String isRequired;

  CustomerField({
    required this.id,
    required this.systemField,
    required this.userHeading,
    required this.isRequired,
  });

  factory CustomerField.fromJson(Map<String, dynamic> json) {
    return CustomerField(
      id: json['id']?.toString() ?? '',
      systemField: json['system_field']?.toString() ?? '',
      userHeading: json['user_heading']?.toString() ?? '',
      isRequired: json['is_required']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "system_field": systemField,
      "user_heading": userHeading,
      "is_required": isRequired,
    };
  }
}
