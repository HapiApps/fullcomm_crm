import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../models/payroll/monthly_unit_payroll.dart';
import '../models/payroll/payroll_user_model.dart';
import '../models/payroll/unit_model.dart';

final pyrlCtr = Get.put(PyrlCtr());

class PyrlCtr extends GetxController {
var saveMonth,year,end;
TextEditingController noOfWorkingDay =TextEditingController();
var getUnits=true.obs;
var getData=true.obs;
var isStored="".obs;
var monthCount=0.obs;
var lastDate,start;
DateTime selected = DateTime(DateTime.now().year,DateTime.now().month, DateTime.now().day);
var startDate="".obs,endDate="".obs,month=DateFormat("MMMM yyyy").format(DateTime.now()).obs;
RxList<units> unitList=<units>[].obs;
dynamic unitName,empName;
RxList<EmployeeModel2> allEmpList=<EmployeeModel2>[].obs;
RxList<EmployeeModel2> idEmpList=<EmployeeModel2>[].obs;
RxList<UnitPayroll> unitPayrollList=<UnitPayroll>[].obs;
TextEditingController duty=TextEditingController();
TextEditingController advance=TextEditingController();
TextEditingController penalty=TextEditingController();
TextEditingController uniform=TextEditingController();
TextEditingController total=TextEditingController();
RoundedLoadingButtonController submit=RoundedLoadingButtonController();

List<PayrollUserModel> users=<PayrollUserModel>[].obs;

}

class EmployeeModel2 {
  String? id;
  String? fName;
  String? mName;
  String? lName;
  String? role;
  String? roleName;
  String? mobileNumber;
  String? whatsappNumber;
  String? emailId;
  String? password;
  String? empCode1;
  String? empCode2;
  String? empCode;
  String? referredBy;
  String? city;
  String? dob;
  String? dateOfBirth;
  String? doj;
  String? dateOfJoining;
  String? imageUrl;
  String? userImage;
  String? userImageUrl;
  String? emergencyNumber;
  String? emergencyName;
  String? emergencyRelation;
  String? emergencyAddressId;
  String? uniform_dt;
  String? uf_details;
  String? uf_amount;
  String? salary;
  String? overallUniform;
  String? overallAdvance;
  String? totalDuty;
  String? overallPenalty;
  String? overallIncentive;
  String? esi;
  String? pf;
  String? payrollUnitName;
  String? unitNames;
  String? ifscCode;
  String? accNo;
  String? bankName;
  String? bkName;
  String? govt;
  String? createdBy;
  String? createdTs;
  String? houseType;
  String? prefixes;
  String? prefixes_2;

  // Document URLs
  String? aadharUrl;
  String? aadharBack;
  String? panUrl;
  String? licenseUrl;
  String? voterUrl;
  String? passbookPhoto;

  // Address and identification
  String? adhaar;
  String? pan;
  String? presentAddressId;
  String? permanentAddressId;
  String? relation;
  String? relationName;

  // Emergency contact
  String? emgName;
  String? emgNo;
  String? emgRelation;
  String? emgAddressId;

  // Reference and previous org
  String? lastOrganization;
  String? ref1Name;
  String? ref1No;
  String? ref2Name;
  String? ref2No;

  // Marital status
  String? maritalStatus;

  // Present address
  String? presentAddressLine1;
  String? presentAddressLine2;
  String? presentArea;
  String? presentCity;
  String? presentState;
  String? presentCountry;
  String? presentPincode;
  String? presentLat;
  String? presentLng;

  // Permanent address
  String? permanentAddressLine1;
  String? permanentAddressLine2;
  String? permanentArea;
  String? permanentCity;
  String? permanentState;
  String? permanentCountry;
  String? permanentPincode;
  String? permanentLat;
  String? permanentLng;
  String? esiNo;
  String? pfNo;

  EmployeeModel2({
    this.id,
    this.fName,
    this.mName,
    this.lName,
    this.role,
    this.roleName,
    this.mobileNumber,
    this.whatsappNumber,
    this.emailId,
    this.password,
    this.empCode1,
    this.empCode2,
    this.empCode,
    this.referredBy,
    this.city,
    this.dob,
    this.dateOfBirth,
    this.doj,
    this.dateOfJoining,
    this.imageUrl,
    this.userImage,
    this.userImageUrl,
    this.emergencyNumber,
    this.emergencyName,
    this.emergencyRelation,
    this.emergencyAddressId,
    this.uniform_dt,
    this.uf_details,
    this.uf_amount,
    this.salary,
    this.overallUniform,
    this.overallAdvance,
    this.bkName,
    this.totalDuty,
    this.overallPenalty,
    this.overallIncentive,
    this.esi,
    this.pf,
    this.payrollUnitName,
    this.unitNames,
    this.ifscCode,
    this.accNo,
    this.bankName,
    this.govt,
    this.createdBy,
    this.createdTs,
    this.houseType,
    this.prefixes,
    this.prefixes_2,
    this.aadharUrl,
    this.aadharBack,
    this.panUrl,
    this.licenseUrl,
    this.voterUrl,
    this.passbookPhoto,
    this.adhaar,
    this.pan,
    this.presentAddressId,
    this.permanentAddressId,
    this.relation,
    this.relationName,
    this.emgName,
    this.emgNo,
    this.emgRelation,
    this.emgAddressId,
    this.lastOrganization,
    this.ref1Name,
    this.ref1No,
    this.ref2Name,
    this.ref2No,
    this.maritalStatus,
    this.presentAddressLine1,
    this.presentAddressLine2,
    this.presentArea,
    this.presentCity,
    this.presentState,
    this.presentCountry,
    this.presentPincode,
    this.presentLat,
    this.presentLng,
    this.permanentAddressLine1,
    this.permanentAddressLine2,
    this.permanentArea,
    this.permanentCity,
    this.permanentState,
    this.permanentCountry,
    this.permanentPincode,
    this.permanentLat,
    this.permanentLng,
    this.esiNo,
    this.pfNo,
  });

