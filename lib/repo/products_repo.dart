import 'dart:convert';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:http/http.dart' as http;
import '../common/billing_data/api_urls.dart';
import '../common/utilities/jwt_storage.dart';
import '../models/billing_models/products_response.dart';

class ProductsRepository{
  /// Get All Products and Stock
  Future<ProductsResponse> getProducts() async {
    try {
      final Map<String, dynamic> requestBody = {
        "action": "select_products",
      };

      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print("b_select_products");
      print(response.body);
      if (response.statusCode == 200) {
        return ProductsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("getProducts Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("getProducts Error: $e");
    }
  }

  }



