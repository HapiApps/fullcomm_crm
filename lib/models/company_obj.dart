//SELECT id, name,mobile_number,email,company_name,status, rating FROM lead
class CompanyObj {
  String? id;
  String? coName;
  String? coIndustry;
  String? product;
  String? emailMap;
  String? phoneMap;
  String? city;

  CompanyObj(
      {this.id,
      this.city,
      this.phoneMap,
      this.coName,
      this.emailMap,
      this.coIndustry,
      this.product});

  factory CompanyObj.fromJson(Map<String, dynamic> json) => CompanyObj(
      id: json["id"],
      coIndustry: json["co_industry"],
      phoneMap: json["phone_map"],
      coName: json["co_name"],
      emailMap: json["email_map"],
      product: json["product"],
      city: json["city"]);
}
