class TemplateModel {
  final String id;
  final String cosId;
  final String? templateName;
  final String? subject;
  final String? message;
  final String? active;
  final String? updatedBy;
  final String? createdBy;
  final String? createdTs;
  final String? updatedTs;

  TemplateModel({
    required this.id,
    required this.cosId,
    this.updatedBy,
    this.createdBy,
    this.createdTs,
    this.templateName,
    this.subject,
    this.message,
    this.active,
    this.updatedTs,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id']?.toString() ?? '',
      cosId: json['cos_id']?.toString() ?? '',
      templateName: json['template_name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      active: json['active']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdTs: json['created_ts']?.toString() ?? '',
      updatedTs: json['updated_ts']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cos_id': cosId,
      'template_name': templateName,
      'subject': subject,
      'message': message,
      'active': active,
      'updated_by': updatedBy,
      'created_by': createdBy,
      'created_ts': createdTs,
      'updated_ts': updatedTs,
    };
  }
}
