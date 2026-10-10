import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/controller/image_controller.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:fullcomm_crm/controller/reminder_controller.dart';
import 'package:fullcomm_crm/models/product_obj.dart';
import 'package:fullcomm_crm/screens/order/order_page.dart';
import 'package:fullcomm_crm/screens/quotation/quotation_history.dart';
import 'package:fullcomm_crm/view_models/billing_provider.dart';

import '../api_services.dart';

extension QuotationApi on ApiService {
  Future insertQuotationAPI(
      BuildContext context, pw.Document pdf, String productListJson) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
      request.fields['clientMail'] = controllers.emailToCtr.text;
      request.fields['subject'] = controllers.emailSubjectCtr.text;
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['count'] = '${controllers.emailCount.value + 1}';
      request.fields['quotation_name'] = "Product Quotation";
      request.fields['body'] = controllers.emailMessageCtr.text;
      request.fields['cus_id'] = controllers.storage.read("id").toString();
      request.fields['created_by'] = controllers.storage.read("id").toString();
      request.fields['customer_id'] = controllers.selectedCustomerId.value;
      request.fields['notes'] = controllers.notesCtr.text;
      request.fields['validity_date'] =
      "${DateFormat('dd-MM-yyyy').format(DateTime.now())} to ${DateFormat('dd-MM-yyyy').format(DateTime.now().add(const Duration(days: 15)))}";
      request.fields['date'] =
      "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
      request.fields['action'] = 'send_quotation';
      request.fields['total_amt'] =
      '${Provider.of<BillingProvider>(context, listen: false).calculatedGrandTotal()}';
      request.fields['productList'] = productListJson;
      request.fields['total_product'] =
          Provider.of<BillingProvider>(context, listen: false)
              .calculatedTotalProducts()
              .toString();
      request.fields['total_item'] =
          Provider.of<BillingProvider>(context, listen: false)
              .calculatedTotalQuantity()
              .toString();
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
      final bytes = await pdf.save();

      request.files.add(
        http.MultipartFile.fromBytes(
          'invoice',
          bytes,
          filename:
          "${controllers.selectedCustomerName.value.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf",
        ),
      );
      var response = await request.send();
      var body = await response.stream.bytesToString();
      debugPrint("body ${request.fields.toString()}");
      debugPrint(body);
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertQuotationAPI(context, pdf, productListJson);
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
        Provider.of<BillingProvider>(context, listen: false)
            .billingItems
            .clear();
        productCtr.getQuotationDetails();
        Get.to(QuotationHistory());
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

  Future insertInvoiceAPI(
      BuildContext context, pw.Document pdf, String productListJson) async {
    // try {
    var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
    request.fields['clientMail'] = controllers.emailToCtr.text;
    request.fields['subject'] = controllers.emailSubjectCtr.text;
    request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
    request.fields['count'] = '${controllers.emailCount.value + 1}';
    request.fields['quotation_name'] = "Product Quotation";
    request.fields['body'] = controllers.emailMessageCtr.text;
    request.fields['cus_id'] = controllers.storage.read("id").toString();
    request.fields['created_by'] = controllers.storage.read("id").toString();
    request.fields['customer_id'] = controllers.selectedCustomerId.value;
    request.fields['notes'] = controllers.notesCtr.text;
    request.fields['type'] = controllers.type.value;
    request.fields['q_id'] = controllers.qId.value;
    request.fields['date'] =
    "${controllers.dateTime.day.toString().padLeft(2, "0")}-${controllers.dateTime.month.toString().padLeft(2, "0")}-${controllers.dateTime.year.toString()} ${DateFormat('hh:mm a').format(DateTime.now())}";
    request.fields['action'] = 'send_invoice';
    request.fields['total_amt'] =
    '${Provider.of<BillingProvider>(context, listen: false).calculatedGrandTotal()}';
    request.fields['productList'] = productListJson;
    request.fields['total_product'] =
        Provider.of<BillingProvider>(context, listen: false)
            .calculatedTotalProducts()
            .toString();
    request.fields['total_item'] =
        Provider.of<BillingProvider>(context, listen: false)
            .calculatedTotalQuantity()
            .toString();
    request.headers.addAll({
      'X-API-TOKEN': "${TokenStorage().readToken()}",
      'Content-Type': 'application/json'
    });
    final bytes = await pdf.save();

    request.files.add(
      http.MultipartFile.fromBytes(
        'invoice',
        bytes,
        filename:
        "${controllers.selectedCustomerName.value.replaceAll(' ', '_')}_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.pdf",
      ),
    );
    var response = await request.send();
    var body = await response.stream.bytesToString();
    debugPrint("body");
    debugPrint(request.fields.toString());
    debugPrint(body);
    if (response.statusCode == 401) {
      final refreshed = await controllers.refreshToken();
      if (refreshed) {
        return insertInvoiceAPI(context, pdf, productListJson);
      } else {
        controllers.setLogOut();
      }
    }
    if (response.statusCode == 200) {
      utils.snackBar(
          msg: "Invoice sent successfully",
          color: Colors.green,
          context: Get.context!);
      controllers.emailMessageCtr.clear();
      controllers.emailToCtr.clear();
      controllers.emailSubjectCtr.clear();
      Provider.of<BillingProvider>(context, listen: false)
          .billingItems
          .clear();
      productCtr.getQuotationDetails();
      Get.to(QuotationHistory());
      controllers.emailCtr.reset();
    } else {
      controllers.emailCtr.reset();
      errorDialog(Get.context!, "Mail has been not sent");
    }
    // } catch (e) {
    //   errorDialog(Get.context!, e.toString());
    //   controllers.emailCtr.reset();
    // }
  }

