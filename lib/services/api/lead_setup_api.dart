import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:fullcomm_crm/controller/table_controller.dart';
import 'package:fullcomm_crm/models/new_lead_obj.dart';
import 'package:fullcomm_crm/models/user_heading_obj.dart';

import '../../models/all_customers_obj.dart';
import '../../models/customer_full_obj.dart';
import '../api_services.dart';

extension LeadSetupApi on ApiService {
  Future updateCategoryAPI(
      BuildContext context, String id, String category) async {
    try {
      Map data = {
        "action": "update_category",
        "category": category,
        "cos_id": controllers.storage.read("cos_id"),
        "id": id,
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
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await updateCategoryAPI(context, id, category);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response["responseMsg"] == "Category updated successfully") {
        await getLeadCategories();
      } else {
        errorDialog(context, request.body);
      }
    } catch (e) {
      errorDialog(context, e.toString());
    }
  }

  Future updateCategories(BuildContext context) async {
    try {
      for (int i = 0; i < controllers.allLeadCategoryList.length; i++) {
        controllers.allLeadCategoryList[i].displayOrder = i + 1;
        int index = controllers.leadCategoryList
            .indexWhere((e) => e.id == controllers.allLeadCategoryList[i].id);

        if (index != -1) {
          controllers.leadCategoryList[index].displayOrder = i + 1;
        }
      }
      controllers.leadCategoryList
          .sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      Map data = {
        "action": "update_lead_details",
        "list": controllers.leadCategoryList.map((e) => e.toJson()).toList(),
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
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updateCategories(context);
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
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getLeadCategories();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.leadCategoryList.value =
            response.map<LeadStatusModel>((item) {
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
        controllers.editMode.value = List.generate(
            controllers.leadCategoryList.length, (index) => false);
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
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await getAllLeadCategories();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
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
        controllers.allLeadCategoryList.value =
            response.map<LeadStatusModel>((item) {
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
          return await getHeading();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.fields.clear();
        controllers.fields.value =
            response.map((e) => CustomerField.fromJson(e)).toList();
        tableController.setHeading(response);
      } else {
        controllers.fields.value = controllers.defaultFields
            .map((e) => CustomerField.fromJson(e))
            .toList();
        tableController.setHeading(controllers.defaultFields);
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.fields.value = controllers.defaultFields
          .map((e) => CustomerField.fromJson(e))
          .toList();
      tableController.setHeading(controllers.defaultFields);
      throw Exception('Failed to load album');
    }
  }

  Future getUserHeading() async {
    try {
      Map data = {
        "search_type": "user_field_head",
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
      debugPrint("Api headings");
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await getUserHeading();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.fields.clear();
        controllers.fields.value =
            response.map((e) => CustomerField.fromJson(e)).toList();
        tableController.setHeadingFields(response);
      } else {
        controllers.fields.value = controllers.defaultFields
            .map((e) => CustomerField.fromJson(e))
            .toList();
        tableController.setHeadingFields(controllers.defaultFields);
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.fields.value = controllers.defaultFields
          .map((e) => CustomerField.fromJson(e))
          .toList();
      tableController.setHeadingFields(controllers.defaultFields);
      throw Exception('Failed to load album');
    }
  }

  Future getCustomFields() async {
    try {
      controllers.getColumn.value = false;
      controllers.addList.clear();
      Map data = {
        "search_type": "custom_fields",
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
          return await getCustomFields();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        final List<dynamic> response = jsonDecode(request.body);
        controllers.addList.value = response
            .map<AdditionalInfo>((e) => AdditionalInfo.fromJson(e))
            .toList();
        controllers.getColumn.value = true;
      } else {
        controllers.getColumn.value = true;
      }
    } catch (e) {
      controllers.getColumn.value = true;
    }
  }
}