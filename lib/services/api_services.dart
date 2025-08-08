import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fullcomm_crm/common/constant/default_constant.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import 'package:fullcomm_crm/models/company_obj.dart';
import 'package:fullcomm_crm/models/good_lead_obj.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';
import 'package:fullcomm_crm/screens/dashboard.dart';
import 'package:fullcomm_crm/screens/leads/prospects.dart';
import 'package:fullcomm_crm/screens/leads/qualified.dart';
import 'package:fullcomm_crm/screens/leads/suspects.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/screens/mail_comments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/models/product_obj.dart';
import 'package:fullcomm_crm/screens/customer/view_customer.dart';
import 'package:fullcomm_crm/screens/employee/view_employee.dart';
import 'package:fullcomm_crm/screens/products/view_product.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/my_encryption_decryption.dart';
import '../common/utilities/utils.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../controller/image_controller.dart';
import '../models/customer_obj.dart';
import '../models/employee_obj.dart';
import '../models/lead_obj.dart';
import '../models/mail_receive_obj.dart';

final ApiService apiService = ApiService._();

class ApiService {
  ApiService._();
  // Future<void> insertEmployeeApi(BuildContext context) async {
  //   try {
  //     String uri = 'https://crm.hapirides.in/$version1/dev/insert_employee.php';
  //     final formData = FormData(({}));
  //
  //     formData.fields.addAll([
  //       MapEntry('name', stringToBase64.encode(controllers.empName.value)),
  //       MapEntry('emp_id', stringToBase64.encode(controllers.empId.value)),
  //       MapEntry('email', stringToBase64.encode(controllers.empEmail.value)),
  //       MapEntry('phone_number', controllers.empPhone.value),
  //       MapEntry('dob', controllers.empDOB.value),
  //       MapEntry('department', stringToBase64.encode(controllers.department)),
  //       MapEntry('position', stringToBase64.encode(controllers.position)),
  //       MapEntry('type', stringToBase64.encode(controllers.employeeType)),
  //       MapEntry('doj', controllers.empDOJ.value),
  //       MapEntry('manager_name', stringToBase64.encode(controllers.empManagerName.value)),
  //       MapEntry('salary', stringToBase64.encode(controllers.empSalary.value)),
  //       MapEntry('bonus', stringToBase64.encode(controllers.empBonus.value)),
  //       MapEntry('benefits', stringToBase64.encode(controllers.benefits)),
  //       MapEntry('degree', stringToBase64.encode(controllers.empDegree.value)),
  //       MapEntry('institution', stringToBase64.encode(controllers.empInstitution.value)),
  //       MapEntry('graduation_year', stringToBase64.encode(controllers.empGraYear.value)),
  //       MapEntry('gender', stringToBase64.encode(controllers.selectedGender)),
  //       MapEntry('marital_status', stringToBase64.encode(controllers.selectedMarital)),
  //       MapEntry('relation_ship', stringToBase64.encode(controllers.selectedRelationShip)),
  //       MapEntry('cos_id', cosId),
  //       MapEntry('door_no', stringToBase64.encode(controllers.empDoorNo.value)),
  //       MapEntry('street_name', stringToBase64.encode(controllers.empStreet.value)),
  //       MapEntry('area', stringToBase64.encode(controllers.empArea.value)),
  //       MapEntry('city', stringToBase64.encode(controllers.empCity.value)),
  //       MapEntry('state', stringToBase64.encode(controllers.emState)),
  //       MapEntry('country', stringToBase64.encode(controllers.empCountry.value)),
  //       MapEntry('pin_code', stringToBase64.encode(controllers.empPinCode.value)),
  //     ]);
  //
  //     if (imageController.empFileName.value.isNotEmpty){
  //       formData.files.add(
  //         MapEntry(
  //           'image',
  //           MultipartFile(
  //             imageController.empMediaData,
  //             filename: imageController.empFileName.value,
  //           ),
  //         ),
  //       );
  //     }
  //
  //     if (imageController.resumeFileName.value.isNotEmpty) {
  //       formData.files.add(
  //         MapEntry(
  //           'resume',
  //           MultipartFile(
  //             imageController.resumeMediaData,
  //             filename: imageController.resumeFileName.value,
  //           ),
  //         ),
  //       );
  //     }
  //
  //     if (imageController.idCardFileName.value.isNotEmpty) {
  //       formData.files.add(
  //         MapEntry(
  //           'id_card',
  //           MultipartFile(
  //             imageController.idCardMediaData,
  //             filename: imageController.idCardFileName.value,
  //           ),
  //         ),
  //       );
  //     }
  //
  //     final response =  await dio.post(uri, data: formData);
  //
  //     if (response.statusCode == 200){
  //       print("Success: ${response.data}");
  //       // Reset the controllers and form fields
  //       //resetFormFields();
  //       controllers.allEmployeeFuture = apiService.allEmployeeDetails();
  //       await Future.delayed(const Duration(milliseconds: 100));
  //       Get.to(const ViewEmployees(), duration: Duration.zero);
  //     } else {
  //       print("Failed: ${response.data}");
  //       errorDialog(context, 'Failed to insert employee: ${response.data}');
  //     }
  //   } on SocketException {
  //     controllers.employeeCtr.reset();
  //     errorDialog(context, 'No internet connection');
  //   }  catch (e) {
  //     controllers.employeeCtr.reset();
  //     errorDialog(context, 'Unexpected error: ${e.toString()}');
  //     print('Unexpected error: ${e.toString()}');
  //   }
  // }

