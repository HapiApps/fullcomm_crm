import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';
import 'package:fullcomm_crm/models/user_heading_obj.dart';
import 'package:fullcomm_crm/screens/leads/new_lead_page.dart';

import '../../models/customer_full_obj.dart';
import '../api_services.dart';

extension LeadApi on ApiService {
  NewLeadObj _leadFromForm({
    required String userId,
    required String leadStatus,
    required String visitType,
    String addressId = "0",
    bool isNew = false,
  }) {
    final today = DateFormat("dd.MM.yyyy").format(DateTime.now());
    final mobile = controllers.numberList
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .join("||");
    final coNumber = controllers.infoNumberList
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .join("||");
    final prospectDate = controllers.prospectDate.value.isEmpty
        ? today
        : controllers.prospectDate.value;
    final exDate =
    controllers.exDate.value.isEmpty ? today : controllers.exDate.value;

    if (isNew) {
      return NewLeadObj(
        points: controllers.leadActions.text.trim(),
        referredBy: controllers.throughBy.text.trim(),
        additionalInfo: controllers.addList.toString(),
        select: false,
        userId: userId,
        addressId: addressId,
        firstname: controllers.leadNameCrt[0].text.trim(),
        email: controllers.leadEmailCrt[0].text.trim(),
        mobileNumber: mobile,
        whatsapp: controllers.leadWhatsCrt[0].text.trim(),
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
        companyNumber: coNumber,
        companyEmail: controllers.leadCoEmailCrt.text.trim(),
        linkedin: controllers.leadLinkedinCrt.text.trim(),
        x: controllers.leadXCrt.text.trim(),
        industry: controllers.industry.toString(),
        product: controllers.leadProduct.text.trim(),
        sourceDetails: controllers.leadProduct.text.trim(),
        type: "1",
        lat: "0.0",
        lng: "0.0",
        leadStatus: leadStatus,
        status: controllers.status.toString(),
        visitType: visitType,
        prospectEnrollmentDate: prospectDate,
        expectedConvertionDate: exDate,
        statusUpdate: controllers.statusCrt.text.trim(),
        numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
        expectedBillingValue: controllers.exMonthBillingValCrt.text.trim(),
        arpuValue: controllers.arpuCrt.text.trim(),
        detailsOfServiceRequired: controllers.sourceCrt.text.trim(),
        rating: controllers.prospectGradingCrt.text.trim(),
        owner: controllers.leadTitleCrt[0].text.trim(),
        createdTs: DateTime.now().toString(),
        updatedTs: DateTime.now().toString(),
        additional: controllers.addList,
      );
    }

    return NewLeadObj(
      points: controllers.leadActions.text.trim(),
      referredBy: controllers.throughBy.text.trim(),
      userId: userId,
      select: false,
      firstname: controllers.leadNameCrt[0].text.trim(),
      email: controllers.leadEmailCrt[0].text.trim(),
      mobileNumber: mobile,
      whatsapp: controllers.leadWhatsCrt[0].text.trim(),
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
      companyNumber: coNumber,
      companyEmail: controllers.leadCoEmailCrt.text.trim(),
      linkedin: controllers.leadLinkedinCrt.text.trim(),
      x: controllers.leadXCrt.text.trim(),
      industry: controllers.industry.toString(),
      product: controllers.leadProduct.text.trim(),
      sourceDetails: controllers.leadProduct.text.trim(),
      type: "1",
      lat: "0.0",
      lng: "0.0",
      leadStatus: leadStatus,
      status: controllers.status.toString(),
      visitType: visitType,
      prospectEnrollmentDate: prospectDate,
      expectedConvertionDate: exDate,
      statusUpdate: controllers.statusCrt.text.trim(),
      numOfHeadcount: controllers.noOfHeadCountCrt.text.trim(),
      expectedBillingValue: controllers.exMonthBillingValCrt.text.trim(),
      arpuValue: controllers.arpuCrt.text.trim(),
      detailsOfServiceRequired: controllers.sourceCrt.text.trim(),
      rating: controllers.prospectGradingCrt.text.trim(),
      owner: controllers.leadTitleCrt[0].text.trim(),
      updatedTs: DateTime.now().toString(),
      additional: controllers.addList,
    );
  }

