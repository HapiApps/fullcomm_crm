import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/controller/table_controller.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import 'package:fullcomm_crm/models/company_obj.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';
import 'package:fullcomm_crm/models/user_heading_obj.dart';
import 'package:fullcomm_crm/screens/leads/prospects.dart';
import 'package:fullcomm_crm/screens/leads/qualified.dart';
import 'package:fullcomm_crm/screens/leads/suspects.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/screens/new_dashboard.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/models/product_obj.dart';
import 'package:fullcomm_crm/screens/customer/view_customer.dart';
import 'package:fullcomm_crm/screens/products/view_product.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../controller/image_controller.dart';
import '../models/customer_activity.dart';
import '../models/employee_obj.dart';
import '../models/mail_receive_obj.dart';
import '../models/meeting_obj.dart';
import '../models/month_report_obj.dart';

final ApiService apiService = ApiService._();

class ApiService {
  ApiService._();

  Future insertLeadAPI(BuildContext context) async {
    var index = controllers.isMainPersonList.indexWhere((element) => element == true);
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
        "cos_id": controllers.storage.read("cos_id"),
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
      if (request.statusCode == 200 && response["message"] == "OK") {
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
        "cos_id": controllers.storage.read("cos_id"),
        "city": controllers.cityController.text,
        "source": controllers.source,
        "source_details": controllers.sourceCrt.text,
        "product_discussion": controllers.prodDescriptionController.text,
        "company_name": controllers.leadCoNameCrt.text.trim(),
        "points": controllers.additionalNotesCrt.text,
        "status": controllers.status,
        //"owner":controllers.leadOwnerNameCrt.text.trim(),
        'prospect_enrollment_date': controllers.prospectDate.value.isEmpty?"${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}":controllers.prospectDate.value,
        'expected_convertion_date': controllers.exDate.value.isEmpty?"${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}":controllers.exDate.value,
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
        "cos_id": controllers.storage.read("cos_id"),
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
        Uri.parse(scriptApi),
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
      if (request.statusCode == 200 && response["message"] == "OK") {
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        allQualifiedDetails();
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
  Future disqualifiedCustomersAPI(BuildContext context,List<Map<String, String>> list) async {
    try{
      print("data ${list.toString()}");
      Map data = {
        "action": "disqualified",
        "active": "2",
        "cusList": list
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="OK"){
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        apiService.allQualifiedDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        prospectsList.clear();
        qualifiedList.clear();
        customerList.clear();
        Navigator.pop(context);
        //Get.to(const Prospects(),duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }

  Future qualifiedCustomersAPI(BuildContext context,List<Map<String, String>> list) async {
    try{
      print("data ${list.toString()}");
      Map data = {
        "action": "disqualified",
        "active": "1",
        "cusList": list
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="OK"){
        apiService.allLeadsDetails();
        apiService.allQualifiedDetails();
        apiService.allNewLeadsDetails();
        apiService.allGoodLeadsDetails();
        apiService.allCustomerDetails();
        prospectsList.clear();
        qualifiedList.clear();
        customerList.clear();
        Navigator.pop(context);
        //Get.to(const Prospects(),duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      errorDialog(Get.context!,e.toString());
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
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allQualifiedDetails();
        allNewLeadsDetails();
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

  Future insertCallCommentAPI(BuildContext context,String type) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode({
                "action": "insert_call_comments",
                "customer_id": controllers.selectedCustomerId.value,
                "mobile_number": controllers.selectedCustomerMobile.value,
                "customer_name": controllers.selectedCustomerName.value,
                "type": type,
                "cos_id": controllers.storage.read("cos_id"),
                "call_type":controllers.callType,
                "call_status":controllers.callStatus,
                //"date":"${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}",
                "date":"${controllers.empDOB.value} ${controllers.callTime.value}",
                "created_by": controllers.storage.read("id"),
                "comments": controllers.callCommentCont.text.trim(),
              }),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "OK") {
        controllers.clearSelectedCustomer();
        controllers.empDOB.value = "";
        controllers.callTime.value = "";
          controllers.callType = null;
          controllers.callStatus = null;
        controllers.callCommentCont.text = "";
        getAllCallActivity();
        Navigator.pop(context);
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

  Future insertMeetingDetailsAPI(BuildContext context) async {
    try {
      Map data = {
        "action": "insert_meeting_details",
        "cus_id": controllers.selectedCustomerId.value,
        "com_name": controllers.selectedCompanyName.value,
        "cus_name": controllers.selectedCustomerName.value,
        "title": controllers.meetingTitleCrt.text.trim(),
        "cos_id": controllers.storage.read("cos_id"),
        "venue":controllers.meetingVenueCrt.text.trim(),
        //"date":"${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}",
        "dates":"${controllers.fDate.value}||${controllers.toDate.value}",
        "times":"${controllers.fTime.value}||${controllers.toTime.value}",
        "created_by": controllers.storage.read("id"),
        "notes": controllers.callCommentCont.text.trim(),
      };
      print("data ${data.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "OK") {
        apiService.insertMeetEmailAPI(context, controllers.selectedCustomerId.value,
            imageController.photo1.value);
        getAllMeetingActivity();
        Navigator.pop(context);
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

  Future<void> allQualifiedDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allDisqualifiedLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "disqualified",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "action": "get_data"
        }),
      );
      controllers.isLead.value=true;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allDisqualifiedLength.value = data.length;
        controllers.isDisqualifiedList.clear();
        for (int i = 0; i < controllers.allDisqualifiedLength.value; i++) {
          controllers.isDisqualifiedList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
            "mail_id": data[i]["email_id"].toString(),
          });
        }
        // Update the observable list with the fetched data
        controllers.disqualifiedFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
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
      controllers.disqualifiedFuture.value = [];
      controllers.isDisqualifiedList.value = [];
      print('Unexpected error: ${e.toString()}');
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future bulkEmailAPI(BuildContext context, List<Map<String, String>> list, String image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      request.fields['subject']        = controllers.emailSubjectCtr.text;
      request.fields['cos_id']         = controllers.storage.read("cos_id").toString();
      request.fields['count']          = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
      request.fields['body']           = controllers.emailMessageCtr.text;
      request.fields['user_id']        = controllers.storage.read("id").toString();
      request.fields['date']           =
      "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action']         = 'bulk_mail_receive';
      List<String> ids    = list.map((e) => e['lead_id'] ?? '').toList();
      List<String> emails = list.map((e) => e['mail'] ?? '').toList();

      request.fields['clientMail'] = emails.join(",");
      request.fields['id']         = ids.join(",");

      if (imageController.empFileName.value.isNotEmpty) {
        var picture1 = http.MultipartFile.fromBytes(
          "attachment",
          imageController.empMediaData,
          filename: imageController.empFileName.value,
        );
        request.files.add(picture1);
      }

      var response = await request.send();
      var body = await response.stream.bytesToString();
      print("Response: $body");
      print("Response: ${request.fields}");

      if (response.statusCode == 200 && body.trim()== "Mail process completed.") {
        utils.snackBar(msg: "Mail has been sent", color: Colors.green, context: Get.context!);
        controllers.emailMessageCtr.clear();
        controllers.emailToCtr.clear();
        controllers.emailSubjectCtr.clear();
        prospectsList.clear();
        // apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        // controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(Get.context!);
        Get.off(const Suspects(), duration: Duration.zero);
        controllers.emailCtr.reset();
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has not been sent");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
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
      if (request.statusCode == 200 && response["message"] == "OK") {
        print("success");
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        apiService.allGoodLeadsDetails();
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

  // Future insertCustomersAPI(BuildContext context, List<Map<String, dynamic>> customerData, List<Map<String, dynamic>> fieldMappings) async {
  //   try {
  //     // List<Map<String, dynamic>> formattedData = customerData.map((customer) {
  //     //   return customer.map((key, value) {
  //     //     if (key == "additional_fields" && value is List) {
  //     //       return MapEntry(key, value);
  //     //     }
  //     //     return MapEntry(key, value.toString());
  //     //   });
  //     // }).toList();
  //     Map data = {
  //       "action": "sheet_customers",
  //       "field_mappings": fieldMappings,
  //       "cusList": customerData,
  //     };
  //     print("Final Data to be sent: ${jsonEncode(data)}");
  //
  //     final request = await http.post(
  //       Uri.parse(scriptApi),
  //       headers: {
  //         "Accept": "application/json",
  //         "Content-Type": "application/json"
  //       },
  //       body: jsonEncode(data),
  //     );
  //
  //     print("request ${request.body}");
  //     Map<String, dynamic> response = json.decode(request.body);
  //
  //     if (request.statusCode == 200 && response["message"] == "Customer save process completed.") {
  //       apiService.allLeadsDetails();
  //       apiService.allNewLeadsDetails();
  //       apiService.allGoodLeadsDetails();
  //       getUserHeading();
  //       prospectsList.clear();
  //       qualifiedList.clear();
  //       customerList.clear();
  //       int success = response["success"];
  //       int failed = response["failed"];
  //       Navigator.pop(context);
  //       controllers.customerCtr.reset();
  //
  //       if (failed == 0) {
  //         print("All customers saved successfully.");
  //         utils.snackBar(context:Get.context!,
  //             msg: "All $success customers saved successfully.",color: Colors.green);
  //       } else {
  //         print("⚠️ $success saved, $failed failed.");
  //         // 👉 Build a readable string
  //         StringBuffer failMsg = StringBuffer();
  //         for (var failure in response["failures"]) {
  //           failMsg.writeln("• ${failure["name"]} (${failure["phone_no"]}) → ${failure["error"]}");
  //         }
  //
  //         cusErrorDialog(
  //           Get.context!,
  //           "$success saved, $failed failed.\n\nFailed List:\n$failMsg",
  //         );
  //       }
  //     } else {
  //       print("insert customers error ${request.body}");
  //       Navigator.pop(context);
  //       errorDialog(Get.context!, "Failed to insert customer details.");
  //       controllers.customerCtr.reset();
  //     }
  //   } catch (e) {
  //     print("Result $e");
  //     Navigator.pop(context);
  //     errorDialog(Get.context!, "Failed to insert customer details.");
  //     controllers.customerCtr.reset();
  //   }
  // }

  Future insertCustomersAPI(
      BuildContext context,
      List<Map<String, dynamic>> customerData,
      List<Map<String, dynamic>> fieldMappings,
      Uint8List excelBytes,
      String excelFileName,
      ) async {
    try {
      Map<String, dynamic> data = {
        "action": "sheet_customers",
        "field_mappings": fieldMappings,
        "cusList": customerData,
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(scriptApi),
      );
      // data.forEach((key, value) {
      //   request.fields[key] = jsonEncode(value);
      // });
      request.fields["action"] = "sheet_customers";
      request.fields["field_mappings"] = jsonEncode(fieldMappings);
      request.fields["cusList"] = jsonEncode(customerData);

      request.files.add(http.MultipartFile.fromBytes(
        'sheet',
        excelBytes,
        filename: excelFileName,
      ));

      print("Server fields: ${request.fields}");
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      Map<String, dynamic> res = json.decode(responseData.body);
      print("Server response: $res");

      if (response.statusCode == 200 &&
          res["message"] == "Customer save process completed.") {
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        apiService.allGoodLeadsDetails();
        getUserHeading();
        prospectsList.clear();
        qualifiedList.clear();
        customerList.clear();

        int success = res["success"];
        int failed = res["failed"];
        Navigator.pop(context);
        controllers.customerCtr.reset();

        if (failed == 0) {
          utils.snackBar(
            context: Get.context!,
            msg: "All $success customers saved successfully.",
            color: Colors.green,
          );
        } else {
          StringBuffer failMsg = StringBuffer();
          for (var failure in res["failures"]) {
            failMsg.writeln(
                "• ${failure["name"]} (${failure["phone_no"]}) → ${failure["error"]}");
          }
          cusErrorDialog(
            Get.context!,
            "$success saved, $failed failed.\n\nFailed List:\n$failMsg",
          );
        }
      } else {
        Navigator.pop(context);
        errorDialog(Get.context!, "Failed to insert customer details.");
        controllers.customerCtr.reset();
      }
    } catch (e) {
      Navigator.pop(context);
      print("Customer insert Error: $e");
      errorDialog(Get.context!, "Failed to insert customer details: $e");
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
        "cos_id": controllers.storage.read("cos_id"),
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
        "cos_id": controllers.storage.read("cos_id"),
        "lead_status": leadId,
        "status": controllers.status,
        "quotation_required": "1",
        "visit_type": callListId,
        "data": jsonString,
        'prospect_enrollment_date': controllers.prospectDate.value.isEmpty?"${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}":controllers.prospectDate.value,
        'expected_convertion_date': controllers.exDate.value.isEmpty?"${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}":controllers.exDate.value,
        'status_update': controllers.statusCrt.text.trim(),
        'num_of_headcount': controllers.noOfHeadCountCrt.text.trim(),
        'expected_billing_value': controllers.expectedConversionDateCrt.text.trim(),
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
          request.body.toString().contains("Customer saved successfully.")) {
        final prefs = await SharedPreferences.getInstance();
        controllers.leadActions.clear();
        controllers.leadDisPointsCrt.clear();
        controllers.prodDescriptionController.clear();
        controllers.exMonthBillingValCrt.clear();
        controllers.arpuCrt.clear();
        controllers.prospectGradingCrt.clear();
        controllers.noOfHeadCountCrt.clear();
        controllers.expectedConversionDateCrt.clear();
        controllers.sourceCrt.clear();
        controllers.prospectEnrollmentDateCrt.clear();
        controllers.statusCrt.clear();
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
        apiService.allGoodLeadsDetails();
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
  Future insertQualifiedAPI(BuildContext context,List<Map<String, String>> list) async {
    try {
      print("data ${qualifiedList.toString()}");
      final request = await http.post(Uri.parse(qualifiedScript),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(list),
          encoding: Encoding.getByName("utf-8"));
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "OK") {
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

  Future insertPromoteCustomerAPI(BuildContext context,List<Map<String, String>> list) async {
    try {
      Map data = {"action": "promote_customers", "cusList": list};
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
      if (request.statusCode == 200 && response["message"] == "OK") {
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
        "cos_id": controllers.storage.read("cos_id"),
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
        Uri.parse(scriptApi),
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
          request.body == "{\"status_code\":200,\"message\":\"OK\"}") {
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
        "action": "login"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Login Res ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200) {
        controllers.storage.write("f_name", response["s_name"]);
        controllers.storage.write("role", "2");
        controllers.storage.write("role_name", "Admin");
        controllers.storage.write("id", response["id"]);
        controllers.storage.write("cos_id", response["cos_id"]);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("loginScreen${controllers.versionNum}", true);
        String input = "Admin";
        controllers.isAdmin.value = input == "Admin" ? true : false;
        prefs.setBool("isAdmin", controllers.isAdmin.value);
        prefs.remove("loginNumber");
        prefs.remove("loginPassword");
        getAllCallActivity();
        getAllMailActivity();
        getAllMeetingActivity();
        getAllNoteActivity();
        loginHistoryApi();
        allLeadsDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allCustomerDetails();
        allQualifiedDetails();
        getUserHeading();
        getRoles();
        getSheet();
        getAllCustomers();
        getOpenedMailActivity(true);
        getReplyMailActivity(true);
        utils.snackBar(
          context: Get.context!,
          msg: "Login Successfully",
          color: Colors.green,
        );
        Get.to(const NewDashboard(), duration: Duration.zero);
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
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "app_version": controllers.versionNum,
        "device_id": webBrowserInfo.productSub,
        "device_brand": allInfo.toString(),
        "device_model": webBrowserInfo.product,
        "device_os": webBrowserInfo.deviceMemory,
        "platform": "3",
        "action": "login_history"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 200) {
        print("Login history added success");
      } else {
        print('Login failed');
        controllers.loginCtr.reset();
      }
    } catch (e) {
      print('Login failed: ${e.toString()}');
      controllers.loginCtr.reset();
    }
  }

  Future getLeadCategory() async {
    try {
      Map data = {
        "search_type": "category",
        "cat_id": controllers.storage.read("cos_id") == '202410' ? "1" : "4",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Category res ${request.body}");
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
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Visit Type res ${request.body}");
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

  Future getAllCustomers() async {
    try {
      Map data = {
        "search_type": "allCustomers",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Customer Res ${request.body}");
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.customers.clear();
        controllers.customers.value = response.map((e) => AllCustomersObj.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future getAllCallActivity() async {
    try {
      Map data = {
        "search_type": "records",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "type":"7"
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
        controllers.callActivity.clear();
        controllers.callActivity.value = response.map((e) => CustomerActivity.fromJson(e)).toList();
        final incoming = controllers.callActivity.where((e) => e.callType.isNotEmpty && e.callType.trim() == "Incoming").toList();
        final outgoing = controllers.callActivity
            .where((e) => e.callType.isNotEmpty && e.callType.trim() == "Outgoing")
            .toList();
        final missed = controllers.callActivity
            .where((e) => e.callType.isNotEmpty && e.callType.trim() == "Missed")
            .toList();

        controllers.allIncomingCalls.value = incoming.length.toString();
        controllers.allOutgoingCalls.value = outgoing.length.toString();
        controllers.allMissedCalls.value = missed.length.toString();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future<void> getAllMailActivity() async {
    controllers.isSent.value = true;
    controllers.isMailLoading.value = true;
    controllers.isOpened.value = false;
    controllers.isReplied.value = false;
    try {
      final data = {
        "search_type": "records",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "type": "8",
      };
      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );
      controllers.isMailLoading.value = false;

      if (request.statusCode == 200) {
        final List response = json.decode(request.body);
        controllers.mailActivity.clear();
        final activities = response.map((e) => CustomerActivity.fromJson(e)).toList();
        controllers.mailActivity.assignAll(activities);
        controllers.allSentMails.value = controllers.mailActivity.length.toString();
      } else {
        throw Exception('Failed to load mail activity');
      }
    } catch (e) {
      controllers.mailActivity.clear();
      controllers.isMailLoading.value = false;
      print("Error in getAllMailActivity: $e");
      rethrow;
    }
  }


  Future getReplyMailActivity(bool isMain) async {
    controllers.mailActivity.clear();
    controllers.isReplied.value = true;
    controllers.isMailLoading.value = true;
    controllers.isOpened.value = false;
    controllers.isSent.value = false;
    try {
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "action": "fetch_mails",
        "type":"reply"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      controllers.isMailLoading.value = false;
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        if(isMain==false){
          controllers.mailActivity.value = response.map((e) => CustomerActivity.fromJson(e)).toList();
        }
        controllers.allReplyMails.value = response.length.toString();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.isMailLoading.value = false;
      throw Exception('Failed to load album');
    }
  }

  Future getOpenedMailActivity(bool isMain) async {
    controllers.mailActivity.clear();
    controllers.isOpened.value = true;
    controllers.isMailLoading.value = true;
    controllers.isSent.value = false;
    controllers.isReplied.value = false;
    try {
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "action": "fetch_mails",
        "type":"reply_seen"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      controllers.isMailLoading.value = false;
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        if(isMain==false){
          controllers.mailActivity.value = response.map((e) => CustomerActivity.fromJson(e)).toList();
        }
        controllers.allOpenedMails.value = response.length.toString();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.isMailLoading.value = false;
      throw Exception('Failed to load album');
    }
  }

  Future getAllMeetingActivity() async {
    try {
      Map data = {
        "search_type": "meeting_details",
        "cos_id": controllers.storage.read("cos_id"),
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
        controllers.meetingActivity.clear();
        controllers.meetingActivity.value = response.map((e) => MeetingObj.fromJson(e)).toList();
        final scheduled = controllers.meetingActivity.where((e) => e.status.isNotEmpty && e.status.trim() == "Scheduled").toList();
        final completed = controllers.meetingActivity
            .where((e) => e.status.isNotEmpty && e.status.trim() == "Completed")
            .toList();
        final cancelled = controllers.meetingActivity
            .where((e) => e.status.isNotEmpty && e.status.trim() == "Cancelled")
            .toList();

        controllers.allScheduleMeet.value = scheduled.length.toString();
        controllers.allCompletedMeet.value = completed.length.toString();
        controllers.allCancelled.value = cancelled.length.toString();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.allScheduleMeet.value = "0";
      controllers.allCompletedMeet.value = "0";
      controllers.allCancelled.value = "0";
      throw Exception('Failed to load album');
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }
  Future updateLeadStatusUpdateAPI(BuildContext context,String leadId,String mobile,String status) async {
    showLoadingDialog(context);
    try{
      Map data ={
        "cos_id":controllers.storage.read("cos_id"),
        'status_update' : status.trim(),
        "lead_id":leadId,
        "phone_no":mobile,
        "action":"status_update"
      };

      print("data lead ${data.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
        // headers: {
        //   "Accept": "application/text",
        //   "Content-Type": "application/x-www-form-urlencoded"
        // },
        body: jsonEncode(data),
        // encoding: Encoding.getByName("utf-8")
      );
      print("request ${request.body}");
      //Navigator.of(context).pop();
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"]=="Customer updated successfully."){
        utils.snackBar(msg: "Your Lead is updated successfully !",
            color: colorsConst.primary,context:Get.context!);
        controllers.leadFuture = apiService.leadsDetails(leadId);
        Get.back();
        //Get.to(const CompanyCamera(),transition: Transition.downToUp,duration: const Duration(seconds: 2));
        apiService.allNewLeadsDetails();
        apiService.allLeadsDetails();
        apiService.allGoodLeadsDetails();
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
        Navigator.of(context).pop();
        errorDialog(Get.context!,request.body);
        controllers.leadCtr.reset();
      }
    }catch(e){
      Navigator.of(context).pop();
      errorDialog(Get.context!,"Something went wrong, Please try again later");
      controllers.leadCtr.reset();
    }
  }
  Future getAllNoteActivity() async {
    try {
      Map data = {
        "search_type": "records",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "type":"10"
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
        controllers.noteActivity.clear();
        controllers.noteActivity.value = response.map((e) => CustomerActivity.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future getUserHeading() async {
    print("Inn Fields");
    try {
      Map data = {
        "search_type": "user_field_head",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"};
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.fields.clear();
        controllers.fields.value = response.map((e) => CustomerField.fromJson(e)).toList();
        tableController.setHeadingFields(response);
      } else {
        controllers.fields.value = controllers.defaultFields.map((e) => CustomerField.fromJson(e)).toList();
        tableController.setHeadingFields(controllers.defaultFields);
        throw Exception('Failed to load album');
      }
    } catch (e) {
        controllers.fields.value = controllers.defaultFields.map((e) => CustomerField.fromJson(e)).toList();
      tableController.setHeadingFields(controllers.defaultFields);
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
        "cos_id": controllers.storage.read("cos_id"),
        "platform": "3"
      };
      final request = await http.post(Uri.parse(scriptApi),
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

  Future insertEmailAPI(BuildContext context, String id, String image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      // Body values
      request.fields['clientMail'] = controllers.emailToCtr.text;
      request.fields['subject'] = controllers.emailSubjectCtr.text;
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
      request.fields['body'] = controllers.emailMessageCtr.text;
      request.fields['user_id'] = controllers.storage.read("id").toString();
      request.fields['id'] = id;
      request.fields['date'] = "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
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
        getAllMailActivity();
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

  Future insertMeetEmailAPI(BuildContext context, String id, String image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      // Body values
      request.fields['clientMail'] = controllers.selectedCustomerEmail.value;
      request.fields['subject'] = "Meeting Reminder: ${controllers.meetingTitleCrt.text}";
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
      request.fields['body'] =  "Meeting Notes: ${controllers.callCommentCont.text}";
      request.fields['user_id'] = controllers.storage.read("id").toString();
      request.fields['id'] = id;
      request.fields['date'] = "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
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
        // utils.snackBar(
        //     msg: "Mail has been sent",
        //     color: Colors.green,
        //     context: Get.context!);

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
  //       "cos_id":controllers.storage.read("cos_id"),
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
              colors: colorsConst.textColor,
            ),
          );
        });
  }
  void cusErrorDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
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
              ),
            ),
          ),
          title: const Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              text,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorsConst.textColor,
              ),

            ),
          ),
        );
      },
    );
  }



  Future<List<ProductObj>> allProductDetails() async {
    final url = Uri.parse(scriptApi);
    controllers.allProductLength.value = 0;
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
            {"search_type": "product", "cos_id": controllers.storage.read("cos_id"), "action": "get_data"}),
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
          "cos_id": controllers.storage.read("cos_id"),
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
          "cos_id": controllers.storage.read("cos_id"),
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
          "cos_id": controllers.storage.read("cos_id"),
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
          "cos_id": controllers.storage.read("cos_id"),
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
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": controllers.storage.read("cos_id"),
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
        controllers.allLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
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
          "cos_id": controllers.storage.read("cos_id"),
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
          "cos_id": controllers.storage.read("cos_id"),
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
        controllers.allNewLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
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
  //         "cos_id":controllers.storage.read("cos_id"),
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
          "cos_id": controllers.storage.read("cos_id"),
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
        controllers.allQualifiedLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
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
        "cos_id": controllers.storage.read("cos_id"),
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

  Future getSheet() async {
    try {
      Map data = {
        "search_type": "sample_sheet",
        "cos_id": controllers.storage.read("cos_id"),
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
          controllers.serverSheet.value = (data[0]["sheet"]);
      } else {
        controllers.serverSheet.value = "";
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.serverSheet.value = "";
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
            {"search_type": "company",
              "cos_id": controllers.storage.read("cos_id"),
              "action": "get_data"}),
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
  DateTime? parseExpiredDate(String s) {
    try {
      final input = s.trim();
      final df = DateFormat("dd-MM-yyyy h.mm a");
      return df.parseStrict(input);
    } catch (e) {
      try {
        final df2 = DateFormat("dd-MM-yyyy h:mm a");
        return df2.parseStrict(s);
      } catch (_) {
        return null;
      }
    }
  }

  Future currentVersion() async {
    try {
      Map data = {
        "search_type": "checkVersion",
        "cos_id": controllers.storage.read("cos_id"),
        "action":"get_data"
      };
      log("data version $data");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      controllers.versionActive.value = false;
      controllers.updateAvailable.value = false;
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.serverVersion.value = response[0]["current_version"];
        controllers.currentUserCount.value = response[0]["user_count"];
        final expiredDate = parseExpiredDate(response[0]["expired_date"]);
        final now = DateTime.now();
        if (expiredDate != null && now.isAfter(expiredDate)) {
          utils.expiredDateDialog(response[0]["expired_date"]);
          controllers.versionActive.value = true;
          controllers.updateAvailable.value = false;
          return;
        }
        if (controllers.versionNum != controllers.serverVersion.value) {
          controllers.versionActive.value = true;
          if (response[0]["active"] == "1") {
            utils.updateDialog();
            controllers.updateAvailable.value = true;
          }
        }
      } else {
        controllers.versionActive.value = false;
      }
    } catch (e) {
      controllers.versionActive.value = false;
    }
  }

  Future getDashBoardReport() async {
    try {
      Map data = {
        "search_type": "main_report",
        "id": controllers.storage.read("id"),
        "role": controllers.storage.read("role"),
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "date": "${DateTime.now().day.toString().padLeft(2, "0")}-${DateTime.now().month.toString().padLeft(2, "0")}-${DateTime.now().year.toString()}"
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

  Future getRatingReport() async {
    try {
      Map data = {
        "search_type": "rating_report",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
      };
      log("main ${data.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("view dashboard report");
      print(request.body);
      controllers.totalCold.value = "0";
      controllers.totalHot.value = "0";
      controllers.totalWarm.value = "0";

      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.totalCold.value = response[0]["cold_total"].toString()=="null"?"0":response[0]["cold_total"];
        controllers.totalHot.value = response[0]["hot_total"].toString()=="null"?"0":response[0]["hot_total"];
        controllers.totalWarm.value = response[0]["warm_total"].toString()=="null"?"0":response[0]["warm_total"];
      } else {
        controllers.totalCold.value = "0";
        controllers.totalHot.value = "0";
        controllers.totalWarm.value = "0";
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.totalCold.value = "0";
      controllers.totalHot.value = "0";
      controllers.totalWarm.value = "0";
      throw Exception('Failed to load album');
    }
  }

  Future getMonthReport() async {
    try {
      Map data = {
        "search_type": "month_report",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "year":"2025"
      };
      log("main ${data.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      if (request.statusCode == 200) {
        List response = json.decode(request.body);
       controllers.setData(response);
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future getDayReport(String year,String month) async {
    try {
      Map data = {
        "search_type": "day_report",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "year":year,
        "month":month
      };
      log("main day wise ${data.toString()}");
      controllers.dayReport.value = [];
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.dayReport.value = response.map<CustomerDayData>(
              (e) => CustomerDayData.fromJson(e),
        ).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      print("day_report $e");
      throw Exception('Failed to load album');
    }
  }

  Future getCustomerReport(String stDate,String endDate) async {
    try {
      Map data = {
        "search_type": "customers_count",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "stDate":stDate,
        "enDate":endDate
      };
      log("main day wise ${data.toString()}");
      controllers.dayReport.value = [];
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.dayReport.value = response.map<CustomerDayData>((e) => CustomerDayData.fromJson(e),).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      print("day_report $e");
      throw Exception('Failed to load album');
    }
  }

  Future getDashboardReport() async {
    final range = dashController.selectedRange.value;
    var today = DateTime.now();
    var tomorrow = DateTime.now().add(Duration(days: 1));
    final adjustedEnd = range?.end.add(const Duration(days: 1));
    try {
      Map data = {
        "search_type": "dashboard_report",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "stDate": range==null?"${today.year}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}":"${range.start.year}-${range.start.month.toString().padLeft(2, "0")}-${range.start.day.toString().padLeft(2, "0")}",
        "enDate": range==null?"${tomorrow.year}-${tomorrow.month.toString().padLeft(2, "0")}-${tomorrow.day.toString().padLeft(2, "0")}":"${adjustedEnd!.year}-${adjustedEnd.month.toString().padLeft(2, "0")}-${adjustedEnd.day.toString().padLeft(2, "0")}"
      };

      log("Dashboard request data: ${data.toString()}");
      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      if (request.statusCode == 200) {
        var response = jsonDecode(request.body) as List;
        dashController.totalMails.value       = response[0]["total_mails"] ?? "0";
        dashController.totalMeetings.value    = response[0]["total_meetings"] ?? "0";
        dashController.totalCalls.value       = response[0]["total_calls"] ?? "0";
        dashController.totalEmployees.value   = response[0]["total_employees"] ?? "0";
        dashController.totalHot.value         = response[0]["hot_total"]?.toString() ?? "0";
        dashController.totalWarm.value        = response[0]["warm_total"]?.toString() ?? "0";
        dashController.totalCold.value        = response[0]["cold_total"]?.toString() ?? "0";
        dashController.totalSuspects.value    = response[0]["total_suspects"]?.toString() ?? "0";
        dashController.totalProspects.value   = response[0]["total_prospects"]?.toString() ?? "0";
        dashController.totalQualified.value   = response[0]["total_qualified"]?.toString() ?? "0";
        dashController.totalUnQualified.value = response[0]["total_disqualified"]?.toString() ?? "0";
        dashController.totalCustomers.value   = response[0]["total_customers"]?.toString() ?? "0";
      } else {
        throw Exception('Failed to load dashboard report');
      }
    } catch (e) {
      print("dashboard_report error: $e");
      throw Exception('Failed to load dashboard report');
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
          "cos_id": controllers.storage.read("cos_id"),
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
        controllers.allCustomerLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
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
            {"search_type": "employee", "cos_id": controllers.storage.read("cos_id"), "action": "get_data"}),
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