  Future insertEmployeeApi(BuildContext context) async {
    try {
      ///home/hapinode3/DomainActiveProj/crm.hapirides.in/zengraf_crm/dev/insert_employee.php
      final uri = Uri.parse(insertEmployee);
      var request = http.MultipartRequest("POST", uri);

      request.fields["name"] = stringToBase64.encode(controllers.empName.value);
      request.fields["emp_id"] = stringToBase64.encode(controllers.empId.value);
      request.fields["email"] =
          stringToBase64.encode(controllers.empEmail.value);
      request.fields["phone_number"] = controllers.empPhone.value;
      request.fields["dob"] = controllers.empDOB.value;
      request.fields["department"] =
          stringToBase64.encode(controllers.department);
      request.fields["position"] = stringToBase64.encode(controllers.position);
      request.fields["type"] = stringToBase64.encode(controllers.employeeType);
      request.fields["doj"] = controllers.empDOJ.value;
      request.fields["manager_name"] =
          stringToBase64.encode(controllers.empManagerName.value);
      request.fields["salary"] =
          stringToBase64.encode(controllers.empSalary.value);
      request.fields["bonus"] =
          stringToBase64.encode(controllers.empBonus.value);
      request.fields["benefits"] = stringToBase64.encode(controllers.benefits);
      request.fields["degree"] =
          stringToBase64.encode(controllers.empDegree.value);
      request.fields["institution"] =
          stringToBase64.encode(controllers.empInstitution.value);
      request.fields["graduation_year"] =
          stringToBase64.encode(controllers.empGraYear.value);
      request.fields["gender"] =
          stringToBase64.encode(controllers.selectedGender);
      request.fields["marital_status"] =
          stringToBase64.encode(controllers.selectedMarital);
      request.fields["relation_ship"] =
          stringToBase64.encode(controllers.selectedRelationShip);
      request.fields["cos_id"] = cosId;
      request.fields["door_no"] =
          stringToBase64.encode(controllers.empDoorNo.value);
      request.fields["street_name"] =
          stringToBase64.encode(controllers.empStreet.value);
      request.fields["area"] = stringToBase64.encode(controllers.empArea.value);
      request.fields["city"] = stringToBase64.encode(controllers.empCity.value);
      request.fields["state"] = stringToBase64.encode(controllers.emState);
      request.fields["country"] =
          stringToBase64.encode(controllers.empCountry.value);
      request.fields["pin_code"] =
          stringToBase64.encode(controllers.empPinCode.value);

      if (imageController.empFileName.value.isNotEmpty) {
        var picture1 = http.MultipartFile.fromBytes(
          "image",
          imageController.empMediaData,
          filename: imageController.empFileName.value,
          //contentType: http.MediaType('image', 'jpeg'),
        );
        request.files.add(picture1);
      }
      if (imageController.resumeFileName.value.isNotEmpty) {
        var picture2 = http.MultipartFile.fromBytes(
          "resume",
          imageController.resumeMediaData,
          filename: imageController.resumeFileName.value,
          //contentType: http.MediaType('image', 'jpeg'),
        );
        request.files.add(picture2);
      }
      if (imageController.idCardFileName.value.isNotEmpty) {
        var picture3 = http.MultipartFile.fromBytes(
          "id_card",
          imageController.idCardMediaData,
          filename: imageController.idCardFileName.value,
          //contentType: http.MediaType('image', 'jpeg'),
        );
        request.files.add(picture3);
      }
      var response = await request.send();
      var output = await http.Response.fromStream(response);
      print("result ${output.body}");
      print("fields ${request.fields}");
      if (response.statusCode == 200 &&
          output.body == "{\"status_code\":200,\"message\":\"ok\"}") {
        print("success");

        controllers.empName.value = "";
        controllers.emNameController.clear();
        controllers.empId.value = "";
        controllers.emIDController.clear();
        controllers.empEmail.value = "";
        controllers.emEmailController.clear();
        controllers.empPhone.value = "";
        controllers.emPhoneController.clear();
        controllers.empDOB.value = "";

        controllers.department = null;
        controllers.position = null;
        controllers.employeeType = null;
        controllers.empDOJ.value = "";
        controllers.empManagerName.value = "";
        controllers.emManagerController.clear();
        controllers.empSalary.value = "";
        controllers.emSalaryController.clear();
        controllers.empBonus.value = "";
        controllers.emBonusController.clear();
        controllers.benefits = null;
        controllers.empDegree.value = "";
        controllers.emDegreeController.clear();
        controllers.empInstitution.value = "";
        controllers.emInstitutionController.clear();
        controllers.empGraYear.value = "";
        controllers.emGraduationYearController.clear();
        controllers.selectedGender = 'Male';
        controllers.selectedMarital = 'Single';
        controllers.selectedRelationShip = 'Spouse';
        controllers.empDoorNo.value = "";
        controllers.emDoorNoController.clear();
        controllers.empStreet.value = "";
        controllers.emStreetController.clear();
        controllers.empArea.value = "";
        controllers.emAreaController.clear();
        controllers.empCity.value = "";
        controllers.emCityController.clear();
        controllers.emState = null;
        controllers.empCountry.value = "";
        controllers.emCountryController.clear();
        controllers.empPinCode.value = "";
        controllers.emPinCodeController.clear();
        imageController.photo1.value = "";
        controllers.allEmployeeFuture = apiService.allEmployeeDetails();
        await Future.delayed(const Duration(milliseconds: 100));
        Get.to(const ViewEmployees(), duration: Duration.zero);
        // Get.to(const ViewStall());
      } else {
        print("Failed");
        errorDialog(Get.context!, output.body);
      }

      // Navigator.push(context,
      //   PageRouteBuilder(
      //     pageBuilder: (context, animation1, animation2) => const ViewEmployees(),
      //     transitionDuration: Duration.zero,
      //     reverseTransitionDuration: Duration.zero,
      //   ),
      // );
      //Get.to(const ViewEmployees());
      // var output=await http.Response.fromStream(response);
      // print("result ${output.body}");

      controllers.employeeCtr.reset();
    } on SocketException {
      controllers.employeeCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
      //throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.employeeCtr.reset();
      errorDialog(Get.context!, 'Server error employee: ${e.toString()}');
      //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      controllers.employeeCtr.reset();
      errorDialog(Get.context!, 'Unexpected error employee: ${e.toString()}');
      //throw Exception('Unexpected error employee: ${e.toString()}'); // Catch other exceptions
    }
  }

