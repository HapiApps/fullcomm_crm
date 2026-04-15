import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/controller/table_controller.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import 'package:fullcomm_crm/models/company_obj.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';
import 'package:fullcomm_crm/models/user_heading_obj.dart';
import 'package:fullcomm_crm/screens/leads/new_lead_page.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/view_models/billing_provider.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/models/product_obj.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/jwt_storage.dart';
import '../common/utilities/reminder_utils.dart';
import '../common/utilities/utils.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';
import '../controller/image_controller.dart';
import '../controller/product_controller.dart';
import '../controller/reminder_controller.dart';
import '../controller/settings_controller.dart';
import '../models/customer_activity.dart';
import '../models/customer_full_obj.dart';
import '../models/employee_obj.dart';
import '../models/mail_receive_obj.dart';
import '../models/meeting_obj.dart';
import '../models/month_report_obj.dart';
import '../screens/DashboardPage.dart';
import '../screens/order/order_page.dart';

final ApiService apiService = ApiService._();

class ApiService {
  ApiService._();

  // Future insertLeadAPI(BuildContext context) async {
  //   var index = controllers.isMainPersonList.indexWhere((element) => element == true);
  //   controllers.leadNames.value = "";
  //   controllers.leadMobiles.value = "";
  //   controllers.leadEmails.value = "";
  //   controllers.leadTitles.value = "";
  //   controllers.leadWhatsApps.value = "";
  //   if (index != -1) {
  //     controllers.mainLeadName.value = controllers.leadNameCrt[index].text;
  //     controllers.mainLeadMobile.value = controllers.leadMobileCrt[index].text;
  //     controllers.mainLeadEmail.value = controllers.leadEmailCrt[index].text;
  //     controllers.mainLeadTitle.value = controllers.leadTitleCrt[index].text;
  //     controllers.mainLeadWhatsApp.value = controllers.leadWhatsCrt[index].text;
  //   } else {
  //     controllers.mainLeadName.value = controllers.leadNameCrt[0].text;
  //     controllers.mainLeadMobile.value = controllers.leadMobileCrt[0].text;
  //     controllers.mainLeadEmail.value = controllers.leadEmailCrt[0].text;
  //     controllers.mainLeadTitle.value = controllers.leadTitleCrt[0].text;
  //     controllers.mainLeadWhatsApp.value = controllers.leadWhatsCrt[0].text;
  //   }
  //   for (int i = 0; i < controllers.leadPersonalItems.value; i++) {
  //     if (i == 0) {
  //       controllers.leadNames.value += controllers.leadNameCrt[i].text;
  //       controllers.leadMobiles.value += controllers.leadMobileCrt[i].text;
  //       controllers.leadEmails.value += controllers.leadEmailCrt[i].text;
  //       controllers.leadTitles.value += controllers.leadTitleCrt[i].text;
  //       controllers.leadWhatsApps.value += controllers.leadWhatsCrt[i].text;
  //     } else if (i != 0 && controllers.leadNameCrt[i].text.isNotEmpty) {
  //       controllers.leadNames.value += "||${controllers.leadNameCrt[i].text}";
  //       controllers.leadMobiles.value +=
  //           "||${controllers.leadMobileCrt[i].text}";
  //       controllers.leadEmails.value += "||${controllers.leadEmailCrt[i].text}";
  //       controllers.leadTitles.value += "||${controllers.leadTitleCrt[i].text}";
  //       controllers.leadWhatsApps.value +=
  //           "||${controllers.leadWhatsCrt[i].text}";
  //     }
  //   }
  //   List<Map<String, String>> leadFields = [];
  //
  //   for (int i = 0; i < controllers.leadFieldItems.value; i++) {
  //     leadFields.add(
  //       {
  //         "field_name": controllers.leadFieldName[i].text.trim(),
  //         "field_value": controllers.leadFieldValue[i].text.trim()
  //       },
  //     );
  //   }
  //   String jsonString = json.encode(leadFields);
  //
  //   try {
  //     //1-Suspects,2-Prospects,3-Qualified,4-Customers.
  //     var leadId; //controllers.visitType
  //     for (var role in controllers.leadCategoryList) {
  //       if (role['value'] == controllers.leadCategory) {
  //         leadId = role['id'];
  //         break;
  //       }
  //     }
  //     var callListId;
  //     for (var role in controllers.callList) {
  //       if (role['value'] == controllers.visitType) {
  //         callListId = role['id'];
  //         break;
  //       }
  //     }
  //     Map billing_data = {
  //       "billing_data": jsonString,
  //       "lead_status": leadId,
  //       "cos_id": controllers.storage.read("cos_id"),
  //       "main_name": controllers.mainLeadName.value,
  //       "main_title": controllers.mainLeadTitle.value,
  //       "main_mobile": controllers.mainLeadMobile.value,
  //       "main_whatsapp": controllers.mainLeadMobile.value,
  //       "main_email": controllers.mainLeadEmail.value,
  //       "name": controllers.leadNames.value,
  //       "title": controllers.leadTitles.value,
  //       "mobile_number": controllers.leadMobiles.value,
  //       "whatsapp_number": controllers.leadMobiles.value,
  //       "email": controllers.leadEmails.value,
  //       "co_name": controllers.leadCoNameCrt.text.trim(),
  //       "co_website": controllers.leadWebsite.text.trim(),
  //       "co_number": controllers.leadCoMobileCrt.text.trim(),
  //       "co_email": controllers.leadCoEmailCrt.text.trim(),
  //       "linkedin": controllers.leadLinkedinCrt.text.trim(),
  //       "gst_number": controllers.leadGstNumCrt.text.trim(),
  //       "gst_DOR": controllers.leadDOR.value,
  //       "gst_location": controllers.leadGstLocationCrt.text.trim(),
  //       "x": controllers.leadXCrt.text.trim(),
  //       "date_of_connection": controllers.empDOB.value,
  //       "source_details": controllers.leadSourceCrt.text.trim(),
  //       "owner": controllers.leadOwnerNameCrt.text.trim(),
  //       "budget": controllers.budgetCrt.text.isEmpty
  //           ? "0"
  //           : controllers.budgetCrt.text.trim(),
  //       "timeline_decision": controllers.leadTime.text.trim(),
  //       "industry": controllers.industry,
  //       "user_id": controllers.storage.read("id"),
  //       "service_interest": controllers.service,
  //       "product_service": controllers.leadProduct.text.trim(),
  //       "description": controllers.leadDescription.text.trim(),
  //       "status": controllers.status,
  //       "rating": controllers.selectedRating,
  //       "source": controllers.source,
  //       "door_no": controllers.doorNumberController.text.trim(),
  //       "street_name": controllers.streetNameController.text.trim(),
  //       "area": controllers.areaController.text.trim(),
  //       "city": controllers.selectedCity.value,
  //       "state": controllers.selectedState.value,
  //       "pin_code": controllers.pinCodeController.text,
  //       "country": controllers.selectedCountry.value,
  //       "actions": controllers.leadActions.text,
  //       "discussion_point": controllers.leadDisPointsCrt.text,
  //       "points": controllers.leadPointsCrt.text,
  //       "platform": 3,
  //       "visit_type": callListId,
  //       "action": "insert_lead"
  //     };
  //
  //     final request = await http.post(
  //       Uri.parse(scriptApi),
  //       headers: {
  //         'X-API-TOKEN': "${TokenStorage().readToken()}",
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(billing_data),
  //     );
  //     Map<String, dynamic> response = json.decode(request.body);
  //     if (request.statusCode == 401) {
  //       final refreshed = await controllers.refreshToken();
  //       if (refreshed) {
  //         return insertLeadAPI(context);
  //       } else {
  //         controllers.setLogOut();
  //       }
  //     }
  //     if (request.statusCode == 200 && response["message"] == "OK") {
  //       billing_utils.snackBar(
  //           msg: "Your Lead is created successfully !",
  //           color: colorsConst.primary,
  //           context: Get.context!);
  //       final prefs = await SharedPreferences.getInstance();
  //
  //       prefs.remove("leadName");
  //       prefs.remove("leadCount");
  //       prefs.remove("leadMobileNumber");
  //       prefs.remove("leadEmail");
  //       prefs.remove("leadTitle");
  //       prefs.remove("leadWhatsApp");
  //       prefs.remove("leadCoName");
  //       prefs.remove("leadCoMobile");
  //       prefs.remove("leadWebsite");
  //       prefs.remove("leadCoEmail");
  //       prefs.remove("leadProduct");
  //       prefs.remove("leadOwnerName");
  //       prefs.remove("industry");
  //       prefs.remove("source");
  //       prefs.remove("status");
  //       prefs.remove("rating");
  //       prefs.remove("service");
  //       prefs.remove("leadDNo");
  //       prefs.remove("leadStreet");
  //       prefs.remove("leadArea");
  //       prefs.remove("leadCity");
  //       prefs.remove("leadPinCode");
  //       prefs.remove("budget");
  //       prefs.remove("leadState");
  //       prefs.remove("leadCountry");
  //       prefs.remove("leadX");
  //       prefs.remove("leadLinkedin");
  //       prefs.remove("leadTime");
  //       prefs.remove("leadDescription");
  //       for (int i = 0; i < controllers.leadPersonalItems.value; i++) {
  //         controllers.leadNameCrt[i].text = "";
  //         controllers.leadMobileCrt[i].text = "";
  //         controllers.leadEmailCrt[i].text = "";
  //         controllers.leadTitleCrt[i].text = "";
  //         controllers.leadWhatsCrt[i].text = "";
  //       }
  //       apiService.allLeadsDetails();
  //       apiService.allNewLeadsDetails();
  //       controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
  //       controllers.allCustomerFuture = apiService.allCustomerDetails();
  //       await Future.delayed(const Duration(milliseconds: 100));
  //       Get.to(const Suspects(), duration: Duration.zero);
  //       controllers.leadCtr.reset();
  //     } else {
  //       errorDialog(Get.context!, request.body);
  //       controllers.leadCtr.reset();
  //     }
  //   } catch (e) {
  //     errorDialog(Get.context!, e.toString());
  //     controllers.leadCtr.reset();
  //   }
  // }

