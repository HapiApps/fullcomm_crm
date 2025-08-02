
class MailReceiveObj {
  String? id;
  String? fromData;
  String? subject;
  String? sentDate;
  String? message;

  MailReceiveObj({
     this.id,
     this.fromData,
     this.subject,
     this.sentDate,
     this.message
  });

  factory MailReceiveObj.fromJson(Map<String, dynamic> json) => MailReceiveObj(
    message: json["message"],
    sentDate: json["sent_date"],
    fromData: json["created_ts"],
    subject: json["subject"],
    id: json['id']
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_ts": fromData,
    "subject": subject,
    "sent_date": sentDate,
    "message": message
  };
}