  Future insertLeadAPI(BuildContext context) async {
    var index =
        controllers.isMainPersonList.indexWhere((element) => element == true);
    print(index);
    controllers.leadNames.value = "";
    controllers.leadMobiles.value = "";
    controllers.leadEmails.value = "";
    controllers.leadTitles.value = "";
    controllers.leadWhatsApps.value = "";
    if (index != -1) {
      controllers.mainLeadName.value = controllers.leadNameCrt[index].text;
      controllers.mainLeadMobile.value = controllers.leadMobileCrt[index].text;
      controllers.mainLeadEmail.value = controllers.leadEmailCrt[index].text;
      controllers.mainLeadTitle.value = controllers.leadTitleCrt[index].text;
      controllers.mainLeadWhatsApp.value = controllers.leadWhatsCrt[index].text;
    } else {
      controllers.mainLeadName.value = controllers.leadNameCrt[0].text;
      controllers.mainLeadMobile.value = controllers.leadMobileCrt[0].text;
      controllers.mainLeadEmail.value = controllers.leadEmailCrt[0].text;
      controllers.mainLeadTitle.value = controllers.leadTitleCrt[0].text;
      controllers.mainLeadWhatsApp.value = controllers.leadWhatsCrt[0].text;
    }
    for (int i = 0; i < controllers.leadPersonalItems.value; i++) {
      if (i == 0) {
        controllers.leadNames.value += controllers.leadNameCrt[i].text;
        controllers.leadMobiles.value += controllers.leadMobileCrt[i].text;
        controllers.leadEmails.value += controllers.leadEmailCrt[i].text;
        controllers.leadTitles.value += controllers.leadTitleCrt[i].text;
        controllers.leadWhatsApps.value += controllers.leadWhatsCrt[i].text;
      } else if (i != 0 && controllers.leadNameCrt[i].text.isNotEmpty) {
        controllers.leadNames.value += "||${controllers.leadNameCrt[i].text}";
        controllers.leadMobiles.value +=
            "||${controllers.leadMobileCrt[i].text}";
        controllers.leadEmails.value += "||${controllers.leadEmailCrt[i].text}";
        controllers.leadTitles.value += "||${controllers.leadTitleCrt[i].text}";
        controllers.leadWhatsApps.value +=
            "||${controllers.leadWhatsCrt[i].text}";
      }
    }
    List<Map<String, String>> leadFields = [];

    for (int i = 0; i < controllers.leadFieldItems.value; i++) {
      leadFields.add(
        {
          "field_name": controllers.leadFieldName[i].text.trim(),
          "field_value": controllers.leadFieldValue[i].text.trim()
        },
      );
    }
    String jsonString = json.encode(leadFields);

    try {
      //1-Suspects,2-Prospects,3-Qualified,4-Customers.
      var leadId; //controllers.visitType
      for (var role in controllers.leadCategoryList) {
        if (role['value'] == controllers.leadCategory) {
          leadId = role['id'];
          break;
        }
      }
      var callListId;
      for (var role in controllers.callList) {
        if (role['value'] == controllers.visitType) {
          callListId = role['id'];
          break;
        }
      }
      Map data = {
        "data": jsonString,
        "lead_status": leadId,
        "cos_id": cosId,
        "main_name": controllers.mainLeadName.value,
        "main_title": controllers.mainLeadTitle.value,
        "main_mobile": controllers.mainLeadMobile.value,
        "main_whatsapp": controllers.mainLeadMobile.value,
        "main_email": controllers.mainLeadEmail.value,
        "name": controllers.leadNames.value,
        "title": controllers.leadTitles.value,
        "mobile_number": controllers.leadMobiles.value,
        "whatsapp_number": controllers.leadMobiles.value,
        "email": controllers.leadEmails.value,
        "co_name": controllers.leadCoNameCrt.text.trim(),
        "co_website": controllers.leadWebsite.text.trim(),
        "co_number": controllers.leadCoMobileCrt.text.trim(),
        "co_email": controllers.leadCoEmailCrt.text.trim(),
        "linkedin": controllers.leadLinkedinCrt.text.trim(),
        "gst_number": controllers.leadGstNumCrt.text.trim(),
        "gst_DOR": controllers.leadDOR.value,
        "gst_location": controllers.leadGstLocationCrt.text.trim(),
        "x": controllers.leadXCrt.text.trim(),
        "date_of_connection": controllers.empDOB.value,
        "source_details": controllers.leadSourceCrt.text.trim(),
        "owner": controllers.leadOwnerNameCrt.text.trim(),
        "budget": controllers.budgetCrt.text.isEmpty
            ? "0"
            : controllers.budgetCrt.text.trim(),
        "timeline_decision": controllers.leadTime.text.trim(),
        "industry": controllers.industry,
        "user_id": controllers.storage.read("id"),
        "service_interest": controllers.service,
        "product_service": controllers.leadProduct.text.trim(),
        "description": controllers.leadDescription.text.trim(),
        "status": controllers.status,
        "rating": controllers.selectedRating,
        "source": controllers.source,
        "door_no": controllers.doorNumberController.text.trim(),
        "street_name": controllers.streetNameController.text.trim(),
        "area": controllers.areaController.text.trim(),
        "city": controllers.selectedCity.value,
        "state": controllers.selectedState.value,
        "pin_code": controllers.pinCodeController.text,
        "country": controllers.selectedCountry.value,
        "actions": controllers.leadActions.text,
        "discussion_point": controllers.leadDisPointsCrt.text,
        "points": controllers.leadPointsCrt.text,
        "platform": 3,
        "visit_type": callListId,
        "action": "insert_lead"
      };

      print("data lead ${data.toString()}");
      final request = await http.post(
        Uri.parse(scriptApi),
        // headers: {
        //   "Accept": "application/text",
        //   "Content-Type": "application/x-www-form-urlencoded"
        // },
        body: jsonEncode(data),
        // encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "ok") {
        utils.snackBar(
            msg: "Your Lead is created successfully !",
            color: colorsConst.primary,
            context: Get.context!);
        final prefs = await SharedPreferences.getInstance();

        prefs.remove("leadName");
        prefs.remove("leadCount");
        prefs.remove("leadMobileNumber");
        prefs.remove("leadEmail");
        prefs.remove("leadTitle");
        prefs.remove("leadWhatsApp");
        prefs.remove("leadCoName");
        prefs.remove("leadCoMobile");
        prefs.remove("leadWebsite");
        prefs.remove("leadCoEmail");
        prefs.remove("leadProduct");
        prefs.remove("leadOwnerName");
        prefs.remove("industry");
        prefs.remove("source");
        prefs.remove("status");
        prefs.remove("rating");
        prefs.remove("service");
        prefs.remove("leadDNo");
        prefs.remove("leadStreet");
        prefs.remove("leadArea");
        prefs.remove("leadCity");
        prefs.remove("leadPinCode");
        prefs.remove("budget");
        prefs.remove("leadState");
        prefs.remove("leadCountry");
        prefs.remove("leadX");
        prefs.remove("leadLinkedin");
        prefs.remove("leadTime");
        prefs.remove("leadDescription");
        for (int i = 0; i < controllers.leadPersonalItems.value; i++) {
          controllers.leadNameCrt[i].text = "";
          controllers.leadMobileCrt[i].text = "";
          controllers.leadEmailCrt[i].text = "";
          controllers.leadTitleCrt[i].text = "";
          controllers.leadWhatsCrt[i].text = "";
        }
        //Get.to(const CompanyCamera(),transition: Transition.downToUp,duration: const Duration(seconds: 2));
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        controllers.allCustomerFuture = apiService.allCustomerDetails();
        await Future.delayed(const Duration(milliseconds: 100));
        Get.to(const Suspects(), duration: Duration.zero);
        // Navigator.push(context,
        //   PageRouteBuilder(
        //     pageBuilder: (context, animation1, animation2) => const ViewLead(),
        //     transitionDuration: Duration.zero,
        //     reverseTransitionDuration: Duration.zero,
        //   ),
        // );
        //Get.to(const ViewLead());
        controllers.leadCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.leadCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.leadCtr.reset();
    }
  }

  Future updateLeadAPI(
      BuildContext context, String leadId, String addressId) async {
    try {
      Map data = {
        "cos_id": cosId,
        "city": controllers.cityController.text,
        "source": controllers.source,
        "source_details": controllers.sourceCrt.text,
        "product_discussion": controllers.prodDescriptionController.text,
        "company_name": controllers.leadCoNameCrt.text.trim(),
        "points": controllers.additionalNotesCrt.text,
        "status": controllers.status,
        //"owner":controllers.leadOwnerNameCrt.text.trim(),
        "prospect_enrollment_date": controllers.prospectEnrollmentDateCrt.text,
        "expected_convertion_date": controllers.expectedConversionDateCrt.text,
        "num_of_headcount": controllers.noOfHeadCountCrt.text,
        "expected_billing_value": controllers.exMonthBillingValCrt.text,
        "arpu_value": controllers.arpuCrt.text,
        "address_id": addressId,
        "lead_id": leadId,
        "name": controllers.leadNameCrt[0].text,
        "title": controllers.leadTitles.value,
        "phone_no": controllers.leadMobileCrt[0].text,
        "whatsapp_number": controllers.leadMobileCrt[0].text,
        "email": controllers.leadEmailCrt[0].text,
        "action": "update_customer"
      };

      print("data lead ${data.toString()}");
      final request = await http.post(
        Uri.parse(scriptApi),
        // headers: {
        //   "Accept": "application/text",
        //   "Content-Type": "application/x-www-form-urlencoded"
        // },
        body: jsonEncode(data),
        // encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");

      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 &&
          response["message"] == "Customer updated successfully.") {
        utils.snackBar(
            msg: "Your Lead is updated successfully !",
            color: colorsConst.primary,
            context: Get.context!);
        controllers.leadFuture = apiService.leadsDetails(leadId);
        Get.back();
        //Get.to(const CompanyCamera(),transition: Transition.downToUp,duration: const Duration(seconds: 2));
        apiService.allNewLeadsDetails();
        apiService.allLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        // await Future.delayed(const Duration(milliseconds: 100));
        // Get.to(const Suspects(),duration: Duration.zero);
        // Navigator.push(context,
        //   PageRouteBuilder(
        //     pageBuilder: (context, animation1, animation2) => const ViewLead(),
        //     transitionDuration: Duration.zero,
        //     reverseTransitionDuration: Duration.zero,
        //   ),
        // );
        //Get.to(const ViewLead());
        controllers.leadCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.leadCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.leadCtr.reset();
    }
  }

  Future fetchPinCodeData(String pinCode) async {
    try {
      controllers.selectedCountry.value = "Loading...";
      controllers.selectedState.value = "Loading...";
      controllers.selectedCity.value = "Loading...";
      final response = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pinCode'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          final district = postOffice['District'];
          final state = postOffice['State'];
          final country = postOffice['Country'];
          controllers.selectedCountry.value = country;
          controllers.selectedState.value = state;
          controllers.selectedCity.value = district;
          // return {
          //   'district': district,
          //   'state': state,
          //   'country': country,
          // };
        } else {
          controllers.selectedCountry.value = "India";
          controllers.selectedState.value = "";
          controllers.selectedCity.value = "";
          print('Failed to fetch location data: ${data[0]['Message']}');
          // throw Exception('Failed to fetch location data: ${data[0]['Message']}');
        }
      } else {
        controllers.selectedCountry.value = "India";
        controllers.selectedState.value = "";
        controllers.selectedCity.value = "";
        print('Failed to fetch location data');
        //throw Exception('Failed to fetch location data');
      }
    } catch (e) {
      controllers.selectedCountry.value = "India";
      controllers.selectedState.value = "";
      controllers.selectedCity.value = "";
      print('Failed to fetch location data');
    }
  }

