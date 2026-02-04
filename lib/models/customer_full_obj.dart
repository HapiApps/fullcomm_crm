String s(dynamic v) {
  if (v == null || v == 'null') return '';
  return v.toString();
}

int? i(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

List<T> listParser<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) builder,
    ) {
  if (raw == null || raw is! List) return [];
  return raw.map((e) => builder(e as Map<String, dynamic>)).toList();
}

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
    return CustomerFullDetails(
      customer: json['customer'] == null
          ? null
          : Customer.fromJson(json['customer']),
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address']),

      customerPersons:
      listParser(json['customer_persons'], Person.fromJson),

      additionalInfo:
      listParser(json['additional_info'], AdditionalInfo.fromJson),

      callRecords:
      listParser(json['call_records'], CallRecord.fromJson),

      mailRecords:
      listParser(json['mail_records'], MailRecord.fromJson),

      meetings:
      listParser(json['meetings'], Meeting.fromJson),

      reminders:
      listParser(json['reminders'], Reminder.fromJson),
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
    return Customer(
      id: i(json['id']),
      companyName: s(json['company_name']),
      leadStatus: i(json['lead_status']),
      rating: s(json['rating']),
      productDiscussion: s(json['product_discussion']),
      visitType: s(json['visit_type']),
      discussionPoint: s(json['discussion_point']),
      companyWebsite: s(json['company_website']),
      companyNumber: s(json['company_number']),
      companyEmail: s(json['company_email']),
      linkedin: s(json['linkedin']),
      x: s(json['x']),
      industry: s(json['industry']),
      product: s(json['product']),
      points: s(json['points']),
      arpuValue: s(json['arpu_value']),
      updatedTs: s(json['updated_ts']),
      source: s(json['source']),
      sourceDetails: s(json['source_details']),
      status: s(json['status']),
      owner: s(json['owner']),
      prospectEnrollmentDate: s(json['prospect_enrollment_date']),
      expectedConvertionDate: s(json['expected_convertion_date']),
      statusUpdate: s(json['status_update']),
      numOfHeadcount: s(json['num_of_headcount']),
      expectedBillingValue: s(json['expected_billing_value']),
      detailsOfServiceRequired: s(json['details_of_service_required']),
      prospectGrading: s(json['prospect_grading']),
      createdTs: s(json['created_ts']),
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
    id: i(json['id']),
    doorNo: s(json['door_no']),
    area: s(json['area']),
    city: s(json['city']),
    country: s(json['country']),
    state: s(json['state']),
    pincode: s(json['pincode']),
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
    id: i(json['id']),
    name: s(json['name']),
    phone: s(json['phone']),
    email: s(json['email']),
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

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) =>
      AdditionalInfo(
        fieldName: s(json['field_name']),
        fieldValue: s(json['field_value']),
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

  factory CallRecord.fromJson(Map<String, dynamic> json) => CallRecord(
    id: i(json['id']),
    cosId: i(json['cos_id']),
    sentId: i(json['sent_id']),
    callVisitType: s(json['call_visit_type']),
    customerName: s(json['customer_name']),
    toData: s(json['to_data']),
    fromData: s(json['from_data']),
    subject: s(json['subject']),
    sentDate: s(json['sent_date']),
    message: s(json['message']),
    attachment: s(json['attachment']),
    sentCount: s(json['sent_count']),
    quotationName: s(json['quotation_name']),
    callType: s(json['call_type']),
    callStatus: s(json['call_status']),
    createdBy: i(json['created_by']),
    updatedBy: i(json['updated_by']),
    createdTs: s(json['created_ts']),
    updatedTs: s(json['updated_ts']),
    active: i(json['active']),
    platform: s(json['platform']),
    upPlatform: s(json['up_platform']),
  );

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
        id: i(json['id']),
        cosId: i(json['cos_id']),
        sentId: i(json['sent_id']),
        callVisitType: s(json['call_visit_type']),
        customerName: s(json['customer_name']),
        toData: s(json['to_data']),
        fromData: s(json['from_data']),
        subject: s(json['subject']),
        sentDate: s(json['sent_date']),
        message: s(json['message']),
        attachment: s(json['attachment']),
        sentCount: s(json['sent_count']),
        quotationName: s(json['quotation_name']),
        callType: s(json['call_type']),
        callStatus: s(json['call_status']),
        createdBy: i(json['created_by']),
        updatedBy: i(json['updated_by']),
        createdTs: s(json['created_ts']),
        updatedTs: s(json['updated_ts']),
        active: i(json['active']),
        platform: s(json['platform']),
        upPlatform: s(json['up_platform']),
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
    id: i(json['id']),
    cosId: i(json['cos_id']),
    cusId: s(json['cus_id']),
    cusName: s(json['cus_name']),
    comName: s(json['com_name']),
    title: s(json['title']),
    venue: s(json['venue']),
    dates: s(json['dates']),
    time: s(json['time']),
    notes: s(json['notes']),
    status: s(json['status']),
    createdTs: s(json['created_ts']),
    updatedTs: s(json['updated_ts']),
    createdBy: s(json['created_by']),
    updatedBy: s(json['updated_by']),
    active: i(json['active']),
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
    id: i(json['id']),
    cosId: i(json['cos_id']),
    title: s(json['title']),
    type: s(json['type']),
    location: s(json['location']),
    repeatType: s(json['repeat_type']),
    employee: s(json['employee']),
    customer: s(json['customer']),
    startDt: s(json['start_dt']),
    endDt: s(json['end_dt']),
    details: s(json['details']),
    setType: s(json['set_type']),
    setTime: s(json['set_time']),
    repeatWise: s(json['repeat_wise']),
    repeatEvery: s(json['repeat_every']),
    repeatOn: s(json['repeat_on']),
    updatedBy: s(json['updated_by']),
    createdBy: s(json['created_by']),
    createdTs: s(json['created_ts']),
    updatedTs: s(json['updated_ts']),
    active: i(json['active']),
    sent5min: i(json['sent_5min']),
    sent5minSms: i(json['sent_5min_sms']),
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

