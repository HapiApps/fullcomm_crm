class NewLeadObj {
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
  //c.source_details, c.details_of_service_required, c.prospect_grading
  final String? accountManager;
  final String? prospectGrading;
  final String? detailsOfServiceRequired;
  final String? additionalInfo;

  NewLeadObj(
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
        this.additionalInfo
      });
  factory NewLeadObj.fromJson(Map<String, dynamic> json) {
    return NewLeadObj(
        userId: json["user_id"],
        addressId: json["address_id"],
        firstname: json["firstname"],
        lineId: json["line_id"],
        mobileNumber: json["phone"],
        emergencyName: json["emergency_name"],
        emergencyNumber: json["emergency_number"],
        emailId: json["email_id"],
        type: json["type"],
        referredBy: json["referred_by"],
        img1: json["img1"],
        img2: json["img2"],
        doorNo: json["door_no"],
        area: json["area"],
        landmark1: json["landmark_1"],
        city: json["city"],
        country: json["country"],
        state: json["state"],
        pincode: json["pincode"],
        tier: json["tier"],
        lat: json["lat"],
        lng: json["lng"],
        quotationUpdate: json["quotation_update"],
        companyName: json["company_name"],
        leadStatus: json["lead_status"],
        rating: json["rating"],
        quotationStatus: json["quotation_status"],
        quotationRequired: json["quotation_required"],
        productDiscussion: json["product_discussion"],
        discussionPoint: json["discussion_point"],
        notes: json["points"],
        arpuValue: json['arpu_value'],
        source: json['source'],
        sourceDetails: json['source_details'],
        status: json['status'],
        owner: json['owner'],
        prospectEnrollmentDate: json['prospect_enrollment_date'],
        expectedConvertionDate: json['expected_convertion_date'],
        statusUpdate: json['status_update'],
        numOfHeadcount: json['num_of_headcount'],
        expectedBillingValue: json['expected_billing_value'],
        updatedTs: json['updated_ts'],
        createdTs: json['created_ts'],
        points: json['points'],
        discussionPoints: json['discussion_point'],
        visitType: json['visit_type'],
        accountManager: json['account_manager'],
        prospectGrading: json['prospect_grading'],
        detailsOfServiceRequired: json['details_of_service_required'],
      additionalInfo: json["additional_info"]
    );
  }
}
