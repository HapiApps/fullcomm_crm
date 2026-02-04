class CustomerActivity {
  final String id;
  final String sentId;
  final String toData;
  final String fromData;
  final String subject;
  final String sentDate;
  final String message;
  final String sentCount;
  final String callType;
  final String callStatus;
  final String quotationName;
  final String customerName;
  final String leadStatus;
  final String attachment;

  CustomerActivity({
    required this.id,
    required this.sentId,
    required this.toData,
    required this.fromData,
    required this.subject,
    required this.sentDate,
    required this.message,
    required this.sentCount,
    required this.quotationName,
    required this.customerName,
    required this.callType,
    required this.leadStatus,
    required this.callStatus,
    required this.attachment
  });

  factory CustomerActivity.fromJson(Map<String, dynamic> json) {
    return CustomerActivity(
      id: json['id']?.toString() ?? '',
      sentId: json['sent_id']?.toString() ?? '',
      toData: json['to_data']?.toString() ?? '',
      fromData: json['from_data']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      sentDate: json['sent_date']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      sentCount: json['sent_count']?.toString() ?? '',
      quotationName: json['quotation_name']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      callType: json['call_type']?.toString() ?? '',
      callStatus: json['call_status']?.toString() ?? '',
      leadStatus: json['lead_status']?.toString() ?? '',
      attachment: json['attachment']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sent_id': sentId,
      'to_data': toData,
      'from_data': fromData,
      'subject': subject,
      'sent_date': sentDate,
      'message': message,
      'sent_count': sentCount,
      'quotation_name': quotationName,
      'customer_name': customerName,
      'call_type': callType,
      'call_status': callStatus,
      'lead_status': leadStatus,
      'attachment':attachment
    };
  }
}
