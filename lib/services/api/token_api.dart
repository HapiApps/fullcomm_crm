import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/controller/controller.dart';

import '../api_services.dart';

extension TokenApi on ApiService {
  Future updateTokenAPI(String token) async {
    try {
      Map data = {
        "action": "update_token",
        "token": token,
        "id": controllers.storage.read("id"),
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
          return updateTokenAPI(token);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        debugPrint("Token updated success");
      } else {
        debugPrint("Token error ${request.body}");
      }
    } catch (e) {
      debugPrint("Token Error $e");
    }
  }
}