  factory EmployeeModel2.fromJson(Map<String, dynamic> json) {
    return EmployeeModel2(
      bkName: json["bk_name"],
      id: json["id"],
      fName: json["firstname"],
      mName: json["middle_name"],
      lName: json["last_name"],
      role: json["role"],
      roleName: json["role_name"],
      mobileNumber: json["mobile_number"],
      whatsappNumber: json["whatsapp_number"],
      emailId: json["email_id"],
      password: json["password"],
      empCode1: json["emp_cd_1"],
      empCode2: json["emp_cd_2"],
      empCode: json["emp_cd_1"],
      referredBy: json["referred_by"],
      city: json["city"],
      dob: json["dob"] ?? json["date_of_birth"],
      dateOfBirth: json["date_of_birth"],
      doj: json["doj"] ?? json["date_of_joining"],
      dateOfJoining: json["date_of_joining"],
      imageUrl: json["image_url"],
      userImage: json["image_url"],
      userImageUrl: json["userImageUrl"],
      emergencyNumber: json["emergency_number"],
      emergencyName: json["emg_name"],
      emergencyRelation: json["emg_relation"],
      emergencyAddressId: json["emg_address_id"],
      uniform_dt: json["uniform_dt"],
      uf_details: json["uf_details"],
      uf_amount: json["uf_amount"],
      salary: json["salary"],
      overallUniform: json["overall_uf_amount"],
      overallAdvance: json["overall_advance"],
      totalDuty: json["total_duty"],
      overallPenalty: json["overall_penalty"],
      overallIncentive: json["overall_incentive"],
      esi: json["esi"],
      pf: json["pf"],
      payrollUnitName: json["unit_names"],
      unitNames: json["unit_names"],
      ifscCode: json["ifsc_code"],
      accNo: json["acc_no"],
      bankName: json["bank_name"],
      govt: json["govt"],
      createdBy: json["created_by"],
      createdTs: json["created_ts"],
      houseType: json["house_type"],
      prefixes: json["prefixes"],
      prefixes_2: json["prefixes_2"],
      aadharUrl: json["aadhar_url"],
      aadharBack: json["aadhar_2_url"],
      panUrl: json["pan_url"],
      licenseUrl: json["license_url"],
      voterUrl: json["voter_url"],
      passbookPhoto: json["passbook_photo"],
      adhaar: json["aadhar_number"],
      pan: json["pan_number"],
      presentAddressId: json["pres_address_id"],
      permanentAddressId: json["perm_address_id"],
      relation: json["relationship"],
      relationName: json["relation_name"],
      emgName: json["emg_name"],
      emgNo: json["emg_no"],
      emgRelation: json["emg_relation"],
      emgAddressId: json["emg_address_id"],
      lastOrganization: json["last_org"],
      ref1Name: json["ref1_name"],
      ref1No: json["ref1_no"],
      ref2Name: json["ref2_name"],
      ref2No: json["ref2_no"],
      maritalStatus: json["marital_status"],
      presentAddressLine1: json["pres_address_line_1"],
      presentAddressLine2: json["pres_address_line_2"],
      presentArea: json["pres_area"],
      presentCity: json["pres_city"],
      presentState: json["pres_state"],
      presentCountry: json["pres_country"],
      presentPincode: json["pres_pincode"],
      presentLat: json["pres_lat"],
      presentLng: json["pres_lng"],
      permanentAddressLine1: json["perm_address_line_1"],
      permanentAddressLine2: json["perm_address_line_2"],
      permanentArea: json["perm_area"],
      permanentCity: json["perm_city"],
      permanentState: json["perm_state"],
      permanentCountry: json["perm_country"],
      permanentPincode: json["perm_pincode"],
      permanentLat: json["perm_lat"],
      permanentLng: json["perm_lng"],
      esiNo: json["esi_no"],
      pfNo: json["pf_no"],
    );
  }
}