  Future updateLeadAPI(BuildContext context, int index, String name,String leadId,  String type, String addressId, RxList<NewLeadObj> list, RxList<NewLeadObj> list2) async {
    try {
      String callListId = "";
      for (var role in controllers.callList) {
        if (role['value'] == controllers.visitType) {
          callListId = role['id'].toString();
          break;
        }
      }
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "city": controllers.cityController.text,
        "source": controllers.leadDisPointsCrt.text.trim(),
        "source_details": controllers.sourceCrt.text,
        "product_discussion": controllers.prodDescriptionController.text,
        "company_name": controllers.leadCoNameCrt.text.trim(),
        "co_website": controllers.leadWebsite.text.trim(),
        "co_number": controllers.infoNumberList
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty)
            .join("||"),
        "co_email": controllers.leadCoEmailCrt.text.trim(),
        "linkedin": controllers.leadLinkedinCrt.text.trim(),
        "x": controllers.leadXCrt.text.trim(),
        "door_no": controllers.doorNumberController.text.trim(),
        "area": controllers.areaController.text.trim(),
        "country": controllers.selectedCountry.value,
        "state": controllers.stateController.text.trim(),
        "pincode": controllers.pinCodeController.text.trim(),
        "industry": controllers.industry,
        "product": controllers.leadProduct.text.trim(),
        "points": controllers.leadActions.text.trim(),
        'status_update': controllers.statusCrt.text.trim(),
        'owner': controllers.leadTitleCrt[0].text.trim(),
        "status": controllers.status,
        'details_of_service_required': controllers.sourceCrt.text.trim(),
        'rating': controllers.prospectGradingCrt.text.trim(),
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
        "phone_no": controllers.numberList
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty)
            .join("||"),
        "whatsapp_number": controllers.leadWhatsCrt[0].text,
        "email": controllers.leadEmailCrt[0].text,
        "action": "update_customer"
      };

      final request = await http.post(
        Uri.parse(scriptApi),
        body: jsonEncode(data),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateLeadAPI(context,index,name,leadId,type,addressId,list,list2);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Customer updated successfully") {
        utils.snackBar(
            msg: "Your Lead is updated successfully !",
            color: Colors.green,
            context: Get.context!);
        list[index]=NewLeadObj(
          select: false,
          firstname: controllers.leadNameCrt[0].text.trim(),
          email: controllers.leadEmailCrt[0].text.trim(),
          mobileNumber: controllers.numberList
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .join("||"),

          userId: controllers.storage.read("id").toString(),
          companyName: controllers.leadCoNameCrt.text.trim(),
          productDiscussion: controllers.prodDescriptionController.text.trim(),
          source: controllers.leadDisPointsCrt.text.trim(),
          notes: controllers.leadActions.text.trim(),

          quotationStatus: "",
          quotationRequired: "1",

          doorNo: controllers.doorNumberController.text.trim(),
          area: controllers.areaController.text.trim(),
          city: controllers.cityController.text.trim(),
          country: controllers.selectedCountry.value,
          state: controllers.stateController.text.trim(),
          pincode: controllers.pinCodeController.text.trim(),

          companyWebsite: controllers.leadWebsite.text.trim(),
          companyNumber: controllers.infoNumberList
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .join("||"),
          companyEmail: controllers.leadCoEmailCrt.text.trim(),
          linkedin: controllers.leadLinkedinCrt.text.trim(),
          x: controllers.leadXCrt.text.trim(),

          industry: controllers.industry.toString(),
          product: controllers.leadProduct.text.trim(),
          sourceDetails: controllers.leadProduct.text.trim(),

          type: "1",
          lat: "0.0",
          lng: "0.0",

          leadStatus: leadId.toString(),
          status: controllers.status.toString(),
          visitType: callListId.toString(),

          prospectEnrollmentDate:
          controllers.prospectDate.value.isEmpty
              ? DateFormat("dd.MM.yyyy").format(DateTime.now())
              : controllers.prospectDate.value,

          expectedConvertionDate:
          controllers.exDate.value.isEmpty
              ? DateFormat("dd.MM.yyyy").format(DateTime.now())
              : controllers.exDate.value,

          statusUpdate: controllers.statusCrt.text.trim(),
          numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
          expectedBillingValue:
          controllers.exMonthBillingValCrt.text.trim(),
          arpuValue: controllers.arpuCrt.text.trim(),

          detailsOfServiceRequired:
          controllers.sourceCrt.text.trim(),
          rating: controllers.prospectGradingCrt.text.trim(),
          owner: controllers.leadTitleCrt[0].text.trim(),

          updatedTs: DateTime.now().toString(),
        );
        list2[index]=NewLeadObj(
          select: false,
          firstname: controllers.leadNameCrt[0].text.trim(),
          email: controllers.leadEmailCrt[0].text.trim(),
          mobileNumber: controllers.numberList
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .join("||"),

          userId: controllers.storage.read("id").toString(),
          companyName: controllers.leadCoNameCrt.text.trim(),
          productDiscussion: controllers.prodDescriptionController.text.trim(),
          source: controllers.leadDisPointsCrt.text.trim(),
          notes: controllers.leadActions.text.trim(),

          quotationStatus: "",
          quotationRequired: "1",

          doorNo: controllers.doorNumberController.text.trim(),
          area: controllers.areaController.text.trim(),
          city: controllers.cityController.text.trim(),
          country: controllers.selectedCountry.value,
          state: controllers.stateController.text.trim(),
          pincode: controllers.pinCodeController.text.trim(),

          companyWebsite: controllers.leadWebsite.text.trim(),
          companyNumber: controllers.infoNumberList
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .join("||"),
          companyEmail: controllers.leadCoEmailCrt.text.trim(),
          linkedin: controllers.leadLinkedinCrt.text.trim(),
          x: controllers.leadXCrt.text.trim(),

          industry: controllers.industry.toString(),
          product: controllers.leadProduct.text.trim(),
          sourceDetails: controllers.leadProduct.text.trim(),

          type: "1",
          lat: "0.0",
          lng: "0.0",

          leadStatus: leadId.toString(),
          status: controllers.status.toString(),
          visitType: callListId.toString(),

          prospectEnrollmentDate:
          controllers.prospectDate.value.isEmpty
              ? DateFormat("dd.MM.yyyy").format(DateTime.now())
              : controllers.prospectDate.value,

          expectedConvertionDate:
          controllers.exDate.value.isEmpty
              ? DateFormat("dd.MM.yyyy").format(DateTime.now())
              : controllers.exDate.value,

          statusUpdate: controllers.statusCrt.text.trim(),
          numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
          expectedBillingValue:
          controllers.exMonthBillingValCrt.text.trim(),
          arpuValue: controllers.arpuCrt.text.trim(),

          detailsOfServiceRequired:
          controllers.sourceCrt.text.trim(),
          rating: controllers.prospectGradingCrt.text.trim(),
          owner: controllers.leadTitleCrt[0].text.trim(),

          updatedTs: DateTime.now().toString(),
        );
        controllers.selectedQualifiedSortBy.value="All";
        controllers.selectRadio(list,list2);

        list.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA); // Desc order
        });
        list2.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA); // Desc order
        });
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) =>  NewLeadPage(index: controllers.leadCategoryList[0].leadStatus ,
        //       name: controllers.leadCategoryList[0].value,list: list,list2: list2, listIndex: 0,)),
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  NewLeadPage(index: index.toString() ,
              name: name,list: list,list2: list2, listIndex: 0,)),
        );
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
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

  Future<void> fetchPinCodeData(String pinCode) async {
    try {
      controllers.selectedCountry.value = "Loading...";

      final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pinCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];

          final district = postOffice['District'] ?? "";
          final state = postOffice['Circle'] ?? "";
          final country = postOffice['Country'] ?? "India";

          // ✅ SET VALUES
          controllers.selectedCountry.value = country;
          controllers.stateController.text = state;
          controllers.cityController.text = district;

          // ✅ FINAL PRINT (THIS is what you want)
          debugPrint("PINCODE: $pinCode");
          debugPrint("COUNTRY: ${controllers.selectedCountry.value}");
          debugPrint("STATE  : ${controllers.stateController.text}");
          debugPrint("CITY   : ${controllers.cityController.text}");
        } else {
          _resetPinValues();
        }
      } else {
        _resetPinValues();
      }
    } catch (e) {
      _resetPinValues();
      debugPrint("PINCODE ERROR: $e");
    }
  }
  void _resetPinValues() {
    controllers.selectedCountry.value = "India";
    controllers.stateController.clear();
    controllers.cityController.clear();
  }

  Future updateCategoryAPI(BuildContext context, String id, String category) async {
    try {
      Map data = {
        "action": "update_category",
        "category": category,
        "cos_id": controllers.storage.read("cos_id"),
        "id": id,
      };

      final request = await http.post(
        Uri.parse(scriptApi),
        // headers: {
        //   "Accept": "application/text",
        //   "Content-Type": "application/x-www-form-urlencoded"
        // },
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      // print(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateCategoryAPI(context,id,category);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["responseMsg"] == "Category updated successfully") {
        getLeadCategories();
      } else {
        apiService.errorDialog(context, request.body);
      }
    } catch (e) {
      apiService.errorDialog(context, e.toString());
    }
  }
  Future updateCategories(BuildContext context) async {
    try {
      for (int i = 0; i < controllers.allLeadCategoryList.length; i++) {
        controllers.allLeadCategoryList[i].displayOrder = i + 1;
        int index = controllers.leadCategoryList.indexWhere(
                (e) => e.id == controllers.allLeadCategoryList[i].id);

        if (index != -1) {
          controllers.leadCategoryList[index].displayOrder = i + 1;
        }
      }
      controllers.leadCategoryList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      Map data = {
        "action": "update_lead_details",
        "list": controllers.leadCategoryList
          .map((e) => e.toJson())
          .toList(),
        "cos_id": controllers.storage.read("cos_id"),
        "updated_by": controllers.storage.read("id"),
      };

      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      debugPrint(data.toString());
      debugPrint(request.body);
      // Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateCategories(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        utils.snackBar(context: context, msg: "Reorder successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(context, request.body);
      }
    } catch (e) {
      apiService.errorDialog(context, e.toString());
    }
  }

  Future updateTokenAPI(String token) async {
    try {
      Map data = {
        "action": "update_token",
        "token": token,
        "id": controllers.storage.read("id"),
      };

      final request = await http.post(
        Uri.parse(scriptApi),
        // headers: {
        //   "Accept": "application/text",
        //   "Content-Type": "application/x-www-form-urlencoded"
        // },
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"),
      );
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateTokenAPI(token);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        log("Token updated success");
      } else {
        log("Token error ${request.body}");
      }
    } catch (e) {
      log("Token Error $e");

    }
  }



  List<Map<String, String>> prospectsList = [];

  Future insertProspectsAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      final request = await http.post(Uri.parse(prospectsScript),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(list),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200 && response["message"] == "OK") {
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        allQualifiedDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        Navigator.pop(context);
        // Get.to(const Prospects(), duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }
  Future disqualifiedCustomersAPI(BuildContext context,List<Map<String, String>> list) async {
    try{
      Map data = {
        "action": "disqualified",
        "active": "2",
        "cusList": list
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("No Matches request.body");
      print(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return disqualifiedCustomersAPI(context,list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="OK"){
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        apiService.allQualifiedDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        prospectsList.clear();
        customerList.clear();
        Navigator.pop(context);
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
      Map data = {
        "action": "disqualified",
        "active": "1",
        "cusList": list
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return qualifiedCustomersAPI(context,list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="OK"){
        apiService.allLeadsDetails();
        apiService.allQualifiedDetails();
        apiService.allNewLeadsDetails();
        apiService.allGoodLeadsDetails();
        apiService.allCustomerDetails();
        prospectsList.clear();
        customerList.clear();
        Navigator.pop(context);
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

  Future insertLeadPromoteAPI(BuildContext context,List<Map<String, String>> list) async {
    try{
      Map data = {
        "action": "lead_promote",
        "cusList": list
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertLeadPromoteAPI(context,list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="OK"){
        apiService.allLeadsDetails();
        apiService.allQualifiedDetails();
        apiService.allNewLeadsDetails();
        apiService.allGoodLeadsDetails();
        apiService.allCustomerDetails();
        prospectsList.clear();
        customerList.clear();
        Navigator.pop(context);
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
  Future insertSuspectsAPI(BuildContext context,List<Map<String, String>> list) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body:
              jsonEncode({"action": "insert_suspects", "list": list}),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertSuspectsAPI(context,list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allQualifiedDetails();
        allNewLeadsDetails();
        allTargetLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        Navigator.pop(context);
        // Get.to(const Suspects(), duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future insertCallCommentAPI(BuildContext context,String type) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
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
                "date":"${controllers.empDOB.value} ${controllers.callTime.value}",
                "created_by": controllers.storage.read("id"),
                "comments": controllers.callCommentCont.text.trim(),
              }),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertCallCommentAPI(context,type);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        controllers.callTime.value = "";
        controllers.callType = "Outgoing";
        controllers.callStatus = "Contacted";
        remController.titleController.text = "Follow-up calling";
        remController.detailsController.text = controllers.callCommentCont.text;
        controllers.callCommentCont.text = "";
        controllers.selectCallType.value="All";
        remController.selectedCallSortBy.value="All";
        getAllCallActivity("");
        mergeStatusWithCount();
        Navigator.pop(context);
        controllers.productCtr.reset();
        if (remController.stDate.value.isEmpty) {
          try {
            String raw = controllers.empDOB.value;
            DateTime d;
            if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
              d = DateFormat("yyyy-MM-dd").parse(raw);
            }
            else if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(raw)) {
              d = DateFormat("dd.MM.yyyy").parse(raw);
            }
            else {
              d = DateTime.parse(raw);
            }
            d = d.add(Duration(days: 3));
            remController.stDate.value = DateFormat("dd.MM.yyyy").format(d);
          } catch (e) {
            log("DATE PARSE ERROR: $e   value='${remController.stDate.value}'");
          }
        }
        remController.stTime.value = "11:00 AM";
        reminderUtils.showAddReminderDialog(context);
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateCallCommentAPI(BuildContext context,String type,String id) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          // headers: {
          //   "Accept": "application/text",
          //   "Content-Type": "application/x-www-form-urlencoded"
          // },
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
                "action": "update_call_comments",
                "customer_id": controllers.selectedCustomerId.value,
                "mobile_number": controllers.selectedCustomerMobile.value,
                "customer_name": controllers.selectedCustomerName.value,
                "type": type,
                "cos_id": controllers.storage.read("cos_id"),
                "call_type":controllers.callType,
                "call_status":controllers.callStatus,
                "date":"${controllers.empDOB.value} ${controllers.callTime.value}",
                "updated_by": controllers.storage.read("id"),
                "comments": controllers.callCommentCont.text.trim(),
                "id":id
              }),
          encoding: Encoding.getByName("utf-8"));
      print("request.body");
      print(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateCallCommentAPI(context,type,id);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "Record updated successfully") {
        controllers.clearSelectedCustomer();
        controllers.empDOB.value = "";
        controllers.callTime.value = "";
        controllers.callType = "Outgoing";
        controllers.callStatus = "Contacted";
        controllers.callCommentCont.text = "";
        getAllCallActivity("");
        Navigator.pop(context);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future insertMeetingDetailsAPI(BuildContext context) async {
    try {
      Map data = {
        "action": "insert_meeting_details",
        "employee": controllers.selectedEmployeeId.value,
        "cus_id": controllers.selectedCustomerId.value,
        "com_name": controllers.selectedCompanyName.value,
        "cus_name": controllers.selectedCustomerName.value,
        "title": controllers.meetingTitleCrt.text.trim(),
        "cos_id": controllers.storage.read("cos_id"),
        "venue":controllers.meetingVenueCrt.text.trim(),
        "dates":"${controllers.fDate.value}||${controllers.toDate.value}",
        "times":"${controllers.fTime.value}||${controllers.toTime.value}",
        "created_by": controllers.storage.read("id"),
        "notes": controllers.callCommentCont.text.trim(),
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertMeetingDetailsAPI(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        getAllMeetingActivity("");
        controllers.clearSelectedCustomer();
        controllers.meetingTitleCrt.text = "";
        controllers.meetingVenueCrt.text = "";
        controllers.fDate.value = "";
        controllers.toDate.value = "";
        controllers.fTime.value = "";
        controllers.toTime.value = "";
        controllers.callCommentCont.text = "";
        Navigator.pop(context);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }
  Future updateMeetingDetailsAPI(BuildContext context,String id) async {
    try {
      Map data = {
        "action": "update_meeting_details",
        "cus_id": controllers.selectedCustomerId.value,
        "employee": controllers.selectedEmployeeId.value,
        "com_name": controllers.selectedCompanyName.value,
        "cus_name": controllers.selectedCustomerName.value,
        "title": controllers.meetingTitleCrt.text.trim(),
        "cos_id": controllers.storage.read("cos_id"),
        "venue":controllers.meetingVenueCrt.text.trim(),
        "dates":"${controllers.fDate.value}||${controllers.toDate.value}",
        "times":"${controllers.fTime.value}||${controllers.toTime.value}",
        "created_by": controllers.storage.read("id"),
        "id": id,
        "notes": controllers.callCommentCont.text.trim(),
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("request.body");
      print(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateMeetingDetailsAPI(context,id);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        getAllMeetingActivity("");
        controllers.clearSelectedCustomer();
        controllers.meetingTitleCrt.text = "";
        controllers.meetingVenueCrt.text = "";
        controllers.fDate.value = "";
        controllers.toDate.value = "";
        controllers.fTime.value = "";
        controllers.toTime.value = "";
        controllers.callCommentCont.text = "";
        Navigator.pop(context);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
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
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "disqualified",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "action": "get_data"
        }),
      );
      controllers.isLead.value=true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allQualifiedDetails();
        } else {
          controllers.setLogOut();
        }
      }
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
        controllers.disqualifiedFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.disqualifiedFuture.value = [];
      controllers.isDisqualifiedList.value = [];
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Future bulkEmailAPI(BuildContext context, List<Map<String, String>> list, String image) async {
  //   try {
  //     var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
  //     request.fields['subject']        = controllers.emailSubjectCtr.text;
  //     request.fields['cos_id']         = controllers.storage.read("cos_id").toString();
  //     request.fields['count']          = '${controllers.emailCount.value + 1}';
  //     request.fields['quotation_name'] = controllers.emailQuotationCtr.text;
  //     request.fields['body']           = controllers.emailMessageCtr.text;
  //     request.fields['user_id']        = controllers.storage.read("id").toString();
  //     request.fields['date']           =
  //     "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
  //     request.fields['action']         = 'bulk_mail_receive';
  //     List<String> ids    = list.map((e) => e['lead_id'] ?? '').toList();
  //     List<String> emails = list.map((e) => e['mail_id'] ?? '').toList();
  //     request.fields['clientMail'] = emails.join(",");
  //     request.fields['id']         = ids.join(",");
  //     request.headers.addAll({
  //       'X-API-TOKEN': "${TokenStorage().readToken()}",
  //       'Content-Type': 'application/json'
  //     });
  //     if (imageController.empFileName.value.isNotEmpty) {
  //       var picture1 = http.MultipartFile.fromBytes(
  //         "attachment",
  //         imageController.empMediaData,
  //         filename: imageController.empFileName.value,
  //       );
  //       request.files.add(picture1);
  //     }
  //
  //     var response = await request.send();
  //     var body = await response.stream.bytesToString();
  //     if (response.statusCode == 200 && body.trim()== "Mail process completed.") {
  //       billing_utils.snackBar(msg: "Mail has been sent", color: Colors.green, context: Get.context!);
  //       controllers.emailMessageCtr.clear();
  //       controllers.emailToCtr.clear();
  //       controllers.emailSubjectCtr.clear();
  //       prospectsList.clear();
  //       apiService.allNewLeadsDetails();
  //       await Future.delayed(const Duration(milliseconds: 100));
  //       Navigator.pop(Get.context!);
  //       Get.off(const Suspects(), duration: Duration.zero);
  //       controllers.emailCtr.reset();
  //     } else {
  //       controllers.emailCtr.reset();
  //       errorDialog(Get.context!, "Mail has not been sent");
  //     }
  //   } catch (e) {
  //     errorDialog(Get.context!, e.toString());
  //     controllers.emailCtr.reset();
  //   }
  // }
  Future bulkEmailAPI(
      BuildContext context,
      List<Map<String, String>> list,
      String image,
      ) async {
    try {
      debugPrint("📤 bulkEmailAPI called");
      debugPrint("📦 Total leads: ${list.length}");

      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));

      request.fields['subject']        = controllers.emailSubjectCtr.text;
      request.fields['cos_id']         =
          controllers.storage.read("cos_id").toString();
      request.fields['count']          =
      '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] =
          controllers.emailQuotationCtr.text;
      request.fields['body']           =
          controllers.emailMessageCtr.text;
      request.fields['user_id']        =
          controllers.storage.read("id").toString();
      request.fields['date'] =
      "${controllers.dateTime.day.toString().padLeft(2, "0")}-"
          "${controllers.dateTime.month.toString().padLeft(2, "0")}-"
          "${controllers.dateTime.year} "
          "${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] = 'bulk_mail_receive';

      /// Extract ids & emails
      List<String> ids =
      list.map((e) => e['lead_id'] ?? '').toList();
      List<String> emails =
      list.map((e) => e['mail_id'] ?? '').toList();

      request.fields['clientMail'] = emails.join(",");
      request.fields['id']         = ids.join(",");

      debugPrint("📧 Emails: ${emails.join(",")}");
      debugPrint("🆔 Lead IDs: ${ids.join(",")}");

      debugPrint("📦 Request Fields:");
      request.fields.forEach((key, value) {
        debugPrint("$key : $value");
      });

      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      });

      debugPrint("🧾 Headers: ${request.headers}");

      if (imageController.empFileName.value.isNotEmpty) {
        debugPrint(
          "🖼 Attachment: ${imageController.empFileName.value}",
        );

        var picture1 = http.MultipartFile.fromBytes(
          "attachment",
          imageController.empMediaData,
          filename: imageController.empFileName.value,
        );
        request.files.add(picture1);
      } else {
        debugPrint("⚠️ No attachment added");
      }

      debugPrint("🚀 Sending bulk mail request...");
      var response = await request.send();

      debugPrint("📡 Status Code: ${response.statusCode}");

      var body = await response.stream.bytesToString();
      debugPrint("📨 Response Body: $body");

      if (body.contains("Mail process completed.")) {
        debugPrint("✅ Bulk mail success");

        utils.snackBar(
          msg: "Mail has been sent",
          color: Colors.green,
          context: Get.context!,
        );

        controllers.emailMessageCtr.clear();
        controllers.emailToCtr.clear();
        controllers.emailSubjectCtr.clear();

        prospectsList.clear();
        apiService.allNewLeadsDetails();

        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pop(Get.context!);
        // Get.off(const Suspects(), duration: Duration.zero);

        controllers.emailCtr.reset();
      } else {
        debugPrint("❌ Bulk mail failed");
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has not been sent");
      }
    } catch (e, s) {
      debugPrint("🔥 Exception: $e");
      debugPrint("🧵 StackTrace: $s");

      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  Future deleteCustomersAPI(BuildContext context, List sendList,RxList<NewLeadObj> list, RxList<NewLeadObj> list2) async {
    try {
      Map data = {"action": "delete_customers", "cusList": sendList,
        "cos_id":controllers.storage.read("cos_id").toString(),"user_id":controllers.storage.read("id").toString()};
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json'
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(sendList);
      print("request.body");
      print(request.body);
      // Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return deleteCustomersAPI(context,sendList,list,list2);
        } else {
          controllers.setLogOut();
        }
      }

      if (request.statusCode == 200) {
        // allLeadsDetails();
        // allNewLeadsDetails();
        // allGoodLeadsDetails();
        // allCustomerDetails();
        // allTargetLeadsDetails();
        // prospectsList.clear();
        // qualifiedList.clear();
        // customerList.clear();
        print("Before remove list length: ${list.length}");
        print("Before remove list2 length: ${list2.length}");
        print("Before remove allLeadList length: ${controllers.allLeadList.length}");
        print("Initial list length: ${list.length}");
        print("Initial list2 length: ${list2.length}");
        print("SendList: $sendList");

        list.removeWhere((item) => sendList.contains(item.userId));
        list2.removeWhere((item) => sendList.contains(item.userId));

        print("Final list length: ${list.length}");
        print("Final list2 length: ${list2.length}");

        for(var i=0;i<sendList.length;i++){
          for(var j=0;j<controllers.allLeadList.length;j++){
            if(controllers.allLeadList[j].userId==sendList[i]){
              controllers.allLeadList.removeAt(j);
            }
          }
        }

        print("After remove list length: ${list.length}");
        print("After remove list2 length: ${list2.length}");
        print("After remove allLeadList length: ${controllers.allLeadList.length}");
        dashController.getDashboardReport();
        controllers.idList.clear();
        Navigator.pop(context);
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
      BuildContext context,
      List<Map<String, dynamic>> customerData,
      List<Map<String, dynamic>> fieldMappings,
      Uint8List excelBytes,
      String excelFileName,
      ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(scriptApi),
      );
      request.fields["action"] = "sheet_customers";
      request.fields["field_mappings"] = jsonEncode(fieldMappings);
      request.fields["cusList"] = jsonEncode(customerData);
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      });
      request.files.add(http.MultipartFile.fromBytes(
        'sheet',
        excelBytes,
        filename: excelFileName,
      ));
      var response = await request.send();

      var responseData = await http.Response.fromStream(response);

// STATUS CODE
      print("STATUS CODE: ${responseData.statusCode}");

// FULL RAW RESPONSE
      print("RAW RESPONSE: ${responseData.body}");

// JSON DECODE
      Map<String, dynamic> res = json.decode(responseData.body);

// PRINT JSON MAP
      print("JSON RESPONSE: $res");

// PRINT PARTICULAR VALUE
      print("MESSAGE: ${res['message']}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertCustomersAPI(context,customerData,
            fieldMappings,
            excelBytes,
            excelFileName,);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        // apiService.allLeadsDetails();
        // apiService.allNewLeadsDetails();
        // apiService.allGoodLeadsDetails();
        // apiService.allTargetLeadsDetails();
        getHeading();
        // apiService.getLeadCategories();
        apiService.getCustomLeads();
        Get.to(DashboardPage());
        prospectsList.clear();
        customerList.clear();

        int success = res["success"];
        int failed = res["failed"];
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
      errorDialog(Get.context!, "Failed to insert customer details: $e");
      controllers.customerCtr.reset();
    }
  }

  Future insertThirumalCustomersAPI(BuildContext context, List<Map<String, dynamic>> customerData) async {
    try {
      List<Map<String, dynamic>> formattedData = customerData.map((customer) {
        return customer.map((key, value) {
          return MapEntry(key, value.toString()); // Convert all values to String
        });
      }).toList();

      Map data = {
        "action": "create_customers",
        "cusList": formattedData
      };

      final request = await http.post(
        Uri.parse(scriptApi),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode(data),
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertThirumalCustomersAPI(context,customerData);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "Customer saved successfully.") {
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        apiService.allGoodLeadsDetails();
        apiService.allTargetLeadsDetails();
        prospectsList.clear();
        customerList.clear();
        int success = response["success"];
        int failed = response["failed"];
        Navigator.pop(context);
        controllers.customerCtr.reset();
        if (failed == 0) {
          log("All customers saved successfully.");
        } else {
          for (var failure in response["failures"]) {
            log("Failed Phone: ${failure["phone_no"]} — ${failure["error"]}");
          }
          errorDialog(Get.context!, "$success saved, $failed failed.\n Failed Phone: ${response["failures"]}");
        }
      } else {
        Navigator.pop(context);
        errorDialog(Get.context!, "Failed to insert customer details.");
        controllers.customerCtr.reset();
      }
    } catch (e) {
      Navigator.pop(context);
      errorDialog(Get.context!, "Failed to insert customer details.");
      controllers.customerCtr.reset();
    }
  }


  Future<void> insertSingleCustomer(BuildContext context,RxList<NewLeadObj> list, RxList<NewLeadObj> list2) async {
    try {
      // Lead Status
      String leadId = controllers.leadCategory == "Suspects"
          ? "1"
          : controllers.leadCategory == "Prospects"
          ? "2"
          : controllers.leadCategory == "Qualified"
          ? "3"
          : "4";

      // Visit Type
      String callListId = "";
      for (var role in controllers.callList) {
        if (role['value'] == controllers.visitType) {
          callListId = role['id'].toString();
          break;
        }
      }

      /// ✅ CUSTOMER LIST (DO NOT use Map<String,String>)
      List<Map<String, dynamic>> customersList = [
        {
          "cos_id": controllers.storage.read("cos_id").toString(),
          "name": controllers.leadNameCrt[0].text.trim(),
          "email": controllers.leadEmailCrt[0].text.trim(),
          "phone_no": controllers.numberList
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .join("||"),
          "whatsapp_no": controllers.leadWhatsCrt[0].text.trim(),
          "created_by": controllers.storage.read("id").toString(),
          "platform": "3",
          "department": "",
          "designation": "",
          "main_person": "1"
        }
      ];

      /// ✅ MAIN REQUEST BODY
      Map<String, dynamic> data = {
        "action": "single_customer",
        "user_id": controllers.storage.read("id").toString(),
        "cos_id": controllers.storage.read("cos_id").toString(),

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
        "pincode": int.tryParse(controllers.pinCodeController.text) ?? 0,

        "co_website": controllers.leadWebsite.text.trim(),
        "co_number": controllers.infoNumberList
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty)
            .join("||"),
        "co_email": controllers.leadCoEmailCrt.text.trim(),
        "linkedin": controllers.leadLinkedinCrt.text.trim(),
        "x": controllers.leadXCrt.text.trim(),

        "industry": controllers.industry,
        "product": controllers.leadProduct.text.trim(),
        "source_details": controllers.leadProduct.text.trim(),

        "type": "1",
        "lat": 0.0,
        "lng": 0.0,
        "platform": "3",

        "lead_status": leadId,
        "status": controllers.status,
        "quotation_required": "1",
        "visit_type": callListId,

        "prospect_enrollment_date": controllers.prospectDate.value.isEmpty
            ? DateFormat("dd.MM.yyyy").format(DateTime.now())
            : controllers.prospectDate.value,

        "expected_convertion_date": controllers.exDate.value.isEmpty
            ? DateFormat("dd.MM.yyyy").format(DateTime.now())
            : controllers.exDate.value,

        "status_update": controllers.statusCrt.text.trim(),
        "num_of_headcount":
        int.tryParse(controllers.noOfHeadCountCrt.text) ?? 0,
        "expected_billing_value":
        double.tryParse(controllers.exMonthBillingValCrt.text) ?? 0.0,
        "arpu_value":
        double.tryParse(controllers.arpuCrt.text) ?? 0.0,

        "details_of_service_required":
        controllers.sourceCrt.text.trim(),
        "rating":
        int.tryParse(controllers.prospectGradingCrt.text) ?? 0,
        "owner": controllers.leadTitleCrt[0].text.trim(),

        /// ✅ IMPORTANT: SEND ARRAY, NOT STRING
        "billing_data": customersList,
      };

      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      final body = response.body.toString();
      print(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertSingleCustomer(context,list,list2);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200 &&
        body.contains("Customer saved successfully")) {
        // list.add(NewLeadObj(
        //   select: false,
        //   firstname: controllers.leadNameCrt[0].text.trim(),
        //   email: controllers.leadEmailCrt[0].text.trim(),
        //   mobileNumber: controllers.numberList
        //       .map((e) => e.text.trim())
        //       .where((e) => e.isNotEmpty)
        //       .join("||"),
        //   whatsapp: controllers.leadWhatsCrt[0].text.trim(),
        //   userId: controllers.storage.read("id").toString(),
        //   companyName: controllers.leadCoNameCrt.text.trim(),
        //   productDiscussion: controllers.prodDescriptionController.text.trim(),
        //   source: controllers.leadDisPointsCrt.text.trim(),
        //   notes: controllers.leadActions.text.trim(),
        //   quotationStatus: "",
        //   quotationRequired: "1",
        //
        //   doorNo: controllers.doorNumberController.text.trim(),
        //   area: controllers.areaController.text.trim(),
        //   city: controllers.cityController.text.trim(),
        //   country: controllers.selectedCountry.value,
        //   state: controllers.stateController.text.trim(),
        //   pincode: controllers.pinCodeController.text.trim(),
        //
        //   companyWebsite: controllers.leadWebsite.text.trim(),
        //   companyNumber: controllers.infoNumberList
        //       .map((e) => e.text.trim())
        //       .where((e) => e.isNotEmpty)
        //       .join("||"),
        //   companyEmail: controllers.leadCoEmailCrt.text.trim(),
        //   linkedin: controllers.leadLinkedinCrt.text.trim(),
        //   x: controllers.leadXCrt.text.trim(),
        //
        //   industry: controllers.industry.toString(),
        //   product: controllers.leadProduct.text.trim(),
        //   sourceDetails: controllers.leadProduct.text.trim(),
        //
        //   type: "1",
        //   lat: "0.0",
        //   lng: "0.0",
        //
        //   leadStatus: leadId.toString(),
        //   status: controllers.status.toString(),
        //   visitType: callListId.toString(),
        //
        //   prospectEnrollmentDate:
        //   controllers.prospectDate.value.isEmpty
        //       ? DateFormat("dd.MM.yyyy").format(DateTime.now())
        //       : controllers.prospectDate.value,
        //
        //   expectedConvertionDate:
        //   controllers.exDate.value.isEmpty
        //       ? DateFormat("dd.MM.yyyy").format(DateTime.now())
        //       : controllers.exDate.value,
        //
        //   statusUpdate: controllers.statusCrt.text.trim(),
        //   numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
        //   expectedBillingValue:
        //   controllers.exMonthBillingValCrt.text.trim(),
        //   arpuValue: controllers.arpuCrt.text.trim(),
        //
        //   detailsOfServiceRequired:
        //   controllers.sourceCrt.text.trim(),
        //   rating: controllers.prospectGradingCrt.text.trim(),
        //   owner: controllers.leadTitleCrt[0].text.trim(),
        //
        //   createdTs: DateTime.now().toString(),
        //   updatedTs: DateTime.now().toString(),
        // ));        // apiService.getCustomLeads();
        // list2.add(NewLeadObj(
        //   select: false,
        //   firstname: controllers.leadNameCrt[0].text.trim(),
        //   email: controllers.leadEmailCrt[0].text.trim(),
        //   mobileNumber: controllers.numberList
        //       .map((e) => e.text.trim())
        //       .where((e) => e.isNotEmpty)
        //       .join("||"),
        //   whatsapp: controllers.leadWhatsCrt[0].text.trim(),
        //   userId: controllers.storage.read("id").toString(),
        //   companyName: controllers.leadCoNameCrt.text.trim(),
        //   productDiscussion: controllers.prodDescriptionController.text.trim(),
        //   source: controllers.leadDisPointsCrt.text.trim(),
        //   notes: controllers.leadActions.text.trim(),
        //
        //   quotationStatus: "",
        //   quotationRequired: "1",
        //
        //   doorNo: controllers.doorNumberController.text.trim(),
        //   area: controllers.areaController.text.trim(),
        //   city: controllers.cityController.text.trim(),
        //   country: controllers.selectedCountry.value,
        //   state: controllers.stateController.text.trim(),
        //   pincode: controllers.pinCodeController.text.trim(),
        //
        //   companyWebsite: controllers.leadWebsite.text.trim(),
        //   companyNumber: controllers.infoNumberList
        //       .map((e) => e.text.trim())
        //       .where((e) => e.isNotEmpty)
        //       .join("||"),
        //   companyEmail: controllers.leadCoEmailCrt.text.trim(),
        //   linkedin: controllers.leadLinkedinCrt.text.trim(),
        //   x: controllers.leadXCrt.text.trim(),
        //
        //   industry: controllers.industry.toString(),
        //   product: controllers.leadProduct.text.trim(),
        //   sourceDetails: controllers.leadProduct.text.trim(),
        //
        //   type: "1",
        //   lat: "0.0",
        //   lng: "0.0",
        //
        //   leadStatus: leadId.toString(),
        //   status: controllers.status.toString(),
        //   visitType: callListId.toString(),
        //
        //   prospectEnrollmentDate:
        //   controllers.prospectDate.value.isEmpty
        //       ? DateFormat("dd.MM.yyyy").format(DateTime.now())
        //       : controllers.prospectDate.value,
        //
        //   expectedConvertionDate:
        //   controllers.exDate.value.isEmpty
        //       ? DateFormat("dd.MM.yyyy").format(DateTime.now())
        //       : controllers.exDate.value,
        //
        //   statusUpdate: controllers.statusCrt.text.trim(),
        //   numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
        //   expectedBillingValue:
        //   controllers.exMonthBillingValCrt.text.trim(),
        //   arpuValue: controllers.arpuCrt.text.trim(),
        //
        //   detailsOfServiceRequired:
        //   controllers.sourceCrt.text.trim(),
        //   rating: controllers.prospectGradingCrt.text.trim(),
        //   owner: controllers.leadTitleCrt[0].text.trim(),
        //
        //   createdTs: DateTime.now().toString(),
        //   updatedTs: DateTime.now().toString(),
        // ));        // apiService.getCustomLeads();
        // print("After nav: ${list.last}");
        // print("After nav: ${list.length}");
        var res = jsonDecode(response.body);

        int customerId = int.parse(res["cus_id"].toString());
        int addressId = 0;
        LeadStatusModel? data;
        int index=0;
        for(var i=0;i<controllers.leadCategoryList.length;i++){
          if(controllers.leadCategoryList[i].leadStatus=="1"){
            log("dataaaa: ${controllers.leadCategoryList[i]}");
            log("dataaaa: ${controllers.leadCategoryList[i].list.length}");
            log("dataaaa: ${controllers.leadCategoryList[i].list2.length}");
            controllers.leadCategoryList[i].list.add(NewLeadObj(
              select: false,
              userId:customerId.toString(),
              addressId: addressId.toString(),
              firstname: controllers.leadNameCrt[0].text.trim(),
              email: controllers.leadEmailCrt[0].text.trim(),
              mobileNumber: controllers.numberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              whatsapp: controllers.leadWhatsCrt[0].text.trim(),
              // userId: controllers.storage.read("id").toString(),
              companyName: controllers.leadCoNameCrt.text.trim(),
              productDiscussion: controllers.prodDescriptionController.text.trim(),
              source: controllers.leadDisPointsCrt.text.trim(),
              notes: controllers.leadActions.text.trim(),
              quotationStatus: "",
              quotationRequired: "1",

              doorNo: controllers.doorNumberController.text.trim(),
              area: controllers.areaController.text.trim(),
              city: controllers.cityController.text.trim(),
              country: controllers.selectedCountry.value,
              state: controllers.stateController.text.trim(),
              pincode: controllers.pinCodeController.text.trim(),

              companyWebsite: controllers.leadWebsite.text.trim(),
              companyNumber: controllers.infoNumberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              companyEmail: controllers.leadCoEmailCrt.text.trim(),
              linkedin: controllers.leadLinkedinCrt.text.trim(),
              x: controllers.leadXCrt.text.trim(),

              industry: controllers.industry.toString(),
              product: controllers.leadProduct.text.trim(),
              sourceDetails: controllers.leadProduct.text.trim(),

              type: "1",
              lat: "0.0",
              lng: "0.0",

              leadStatus: leadId.toString(),
              status: controllers.status.toString(),
              visitType: callListId.toString(),

              prospectEnrollmentDate:
              controllers.prospectDate.value.isEmpty
                  ? DateFormat("dd.MM.yyyy").format(DateTime.now())
                  : controllers.prospectDate.value,

              expectedConvertionDate:
              controllers.exDate.value.isEmpty
                  ? DateFormat("dd.MM.yyyy").format(DateTime.now())
                  : controllers.exDate.value,

              statusUpdate: controllers.statusCrt.text.trim(),
              numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
              expectedBillingValue:
              controllers.exMonthBillingValCrt.text.trim(),
              arpuValue: controllers.arpuCrt.text.trim(),

              detailsOfServiceRequired:
              controllers.sourceCrt.text.trim(),
              rating: controllers.prospectGradingCrt.text.trim(),
              owner: controllers.leadTitleCrt[0].text.trim(),

              createdTs: DateTime.now().toString(),
              updatedTs: DateTime.now().toString(),
            ));
            controllers.leadCategoryList[i].list2.add(NewLeadObj(
              select: false,
              userId:customerId.toString(),
              addressId: addressId.toString(),
              firstname: controllers.leadNameCrt[0].text.trim(),
              email: controllers.leadEmailCrt[0].text.trim(),
              mobileNumber: controllers.numberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              whatsapp: controllers.leadWhatsCrt[0].text.trim(),
              // userId: controllers.storage.read("id").toString(),
              companyName: controllers.leadCoNameCrt.text.trim(),
              productDiscussion: controllers.prodDescriptionController.text.trim(),
              source: controllers.leadDisPointsCrt.text.trim(),
              notes: controllers.leadActions.text.trim(),
              quotationStatus: "",
              quotationRequired: "1",

              doorNo: controllers.doorNumberController.text.trim(),
              area: controllers.areaController.text.trim(),
              city: controllers.cityController.text.trim(),
              country: controllers.selectedCountry.value,
              state: controllers.stateController.text.trim(),
              pincode: controllers.pinCodeController.text.trim(),

              companyWebsite: controllers.leadWebsite.text.trim(),
              companyNumber: controllers.infoNumberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              companyEmail: controllers.leadCoEmailCrt.text.trim(),
              linkedin: controllers.leadLinkedinCrt.text.trim(),
              x: controllers.leadXCrt.text.trim(),

              industry: controllers.industry.toString(),
              product: controllers.leadProduct.text.trim(),
              sourceDetails: controllers.leadProduct.text.trim(),

              type: "1",
              lat: "0.0",
              lng: "0.0",

              leadStatus: leadId.toString(),
              status: controllers.status.toString(),
              visitType: callListId.toString(),

              prospectEnrollmentDate:
              controllers.prospectDate.value.isEmpty
                  ? DateFormat("dd.MM.yyyy").format(DateTime.now())
                  : controllers.prospectDate.value,

              expectedConvertionDate:
              controllers.exDate.value.isEmpty
                  ? DateFormat("dd.MM.yyyy").format(DateTime.now())
                  : controllers.exDate.value,

              statusUpdate: controllers.statusCrt.text.trim(),
              numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
              expectedBillingValue:
              controllers.exMonthBillingValCrt.text.trim(),
              arpuValue: controllers.arpuCrt.text.trim(),

              detailsOfServiceRequired:
              controllers.sourceCrt.text.trim(),
              rating: controllers.prospectGradingCrt.text.trim(),
              owner: controllers.leadTitleCrt[0].text.trim(),

              createdTs: DateTime.now().toString(),
              updatedTs: DateTime.now().toString(),
            ));
            controllers.allLeadList.add(NewLeadObj(
              select: false,
              userId:customerId.toString(),
              addressId: addressId.toString(),
              firstname: controllers.leadNameCrt[0].text.trim(),
              email: controllers.leadEmailCrt[0].text.trim(),
              mobileNumber: controllers.numberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              whatsapp: controllers.leadWhatsCrt[0].text.trim(),
              // userId: controllers.storage.read("id").toString(),
              companyName: controllers.leadCoNameCrt.text.trim(),
              productDiscussion: controllers.prodDescriptionController.text.trim(),
              source: controllers.leadDisPointsCrt.text.trim(),
              notes: controllers.leadActions.text.trim(),
              quotationStatus: "",
              quotationRequired: "1",

              doorNo: controllers.doorNumberController.text.trim(),
              area: controllers.areaController.text.trim(),
              city: controllers.cityController.text.trim(),
              country: controllers.selectedCountry.value,
              state: controllers.stateController.text.trim(),
              pincode: controllers.pinCodeController.text.trim(),

              companyWebsite: controllers.leadWebsite.text.trim(),
              companyNumber: controllers.infoNumberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              companyEmail: controllers.leadCoEmailCrt.text.trim(),
              linkedin: controllers.leadLinkedinCrt.text.trim(),
              x: controllers.leadXCrt.text.trim(),

              industry: controllers.industry.toString(),
              product: controllers.leadProduct.text.trim(),
              sourceDetails: controllers.leadProduct.text.trim(),

              type: "1",
              lat: "0.0",
              lng: "0.0",

              leadStatus: leadId.toString(),
              status: controllers.status.toString(),
              visitType: callListId.toString(),

              prospectEnrollmentDate:
              controllers.prospectDate.value.isEmpty
                  ? DateFormat("dd.MM.yyyy").format(DateTime.now())
                  : controllers.prospectDate.value,

              expectedConvertionDate:
              controllers.exDate.value.isEmpty
                  ? DateFormat("dd.MM.yyyy").format(DateTime.now())
                  : controllers.exDate.value,

              statusUpdate: controllers.statusCrt.text.trim(),
              numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
              expectedBillingValue:
              controllers.exMonthBillingValCrt.text.trim(),
              arpuValue: controllers.arpuCrt.text.trim(),

              detailsOfServiceRequired:
              controllers.sourceCrt.text.trim(),
              rating: controllers.prospectGradingCrt.text.trim(),
              owner: controllers.leadTitleCrt[0].text.trim(),

              createdTs: DateTime.now().toString(),
              updatedTs: DateTime.now().toString(),
            ));
            controllers.customers.add(AllCustomersObj(
              id:customerId.toString(),
              name: controllers.leadNameCrt[0].text.trim(),
              companyName: controllers.leadCoNameCrt.text.trim(),
              phoneNo: controllers.numberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              email: controllers.leadEmailCrt[0].text.trim(), leadStatus: controllers.leadCategoryList[0].id,
              category: controllers.leadCategoryList[0].value,

            ));
            index=i;
            controllers.leadCategoryList.refresh();
            data=controllers.leadCategoryList[i];
            break;
          }
        }
        log("dataaaa: ${data}");
        log("dataaaa: ${data!.list.length}");
        log("dataaaa: ${data.list2.length}");
        controllers.selectedIndex.value=int.parse(data.leadStatus.toString());
        controllers.selectedQualifiedSortBy.value="All";
        controllers.selectRadio(list,list2);
        dashController.getDashboardReport();
        controllers.leadCategoryList.refresh();
        data.list.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA); // Desc order
        });
        data.list2.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA); // Desc order
        });
        Get.to(NewLeadPage(index: data.leadStatus ,
          name: data.value,list: data.list,list2: data.list2, listIndex: index,));
      } else if (body.contains("Phone number")) {
        errorDialog(context, "Phone number already exists");
      } else {
        errorDialog(context, body);
      }
    } catch (e) {
      errorDialog(context, e.toString());
    }
  }


  // List<Map<String, String>> qualifiedList = [];
  // Future insertQualifiedAPI(BuildContext context,List<Map<String, String>> list) async {
  //   try {
  //     print("insertQualifiedAPI");
  //     final request = await http.post(Uri.parse(qualifiedScript),
  //         headers: {
  //           'X-API-TOKEN': "${TokenStorage().readToken()}",
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode(list),
  //         encoding: Encoding.getByName("utf-8"));
  //     Map<String, dynamic> response = json.decode(request.body);
  //     if (request.statusCode == 200 && response["message"] == "OK") {
  //       apiService.allLeadsDetails();
  //       apiService.allNewLeadsDetails();
  //       allCustomerDetails();
  //       controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
  //       Navigator.pop(context);
  //       qualifiedList.clear();
  //       // Get.to(const Qualified(), duration: Duration.zero);
  //       controllers.productCtr.reset();
  //     } else {
  //       errorDialog(Get.context!, request.body);
  //       controllers.productCtr.reset();
  //     }
  //   } on SocketException {
  //     controllers.productCtr.reset();
  //     errorDialog(Get.context!, 'No internet connection');
  //     //throw Exception('No internet connection'); // Handle network errors
  //   } on HttpException catch (e) {
  //     controllers.productCtr.reset();
  //     errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
  //     //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
  //   } catch (e) {
  //     errorDialog(Get.context!, e.toString());
  //     controllers.productCtr.reset();
  //   }
  // }

  // Future insertPromoteAPI(BuildContext context,String id,String status,String name, RxList<NewLeadObj> list, RxList<NewLeadObj> list2) async {
  //   try {
  //     print("insertQualifiedAPI");
  //     Map<String, dynamic> billing_data ={
  //       "id": id,
  //       "lead_status": status,
  //       "created_by": controllers.storage.read("id"),
  //       "cos_id": controllers.storage.read("cos_id"),
  //       "action": "update_promote"
  //     };
  //     final request = await http.post(Uri.parse(scriptApi),
  //         headers: {
  //           'X-API-TOKEN': "${TokenStorage().readToken()}",
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode(billing_data),
  //         encoding: Encoding.getByName("utf-8"));
  //     Map<String, dynamic> response = json.decode(request.body);
  //     debugPrint(billing_data.toString());
  //     debugPrint(request.body);
  //     if (request.statusCode == 401) {
  //       final refreshed = await controllers.refreshToken();
  //       if (refreshed) {
  //         return insertPromoteAPI(context,id,status,name,list,list2);
  //       } else {
  //         controllers.setLogOut();
  //       }
  //     }
  //     if (request.statusCode == 200 && response["message"] == "OK") {
  //       controllers.selectedIndex.value=int.parse(status);
  //       Get.back();
  //       Get.to( NewLeadPage(index: status, name: name,list: list,list2: list2,), duration: Duration.zero);
  //       controllers.productCtr.reset();
  //     }
  //     else {
  //       errorDialog(Get.context!, request.body);
  //       controllers.productCtr.reset();
  //     }
  //   } on SocketException {
  //     controllers.productCtr.reset();
  //     errorDialog(Get.context!, 'No internet connection');
  //     //throw Exception('No internet connection'); // Handle network errors
  //   } on HttpException catch (e) {
  //     controllers.productCtr.reset();
  //     errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
  //     //throw Exception('Server error employee: ${e.toString()}'); // Handle HTTP errors
  //   } catch (e) {
  //     errorDialog(Get.context!, e.toString());
  //     controllers.productCtr.reset();
  //   }
  // }
  Future insertPromoteListAPI(BuildContext context,String status,String name, RxList<NewLeadObj> list, RxList<NewLeadObj> list2) async {
    try {
      print("#####");
      Map<String, dynamic> data ={
        "id":controllers.idList,
        "lead_status": status,
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "action": "update_promote_list"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      debugPrint(data.toString());
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertPromoteListAPI(context,status,name,list,list2);
        } else {
          controllers.setLogOut();
        }
      }
      // if (request.statusCode == 200 && response["message"] == "OK") {
      //   controllers.selectedIndex.value = int.parse(status);
      //   RxList<NewLeadObj> tempList=<NewLeadObj>[].obs;
      //   print("status: ${status}");
      //   print("Selected Index: ${controllers.selectedIndex.value}");
      //
      //   for (var i = 0; i < controllers.idList.length; i++) {
      //     print("Checking idList[$i]: ${controllers.idList[i]}");
      //
      //     for (var j = 0; j < list.length; j++) {
      //       print("Comparing list[$j].userId: ${list[j].userId}");
      //
      //       if (list[j].userId == controllers.idList[i]) {
      //         print("MATCH FOUND -> userId: ${list[j].userId}");
      //
      //         list[j].leadStatus = status;
      //
      //         tempList.add(list[j]);
      //
      //         print("Removing from main list index: $j");
      //
      //         list.removeAt(j);
      //         list2.removeAt(j);
      //
      //       }
      //     }
      //   }
      //
      //   log("list2: ${list}");
      //   log("list2: ${list2}");
      //   log("controllers.leadCategoryList[int.parse(status)].list: ${controllers.leadCategoryList[controllers.selectedIndex.value].list}");
      //   log("controllers.leadCategoryList[int.parse(status)].list2: ${controllers.leadCategoryList[controllers.selectedIndex.value].list2}");
      //
      //
      //   print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].leadStatus}");
      //   print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].value}");
      //   print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].list}");
      //   print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].list2}");
      //   controllers.idList.clear();
      //   // dashController.getDashboardReport();
      //   // controllers.selectedIndex.value = int.parse(status);
      //   // Navigator.pop(context); // dialog close only
      //
      //   Future.delayed(Duration(milliseconds: 10), () {
      //     Get.to(
      //           () => NewLeadPage(
      //         key: UniqueKey(),
      //         index: controllers.leadCategoryList[controllers.selectedIndex.value].leadStatus,
      //         name: controllers.leadCategoryList[controllers.selectedIndex.value].value,
      //         list: controllers.leadCategoryList[controllers.selectedIndex.value].list,
      //         list2: controllers.leadCategoryList[controllers.selectedIndex.value].list2, listIndex: int.parse(status),
      //       ),
      //     );
      //   });
      //   controllers.productCtr.reset();
      // }
      if (request.statusCode == 200 && response["message"] == "OK") {
        controllers.selectedIndex.value = int.parse(status);
        RxList<NewLeadObj> tempList=<NewLeadObj>[].obs;
        print("status: ${status}");
        print("Selected Index: ${controllers.selectedIndex.value}");

        for (var i = 0; i < controllers.idList.length; i++) {
          print("Checking idList[$i]: ${controllers.idList[i]}");

          for (var j = 0; j < list.length; j++) {
            print("Comparing list[$j].userId: ${list[j].userId}");

            if (list[j].userId == controllers.idList[i]) {
              print("MATCH FOUND -> userId: ${list[j].userId}");

              list[j].leadStatus = status;

              tempList.add(list[j]);

              print("Removing from main list index: $j");

              list.removeAt(j);
              list2.removeAt(j);

            }
          }
        }
        LeadStatusModel? data;
        for(var i=0;i<controllers.leadCategoryList.length;i++){
          if(controllers.leadCategoryList[i].leadStatus==status){
            controllers.leadCategoryList[i].list.addAll(tempList);
            controllers.leadCategoryList[i].list2.addAll(tempList);
            data=controllers.leadCategoryList[i];
            break;
          }
        }
        // log("controllers.leadCategoryList[int.parse(status)].list: ${controllers.leadCategoryList[controllers.selectedIndex.value].list}");
        // log("controllers.leadCategoryList[int.parse(status)].list2: ${controllers.leadCategoryList[controllers.selectedIndex.value].list2}");
        //
        //
        // print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].leadStatus}");
        // print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].value}");
        // print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].list}");
        // print("Category List : ${controllers.leadCategoryList[controllers.selectedIndex.value].list2}");
        controllers.idList.clear();
        // dashController.getDashboardReport();
        // controllers.selectedIndex.value = int.parse(status);
        // Navigator.pop(context); // dialog close only

        Future.delayed(Duration(milliseconds: 10), () {
          Get.to(
                () => NewLeadPage(
              key: UniqueKey(),
              index: data!.leadStatus,
              name: data.value,
              list: data.list,
              list2: data.list2, listIndex: int.parse(status),
            ), preventDuplicates: false,
          );
        });
        controllers.productCtr.reset();
      }
      else {
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
  Future updateLeadStatus(BuildContext context,List<Map<String, String>> list,String status) async {
    try {
      print("updateLeadStatusAPI");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "action": "lead_status",
            "list": list,
            "lead_status": status,          // extra value
            "cos_id": controllers.storage.read("cos_id").toString()       // vera value venumna
          }),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateLeadStatus(context,list,status);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        allCustomerDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        Navigator.pop(context);
        // qualifiedList.clear();
        customerList.clear();
        prospectsList.clear();
        // if(status=="1"){
        //   Get.to(const Suspects(), duration: Duration.zero);
        // }else if(status=="2"){
        //   Get.to(const Prospects(), duration: Duration.zero);
        // }else if(status=="3"){
        //   Get.to(const Qualified(), duration: Duration.zero);
        // }else{
        //   Get.to(const ViewCustomer(), duration: Duration.zero);
        // }
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
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertPromoteCustomerAPI(context,list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        apiService.allLeadsDetails();
        apiService.allNewLeadsDetails();
        controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
        controllers.allCustomerFuture = apiService.allCustomerDetails();
        Navigator.pop(context);
        customerList.clear();
        // Get.to(const ViewCustomer(), duration: Duration.zero);
        controllers.productCtr.reset();
      } else {
        errorDialog(Get.context!, request.body);
        controllers.productCtr.reset();
      }
    } on SocketException {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'No internet connection');
    } on HttpException catch (e) {
      controllers.productCtr.reset();
      errorDialog(Get.context!, 'Server error promote: ${e.toString()}');
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  void loginCApi(context) async {
    try {
      Map data = {
        "mobile_number": controllers.loginNumber.text,
        "password": controllers.loginPassword.text,
        "action": "login_jwt"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print("request.body");
      // print(request.body);

      final Map<String, dynamic> response = json.decode(request.body);

      print(response);
      if(request.body.toString().contains("Invalid mobile number or password")){
        utils.snackBar(context: context, msg: "Invalid mobile number or password", color: Colors.red);
        controllers.loginCtr.reset();
      }
      // if (request.statusCode == 401) {
      //   final refreshed = await controllers.refreshToken();
      //   if (refreshed) {
      //     return loginCApi(context);
      //   } else {
      //     controllers.setLogOut();
      //   }
      // }

      if (request.statusCode == 200 && response['status'] == 'success') {
        TokenStorage().writeToken(response['access_token']);
        TokenStorage().writeRefreshToken(response['refresh_token']);
        controllers.storage.write("f_name", response['user']['s_name']);
        controllers.storage.write("mobile", response['user']['s_mobile']);
        controllers.storage.write("role", response['user']['permission']);
        controllers.storage.write("id", response['user']['id']);
        controllers.storage.write("cos_id", response['user']["cos_id"]);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("loginScreen$versionNum", true);
        String input = "Admin";
        controllers.isAdmin.value = input == "Admin" ? true : false;
        prefs.setBool("isAdmin", controllers.isAdmin.value);
        prefs.remove("loginNumber");
        prefs.remove("loginPassword");
        getAllCallActivity("");
        getAllMailActivity();
        getAllMeetingActivity("");
        getAllNoteActivity();
        loginHistoryApi();
        allLeadsDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allCustomerDetails();
        allQualifiedDetails();
        allTargetLeadsDetails();
        getUserHeading();
        getRoles();
        getSheet();
        getAllCustomers();
        getOpenedMailActivity(true);
        getReplyMailActivity(true);
        remController.allReminders("2");
        settingsController.allRoles();
        settingsController.allOfficeHours();
        utils.snackBar(
          context: Get.context!,
          msg: "Login Successfully",
          color: Colors.green,
        );
        Get.to(const DashboardPage(), duration: Duration.zero);
        controllers.loginCtr.reset();
      } else {
        controllers.loginCtr.reset();
        errorDialog(Get.context!, 'No Account Found');
      }
    } catch (e) {
      controllers.loginCtr.reset();
      errorDialog(Get.context!, 'Login failed: ${e.toString()}');
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
        "app_version": versionNum,
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
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return loginHistoryApi();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        log("Login history added success");
      } else {
        controllers.loginCtr.reset();
      }
    } catch (e) {
      controllers.loginCtr.reset();
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
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getVisitType();
        } else {
          controllers.setLogOut();
        }
      }
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

  Future getLeadCategories() async {
    try {
      // controllers.leadCategoryList.clear();
      debugPrint("get leadddddd");
      Map data = {
        "search_type": "lead_categories",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("leadddddd");
      debugPrint(data.toString());
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getLeadCategories();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        // controllers.leadCategoryList.clear();
        List response = json.decode(request.body);
        controllers.leadCategoryList.value = response.map<LeadStatusModel>((item) {
          return LeadStatusModel(
            leadStatus: item["lead_status"].toString(),
            value: item["value"].toString(),
            id: item["id"].toString(),
            icon1: item["icon1"].toString(),
            icon2: item["icon2"].toString(),
            displayOrder: item["display_order"],
            active: item['active'].toString(),
            totalLead: item['total_lead'].toString(),
          );
        }).toList();
        // controllers.leadCategoryList.assignAll(converted);
        controllers.editMode.value =List.generate(controllers.leadCategoryList.length, (index) => false);
        // controllers.leadCategoryList.sort(
        //       (a, b) => int.parse(a.leadStatus)
        //       .compareTo(int.parse(b.leadStatus)),
        // );
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }
  Future getAllLeadCategories() async {
    try {
      controllers.allLeadCategoryList.clear();
      controllers.allLead.clear();
      Map data = {
        "search_type": "all_lead_categories",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("allleadddddd");
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getLeadCategories();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        // controllers.leadCategoryList.clear();
        List response = json.decode(request.body);
        controllers.allLead.value = response.map<LeadStatusModel>((item) {
          return LeadStatusModel(
            leadStatus: item["lead_status"].toString(),
            value: item["value"].toString(),
            id: item["id"].toString(),
            icon1: item["icon1"].toString(),
            icon2: item["icon2"].toString(),
            displayOrder: item["display_order"],
            active: item['active'].toString(),
            totalLead: item['total_lead'].toString(),
          );
        }).toList();
        controllers.allLeadCategoryList.value = response.map<LeadStatusModel>((item) {
          return LeadStatusModel(
            leadStatus: item["lead_status"].toString(),
            value: item["value"].toString(),
            id: item["id"].toString(),
            icon1: item["icon1"].toString(),
            icon2: item["icon2"].toString(),
            displayOrder: item["display_order"],
            active: item['active'].toString(),
            totalLead: item['total_lead'].toString(),
          );
        }).toList();

        // controllers.leadCategoryList.assignAll(converted);
        // controllers.leadCategoryList.sort(
        //       (a, b) => int.parse(a.leadStatus)
        //       .compareTo(int.parse(b.leadStatus)),
        // );
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
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("allCustomers");
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllCustomers();
        } else {
          controllers.setLogOut();
        }
      }
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

  Future getAllEmployees() async {
    try {
      Map data = {
        "search_type": "allEmployees",
        "cos_id": "${int.parse(controllers.storage.read("cos_id"))}",
        "action": "get_data"
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllEmployees();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.employees.clear();
        controllers.employees.value = response.map((e) => AllEmployeesObj.fromJson(e)).toList();
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
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      controllers.isMailLoading.value = false;
      print("getting mails");
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllMailActivity();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        final List response = json.decode(request.body);
        controllers.mailActivity.clear();
        final activities = response.map((e) => CustomerActivity.fromJson(e)).toList();
        controllers.mailActivity.assignAll(activities);
        controllers.allSentMails.value = controllers.mailActivity.length.toString();
        remController.selectedMailSortBy.value=dashController.selectedSortBy.value;
        remController.sortMails();
        // remController.sortMails();
        // remController.dashboardCommunicationFilterList(
        //   dataList: controllers.mailActivity,
        //   searchText: controllers.searchText.value.toLowerCase(),
        //   callType: controllers.selectCallType.value,
        //   sortField: controllers.sortFieldCallActivity.value,
        //   sortOrder: controllers.sortOrderCallActivity.value,
        //   selectedMonth: remController.selectedCallMonth.value,
        //   selectedRange: remController.selectedCallRange.value,
        //   selectedDateFilter: remController.selectedCallSortBy.value,
        // );
      } else {
        throw Exception('Failed to load mail activity');
      }
    } catch (e) {
      controllers.mailActivity.clear();
      controllers.isMailLoading.value = false;
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
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getReplyMailActivity(isMain);
        } else {
          controllers.setLogOut();
        }
      }
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
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getOpenedMailActivity(isMain);
        } else {
          controllers.setLogOut();
        }
      }
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

  Future getAllMeetingActivity(String cusId) async {
    try {
      Map data = {
        "search_type": "meeting_details",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "cus_id": cusId
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      // print(billing_data);
      // print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllMeetingActivity(cusId);
        } else {
          controllers.setLogOut();
        }
      }
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
        remController.dashboardMeetings(
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectMeetingType.value,
          sortField: controllers.sortFieldMeetingActivity.value,
          sortOrder: controllers.sortOrderMeetingActivity.value,
        );
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

      final request = await http.post(Uri.parse(scriptApi),
        body: jsonEncode(data),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateLeadStatusUpdateAPI(context,leadId,mobile,status);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="Customer updated successfully."){
        utils.snackBar(msg: "Your Lead is updated successfully !",
            color: Colors.green,context:Get.context!);
        Get.back();
        apiService.allNewLeadsDetails();
        apiService.allLeadsDetails();
        apiService.allGoodLeadsDetails();
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
  Future updateInstantChanges(BuildContext context,
      {required String leadId,required String value,required String column}) async {
    showLoadingDialog(context);
    try{
      Map data ={
        "updated_by":controllers.storage.read("id"),
        "column":column,
        'value' : value,
        "id":leadId,
        "action":"instant_value"
      };

      final request = await http.post(Uri.parse(scriptApi),
        body: jsonEncode(data),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
      );
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateInstantChanges(context,leadId: leadId,value: value,column: column);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"]=="Customer updated successfully."){
        utils.snackBar(msg: "Your Lead is updated successfully !",
            color: Colors.green,context:Get.context!);
        Get.back();
        apiService.allNewLeadsDetails();
        apiService.allLeadsDetails();
        apiService.allGoodLeadsDetails();
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
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllNoteActivity();
        } else {
          controllers.setLogOut();
        }
      }
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

  Future getHeading() async {
    try {
      Map data = {
        "search_type": "user_field_head",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"};
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getUserHeading();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.fields.clear();
        controllers.fields.value = response.map((e) => CustomerField.fromJson(e)).toList();
        tableController.setHeading(response);
      } else {
        controllers.fields.value = controllers.defaultFields.map((e) => CustomerField.fromJson(e)).toList();
        tableController.setHeading(controllers.defaultFields);
        throw Exception('Failed to load album');
      }
    } catch (e) {
        controllers.fields.value = controllers.defaultFields.map((e) => CustomerField.fromJson(e)).toList();
        tableController.setHeading(controllers.defaultFields);
        throw Exception('Failed to load album');
    }
  }
  Future getUserHeading() async {
    try {
      Map data = {
        "search_type": "user_field_head",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"};
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print("Api headings");
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getUserHeading();
        } else {
          controllers.setLogOut();
        }
      }
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
  ///
  // Future getUserHeading2() async {
  //   try {
  //     Map billing_data = {
  //       "search_type": "user_field_head",
  //       "cos_id": controllers.storage.read("cos_id"),
  //       "action": "get_data"};
  //     final request = await http.post(Uri.parse(scriptApi),
  //         headers: {
  //           'X-API-TOKEN': "${TokenStorage().readToken()}",
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode(billing_data),
  //         encoding: Encoding.getByName("utf-8"));
  //     if (request.statusCode == 401) {
  //       final refreshed = await controllers.refreshToken();
  //       if (refreshed) {
  //         return getUserHeading2();
  //       } else {
  //         controllers.setLogOut();
  //       }
  //     }
  //     if (request.statusCode == 200) {
  //       List response = json.decode(request.body);
  //       controllers.fields.clear();
  //       controllers.fields.value = response.map((e) => CustomerField.fromJson(e)).toList();
  //       tableController.setHeadingFields(response);
  //     } else {
  //       controllers.fields.value = controllers.defaultFields.map((e) => CustomerField.fromJson(e)).toList();
  //       tableController.setHeadingFields(controllers.defaultFields);
  //       throw Exception('Failed to load album');
  //     }
  //   } catch (e) {
  //       controllers.fields.value = controllers.defaultFields.map((e) => CustomerField.fromJson(e)).toList();
  //       tableController.setHeadingFields(controllers.defaultFields);
  //       throw Exception('Failed to load album');
  //   }
  // }

  Future insertQuotationAPI(BuildContext context,pw.Document pdf,String productListJson) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
      request.fields['clientMail'] = controllers.selectedCustomerEmail.value;
      request.fields['subject'] = controllers.emailSubjectCtr.text;
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = "Product Quotation";
      request.fields['body'] = controllers.emailMessageCtr.text;
      request.fields['cus_id'] = controllers.storage.read("id").toString();
      request.fields['customer_id'] = controllers.selectedCustomerId.value;
      request.fields['notes'] = controllers.notesCtr.text;
      request.fields['validity_date'] = "${DateFormat('dd-MM-yyyy').format(DateTime.now())} to ${DateFormat('dd-MM-yyyy').format(DateTime.now().add(Duration(days: 15)))}";
      request.fields['date'] = "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] = 'send_quotation';
      request.fields['total_amt'] = '${Provider.of<BillingProvider>(context, listen: false).calculatedGrandTotal()}';
      request.fields['productList'] = productListJson;
      request.fields['total_product'] = Provider.of<BillingProvider>(context, listen: false).calculatedTotalProducts().toString();
      request.fields['total_item'] = Provider.of<BillingProvider>(context, listen: false).calculatedTotalQuantity().toString();
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
      final bytes = await pdf.save();



      request.files.add(
        http.MultipartFile.fromBytes(
          'invoice',
          bytes,
          filename: "${controllers.selectedCustomerName.value.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf",
        ),
      );
      var response = await request.send();
      var body = await response.stream.bytesToString();
      print("body");
      print(body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertQuotationAPI(context,pdf,productListJson);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        utils.snackBar(
            msg: "Quotation sent successfully",
            color: Colors.green,
            context: Get.context!);
        controllers.emailMessageCtr.clear();
        controllers.emailToCtr.clear();
        controllers.emailSubjectCtr.clear();
        productCtr.productsList.clear();
        Provider.of<BillingProvider>(context, listen: false).billingItems.clear();
        productCtr.getQuotationDetails();
        Navigator.pop(Get.context!);
        controllers.changeTab(0);
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
  Future updateAppointmentStatus(BuildContext context,String status) async {
    try {
      Map data ={
        "created_by":controllers.storage.read("id"),
        "cos_id":controllers.storage.read("cos_id"),
        "status":status,
        "idList":remController.selectedMeetingIds.value,
        "action":"appointment_status"
      };

      final request = await http.post(Uri.parse(scriptApi),
        body: jsonEncode(data),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
      );
      print("body");
      print(data);
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateAppointmentStatus(context,status);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        utils.snackBar( msg: "Status Updated Successfully", color: Colors.green, context: Get.context!);
        remController.selectedMeetingIds.clear();
        apiService.getAllMeetingActivity("");
        Navigator.pop(Get.context!);
        remController.selectedMeetSortBy.value = dashController.selectedSortBy.value;
        remController.dashboardMeetings(
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectMeetingType.value,
          sortField: controllers.sortFieldMeetingActivity.value,
          sortOrder: controllers.sortOrderMeetingActivity.value,
        );
        controllers.emailCtr.reset();
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Status Updated Failed");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  Future confirmOrderAPI(BuildContext context,String id,String cusId,String totalAmt,String name,String number) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['updated_by'] = controllers.storage.read("id").toString();
      request.fields['id'] = id;
      request.fields['customer_id'] = cusId;
      request.fields['action'] = 'insert_order';
      request.fields['total_amt'] = totalAmt;
      request.fields['name'] = name;
      request.fields['number'] = number;
      // request.fields['productList'] = productListJson;
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
      var response = await request.send();
      var body = await response.stream.bytesToString();
      print("body");
      print(request.fields);
      print(body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return confirmOrderAPI(context,id,cusId,totalAmt,name,number);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        utils.snackBar(
            msg: "Order Confirmed",
            color: Colors.green,
            context: Get.context!);
        // controllers.clearSelectedCustomer();
        // productCtr.clearProduct();
        // Navigator.pop(Get.context!);
        controllers.emailCtr.reset();
        productCtr.getQuotationDetails();
        productCtr.getOrderDetails();
        remController.selectedCallSortBy.value = dashController.selectedSortBy.value;
        controllers.changeTab(0);
        controllers.selectedIndex.value=106;
        Navigator.push(context,
          PageRouteBuilder(
            pageBuilder: (context,animation1,animation2) =>
            const OrderPage(),
            transitionDuration:Duration.zero,
            reverseTransitionDuration:Duration.zero,),);
        controllers.oldIndex.value = controllers.selectedIndex.value;
        controllers.selectedIndex.value = 101;
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has been not sent");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
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
      request.fields['customer_name'] = controllers.selectedCustomerName.value;
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
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
      print("body");
      print(body);
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
      request.fields['customer_name'] = controllers.selectedCustomerName.value;
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
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
      if (response.statusCode == 200 && body == "Message has been sent") {
        log("Mail sent successfully");
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Mail has been not sent");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }
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
              isCopy: true,
              colors: colorsConst.textColor,
            ),
          );
        });
  }
  void cusErrorDialog(BuildContext context, String text) {
    final parts = text.split('\n\nFailed List:\n');
    final headerText = parts.first;
    final failedLines = parts.length > 1
        ? parts.last
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList()
        : <String>[];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 500,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      5.width,
                      Center(
                        child: Text(
                          headerText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                            controllers.leadCtr.reset();
                          },
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  if (failedLines.isNotEmpty)
                    Container(
                      width: 450,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        color: Colors.grey.shade200,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: const Text(
                          'Failed List:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (failedLines.isNotEmpty)
                    Container(
                      width: 450,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                      ),
                      child: Column(
                        children: failedLines.map((line) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    line.replaceFirst('• ', ''),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  24.height,
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {"search_type": "product", "cos_id": controllers.storage.read("cos_id"), "action": "get_data"}),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allProductDetails();
        } else {
          controllers.setLogOut();
        }
      }
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
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "customer_comments",
          "id": id,
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allCommentDetails(id);
        } else {
          controllers.setLogOut();
        }
      }
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
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "mail_comments",
          "id": id,
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return mailCommentDetails(id);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
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
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "mail_receive",
          "id": controllers.storage.read("id"),
          "role": controllers.storage.read("role"),
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allCommentReportDetails();
        } else {
          controllers.setLogOut();
        }
      }
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
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "mail_receive",
          "cos_id": controllers.storage.read("cos_id"),
          "sent_id": id,
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return mailReceiveDetails(id);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Cast to List
        controllers.mailReceivesList.value = data;
        controllers.emailCount.value = int.parse(controllers
                .mailReceivesList[controllers.mailReceivesList.length - 1]
            ['sent_count']);
      } else {
        controllers.mailReceivesList.value = [];
        throw Exception(
            'Failed to load leads: Status code ${response.statusCode}'); // Provide more specific error message
      }
    } on SocketException {
      controllers.mailReceivesList.value = [];
    } on HttpException {
      controllers.mailReceivesList.value = [];
    } catch (e) {
      controllers.mailReceivesList.value = [];
    }
  }

  Future<List<NewLeadObj>> allLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allLeadsLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "2",
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allLeadsDetails();
        } else {
          controllers.setLogOut();
        }
      }
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
            "mail": data[i]["email_id"].toString(),
          });
        }
        controllers.allLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.allLeads.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isLead.value = true;
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load leads: Status code ${response.body}'); // Provide more specific error message
      }
    } on SocketException {
      throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      controllers.allLeadFuture.value = [];
      controllers.allLeads.value = [];
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
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "lead_details",
          "cos_id": controllers.storage.read("cos_id"),
          "lead_id": leadId,
          "action": "get_data"
        }),
      );
      controllers.isLead.value = true;
      controllers.isLeadLoading.value = false;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return leadsDetails(leadId);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}'); // Provide more specific error message
      }
    } on SocketException {
      controllers.isLeadLoading.value = false;
      throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      controllers.isLeadLoading.value = false;
      throw Exception('Server error: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      controllers.isLeadLoading.value = false;
      throw Exception('Unexpected error lead: ${e.toString()}'); // Catch other exceptions
    }
  }

  Future<CustomerFullDetails> leadsDetailsForCustomer(String customerId) async {
    controllers.isLeadLoading.value = true;
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        // headers: {'Content-Type': 'application/json'},
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "cos_id": controllers.storage.read("cos_id"),
          "customer_id": customerId,
          "action": "lead_details"
        }),
      );

      controllers.isLeadLoading.value = false;
      print(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return leadsDetailsForCustomer(customerId);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['responseCode']?.toString() == '200') {
          final data = decoded['data'];
          if (data is Map<String, dynamic>) {
            return CustomerFullDetails.fromJson(data);
          } else {
            throw Exception('Unexpected billing_data payload format');
          }
        } else {
          throw Exception('API error: ${decoded['responseMsg'] ?? response.body}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      controllers.isLeadLoading.value = false;
      throw Exception('No internet connection');
    } catch (e) {
      controllers.isLeadLoading.value = false;
      rethrow;
    }
  }

  Future<void> allNewLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allNewLeadsLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "1",
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allNewLeadsDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        controllers.allNewLeadsLength.value = data.length;
        controllers.isNewLeadList.clear();

        for (int i = 0; i < data.length; i++) {
          controllers.isNewLeadList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
            "mail": data[i]["email_id"].toString(),
          });
        }

        controllers.allNewLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isLead.value = true;
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.allNewLeadFuture.value = [];
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Map<String, int> getStatusCountMap() {
    final Map<String, int> map = {};

    for (var item in remController.callFilteredList) {
      final status = item.callStatus.trim();
      if (status.isEmpty) continue;

      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }
  // Map<String, int> getStatusCountMap() {
  //   final Map<String, int> map = {};
  //
  //   for (var item in controllers.callActivity) {
  //     final status = item.callStatus.trim();
  //     if (status.isEmpty) continue;
  //
  //     map[status] = (map[status] ?? 0) + 1;
  //   }
  //   return map;
  // }
  void mergeStatusWithCount() {
    final statusCountMap = getStatusCountMap();

    controllers.hCallStatusList.value =
        controllers.hCallStatusList.map((item) {
          final statusValue = item["value"]?.toString();

          return {
            ...item,
            "count": statusCountMap[statusValue] ?? 0,
          };
        }).toList();

    // 🔹 Total count calculate
    int totalCount = controllers.hCallStatusList.fold(
        0, (sum, item) => sum + ((item["count"] ?? 0) as int));

    controllers.allCalls.value = totalCount.toString();

    log("Total Calls: $totalCount");
    log("Merged Status List: ${controllers.hCallStatusList}");
  }//new
  Future getAllCallActivity(String cusId) async {
    try {
      Map data = {
        "search_type": "records",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "type": "7",
        "cus_id": cusId
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getAllCallActivity(cusId);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.callActivity.clear();
        controllers.callActivity.value = response.map((e) => CustomerActivity.fromJson(e)).toList();
        // final incoming = controllers.callActivity.where((e) => e.callType.isNotEmpty && e.callType.trim() == "Incoming").toList();
        // final outgoing = controllers.callActivity
        //     .where((e) => e.callType.isNotEmpty && e.callType.trim() == "Outgoing")
        //     .toList();
        // final missed = controllers.callActivity
        //     .where((e) => e.callType.isNotEmpty && e.callType.trim() == "Missed")
        //     .toList();
        //
        // controllers.allIncomingCalls.value = incoming.length.toString();
        // controllers.allOutgoingCalls.value = outgoing.length.toString();
        // controllers.allMissedCalls.value = missed.length.toString();
        controllers.allCalls.value = response.length.toString();
        mergeStatusWithCount();
        remController.filterAndSortCalls(
          allCalls: controllers.callActivity,
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectCallType.value,
          sortField: controllers.sortFieldCallActivity.value,
          sortOrder: controllers.sortOrderCallActivity.value,
          selectedMonth: remController.selectedCallMonth.value,
          selectedRange: remController.selectedCallRange.value,
          selectedDateFilter: remController.selectedCallSortBy.value,
        );
        remController.dashboardCommunicationFilterList(
          dataList: controllers.callActivity,
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectCallType.value,
          sortField: controllers.sortFieldCallActivity.value,
          sortOrder: controllers.sortOrderCallActivity.value,
          selectedMonth: remController.selectedCallMonth.value,
          selectedRange: remController.selectedCallRange.value,
          selectedDateFilter: remController.selectedCallSortBy.value,
        );
      } else {
        controllers.allIncomingCalls.value = "0";
        controllers.allOutgoingCalls.value = "0";
        controllers.allMissedCalls.value = "0";
        controllers.callActivity.clear();
        throw Exception('Failed to load album Recordssss');
      }
    } catch (e) {
      controllers.allIncomingCalls.value = "0";
      controllers.allOutgoingCalls.value = "0";
      controllers.allMissedCalls.value = "0";
      controllers.callActivity.clear();
      throw Exception('Failed to load album Recordssss');
    }
  }
  Future getMailCallActivity() async {
    try {
      Map data = {
        "search_type": "mails_calls",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getMailCallActivity();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        remController.callMailsDetailsList2.clear();

        remController.callMailsDetailsList2.value = response.map((e) => CustomerActivity.fromJson(e)).toList();

        remController.dashboardCommunicationFilterList(
          dataList: remController.callMailsDetailsList2,
          searchText: controllers.searchText.value.toLowerCase(),
          callType: controllers.selectCallType.value,
          sortField: controllers.sortFieldCallActivity.value,
          sortOrder: controllers.sortOrderCallActivity.value,
          selectedMonth: remController.selectedCallMonth.value,
          selectedRange: remController.selectedCallRange.value,
          selectedDateFilter: remController.selectedCallSortBy.value,
        );
      } else {
        controllers.allIncomingCalls.value = "0";
        controllers.allOutgoingCalls.value = "0";
        controllers.allMissedCalls.value = "0";
        controllers.callActivity.clear();
        throw Exception('Failed to load album Recordssss');
      }
    } catch (e) {
      controllers.allIncomingCalls.value = "0";
      controllers.allOutgoingCalls.value = "0";
      controllers.allMissedCalls.value = "0";
      controllers.callActivity.clear();
      throw Exception('Failed to load album Recordssss');
    }
  }
  Future<void> allRatingLeadsDetails(String type) async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "rating_leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "type": type,
          "action": "get_data"
        }),
      );
      debugPrint("rating leads ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allRatingLeadsDetails(type);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        controllers.allRatingLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isLead.value = true;
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.allRatingLeadFuture.value = [];
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future<List<NewLeadObj>> allGoodLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi); // Double-check URL correctness
    controllers.allGoodLeadsLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "3",
          "action": "get_data"
        }),
      );
      controllers.isLead.value = true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allGoodLeadsDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List; // Cast to List
        controllers.allGoodLeadsLength.value = data.length;
        controllers.isGoodLeadList.value = [];
        for (int i = 0; i < controllers.allGoodLeadsLength.value; i++) {
          controllers.isGoodLeadList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
            "mail": data[i]["email_id"].toString(),
          });
        }
        controllers.allQualifiedLeadFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load leads: Status code ${response.body}'); // Provide more specific error message
      }
    } on SocketException {
      throw Exception('No internet connection'); // Handle network errors
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}'); // Handle HTTP errors
    } catch (e) {
      throw Exception(
          'Unexpected error lead: ${e.toString()}'); // Catch other exceptions
    }
  }

  Future getRoles() async {
    try {
      Map data = {
        "search_type": "all_roles",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data"
      };

      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getRoles();
        } else {
          controllers.setLogOut();
        }
      }
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
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getSheet();
        } else {
          controllers.setLogOut();
        }
      }
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
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {"search_type": "company",
              "cos_id": controllers.storage.read("cos_id"),
              "action": "get_data"}),
      );
      controllers.isLead.value = true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allCompanyDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allCompanyLength.value = data.length;
        return data.map((json) => CompanyObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load companies: Status code ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
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
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      controllers.versionActive.value = false;
      controllers.updateAvailable.value = false;
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return currentVersion();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.serverVersion.value = response[0]["current_version"];
        controllers.currentUserCount.value = response[0]["user_count"];
        controllers.planType.value = response[0]["plan_type"].toString();
        final expiredDate = parseExpiredDate(response[0]["expired_date"]);
        final now = DateTime.now();
        if (expiredDate != null && now.isAfter(expiredDate)) {
          utils.expiredDateDialog(response[0]["expired_date"]);
          controllers.versionActive.value = true;
          controllers.updateAvailable.value = false;
          return;
        }
        if (versionNum != controllers.serverVersion.value) {
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
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      log("view dashboard report");
      log(request.body);
      controllers.directVisit.value = "0";
      controllers.telephoneCalls.value = "0";
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getDashBoardReport();
        } else {
          controllers.setLogOut();
        }
      }
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
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getMonthReport();
        } else {
          controllers.setLogOut();
        }
      }
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
      dashController.dayReport.value = [];
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getDayReport(year,month);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        dashController.dayReport.value = response.map<CustomerDayData>(
              (e) => CustomerDayData.fromJson(e),
        ).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future<void> sendOtpAPI({required String mobile})  async {
    try {
      Map data = {"mobile": "91$mobile",
        "action": "send_sms"
      };
      log(data.toString());
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      Map<String, dynamic> response = json.decode(request.body.trim());
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return sendOtpAPI(mobile: mobile);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        log("res $response");
        controllers.otp.value = response["otp"].toString();
        controllers.loginCtr.reset();
      } else {
        utils.snackBar(
            msg: response.toString(), color: Colors.red, context: Get.context!);
        controllers.loginCtr.reset();
      }
    } catch (e) {
      utils.snackBar(
          msg: e.toString(), color: Colors.red, context: Get.context!);
      controllers.loginCtr.reset();
    }
  }

  Future<void> resetPasswordAPI({required String mobile,required String pass})  async {
    try {
      Map data = {
        "mobile_number": mobile,
        "password": pass,
        "updated_by" : controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "action": "forgot_password"
      };
      log(data.toString());
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      Map<String, dynamic> response = json.decode(request.body.trim());
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return resetPasswordAPI(mobile: mobile,pass: pass);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        log("res $response");
        controllers.storage.write("f_name", response["billing_data"]["s_name"]);
        controllers.storage.write("role", response["billing_data"]["permission"]);
        controllers.storage.write("role_name", "Admin");
        controllers.storage.write("id", response["billing_data"]["id"]);
        controllers.storage.write("cos_id", response["billing_data"]["cos_id"]);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("loginScreen${versionNum}", true);
        String input = "Admin";
        controllers.isAdmin.value = input == "Admin" ? true : false;
        prefs.setBool("isAdmin", controllers.isAdmin.value);
        prefs.remove("loginNumber");
        prefs.remove("loginPassword");
        getAllCallActivity("");
        getAllMailActivity();
        getAllMeetingActivity("");
        getAllNoteActivity();
        loginHistoryApi();
        allLeadsDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allCustomerDetails();
        allQualifiedDetails();
        allTargetLeadsDetails();
        getUserHeading();
        getRoles();
        getSheet();
        getAllCustomers();
        getOpenedMailActivity(true);
        getReplyMailActivity(true);
        remController.allReminders("2");
        settingsController.allRoles();
        settingsController.allOfficeHours();
        utils.snackBar(
          context: Get.context!,
          msg: "Password Updated Successfully",
          color: Colors.green,
        );
        Get.to(const DashboardPage(), duration: Duration.zero);
        controllers.loginCtr.reset();
      } else {
        utils.snackBar(
            msg: response.toString(), color: Colors.red, context: Get.context!);
        controllers.loginCtr.reset();
      }
    } catch (e) {
      utils.snackBar(
          msg: e.toString(), color: Colors.red, context: Get.context!);
      controllers.loginCtr.reset();
    }
  }

  Future<bool> checkMobileAPI({required String mobile})  async {
    try {
      Map data = {
        "mobile_number": mobile,
        "action": "check_mobile"
      };
      log(data.toString());
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      Map<String, dynamic> response = json.decode(request.body.trim());
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return checkMobileAPI(mobile: mobile);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response.containsKey("s_name")) {
        log("res $response");
        controllers.loginCtr.reset();
        return true;
      } else {
        //Santhiya
        utils.snackBar(
            msg: "Mobile number not registered", color: Colors.red, context: Get.context!);
        controllers.loginCtr.reset();
        return false;
      }
    } catch (e) {
      //Santhiya
      utils.snackBar(
          msg: "Mobile number not registered", color: Colors.red, context: Get.context!);
      controllers.loginCtr.reset();
      return false;
    }
  }


  Future<List<NewLeadObj>> allCustomerDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allCustomerLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "4",
          "action": "get_data"
        }),
      );
      controllers.isLead.value = true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allCustomerDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allCustomerLength.value = data.length;
        controllers.isCustomerList.value=[];
        for(int i=0;i<controllers.allCustomerLength.value;i++){
          controllers.isCustomerList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
            "mail_id": data[i]["email_id"].toString(),
          });
        }
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
      controllers.allCustomerLeadFuture.clear();
      throw Exception('Unexpected error lead: ${e.toString()}');
    }
  }

  Future<void> allTargetLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allTargetLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "0",
          "action": "get_data"
        }),
      );
      controllers.isLead.value=true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allTargetLeadsDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allTargetLength.value = data.length;
        controllers.isTargetLeadList.clear();
        controllers.targetLeadsFuture.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        for (int i = 0; i < controllers.allTargetLength.value; i++) {
          controllers.isTargetLeadList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
            "mail_id": data[i]["email_id"].toString(),
          });
        }
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.isTargetLeadList.clear();
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future<List<EmployeeObj>> allEmployeeDetails() async {
    final url = Uri.parse(scriptApi); // Double-check URL correctness
    controllers.allEmployeeLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {"search_type": "employee", "cos_id": controllers.storage.read("cos_id"), "action": "get_data"}),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return allEmployeeDetails();
        } else {
          controllers.setLogOut();
        }
      }
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
  /// New Leads -santhiya
  List<Map<String, String>> newLeadList = [];

  Future<void> getCustomLeads() async {
    debugPrint("getCustomLeads");
    controllers.isCrmData.value = false;
    controllers.allLeadList.clear();
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "all_leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_id": "",
          "action": "get_data"
        }),
      );
      // debugPrint("response.bodyyyy");
      // debugPrint(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getCustomLeads();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        // newLeadList.clear();
        controllers.allLeadList.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        // controllers.searchNewLeadList.value = billing_data.map((json) => NewLeadObj.fromJson(json)).toList();
        for (var e in controllers.leadCategoryList) { e.list.clear(); e.list2.clear(); }
        for (int i = 0; i < controllers.leadCategoryList.length; i++) {
          for (int j = 0; j < controllers.allLeadList.length; j++) {
            if (controllers.leadCategoryList[i].leadStatus == controllers.allLeadList[j].leadStatus) {
              controllers.leadCategoryList[i].list.add(controllers.allLeadList[j]);
              controllers.leadCategoryList[i].list2.add(controllers.allLeadList[j]);
              // print("Added → ${controllers.allLeadList[j].leadStatus} to ${controllers.leadCategoryList[i].leadStatus}");
            }
          }
          // print("Final List for ${controllers.leadCategoryList[i].leadStatus} : ${controllers.leadCategoryList[i].list}");
        }
        // log("----------> ${controllers.leadCategoryList}");
        controllers.isCrmData.value=true;
        dashController.getCustomerStatus();
      } else {
        controllers.allLeadList.clear();
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.allLeadList.clear();
      controllers.isCrmData.value=true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.allLeadList.clear();
      controllers.isCrmData.value=true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.allLeadList.clear();
      controllers.isCrmData.value=true;
      controllers.newLeadList.clear();
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
  Future<void> getLeadRatingDetails(String type) async {
    // debugPrint("getLeadRatingDetails");
    controllers.isCrmData.value = false;
    controllers.ratingList.clear();
    controllers.ratingList2.clear();
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "lead_rating_leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_status": controllers.leadCategoryList.last.leadStatus,
          "type": type,
          "action": "get_data"
        }),
      );
      // debugPrint("response.bodyyyy");
      // debugPrint(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getCustomLeads();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.ratingList.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.ratingList2.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isCrmData.value=true;
      } else {
        controllers.allLeadList.clear();
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value=true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value=true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value=true;
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
  Future<void> getCustomerRatingDetails(String type) async {
    // print("getCustomerRatingDetails");
    controllers.isCrmData.value = false;
    controllers.ratingList.clear();
    controllers.ratingList2.clear();
    final url = Uri.parse(scriptApi);
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "customer_rating_leads",
          "cos_id": controllers.storage.read("cos_id"),
          "role": controllers.storage.read("role"),
          "id": controllers.storage.read("id"),
          "lead_status": controllers.leadCategoryList.last.leadStatus,
          "type": type,
          "action": "get_data"
        }),
      );
      // print("customer_rating_leads");
      // print(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getCustomLeads();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.ratingList.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.ratingList2.value = data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isCrmData.value=true;
      } else {
        controllers.ratingList.clear();
        controllers.ratingList2.clear();
        controllers.isCrmData.value=true;
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value=true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value=true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value=true;
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
void changeList(String leadId){
  controllers.isLead.value = false;
  controllers.newLeadList.value.clear();
    controllers.searchNewLeadList.value.clear();
    for(var i=0;i<controllers.allLeadList.length;i++){
      if(controllers.allLeadList[i].leadStatus==leadId){
        controllers.newLeadList.value.add(controllers.allLeadList[i]);
      }
    }
    controllers.searchNewLeadList.value=controllers.newLeadList.value;
  controllers.isLead.value = true;
}
}