  Future updateLeadAPI(BuildContext context,
      {required int index,
        required String name,
        required String leadId,
        required String type,
        required String addressId,
        required List<AdditionalInfo> addList,
        required RxList<NewLeadObj> list,
        required RxList<NewLeadObj> list2}) async {
    try {
      String callListId = "";
      for (var role in controllers.callList) {
        if (role['value'] == controllers.visitType) {
          callListId = role['id'].toString();
          break;
        }
      }
      final today =
          "${(controllers.dateTime.day.toString().padLeft(2, "0"))}.${(controllers.dateTime.month.toString().padLeft(2, "0"))}.${(controllers.dateTime.year.toString())}";
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
        'prospect_enrollment_date': controllers.prospectDate.value.isEmpty
            ? today
            : controllers.prospectDate.value,
        'expected_convertion_date': controllers.exDate.value.isEmpty
            ? today
            : controllers.exDate.value,
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
        "action": "update_customer",
        "additional_list": controllers.addList,
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
          return await updateLeadAPI(context,
              index: index,
              name: name,
              leadId: leadId,
              type: type,
              addressId: addressId,
              addList: addList,
              list: list,
              list2: list2);
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
        list[index] = _leadFromForm(
            userId: leadId, leadStatus: leadId, visitType: callListId);
        list2[index] = _leadFromForm(
            userId: leadId, leadStatus: leadId, visitType: callListId);

        final indexValue =
        controllers.customers.indexWhere((e) => e.id == leadId);

        if (indexValue != -1) {
          controllers.customers[indexValue].name =
              controllers.leadNameCrt[0].text.trim();
          controllers.customers[indexValue].companyName =
              controllers.leadCoNameCrt.text.trim();
          controllers.customers[indexValue].phoneNo = controllers.numberList
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .join("||");
          controllers.customers[indexValue].email =
              controllers.leadEmailCrt[0].text.trim();

          controllers.customers.refresh();
        }
        if (controllers.selectedQualifiedSortBy.value == "") {
          controllers.selectedQualifiedSortBy.value = "All";
        }
        controllers.selectRadio(list, list2);

        list.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA);
        });
        list2.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA);
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => NewLeadPage(
                index: index.toString(),
                name: name,
                list: list,
                list2: list2,
                listIndex: 0,
              )),
        );
        controllers.allGoodLeadFuture = allGoodLeadsDetails();
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

  Future updateLeadStatusUpdateAPI(
      BuildContext context, String leadId, String mobile, String status) async {
    showLoadingDialog(context);
    try {
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        'status_update': status.trim(),
        "lead_id": leadId,
        "phone_no": mobile,
        "action": "status_update"
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
          return await updateLeadStatusUpdateAPI(context, leadId, mobile, status);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Customer updated successfully.") {
        utils.snackBar(
            msg: "Your Lead is updated successfully !",
            color: Colors.green,
            context: Get.context!);
        Get.back();
        allNewLeadsDetails();
        allLeadsDetails();
        allGoodLeadsDetails();
        controllers.leadCtr.reset();
      } else {
        Navigator.of(context).pop();
        errorDialog(Get.context!, request.body);
        controllers.leadCtr.reset();
      }
    } catch (e) {
      Navigator.of(context).pop();
      errorDialog(Get.context!, "Something went wrong, Please try again later");
      controllers.leadCtr.reset();
    }
  }

  Future updateInstantChanges(BuildContext context,
      {required String leadId,
        required String value,
        required String column}) async {
    showLoadingDialog(context);
    try {
      Map data = {
        "updated_by": controllers.storage.read("id"),
        "column": column,
        'value': value,
        "id": leadId,
        "action": "instant_value"
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
          return await updateInstantChanges(context,
              leadId: leadId, value: value, column: column);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Customer updated successfully.") {
        utils.snackBar(
            msg: "Your Lead is updated successfully !",
            color: Colors.green,
            context: Get.context!);
        Get.back();
        allNewLeadsDetails();
        allLeadsDetails();
        allGoodLeadsDetails();
        controllers.leadCtr.reset();
      } else {
        Navigator.of(context).pop();
        errorDialog(Get.context!, request.body);
        controllers.leadCtr.reset();
      }
    } catch (e) {
      Navigator.of(context).pop();
      errorDialog(Get.context!, "Something went wrong, Please try again later");
      controllers.leadCtr.reset();
    }
  }


  Future<void> insertSingleCustomer(BuildContext context, RxList<NewLeadObj> list,
      RxList<NewLeadObj> list2) async {
    try {
      String leadId = controllers.leadCategory == "Suspects"
          ? "1"
          : controllers.leadCategory == "Prospects"
          ? "2"
          : controllers.leadCategory == "Qualified"
          ? "3"
          : "4";

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

      Map<String, dynamic> data = {
        "action": "single_customer",
        "additional_list": controllers.addList,
        "user_id": controllers.storage.read("id").toString(),
        "cos_id": controllers.storage.read("cos_id").toString(),
        "company_name": controllers.leadCoNameCrt.text.trim(),
        "product_discussion": controllers.prodDescriptionController.text.trim(),
        "source": controllers.leadDisPointsCrt.text.trim(),
        "points": controllers.leadActions.text.trim(),
        "referred_by": controllers.throughBy.text.trim(),
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
        "visit_type": controllers.visitType,
        "prospect_enrollment_date": controllers.prospectDate.value.isEmpty
            ? DateFormat("dd.MM.yyyy").format(DateTime.now())
            : controllers.prospectDate.value,
        "expected_convertion_date": controllers.exDate.value.isEmpty
            ? DateFormat("dd.MM.yyyy").format(DateTime.now())
            : controllers.exDate.value,
        "status_update": controllers.statusCrt.text.trim(),
        "num_of_headcount": int.tryParse(controllers.noOfHeadCountCrt.text) ?? 0,
        "expected_billing_value":
        double.tryParse(controllers.exMonthBillingValCrt.text) ?? 0.0,
        "arpu_value": double.tryParse(controllers.arpuCrt.text) ?? 0.0,
        "details_of_service_required": controllers.sourceCrt.text.trim(),
        "rating": int.tryParse(controllers.prospectGradingCrt.text) ?? 0,
        "owner": controllers.leadTitleCrt[0].text.trim(),
        "data": customersList,
      };

      final response = await http
          .post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      )
          .timeout(const Duration(seconds: 20));

      final body = response.body.toString();
      debugPrint(data.toString());
      debugPrint(response.body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await insertSingleCustomer(context, list, list2);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200 &&
          body.contains("Customer saved successfully")) {
        var res = jsonDecode(response.body);

        int customerId = int.parse(res["cus_id"].toString());
        LeadStatusModel? category;
        int index = 0;
        for (var i = 0; i < controllers.leadCategoryList.length; i++) {
          if (controllers.leadCategoryList[i].leadStatus == "1") {
            controllers.leadCategoryList[i].list.add(_leadFromForm(
                userId: customerId.toString(),
                leadStatus: leadId,
                visitType: controllers.visitType.toString(),
                isNew: true));
            controllers.leadCategoryList[i].list2.add(_leadFromForm(
                userId: customerId.toString(),
                leadStatus: leadId,
                visitType: controllers.visitType.toString(),
                isNew: true));
            controllers.allLeadList.add(_leadFromForm(
                userId: customerId.toString(),
                leadStatus: leadId,
                visitType: controllers.visitType.toString(),
                isNew: true));
            controllers.customers.add(AllCustomersObj(
              id: customerId.toString(),
              name: controllers.leadNameCrt[0].text.trim(),
              companyName: controllers.leadCoNameCrt.text.trim(),
              phoneNo: controllers.numberList
                  .map((e) => e.text.trim())
                  .where((e) => e.isNotEmpty)
                  .join("||"),
              email: controllers.leadEmailCrt[0].text.trim(),
              leadStatus: controllers.leadCategoryList[0].id,
              category: controllers.leadCategoryList[0].value,
            ));
            index = i;
            controllers.leadCategoryList.refresh();
            category = controllers.leadCategoryList[i];
            break;
          }
        }
        controllers.selectedIndex.value =
            int.parse(category!.leadStatus.toString());
        if (controllers.selectedQualifiedSortBy.value == "") {
          controllers.selectedQualifiedSortBy.value = "All";
        }
        controllers.selectRadio(list, list2);
        dashController.getWholeReport();
        controllers.leadCategoryList.refresh();
        category.list.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA);
        });
        category.list2.sort((a, b) {
          DateTime dateA = DateTime.parse(a.updatedTs.toString());
          DateTime dateB = DateTime.parse(b.updatedTs.toString());
          return dateB.compareTo(dateA);
        });
        Get.to(NewLeadPage(
          index: category.leadStatus,
          name: category.value,
          list: category.list,
          list2: category.list2,
          listIndex: index,
        ));
      } else if (body.contains("Phone number")) {
        errorDialog(context, "Phone number already exists");
      } else {
        errorDialog(context, body);
      }
    } on TimeoutException {
      controllers.leadCtr.reset();
      errorDialog(context,
          "Internet connection is slow. Please check your connection and try again.");
    } on SocketException {
      controllers.leadCtr.reset();
      errorDialog(
          context, "Please check your internet connection and try again.");
    } on http.ClientException {
      controllers.leadCtr.reset();
      errorDialog(context,
          "Unable to connect to the server. Please check your internet connection.");
    } catch (e) {
      controllers.leadCtr.reset();
      errorDialog(context, "Something went wrong. Please try again.");
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
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
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

      debugPrint("STATUS CODE: ${responseData.statusCode}");

      Map<String, dynamic> res = json.decode(responseData.body);

      debugPrint("JSON RESPONSE: $res");
      debugPrint("MESSAGE: ${res['message']}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await insertCustomersAPI(
            context,
            customerData,
            fieldMappings,
            excelBytes,
            excelFileName,
          );
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        getHeading();
        getCustomLeads();
        Navigator.pop(context);
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

  Future insertThirumalCustomersAPI(
      BuildContext context, List<Map<String, dynamic>> customerData) async {
    try {
      List<Map<String, dynamic>> formattedData = customerData.map((customer) {
        return customer.map((key, value) {
          return MapEntry(key, value.toString());
        });
      }).toList();

      Map data = {"action": "create_customers", "cusList": formattedData};

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
          return await insertThirumalCustomersAPI(context, customerData);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Customer saved successfully.") {
        allLeadsDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allTargetLeadsDetails();
        prospectsList.clear();
        customerList.clear();
        int success = response["success"];
        int failed = response["failed"];
        Navigator.pop(context);
        controllers.customerCtr.reset();
        if (failed == 0) {
          debugPrint("All customers saved successfully.");
        } else {
          for (var failure in response["failures"]) {
            debugPrint(
                "Failed Phone: ${failure["phone_no"]} — ${failure["error"]}");
          }
          errorDialog(Get.context!,
              "$success saved, $failed failed.\n Failed Phone: ${response["failures"]}");
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

  Future deleteCustomersAPI(BuildContext context, List sendList,
      RxList<NewLeadObj> list, RxList<NewLeadObj> list2) async {
    try {
      Map data = {
        "action": "delete_customers",
        "cusList": sendList,
        "cos_id": controllers.storage.read("cos_id").toString(),
        "user_id": controllers.storage.read("id").toString()
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json'
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await deleteCustomersAPI(context, sendList, list, list2);
        } else {
          controllers.setLogOut();
        }
      }

      if (request.statusCode == 200) {
        list.removeWhere((item) => sendList.contains(item.userId));
        list2.removeWhere((item) => sendList.contains(item.userId));

        for (var i = 0; i < sendList.length; i++) {
          for (var j = 0; j < controllers.allLeadList.length; j++) {
            if (controllers.allLeadList[j].userId == sendList[i]) {
              controllers.allLeadList.removeAt(j);
            }
          }
        }

        dashController.getWholeReport();
        controllers.idList.clear();
        Navigator.pop(context);
        utils.snackBar(
            context: context, msg: "Deleted Successfully", color: Colors.green);
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

  Future insertPromoteListAPI(BuildContext context, String reason, String status,
      String name, RxList<NewLeadObj> list, RxList<NewLeadObj> list2) async {
    try {
      Map<String, dynamic> data = {
        "id": controllers.idList,
        "lead_status": status,
        "reason": reason,
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
          return await insertPromoteListAPI(
              context, reason, status, name, list, list2);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        controllers.selectedIndex.value = int.parse(status);
        RxList<NewLeadObj> tempList = <NewLeadObj>[].obs;

        for (var i = 0; i < controllers.idList.length; i++) {
          for (var j = 0; j < list.length; j++) {
            if (list[j].userId == controllers.idList[i]) {
              list[j].leadStatus = status;
              tempList.add(list[j]);
              list.removeAt(j);
              list2.removeAt(j);
            }
          }
        }
        LeadStatusModel? category;
        for (var i = 0; i < controllers.leadCategoryList.length; i++) {
          if (controllers.leadCategoryList[i].leadStatus == status) {
            controllers.leadCategoryList[i].list.addAll(tempList);
            controllers.leadCategoryList[i].list2.addAll(tempList);
            category = controllers.leadCategoryList[i];
            break;
          }
        }
        controllers.idList.clear();

        Future.delayed(const Duration(milliseconds: 10), () {
          Get.to(
                () => NewLeadPage(
              key: UniqueKey(),
              index: category!.leadStatus,
              name: category.value,
              list: category.list,
              list2: category.list2,
              listIndex: int.parse(status),
            ),
            preventDuplicates: false,
          );
        });
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

  Future updateLeadStatus(BuildContext context, List<Map<String, String>> list,
      String status) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "action": "lead_status",
            "list": list,
            "lead_status": status,
            "cos_id": controllers.storage.read("cos_id").toString()
          }),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await updateLeadStatus(context, list, status);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allNewLeadsDetails();
        allCustomerDetails();
        controllers.allGoodLeadFuture = allGoodLeadsDetails();
        Navigator.pop(context);
        customerList.clear();
        prospectsList.clear();
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

  Future insertPromoteCustomerAPI(
      BuildContext context, List<Map<String, String>> list) async {
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
          return await insertPromoteCustomerAPI(context, list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allNewLeadsDetails();
        controllers.allGoodLeadFuture = allGoodLeadsDetails();
        controllers.allCustomerFuture = allCustomerDetails();
        Navigator.pop(context);
        customerList.clear();
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
        allLeadsDetails();
        allNewLeadsDetails();
        allQualifiedDetails();
        controllers.allGoodLeadFuture = allGoodLeadsDetails();
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

  Future disqualifiedCustomersAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      Map data = {"action": "disqualified", "active": "2", "cusList": list};
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint(request.body);
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await disqualifiedCustomersAPI(context, list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allNewLeadsDetails();
        allQualifiedDetails();
        controllers.allGoodLeadFuture = allGoodLeadsDetails();
        prospectsList.clear();
        customerList.clear();
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

  Future qualifiedCustomersAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      Map data = {"action": "disqualified", "active": "1", "cusList": list};
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
          return await qualifiedCustomersAPI(context, list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allQualifiedDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allCustomerDetails();
        prospectsList.clear();
        customerList.clear();
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

  Future insertLeadPromoteAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      Map data = {"action": "lead_promote", "cusList": list};
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
          return await insertLeadPromoteAPI(context, list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allQualifiedDetails();
        allNewLeadsDetails();
        allGoodLeadsDetails();
        allCustomerDetails();
        prospectsList.clear();
        customerList.clear();
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

  Future insertSuspectsAPI(
      BuildContext context, List<Map<String, String>> list) async {
    try {
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"action": "insert_suspects", "list": list}),
          encoding: Encoding.getByName("utf-8"));
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await insertSuspectsAPI(context, list);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["message"] == "OK") {
        allLeadsDetails();
        allQualifiedDetails();
        allNewLeadsDetails();
        allTargetLeadsDetails();
        controllers.allGoodLeadFuture = allGoodLeadsDetails();
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
}