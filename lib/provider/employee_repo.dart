import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:pss_web/model/customer_response.dart';
import 'package:pss_web/model/delivery_response.dart';
import 'package:pss_web/model/employee_details.dart';
import '../api/api_urls.dart';
import '../data/local.dart';
import '../model/common_response.dart';
import '../model/role_details.dart';


class EmployeeRepository {
  ///Vendor Fetch Data
  Future<RoleData> getRoleData() async {
    try {
      final response = await http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "action" : "p_employee_role_details"
            },
          )
      );
     // log("role: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

       // log("Vendor Repository if $data");

        return RoleData.fromJson(data);
      } else {
        log("Vendor Data Fetch Error");
        throw Exception();
      }
    }
    catch (e) {
      throw Exception(e);
    }
  }
  Future<StaffData> getStaffRoleData() async {
    try {
      final response = await http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "action" : "p_employee_details"
            },
          )
      );
     // log("role: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // log("Vendor Repository if $data");

        return StaffData.fromJson(data);
      } else {
        log("Vendor Data Fetch Error");
        throw Exception();
      }
    }
    catch (e) {
      throw Exception(e);
    }
  }

  Future<CustomerResponse> getCustomerRoleData() async {
    try {
      final response = await http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "action" : "p_select_customer"
            },
          )
      );
      //log("role: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // log("Vendor Repository if $data");

        return CustomerResponse.fromJson(data);
      } else {
        log("Vendor Data Fetch Error");
        throw Exception();
      }
    }
    catch (e) {
      throw Exception(e);
    }
  }

  Future<DeliveryDetails> getDeliveryData() async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.script),
        headers: {
          "Content-Type": "application/json", // ✅ Added header
          "Accept": "application/json"
        },
        body: jsonEncode({
          "action": "p_select_delper_details"
        }),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || data.isEmpty) {
          log("Vendor Repository: Empty response body");
          throw Exception("Empty response from server");
        }

        log("Vendor Repository Success: $data");

        // ✅ Return the parsed data
        return DeliveryDetails.fromJson(data);
      } else {
        log("Vendor Data Fetch Error: ${response.statusCode}");
        throw Exception("Failed to fetch delivery data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      log("Vendor Repository Exception: $e");
      throw Exception("Error fetching delivery data: $e");
    }
  }


  Future<CommonResponse> insertRole({
    required  roleName,
    required  roleDesc,
    required  active,
    })
  async{

    try{
      Uri.parse(ApiUrl.script);

      final response =   await  http.post(

          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "roleName": roleName,
              "roleDesc": roleDesc,
              "active": active,
              "action" : "p_add_role",
              "created_by" : localData.currentUserID
            },
          )
      );

      if(response.statusCode == 200){

        log("Add role Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("role Insert Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> updateRole({
    required  roleName,
    required  roleDesc,
    required  id,
    required  active,
  })
  async{

    try{
      Uri.parse(ApiUrl.script);

      final response =   await  http.post(

          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "roleName": roleName,
              "roleDesc": roleDesc,
              "active": active ?? 1,
              "id": id,
              "action" : "p_update_role",
              "updated_by" : localData.currentUserID
            },
          )
      );

      if(response.statusCode == 200){

     //   log("Add role Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("role Insert Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> insertEmployee({

    required  emp_name,
    required  emp_mobile,
    required  emp_whatsapp,
    required  emp_email,
    required  emp_address,
    required  emp_password,
    required  emp_role,
    required  roles,
    required  emp_join_date,
    required  emp_salary,
    required  emp_bonus,
    required  active,
    })
  async{

    try{
      final response =   await  http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "emp_name":emp_name ,
              "emp_mobile": emp_mobile,
              "emp_whatsapp": emp_whatsapp,
              "emp_email": emp_email,
              "emp_address": emp_address,
              "emp_password": emp_password,
              "emp_role": emp_role,
              "roles": roles,
              "emp_join_date": emp_join_date,
              "emp_salary": emp_salary,
              "emp_bonus": emp_bonus,
              "created_by": localData.currentUserID,
              "active": active,
              "action":"p_add_employee_details"
            },
          )
      );
      // log("Add Employee Repository if ${response.body}");
      // log("Add Employee Repository if ${emp_name}");
      // log("Add Employee Repository if ${emp_mobile}");
      // log("Add Employee Repository if ${emp_whatsapp}");
      // log("Add Employee Repository if ${emp_email}");
      // log("Add Employee Repository if ${emp_address}");
      // log("Add Employee Repository if ${emp_password}");
      // log("Add Employee Repository if ${emp_role}");
      // log("Add Employee Repository if ${emp_salary}");
      // log("Add Employee Repository if ${emp_bonus}");
      // log("Add Employee Repository if ${emp_join_date}");

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

  Future<CommonResponse> updateEmployee({
    required id,
    required  emp_name,
    required  emp_mobile,
    required  emp_whatsapp,
    required  emp_email,
    required  emp_address,
    required  emp_password,
    required  emp_role,
    required  roles,
    required  emp_join_date,
    required  emp_salary,
    required  emp_bonus,
    required  active,
  })
  async{

    try{
      final response =   await  http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "id":id,
              "emp_name":emp_name ,
              "emp_mobile": emp_mobile,
              "emp_whatsapp": emp_whatsapp,
              "emp_email": emp_email,
              "emp_address": emp_address,
              "emp_password": emp_password,
              "emp_role": emp_role,
              "roles": roles,
              "emp_join_date": emp_join_date,
              "emp_salary": emp_salary,
              "emp_bonus": emp_bonus,
              "created_by": localData.currentUserID,
              "active": active,
              "action":"p_update_employee"
            },
          )
      );
      // log("Add Employee Repository if ${response.body}");
      // log("Add Employee Repository if ${emp_name}");
      // log("Add Employee Repository if ${emp_mobile}");
      // log("Add Employee Repository if ${emp_whatsapp}");
      // log("Add Employee Repository if ${emp_email}");
      // log("Add Employee Repository if ${emp_address}");
      // log("Add Employee Repository if ${emp_password}");
      // log("Add Employee Repository if ${emp_role}");
      // log("Add Employee Repository if ${emp_salary}");
      // log("Add Employee Repository if ${emp_bonus}");
      // log("Add Employee Repository if ${emp_join_date}");

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

          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "employee_ids": employeeIds,
              "id": employeeId,
              "action" : "p_delete_employee",
              "updated_by" : localData.currentUserID
            },
          )

      );

      if(response.statusCode == 200){

        // log("delete vendor Repository if ${response.body}");

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

  Future<CommonResponse> roledelete({List<String>? roleIds,String? roleId}) async{

    try{

      log("Single Product Id: $roleId");

      final response =   await  http.post(

          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "role_ids": roleIds,
              "id": roleId,
              "action" : "p_delete_role",
              "updated_by" : localData.currentUserID
            },
          )

      );

      if(response.statusCode == 200){

        log("delete role Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("role Delete Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> insertCustomer({

    required  name,
    required  mobile,
    required  whatsapp,
    required  email,
    required  address,
    required  password,
    required  active,
  })
  async{

    try{
      final response =   await  http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "name":name ,
              "mobile": mobile,
              "whatsapp": whatsapp,
              "email": email,
              "address": address,
              "password":password,
              "created_by": localData.currentUserID,
              "active": active,
              "action":"p_add_customer"
            },
          )
      );
      // log("Add Employee Repository if ${response.body}");
      // log("Add Employee Repository if ${name}");
      // log("Add Employee Repository if ${mobile}");
      // log("Add Employee Repository if ${whatsapp}");
      // log("Add Employee Repository if ${email}");
      // log("Add Employee Repository if ${address}");
      // log("Add Employee Repository if $password}");

      if(response.statusCode == 200){

        log("Add Customer Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("Customer Insert Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> updateCustomer({
    required id,
    required  name,
    required  mobile,
    required  whatsapp,
    required  email,
    required  address,
    required  password,
    required  active,
  })
  async{

    try{
      final response =   await  http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "id":id,
              "name":name ,
              "mobile": mobile,
              "whatsapp": whatsapp,
              "email": email,
              "address": address,
              "password": password,
              "created_by": localData.currentUserID,
              "active": active,
              "action":"p_update_customer"
            },
          )
      );
      // log("Add Employee Repository if ${response.body}");
      // log("Add Employee Repository if ${name}");
      // log("Add Employee Repository if ${mobile}");
      // log("Add Employee Repository if ${whatsapp}");
      // log("Add Employee Repository if ${email}");
      // log("Add Employee Repository if ${address}");
      // log("Add Employee Repository if ${password}");


      if(response.statusCode == 200){

      //  log("Add Customer Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("Customer Insert Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> deleteCustomer({List<String>? customerIds,String? customerId}) async{

    try{

      //log("Single Product Id: $customerId");

      final response =   await  http.post(

          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "customer_ids": customerIds,
              "id": customerId,
              "action" : "p_delete_customer",
              "updated_by" : localData.currentUserID
            },
          )

      );

      if(response.statusCode == 200){

     //   log("delete customerId Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("customerId Delete Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }

  Future<CommonResponse> inserDelivery({

    required  emp_name,
    required  emp_mobile,
    required  emp_whatsapp,
    required  emp_email,
    required  emp_address,
    required  emp_password,
    required  emp_join_date,
    required  emp_salary,
    required  emp_bonus,
    required  active,
  })
  async{

    try{
      final response =   await  http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "emp_name":emp_name ,
              "emp_mobile": emp_mobile,
              "emp_whatsapp": emp_whatsapp,
              "emp_email": emp_email,
              "emp_address": emp_address,
              "emp_password": emp_password,
              "emp_join_date": emp_join_date,
              "emp_salary": emp_salary,
              "emp_bonus": emp_bonus,
              "created_by": localData.currentUserID,
              "active": active,
              "action":"p_add_delper"
            },
          )
      );
      // log("Add Employee Repository if ${response.body}");
      // log("Add Employee Repository if ${emp_name}");
      // log("Add Employee Repository if ${emp_mobile}");
      // log("Add Employee Repository if ${emp_whatsapp}");
      // log("Add Employee Repository if ${emp_email}");
      // log("Add Employee Repository if ${emp_address}");
      // log("Add Employee Repository if ${emp_password}");
      // log("Add Employee Repository if ${emp_salary}");
      // log("Add Employee Repository if ${emp_bonus}");
      // log("Add Employee Repository if ${emp_join_date}");

      if(response.statusCode == 200){

        log("Add Delivery Repository if ${response.body}");

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

  Future<CommonResponse> updateDelivery({
    required id,
    required  emp_name,
    required  emp_mobile,
    required  emp_whatsapp,
    required  emp_email,
    required  emp_address,
    required  emp_password,
    required  emp_join_date,
    required  emp_salary,
    required  emp_bonus,
    required  active,
  })
  async{

    try{
      final response =   await  http.post(
          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "id":id,
              "emp_name":emp_name ,
              "emp_mobile": emp_mobile,
              "emp_whatsapp": emp_whatsapp,
              "emp_email": emp_email,
              "emp_address": emp_address,
              "emp_password": emp_password,
              "emp_join_date": emp_join_date,
              "emp_salary": emp_salary,
              "emp_bonus": emp_bonus,
              "created_by": localData.currentUserID,
              "active": active,
              "action":"p_update_delper"
            },
          )
      );
      // log("Add Employee Repository if ${response.body}");
      // log("Add Employee Repository if ${emp_name}");
      // log("Add Employee Repository if ${emp_mobile}");
      // log("Add Employee Repository if ${emp_whatsapp}");
      // log("Add Employee Repository if ${emp_email}");
      // log("Add Employee Repository if ${emp_address}");
      // log("Add Employee Repository if ${emp_password}");
      //
      // log("Add Employee Repository if ${emp_salary}");
      // log("Add Employee Repository if ${emp_bonus}");
      // log("Add Employee Repository if ${emp_join_date}");

      if(response.statusCode == 200){

       // log("Add Employee Repository if ${response.body}");

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

  Future<CommonResponse> deleteDelivery({List<String>? employeeIds,String? employeeId}) async{

    try{

    //  log("Single Product Id: $employeeId");

      final response =   await  http.post(

          Uri.parse(ApiUrl.script),
          body: jsonEncode(
            {
              "delivery_ids": employeeIds,
              "id": employeeId,
              "action" : "p_delete_delper",
              "updated_by" : localData.currentUserID
            },
          )

      );

      if(response.statusCode == 200){

      //  log("delete delivery Repository if ${response.body}");

        final Map<String,dynamic> data =  jsonDecode(response.body);

        return CommonResponse.fromJson(data);

      }else{
        log("delivery Delete Error");
        throw Exception();
      }
    }
    catch(e){
      throw Exception(e);
    }
  }


}