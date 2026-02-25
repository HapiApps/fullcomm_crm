import 'package:get/get.dart';

import 'new_lead_obj.dart';

class AllCustomersObj {
  final String id, name, companyName, phoneNo, email,leadStatus;

  AllCustomersObj({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phoneNo,
    required this.email,
    required this.leadStatus,
  });

  factory AllCustomersObj.fromJson(Map<String, dynamic> json) {
    return AllCustomersObj(
      id: json['id']?.toString() ?? '',
      name: json['name'] == 'null' ? '' : json['name']?.toString() ?? '',
      companyName:
      json['company_name'] == 'null'
          ? ''
          : json['company_name']?.toString() ?? '',
      phoneNo: json['phone_no']?.toString() ?? '',
      leadStatus: json['lead_status']?.toString() ?? '',
      email: (json['email'] == 'null' || json['email'] == null)
          ? ''
          : json['email'].toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'phone_no': phoneNo,
      'email': email,
      'lead_status': leadStatus,
    };
  }
}

class LeadStatusModel {
  String leadStatus;
  String value;
  String id;
  String icon1;
  String icon2;
  RxList<NewLeadObj> list;
  RxList<NewLeadObj> list2;

  LeadStatusModel({
    required String leadStatus,
    required String value,
    required String id,
    required String icon1,
    required String icon2,
  })  : leadStatus = leadStatus,
        value = value,
        id = id,
        icon1 = icon1,
        icon2 = icon2,
        list = <NewLeadObj>[].obs,
        list2 = <NewLeadObj>[].obs;
  @override
  String toString() {
    return 'LeadStatusModel(leadStatus: $leadStatus, '
        'value: $value, '
        'id: $id, '
        'icon1: $icon1, '
        'icon2: $icon2, '
        'listCount: ${list.length}, '
        'list2Count: ${list2.length})';
  }
}

class AllEmployeesObj {
  final String id;
  final String name;
  final String phoneNo;
  final String email;

  AllEmployeesObj({
    required this.id,
    required this.name,
    required this.phoneNo,
    required this.email,
  });

  factory AllEmployeesObj.fromJson(Map<String, dynamic> json) {
    return AllEmployeesObj(
      id: json['id']?.toString() ?? '',
      name: json['s_name'] == 'null' ? '' : json['s_name']?.toString() ?? '',
      phoneNo: json['s_mobile']?.toString() ?? '',
      email: (json['email'] == 'null' || json['email'] == null)
          ? ''
          : json['email'].toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_no': phoneNo,
      'email': email,
    };
  }

  @override
  String toString() {
    return name;
  }
}

