class CustomersObj {
  String? id;
  String? mainName;
  String? mainMobile;
  String? mainEmail;
  String? mainWhatsApp;
  String? companyName;
  String? status;
  String? rating;
  String? emailUpdate;
  String? name;
  String? title;
  String? mobileNumber;
  String? whatsappNumber;
  String? email;
  String? mainTitle;
  String? addressId;
  String? companyWebsite;
  String? companyNumber;
  String? companyEmail;
  String? industry;
  String? productServices;
  String? source;
  String? owner;
  String? budget;
  String? timelineDecision;
  String? serviceInterest;
  String? description;
  String? leadStatus;
  String? active;
  String? addressLine1;
  String? addressLine2;
  String? area;
  String? city;
  String? state;
  String? country;
  String? pinCode;
  String? linkedin;
  String? x;
  String? quotationStatus;
  String? productDiscussion;
  String? discussionPoint;
  String? notes;
  String? quotationRequired;

  CustomersObj(
      {this.id,
      this.mainName,
      this.mainMobile,
      this.mainEmail,
      this.companyName,
      this.status,
      this.rating,
      this.emailUpdate,
      this.name,
      this.title,
      this.mobileNumber,
      this.whatsappNumber,
      this.email,
      this.mainTitle,
      this.addressId,
      this.companyWebsite,
      this.companyNumber,
      this.companyEmail,
      this.industry,
      this.productServices,
      this.source,
      this.owner,
      this.budget,
      this.timelineDecision,
      this.serviceInterest,
      this.description,
      this.leadStatus,
      this.active,
      this.addressLine1,
      this.addressLine2,
      this.area,
      this.city,
      this.state,
      this.country,
      this.pinCode,
      this.mainWhatsApp,
      this.linkedin,
      this.x,
      this.quotationStatus,
      this.productDiscussion,
      this.discussionPoint,
      this.notes,
      this.quotationRequired});

  factory CustomersObj.fromJson(Map<String?, dynamic> json) {
    return CustomersObj(
      id: json["user_id"]?.toString() ?? '',
      mainName: json["firstname"]?.toString() ?? '',
      mainMobile: json["phone"]?.toString() ?? '',
      mainEmail: json["email_id"]?.toString() ?? '',
      mainWhatsApp: json["emergency_number"]?.toString() ?? '',
      companyName: json["company_name"]?.toString() ?? '',
      status: json["status"]?.toString() ?? '',
      rating: json["rating"]?.toString() ?? '',
      emailUpdate: json["quotation_update"]?.toString() ?? '',
      name: json["emergency_name"]?.toString() ?? '',
      mobileNumber: json["mobile_number"]?.toString() ?? '',
      addressId: json["address_id"]?.toString() ?? '',
      leadStatus: json["lead_status"]?.toString() ?? '',
      active: json["active"]?.toString() ?? '',
      addressLine1: json["door_no"]?.toString() ?? '',
      addressLine2: json["landmark_1"]?.toString() ?? '',
      area: json["area"]?.toString() ?? '',
      city: json["city"]?.toString() ?? '',
      state: json["state"]?.toString() ?? '',
      country: json["country"]?.toString() ?? '',
      pinCode: json["pincode"]?.toString() ?? '',
      quotationStatus: json["quotation_status"]?.toString() ?? '',
      productDiscussion: json["product_discussion"]?.toString() ?? '',
      discussionPoint: json["discussion_point"]?.toString() ?? '',
      notes: json["points"]?.toString() ?? '',
      quotationRequired: json["quotation_required"]?.toString() ?? '',
    );
  }

  Map<String?, dynamic> toJson() {
    return {
      "user_id": id,
      "firstname": mainName,
      "phone": mainMobile,
      "email_id": mainEmail,
      "emergency_number": mainWhatsApp,
      "company_name": companyName,
      "status": status,
      "rating": rating,
      "quotation_update": emailUpdate,
      "emergency_name": name,
      "address_id": addressId,
      "lead_status": leadStatus,
      "active": active,
      "door_no": addressLine1,
      "address_line_2": addressLine2,
      "area": area,
      "city": city,
      "state": state,
      "country": country,
      "pincode": pinCode,
      "product_discussion": productDiscussion,
      "quotation_required": quotationRequired,
      "points": notes,
      "quotation_status": quotationStatus,
      "discussion_point": discussionPoint
    };
  }
}
