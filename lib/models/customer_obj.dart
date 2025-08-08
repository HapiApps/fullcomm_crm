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
      id: json["user_id"],
      mainName: json["firstname"],
      mainMobile: json["phone"],
      mainEmail: json["email_id"],
      mainWhatsApp: json["emergency_number"],
      companyName: json["company_name"],
      status: json["status"],
      rating: json["rating"],
      emailUpdate: json["quotation_update"],
      name: json["emergency_name"],
      mobileNumber: json["mobile_number"],
      addressId: json["address_id"],
      leadStatus: json["lead_status"],
      active: json["active"],
      addressLine1: json["door_no"],
      addressLine2: json["landmark_1"],
      area: json["area"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      pinCode: json["pincode"],
      quotationStatus: json["quotation_status"],
      productDiscussion: json["product_discussion"],
      discussionPoint: json["discussion_point"],
      notes: json["points"],
      quotationRequired: json["quotation_required"],
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
