class NewLeadObj {
  final String? userId;
  final String? addressId;
  final String? firstname;
  final String? lineId;
  final String? mobileNumber;
  final String? emergencyName;
  final String? emergencyNumber;
  final String? email;
  final String? whatsapp;
  final String? type;
  final String? referredBy;
  final String? img1;
  final String? img2;
  final String? doorNo;
  final String? area;
  final String? landmark1;
  final String? city;
  final String? country;
  final String? state;
  final String? pincode;
  final String? tier;
  final String? lat;
  final String? lng;
  final String? companyName;
  final String? companyNumber;
  final String? companyWebsite;
  final String? companyEmail;
  final String? linkedin;
  final String? leadStatus;
  final String? rating;
  final String? quotationUpdate;
  final String? active;
  final String? quotationStatus;
  final String? productDiscussion;
  final String? discussionPoint;
  final String? notes;
  final String? quotationRequired;
  final String? arpuValue;
  final String? source;
  final String? sourceDetails;
  final String? status;
  final String? owner;
  final String? prospectEnrollmentDate;
  final String? expectedConvertionDate;
  final String? statusUpdate;
  final String? numOfHeadcount;
  final String? expectedBillingValue;
  final String? updatedTs;
  final String? createdTs;
  final String? points;
  final String? discussionPoints;
  final String? visitType;
  final String? accountManager;
  final String? prospectGrading;
  final String? detailsOfServiceRequired;
  final String? additionalInfo;
  final String? industry;
  final String? product;
  final String? x;

