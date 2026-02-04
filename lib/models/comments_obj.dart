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
    comments: json["comments"]?.toString() ?? '',
    date: json["date"]?.toString() ?? '',
    type: json["type"]?.toString() ?? '',
    createdTs: json["created_ts"] != null
        ? DateTime.parse(json["created_ts"].toString())
        : DateTime.now(),
    updateTs: json["updated_ts"] != null
        ? DateTime.parse(json["updated_ts"].toString())
        : DateTime.now(),
    name: json["name"]?.toString() ?? '',
    phoneNo: json["phone_no"]?.toString() ?? '',
    firstname: json["firstname"] == null || json["firstname"] == 'null'
        ? "Amutha"
        : json["firstname"].toString(),
    companyName: json["company_name"]?.toString() ?? '',
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
