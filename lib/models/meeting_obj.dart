class MeetingObj {
  final String id;
  final String cusId;
  final String cusName;
  final String comName;
  final String title;
  final String venue;
  final String dates;
  final String time;
  final String notes;
  final String status;
  final String createdBy;
  final String employeeName;
  final String employee;

  MeetingObj({
    required this.id,
    required this.cusId,
    required this.cusName,
    required this.comName,
    required this.title,
    required this.venue,
    required this.dates,
    required this.time,
    required this.notes,
    required this.status,
    required this.createdBy,
    required this.employeeName,
    required this.employee,
  });

  factory MeetingObj.fromJson(Map<String, dynamic> json) {
    return MeetingObj(
      id: json['id']?.toString() ?? '',
      cusId: json['cus_id']?.toString() ?? '',
      cusName: json['cus_name']?.toString() ?? '',
      comName: json['com_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      venue: json['venue']?.toString() ?? '',
      dates: json['dates']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      employee: json['employee']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cus_id': cusId,
      'cus_name': cusName,
      'com_name': comName,
      'title': title,
      'venue': venue,
      'dates': dates,
      'time': time,
      'notes': notes,
      'status': status,
      'created_by': createdBy,
      'employee_name': employeeName,
      'employee': employee,
    };
  }
}
