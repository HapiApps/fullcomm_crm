class MailReceiveObj {
  String? id;
  String? fromData;
  String? subject;
  String? sentDate;
  String? message;

  MailReceiveObj(
      {this.id, this.fromData, this.subject, this.sentDate, this.message});

  factory MailReceiveObj.fromJson(Map<String, dynamic> json) => MailReceiveObj(
    message: json["message"]?.toString() ?? '',
    sentDate: json["sent_date"]?.toString() ?? '',
    fromData: json["created_ts"]?.toString() ?? '',
    subject: json["subject"]?.toString() ?? '',
    id: json['id']?.toString() ?? '',
  );


  Map<String, dynamic> toJson() => {
        "id": id,
        "created_ts": fromData,
        "subject": subject,
        "sent_date": sentDate,
        "message": message
      };
}
