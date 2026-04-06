class UserDataResponse {
  int? responseCode;
  String? message;
  String? userType;
  UserData? userData;

  UserDataResponse({
    this.responseCode,
    this.message,
    this.userType,
    this.userData,
  });

  factory UserDataResponse.fromJson(Map<String, dynamic> json) =>
      UserDataResponse(
        responseCode: int.tryParse(json["responseCode"].toString()),
        message: json["message"]?.toString(),
        userType: json["userType"]?.toString(),
        userData:
        json["userData"] == null ? null : UserData.fromJson(json["userData"]),
      );

  Map<String, dynamic> toJson() => {
    "responseCode": responseCode,
    "message": message,
    "userType": userType,
    "userData": userData?.toJson(),
  };
}

class UserData {
  int? id;
  String? sName;
  String? sMobile;
  String? email;
  DateTime? dob;
  String? sAddress;
  String? salary;
  String? bonus;
  String? password;
  String? role;
  String? otherRoles;
  DateTime? joiningDate;
  String? whatsapp;
  String? secret;
  int? cancelAccess;

  UserData({
    this.id,
    this.sName,
    this.sMobile,
    this.email,
    this.dob,
    this.sAddress,
    this.salary,
    this.bonus,
    this.password,
    this.role,
    this.otherRoles,
    this.joiningDate,
    this.whatsapp,
    this.secret,
    this.cancelAccess,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: int.tryParse(json["id"].toString()),
    sName: json["s_name"]?.toString(),
    sMobile: json["s_mobile"]?.toString(),
    email: json["email"]?.toString(),
    dob: json["dob"] == null ? null : DateTime.tryParse(json["dob"].toString()),
    sAddress: json["s_address"]?.toString(),
    salary: json["salary"]?.toString(),
    bonus: json["bonus"]?.toString(),
    password: json["password"]?.toString(),
    role: json["role"]?.toString(),
    otherRoles: json["other_roles"]?.toString(),
    joiningDate: json["joining_date"] == null
        ? null
        : DateTime.tryParse(json["joining_date"].toString()),
    whatsapp: json["whatsapp"]?.toString(),
    secret: json["secret_code"]?.toString(), // ✅ FIXED
    cancelAccess: json["cancel_access"] == null
        ? 0
        : int.tryParse(json["cancel_access"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "s_name": sName,
    "s_mobile": sMobile,
    "email": email,
    "dob": dob == null
        ? null
        : "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
    "s_address": sAddress,
    "salary": salary,
    "bonus": bonus,
    "password": password,
    "role": role,
    "other_roles": otherRoles,
    "joining_date": joiningDate == null
        ? null
        : "${joiningDate!.year.toString().padLeft(4, '0')}-${joiningDate!.month.toString().padLeft(2, '0')}-${joiningDate!.day.toString().padLeft(2, '0')}",
    "whatsapp": whatsapp,
    "secret_code": secret,
    "cancel_access": cancelAccess,
  };
}