class OfficeHoursObj {
  final String id;
  final String cosId;
  final String shiftName;
  final String fromTime;
  final String toTime;
  final String days;
  final String updatedTs;
  final String employeeName;

  OfficeHoursObj({
    required this.id,
    required this.cosId,
    required this.updatedTs,
    required this.employeeName,
    required this.shiftName,
    required this.fromTime,
    required this.toTime,
    required this.days,
  });

  factory OfficeHoursObj.fromJson(Map<String, dynamic> json) {
    return OfficeHoursObj(
      id: json['id'] ?? '',
      cosId: json['cos_id'] ?? '',
      updatedTs: json['updated_ts'] ?? '',
      employeeName: json['employee_name'] ?? '',
      shiftName: json['shift_name'] ?? '',
      fromTime: json['from_time'] ?? '',
      toTime: json['to_time'] ?? '',
      days: json['days'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cos_id': cosId,
      'updated_ts': updatedTs,
      'employee_name': employeeName,
      'shift_name': shiftName,
      'from_time': fromTime,
      'to_time': toTime,
      'days': days,
    };
  }
}
