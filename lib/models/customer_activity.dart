class CustomerActivity {
  final String id;
  final String sentId;
  final String toData;
  final String fromData;
  final String subject;
  final String sentDate;
  final String message;
  final String sentCount;
  final String quotationName;
  final String customerName;

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
  });

  factory CustomerActivity.fromJson(Map<String, dynamic> json) {
    return CustomerActivity(
      id: json['id'] ?? '',
      sentId: json['sent_id'] ?? '',
      toData: json['to_data'] ?? '',
      fromData: json['from_data'] ?? '',
      subject: json['subject'] ?? '',
      sentDate: json['sent_date'] ?? '',
      message: json['message'] ?? '',
      sentCount: json['sent_count'] ?? '',
      quotationName: json['quotation_name'] ?? '',
      customerName: json['customer_name'] ?? '',
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
    };
  }
}