  Future insertProductAPI(BuildContext context) async {
    try {
      Map data = {
        "name": controllers.prodNameController.text.trim(),
        "brand": controllers.prodBrandController.text.trim(),
        "category": controllers.categoryController.text.trim(),
        "sub_category": controllers.subCategory,
        "compare_price": controllers.comparePriceController.text.trim(),
        "tax": controllers.tax,
        "cos_id": cosId,
        "discount": controllers.discountOnMRPController.text.trim(),
        "product_price": controllers.productPriceController.text.trim(),
        "description": controllers.prodDescriptionController.text.trim(),
        "net_price": controllers.netPriceController.text.trim(),
        "max_discount": controllers.discountController.text.trim(),
        "code": controllers.hsnController.text.trim(),
        "mark_as_top": controllers.topProduct,
      };

      print("data ${data.toString()}");
      final request = await http.post(
        Uri.parse(insertProduct),
        // headers: {
        //   "Accept": "application/text",
        //   "Content-Type": "application/x-www-form-urlencoded"
        // },
        body: jsonEncode(data),
        // encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      // Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200) {
        utils.snackBar(
            msg: "Your product created successfully",
            color: colorsConst.primary,
            context: Get.context!);
        //final prefs =await SharedPreferences.getInstance();
        controllers.prodNameController.clear();
        controllers.prodBrandController.clear();
        controllers.categoryController.clear();
        controllers.subCategory = null;
        controllers.comparePriceController.clear();
        controllers.tax = null;
        controllers.discountOnMRPController.clear();
        controllers.productPriceController.clear();
        controllers.prodDescriptionController.clear();
        controllers.netPriceController.clear();
        controllers.discountController.clear();
        controllers.hsnController.clear();
        controllers.topProduct = null;
        //Get.to(const CompanyCamera(),transition: Transition.downToUp,duration: const Duration(seconds: 2));
        controllers.allProductFuture = apiService.allProductDetails();
        await Future.delayed(const Duration(milliseconds: 100));
        // Navigator.push(context,
        //   PageRouteBuilder(
        //     pageBuilder: (context, animation1, animation2) => const ViewProduct(),
        //     transitionDuration: Duration.zero,
        //     reverseTransitionDuration: Duration.zero,
        //   ),
        // );
        Get.to(
          const ViewProduct(),
          duration: Duration.zero,
        );
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  List<Map<String, String>> prospectsList = [];

  Future insertProspectsAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      print("data ${list.toString()}");
      final request = await http.post(Uri.parse(prospectsScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(list),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "ok") {
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        Navigator.pop(context);
        Get.to(const Prospects(), duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
      //throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
      //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future insertSuspectsAPI(BuildContext context) async {
    try {
      print("data ${qualifiedList.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body:
              jsonEncode({"action": "insert_suspects", "list": qualifiedList}),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "ok") {
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        Navigator.pop(context);
        Get.to(const Suspects(), duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
      //throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
      //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future deleteCustomersAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      print("data ${list.toString()}");
      Map data = {"action": "delete_customers", "cusList": list};
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "ok") {
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        prospectsList.clear();
        qualifiedList.clear();
        customerList.clear();
        Navigator.pop(context);
        //Get.to(const Prospects(),duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future insertCustomersAPI(
      BuildContext context, List<Map<String, dynamic>> customerData) async {
    try {
      print("data ${customerData.toString()}");

      // Convert values to strings if necessary
      List<Map<String, dynamic>> formattedData = customerData.map((customer) {
        return customer.map((key, value) {
          return MapEntry(
              key, value.toString()); // Convert all values to String
        });
      }).toList();

      Map data = {"action": "create_customers", "cusList": formattedData};

      print("Final Data to be sent: ${jsonEncode(data)}"); // Debug JSON

      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json" // Change Content-Type to JSON
        },
        body: jsonEncode(data),
      );

      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);

      if (request.statusCode == 200 &&
          response["message"] == "Customer saved successfully.") {
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        prospectsList.clear();
        qualifiedList.clear();
        customerList.clear();
        int success = response["success"];
        int failed = response["failed"];
        Navigator.pop(context);
        controllers.customerCtr.reset();
        if (failed == 0) {
          print("All customers saved successfully.");
        } else {
          print("⚠️ $success saved, $failed failed.");
          for (var failure in response["failures"]) {
            print("Failed Phone: ${failure["phone_no"]} — ${failure["error"]}");
          }
          errorDialog(Get.context!,
              "$success saved, $failed failed.\n Failed Phone: ${response["failures"]}");
        }
      } else {
        print("insert customers error ${request.body}");
        Navigator.pop(context);
        errorDialog(Get.context!, "Failed to insert customer details.");
        controllers.customerCtr.reset();
      }
    } catch (e) {
      print("Result $e");
      Navigator.pop(context);
      errorDialog(Get.context!, "Failed to insert customer details.");
      controllers.customerCtr.reset();
    }
  }

  Future<void> insertSingleCustomer(context) async {
    try {
      //1-Suspects,2-Prospects,3-Qualified,4-Customers.
      var leadId; //controllers.visitType
      // for (var role in controllers.leadCategoryList) {
      //   if (role['value'] == controllers.leadCategory) {
      //     leadId = role['id'];
      //     break;
      //   }
      // }
      leadId = controllers.leadCategory == "Suspects"
          ? "1"
          : controllers.leadCategory == "Prospects"
              ? "2"
              : controllers.leadCategory == "Qualified"
                  ? "3"
                  : "4";
      var callListId;
      for (var role in controllers.callList) {
        if (role['value'] == controllers.visitType) {
          callListId = role['id'];
          break;
        }
      }
      List<Map<String, String>> customersList = [];
      //for (int i = 0; i < _addCustomer.length; i++) {
      customersList.add({
        "cos_id": cosId,
        "name": controllers.leadNameCrt[0].text.trim(),
        "email": controllers.leadEmailCrt[0].text.trim(),
        "phone_no": controllers.leadMobileCrt[0].text.trim(),
        "whatsapp_no": controllers.leadMobileCrt[0].text.trim(),
        "created_by": controllers.storage.read("id"),
        "platform": "3",
        "department": "",
        "designation": "",
        "main_person": "1"
      });
      // }
      String jsonString = json.encode(customersList);
      Map<String, dynamic> data = {
        "action": "single_customer",
        "user_id": controllers.storage.read("id"),
        "company_name": controllers.leadCoNameCrt.text.trim(),
        "product_discussion": controllers.prodDescriptionController.text.trim(),
        "source": controllers.leadDisPointsCrt.text.trim(),
        "points": controllers.leadActions.text.trim(),
        "quotation_status": "",
        "door_no": controllers.doorNumberController.text.trim(),
        "area": controllers.areaController.text.trim(),
        "city": controllers.cityController.text.trim(),
        "country": controllers.selectedCountry.value,
        "state": controllers.stateController.text.trim(),
        "pincode": controllers.pinCodeController.text.trim(),
        "co_website": controllers.leadWebsite.text.trim(),
        "co_number": controllers.leadCoMobileCrt.text.trim(),
        "co_email": controllers.leadCoEmailCrt.text.trim(),
        "linkedin": controllers.leadLinkedinCrt.text.trim(),
        "gst_number": controllers.leadGstNumCrt.text.trim(),
        "gst_DOR": controllers.leadDOR.value,
        "gst_location": controllers.leadGstLocationCrt.text.trim(),
        "type": "1",
        "lat": "",
        "lng": "",
        "platform": "3",
        "cos_id": cosId,
        "lead_status": leadId,
        "status": controllers.status,
        "quotation_required": "1",
        "visit_type": callListId,
        "data": jsonString,
        'prospect_enrollment_date':
            controllers.prospectEnrollmentDateCrt.text.trim(),
        'expected_convertion_date':
            controllers.expectedConversionDateCrt.text.trim(),
        'status_update': controllers.statusCrt.text.trim(),
        'num_of_headcount': controllers.noOfHeadCountCrt.text.trim(),
        'expected_billing_value':
            controllers.expectedConversionDateCrt.text.trim(),
        'arpu_value': controllers.arpuCrt.text.trim(),
        'details_of_service_required': controllers.sourceCrt.text.trim(),
        'rating': controllers.prospectGradingCrt.text.trim(),
        'owner': controllers.leadTitleCrt[0].text.trim()
      };
      print("insert lead $data");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      //Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 &&
          request.body.toString().contains("Customer saved successfully")) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove("leadName");
        prefs.remove("leadCount");
        prefs.remove("leadMobileNumber");
        prefs.remove("leadEmail");
        prefs.remove("leadTitle");
        prefs.remove("leadWhatsApp");
        prefs.remove("leadCoName");
        prefs.remove("leadCoMobile");
        prefs.remove("leadWebsite");
        prefs.remove("leadCoEmail");
        prefs.remove("leadProduct");
        prefs.remove("leadOwnerName");
        prefs.remove("industry");
        prefs.remove("source");
        prefs.remove("status");
        prefs.remove("rating");
        prefs.remove("service");
        prefs.remove("leadDNo");
        prefs.remove("leadStreet");
        prefs.remove("leadArea");
        prefs.remove("leadCity");
        prefs.remove("leadPinCode");
        prefs.remove("budget");
        prefs.remove("leadState");
        prefs.remove("leadCountry");
        prefs.remove("leadX");
        prefs.remove("leadLinkedin");
        prefs.remove("leadTime");
        prefs.remove("leadDescription");
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        prospectsList.clear();
        qualifiedList.clear();
        customerList.clear();
        Navigator.pop(context);
        //Get.to(const Prospects(),duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  List<Map<String, String>> qualifiedList = [];
  Future insertQualifiedAPI(BuildContext context) async {
    try {
      print("data ${qualifiedList.toString()}");
      final request = await http.post(Uri.parse(qualifiedScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(qualifiedList),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "ok") {
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        Navigator.pop(context);
        qualifiedList.clear();
        Get.to(const Qualified(), duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
      //throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
      //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  List<Map<String, String>> customerList = [];

  Future insertPromoteCustomerAPI(BuildContext context) async {
    try {
      Map data = {"action": "promote_customers", "cusList": customerList};
      print("customer $data");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "ok") {
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        controllers.allCustomerFuture = apiService.allCustomerDetails();
        Navigator.pop(context);
        customerList.clear();
        Get.to(const ViewCustomer(), duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
      //throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
      //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future insertCompanyAPI(BuildContext context) async {
    try {
      Map data = {
        "coName": controllers.coNameController.text.trim(),
        "industry": controllers.coIndustry,
        "phone_map": controllers.coMobileController.text.trim(),
        "product": controllers.coProductController.text.trim(),
        "email": controllers.coEmailController.text.trim(),
        "website": controllers.coWebSiteController.text.trim(),
        "cos_id": cosId,
        "x": controllers.coXController.text.trim(),
        "linkedin": controllers.coLinkedinController.text.trim(),
        "door_no": controllers.coDNoController.text.trim(),
        "street_name": controllers.coStreetController.text.trim(),
        "area": controllers.coAreaController.text.trim(),
        "city": controllers.selectedCity,
        "state": controllers.selectedState,
        "pin_code": controllers.coPinCodeController.text.trim(),
        "country": controllers.selectedCountry.value,
      };

      print("data ${data.toString()}");
      final request = await http.post(
        Uri.parse(insertCompany),
        // headers: {
        //   "Accept": "application/text",
        //   "Content-Type": "application/x-www-form-urlencoded"
        // },
        body: jsonEncode(data),
        // encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      // Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 &&
          request.body == "{\"status_code\":200,\"message\":\"ok\"}") {
        utils.snackBar(
            msg: "Your company created successfully",
            color: colorsConst.primary,
            context: Get.context!);
        final prefs = await SharedPreferences.getInstance();
        prefs.remove("coName");
        prefs.remove("coMobile");
        prefs.remove("coWebsite");
        prefs.remove("coEmail");
        prefs.remove("coProduct");
        prefs.remove("coIndustry");

        prefs.remove("coDNo");
        prefs.remove("coStreet");
        prefs.remove("coArea");
        prefs.remove("leadPinCode");
        prefs.remove("coX");
        prefs.remove("coLinkedin");
        //Get.to(const CompanyCamera(),transition: Transition.downToUp,duration: const Duration(seconds: 2));
        //controllers.allProductFuture=apiService.allProductDetails();
        await Future.delayed(const Duration(milliseconds: 100));
        // Navigator.push(context,
        //   PageRouteBuilder(
        //     pageBuilder: (context, animation1, animation2) => const ViewProduct(),
        //     transitionDuration: Duration.zero,
        //     reverseTransitionDuration: Duration.zero,
        //   ),
        // );
        //Get.to(const ViewProduct(),duration: Duration.zero,);
        controllers.leadCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.leadCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.leadCtr.reset();
    }
  }

  void loginCApi() async {
    try {
      Map data = {
        "mobile_number": controllers.loginNumber.text,
        "password": controllers.loginPassword.text,
        "unit_login": "0",
        "action": "sign_on"
      };
      final request = await http.post(Uri.parse(login),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      //print("Login Res ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200) {
        controllers.storage.write("f_name", response["firstname"]);
        controllers.storage.write("role", response["role"]);
        controllers.storage.write("role_name", response["role_name"]);
        controllers.storage.write("id", response["id"]);

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("loginScreen", true);
        String input = response["role_name"];
        controllers.isAdmin.value = input == "Admin" ? true : false;
        prefs.setBool("isAdmin", controllers.isAdmin.value);
        prefs.remove("loginNumber");
        prefs.remove("loginPassword");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        controllers.allCustomerFuture = apiService.allCustomerDetails();
        utils.snackBar(
          context: Get.context!,
          msg: "Login Successfully",
          color: Colors.green,
        );
        Get.to(const Dashboard(), duration: Duration.zero);
        controllers.loginCtr.reset();
      } else {
        errorDialog(Get.context!, 'No Account Found');
        controllers.loginCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, 'Login failed: ${e.toString()}');
      controllers.loginCtr.reset();
    }
  }

  void loginHistoryApi() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    final allInfo = webBrowserInfo.data;
    try {
      Map data = {
        "mobile_number": controllers.loginNumber.text,
        "password": controllers.loginPassword.text,
        "cos_id": cosId,
        "app_version": controllers.versionNum,
        "device_id": webBrowserInfo.productSub,
        "device_brand": allInfo.toString(),
        "device_model": webBrowserInfo.product,
        "device_os": webBrowserInfo.deviceMemory,
        "platform": "3",
        "action": "sign_on"
      };
      final request = await http.post(Uri.parse(login),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200) {
        controllers.storage.write("f_name", response["firstname"]);
        controllers.storage.write("role", response["role"]);
        controllers.storage.write("role_name", response["role"]);
        controllers.storage.write("id", response["id"]);

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("loginScreen", true);
        String input = response["role_name"];
        controllers.isAdmin.value = input == "Admin" ? true : false;
        prefs.setBool("isAdmin", controllers.isAdmin.value);
        prefs.remove("loginNumber");
        prefs.remove("loginPassword");
        utils.snackBar(
          context: Get.context!,
          msg: "Login Successful",
          color: Colors.green,
        );
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        controllers.allCustomerFuture = apiService.allCustomerDetails();
        Get.to(const Dashboard(), duration: Duration.zero);
        controllers.loginCtr.reset();
      } else {
        errorDialog(Get.context!, 'Login failed');
        controllers.loginCtr.reset();
      }
    } catch (e) {
      errorDialog(Get.context!, 'Login failed: ${e.toString()}');
      controllers.loginCtr.reset();
    }
  }

  Future getLeadCategory() async {
    try {
      Map data = {
        "search_type": "category",
        "cat_id": cosId == '202410' ? "1" : "3",
        "cos_id": cosId,
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.leadCategoryList.clear();
        controllers.leadCategoryGrList.clear();
        controllers.leadCategoryList.value = response;
        for (var i = 0; i < response.length; i++) {
          controllers.leadCategoryGrList.add(response[i]["value"]);
        }
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future getVisitType() async {
    try {
      Map data = {
        "search_type": "visit_type",
        "cat_id": "2",
        "cos_id": cosId,
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.callNameList = [];
        for (int i = 0; i < response.length; i++) {
          if (!controllers.callNameList.contains(response[i]["value"])) {
            controllers.callNameList.add(response[i]["value"]);
          }
        }
        controllers.callList.clear();
        controllers.callList.value = response;
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future insertUsersPHP(BuildContext context) async {
    try {
      var roleId;
      for (var role in controllers.roleList) {
        if (role['role'] == controllers.role) {
          roleId = role['id'];
          break;
        }
      }
      controllers.roleId = roleId.toString();
      Map data = {
        "firstname": controllers.signFirstName.text.trim(),
        "surname": controllers.signLastName.text.trim(),
        "mobile_number": controllers.signMobileNumber.text.trim(),
        "whatsapp_number": controllers.signWhatsappNumber.text.trim(),
        "email_id": controllers.signEmailID.text.trim(),
        "referred_by": controllers.signReferBy.text.trim(),
        "password": controllers.signPassword.text.trim(),
        "role": controllers.roleId,
        "created_by": controllers.storage.read("id"),
        "boss_id": controllers.storage.read("id"),
        "cos_id": cosId,
        "platform": "3"
      };
      final request = await http.post(Uri.parse(insertUser),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      //Map<String, dynamic> res = json.decode(request.body);
      if (request.statusCode == 200) {
        utils.snackBar(
            context: Get.context!,
            msg: "User created successfully",
            color: Colors.green);
        controllers.loginCtr.success();

        final prefs = await SharedPreferences.getInstance();
        prefs.remove("sign_first_name");
        prefs.remove("sign_mobile_number");
        prefs.remove("sign_whatsapp_number");
        prefs.remove("sign_password");
        prefs.remove("sign_email_id");
        controllers.signFirstName.clear();
        controllers.signLastName.clear();
        controllers.signMobileNumber.clear();
        controllers.signWhatsappNumber.clear();
        controllers.signPassword.clear();
        controllers.signEmailID.clear();
        controllers.signReferBy.clear();
        controllers.role = null;
      } else if (request.body == '{"fail":"Phone number already exits"}') {
        errorDialog(
            Get.context!, "Employee with this Phone Number already exits");
        // utils.snackBar(context: Get.context!, msg:"Employee with this Phone Number already exits",color:colorsConst.primary,);
        //Get.to(const SignUp());
        controllers.loginCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        //utils.snackBar(context: Get.context!, msg: "Your Request Failed",color:colorsConst.primary,);
        controllers.loginCtr.reset();
      }
    } on SocketException {
      controllers.loginCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
      //throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.loginCtr.reset();
      errorDialog(Get.context!, 'Server error employee: ${e.toString()}');
      //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      controllers.loginCtr.reset();
      errorDialog(Get.context!, 'Unexpected error Signup: ${e.toString()}');
      //throw Exception('Unexpected error employee: ${e.toString()}'); // Catch other exceptions
    }
  }

  // Future insertEmailAPI(BuildContext context,String id) async {
  //   try{
  //     final uri=Uri.parse('https://crm.hapirides.in/$version1/mail_receive.php');
  //     var request=http.MultipartRequest("POST",uri);
  //     //request.fields["clientMail"]=controllers.emailToCtr.text.trim();
  //     request.fields["clientMail"]="butterscotch1902@gmail.com";
  //     request.fields["subject"]=controllers.emailSubjectCtr.text;
  //     request.fields["cos_id"]=cosId;
  //     request.fields["count"]='${controllers.emailCount.value+1}';
  //     request.fields["quotation_name"]=controllers.emailQuotationCtr.text;
  //     request.fields["body"]=controllers.emailMessageCtr.text;
  //     request.fields["user_id"]="1";
  //     request.fields["id"]=id;
  //     request.fields["date"]="${(controllers.dateTime.day.toString().padLeft(2,"0"))}-${(controllers.dateTime.month.toString().padLeft(2,"0"))}-${(controllers.dateTime.year.toString())} ${DateFormat('hh:mm a').format(DateTime.now()).toString()}";
  //     request.fields["dates"]="${(controllers.dateTime.day.toString().padLeft(2,"0"))}-${(controllers.dateTime.month.toString().padLeft(2,"0"))}-${(controllers.dateTime.year.toString())} ${DateFormat('hh:mm a').format(DateTime.now()).toString()}";
  //
  //     var response =await request.send();
  //     var output=await http.Response.fromStream(response);
  //     print("result ${output.body}");
  //     print("fields ${request.fields}");
  //     if(response.statusCode==200){
  //
  //     }else{
  //       print("Failed");
  //       utils.snackBar(msg: "Mail has not sent ${output.body}",color: colorsConst.primary,context:Get.context!);
  //       controllers.emailCtr.reset();
  //     }
  //
  //   } on SocketException {
  //     controllers.emailCtr.reset();
  //     errorDialog(Get.context!,'No internet connection');
  //     //throw Exception('No internet connection'); // Handle network errors
  //   } on HttpException catch (e) {
  //     controllers.emailCtr.reset();
  //     errorDialog(Get.context!,'Server error email: ${e.toString()}');
  //     //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
  //   } catch (e) {
  //     controllers.emailCtr.reset();
  //     errorDialog(Get.context!,'Unexpected error email: ${e.toString()}');
  //     //throw Exception('Unexpected error employee: ${e.toString()}'); // Catch other exceptions
  //   }
  // }

  // Future insertEmailAPI(BuildContext context,String id) async {
  //   try{
  //     Map data ={
  //     "clientMail":controllers.emailToCtr.text,
  //     "subject":controllers.emailSubjectCtr.text,
  //     "cos_id":cosId,
  //     "count":'${controllers.emailCount.value+1}',
  //     "quotation_name":controllers.emailQuotationCtr.text,
  //     "body":controllers.emailMessageCtr.text,
  //     "user_id":controllers.storage.read("id"),
  //     "id":id,
  //     "date":"${(controllers.dateTime.day.toString().padLeft(2,"0"))}-${(controllers.dateTime.month.toString().padLeft(2,"0"))}-${(controllers.dateTime.year.toString())} ${DateFormat('hh:mm a').format(DateTime.now()).toString()}",
  //       "action":"mail_receive"
  //     };
  //
  //     print("data ${data.toString()}");
  //     final request = await http.post(Uri.parse(scriptApi),
  //       // headers: {
  //       //   "Accept": "application/text",
  //       //   "Content-Type": "application/x-www-form-urlencoded"
  //       // },
  //       body: jsonEncode(data),
  //       // encoding: Encoding.getByName("utf-8")
  //     );
  //     print("request ${request.body}");
  //     // Map<String, dynamic> response = json.decode(request.body);
  //     if (request.statusCode == 200 && request.body == "Message has been sent"){
  //       utils.snackBar(msg: "Mail has been sent",color: Colors.green,context:Get.context!);
  //       controllers.emailMessageCtr.clear();
  //       controllers.emailToCtr.clear();
  //       controllers.emailSubjectCtr.clear();
  //        apiService.allLeadsDetails();
  //       controllers.allNewLeadFuture=apiService.allNewLeadsDetails();
  //       controllers.allGoodLeadFuture=apiService.allGoodLeadsDetails();
  //       await Future.delayed(const Duration(milliseconds: 100));
  //       Navigator.pop(Get.context!);
  //       controllers.emailCtr.reset();
  //     } else {
  //       controllers.emailCtr.reset();
  //       errorDialog(Get.context!,"Mail has been not sent");
  //     }
  //   }catch(e){
  //     errorDialog(Get.context!,e.toString());
  //     controllers.emailCtr.reset();
  //   }
  // }
  Future insertEmailAPI(BuildContext context, String id, String image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      // Body values
      request.fields['clientMail'] = controllers.emailToCtr.text;
      request.fields['subject'] = controllers.emailSubjectCtr.text;
      request.fields['cos_id'] = cosId.toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
      request.fields['body'] = controllers.emailMessageCtr.text;
      request.fields['user_id'] = controllers.storage.read("id").toString();
      request.fields['id'] = id;
      request.fields['date'] =
          "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] = 'mail_receive';

      if (imageController.empFileName.value.isNotEmpty) {
        var picture1 = http.MultipartFile.fromBytes(
          "attachment",
          imageController.empMediaData,
          filename: imageController.empFileName.value,
          //contentType: http.MediaType('image', 'jpeg'),
        );
        request.files.add(picture1);
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();
      print("Response: $body");
      if (response.statusCode == 200 && body == "Message has been sent") {
        utils.snackBar(
            msg: "Mail has been sent",
            color: Colors.green,
            context: Get.context!);
        controllers.emailMessageCtr.clear();
        controllers.emailToCtr.clear();
        controllers.emailSubjectCtr.clear();
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(Get.context!);
        controllers.emailCtr.reset();
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has been not sent");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  // Future insertCustomerAPI(BuildContext context) async {
  //   try{
  //     Map data ={
  //       "name":controllers.customerNameController.text.trim(),
  //       "customer_id":controllers.customerIdController.text.trim(),
  //       "mobile_number":controllers.customerMobileController.text.trim(),
  //       "email":controllers.customerEmailController.text.trim(),
  //       "co_name":controllers.customerCoNameController.text.trim(),
  //       "no_unit":controllers.customerNoUnitController.text.trim(),
  //       "no_employees":controllers.noOfEmpController.text.trim(),
  //       "cos_id":cosId,
  //       "field_officer":controllers.customerFieldOfficerController.text.trim(),
  //       "description":controllers.customerDescriptionController.text.trim(),
  //       "door_no":controllers.customerUnitNameController.text.trim(),
  //       "street_name":controllers.customerStreetController.text.trim(),
  //       "area":controllers.customerAreaController.text.trim(),
  //       "city":controllers.customerCityController.text.trim(),
  //       "state":controllers.states,
  //       "pin_code":controllers.customerPinCodeController.text.trim(),
  //       "country":controllers.customerCountryController.text.trim(),
  //     };
  //
  //     print("data ${data.toString()}");
  //     final request = await http.post(Uri.parse(insertCustomer),
  //         // headers: {
  //         //   "Accept": "application/text",
  //         //   "Content-Type": "application/x-www-form-urlencoded"
  //         // },
  //         body: jsonEncode(data),
  //         // encoding: Encoding.getByName("utf-8")
  //     );
  //     //print("request ${request.body}");
  //     // Map<String, dynamic> response = json.decode(request.body);
  //     if (request.statusCode == 200){
  //       utils.snackBar(msg: "Your customer created successfully",color: colorsConst.primary,context:Get.context!);
  //       //final prefs =await SharedPreferences.getInstance();
  //       controllers.customerNameController.clear();
  //       controllers.customerIdController.clear();
  //        controllers.customerMobileController.clear();
  //       controllers.customerEmailController.clear();
  //       controllers.customerCoNameController.clear();
  //       controllers.customerNoUnitController.clear();
  //       controllers.noOfEmpController.clear();
  //       controllers.customerFieldOfficerController.clear();
  //        controllers.customerDescriptionController.clear();
  //        controllers.customerUnitNameController.clear();
  //        controllers.customerStreetController.clear();
  //         controllers.customerAreaController.clear();
  //         controllers.customerCityController.clear();
  //         controllers.states=null;
  //         controllers.customerPinCodeController.clear();
  //         controllers.customerCountryController.clear();
  //       //Get.to(const CompanyCamera(),transition: Transition.downToUp,duration: const Duration(seconds: 2));
  //       controllers.allCustomerFuture=apiService.allCustomerDetails();
  //       await Future.delayed(const Duration(milliseconds: 100));
  //       Navigator.push(Get.context!,
  //         PageRouteBuilder(
  //           pageBuilder: (context, animation1, animation2) => const ViewCustomer(),
  //           transitionDuration: Duration.zero,
  //           reverseTransitionDuration: Duration.zero,
  //         ),
  //       );
  //       //Get.to(const ViewCustomer());
  //       controllers.customerCtr.reset();
  //     } else {
  //       controllers.customerCtr.reset();
  //       errorDialog(Get.context!,request.body);
  //     }
  //   }catch(e){
  //     errorDialog(Get.context!,e.toString());
  //     controllers.customerCtr.reset();
  //   }
  // }
  void errorDialog(BuildContext context, String text) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: colorsConst.primary,
            iconPadding: const EdgeInsets.fromLTRB(0, 0.5, 1, 0),
            icon: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controllers.leadCtr.reset();
                    },
                    icon: Icon(
                      Icons.close,
                      color: colorsConst.third,
                    ))),
            title: const Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
            content: CustomText(
              text: text,
              textAlign: TextAlign.center,
              size: 14,
              isBold: true,
              colors: Colors.white,
            ),
          );
        });
  }
  // void errorDialog(BuildContext context,String text){
  //   showDialog(context: context,
  //       barrierDismissible: false,
  //       builder:(context){
  //         return AlertDialog(
  //           // backgroundColor: colorsConst.primary,
  //             title: const Center(
  //               child: Column(
  //                 children:[
  //                   Icon(Icons.error_outline,size: 30,color: Colors.red,)
  //                 ],
  //               ),
  //             ),
  //             content:CustomText(
  //               text: text,
  //               size: 14,
  //               isBold: true,
  //             ),
  //           actions: [
  //             SizedBox(
  //               width: 80,
  //               height: 35,
  //               child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     shape: const RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.zero
  //                     ),
  //                     backgroundColor: colorsConst.primary,
  //                   ),
  //                   onPressed: (){
  //                     Navigator.pop(context);
  //
  //                   },
  //                   child: const CustomText(
  //                     text: "Close",
  //                     colors: Colors.white,
  //                     size: 14,
  //                     isBold: true,
  //                   )),
  //             ),
  //           ],
  //         );
  //       }
  //   );
  // }

  Future<List<ProductObj>> allProductDetails() async {
    final url = Uri.parse(scriptApi);
    controllers.allProductLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
            {"search_type": "product", "cos_id": cosId, "action": "get_data"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allProductLength.value = data.length;
        return data.map((json) => ProductObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load products: Status code ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      throw Exception(
          'Server error product: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      throw Exception(
          'Unexpected error product: ${e.toString()}'); // Catch other exceptions
    }
  }

  Future<List<CommentsObj>> allCommentDetails(String id) async {
    controllers.allDirectVisit.value = "0";
    controllers.allTelephoneCalls.value = "0";
    final url = Uri.parse(scriptApi); // Double-check URL correctness
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "customer_comments",
          "id": id,
          "cos_id": cosId,
          "action": "get_data"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        var type1Count = data.where((item) => item['type'] == "1").length;
        var type2Count = data.where((item) => item['type'] == "2").length;
        controllers.allDirectVisit.value = type1Count.toString();
        controllers.allTelephoneCalls.value = type2Count.toString();
        return data.map((json) => CommentsObj.fromJson(json)).toList();
      } else {
        controllers.allDirectVisit.value = "0";
        controllers.allTelephoneCalls.value = "0";
        throw Exception(
            'Failed to load products: Status code ${response.body}');
      }
    } on SocketException {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Server error product: ${e.toString()}');
    } catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Unexpected error product: ${e.toString()}');
    }
  }

  Future<List<MailReceiveObj>> mailCommentDetails(String id) async {
    final url = Uri.parse(scriptApi);
    print("Id $id}");
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "mail_comments",
          "id": id,
          "cos_id": cosId,
          "action": "get_data"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        // var type1Count = data.where((item) => item['type'] == "1").length;
        // var type2Count = data.where((item) => item['type'] == "2").length;
        // controllers.allDirectVisit.value = type1Count.toString();
        // controllers.allTelephoneCalls.value = type2Count.toString();
        return data.map((json) => MailReceiveObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load products: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error product: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error product: ${e.toString()}');
    }
  }

  Future<List<CommentsObj>> allCommentReportDetails() async {
    controllers.allDirectVisit.value = "0";
    controllers.allTelephoneCalls.value = "0";
    final url = Uri.parse(scriptApi); // Double-check URL correctness
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "mail_receive",
          "id": controllers.storage.read("id"),
          "role": controllers.storage.read("role"),
          "cos_id": cosId,
          "action": "get_data"
        }),
      );
      print("com ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        var type1Count = data.where((item) => item['type'] == "1").length;
        var type2Count = data.where((item) => item['type'] == "2").length;
        controllers.allDirectVisit.value = type1Count.toString();
        controllers.allTelephoneCalls.value = type2Count.toString();
        return data.map((json) => CommentsObj.fromJson(json)).toList();
      } else {
        controllers.allDirectVisit.value = "0";
        controllers.allTelephoneCalls.value = "0";
        throw Exception(
            'Failed to load products: Status code ${response.body}');
      }
    } on SocketException {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Server error product: ${e.toString()}');
    } catch (e) {
      controllers.allDirectVisit.value = "0";
      controllers.allTelephoneCalls.value = "0";
      throw Exception('Unexpected error product: ${e.toString()}');
    }
  }

  void mailReceiveDetails(String id) async {
    final url = Uri.parse(scriptApi); // Double-check URL correctness
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "mail_receive",
          "cos_id": cosId,
          "sent_id": id,
          "action": "get_data"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Cast to List
        controllers.mailReceivesList.value = data;
        controllers.emailCount.value = int.parse(controllers
                .mailReceivesList[controllers.mailReceivesList.length - 1]
            ['sent_count']);
        print(controllers.emailCount.value);
        //print("Mails ${controllers.mailReceivesList}");
      } else {
        controllers.mailReceivesList.value = [];
        throw Exception(
            'Failed to load leads: Status code ${response.statusCode}'); // Provide more specific error message
      }
    } on SocketException {
      controllers.mailReceivesList.value = [];
      print('No internet connection');
    } on HttpException catch (e) {
      controllers.mailReceivesList.value = [];
      print('Server error: ${e.toString()}');
    } catch (e) {
      controllers.mailReceivesList.value = [];
      print('Unexpected error lead : ${e.toString()}');
    }
  }

  Future<List<NewLeadObj>> allLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allLeadsLength.value = 0;
    print("lead id role ${controllers.storage.read("role")}");
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": cosId,
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "2",
          "action": "get_data"
        }),
      );
      controllers.isLead.value = true;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List; // Cast to List
        controllers.allLeadsLength.value = data.length;
        controllers.isLeadsList.value = [];
        for (int i = 0; i < controllers.allLeadsLength.value; i++) {
          //controllers.isLeadsList.add(false);
          controllers.isLeadsList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
          });
        }
        controllers.allLeadFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.allLeads.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load leads: Status code ${response.body}'); // Provide more specific error message
      }
    } on SocketException {
      print('No internet connection');
      throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      print('Server error: ${e.toString()}');
      throw Exception('Server error: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      controllers.allLeadFuture.value = [];
      controllers.allLeads.value = [];
      print('Unexpected error lead: ${e.toString()}');
      throw Exception(
          'Unexpected error lead: ${e.toString()}'); // Catch other exceptions
    }
  }

  Future<List<NewLeadObj>> leadsDetails(String leadId) async {
    controllers.isLeadLoading.value = true;
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "lead_details",
          "cos_id": cosId,
          "lead_id": leadId,
          "action": "get_data"
        }),
      );
      controllers.isLead.value = true;
      controllers.isLeadLoading.value = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        //controllers.allLeads.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load leads: Status code ${response.body}'); // Provide more specific error message
      }
    } on SocketException {
      controllers.isLeadLoading.value = false;
      print('No internet connection');
      throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.isLeadLoading.value = false;
      print('Server error: ${e.toString()}');
      throw Exception('Server error: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      controllers.isLeadLoading.value = false;
      print('Unexpected error lead: ${e.toString()}');
      throw Exception(
          'Unexpected error lead: ${e.toString()}'); // Catch other exceptions
    }
  }

  Future<void> allNewLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allNewLeadsLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": cosId,
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "1",
          "action": "get_data"
        }),
      );
      controllers.isLead.value = true;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allNewLeadsLength.value = data.length;
        controllers.isNewLeadList.clear();
        for (int i = 0; i < controllers.allNewLeadsLength.value; i++) {
          controllers.isNewLeadList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
          });
        }

        // Update the observable list with the fetched data
        controllers.allNewLeadFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      print('No internet connection');
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      print('Server error: ${e.toString()}');
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.allNewLeadFuture.value = [];
      print('Unexpected error: ${e.toString()}');
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Future<List<NewLeadObj>> allNewLeadsDetails() async {
  //   controllers.isLead.value=false;
  //   final url = Uri.parse(scriptApi);
  //   controllers.allNewLeadsLength.value=0;
  //   try {
  //     final response = await http.post(
  //       url,
  //       body: jsonEncode({
  //         "search_type": "leads",
  //         "cos_id":cosId,
  //         "role":controllers.storage.read("role"),
  //         "id":controllers.storage.read("id"),
  //         "lead_id":"1",
  //         "action":"get_data"
  //       }),
  //     );
  //     controllers.isLead.value=true;
  //     if (response.statusCode == 200){
  //       final data = jsonDecode(response.body) as List;
  //       controllers.allNewLeadsLength.value=data.length;
  //       controllers.isNewLeadList.value=[];
  //       for(int i=0;i<controllers.allNewLeadsLength.value;i++){
  //         controllers.isNewLeadList.add({
  //           "isSelect":false,
  //           "lead_id":data[i]["user_id"].toString(),
  //           "rating":data[i]["rating"].toString(),
  //         });
  //       }
  //       return data.map((json) => NewLeadObj.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load leads: Status code ${response.body}'); // Provide more specific error message
  //     }
  //   } on SocketException {
  //     print('No internet connection');
  //     throw Exception('No internet connection'); // Handle network errors
  //   } on HttpException catch (e) {
  //     print('Server error: ${e.toString()}');
  //     throw Exception('Server error: ${e.toString()}'); // Handle HTTP errors
  //   } catch (e) {
  //     print('Unexpected error lead: ${e.toString()}');
  //     throw Exception('Unexpected error lead: ${e.toString()}'); // Catch other exceptions
  //
  //   }
  // }

  Future<List<NewLeadObj>> allGoodLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi); // Double-check URL correctness
    controllers.allGoodLeadsLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": cosId,
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "3",
          "action": "get_data"
        }),
      );
      //print("lead ${response.body}");
      controllers.isLead.value = true;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List; // Cast to List
        controllers.allGoodLeadsLength.value = data.length;
        controllers.isGoodLeadList.value = [];
        for (int i = 0; i < controllers.allGoodLeadsLength.value; i++) {
          //controllers.isGoodLeadList.add(false);
          controllers.isGoodLeadList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
          });
        }
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load leads: Status code ${response.body}'); // Provide more specific error message
      }
    } on SocketException {
      print('No internet connection');
      throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      print('Server error: ${e.toString()}');
      throw Exception('Server error: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      print('Unexpected error lead: ${e.toString()}');
      throw Exception(
          'Unexpected error lead: ${e.toString()}'); // Catch other exceptions
    }
  }

  Future getRoles() async {
    try {
      Map data = {
        "search_type": "allroles",
        "cos_id": cosId,
        "action": "get_data"
      };

      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 200) {
        final List data = json.decode(request.body);
        controllers.roleNameList = [];
        for (int i = 0; i < data.length; i++) {
          controllers.roleNameList.add(data[i]["role"]);
        }
        controllers.roleList.value = data;
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future<List<CompanyObj>> allCompanyDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allCompanyLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
            {"search_type": "company", "cos_id": cosId, "action": "get_data"}),
      );
      //print("Company ${response.body}");
      controllers.isLead.value = true;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allCompanyLength.value = data.length;
        return data.map((json) => CompanyObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load companies: Status code ${response.statusCode}');
      }
    } on SocketException {
      print('No internet connection');
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      print('Server error: ${e.toString()}');
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      print('Unexpected error lead: ${e.toString()}');
      throw Exception('Unexpected error lead: ${e.toString()}');
    }
  }

  Future getDashBoardReport() async {
    try {
      Map data = {
        "search_type": "main_report",
        "id": controllers.storage.read("id"),
        "role": controllers.storage.read("role"),
        "cos_id": cosId,
        "action": "get_data",
        "date":
            "${DateTime.now().day.toString().padLeft(2, "0")}-${DateTime.now().month.toString().padLeft(2, "0")}-${DateTime.now().year.toString()}"
      };
      log("main ${data.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      log("view dashboard report");
      log(request.body);
      controllers.directVisit.value = "0";
      controllers.telephoneCalls.value = "0";
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        for (var i = 0; i < response.length; i++) {
          if (response[i]["type"] == "1") {
            controllers.directVisit.value = response[i]["type_count"];
          } else {
            controllers.telephoneCalls.value = response[i]["type_count"];
          }
        }
      } else {
        controllers.directVisit.value = "0";
        controllers.telephoneCalls.value = "0";
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.directVisit.value = "0";
      controllers.telephoneCalls.value = "0";
      throw Exception('Failed to load album');
    }
  }

  Future<List<NewLeadObj>> allCustomerDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allCustomerLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": cosId,
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "4",
          "action": "get_data"
        }),
      );
      //print("Customer ${response.body}");
      controllers.isLead.value = true;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allCustomerLength.value = data.length;
        // controllers.isGoodLeadList.value=[];
        // for(int i=0;i<controllers.allGoodLeadsLength.value;i++){
        //   controllers.isGoodLeadList.add(false);
        // }
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error lead: ${e.toString()}');
    }
  }

  Future<List<EmployeeObj>> allEmployeeDetails() async {
    final url = Uri.parse(scriptApi); // Double-check URL correctness
    controllers.allEmployeeLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
            {"search_type": "employee", "cos_id": cosId, "action": "get_data"}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allEmployeeLength.value = data.length;
        return data.map((json) => EmployeeObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load employee: Status code ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error employee: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error employee: ${e.toString()}');
    }
  }
}
