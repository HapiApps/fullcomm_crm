class AllCustomersObj {
  final String id, name, companyName, phoneNo, email;

  AllCustomersObj({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phoneNo,
    required this.email,
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
    };
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

