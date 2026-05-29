import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:provider/provider.dart';
import '../common/constant/api.dart';
import '../common/utilities/jwt_storage.dart';
import '../common/utilities/utils.dart';
import '../controller/controller.dart';
import '../controller/new_payroll_controller.dart';
import '../models/payroll/monthly_unit_payroll.dart';
import '../models/payroll/payroll_user_model.dart';
import '../models/payroll/unit_model.dart';
import '../provider/employee_provider.dart';
import '../screens/new_payroll/wages_sheet.dart';

class NewPayrollApiServices{
  /// private constructor
  NewPayrollApiServices._(); // singleton
  /// the one and only instance of this singleton
  static final instance = NewPayrollApiServices._();
  Future addRoleSetting(BuildContext context) async {
    final url = Uri.parse(scriptApi);
    RxList<RolePayrollSetting> sendList=<RolePayrollSetting> [].obs;
    sendList.add(pyrlCtr.settingList[pyrlCtr.editIndex.value]);
    Map data = {
      "action":"add_unit_payroll_setting",
      "created_by":controllers.storage.read("id"),
      "cos_id":controllers.storage.read("cos_id"),
      "settingList":sendList,
    };
    final response = await http.post(
      url,
      // headers: {'Content-Type': 'application/json'},
      headers: {
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // json.decode(request.body);
    print("request.body");
    debugPrint(response.body);
    // unitCtr.submitController.reset();
    if (response.statusCode == 401) {
      final refreshed = await controllers.refreshToken();
      if (refreshed) {
        return addRoleSetting(context);
      } else {
        controllers.setLogOut();
      }
    }
    if (response.statusCode == 200) {
      pyrlCtr.submit.success();
      pyrlCtr.isAdd.value=false;
      utils.snackBar(context: context,msg: "Saved Successfully",color:Colors.green);
    } else {
      utils.snackBar(context: context,msg: "Failed",color: Colors.red);
      pyrlCtr.submit.success();
    }
  }
  Future deleteSetting(BuildContext context) async {
    final url = Uri.parse(scriptApi);
    Map data = {
      "action":"delete_payroll_setting",
      "created_by":controllers.storage.read("id"),
      "cos_id":controllers.storage.read("cos_id"),
      "settingList":pyrlCtr.settingList,
    };
    final response = await http.post(
      url,
      // headers: {'Content-Type': 'application/json'},
      headers: {
        'X-API-TOKEN': "${TokenStorage().readToken()}",
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    // json.decode(request.body);
    print("request.body");
    debugPrint(response.body);
    // unitCtr.submitController.reset();
    if (response.statusCode == 401) {
      final refreshed = await controllers.refreshToken();
      if (refreshed) {
        return addRoleSetting(context);
      } else {
        controllers.setLogOut();
      }
    }
    if (response.statusCode == 200) {
      pyrlCtr.submit.success();
      pyrlCtr.isAdd.value=false;
      pyrlCtr.selectedSettingIds.clear();
      Navigator.pop(context);
      utils.snackBar(context: context,msg: "Deleted Successfully",color:Colors.green);
      getRoleSettings(context);
    } else {
      utils.snackBar(context: context,msg: "Failed",color: Colors.red);
      pyrlCtr.submit.success();
    }
  }
  Future getRoleSettings(context) async {
    try{
      pyrlCtr.getUnits.value=false;
      pyrlCtr.settingList.clear();
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        // "com_id":controllers.storage.read("com_id"),
        "search_type":"get_payroll_setting",
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      final List dataValue= json.decode(request.body);
      debugPrint(data.toString());
      debugPrint(request.body.toString());
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getRoleSettings(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200){
        var unitList =dataValue.map((json) => units.fromJson(json)).toList();
        for(var i=0;i<unitList.length;i++){
          Map<String, dynamic>? match;


          Map<String, dynamic>? match2;
            print("unitList[i].type ${unitList[i].type}");
          if(unitList[i].type=="2"){
            if (unitList[i].roleId != "null") {
              try {
                debugPrint(Provider.of<EmployeeProvider>(context, listen: false).depList.toString());
                match2 = Provider.of<EmployeeProvider>(context, listen: false).depList
                    .firstWhere(
                      (item) => item['id'].toString() == unitList[i].roleId,
                );
              } catch (e) {
                match2 = null;
              }
            }
          }else{
            if (unitList[i].roleId != "null") {
              try {
                debugPrint(settingsController.roleList.toString());
                match = settingsController.roleList
                    .firstWhere(
                      (item) => item.uId.toString() == unitList[i].roleId,
                ) as Map<String, dynamic>?;
              } catch (e) {
                match = null;
              }
            }
          }
          pyrlCtr.settingList.add(RolePayrollSetting(
            id: unitList[i].id.toString(),role: match,
              roleId: unitList[i].type=="1"?unitList[i].roleId:"",
              roleName: unitList[i].type=="1"?unitList[i].roleName:"",
              dName: unitList[i].type=="2"?unitList[i].roleName:"",
              dep: match2,
              dId: unitList[i].type=="2"?unitList[i].roleId:"",

              salary: TextEditingController(text: unitList[i].salary),
              perDay: TextEditingController(text: unitList[i].perDay),
              basic: TextEditingController(text: unitList[i].basicDa),
              hra: TextEditingController(text: unitList[i].hra),
              da: TextEditingController(text: unitList[i].basicDa),
              nH: TextEditingController(text: unitList[i].nHolidays),
              sH: TextEditingController(text: unitList[i].sHolidays),
              oH: TextEditingController(text: unitList[i].oHolidays),
              bonus: TextEditingController(text: unitList[i].bonus),
              esi: TextEditingController(text: unitList[i].esi),
              pf: TextEditingController(text: unitList[i].pf),
              tds: TextEditingController(text: unitList[i].tds),
              pt: TextEditingController(text: unitList[i].pt),
              deduction: TextEditingController(text: unitList[i].deduction),
              totalAmt: TextEditingController(text: unitList[i].totalAmt),
              netPay: TextEditingController(text: unitList[i].netAmt),
              pfWages: TextEditingController(text: unitList[i].pfWages),
              esiWages: TextEditingController(text: unitList[i].esiWages),
              monthlyWages: unitList[i].salary=="0"||unitList[i].salary==""||unitList[i].salary=="null"?false:true
          ));
          pyrlCtr.settingList.sort(
                (a, b) => a.roleName.toString().compareTo(b.roleName.toString()),
          );
        }
        pyrlCtr.getUnits.value=true;
        // return dataValue.map((json) => units.fromJson(json)).toList();
      } else {
        pyrlCtr.getUnits.value=true;
        throw Exception('Failed to load album');
      }
    }catch(e){
      debugPrint(e.toString());
      pyrlCtr.getUnits.value=true;
      throw Exception('Failed to load album');
    }
  }
  Future<void> insertPayrollList(context,List<PayrollUserModel> dataList) async {
    try {
      debugPrint("log");
      debugPrint("print");
      final List<Map<String, dynamic>> empList =
      dataList.map((e) => e.toJson()).toList();
      debugPrint(empList.toString());

      final Map<String, dynamic> sendData = {
        'action': "payroll_user_list",
        'empList': empList,
        'created_by': controllers.storage.read("id"),
        'month': pyrlCtr.month.value,
        "cos_id":controllers.storage.read("cos_id"),
        // "com_id":controllers.storage.read("com_id"),
      };
      debugPrint(sendData.toString());

      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(sendData),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertPayrollList(context,dataList);
        } else {
          controllers.setLogOut();
        }
      }

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
      debugPrint("log");
      debugPrint("print");
      final List<Map<String, dynamic>> empList =
      dataList.map((e) => e.toJson()).toList();
      final Map<String, dynamic> sendData = {
        'action': "update_payroll_user_list",
        'empList': empList,
        'created_by': controllers.storage.read("id"),
        'slip_id': slipId,
        "cos_id":controllers.storage.read("cos_id"),
        // "com_id":controllers.storage.read("com_id"),
      };
      debugPrint(sendData.toString());

      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(sendData),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return updatePayrollList(context,dataList,slipId);
        } else {
          controllers.setLogOut();
        }
      }
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
  Future<List<UnitPayroll>> getUnitPayroll() async {
    try{
      pyrlCtr.getData.value=false;
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        // "com_id":controllers.storage.read("com_id"),
        "search_type":"new_monthly_payroll",
        // "unit_id":unitId,
        "month":pyrlCtr.month.value,
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      final List dataValue= json.decode(request.body);
      pyrlCtr.unitPayrollList2.clear();
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getUnitPayroll();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200){
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList2.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.unitPayrollList2.clear();
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      debugPrint(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      pyrlCtr.unitPayrollList2.clear();
      throw Exception('Failed to load album');
    }
  }
  Future<List<UnitPayroll>> getEsiWages() async {
    try{
      pyrlCtr.getData.value=false;
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        // "com_id":controllers.storage.read("com_id"),
        "search_type":"esi_wages_payroll",
        "month":pyrlCtr.month.value,
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      final List dataValue= json.decode(request.body);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getEsiWages();
        } else {
          controllers.setLogOut();
        }
      }
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
      debugPrint(e.toString());
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
        // "com_id":controllers.storage.read("com_id"),
        "search_type":"pf_wages_payroll",
        "month":pyrlCtr.month.value,
        "role":controllers.storage.read("role"),
        "id":controllers.storage.read("id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      final List dataValue= json.decode(request.body);
      // debugPrint(data);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getPfWages();
        } else {
          controllers.setLogOut();
        }
      }
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
      debugPrint(e.toString());
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
        // "com_id":controllers.storage.read("com_id"),
        "search_type":"payslip_payroll",
        "month":pyrlCtr.month.value,
        "id":id
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      final List dataValue= json.decode(request.body);
      debugPrint(data.toString());
      debugPrint(request.body);
      pyrlCtr.unitPayrollList.clear();
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getPaySlip(id);
        } else {
          controllers.setLogOut();
        }
      }
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
      debugPrint(e.toString());
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
      final List dataValue= json.decode(request.body);
      // debugPrint(data);
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
      debugPrint(e.toString());
      pyrlCtr.getData.value=true;
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
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
    debugPrint(request.body);
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


