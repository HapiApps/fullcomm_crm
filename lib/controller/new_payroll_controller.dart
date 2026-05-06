import 'package:flutter/cupertino.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../common/billing_data/local_data.dart';
import '../models/payroll/monthly_unit_payroll.dart';
import '../models/payroll/payroll_user_model.dart';
import '../models/payroll/unit_model.dart';

final pyrlCtr = Get.put(PyrlCtr());

class PyrlCtr extends GetxController {

  RxList<RolePayrollSetting> settingList=<RolePayrollSetting>[].obs;
  void addSetting(){
    if(controllers.storage.read("com_id")=="1"){
      settingList.add(RolePayrollSetting(
          salary: TextEditingController(),
          basic: TextEditingController(),
          hra: TextEditingController(),
          da: TextEditingController(),
          nH: TextEditingController(),
          sH: TextEditingController(),
          oH: TextEditingController(),
          bonus: TextEditingController(),
          esi: TextEditingController(),
          pf: TextEditingController(),
          tds: TextEditingController(),
          pt: TextEditingController(),
          deduction: TextEditingController(),
          totalAmt: TextEditingController(),
          netPay: TextEditingController(),
          pfWages: TextEditingController(),
          esiWages: TextEditingController(),
          monthlyWages: true
      ));
    }else{
      settingList.add(RolePayrollSetting(
          perDay: TextEditingController(),
          leave: TextEditingController(),
          gravity: TextEditingController(),
          adminCharges: TextEditingController(),
          optionSalary: TextEditingController(),
          bonus: TextEditingController(),
          esi: TextEditingController(),
          pf: TextEditingController(),
          tds: TextEditingController(),
          pt: TextEditingController(),
          deduction: TextEditingController(),
          totalAmt: TextEditingController(),
          netPay: TextEditingController(),
          pfWages: TextEditingController(),
          esiWages: TextEditingController(),
          convin: TextEditingController(),
          monthlyWages: false
      ));
    }
  }
  
  
var saveMonth,year,end;
TextEditingController noOfWorkingDay =TextEditingController();
var getUnits=true.obs;
var getData=true.obs;
var isStored="".obs;
var monthCount=0.obs;
var lastDate,start;
DateTime selected = DateTime(DateTime.now().year,DateTime.now().month, DateTime.now().day);
var startDate="".obs,endDate="".obs,month=DateFormat("MMMM yyyy").format(DateTime.now()).obs;
RxList<units> unitList=<units>[].obs;
dynamic unitName,empName;
RxList<UnitPayroll> unitPayrollList=<UnitPayroll>[].obs;
TextEditingController duty=TextEditingController();
TextEditingController advance=TextEditingController();
TextEditingController penalty=TextEditingController();
TextEditingController uniform=TextEditingController();
TextEditingController total=TextEditingController();
RoundedLoadingButtonController submit=RoundedLoadingButtonController();

List<PayrollUserModel> users=<PayrollUserModel>[].obs;

}
