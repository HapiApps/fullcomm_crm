class AllCustomersObj {
  final String id;
  final String name;
  final String companyName;
  final String phoneNo;
  final String email;

  AllCustomersObj({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phoneNo,
    required this.email,
  });

  factory AllCustomersObj.fromJson(Map<String, dynamic> json) {
    return AllCustomersObj(
      id: json['id'] ?? '',
      name: json['name'] == 'null' ? '' : json['name'] ?? '',
      companyName: json['company_name'] == 'null' ? '' : json['company_name'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      email: (json['email'] == 'null' || json['email'] == null) ? '' : json['email'],
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
