class GoodLeadObj {
  final String? userId;
  final String? addressId;
  final String? firstname;
  final String? lineId;
  final String? mobileNumber;
  final String? emergencyName;
  final String? emergencyNumber;
  final String? emailId;
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
  final String? status;
  final String? rating;
  final String? quotationUpdate;
  final String? active;
  final String? leadStatus;
  final String? arpuValue;
  final String? source;
  final String? sourceDetails;
  final String? owner;
  final String? prospectEnrollmentDate;
  final String? expectedConvertionDate;
  final String? statusUpdate;
  final String? numOfHeadcount;
  final String? expectedBillingValue;

  GoodLeadObj(
      {this.userId,
      this.addressId,
      this.firstname,
      this.lineId,
      this.mobileNumber,
      this.emergencyName,
      this.emergencyNumber,
      this.emailId,
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
      this.status,
      this.active,
      this.leadStatus,
      this.arpuValue,
      this.expectedBillingValue,
      this.expectedConvertionDate,
      this.numOfHeadcount,
      this.owner,
      this.prospectEnrollmentDate,
      this.source,
      this.sourceDetails,
      this.statusUpdate});
  factory GoodLeadObj.fromJson(Map<String, dynamic> json) {
    return GoodLeadObj(
      userId: json["user_id"]?.toString() ?? '',
      addressId: json["address_id"]?.toString() ?? '',
      firstname: json["firstname"]?.toString() ?? '',
      lineId: json["line_id"]?.toString() ?? '',
      mobileNumber: json["phone"]?.toString() ?? '',
      emergencyName: json["emergency_name"]?.toString() ?? '',
      emergencyNumber: json["emergency_number"]?.toString() ?? '',
      emailId: json["email_id"]?.toString() ?? '',
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
      quotationUpdate: json["quotation_update"]?.toString() ?? '',
      companyName: json["company_name"]?.toString() ?? '',
      status: json["status"]?.toString() ?? '',
      rating: json["rating"]?.toString() ?? '',
      leadStatus: json["lead_status"]?.toString() ?? '',
      arpuValue: json['arpu_value']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceDetails: json['source_details']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      prospectEnrollmentDate:
      json['prospect_enrollment_date']?.toString() ?? '',
      expectedConvertionDate:
      json['expected_convertion_date']?.toString() ?? '',
      statusUpdate: json['status_update']?.toString() ?? '',
      numOfHeadcount: json['num_of_headcount']?.toString() ?? '',
      expectedBillingValue: json['expected_billing_value']?.toString() ?? '',
    );
  }
}