  Future insertPOAPI(BuildContext context, String email, String cId,
      String qId, String cName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
      request.fields['action'] = 'send_po';
      request.fields['customer_id'] = cId;
      request.fields['q_id'] = qId;
      request.fields['created_by'] = controllers.storage.read("id").toString();
      request.fields['clientMail'] = email;
      request.fields['po_number'] = controllers.emailToCtr.text;
      request.fields['po_date'] = controllers.emailSubjectCtr.text;
      request.fields['customer_name'] = cName;
      request.fields['notes'] = controllers.notesCtr.text;
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
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
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertPOAPI(context, email, cId, qId, cName);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        utils.snackBar(
            msg: "Purchase Order Saved successfully",
            color: Colors.green,
            context: Get.context!);
        productCtr.getQuotationDetails();
        Navigator.pop(Get.context!);
        controllers.emailCtr.reset();
      } else {
        controllers.emailCtr.reset();
        errorDialog(Get.context!, "Failed");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.emailCtr.reset();
    }
  }

  Future confirmOrderAPI(BuildContext context, String iNo, String id,
      String cusId, String totalAmt, String name, String number) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(scriptApi));
      request.fields['cos_id'] = controllers.storage.read("cos_id").toString();
      request.fields['updated_by'] = controllers.storage.read("id").toString();
      request.fields['id'] = id;
      request.fields['i_no'] = iNo;
      request.fields['customer_id'] = cusId;
      request.fields['action'] = 'insert_order';
      request.fields['total_amt'] = totalAmt;
      request.fields['name'] = name;
      request.fields['number'] = number;
      request.headers.addAll({
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json'
      });
      var response = await request.send();
      var body = await response.stream.bytesToString();
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          // FIXED: argument order now matches the function signature
          return confirmOrderAPI(
              context, iNo, id, cusId, totalAmt, name, number);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        utils.snackBar(
            msg: "Order Confirmed",
            color: Colors.green,
            context: Get.context!);
        controllers.productCtr.reset();
        productCtr.getQuotationDetails();
        productCtr.getOrderDetails();
        remController.selectedCallSortBy.value =
            dashController.selectedSortBy.value;
        controllers.changeTab(0);
        controllers.selectedIndex.value = 106;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
            const OrderPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        controllers.oldIndex.value = controllers.selectedIndex.value;
        controllers.selectedIndex.value = 101;
      } else {
        controllers.productCtr.reset();
        errorDialog(Get.context!, "Failed");
      }
    } catch (e) {
      errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  Future updateConditions(BuildContext context) async {
    try {
      Map data = {
        "action": "update_terms_conditions",
        "list": productCtr.termsAndConditionsList,
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
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateConditions(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        utils.snackBar(
            context: context, msg: "Reorder successfully", color: Colors.green);
        controllers.productCtr.reset();
      } else {
        errorDialog(context, request.body);
      }
    } catch (e) {
      errorDialog(context, e.toString());
    }
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
        body: jsonEncode({
          "search_type": "product",
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
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
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error product: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error product: ${e.toString()}');
    }
  }
}