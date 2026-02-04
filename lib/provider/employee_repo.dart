import 'dart:convert';
import 'dart:developer';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:http/http.dart' as http;

import '../common/utilities/jwt_storage.dart';
import '../controller/controller.dart';
import '../models/common_response.dart';
import '../models/employee_details.dart';


class EmployeeRepository {
  Future<List<Map<String, dynamic>>> getRole() async {
    try {
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'search_type': "all_roles",
          'action': "get_data",
          "cos_id": controllers.storage.read("cos_id"),
        }),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Map<String, dynamic>> dataMap = jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
        return dataMap;
      } else {
        throw Exception('Failed to load getUser ${response.body}');
      }
    } catch (e) {
      log("Error getUser : $e");
      throw Exception(e);
    }
  }


  Future<StaffData> getStaffRoleData() async {
    try {
      final response = await http.post(
          Uri.parse(scriptApi),
          body: jsonEncode({
              "action" : "p_employee_details",
            "cos_id": controllers.storage.read("cos_id")
            },
          ),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
      );
     // log("role: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return StaffData.fromJson(data);
      } else {
        log("Vendor Data Fetch Error");
        throw Exception();
      }
    }
    catch (e) {
      print("Error getStaffRoleData : $e");
      throw Exception(e);
    }
  }


  Future<CommonResponse> insertEmployee({
    required  empName,
    required empMobile,
    required empWhatsapp,
    required empEmail,
    required empAddress,
    required empPassword,
    required empRole,
    required empJoinDate,
    required empSalary,
    required empBonus,
    required  active,
    })
  async{

    try{
      final response =   await  http.post(
          Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
        body: jsonEncode(
          {
            "emp_name":empName ,
            "emp_mobile": empMobile,
            "emp_whatsapp": empWhatsapp,
            "emp_email": empEmail,
            "emp_address": empAddress,
            "emp_password": empPassword,
            "emp_role": empRole,
            "emp_join_date": empJoinDate,
            "emp_salary": empSalary,
            "emp_bonus": empBonus,
            "created_by": controllers.storage.read("id"),
            "active": active,
            "action":"p_add_employee_details",
            "cos_id": controllers.storage.read("cos_id")
          },
        ),
      );
      // print(response.body);
      if(response.statusCode == 200){
        final Map<String,dynamic> data =  jsonDecode(response.body);
        return CommonResponse.fromJson(data);
      }else{
        log("Employee Insert Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> updateEmployee({
    required id,
    required  empName,
    required  empMobile,
    required  empWhatsapp,
    required  empEmail,
    required  empAddress,
    required  empPassword,
    required  empRole,
    required  empJoinDate,
    required  empSalary,
    required  empBonus,
    required  active,
  })
  async{
    try{
      final response =   await  http.post(
          Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
              "id":id,
              "emp_name":empName ,
              "emp_mobile": empMobile,
              "emp_whatsapp": empWhatsapp,
              "emp_email": empEmail,
              "emp_address": empAddress,
              "emp_password": empPassword,
              "emp_role": empRole,
              "emp_join_date": empJoinDate,
              "emp_salary": empSalary,
              "emp_bonus": empBonus,
              "created_by": controllers.storage.read("id"),
              "active": active,
              "action":"p_update_employee",
              "cos_id": controllers.storage.read("cos_id")
            },
          )
      );

      if(response.statusCode == 200){

        log("Add Employee Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("Employee Insert Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> deleteEmployee({List<String>? employeeIds,String? employeeId}) async{
    try{
      log("Single Product Id: $employeeId");
      final response =   await  http.post(
          Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
              "employee_ids": employeeIds,
              "id": employeeId,
              "action" : "p_delete_employee",
              "updated_by" : controllers.storage.read("id"),
            "cos_id": controllers.storage.read("cos_id")
            },
          )
      );
      if(response.statusCode == 200){
        final Map<String,dynamic> data =  jsonDecode(response.body);
        return CommonResponse.fromJson(data);

      }else{
        log("employeeId Delete Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }
}