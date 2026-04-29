import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import '../common/constant/api.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../controller/new_payroll_controller.dart';
import '../models/payroll/monthly_unit_payroll.dart';
import '../models/payroll/payroll_user_model.dart';
import '../models/payroll/unit_model.dart';
import '../screens/new_payroll/wages_sheet.dart';

class NewPayrollApiServices{
  /// private constructor
  NewPayrollApiServices._(); // singleton
  /// the one and only instance of this singleton
  static final instance = NewPayrollApiServices._();

  Future<List<units>> getAllUnits() async {
    try{
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
        "search_type":"payroll_units",
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      final List dataValue= json.decode(request.body);
      // print(data);
      // print(dataValue);
      pyrlCtr.unitList.clear();
      if (request.statusCode == 200){
        pyrlCtr.getUnits.value=true;
        pyrlCtr.unitList.value=dataValue.map((json) => units.fromJson(json)).toList();
        return dataValue.map((json) => units.fromJson(json)).toList();
      } else {
        pyrlCtr.getUnits.value=true;
        pyrlCtr.unitList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      log(e.toString());
      pyrlCtr.getUnits.value=true;
      pyrlCtr.unitList.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<UnitPayroll>> getUnitPayroll(String unitId) async {
    try{
      pyrlCtr.getData.value=false;
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
        "search_type":"new_monthly_payroll",
        "unit_id":unitId,
        "month":pyrlCtr.month.value,
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      final List dataValue= json.decode(request.body);
      // print(data);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 200){
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      log(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<UnitPayroll>> getTeamUnitPayroll(String teamId) async {
    try{
      pyrlCtr.getData.value=false;
      pyrlCtr.unitPayrollList.clear();
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
        "search_type":"team_new_monthly_payroll",
        "team_id":teamId,
        "month":pyrlCtr.month.value,
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      // print(data);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 200){
        final List dataValue= json.decode(request.body);
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      log(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<UnitPayroll>> getEsiWages() async {
    try{
      pyrlCtr.getData.value=false;
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
        "search_type":"esi_wages_payroll",
        "month":pyrlCtr.month.value,
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      final List dataValue= json.decode(request.body);
      // print(data);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 200){
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      log(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<UnitPayroll>> getPfWages() async {
    try{
      pyrlCtr.getData.value=false;
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
        "search_type":"pf_wages_payroll",
        "month":pyrlCtr.month.value,
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      final List dataValue= json.decode(request.body);
      // print(data);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 200){
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      log(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<UnitPayroll>> getPaySlip(String id) async {
    try{
      pyrlCtr.getData.value=false;
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
        "search_type":"payslip_payroll",
        "month":pyrlCtr.month.value,
        "id":id
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      final List dataValue= json.decode(request.body);
      // print(data);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 200){
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      log(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<UnitPayroll>> getSalarySlip(String id) async {
    try{
      pyrlCtr.getData.value=false;
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
        "search_type":"salary_slip_payroll",
        "month":pyrlCtr.month.value,
        "id":id
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      print(data);
      print(request.body);
      final List dataValue= json.decode(request.body);
      // print(data);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 200){
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      log(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<EmployeeModel2>> allEmpList() async {
    pyrlCtr.getData.value=false;
    Map data = {
      "action":"get_data",
      "cos_id":controllers.storage.read("cos_id"),
      "com_id":controllers.storage.read("com_id"),
      "search_type":"payroll_emps",
      "role":controllers.storage.read("role")
    };
    final request = await http.post(Uri.parse(scriptApi),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    print("request.body............");
    print(request.body);
    pyrlCtr.allEmpList.clear();
    if (request.statusCode == 200) {
      final List data= json.decode(request.body);
      pyrlCtr.allEmpList.value=data.map((json) => EmployeeModel2.fromJson(json)).toList();
      pyrlCtr.getData.value=true;
      return data.map((json) => EmployeeModel2.fromJson(json)).toList();
    } else {
      pyrlCtr.allEmpList.clear();
      pyrlCtr.getData.value=true;
      throw Exception('Failed to load album');
    }
  }
  Future<List<EmployeeModel2>> getIDCardNew(String id) async {
    pyrlCtr.getData.value=false;
    Map data = {
      "action":"get_data",
      "cos_id":controllers.storage.read("cos_id"),
      "com_id":controllers.storage.read("com_id"),
      "search_type":"id_emps",
      "id":id
    };
    final request = await http.post(Uri.parse(scriptApi),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    print("request.body............");
    print(request.body);
    pyrlCtr.idEmpList.clear();
    if (request.statusCode == 200) {
      final List data= json.decode(request.body);
      pyrlCtr.idEmpList.value=data.map((json) => EmployeeModel2.fromJson(json)).toList();
      pyrlCtr.getData.value=true;
      return data.map((json) => EmployeeModel2.fromJson(json)).toList();
    } else {
      pyrlCtr.idEmpList.clear();
      pyrlCtr.getData.value=true;
      throw Exception('Failed to load album');
    }
  }

  Future<void> insertPayrollList(context,List<PayrollUserModel> dataList) async {
    try {
      log("log");
      print("print");
      final List<Map<String, dynamic>> empList =
      dataList.map((e) => e.toJson()).toList();
      print(empList.toString());

      final Map<String, dynamic> sendData = {
        'action': "payroll_user_list",
        'empList': empList,
        'created_by': controllers.storage.read("id"),
        'month': pyrlCtr.month.value,
        'unit_id': controllers.storage.read("p_unit_id"),
        'unit_name': controllers.storage.read("p_unit_name"),
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
      };
      log(sendData.toString());

      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(sendData),
          encoding: Encoding.getByName("utf-8"));
      log("response.body");
      log(request.body);
      if (request.statusCode == 200) {
        utils.snackBar(context: context,msg: "Saved Successfully", color: Colors.green);
        pyrlCtr.users.clear();
        pyrlCtr.unitPayrollList.clear();
        Get.to(const UnitSlip(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
        pyrlCtr.submit.reset();
      } else {
        utils.snackBar(context: context,msg:"Failed",color: Colors.red);
        pyrlCtr.submit.reset();
      }
    } catch (e) {
      utils.snackBar(context: context,msg:"Failed",color: Colors.red);
      pyrlCtr.submit.reset();
    }
  }
  Future<void> updatePayrollList(context,List<PayrollUserModel> dataList,String slipId) async {
    try {
      log("log");
      print("print");
      final List<Map<String, dynamic>> empList =
      dataList.map((e) => e.toJson()).toList();
      final Map<String, dynamic> sendData = {
        'action': "update_payroll_user_list",
        'empList': empList,
        'created_by': controllers.storage.read("id"),
        'slip_id': slipId,
        "cos_id":controllers.storage.read("cos_id"),
        "com_id":controllers.storage.read("com_id"),
      };
      log(sendData.toString());

      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(sendData),
          encoding: Encoding.getByName("utf-8"));
      log("response.body");
      log(request.body);
      if (request.statusCode == 200) {
        utils.snackBar(context: context,msg: "Saved Successfully", color: Colors.green);
        pyrlCtr.users.clear();
        pyrlCtr.unitPayrollList.clear();
        Get.to(const UnitSlip(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
        pyrlCtr.submit.reset();
      } else {
        utils.snackBar(context: context,msg:"Failed",color: Colors.red);
        pyrlCtr.submit.reset();
      }
    } catch (e) {
      utils.snackBar(context: context,msg:"Failed",color: Colors.red);
      pyrlCtr.submit.reset();
    }
  }

  Future addDutyDays(BuildContext context,{required String basic,required String da,required String hra,required String dedection,required String netAmt}) async {
    Map data = {
      // "action":insertMonthlyPayroll,
      "emp_id":controllers.storage.read("p_emp_id"),
      "name":controllers.storage.read("p_emp_name"),
      "unit_id":controllers.storage.read("p_unit_id"),
      "unit_name":controllers.storage.read("p_unit_name"),
      "created_by":controllers.storage.read("id"),
      "duty":pyrlCtr.duty.text.trim(),
      "advance":parseDoubleOrZero(pyrlCtr.advance.text.trim()),
      "penalty":parseDoubleOrZero(pyrlCtr.penalty.text.trim()),
      "uniform":parseDoubleOrZero(pyrlCtr.uniform.text.trim()),
      "total":pyrlCtr.total.text.trim(),
      "month":pyrlCtr.month.value,
      "basic":basic,
      "da":da,
      "hra":hra,
      "deduction":dedection,
      "net_amount":netAmt,
    };
    final request = await http.post(Uri.parse(scriptApi),
        headers: {
          "Accept": "application/text",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: jsonEncode(data),
        encoding: Encoding.getByName("utf-8"));
    log(request.body);
    if (request.statusCode == 200) {
      utils.snackBar(context: context,msg: "Saved Successfully", color: Colors.green);
      Get.to(const UnitSlip(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
      pyrlCtr.submit.reset();
    } else {
      utils.snackBar(context: context,msg: "Failed", color: Colors.red);
      pyrlCtr.submit.reset();
    }
  }
  String parseDoubleOrZero(String? value) {
    if (value == null || value.trim().isEmpty) return "0";
    return value;
  }
}


