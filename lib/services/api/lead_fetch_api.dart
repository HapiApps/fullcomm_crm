import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/controller/emp_report_controller.dart';
import 'package:fullcomm_crm/models/customer_full_obj.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';

import '../api_services.dart';

extension LeadFetchApi on ApiService {
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
      controllers.isLead.value = true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await allQualifiedDetails();
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
        controllers.disqualifiedFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
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
          return await allLeadsDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allLeadsLength.value = data.length;
        controllers.isLeadsList.value = [];
        for (int i = 0; i < controllers.allLeadsLength.value; i++) {
          controllers.isLeadsList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
            "mail": data[i]["email_id"].toString(),
          });
        }
        controllers.allLeadFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.allLeads.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isLead.value = true;
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.allLeadFuture.value = [];
      controllers.allLeads.value = [];
      throw Exception('Unexpected error lead: ${e.toString()}');
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
          return await allNewLeadsDetails();
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

        controllers.allNewLeadFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
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

  Future<List<NewLeadObj>> allGoodLeadsDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
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
          return await allGoodLeadsDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
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
        controllers.allQualifiedLeadFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
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
          return await allCustomerDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allCustomerLength.value = data.length;
        controllers.isCustomerList.value = [];
        for (int i = 0; i < controllers.allCustomerLength.value; i++) {
          controllers.isCustomerList.add({
            "isSelect": false,
            "lead_id": data[i]["user_id"].toString(),
            "rating": data[i]["rating"].toString(),
            "mail_id": data[i]["email_id"].toString(),
          });
        }
        controllers.allCustomerLeadFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
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
      controllers.isLead.value = true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await allTargetLeadsDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allTargetLength.value = data.length;
        controllers.isTargetLeadList.clear();
        controllers.targetLeadsFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
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
          return await leadsDetails(leadId);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => NewLeadObj.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.isLeadLoading.value = false;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.isLeadLoading.value = false;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.isLeadLoading.value = false;
      throw Exception('Unexpected error lead: ${e.toString()}');
    }
  }

  Future<CustomerFullDetails> leadsDetailsForCustomer(String customerId) async {
    controllers.isLeadLoading.value = true;
    final url = Uri.parse(scriptApi);
    try {
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "customer_id": customerId,
        "action": "lead_details"
      };

      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      debugPrint(response.body);
      controllers.isLeadLoading.value = false;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await leadsDetailsForCustomer(customerId);
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
            throw Exception('Unexpected data payload format');
          }
        } else {
          throw Exception(
              'API error: ${decoded['responseMsg'] ?? response.body}');
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

  Future<void> getCustomLeads({bool showLoader = true}) {
    leadsFuture ??= _fetchCustomLeads(showLoader).whenComplete(() {
      leadsFuture = null;
    });
    return leadsFuture!;
  }

  Future<void> _fetchCustomLeads(bool showLoader) async {
    if (showLoader) {
      controllers.isCrmData.value = false;
    }
    final url = Uri.parse(scriptApi);
    try {
      Map data = {
        "search_type": "all_leads",
        "cos_id": controllers.storage.read("cos_id"),
        "role": controllers.storage.read("role"),
        "id": controllers.storage.read("id"),
        "lead_id": "",
        "action": "get_data"
      };
      debugPrint("All leads data $data");
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
          return await _fetchCustomLeads(showLoader);
        } else {
          controllers.isCrmData.value = true;
          controllers.setLogOut();
          return;
        }
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        debugPrint("allLeadList ${data.length}");
        controllers.allLeadList.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();

        for (var e in controllers.leadCategoryList) {
          e.list.clear();
          e.list2.clear();
        }
        for (int i = 0; i < controllers.leadCategoryList.length; i++) {
          for (int j = 0; j < controllers.allLeadList.length; j++) {
            if (controllers.leadCategoryList[i].leadStatus ==
                controllers.allLeadList[j].leadStatus) {
              controllers.leadCategoryList[i].list
                  .add(controllers.allLeadList[j]);
              controllers.leadCategoryList[i].list2
                  .add(controllers.allLeadList[j]);
            }
          }
        }
        controllers.isCrmData.value = true;
        dashController.getWholeReport();
      } else {
        controllers.allLeadList.clear();
        controllers.isCrmData.value = true;
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.allLeadList.clear();
      controllers.isCrmData.value = true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.allLeadList.clear();
      controllers.isCrmData.value = true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.allLeadList.clear();
      controllers.isCrmData.value = true;
      controllers.newLeadList.clear();
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  void changeList(String leadId) {
    controllers.isLead.value = false;
    controllers.newLeadList.value.clear();
    controllers.searchNewLeadList.value.clear();
    for (var i = 0; i < controllers.allLeadList.length; i++) {
      if (controllers.allLeadList[i].leadStatus == leadId) {
        controllers.newLeadList.value.add(controllers.allLeadList[i]);
      }
    }
    controllers.searchNewLeadList.value = controllers.newLeadList.value;
    controllers.isLead.value = true;
  }

  Future<void> getEmpLeads(String startDate, String endDate) async {
    controllers.isCustomer.value = false;
    controllers.empLeadList.clear();
    controllers.empLeadList2.clear();
    controllers.allCus.value = 0;
    controllers.mainCus.value = 0;
    controllers.pendingCus.value = 0;
    final url = Uri.parse(scriptApi);
    try {
      String from = DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd-MM-yyyy').parse(startDate));
      String to = DateFormat('yyyy-MM-dd')
          .format(DateFormat('dd-MM-yyyy').parse(endDate));
      Map data = {
        "search_type": "emp_leads",
        "cos_id": controllers.storage.read("cos_id"),
        "role": controllers.storage.read("role"),
        "id": repCtr.empId.value,
        "stDate": from,
        "enDate": to,
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
          return await getEmpLeads(startDate, endDate);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.empLeadList.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.empLeadList2.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        for (var i = 0; i < controllers.empLeadList.length; i++) {
          if (controllers.empLeadList[i].category ==
              controllers.leadCategoryList.last.value) {
            controllers.mainCus.value++;
          } else {
            controllers.pendingCus.value++;
          }
          controllers.allCus.value++;
        }
        controllers.isCustomer.value = true;
        dashController.getWholeReport();
      } else {
        controllers.empLeadList.clear();
        controllers.empLeadList2.clear();
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.empLeadList.clear();
      controllers.empLeadList2.clear();
      controllers.isCustomer.value = true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.empLeadList.clear();
      controllers.empLeadList2.clear();
      controllers.isCustomer.value = true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.empLeadList.clear();
      controllers.empLeadList2.clear();
      controllers.isCustomer.value = true;
      throw Exception('Unexpected error: ${e.toString()}');
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
          return await allRatingLeadsDetails(type);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        controllers.allRatingLeadFuture.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
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

  Future<void> getLeadRatingDetails(String type) async {
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
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await getLeadRatingDetails(type);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.ratingList.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.ratingList2.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isCrmData.value = true;
      } else {
        controllers.allLeadList.clear();
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value = true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value = true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value = true;
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future<void> getCustomerRatingDetails(String type) async {
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
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await getCustomerRatingDetails(type);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.ratingList.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.ratingList2.value =
            data.map((json) => NewLeadObj.fromJson(json)).toList();
        controllers.isCrmData.value = true;
      } else {
        controllers.ratingList.clear();
        controllers.ratingList2.clear();
        controllers.isCrmData.value = true;
        throw Exception('Failed to load leads: Status code ${response.body}');
      }
    } on SocketException {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value = true;
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value = true;
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      controllers.ratingList.clear();
      controllers.ratingList2.clear();
      controllers.isCrmData.value = true;
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}