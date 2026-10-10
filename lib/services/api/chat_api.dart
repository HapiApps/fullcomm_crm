import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/models/customer_chat_obj.dart';

import '../api_services.dart';

extension ChatApi on ApiService {
  Future sendWhatAppMessage(BuildContext context, String message, String phone,
      String companyId) async {
    try {
      Map data = {
        "action": "send_whatsapp_message",
        "message": message,
        "phone": phone,
        "company_id": companyId,
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("request $data");
      debugPrint("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return sendWhatAppMessage(context, message, phone, companyId);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Message sent successfully") {
      } else {}
    } catch (e) {
      // apiService.errorDialog(Get.context!,e.toString());
      // controllers.productCtr.reset();
    }
  }

  Future sendInstagramMessage(BuildContext context, String message,
      String recipientId, String companyId) async {
    try {
      Map data = {
        "action": "send_instagram_message",
        "message": message,
        "recipient_id": recipientId,
        "company_id": companyId,
        "cos_id": controllers.storage.read("cos_id"),
        "send_by": controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("request $data");
      debugPrint("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return sendInstagramMessage(context, message, recipientId, companyId);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Message sent successfully") {
      } else {}
    } catch (e) {
      // apiService.errorDialog(Get.context!,e.toString());
      // controllers.productCtr.reset();
    }
  }

  Future getWhatsAppCustomers() async {
    try {
      controllers.whatsAppCustomers.clear();
      controllers.whatsAppCustomers2.clear();
      Map data = {
        "search_type": "whatsapp_customers",
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
      debugPrint("chat_clients");
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getWhatsAppCustomers();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.whatsAppCustomers.value =
            response.map((e) => AllCustomersObj.fromJson(e)).toList();
        controllers.whatsAppCustomers2.value =
            response.map((e) => AllCustomersObj.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future getInstagramCustomers() async {
    try {
      controllers.instagramCustomers.clear();
      controllers.instagramCustomers2.clear();
      Map data = {
        "search_type": "instagram_customers",
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
      debugPrint("insta_clients");
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getInstagramCustomers();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.instagramCustomers.value =
            response.map((e) => AllCustomersObj.fromJson(e)).toList();
        controllers.instagramCustomers2.value =
            response.map((e) => AllCustomersObj.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future<void> getCustomerChats(String id, String metaType) async {
    controllers.chatLoading.value = false;
    controllers.customerChatDetails.clear();
    final url = Uri.parse(scriptApi);
    try {
      Map data = {
        "search_type": "customer_chats",
        "cos_id": controllers.storage.read("cos_id"),
        "id": id,
        "meta_type": metaType,
        "action": "get_data"
      };
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getCustomerChats(id, metaType);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.customerChatDetails.value =
            data.map((json) => ChatModel.fromJson(json)).toList();
        controllers.chatLoading.value = true;
      } else {
        controllers.customerChatDetails.clear();
        controllers.chatLoading.value = true;
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.customerChatDetails.clear();
      controllers.chatLoading.value = true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.customerChatDetails.clear();
      controllers.chatLoading.value = true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.customerChatDetails.clear();
      controllers.chatLoading.value = true;
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}