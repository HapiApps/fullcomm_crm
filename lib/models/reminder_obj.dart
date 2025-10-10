class ReminderModel {
  final String id;
  final String cosId;
  final String title;
  final String type;
  final String location;
  final String repeatType;
  final String startDt;
  final String endDt;
  final String details;
  final String? updatedBy;
  final String createdBy;
  final String createdTs;
  final String updatedTs;
  final String employeeName;
  final String customerName;

  ReminderModel({
    required this.id,
    required this.cosId,
    required this.title,
    required this.type,
    required this.location,
    required this.repeatType,
    required this.startDt,
    required this.endDt,
    required this.details,
    this.updatedBy,
    required this.createdBy,
    required this.createdTs,
    required this.updatedTs,
    required this.employeeName,
    required this.customerName,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] ?? '',
      cosId: json['cos_id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      repeatType: json['repeat_type'] ?? '',
      startDt: json['start_dt'] ?? '',
      endDt: json['end_dt'] ?? '',
      details: json['details'] ?? '',
      updatedBy: json['updated_by'],
      createdBy: json['created_by'] ?? '',
      createdTs: json['created_ts'] ?? '',
      updatedTs: json['updated_ts'] ?? '',
      employeeName: json['employee_name'] ?? '',
      customerName: json['customer_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cos_id': cosId,
      'title': title,
      'type': type,
      'location': location,
      'repeat_type': repeatType,
      'start_dt': startDt,
      'end_dt': endDt,
      'details': details,
      'updated_by': updatedBy,
      'created_by': createdBy,
      'created_ts': createdTs,
      'updated_ts': updatedTs,
      'employee_name': employeeName,
      'customer_name': customerName,
    };
  }
}
