class CommentsObj {
  String comments;
  String date;
  String type;
  DateTime createdTs;
  DateTime updateTs;
  String name;
  String phoneNo;
  String? firstname;
  String companyName;

  CommentsObj(
      {required this.comments,
      required this.date,
      required this.type,
      required this.createdTs,
      required this.name,
      required this.phoneNo,
      this.firstname,
      required this.companyName,
      required this.updateTs});

  factory CommentsObj.fromJson(Map<String, dynamic> json) => CommentsObj(
        comments: json["comments"],
        date: json["date"],
        type: json["type"],
        createdTs: DateTime.parse(json["created_ts"]),
        updateTs: DateTime.parse(json["updated_ts"]),
        name: json["name"],
        phoneNo: json["phone_no"],
        firstname: json["firstname"] ?? "Amutha",
        companyName: json["company_name"],
      );

  Map<String, dynamic> toJson() => {
        "comments": comments,
        "date": date,
        "type": type,
        "created_ts": createdTs.toIso8601String(),
        "updated_ts": createdTs.toIso8601String(),
        "name": name,
        "phone_no": phoneNo,
        "firstname": firstname,
        "company_name": companyName,
      };
}
