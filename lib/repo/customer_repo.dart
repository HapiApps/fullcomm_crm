import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/billing_data/api_urls.dart';
import '../controller/controller.dart';
import '../models/billing_models/cashier_details.dart';
import '../models/billing_models/customers_response.dart';
import '../models/billing_models/user_common_response.dart';

class CustomersRepository {
  /// ----------- Get Customer List ---------------
  Future<CustomersResponse> getCustomers() async {
    final body = jsonEncode({
      'action': 'b_select_customers', // Fix
    });
    try {
      final response = await http.post(Uri.parse(ApiUrl.script),body: body);
      return CustomersResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("getCustomers Error : $e");
    }
  }

  /// ------------ Add Customer ---------------
  Future<CommonUserResponse> addCustomer({
    required String name,
    required String mobile,
    required String addressLine1,
    required String area,
    required String pincode,
    required String city,
    required String state,
  })
  async {
    final body = jsonEncode({
      "name": name,
      "mobile": mobile,
      "platform": "3",
      "created_by": controllers.storage.read("id"),
      "address_line_1": addressLine1,
      "area": area,
      'pincode': pincode,
      'city': city,
      'state': state,
      'country': 'India',
      'action': 'b_add_customer', /// Fix
    });

    try {
      final response = await http.post(
          Uri.parse(ApiUrl.script),
          body: body
      );

      return CommonUserResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("addCustomer Error : $e");
    }
  }

  Future<CashierAmountResponse> getCashierAmount({required String createdBy}) async {
    final body = jsonEncode({
      "action":"b_select_cashier_amount",
      "created_by": createdBy
    });

    try {
      final response = await http.post(
        Uri.parse(ApiUrl.script),
        body: body,
      );
      return CashierAmountResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception("getCashierAmount Error : $e");
    }
  }
}


