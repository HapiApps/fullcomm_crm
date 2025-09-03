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
  });

  factory MeetingObj.fromJson(Map<String, dynamic> json) {
    return MeetingObj(
      id: json['id'] ?? '',
      cusId: json['cus_id'] ?? '',
      cusName: json['cus_name'] ?? '',
      comName: json['com_name'] ?? '',
      title: json['title'] ?? '',
      venue: json['venue'] ?? '',
      dates: json['dates'] ?? '',
      time: json['time'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? '',
      createdBy: json['created_by'] ?? '',
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
    };
  }
}
