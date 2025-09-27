import 'dart:convert';

StaffData staffDataFromJson(String str) => StaffData.fromJson(json.decode(str));

String staffDataToJson(StaffData data) => json.encode(data.toJson());

class StaffData {
  int? responseCode;
  String? result;
  String? responseMsg;
  List<Staff>? employees;

  StaffData({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.employees,
  });

  factory StaffData.fromJson(Map<String, dynamic> json) => StaffData(
    responseCode: json["responseCode"],
    result: json["result"],
    responseMsg: json["responseMsg"],
    employees: json["employees"] == null
        ? []
        : List<Staff>.from(json["employees"].map((x) => Staff.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "responseCode": responseCode,
    "result": result,
    "responseMsg": responseMsg,
    "employees": employees == null
        ? []
        : List<dynamic>.from(employees!.map((x) => x.toJson())),
  };
}

class Staff {
  String? id;
  String? sName;
  String? sMobile;
  String? email;
  String? sAddress;
  String? salary;
  String? bonus;
  String? dob;
  String? otherRoles;
  String? whatsapp;
  String? role;
  String? roleTitle; // <--- Added this line
  String? password;
  String? joiningDate;
  String? platform;
  String? upPlatform;
  String? active;
  String? updatedTs;
  String? createdTs;
  String? updatedBy;
  String? createdBy;
  String? cosId;

  Staff({
    this.id,
    this.sName,
    this.sMobile,
    this.email,
    this.sAddress,
    this.salary,
    this.bonus,
    this.dob,
    this.otherRoles,
    this.whatsapp,
    this.role,
    this.roleTitle, // <--- Added this line
    this.password,
    this.joiningDate,
    this.platform,
    this.upPlatform,
    this.active,
    this.updatedTs,
    this.createdTs,
    this.updatedBy,
    this.createdBy,
    this.cosId,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json["id"],
    sName: json["s_name"],
    sMobile: json["s_mobile"],
    email: json["email"],
    sAddress: json["s_address"],
    salary: json["salary"],
    bonus: json["bonus"],
    dob: json["dob"],
    otherRoles: json["other_roles"],
    whatsapp: json["whatsapp"],
    role: json["role"],
    roleTitle: json["role_title"], // <--- Mapped from JSON response
    password: json["password"],
    joiningDate: json["joining_date"],
    platform: json["platform"],
    upPlatform: json["up_platform"],
    active: json["active"],
    updatedTs: json["updated_ts"],
    createdTs: json["created_ts"],
    updatedBy: json["updated_by"],
    createdBy: json["created_by"],
    cosId: json["cos_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "s_name": sName,
    "s_mobile": sMobile,
    "email": email,
    "s_address": sAddress,
    "salary": salary,
    "bonus": bonus,
    "dob": dob,
    "other_roles": otherRoles,
    "whatsapp": whatsapp,
    "role": role,
    "role_title": roleTitle, // <--- Added this line to map to JSON
    "password": password,
    "joining_date": joiningDate,
    "platform": platform,
    "up_platform": upPlatform,
    "active": active,
    "updated_ts": updatedTs,
    "created_ts": createdTs,
    "updated_by": updatedBy,
    "created_by": createdBy,
    "cos_id": cosId,
  };
  List<String> toCsvRow() {
    return [
      id ?? '',
      cosId ?? '',
      sName ?? '',
      sMobile ?? '',
      email ?? '',
      sAddress ?? '',
      password ?? '',
      whatsapp ?? '',
      active ?? '',
      salary ?? '',
      bonus ?? '',
      dob ?? '',
      otherRoles ?? '',
      role ?? '',
      roleTitle ?? '',
      joiningDate ?? '',
    ];
  }

}