  NewLeadObj(
      {this.userId,
        this.companyNumber, this.companyWebsite, this.companyEmail, this.linkedin,
        this.addressId,
      this.firstname,
      this.lineId,
      this.mobileNumber,
      this.emergencyName,
      this.emergencyNumber,
      this.email,
      this.type,
      this.referredBy,
      this.img1,
      this.img2,
      this.doorNo,
      this.area,
      this.landmark1,
      this.city,
      this.country,
      this.state,
      this.pincode,
      this.tier,
      this.lat,
      this.lng,
      this.companyName,
      this.quotationUpdate,
      this.rating,
      this.leadStatus,
      this.active,
      this.quotationStatus,
      this.productDiscussion,
      this.discussionPoint,
      this.notes,
      this.quotationRequired,
      this.arpuValue,
      this.expectedBillingValue,
      this.expectedConvertionDate,
      this.numOfHeadcount,
      this.owner,
      this.prospectEnrollmentDate,
      this.source,
      this.sourceDetails,
      this.status,
      this.statusUpdate,
      this.updatedTs,
      this.discussionPoints,
      this.points,
      this.visitType,
      this.createdTs,
      this.accountManager,
      this.prospectGrading,
      this.detailsOfServiceRequired,
        this.additionalInfo,
        this.whatsapp,this.industry,this.product,this.x
      });
  factory NewLeadObj.fromJson(Map<String, dynamic> json) {
    return NewLeadObj(
      userId: json["user_id"]?.toString() ?? '',
      addressId: json["address_id"]?.toString() ?? '',
      firstname: json["firstname"]?.toString() ?? '',
      lineId: json["line_id"]?.toString() ?? '',
      mobileNumber: json["phone"]?.toString() ?? '',
      emergencyName: json["emergency_name"]?.toString() ?? '',
      emergencyNumber: json["emergency_number"]?.toString() ?? '',
      email: json["email"]?.toString() ?? '',
      type: json["type"]?.toString() ?? '',
      referredBy: json["referred_by"]?.toString() ?? '',
      img1: json["img1"]?.toString() ?? '',
      img2: json["img2"]?.toString() ?? '',
      doorNo: json["door_no"]?.toString() ?? '',
      area: json["area"]?.toString() ?? '',
      landmark1: json["landmark_1"]?.toString() ?? '',
      city: json["city"]?.toString() ?? '',
      country: json["country"]?.toString() ?? '',
      state: json["state"]?.toString() ?? '',
      pincode: json["pincode"]?.toString() ?? '',
      tier: json["tier"]?.toString() ?? '',
      lat: json["lat"]?.toString() ?? '',
      lng: json["lng"]?.toString() ?? '',
      companyEmail: json["company_email"]?.toString() ?? '',
      companyNumber: json["company_number"]?.toString() ?? '',
      companyWebsite: json["company_website"]?.toString() ?? '',
      linkedin: json["linkedin"]?.toString() ?? '',
      active: json["active"]?.toString() ?? '',
      quotationUpdate: json["quotation_update"]?.toString() ?? '',
      companyName: json["company_name"]?.toString() ?? '',
      leadStatus: json["lead_status"]?.toString() ?? '',
      rating: json["rating"]?.toString() ?? '',
      quotationStatus: json["quotation_status"]?.toString() ?? '',
      quotationRequired: json["quotation_required"]?.toString() ?? '',
      productDiscussion: json["product_discussion"]?.toString() ?? '',
      discussionPoint: json["discussion_point"]?.toString() ?? '',
      notes: json["points"]?.toString() ?? '',
      arpuValue: json['arpu_value']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceDetails: json['source_details']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      prospectEnrollmentDate:
      json['prospect_enrollment_date']?.toString() ?? '',
      expectedConvertionDate:
      json['expected_convertion_date']?.toString() ?? '',
      statusUpdate: json['status_update']?.toString() ?? '',
      numOfHeadcount: json['num_of_headcount']?.toString() ?? '',
      expectedBillingValue:
      json['expected_billing_value']?.toString() ?? '',
      updatedTs: json['updated_ts']?.toString() ?? '',
      createdTs: json['created_ts']?.toString() ?? '',
      points: json['points']?.toString() ?? '',
      discussionPoints: json['discussion_point']?.toString() ?? '',
      visitType: json['visit_type']?.toString() ?? '',
      accountManager: json['account_manager']?.toString() ?? '',
      prospectGrading: json['prospect_grading']?.toString() ?? '',
      detailsOfServiceRequired:
      json['details_of_service_required']?.toString() ?? '',
      additionalInfo: json["additional_info"]?.toString() ?? '',
      whatsapp: json["whatsapp"]?.toString() ?? '',
      product: json["product"]?.toString() ?? '',
      industry: json["industry"]?.toString() ?? '',
      x: json["x"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> asMap() {
    return {
      "user_id": userId,
      "address_id": addressId,
      "firstname": firstname,
      "line_id": lineId,
      "phone": mobileNumber,
      "emergency_name": emergencyName,
      "emergency_number": emergencyNumber,
      "email": email,
      "type": type,
      "referred_by": referredBy,
      "img1": img1,
      "img2": img2,
      "door_no": doorNo,
      "area": area,
      "landmark_1": landmark1,
      "city": city,
      "country": country,
      "state": state,
      "pincode": pincode,
      "tier": tier,
      "lat": lat,
      "lng": lng,
      "quotation_update": quotationUpdate,
      "company_name": companyName,
      "lead_status": leadStatus,
      "rating": rating,
      "quotation_status": quotationStatus,
      "quotation_required": quotationRequired,
      "product_discussion": productDiscussion,
      "discussion_point": discussionPoint,
      "points": notes,
      "arpu value": arpuValue,
      "source of prospect": source,
      "prospect source details": sourceDetails,
      "status": status,
      "status update": statusUpdate,
      "ac manager": owner,
      "prospect enrollment date": prospectEnrollmentDate,
      "expected conversion date": expectedConvertionDate,
      "status_update": statusUpdate,
      "num of headcount": numOfHeadcount,
      "expected billing value": expectedBillingValue,
      "date": updatedTs,
      "created_ts": createdTs,
      "visit_type": visitType,
      "account_manager": accountManager,
      "prospect_grading": prospectGrading,
      "details of services required": detailsOfServiceRequired,
      "additional_info": additionalInfo,
      "whatsapp": whatsapp,
      "company_email": companyEmail,
      "company_website": companyWebsite,
      "company_number": companyNumber,
      "linkedin": linkedin,
      "industry": industry,
      "product": product,
      "x": x
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "id": userId,
      "mainName": firstname,
      "mainMobile": mobileNumber,
      "mainEmail": email,
      "mainWhatsApp": whatsapp,
      "company_name": companyName,
      "status": status,
      "rating": rating,
      "emailUpdate": quotationRequired,
      "name": firstname,
      "title":"",
      "mobile_number": mobileNumber,
      "whatsappNumber": whatsapp,
      "email": email,
      "mainTitle": "",
      "addressId": addressId,
      "companyWebsite": whatsapp,
      "companyNumber": companyNumber,
      "companyEmail": companyEmail,
      "industry": industry,
      "productServices": "",
      "source": source,
      "owner": owner,
      "budget": "",
      "timelineDecision": "",
      "serviceInterest": "",
      "description": "",
      "lead_status": leadStatus == "1"
          ? "Suspects"
          : leadStatus == "2"
          ? "Prospects"
          : leadStatus == "3"
          ? "Qualified"
          : "Customers",
      "active": active,
      "door_no": doorNo,
      "landmark_1": landmark1,
      "area": area,
      "city": city,
      "state": state,
      "country": country,
      "pinCode": pincode,
      "linkedin": linkedin,
      "x": x,
      "quotation_status": quotationStatus,
      "product_discussion": productDiscussion,
      "discussion_point": discussionPoint,
      "notes": notes,
      "quotationRequired": quotationRequired,
      "arpu_value": arpuValue,
      "source_details": sourceDetails,
      "prospect_enrollment_date": prospectEnrollmentDate,
      "expected_convertion_date": expectedConvertionDate,
      "status_update": statusUpdate,
      "num_of_headcount": numOfHeadcount,
      "expected_billing_value": expectedBillingValue,
      "visit_type": visitType,
      "points": notes,
      "details_of_service_required": detailsOfServiceRequired,
      "updatedTs": updatedTs,
      "date": updatedTs,
    };
  }
}