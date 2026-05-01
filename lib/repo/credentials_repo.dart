import 'dart:convert';
import 'dart:developer';
import '../common/billing_data/api_urls.dart';
import '../models/billing_models/user_response.dart';
import 'package:http/http.dart' as http;

class CredentialsRepository {

  /// -------------- User Login ----------------
  Future<UserDataResponse> loginApi({required String mobile, required String password}) async {
    final response = await http.post(
      Uri.parse(ApiUrl.script),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "mobile": mobile,
        "password": password,
        "action": "b_login"
      }),
    );
    if (response.statusCode == 200) {
      return UserDataResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login Error : ${response.body}");
    }
  }

}
