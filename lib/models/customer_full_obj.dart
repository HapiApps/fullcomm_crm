
class CustomerFullDetails {
  final Customer? customer;
  final Address? address;
  final List<Person> customerPersons;
  final List<AdditionalInfo> additionalInfo;
  final List<CallRecord> callRecords;
  final List<MailRecord> mailRecords;
  final List<Meeting> meetings;
  final List<Reminder> reminders;

  CustomerFullDetails({
    required this.customer,
    required this.address,
    required this.customerPersons,
    required this.additionalInfo,
    required this.callRecords,
    required this.mailRecords,
    required this.meetings,
    required this.reminders,
  });

  factory CustomerFullDetails.fromJson(Map<String, dynamic> json) {
    final cust = json['customer'] as Map<String, dynamic>?;
    final addr = json['address'] as Map<String, dynamic>?;

    List<Person> parsePersons(dynamic raw) {
      if (raw == null) return [];
      return (raw as List).map((e) => Person.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<AdditionalInfo> parseAdditional(dynamic raw) {
      if (raw == null) return [];
      return (raw as List).map((e) => AdditionalInfo.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<CallRecord> parseCalls(dynamic raw) {
      if (raw == null) return [];
      return (raw as List).map((e) => CallRecord.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<MailRecord> parseMails(dynamic raw) {
      if (raw == null) return [];
      return (raw as List).map((e) => MailRecord.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<Meeting> parseMeetings(dynamic raw) {
      if (raw == null) return [];
      return (raw as List).map((e) => Meeting.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<Reminder> parseReminders(dynamic raw) {
      if (raw == null) return [];
      return (raw as List).map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
    }

    return CustomerFullDetails(
      customer: cust != null ? Customer.fromJson(cust) : null,
      address: addr != null ? Address.fromJson(addr) : null,
      customerPersons: parsePersons(json['customer_persons']),
      additionalInfo: parseAdditional(json['additional_info']),
      callRecords: parseCalls(json['call_records']),
      mailRecords: parseMails(json['mail_records']),
      meetings: parseMeetings(json['meetings']),
      reminders: parseReminders(json['reminders']),
    );
  }

  Map<String, dynamic> toJson() => {
    'customer': customer?.toJson(),
    'address': address?.toJson(),
    'customer_persons': customerPersons.map((e) => e.toJson()).toList(),
    'additional_info': additionalInfo.map((e) => e.toJson()).toList(),
    'call_records': callRecords.map((e) => e.toJson()).toList(),
    'mail_records': mailRecords.map((e) => e.toJson()).toList(),
    'meetings': meetings.map((e) => e.toJson()).toList(),
    'reminders': reminders.map((e) => e.toJson()).toList(),
  };
}

/// Customer
class Customer {
  final int? id;
  final String? companyName;
  final int? leadStatus;
  final String? rating;
  final String? productDiscussion;
  final String? visitType;
  final String? discussionPoint;
  final String? companyWebsite;
  final String? companyNumber;
  final String? companyEmail;
  final String? linkedin;
  final String? x;
  final String? industry;
  final String? product;
  final String? points;
  final String? arpuValue;
  final String? updatedTs;
  final String? source;
  final String? sourceDetails;
  final String? status;
  final String? owner;
  final String? prospectEnrollmentDate;
  final String? expectedConvertionDate;
  final String? statusUpdate;
  final String? numOfHeadcount;
  final String? expectedBillingValue;
  final String? detailsOfServiceRequired;
  final String? prospectGrading;
  final String? createdTs;

  Customer({
    this.id,
    this.companyName,
    this.leadStatus,
    this.rating,
    this.productDiscussion,
    this.visitType,
    this.discussionPoint,
    this.companyWebsite,
    this.companyNumber,
    this.companyEmail,
    this.linkedin,
    this.x,
    this.industry,
    this.product,
    this.points,
    this.arpuValue,
    this.updatedTs,
    this.source,
    this.sourceDetails,
    this.status,
    this.owner,
    this.prospectEnrollmentDate,
    this.expectedConvertionDate,
    this.statusUpdate,
    this.numOfHeadcount,
    this.expectedBillingValue,
    this.detailsOfServiceRequired,
    this.prospectGrading,
    this.createdTs,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return Customer(
      id: parseInt(json['id']),
      companyName: json['company_name']?.toString(),
      leadStatus: parseInt(json['lead_status']),
      rating: json['rating']?.toString(),
      productDiscussion: json['product_discussion']?.toString(),
      visitType: json['visit_type']?.toString(),
      discussionPoint: json['discussion_point']?.toString(),
      companyWebsite: json['company_website']?.toString(),
      companyNumber: json['company_number']?.toString(),
      companyEmail: json['company_email']?.toString(),
      linkedin: json['linkedin']?.toString(),
      x: json['x']?.toString(),
      industry: json['industry']?.toString(),
      product: json['product']?.toString(),
      points: json['points']?.toString(),
      arpuValue: json['arpu_value']?.toString(),
      updatedTs: json['updated_ts']?.toString(),
      source: json['source']?.toString(),
      sourceDetails: json['source_details']?.toString(),
      status: json['status']?.toString(),
      owner: json['owner']?.toString(),
      prospectEnrollmentDate: json['prospect_enrollment_date']?.toString(),
      expectedConvertionDate: json['expected_convertion_date']?.toString(),
      statusUpdate: json['status_update']?.toString(),
      numOfHeadcount: json['num_of_headcount']?.toString(),
      expectedBillingValue: json['expected_billing_value']?.toString(),
      detailsOfServiceRequired: json['details_of_service_required']?.toString(),
      prospectGrading: json['prospect_grading']?.toString(),
      createdTs: json['created_ts']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'company_name': companyName,
    'lead_status': leadStatus,
    'rating': rating,
    'product_discussion': productDiscussion,
    'visit_type': visitType,
    'discussion_point': discussionPoint,
    'company_website': companyWebsite,
    'company_number': companyNumber,
    'company_email': companyEmail,
    'linkedin': linkedin,
    'x': x,
    'industry': industry,
    'product': product,
    'points': points,
    'arpu_value': arpuValue,
    'updated_ts': updatedTs,
    'source': source,
    'source_details': sourceDetails,
    'status': status,
    'owner': owner,
    'prospect_enrollment_date': prospectEnrollmentDate,
    'expected_convertion_date': expectedConvertionDate,
    'status_update': statusUpdate,
    'num_of_headcount': numOfHeadcount,
    'expected_billing_value': expectedBillingValue,
    'details_of_service_required': detailsOfServiceRequired,
    'prospect_grading': prospectGrading,
    'created_ts': createdTs,
  };
}

/// Address
class Address {
  final int? id;
  final String? doorNo;
  final String? area;
  final String? city;
  final String? country;
  final String? state;
  final String? pincode;

  Address({
    this.id,
    this.doorNo,
    this.area,
    this.city,
    this.country,
    this.state,
    this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
    doorNo: json['door_no']?.toString(),
    area: json['area']?.toString(),
    city: json['city']?.toString(),
    country: json['country']?.toString(),
    state: json['state']?.toString(),
    pincode: json['pincode']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'door_no': doorNo,
    'area': area,
    'city': city,
    'country': country,
    'state': state,
    'pincode': pincode,
  };
}

/// Person (customer_persons)
class Person {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;

  Person({this.id, this.name, this.phone, this.email});

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
    name: json['name']?.toString(),
    phone: json['phone']?.toString(),
    email: json['email']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
  };
}

/// Additional info
class AdditionalInfo {
  final String? fieldName;
  final String? fieldValue;

  AdditionalInfo({this.fieldName, this.fieldValue});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) => AdditionalInfo(
    fieldName: json['field_name']?.toString(),
    fieldValue: json['field_value']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'field_name': fieldName,
    'field_value': fieldValue,
  };
}

/// Call record (mail_receive with call_visit_type = 7)
class CallRecord {
  final int? id;
  final int? cosId;
  final int? sentId;
  final String? callVisitType;
  final String? customerName;
  final String? toData;
  final String? fromData;
  final String? subject;
  final String? sentDate;
  final String? message;
  final String? attachment;
  final String? sentCount;
  final String? quotationName;
  final String? callType;
  final String? callStatus;
  final int? createdBy;
  final int? updatedBy;
  final String? createdTs;
  final String? updatedTs;
  final int? active;
  final String? platform;
  final String? upPlatform;

  CallRecord({
    this.id,
    this.cosId,
    this.sentId,
    this.callVisitType,
    this.customerName,
    this.toData,
    this.fromData,
    this.subject,
    this.sentDate,
    this.message,
    this.attachment,
    this.sentCount,
    this.quotationName,
    this.callType,
    this.callStatus,
    this.createdBy,
    this.updatedBy,
    this.createdTs,
    this.updatedTs,
    this.active,
    this.platform,
    this.upPlatform,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    int? pInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return CallRecord(
      id: pInt(json['id']),
      cosId: pInt(json['cos_id']),
      sentId: pInt(json['sent_id']),
      callVisitType: json['call_visit_type']?.toString(),
      customerName: json['customer_name']?.toString(),
      toData: json['to_data']?.toString(),
      fromData: json['from_data']?.toString(),
      subject: json['subject']?.toString(),
      sentDate: json['sent_date']?.toString(),
      message: json['message']?.toString(),
      attachment: json['attachment']?.toString(),
      sentCount: json['sent_count']?.toString(),
      quotationName: json['quotation_name']?.toString(),
      callType: json['call_type']?.toString(),
      callStatus: json['call_status']?.toString(),
      createdBy: pInt(json['created_by']),
      updatedBy: pInt(json['updated_by']),
      createdTs: json['created_ts']?.toString(),
      updatedTs: json['updated_ts']?.toString(),
      active: pInt(json['active']),
      platform: json['platform']?.toString(),
      upPlatform: json['up_platform']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cos_id': cosId,
    'sent_id': sentId,
    'call_visit_type': callVisitType,
    'customer_name': customerName,
    'to_data': toData,
    'from_data': fromData,
    'subject': subject,
    'sent_date': sentDate,
    'message': message,
    'attachment': attachment,
    'sent_count': sentCount,
    'quotation_name': quotationName,
    'call_type': callType,
    'call_status': callStatus,
    'created_by': createdBy,
    'updated_by': updatedBy,
    'created_ts': createdTs,
    'updated_ts': updatedTs,
    'active': active,
    'platform': platform,
    'up_platform': upPlatform,
  };
}

/// Mail record (call_visit_type = 8) - same shape as CallRecord
class MailRecord extends CallRecord {
  MailRecord({
    int? id,
    int? cosId,
    int? sentId,
    String? callVisitType,
    String? customerName,
    String? toData,
    String? fromData,
    String? subject,
    String? sentDate,
    String? message,
    String? attachment,
    String? sentCount,
    String? quotationName,
    String? callType,
    String? callStatus,
    int? createdBy,
    int? updatedBy,
    String? createdTs,
    String? updatedTs,
    int? active,
    String? platform,
    String? upPlatform,
  }) : super(
    id: id,
    cosId: cosId,
    sentId: sentId,
    callVisitType: callVisitType,
    customerName: customerName,
    toData: toData,
    fromData: fromData,
    subject: subject,
    sentDate: sentDate,
    message: message,
    attachment: attachment,
    sentCount: sentCount,
    quotationName: quotationName,
    callType: callType,
    callStatus: callStatus,
    createdBy: createdBy,
    updatedBy: updatedBy,
    createdTs: createdTs,
    updatedTs: updatedTs,
    active: active,
    platform: platform,
    upPlatform: upPlatform,
  );

  factory MailRecord.fromJson(Map<String, dynamic> json) =>
      MailRecord(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
        cosId: json['cos_id'] is int ? json['cos_id'] : int.tryParse('${json['cos_id']}'),
        sentId: json['sent_id'] is int ? json['sent_id'] : int.tryParse('${json['sent_id']}'),
        callVisitType: json['call_visit_type']?.toString(),
        customerName: json['customer_name']?.toString(),
        toData: json['to_data']?.toString(),
        fromData: json['from_data']?.toString(),
        subject: json['subject']?.toString(),
        sentDate: json['sent_date']?.toString(),
        message: json['message']?.toString(),
        attachment: json['attachment']?.toString(),
        sentCount: json['sent_count']?.toString(),
        quotationName: json['quotation_name']?.toString(),
        callType: json['call_type']?.toString(),
        callStatus: json['call_status']?.toString(),
        createdBy: json['created_by'] is int ? json['created_by'] : int.tryParse('${json['created_by']}'),
        updatedBy: json['updated_by'] is int ? json['updated_by'] : int.tryParse('${json['updated_by']}'),
        createdTs: json['created_ts']?.toString(),
        updatedTs: json['updated_ts']?.toString(),
        active: json['active'] is int ? json['active'] : int.tryParse('${json['active']}'),
        platform: json['platform']?.toString(),
        upPlatform: json['up_platform']?.toString(),
      );
}

/// Meeting
class Meeting {
  final int? id;
  final int? cosId;
  final String? cusId;
  final String? cusName;
  final String? comName;
  final String? title;
  final String? venue;
  final String? dates; // note: in sample "22.10.2025||23.10.2025"
  final String? time;  // "4:05 PM||4:05 PM"
  final String? notes;
  final String? status;
  final String? createdTs;
  final String? updatedTs;
  final String? createdBy;
  final String? updatedBy;
  final int? active;

  Meeting({
    this.id,
    this.cosId,
    this.cusId,
    this.cusName,
    this.comName,
    this.title,
    this.venue,
    this.dates,
    this.time,
    this.notes,
    this.status,
    this.createdTs,
    this.updatedTs,
    this.createdBy,
    this.updatedBy,
    this.active,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
    cosId: json['cos_id'] is int ? json['cos_id'] : int.tryParse('${json['cos_id']}'),
    cusId: json['cus_id']?.toString(),
    cusName: json['cus_name']?.toString(),
    comName: json['com_name']?.toString(),
    title: json['title']?.toString(),
    venue: json['venue']?.toString(),
    dates: json['dates']?.toString(),
    time: json['time']?.toString(),
    notes: json['notes']?.toString(),
    status: json['status']?.toString(),
    createdTs: json['created_ts']?.toString(),
    updatedTs: json['updated_ts']?.toString(),
    createdBy: json['created_by']?.toString(),
    updatedBy: json['updated_by']?.toString(),
    active: json['active'] is int ? json['active'] : int.tryParse('${json['active']}'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cos_id': cosId,
    'cus_id': cusId,
    'cus_name': cusName,
    'com_name': comName,
    'title': title,
    'venue': venue,
    'dates': dates,
    'time': time,
    'notes': notes,
    'status': status,
    'created_ts': createdTs,
    'updated_ts': updatedTs,
    'created_by': createdBy,
    'updated_by': updatedBy,
    'active': active,
  };
}

/// Reminder
class Reminder {
  final int? id;
  final int? cosId;
  final String? title;
  final String? type;
  final String? location;
  final String? repeatType;
  final String? employee;
  final String? customer;
  final String? startDt;
  final String? endDt;
  final String? details;
  final String? setType;
  final String? setTime;
  final String? repeatWise;
  final String? repeatEvery;
  final String? repeatOn;
  final String? updatedBy;
  final String? createdBy;
  final String? createdTs;
  final String? updatedTs;
  final int? active;
  final int? sent5min;
  final int? sent5minSms;

  Reminder({
    this.id,
    this.cosId,
    this.title,
    this.type,
    this.location,
    this.repeatType,
    this.employee,
    this.customer,
    this.startDt,
    this.endDt,
    this.details,
    this.setType,
    this.setTime,
    this.repeatWise,
    this.repeatEvery,
    this.repeatOn,
    this.updatedBy,
    this.createdBy,
    this.createdTs,
    this.updatedTs,
    this.active,
    this.sent5min,
    this.sent5minSms,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
    cosId: json['cos_id'] is int ? json['cos_id'] : int.tryParse('${json['cos_id']}'),
    title: json['title']?.toString(),
    type: json['type']?.toString(),
    location: json['location']?.toString(),
    repeatType: json['repeat_type']?.toString(),
    employee: json['employee']?.toString(),
    customer: json['customer']?.toString(),
    startDt: json['start_dt']?.toString(),
    endDt: json['end_dt']?.toString(),
    details: json['details']?.toString(),
    setType: json['set_type']?.toString(),
    setTime: json['set_time']?.toString(),
    repeatWise: json['repeat_wise']?.toString(),
    repeatEvery: json['repeat_every']?.toString(),
    repeatOn: json['repeat_on']?.toString(),
    updatedBy: json['updated_by']?.toString(),
    createdBy: json['created_by']?.toString(),
    createdTs: json['created_ts']?.toString(),
    updatedTs: json['updated_ts']?.toString(),
    active: json['active'] is int ? json['active'] : int.tryParse('${json['active']}'),
    sent5min: json['sent_5min'] is int ? json['sent_5min'] : int.tryParse('${json['sent_5min']}'),
    sent5minSms: json['sent_5min_sms'] is int ? json['sent_5min_sms'] : int.tryParse('${json['sent_5min_sms']}'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cos_id': cosId,
    'title': title,
    'type': type,
    'location': location,
    'repeat_type': repeatType,
    'employee': employee,
    'customer': customer,
    'start_dt': startDt,
    'end_dt': endDt,
    'details': details,
    'set_type': setType,
    'set_time': setTime,
    'repeat_wise': repeatWise,
    'repeat_every': repeatEvery,
    'repeat_on': repeatOn,
    'updated_by': updatedBy,
    'created_by': createdBy,
    'created_ts': createdTs,
    'updated_ts': updatedTs,
    'active': active,
    'sent_5min': sent5min,
    'sent_5min_sms': sent5minSms,
  };
}

