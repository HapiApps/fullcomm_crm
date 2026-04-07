import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import '../billing_utils/toast_messages.dart';
import '../common/billing_data/api_urls.dart';
import '../common/utilities/jwt_storage.dart';
import '../controller/controller.dart';
import '../models/billing_models/category_model.dart';
import '../models/billing_models/online_orders.dart';
import '../models/billing_models/order_details.dart';
import '../models/billing_models/place_order.dart';
import '../models/billing_models/placed_order_response.dart';
import '../models/billing_models/return_qty.dart';
import 'package:http/http.dart' as http;

class PlaceOrderRepository {

  /// Place Order :
  // Future<PlacedOrderResponse> placeOrder({required Order order}) async {
  //   try {
  //
  //     final response = await http.post(
  //         Uri.parse(ApiUrl.script),
  //         body: jsonEncode(order.toJson())
  //         );
  //
  //     if (response.statusCode == 200) {
  //
  //       final data = jsonDecode(response.body);
  //
  //       return PlacedOrderResponse.fromJson(data);
  //
  //     } else {
  //       log("placeOrder Error : ${response.body} \n"
  //           "Reason:${response.reasonPhrase}");
  //
  //       throw "Error on billing";
  //     }
  //   } catch (e) {
  //     throw Exception("placeOrder Catch Error : $e");
  //   }
  // }
  Future<PlacedOrderResponse> placeOrder({required Order order,required BuildContext context}) async {
    try {
      final Map<String, dynamic> requestBody = {
        ...order.toJson(),
        'action': 'b_insert_bill_products',
      };

      final response = await http.post(
        Uri.parse(ApiUrl.script),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      // 🔥 PRINT RAW ORDER OBJECT
      log("======== ORDER OBJECT ========");
      log(order.toString());

      // 🔥 PRINT ORDER JSON
      final orderJson = order.toJson();
      log("======== ORDER JSON ========");
      log(const JsonEncoder.withIndent('  ').convert(orderJson));



      // 🔥 PRINT FULL REQUEST BODY
      log("======== FINAL REQUEST BODY ========");
      log(const JsonEncoder.withIndent('  ').convert(requestBody));


      log("======== RESPONSE STATUS ========");
      log(response.statusCode.toString());

      log("======== RESPONSE BODY ========");
      log(response.body);
      log('placeOrder Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception("Empty response body");
        }

        final data = jsonDecode(response.body);
        return PlacedOrderResponse.fromJson(data);
      } else {
        throw Exception("Server error: ${response.reasonPhrase}");
      }
    } on TimeoutException {
      log("Request timed out!");
      Toasts.showToastBar(context: context, text: 'Request timed out!. Please try again',color: Colors.red);
      throw Exception("Request timed out!");
    } on SocketException {
      log("Network issue!");
      Toasts.showToastBar(context: context, text: 'Network issue!. Please try again',color: Colors.red);
      throw Exception("Network issue!. Please try again");
    } catch (e) {
      log("placeOrder Catch Error: $e");
      throw Exception("placeOrder Catch Error: $e");
    }
  }
  Future<OrdersResponse> getOrderDetails({required String stDate,required String enDate}) async {
    final body = jsonEncode({
      'action'  : 'b_select_order_details',
      'st_date' : stDate,
      'en_date' : enDate
    });

    try {

      final response = await http.post(Uri.parse(ApiUrl.script),body: body);
      return OrdersResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("getCustomers Error : $e");
    }
  }
  Future<OrderStatusResponse> getOnlineOrderDetails({
    required String stDate,
    required String enDate
  }) async {

    final body = jsonEncode({
      'action': 'b_select_online_order_details',
      'st_date': stDate,
      'en_date': enDate
    });

    try {

      final response = await http.post(
        Uri.parse(ApiUrl.script),
        body: body,
      );

      print("online orders ${response.body}");

      final jsonData = jsonDecode(response.body);

      return OrderStatusResponse.fromJson(jsonData);

    } catch (e) {
      throw Exception("getOnlineOrderDetails Error: $e");
    }
  }
  Future<OrdersResponse> getLastOrderDetails() async {
    final body = jsonEncode({
      'action': 'b_select_last_order',
      'user_id': controllers.storage.read("id")
    });
    try {
      final response = await http.post(Uri.parse(ApiUrl.script),body: body);
      return OrdersResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("getCustomers Error : $e");
    }
  }
  static Future<List<Category>> getCategories() async {
    final body = jsonEncode({
      "action": "b_select_cat", // 👈 backend action
    });

    try {
      final response = await http.post(
        Uri.parse(ApiUrl.script),
        body: body,
      );

      final decoded = jsonDecode(response.body);

      if (decoded['responseCode'] == 200) {
        final List list = decoded['categories'];
        return list.map((e) => Category.fromJson(e)).toList();
      } else {
        throw Exception(decoded['responseMsg']);
      }
    } catch (e) {
      throw Exception("getCategories Error : $e");
    }
  }

  static Future<bool> insertProduct(Map<String, dynamic> data) async {
    final body = jsonEncode(data);

    try {
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json'
        },
        body: body,
      );

      print("REQUEST BODY: $body");
      print("RESPONSE BODY: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertProduct(data);
        } else {
          controllers.setLogOut();
        }
      }
      final decoded = jsonDecode(response.body);

      // ✅ BACKEND CONFIRMED SUCCESS FLAG
      if (decoded is Map && decoded['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print("Insert Product Exception: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> checkBarcode(
      Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(ApiUrl.script),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }


  Future<Map<String, dynamic>> updateBillStatus(String invoiceNo) async {
    final url = http.post(Uri.parse(ApiUrl.script));

    final response = await http.post(
      Uri.parse(ApiUrl.script),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "invoice_no": invoiceNo,
        "action":"b_bill_status",
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "status": false,
        "message": "Server error: ${response.statusCode}"
      };
    }
  }
  Future<Map<String, dynamic>> updateStock({
    required List<StockProduct> products,
  }) async
  {
    final body = jsonEncode({
      "action": "b_return_quantity",
      "products": products.map((p) => p.toJson()).toList(),
    });

    final response = await http.post(
      Uri.parse(ApiUrl.script),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      print("response1${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to update stock: ${response.statusCode} ${response.body}");
    }
  }
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      print('Sending cancel order request for Order ID: $orderId');

      final response = await http.post(
        Uri.parse(ApiUrl.script),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'action': 'b_cancel_order',
          'order_id': orderId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parsing the response and returning the data
        final responseData = json.decode(response.body);
        print('Order cancellation successful: $responseData');
        return responseData; // Return the response from the API
      } else {
        // Handling non-200 responses
        print('Error in response: ${response.body}');
        return {
          'ResponseCode': '500',
          'ResponseMsg': 'Error updating order status',
        };
      }
    } catch (e) {
      // Catch any exception (network or parsing errors)
      print('Error occurred: $e');
      return {
        'ResponseCode': '500',
        'ResponseMsg': 'Failed to connect to the server: $e',
      };
    }
  }
}
