import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/jwt_storage.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/dashboard_controller.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/models/company_obj.dart';
import 'package:fullcomm_crm/models/employee_obj.dart';
import 'package:fullcomm_crm/models/month_report_obj.dart';

import '../api_services.dart';

extension MasterApi on ApiService {

  Future getAllCustomers() async {
    try {
      Map data = {
        "search_type": "allCustomers",
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
          return await getAllCustomers();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.customers.clear();
        controllers.customers.value =
            response.map((e) => AllCustomersObj.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future syncContactsToCrm() async {
    try {
      Map data = {
        "cos_id": controllers.storage.read("cos_id"),
        "mobile_number": controllers.storage.read("mobile"),
        "action": "sync_contacts_to_crm"
      };
      debugPrint("Sync Contacts Data: $data");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("syncContactsToCrm");
      debugPrint(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await syncContactsToCrm();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        final res = jsonDecode(request.body);
        final added = int.tryParse("${res['added']}") ?? 0;
        if (added > 0) {
          getCustomLeads(showLoader: false);
        }
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }


  Future getAllEmployees() async {
    try {
      Map data = {
        "search_type": "allEmployees",
        "cos_id": "${int.parse(controllers.storage.read("cos_id"))}",
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
          return await getAllEmployees();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.employees.clear();
        controllers.employees.value =
            response.map((e) => AllEmployeesObj.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future<List<EmployeeObj>> allEmployeeDetails() async {
    final url = Uri.parse(scriptApi);
    controllers.allEmployeeLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "employee",
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await allEmployeeDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allEmployeeLength.value = data.length;
        return data.map((json) => EmployeeObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load employee: Status code ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error employee: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error employee: ${e.toString()}');
    }
  }

  Future<List<CompanyObj>> allCompanyDetails() async {
    controllers.isLead.value = false;
    final url = Uri.parse(scriptApi);
    controllers.allCompanyLength.value = 0;
    try {
      final response = await http.post(
        url,
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "search_type": "company",
          "cos_id": controllers.storage.read("cos_id"),
          "action": "get_data"
        }),
      );
      controllers.isLead.value = true;
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await allCompanyDetails();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        controllers.allCompanyLength.value = data.length;
        return data.map((json) => CompanyObj.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load companies: Status code ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException catch (e) {
      throw Exception('Server error: ${e.toString()}');
    } catch (e) {
      throw Exception('Unexpected error lead: ${e.toString()}');
    }
  }

  Future getRoles() async {
    try {
      Map data = {
        "search_type": "all_roles",
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
          return await getRoles();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        final List data = json.decode(request.body);
        controllers.roleNameList = [];
        for (int i = 0; i < data.length; i++) {
          controllers.roleNameList.add(data[i]["role"]);
        }
        controllers.roleList.value = data;
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future getSheet() async {
    try {
      Map data = {
        "search_type": "sample_sheet",
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
          return await getSheet();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        final List data = json.decode(request.body);
        controllers.serverSheet.value = (data[0]["sheet"]);
      } else {
        controllers.serverSheet.value = "";
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.serverSheet.value = "";
      throw Exception('Failed to load album');
    }
  }

  Future getDashBoardReport() async {
    try {
      Map data = {
        "search_type": "main_report",
        "id": controllers.storage.read("id"),
        "role": controllers.storage.read("role"),
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "date":
        "${DateTime.now().day.toString().padLeft(2, "0")}-${DateTime.now().month.toString().padLeft(2, "0")}-${DateTime.now().year.toString()}"
      };
      debugPrint("main ${data.toString()}");
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("view dashboard report");
      debugPrint(request.body);
      controllers.directVisit.value = "0";
      controllers.telephoneCalls.value = "0";
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await getDashBoardReport();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        for (var i = 0; i < response.length; i++) {
          if (response[i]["type"] == "1") {
            controllers.directVisit.value = response[i]["type_count"];
          } else {
            controllers.telephoneCalls.value = response[i]["type_count"];
          }
        }
      } else {
        controllers.directVisit.value = "0";
        controllers.telephoneCalls.value = "0";
        throw Exception('Failed to load album');
      }
    } catch (e) {
      controllers.directVisit.value = "0";
      controllers.telephoneCalls.value = "0";
      throw Exception('Failed to load album');
    }
  }

  Future getMonthReport() async {
    try {
      Map data = {
        "search_type": "month_report",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "year": "2025"
      };
      debugPrint("main ${data.toString()}");
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
          return await getMonthReport();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        controllers.setData(response);
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future getDayReport(String year, String month) async {
    try {
      Map data = {
        "search_type": "day_report",
        "cos_id": controllers.storage.read("cos_id"),
        "action": "get_data",
        "year": year,
        "month": month
      };
      debugPrint("main day wise ${data.toString()}");
      dashController.dayReport.value = [];
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
          return await getDayReport(year, month);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        dashController.dayReport.value = response
            .map<CustomerDayData>((e) => CustomerDayData.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception('Failed to load album');
    }
  }

  Future crmReminder(BuildContext context) async {
    try {
      Map data = {
        "action": "crm_reminder",
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      debugPrint("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return await crmReminder(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 &&
          response["message"] == "Department added successfully") {
      } else {
        errorDialog(context, request.body);
      }
    } catch (e) {
      errorDialog(context, e.toString());
    }
  }

  Future<void> fetchPinCodeData(String pinCode) async {
    try {
      controllers.selectedCountry.value = "Loading...";

      final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pinCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];

          final district = postOffice['District'] ?? "";
          final state = postOffice['Circle'] ?? "";
          final country = postOffice['Country'] ?? "India";

          controllers.selectedCountry.value = country;
          controllers.stateController.text = state;
          controllers.cityController.text = district;
        } else {
          _resetPinValues();
        }
      } else {
        _resetPinValues();
      }
    } catch (e) {
      _resetPinValues();
    }
  }

  Future<void> fetchPinCodeData2(String pinCode) async {
    try {
      controllers.comCountry.text = "Loading...";

      final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pinCode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];

          final district = postOffice['District'] ?? "";
          final state = postOffice['Circle'] ?? "";
          final country = postOffice['Country'] ?? "India";

          controllers.comCountry.text = country;
          controllers.comState.text = state;
          controllers.comCity.text = district;
        } else {
          _resetPinValues();
        }
      } else {
        _resetPinValues();
      }
    } catch (e) {
      _resetPinValues();
    }
  }

  void _resetPinValues() {
    controllers.selectedCountry.value = "India";
    controllers.stateController.clear();
    controllers.cityController.clear();
  }
}