import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/screens/new_payroll/search_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../billing_utils/sized_box.dart';
import '../../common/constant/api.dart' as assets;
import '../../common/constant/colors_constant.dart';
import '../../components/Customtext.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_textfield.dart';
import '../../components/emp_drop.dart';
import '../../components/month_calender.dart';
import '../../controller/new_payroll_controller.dart';
import '../../models/payroll/monthly_unit_payroll.dart';
import '../../models/payroll/payroll_user_model.dart';
import '../../models/payroll/unit_model.dart';
import '../../services/new_payroll_api_services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column,Row;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AttendanceDuty extends StatefulWidget {
  const AttendanceDuty({super.key});

  @override
  State<AttendanceDuty> createState() => _AttendanceDutyState();
}

class _AttendanceDutyState extends State<AttendanceDuty> {
  var newPyrlServ=NewPayrollApiServices.instance;
  // var salary=0.0;
  // var totalEarning=0.0;
  // var basicCalc=0.0;
  // var daCalc=0.0;
  // var hraCalc=0.0;
  // var esiCalc=0.0;
  // var pfCalc=0.0;
  List<String>? rolesL;
  List<String>? salaryL;
  List<String>? perSalaryL;
  List<String>? totalEarningL;
  List<String>? basicCalcL;
  List<String>? daCalcL;
  List<String>? hraCalcL;
  List<String>? esiCalcL;
  List<String>? pfCalcL;
  List<String>? esiWagesCalcL;
  List<String>? pfWagesCalcL;
  List<String>? workingDaysL;
  List<String>? weekOffL;
  List<String>? monthlyWagesL;
  List<String>? adCL;
  List<String>? bonusCL;
  List<String>? oPCL;

  double earned =0.0;
  double earnedBasic  =0.0;
  double earnedDa  =0.0;
  double earnedHra  =0.0;
  double deduction  =0.0;
  double netSalary  =0.0;
  var totalDuty = 0.0.obs;
  var totalOT = 0.0.obs;
  var totalAdvance = 0.0.obs;
  var totalUniform = 0.0.obs;
  var totalPenalty = 0.0.obs;
  var totalBonus2 = 0.0.obs;
  var totalFood = 0.0.obs;
  var totalDed = 0.0.obs;
  var total = 0.0.obs;

  var totalBasic = 0.0.obs;
  var totalHra = 0.0.obs;
  var totalDa = 0.0.obs;
  var tEsi = 0.0.obs;
  var tPf = 0.0.obs;
  var totalEarned = 0.0.obs;   // Gross Earned before deductions
  var unitId;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pyrlCtr.unitName=null;
      pyrlCtr.empName=null;
      pyrlCtr.duty.clear();
      pyrlCtr.penalty.clear();
      pyrlCtr.advance.clear();
      pyrlCtr.uniform.clear();
      pyrlCtr.total.clear();
      pyrlCtr.users.clear();
      pyrlCtr.start =
      ("01-${(pyrlCtr.selected.month.toString().padLeft(2, "0"))}-${pyrlCtr.selected.year}");
      var ex = pyrlCtr.start.split("-");
      var date = DateTime(int.parse(ex.first), int.parse(ex[1]) + 1,0);
      pyrlCtr.lastDate = date.day;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final activeUsers = pyrlCtr.users.where((u) => u.active != "2").toList();
    var mobileSize= MediaQuery.of(context).size.width*0.95;
    var webSize= MediaQuery.of(context).size.width*0.97;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: colorsConst.backgroundColor,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Obx(()=>Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  30.height,
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        Get.back();
                      }, icon: Icon(Icons.arrow_back)),
                      CustomText(
                        text: "Quotation Details",
                        colors: colorsConst.textColor,
                        size: 20,
                        isBold: true,
                        isCopy: true,
                      ),
                    ],
                  ),
                  10.height,
                  TextButton(
                      onPressed: (){
                        showMonthPicker2(
                          context: context,
                          month: pyrlCtr.month,
                          function: (){
                            if(pyrlCtr.unitName!=null){
                              getPyrlAtt(unitId);
                            }
                          }
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month,color: Colors.blueGrey),10.width,
                          CustomText(text: pyrlCtr.month.value,colors: colorsConst.primary,size:15, isCopy: true,),
                        ],
                      )),
                  10.height,
                  pyrlCtr.getUnits.value == false
                      ? const CircularProgressIndicator()
                      : pyrlCtr.unitList.isEmpty
                      ? const CustomText(text: "No Unit Found", isCopy: true,)
                      : PayrollUnitDropDown(
                    size: kIsWeb?webSize:mobileSize,
                    color: Colors.white,
                    text: "Unit Name",
                    unitList: pyrlCtr.unitList,
                    onChanged: (units? unit) {
                      setState(() {
                        pyrlCtr.unitName = unit;
                        controllers.storage.write("p_unit_id", unit!.id);
                        controllers.storage.write("p_unit_name", unit.unit_name);
                        rolesL = unit.payrollRoleIds;
                        salaryL = unit.payrollSalaries;
                        perSalaryL = unit.payrollPerDay;
                        basicCalcL = unit.payrollBasic;
                        hraCalcL = unit.payrollHra;
                        daCalcL = unit.payrollAllowance;
                        esiCalcL = unit.payrollEsi;
                        pfCalcL = unit.payrollPf;
                        esiWagesCalcL = unit.payrollEsiWages;
                        pfWagesCalcL = unit.payrollPfWages;
                        workingDaysL = unit.payrollWorkingDays;
                        weekOffL = unit.payrollWeekOff;
                        monthlyWagesL = unit.monthlyWages;
                        adCL = unit.payrollAdminCharges;
                        bonusCL = unit.payrollBonus;
                        oPCL = unit.payrollOSalary;
                        unitId=unit.id;
                        getPyrlAtt(unitId);
                      });
                    },),
                  pyrlCtr.getData.value==false?const CircularProgressIndicator():
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          10.height,
                          EmployeeSearchBox(
                            allEmployees: pyrlCtr.allEmpList,
                            onEmployeeSelected: (selectedEmployee) {
                              setState(() {
                                // Save selected employee details
                                controllers.storage.write("p_emp_id", selectedEmployee.id);
                                controllers.storage.write("p_emp_name", selectedEmployee.fName);

                                // Check if employee already exists in the list
                                bool alreadyExists = pyrlCtr.users.any(
                                      (user) => user.empId == selectedEmployee.id.toString(),
                                );

                                if (!alreadyExists) {
                                  // Add to payroll users only if not already in the list
                                  pyrlCtr.users.add(
                                    PayrollUserModel(
                                      empId: selectedEmployee.id.toString(),
                                      name: selectedEmployee.fName.toString(),
                                      code: selectedEmployee.empCode.toString(),
                                      rank: selectedEmployee.roleName.toString(),
                                      duty: TextEditingController(),
                                      ot: TextEditingController(),
                                      advance: TextEditingController(),
                                      penalty: TextEditingController(),
                                      uniform: TextEditingController(),
                                      total: TextEditingController(),
                                      food: TextEditingController(),
                                      bonus2: TextEditingController(),
                                      basic: "",
                                      newE: "1",
                                      da: "",
                                      hra: "",
                                      esi: "",
                                      pf: "",
                                      deduction: TextEditingController(),
                                      netAmount: "",
                                      active: "1",
                                    ),
                                  );
                                } else {
                                  // Optional: Show message or toast
                                  utils.snackBar(context: Get.context!, msg: "${selectedEmployee.fName} already added ",color: Colors.red);
                                }
                              });
                            },
                          ),
                          10.height,
                          if(pyrlCtr.users.isNotEmpty)
                          Obx(() => Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            border: TableBorder.all(color: Colors.grey.shade300),
                            columnWidths: {
                              0: FixedColumnWidth(MediaQuery.of(context).size.width * 0.03),
                              1: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              2: FixedColumnWidth(MediaQuery.of(context).size.width * 0.08),
                              3: FixedColumnWidth(MediaQuery.of(context).size.width * 0.3),
                              4: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              5: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              6: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              7: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              8: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              9: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              10: FixedColumnWidth(MediaQuery.of(context).size.width * 0.06),
                              11: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              12: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                              13: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                            },
                            children: [
                              // Header row
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade200),
                                children: [
                                  textBox("S.No"),
                                  textBox("ID"),
                                  textBox("Rank"),
                                  textBox("Name"),
                                  textBox("Duty"),
                                  textBox("OT"),
                                  textBox("Advance"),
                                  textBox("Uniform"),
                                  textBox("Penalty"),
                                  textBox("Bonus"),
                                  textBox("Food Charges"),
                                  textBox("Total"),
                                  textBox("Deduction"),
                                  textBox("Delete"),
                                ],
                              ),

                              // Data rows
                              ...List.generate(pyrlCtr.users.length, (index) {
                                final user = pyrlCtr.users[index];
                                if (user.active == "2") {
                                  return TableRow(children: [
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                  0.height,
                                ]);
                                }
                                return TableRow(
                                  children: [
                                    valueBox((index + 1).toString()),
                                    valueBox(pyrlCtr.users[index].code.toString()),
                                    valueBox(pyrlCtr.users[index].rank.toString()),
                                    valueBox(pyrlCtr.users[index].name.toString()),
                                    UnderLineTextField(
                                      width: 70,
                                      controller: user.duty,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => calculatePayroll(index),
                                      isRequired: true,
                                    ),
                                    UnderLineTextField(
                                      width: 70,
                                      controller: user.ot,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                      ],
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => user.ot.text.isNotEmpty?calculatePayroll(index):null,
                                    ),
                                    UnderLineTextField(
                                      width: 70,
                                      controller: user.advance,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => calculatePayroll(index),
                                    ),
                                    UnderLineTextField(
                                      width: 70,
                                      controller: user.uniform,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => calculatePayroll(index),
                                    ),
                                    UnderLineTextField(
                                      width: 70,
                                      controller: user.penalty,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => calculatePayroll(index),
                                    ),
                                    UnderLineTextField(
                                      width: 70,
                                      controller: user.bonus2,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => calculatePayroll(index),
                                    ),
                                    UnderLineTextField(
                                      width: 70,
                                      controller: user.food,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => calculatePayroll(index),
                                    ),
                                    valueBox(user.total.text),
                                    valueBox(user.deduction.text),
                                    IconButton(
                                      onPressed: () {
                                        controllers.loginPassword.clear();
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (dialogCtx) {
                                            return Center(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width * 0.80, // FULL dialog width
                                                ),
                                                child: AlertDialog(
                                                  title: const Center(child: CustomText(text: "Verify Password", isCopy: true,)),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      CustomTextField(
                                                        width: double.infinity,
                                                        controller: controllers.loginPassword,
                                                        keyboardType: TextInputType.visiblePassword,
                                                        textInputAction: TextInputAction.done,
                                                        textCapitalization: TextCapitalization.none,
                                                        text: "Password",
                                                      ),
                                                    ],
                                                  ),
                                                  actionsAlignment: MainAxisAlignment.spaceBetween,
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(dialogCtx).pop();
                                                      },
                                                      child: const Text("CANCEL"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        final pass = controllers.loginPassword.text.trim();
                                                        if (pass.isEmpty) {
                                                          utils.snackBar(
                                                            context: context,
                                                            msg: "Please fill password",
                                                            color: Colors.red,
                                                          );
                                                          return;
                                                        }

                                                        final saved = controllers.storage.read("password")?.toString() ?? "";
                                                        if (pass == saved) {
                                                          Navigator.of(dialogCtx).pop();
                                                          setState(() {
                                                            user.active = "2";
                                                            calculatePayroll(index);
                                                          });
                                                        } else {
                                                          utils.snackBar(
                                                            context: context,
                                                            msg: "Incorrect password",
                                                            color: Colors.red,
                                                          );
                                                        }
                                                      },
                                                      child: const Text("VERIFY"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.delete_outline_outlined, color: Colors.red),
                                    )
                                  ],
                                );
                              }),
                              // Totals row
                              TableRow(
                                decoration: BoxDecoration(color: Colors.grey.shade300),
                                children: [
                                  textBox(""),
                                  textBox(""),
                                  textBox(""),
                                  textBox("Total", width: 150),
                                  valueBox(totalDuty.value.toString()),
                                  valueBox(totalOT.value.toString()),
                                  valueBox(totalAdvance.value.toStringAsFixed(2)),
                                  valueBox(totalUniform.value.toStringAsFixed(2)),
                                  valueBox(totalPenalty.value.toStringAsFixed(2)),
                                  valueBox(totalBonus2.value.toStringAsFixed(2)),
                                  valueBox(totalFood.value.toStringAsFixed(2)),
                                  valueBox(totalEarned.value.toStringAsFixed(2)),
                                  valueBox(totalDed.value.toStringAsFixed(2)),
                                  textBox(""),
                                ],
                              ),
                            ],
                          )),
                          20.height,
                          pyrlCtr.users.isNotEmpty?
                          SizedBox(
                            width: kIsWeb?webSize:mobileSize,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomLoadingButton(
                                    controller: pyrlCtr.submit,text: "Save",
                                    callback: (){
                                      if(pyrlCtr.unitName==null){
                                        utils.snackBar(context: Get.context!, msg: "Select Unit name",color: colorsConst.primary);
                                        pyrlCtr.submit.reset();
                                      }else{
                                        checkValue(context);
                                      }
                                    },
                                    isLoading: true, backgroundColor: colorsConst.primary,
                                    radius: 10, width:  kIsWeb?webSize/4:mobileSize),
                                CustomLoadingButton(text: "Excel",isImage: false,
                                    callback: (){
                                      if(pyrlCtr.unitName==null){
                                        utils.snackBar(context: Get.context!, msg: "Select Unit name",color: colorsConst.primary);
                                        pyrlCtr.submit.reset();
                                      }else{
                                        bool hasEmptyDuty = false;
                                        for (var i = 0; i < pyrlCtr.users.length; i++) {
                                          if (pyrlCtr.users[i].duty.text.trim().isEmpty ||
                                              pyrlCtr.users[i].duty.text == "0") {
                                            utils.snackBar(
                                              context: context,
                                              msg: "Fill duty days for ${pyrlCtr.users[i].name}",
                                              color: Colors.red,
                                            );
                                            pyrlCtr.submit.reset();
                                            hasEmptyDuty = true;
                                            break; // exit the loop after first invalid
                                          }
                                        }
                                        if (!hasEmptyDuty) {
                                          generateExcel(pyrlCtr.users);
                                        }
                                      }
                                    },
                                    isLoading: false, backgroundColor: colorsConst.primary,
                                    radius: 5, width:  kIsWeb?webSize/4:mobileSize),
                                CustomLoadingButton(text: "PDF",
                                    callback: (){
                                      if(pyrlCtr.unitName==null){
                                        utils.snackBar(context: Get.context!, msg: "Select Unit name",color: colorsConst.primary);
                                        pyrlCtr.submit.reset();
                                      }else{
                                        bool hasEmptyDuty = false;
                                        for (var i = 0; i < pyrlCtr.users.length; i++) {
                                          if (pyrlCtr.users[i].duty.text.trim().isEmpty ||
                                              pyrlCtr.users[i].duty.text == "0") {
                                            utils.snackBar(
                                              context: context,
                                              msg: "Fill duty days for ${pyrlCtr.users[i].name}",
                                              color: Colors.red,
                                            );
                                            pyrlCtr.submit.reset();
                                            hasEmptyDuty = true;
                                            break; // exit the loop after first invalid
                                          }
                                        }
                                        if (!hasEmptyDuty) {
                                          exportPayrollToPdf(pyrlCtr.users);
                                        }
                                      }
                                    },isImage: false,
                                    isLoading: false, backgroundColor: colorsConst.primary,
                                    radius: 5, width:  kIsWeb?webSize/4:mobileSize),
                              ],
                            ),
                          )
                          :const CustomText(text: "\n\n\n\n\nSelect Employee",colors: Colors.grey,size:15,isBold: true, isCopy: true,),
                          50.height
                        ],
                      ),
                    ),
                  )
                ],
              )),
            ),
          ],
        )
      ),
    );
  }

  Widget textBox(String text, {double? width = 70}){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomText(text: text, isCopy: true,),
    );
  }
  Widget valueBox(String value, {double? width = 90}){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomText(text: value,colors: Colors.grey, isCopy: true,),
    );
  }

  void checkValue(BuildContext context) {
    // Flag to check validation
    bool hasEmptyDuty = false;

    for (var i = 0; i < pyrlCtr.users.length; i++) {
      if (pyrlCtr.users[i].duty.text.trim().isEmpty ||
          pyrlCtr.users[i].duty.text == "0") {
        utils.snackBar(
          context: context,
          msg: "Fill duty days for ${pyrlCtr.users[i].name}",
          color: Colors.red,
        );
        pyrlCtr.submit.reset();
        hasEmptyDuty = true;
        break; // exit the loop after first invalid
      }
    }

    // Only proceed if all duty fields are filled
    if (!hasEmptyDuty) {
      if(pyrlCtr.isStored.value!=""){
        controllers.loginPassword.clear();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80, // FULL dialog width
                ),
                child: AlertDialog(
                  title: const Center(child: CustomText(text: "Verify Password", isCopy: true,)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        width: double.infinity,
                        controller: controllers.loginPassword,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.none,
                        text: "Password",
                      ),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    TextButton(
                      onPressed: () {
                        pyrlCtr.submit.reset();
                        Navigator.of(dialogCtx).pop();
                      },
                      child: const Text("CANCEL"),
                    ),
                    TextButton(
                      onPressed: () {
                        final pass = controllers.loginPassword.text.trim();
                        if (pass.isEmpty) {
                          pyrlCtr.submit.reset();
                          utils.snackBar(
                            context: context,
                            msg: "Please fill password",
                            color: Colors.red,
                          );
                          return;
                        }

                        final saved = controllers.storage.read("password")?.toString() ?? "";
                        if (pass == saved) {
                          Navigator.of(dialogCtx).pop();
                          newPyrlServ.updatePayrollList(context, pyrlCtr.users,pyrlCtr.isStored.value);
                        } else {
                          pyrlCtr.submit.reset();
                          utils.snackBar(
                            context: context,
                            msg: "Incorrect password",
                            color: Colors.red,
                          );
                        }
                      },
                      child: const Text("VERIFY"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }else{
        newPyrlServ.insertPayrollList(context, pyrlCtr.users);
      }
    }
  }

  Future<List<UnitPayroll>> getPyrlAtt(String unitId) async {
    try{
      pyrlCtr.getData.value=false;
      pyrlCtr.isStored.value="";
      pyrlCtr.users.clear();
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
      if (request.statusCode == 200){
        pyrlCtr.unitPayrollList.value=dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
        var idList = pyrlCtr.unitPayrollList[0].empId.toString().split(',');
        var namesList = pyrlCtr.unitPayrollList[0].name.toString().split(',');
        var codeList = pyrlCtr.unitPayrollList[0].empcd.toString().split(',');
        var roleList = pyrlCtr.unitPayrollList[0].roleName.toString().split(',');
        var dutyList = pyrlCtr.unitPayrollList[0].duty.toString().split(',');
        var otList = pyrlCtr.unitPayrollList[0].ot.toString().split(',');
        var basicList = pyrlCtr.unitPayrollList[0].basic.toString().split(',');
        var hraList = pyrlCtr.unitPayrollList[0].hra.toString().split(',');
        var daList = pyrlCtr.unitPayrollList[0].da.toString().split(',');
        var netAmtList = pyrlCtr.unitPayrollList[0].netAmount.toString().split(',');
        var advanceList = pyrlCtr.unitPayrollList[0].advance.toString().split(',');
        var uniformList = pyrlCtr.unitPayrollList[0].uniform.toString().split(',');
        var penaltyList = pyrlCtr.unitPayrollList[0].penalty.toString().split(',');
        var esiList = pyrlCtr.unitPayrollList[0].esi.toString().split(',');
        var pfList = pyrlCtr.unitPayrollList[0].pf.toString().split(',');
        var deductionList = pyrlCtr.unitPayrollList[0].deduction.toString().split(',');
        var totalList = pyrlCtr.unitPayrollList[0].total.toString().split(',');
        for(var i=0;i<idList.length;i++){

          pyrlCtr.users.add(
            PayrollUserModel(
              empId: idList[i].toString(),
              name: namesList[i].toString(),
              code: codeList[i].toString(),
              rank: roleList[i].toString(),
              duty: TextEditingController(text: dutyList[i].toString()),
              ot: TextEditingController(text: parseIntOrZero(otList[i].toString()).toString()),
              advance: TextEditingController(text: parseIntOrZero(advanceList[i].toString()).toString()),
              penalty: TextEditingController(text: parseIntOrZero(penaltyList[i].toString()).toString()),
              uniform: TextEditingController(text: parseIntOrZero(uniformList[i].toString()).toString()),
              total: TextEditingController(text: parseIntOrZero(totalList[i].toString()).toString()),
              food: TextEditingController(text: ""),
              bonus2: TextEditingController(text: ""),
              basic: basicList[i].toString(),
              da: daList[i].toString(),
              hra: hraList[i].toString(),
              esi: esiList[i].toString(),
              pf: pfList[i].toString(),
              deduction: TextEditingController(text: parseIntOrZero(deductionList[i].toString()).toString()),
              netAmount: netAmtList[i].toString(), newE: '0',
            ),
          );
        }
        setState(() {
          totalDuty.value = 0;
          totalOT.value = 0;
          totalAdvance.value = 0;
          totalPenalty.value = 0;
          totalBonus2.value = 0;
          totalFood.value = 0;
          totalDed.value = 0;
          totalUniform.value = 0;
          total.value = 0;   // Net
          totalBasic.value = 0;
          totalHra.value = 0;
          totalDa.value = 0;
          tEsi.value = 0;
          tPf.value = 0;
          totalEarned.value = 0;

          for (var i = 0; i < pyrlCtr.users.length; i++) {
            double duty = parseIntOrZero(pyrlCtr.users[i].duty.text);
            double ot = parseIntOrZero(pyrlCtr.users[i].ot.text);

            totalDuty.value += duty;
            totalOT.value +=ot;
            totalAdvance.value += parseDoubleOrZero(pyrlCtr.users[i].advance.text);
            totalPenalty.value += parseDoubleOrZero(pyrlCtr.users[i].penalty.text);
            totalBonus2.value += parseDoubleOrZero(pyrlCtr.users[i].bonus2.text);
            totalFood.value += parseDoubleOrZero(pyrlCtr.users[i].food.text);
            totalUniform.value += parseDoubleOrZero(pyrlCtr.users[i].uniform.text);
            totalDed.value += parseDoubleOrZero(pyrlCtr.users[i].deduction.text);
            total.value += parseDoubleOrZero(pyrlCtr.users[i].netAmount);

            totalBasic.value += parseDoubleOrZero(pyrlCtr.users[i].basic);
            totalHra.value += parseDoubleOrZero(pyrlCtr.users[i].hra);
            totalDa.value += parseDoubleOrZero(pyrlCtr.users[i].da);
            tEsi.value += parseDoubleOrZero(pyrlCtr.users[i].esi);
            tPf.value += parseDoubleOrZero(pyrlCtr.users[i].pf);
            totalEarned.value += parseDoubleOrZero(pyrlCtr.users[i].total.text);
          }
        });
        pyrlCtr.getData.value=true;
        pyrlCtr.isStored.value=pyrlCtr.unitPayrollList[0].id.toString();
        return dataValue.map((json) => UnitPayroll.fromJson(json)).toList();
      } else {
        pyrlCtr.getData.value=true;
        pyrlCtr.isStored.value="";
        pyrlCtr.unitPayrollList.clear();
        throw Exception('Failed to load album');
      }
    }catch(e){
      pyrlCtr.getData.value=true;
      pyrlCtr.isStored.value="";
      pyrlCtr.unitPayrollList.clear();
      throw Exception('Failed to load album');
    }
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;

    String str = value.toString().trim();

    if (str.isEmpty) return 0;

    return int.tryParse(str) ?? 0;
  }
  double safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v.toString().trim().isEmpty) return 0.0;
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int countSaturdaysAndSundays(String type) {
    // monthYear example: "December 2025"
    List parts = pyrlCtr.month.value.split(" "); // ["December", "2025"]

    String monthName = parts[0];
    int year = int.parse(parts[1]);

    // Convert month name to month number
    int monthNumber = DateFormat("MMMM").parse(monthName).month;

    int saturdays = 0;
    int sundays = 0;

    // Number of days in this month
    int daysInMonth = DateTime(year, monthNumber + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(year, monthNumber, day);

      if (date.weekday == DateTime.saturday) {
        saturdays++;
      } else if (date.weekday == DateTime.sunday) {
        sundays++;
      }
    }
    print("Saturdays: $saturdays, Sundays: $sundays");

    if(type=="1"){
      return sundays; // Sundays
    }else if(type=="2"){
      return saturdays; // Saturday
    }else{
      return sundays+saturdays; // Both
    }
    // return saturdays + sundays;
  }

  // /// OLD CODE
  // void calculatePayroll(int index) {
  //   print("========== DEBUG VALUES ==========");
  //   print("User Index: $index");
  //   print("User Name: ${pyrlCtr.users[index].name}");
  //   print("User Rank: ${pyrlCtr.users[index].rank}");
  //   print("OT: ${pyrlCtr.users[index].ot.text}");
  //   print("====================================");
  //
  //   double salary = 0.0;
  //   double perSalary = 0.0;
  //   double totalEarning = 0.0;
  //   double basicCalc = 0.0;
  //   double daCalc = 0.0;
  //   double hraCalc = 0.0;
  //   double esiCalc = 0.0;
  //   double pfCalc = 0.0;
  //   double esiWagesCalc = 0.0;
  //   double pfWagesCalc = 0.0;
  //   double adCalc = 0.0;
  //   double bonusCalc = 0.0;
  //   double oPCalc = 0.0;
  //   int workingDay = 0;
  //   bool monthlyWage = true;
  //
  //   bool roleFound = false;
  //
  //   // -----------------------------
  //   // SAFE PARSE HELPERS
  //   // -----------------------------
  //
  //   double safeDouble(dynamic v) {
  //     if (v == null) return 0.0;
  //     String s = v.toString().trim();
  //     if (s.isEmpty || s == "null") return 0.0;
  //     return double.tryParse(s) ?? 0.0;
  //   }
  //
  //   int safeInt(dynamic v) {
  //     if (v == null) return 0;
  //     String s = v.toString().trim();
  //     if (s.isEmpty || s == "null") return 0;
  //     return int.tryParse(s) ?? 0;
  //   }
  //
  //   // -----------------------------
  //   // 1. GET ROLE SETTINGS
  //   // -----------------------------
  //   for (var i = 0; i < rolesL!.length; i++) {
  //     if (rolesL![i] == pyrlCtr.users[index].rank) {
  //       monthlyWage = monthlyWagesL?[i]=="0"?false:true;
  //       salary = safeDouble(salaryL?[i]);
  //       perSalary = safeDouble(perSalaryL?[i]);
  //
  //       basicCalc = safeDouble(basicCalcL?[i]);
  //       hraCalc = safeDouble(hraCalcL?[i]);
  //       daCalc = safeDouble(daCalcL?[i]);
  //       esiCalc = safeDouble(esiCalcL?[i]);
  //       esiWagesCalc = safeDouble(esiWagesCalcL?[i]);
  //       pfCalc = safeDouble(pfCalcL?[i]);
  //       pfWagesCalc = safeDouble(pfWagesCalcL?[i]);
  //       adCalc = safeDouble(adCL?[i]);
  //       bonusCalc = safeDouble(bonusCL?[i]);
  //       oPCalc = safeDouble(oPCL?[i]);
  //       if(weekOffL?[i].toString()=="0||0||0"){
  //         workingDay=pyrlCtr.lastDate;
  //       }else if(weekOffL?[i].toString()=="1||1||0"){
  //         workingDay=pyrlCtr.lastDate-countSaturdaysAndSundays("1");
  //       }else if(weekOffL?[i].toString()=="1||0||1"){
  //         workingDay=pyrlCtr.lastDate-countSaturdaysAndSundays("2");
  //       }else{
  //         workingDay=pyrlCtr.lastDate-countSaturdaysAndSundays("3");
  //       }
  //       print("weekOffL?[i].toString()= ${weekOffL?[i].toString()}");
  //       print("workingDay= $workingDay");
  //       pyrlCtr.users[index].salary = salary.toString();
  //
  //       roleFound = true;
  //       break;
  //     }
  //   }
  //
  //   if (!roleFound) {
  //     utils.toast(
  //       context: Get.context!,
  //       text: "No settings found for this role",
  //       color: Colors.red,
  //     );
  //
  //     if (pyrlCtr.users[index].newE == "1") {
  //       setState(() => pyrlCtr.users.removeAt(index));
  //     }
  //     return;
  //   }
  //
  //   // -----------------------------
  //   // 2. DUTY & OT
  //   // -----------------------------
  //   int dutyDays = safeInt(pyrlCtr.users[index].duty.text);
  //   int otDays = safeInt(pyrlCtr.users[index].ot.text);
  //   int totalDutyDays = dutyDays + otDays;
  //
  //   int deductionDuty = dutyDays;
  //
  //   // -----------------------------
  //   // 3. CALCULATE EARNED
  //   // -----------------------------
  //   // String comId = controllers.storage.read("com_id").toString();
  //   // bool isCompanyOne = comId == "1";
  //
  //   double earned = 0.0;
  //   double earnedBasic = 0.0;
  //   double earnedDa = 0.0;
  //   double earnedHra = 0.0;
  //   double totalEsi = 0.0;
  //   double totalPf = 0.0;
  //   double totalEsiW = 0.0;
  //   double totalPfW = 0.0;
  //   double totalad = 0.0;
  //   double totalBonus = 0.0;
  //   double totalOp = 0.0;
  //
  //   if (monthlyWage==true) {
  //     print("oneeee  $workingDay");
  //     print("dutyDays  $dutyDays");
  //     print("totalDutyDays  $totalDutyDays");
  //     // METHOD 1: Individual split
  //     double perDayBasic = basicCalc / workingDay;
  //     double perDayDa = daCalc / workingDay;
  //     double perDayHra = hraCalc / workingDay;
  //
  //     earnedBasic = perDayBasic * totalDutyDays;
  //     earnedDa = perDayDa * totalDutyDays;
  //     earnedHra = perDayHra * totalDutyDays;
  //
  //     earned = earnedBasic + earnedDa + earnedHra;
  //
  //     totalEsi = (esiCalc / workingDay) * deductionDuty;
  //     totalPf = (pfCalc / workingDay) * deductionDuty;
  //     totalEsiW = (esiWagesCalc / workingDay) * deductionDuty;
  //     totalPfW = (pfWagesCalc / workingDay) * deductionDuty;
  //     totalad = adCalc * deductionDuty;
  //     totalBonus = bonusCalc * deductionDuty;
  //     totalOp = oPCalc * deductionDuty;
  //
  //   }
  //   else {
  //     print("twoooo");
  //     totalOp = oPCalc * deductionDuty;
  //     totalBonus = bonusCalc * deductionDuty;
  //     // Correct earned calculation
  //     earned = (totalDutyDays * perSalary)+totalOp+ totalBonus;
  //     print("earned $earned");
  //
  //     // Split for UI display
  //     earnedBasic = earned;
  //     earnedDa = 0;
  //     earnedHra = 0;
  //
  //     totalEsi = esiCalc * deductionDuty;
  //     totalPf = pfCalc * deductionDuty;
  //     totalEsiW = esiWagesCalc * deductionDuty;
  //     totalPfW = pfWagesCalc * deductionDuty;
  //     totalad = adCalc * deductionDuty;
  //
  //
  //     pyrlCtr.users[index].salary = perSalary.toString();
  //   }
  //
  //   // -----------------------------
  //   // 5. OTHER DEDUCTIONS
  //   // -----------------------------
  //   double advance = safeDouble(pyrlCtr.users[index].advance.text);
  //   double uniform = safeDouble(pyrlCtr.users[index].uniform.text);
  //   double penalty = safeDouble(pyrlCtr.users[index].penalty.text);
  //
  //   double deduction = totalEsi + totalPf + advance + uniform + penalty+ totalad;
  //   print("deduction $deduction");
  //
  //   // -----------------------------
  //   // 6. NET SALARY
  //   // -----------------------------
  //   double netSalary = earned - deduction;
  //   print("netSalary $netSalary");
  //
  //   // -----------------------------
  //   // 7. SAVE VALUES
  //   // -----------------------------
  //   pyrlCtr.users[index].basic = earnedBasic.round().toString();
  //   pyrlCtr.users[index].da = earnedDa.round().toString();
  //   pyrlCtr.users[index].hra = earnedHra.round().toString();
  //
  //   pyrlCtr.users[index].esi = totalEsi.round().toString();
  //   pyrlCtr.users[index].pf = totalPf.round().toString();
  //
  //   pyrlCtr.users[index].esiWagesAmt = totalEsiW.round().toString();
  //   pyrlCtr.users[index].pfWagesAmt = totalPfW.round().toString();
  //
  //   pyrlCtr.users[index].total.text = earned.round().toString();
  //   pyrlCtr.users[index].deduction.text = deduction.round().toString();
  //   pyrlCtr.users[index].netAmount = netSalary.round().toString();
  //
  //   // -----------------------------
  //   // 8. RECALCULATE TOTALS
  //   // -----------------------------
  //   setState(() {
  //     totalDuty.value = 0;
  //     totalAdvance.value = 0;
  //     totalPenalty.value = 0;
  //     totalDed.value = 0;
  //     totalUniform.value = 0;
  //     total.value = 0;
  //     totalBasic.value = 0;
  //     totalHra.value = 0;
  //     totalDa.value = 0;
  //     tEsi.value = 0;
  //     tPf.value = 0;
  //     totalEarned.value = 0;
  //
  //     for (var u in pyrlCtr.users) {
  //       if (u.active == "1") {
  //         int duty = safeInt(u.duty.text);
  //         int ot = safeInt(u.ot.text);
  //
  //         totalDuty.value += duty + ot;
  //         totalAdvance.value += safeDouble(u.advance.text);
  //         totalPenalty.value += safeDouble(u.penalty.text);
  //         totalUniform.value += safeDouble(u.uniform.text);
  //         totalDed.value += safeDouble(u.deduction.text);
  //         total.value += safeDouble(u.netAmount);
  //
  //         totalBasic.value += safeDouble(u.basic);
  //         totalHra.value += safeDouble(u.hra);
  //         totalDa.value += safeDouble(u.da);
  //         tEsi.value += safeDouble(u.esi);
  //         tPf.value += safeDouble(u.pf);
  //         totalEarned.value += safeDouble(u.total.text);
  //       }
  //     }
  //   });
  //
  //   log("Payroll calculated for ${pyrlCtr.users[index].name}");
  //   // log("Payroll calculated for ${pyrlCtr.users[index].esiWagesAmt}");
  //   // log("Payroll calculated for ${pyrlCtr.users[index].pfWagesAmt}");
  // }
  /// NEW CODE
  // void calculatePayroll(int index) {
  //   print("========== DEBUG VALUES ==========");
  //   print("User Index: $index");
  //   print("User Name: ${pyrlCtr.users[index].name}");
  //   print("User Rank: ${pyrlCtr.users[index].rank}");
  //   print("Duty: ${pyrlCtr.users[index].duty.text}");
  //   print("OT: ${pyrlCtr.users[index].ot.text}");
  //   print("monthlyWagesL: $monthlyWagesL");
  //   print("====================================");
  //
  //   double salary = 0.0;
  //   double perSalary = 0.0;
  //
  //   double basicCalc = 0.0;
  //   double daCalc = 0.0;
  //   double hraCalc = 0.0;
  //   double esiCalc = 0.0;
  //   double pfCalc = 0.0;
  //   double esiWagesCalc = 0.0;
  //   double pfWagesCalc = 0.0;
  //   double adCalc = 0.0;
  //   double bonusCalc = 0.0;
  //   double oPCalc = 0.0;
  //
  //   int workingDay = 0;
  //   bool monthlyWage = true;
  //   bool roleFound = false;
  //
  //   // ---------------- SAFE PARSE ----------------
  //   double safeDouble(dynamic value) {
  //     if (value == null) return 0.0;
  //
  //     final String v = value.toString().trim();
  //
  //     if (v.isEmpty || v.toLowerCase() == "null") {
  //       return 0.0;
  //     }
  //
  //     return double.tryParse(v) ?? 0.0;
  //   }
  //
  //
  //   // ---------------- ROLE SETTINGS ----------------
  //   for (var i = 0; i < rolesL!.length; i++) {
  //     if (rolesL![i] == pyrlCtr.users[index].rank) {
  //       monthlyWage = monthlyWagesL?[i] == "0" ? false : true;
  //
  //       salary = safeDouble(salaryL?[i]);
  //       perSalary = safeDouble(perSalaryL?[i]);
  //
  //       basicCalc = safeDouble(basicCalcL?[i]);
  //       daCalc = safeDouble(daCalcL?[i]);
  //       hraCalc = safeDouble(hraCalcL?[i]);
  //
  //       esiCalc = safeDouble(esiCalcL?[i]);
  //       pfCalc = safeDouble(pfCalcL?[i]);
  //       esiWagesCalc = safeDouble(esiWagesCalcL?[i]);
  //       pfWagesCalc = safeDouble(pfWagesCalcL?[i]);
  //
  //       adCalc = safeDouble(adCL?[i]);
  //       bonusCalc = safeDouble(bonusCL?[i]);
  //       oPCalc = safeDouble(oPCL?[i]);
  //
  //       if (weekOffL?[i].toString() == "0||0||0") {
  //         workingDay = pyrlCtr.lastDate;
  //       } else if (weekOffL?[i].toString() == "1||1||0") {
  //         workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("1");
  //       } else if (weekOffL?[i].toString() == "1||0||1") {
  //         workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("2");
  //       } else {
  //         workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("3");
  //       }
  //
  //       pyrlCtr.users[index].salary =
  //       monthlyWage ? salary.toString() : perSalary.toString();
  //
  //       roleFound = true;
  //       break;
  //     }
  //   }
  //
  //   if (!roleFound) {
  //     utils.toast(
  //       context: Get.context!,
  //       text: "No settings found for this role",
  //       color: Colors.red,
  //     );
  //
  //     if (pyrlCtr.users[index].newE == "1") {
  //       setState(() => pyrlCtr.users.removeAt(index));
  //     }
  //     return;
  //   }
  //
  //   // ---------------- DUTY & OT ----------------
  //   double dutyDays = safeDouble(pyrlCtr.users[index].duty.text);
  //   double otDays = safeDouble(pyrlCtr.users[index].ot.text);
  //
  //   // ---------------- EARNINGS ----------------
  //   double earned = 0.0;
  //   double earnedBasic = 0.0;
  //   double earnedDa = 0.0;
  //   double earnedHra = 0.0;
  //
  //   double totalEsi = 0.0;
  //   double totalPf = 0.0;
  //   double totalEsiW = 0.0;
  //   double totalPfW = 0.0;
  //   double totalad = 0.0;
  //   double totalBonus = 0.0;
  //   double totalOp = 0.0;
  //
  //   if (monthlyWage) {
  //     print("Monthly WAGE CALCULATION");
  //     double perDayBasic = basicCalc / workingDay;
  //     double perDayDa = daCalc / workingDay;
  //     double perDayHra = hraCalc / workingDay;
  //
  //     // Normal duty
  //     earnedBasic = perDayBasic * dutyDays;
  //     earnedDa = perDayDa * dutyDays;
  //     earnedHra = perDayHra * dutyDays;
  //
  //     // OT (same rate as 1 day)
  //     earnedBasic += perDayBasic * otDays;
  //     earnedDa += perDayDa * otDays;
  //     earnedHra += perDayHra * otDays;
  //
  //     earned = earnedBasic + earnedDa + earnedHra;
  //
  //     // Deductions ONLY for duty
  //     totalEsi = (esiCalc / workingDay) * dutyDays;
  //     totalPf = (pfCalc / workingDay) * dutyDays;
  //     totalEsiW = (esiWagesCalc / workingDay) * dutyDays;
  //     totalPfW = (pfWagesCalc / workingDay) * dutyDays;
  //
  //     totalad = adCalc * dutyDays;
  //     totalBonus = bonusCalc * dutyDays;
  //     totalOp = oPCalc * dutyDays;
  //   } else {
  //     print("DAILY WAGE CALCULATION");
  //
  //     print("perSalary = $perSalary");
  //     print("dutyDays = $dutyDays");
  //     print("otDays = $otDays");
  //
  //     double normalEarned = dutyDays * perSalary;
  //     double otEarned = otDays * perSalary;
  //
  //     print("normalEarned = $normalEarned");
  //     print("otEarned = $otEarned");
  //
  //     totalOp = oPCalc * dutyDays;
  //     totalBonus = bonusCalc * dutyDays;
  //
  //     earned = normalEarned + otEarned + totalOp + totalBonus;
  //
  //     earnedBasic = earned;
  //     earnedDa = 0;
  //     earnedHra = 0;
  //
  //     totalEsi = esiCalc * dutyDays;
  //     totalPf = pfCalc * dutyDays;
  //     totalEsiW = esiWagesCalc * dutyDays;
  //     totalPfW = pfWagesCalc * dutyDays;
  //     totalad = adCalc * dutyDays;
  //
  //     pyrlCtr.users[index].salary = perSalary.toString();
  //   }
  //
  //
  //   // ---------------- OTHER DEDUCTIONS ----------------
  //   double advance = safeDouble(pyrlCtr.users[index].advance.text);
  //   double uniform = safeDouble(pyrlCtr.users[index].uniform.text);
  //   double penalty = safeDouble(pyrlCtr.users[index].penalty.text);
  //   double food = safeDouble(pyrlCtr.users[index].food.text);
  //   double bonus2 = safeDouble(pyrlCtr.users[index].bonus2.text);
  //
  //   double deduction =totalEsi + totalPf + advance + uniform + penalty + totalad+food;
  //
  //   double netSalary = (earned - deduction)+bonus2;
  //
  //   // ---------------- SAVE VALUES ----------------
  //   pyrlCtr.users[index].basic = earnedBasic.round().toString();
  //   pyrlCtr.users[index].da = earnedDa.round().toString();
  //   pyrlCtr.users[index].hra = earnedHra.round().toString();
  //
  //   pyrlCtr.users[index].esi = totalEsi.round().toString();
  //   pyrlCtr.users[index].pf = totalPf.round().toString();
  //
  //   pyrlCtr.users[index].esiWagesAmt = totalEsiW.round().toString();
  //   pyrlCtr.users[index].pfWagesAmt = totalPfW.round().toString();
  //
  //   pyrlCtr.users[index].total.text = earned.round().toString();
  //   pyrlCtr.users[index].deduction.text = deduction.round().toString();
  //   pyrlCtr.users[index].netAmount = netSalary.round().toString();
  //
  //   // ---------------- TOTALS ----------------
  //   setState(() {
  //     totalDuty.value = 0;
  //     totalOT.value = 0;
  //     totalAdvance.value = 0;
  //     totalPenalty.value = 0;
  //     totalBonus2.value = 0;
  //     totalFood.value = 0;
  //     totalUniform.value = 0;
  //     totalDed.value = 0;
  //     total.value = 0;
  //     totalBasic.value = 0;
  //     totalHra.value = 0;
  //     totalDa.value = 0;
  //     tEsi.value = 0;
  //     tPf.value = 0;
  //     totalEarned.value = 0;
  //
  //     for (var u in pyrlCtr.users) {
  //       if (u.active == "1") {
  //         totalDuty.value +=safeDouble(u.duty.text);
  //         totalOT.value +=safeDouble(u.ot.text);
  //         totalAdvance.value += safeDouble(u.advance.text);
  //         totalPenalty.value += safeDouble(u.penalty.text);
  //         totalBonus2.value += safeDouble(u.bonus2.text);
  //         totalFood.value += safeDouble(u.food.text);
  //         totalUniform.value += safeDouble(u.uniform.text);
  //         totalDed.value += safeDouble(u.deduction.text);
  //         total.value += safeDouble(u.netAmount);
  //
  //         totalBasic.value += safeDouble(u.basic);
  //         totalHra.value += safeDouble(u.hra);
  //         totalDa.value += safeDouble(u.da);
  //         tEsi.value += safeDouble(u.esi);
  //         tPf.value += safeDouble(u.pf);
  //         totalEarned.value += safeDouble(u.total.text);
  //       }
  //     }
  //   });
  //
  //   log("Payroll calculated for ${pyrlCtr.users[index].name}");
  // }
///
//   void calculatePayroll(int index) {
//     double safeDouble(dynamic value) {
//       if (value == null) return 0.0;
//       final String v = value.toString().trim();
//       if (v.isEmpty || v.toLowerCase() == "null") return 0.0;
//       return double.tryParse(v) ?? 0.0;
//     }
//
//     double salary = 0.0, perSalary = 0.0;
//     double basicCalc = 0.0, daCalc = 0.0, hraCalc = 0.0;
//     double adCalc = 0.0, bonusCalc = 0.0, oPCalc = 0.0;
//
//     int workingDay = 0;
//     bool monthlyWage = true;
//     bool roleFound = false;
//
//     // -------- ROLE SETTINGS --------
//     for (var i = 0; i < rolesL!.length; i++) {
//       if (rolesL![i] == pyrlCtr.users[index].rank) {
//         monthlyWage = monthlyWagesL?[i] == "0" ? false : true;
//
//         salary = safeDouble(salaryL?[i]);
//         perSalary = safeDouble(perSalaryL?[i]);
//
//         basicCalc = safeDouble(basicCalcL?[i]);
//         daCalc = safeDouble(daCalcL?[i]);
//         hraCalc = safeDouble(hraCalcL?[i]);
//
//         adCalc = safeDouble(adCL?[i]);
//         bonusCalc = safeDouble(bonusCL?[i]);
//         oPCalc = safeDouble(oPCL?[i]);
//
//         if (weekOffL?[i].toString() == "0||0||0") {
//           workingDay = pyrlCtr.lastDate;
//         } else if (weekOffL?[i].toString() == "1||1||0") {
//           workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("1");
//         } else if (weekOffL?[i].toString() == "1||0||1") {
//           workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("2");
//         } else {
//           workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("3");
//         }
//
//         pyrlCtr.users[index].salary =
//         monthlyWage ? salary.toString() : perSalary.toString();
//
//         roleFound = true;
//         break;
//       }
//     }
//
//     if (!roleFound) return;
//
//     double dutyDays = safeDouble(pyrlCtr.users[index].duty.text);
//     double otDays = safeDouble(pyrlCtr.users[index].ot.text);
//
//     double earned = 0.0, earnedBasic = 0.0, earnedDa = 0.0, earnedHra = 0.0;
//     double totalEsi = 0.0, totalPf = 0.0;
//     double totalEsiW = 0.0, totalPfW = 0.0;
//     double totalad = 0.0, totalBonus = 0.0, totalOp = 0.0;
//
//     // ================= MONTHLY =================
//     if (monthlyWage) {
//       double perDayBasic = basicCalc / workingDay;
//       double perDayDa = daCalc / workingDay;
//       double perDayHra = hraCalc / workingDay;
//
//       // Earnings (Duty + OT)
//       earnedBasic = (perDayBasic * dutyDays) + (perDayBasic * otDays);
//       earnedDa = (perDayDa * dutyDays) + (perDayDa * otDays);
//       earnedHra = (perDayHra * dutyDays) + (perDayHra * otDays);
//
//       earned = earnedBasic + earnedDa + earnedHra;
//
//       // -------- PF & ESI SLAB LOGIC --------
//       double slab = (salary <= 15000) ? 6000 : 15000;
//
//       double pfFull = slab * 0.12;
//       double esiFull = slab * 0.0075;
//
//       // ONLY duty days (NO OT)
//       totalPf = (pfFull / workingDay) * dutyDays;
//       totalEsi = (esiFull / workingDay) * dutyDays;
//
//       // Wages
//       totalPfW = (slab / workingDay) * dutyDays;
//       totalEsiW = (slab / workingDay) * dutyDays;
//
//       totalad = adCalc * dutyDays;
//       totalBonus = bonusCalc * dutyDays;
//       totalOp = oPCalc * dutyDays;
//     }
//
//     // ================= DAILY =================
//     else {
//       double normalEarned = dutyDays * perSalary;
//       double otEarned = otDays * perSalary;
//
//       totalOp = oPCalc * dutyDays;
//       totalBonus = bonusCalc * dutyDays;
//
//       earned = normalEarned + otEarned + totalOp + totalBonus;
//
//       earnedBasic = earned;
//
//       totalPf = 0; // optional (you can apply slab here also if needed)
//       totalEsi = 0;
//
//       totalPfW = 0;
//       totalEsiW = 0;
//
//       totalad = adCalc * dutyDays;
//
//       pyrlCtr.users[index].salary = perSalary.toString();
//     }
//
//     // -------- OTHER DEDUCTIONS --------
//     double advance = safeDouble(pyrlCtr.users[index].advance.text);
//     double uniform = safeDouble(pyrlCtr.users[index].uniform.text);
//     double penalty = safeDouble(pyrlCtr.users[index].penalty.text);
//     double food = safeDouble(pyrlCtr.users[index].food.text);
//     double bonus2 = safeDouble(pyrlCtr.users[index].bonus2.text);
//
//     double deduction =
//         totalEsi + totalPf + advance + uniform + penalty + totalad + food;
//
//     double netSalary = (earned - deduction) + bonus2;
//
//     // -------- SAVE --------
//     pyrlCtr.users[index].basic = earnedBasic.round().toString();
//     pyrlCtr.users[index].da = earnedDa.round().toString();
//     pyrlCtr.users[index].hra = earnedHra.round().toString();
//
//     pyrlCtr.users[index].esi = totalEsi.round().toString();
//     pyrlCtr.users[index].pf = totalPf.round().toString();
//
//     pyrlCtr.users[index].esiWagesAmt = totalEsiW.round().toString();
//     pyrlCtr.users[index].pfWagesAmt = totalPfW.round().toString();
//
//     pyrlCtr.users[index].total.text = earned.round().toString();
//     pyrlCtr.users[index].deduction.text = deduction.round().toString();
//     pyrlCtr.users[index].netAmount = netSalary.round().toString();
//   }
  ///Today
  void calculatePayroll(int index) {
    setState(() {
      print("========== START PAYROLL ==========");

      double safeDouble(dynamic value) {
        if (value == null) return 0.0;
        final String v = value.toString().trim();
        if (v.isEmpty || v.toLowerCase() == "null") return 0.0;
        return double.tryParse(v) ?? 0.0;
      }

      print("User: ${pyrlCtr.users[index].name}");
      print("Role: ${pyrlCtr.users[index].rank}");

      double salary = 0.0, perSalary = 0.0;
      double basicCalc = 0.0, daCalc = 0.0, hraCalc = 0.0;
      double adCalc = 0.0, bonusCalc = 0.0, oPCalc = 0.0;

      int workingDay = 0;
      bool monthlyWage = true;
      bool roleFound = false;

      // -------- ROLE SETTINGS --------
      for (var i = 0; i < rolesL!.length; i++) {
        if (rolesL![i] == pyrlCtr.users[index].rank) {

          monthlyWage = monthlyWagesL?[i] == "0" ? false : true;

          salary = safeDouble(salaryL?[i]);
          perSalary = safeDouble(perSalaryL?[i]);

          basicCalc = safeDouble(basicCalcL?[i]);
          daCalc = safeDouble(daCalcL?[i]);
          hraCalc = safeDouble(hraCalcL?[i]);

          adCalc = safeDouble(adCL?[i]);
          bonusCalc = safeDouble(bonusCL?[i]);
          oPCalc = safeDouble(oPCL?[i]);

          print("Salary: $salary");
          print("Per Salary: $perSalary");
          print("Monthly Wage: $monthlyWage");

          if (weekOffL?[i].toString() == "0||0||0") {
            workingDay = pyrlCtr.lastDate;
          } else if (weekOffL?[i].toString() == "1||1||0") {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("1");
          } else if (weekOffL?[i].toString() == "1||0||1") {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("2");
          } else {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("3");
          }

          print("Working Days: $workingDay");

          roleFound = true;
          break;
        }
      }

      if (!roleFound) {
        print("❌ Role not found");
        return;
      }

      double dutyDays = safeDouble(pyrlCtr.users[index].duty.text);
      double otDays = safeDouble(pyrlCtr.users[index].ot.text);

      print("Duty Days: $dutyDays");
      print("OT Days: $otDays");

      double earned = 0.0, earnedBasic = 0.0, earnedDa = 0.0, earnedHra = 0.0;
      double totalEsi = 0.0, totalPf = 0.0;
      double totalEsiW = 0.0, totalPfW = 0.0;
      double totalad = 0.0, totalBonus = 0.0, totalOp = 0.0;

      // ================= MONTHLY =================
      if (monthlyWage) {

        print("------ MONTHLY CALCULATION ------");

        double perDayBasic = basicCalc / workingDay;
        double perDayDa = daCalc / workingDay;
        double perDayHra = hraCalc / workingDay;

        print("Per Day Basic: $perDayBasic");
        print("Per Day DA: $perDayDa");
        print("Per Day HRA: $perDayHra");

        earnedBasic = (perDayBasic * dutyDays) + (perDayBasic * otDays);
        earnedDa = (perDayDa * dutyDays) + (perDayDa * otDays);
        earnedHra = (perDayHra * dutyDays) + (perDayHra * otDays);

        earned = earnedBasic + earnedDa + earnedHra;

        print("Earned Basic: $earnedBasic");
        print("Earned DA: $earnedDa");
        print("Earned HRA: $earnedHra");
        print("Total Earned: $earned");

        // -------- PF & ESI --------
        double slab = (salary <= 15000) ? 6000 : 15000;

        print("------ PF & ESI DEBUG ------");
        print("Salary: $salary");
        print("Selected Slab: $slab");

        double pfFull = slab * 0.12;
        double esiFull = slab * 0.0075;

        print("PF Full: $pfFull");
        print("ESI Full: $esiFull");

        totalPf = (pfFull / workingDay) * dutyDays;
        totalEsi = (esiFull / workingDay) * dutyDays;

        print("PF Per Day: ${pfFull / workingDay}");
        print("ESI Per Day: ${esiFull / workingDay}");

        print("Final PF: $totalPf");
        print("Final ESI: $totalEsi");

        totalPfW = (slab / workingDay) * dutyDays;
        totalEsiW = (slab / workingDay) * dutyDays;

        print("PF Wages: $totalPfW");
        print("ESI Wages: $totalEsiW");

        totalad = adCalc * dutyDays;
        totalBonus = bonusCalc * dutyDays;
        totalOp = oPCalc * dutyDays;
      }

      // ================= DAILY =================
      else {

        print("------ DAILY CALCULATION ------");

        double normalEarned = dutyDays * perSalary;
        double otEarned = otDays * perSalary;

        print("Normal Earned: $normalEarned");
        print("OT Earned: $otEarned");

        totalOp = oPCalc * dutyDays;
        totalBonus = bonusCalc * dutyDays;

        earned = normalEarned + otEarned + totalOp + totalBonus;

        print("Total Earned: $earned");

        earnedBasic = earned;

        totalPf = 0;
        totalEsi = 0;

        totalPfW = 0;
        totalEsiW = 0;

        totalad = adCalc * dutyDays;
      }

      // -------- OTHER DEDUCTIONS --------
      double advance = safeDouble(pyrlCtr.users[index].advance.text);
      double uniform = safeDouble(pyrlCtr.users[index].uniform.text);
      double penalty = safeDouble(pyrlCtr.users[index].penalty.text);
      double food = safeDouble(pyrlCtr.users[index].food.text);
      double bonus2 = safeDouble(pyrlCtr.users[index].bonus2.text);

      print("Advance: $advance");
      print("Uniform: $uniform");
      print("Penalty: $penalty");
      print("Food: $food");

      double deduction =
          totalEsi + totalPf + advance + uniform + penalty + totalad + food;

      double netSalary = (earned - deduction) + bonus2;

      print("Total Deduction: $deduction");
      print("Net Salary: $netSalary");

      // -------- SAVE --------
      pyrlCtr.users[index].basic = earnedBasic.round().toString();
      pyrlCtr.users[index].da = earnedDa.round().toString();
      pyrlCtr.users[index].hra = earnedHra.round().toString();

      pyrlCtr.users[index].esi = totalEsi.round().toString();
      pyrlCtr.users[index].pf = totalPf.round().toString();

      pyrlCtr.users[index].esiWagesAmt = totalEsiW.round().toString();
      pyrlCtr.users[index].pfWagesAmt = totalPfW.round().toString();

      pyrlCtr.users[index].total.text = earned.round().toString();
      pyrlCtr.users[index].deduction.text = deduction.round().toString();
      pyrlCtr.users[index].netAmount = netSalary.round().toString();

      print("========== END PAYROLL ==========");
    });
  }
  double parseSafeDouble(dynamic val) {
    if (val == null) return 0.0;
    String s = val.toString().trim();
    if (s.isEmpty || s == "null") return 0.0;
    return double.tryParse(s) ?? 0.0;
  }

  int parseSafeInt(dynamic val) {
    if (val == null) return 0;
    String s = val.toString().trim();
    if (s.isEmpty || s == "null") return 0;
    return int.tryParse(s) ?? 0;
  }


  /// Second corrected code
  // void calculatePayroll(int index) {
  //   // try {
  //   print("========== DEBUG VALUES ==========");
  //   print("User Index: $index");
  //   print("User Name: ${pyrlCtr.users[index].name}");
  //   print("User Rank: ${pyrlCtr.users[index].rank}");
  //   print("------------------------------------");
  //
  //   print("User Duty Text       = ${pyrlCtr.users[index].duty.text}");
  //   print("User OT Text         = ${pyrlCtr.users[index].ot.text}");
  //   print("User Advance Text    = ${pyrlCtr.users[index].advance.text}");
  //   print("User Uniform Text    = ${pyrlCtr.users[index].uniform.text}");
  //   print("User Penalty Text    = ${pyrlCtr.users[index].penalty.text}");
  //   print("------------------------------------");
  //
  //   print("====================================");
  //
  //   var salary = 0.0;
  //     var perSalary = 0.0;
  //     var totalEarning = 0.0;
  //     var basicCalc = 0.0;
  //     var daCalc = 0.0;
  //     var hraCalc = 0.0;
  //     var esiCalc = 0.0;
  //     var pfCalc = 0.0;
  //     var workingDay = 0;
  //
  //     bool roleFound = false;
  //
  //     // 1. Role settings
  //     for (var i = 0; i < rolesL!.length; i++) {
  //       print("Role Matched Index: $i");
  //
  //       print("salaryL[i]         = ${salaryL?[i]}");
  //       print("perSalaryL[i]      = ${perSalaryL?[i]}");
  //       print("basicCalcL[i]      = ${basicCalcL?[i]}");
  //       print("hraCalcL[i]        = ${hraCalcL?[i]}");
  //       print("daCalcL[i]         = ${daCalcL?[i]}");
  //       print("esiCalcL[i]        = ${esiCalcL?[i]}");
  //       print("pfCalcL[i]         = ${pfCalcL?[i]}");
  //       print("workingDaysL[i]    = ${workingDaysL?[i]}");
  //
  //       print("------------------------------------");
  //
  //       print("Converted salary     = $salary");
  //       print("Converted perSalary  = $perSalary");
  //       print("basicCalc value      = $basicCalc");
  //       print("hraCalc value        = $hraCalc");
  //       print("daCalc value         = $daCalc");
  //       print("esiCalc value        = $esiCalc");
  //       print("pfCalc value         = $pfCalc");
  //       print("Working Day final    = $workingDay");
  //       print("------------------------------------");
  //       if (rolesL![i] == pyrlCtr.users[index].rank) {
  //         salary = double.parse(salaryL![i].toString());
  //         perSalary = perSalaryL?[i].toString()==""||perSalaryL?[i].toString()=="null"?0.0:double.parse(perSalaryL![i].toString());
  //         pyrlCtr.users[index].salary = salary.toString();
  //
  //         basicCalc = double.parse(basicCalcL![i].toString());
  //         hraCalc = double.parse(hraCalcL![i].toString());
  //         daCalc = double.parse(daCalcL![i].toString());
  //         esiCalc = double.parse(esiCalcL![i].toString());
  //         pfCalc = double.parse(pfCalcL![i].toString());
  //         print("workingDay  $workingDaysL");
  //         workingDay = workingDaysL![i].toString() == "0"
  //             ? int.parse(workingDaysL![i].toString())
  //             : pyrlCtr.lastDate;
  //
  //         roleFound = true;
  //         break;
  //       }
  //     }
  //
  //     if (!roleFound) {
  //       utils.toast(
  //         context: Get.context!,
  //         text: "No settings found for this role",
  //         color: Colors.red,
  //       );
  //
  //       if (pyrlCtr.users[index].newE == "1") {
  //         setState(() {
  //           pyrlCtr.users.removeAt(index);
  //         });
  //       }
  //       return;
  //     }
  //
  //     print("index $index");
  //
  //
  //     // Company check
  //     String comId = controllers.storage.read("com_id").toString();
  //     bool isCompanyOne = comId == "1";
  //
  //     // Duty & OT
  //     int dutyDays = parseIntOrZero(pyrlCtr.users[index].duty.text) +
  //         parseIntOrZero(pyrlCtr.users[index].ot.text);
  //
  //     int deductionDutyDays = parseIntOrZero(pyrlCtr.users[index].duty.text);
  //
  //     double perDayBasic = 0;
  //     double perDayDa = 0;
  //     double perDayHra = 0;
  //     double earnedBasic = 0;
  //     double earnedDa = 0;
  //     double earnedHra = 0;
  //     double earned = 0;
  //
  //     // 2. TWO SALARY METHODS
  //     if (isCompanyOne) {
  //       // 👉 METHOD 1: NORMAL SPLIT METHOD
  //       perDayBasic = basicCalc / workingDay;
  //       perDayDa = daCalc / workingDay;
  //       perDayHra = hraCalc / workingDay;
  //
  //       earnedBasic = perDayBasic * dutyDays;
  //       earnedDa = perDayDa * dutyDays;
  //       earnedHra = perDayHra * dutyDays;
  //
  //       earned = earnedBasic + earnedDa + earnedHra;
  //
  //     } else {
  //       // 👉 METHOD 2: PERSALARY METHOD
  //       double perDaySalary = perSalary / workingDay;
  //       earned = perDaySalary * dutyDays;
  //
  //       // Put entire earned under basic
  //       earnedBasic = earned;
  //       earnedDa = 0;
  //       earnedHra = 0;
  //     }
  //
  //     // 3. ESI & PF
  //     double perDayEsi = esiCalc / workingDay;
  //     double perDayPf = pfCalc / workingDay;
  //
  //     double totalEsi = perDayEsi * deductionDutyDays;
  //     double totalPf = perDayPf * deductionDutyDays;
  //
  //     // 4. Other deductions
  //     double advance = parseDoubleOrZero(pyrlCtr.users[index].advance.text);
  //     double uniform = parseDoubleOrZero(pyrlCtr.users[index].uniform.text);
  //     double penalty = parseDoubleOrZero(pyrlCtr.users[index].penalty.text);
  //
  //     double deduction = totalEsi + totalPf + advance + uniform + penalty;
  //
  //     // 5. Net salary
  //     double netSalary = earned - deduction;
  //
  //     // 6. Save values
  //     pyrlCtr.users[index].basic = earnedBasic.round().toString();
  //     pyrlCtr.users[index].da = earnedDa.round().toString();
  //     pyrlCtr.users[index].hra = earnedHra.round().toString();
  //
  //     pyrlCtr.users[index].esi = totalEsi.round().toString();
  //     pyrlCtr.users[index].pf = totalPf.round().toString();
  //
  //     pyrlCtr.users[index].total.text = earned.round().toString();
  //     pyrlCtr.users[index].deduction.text = deduction.round().toString();
  //     pyrlCtr.users[index].netAmount = netSalary.round().toString();
  //
  //     // 7. Recalculate totals
  //     setState(() {
  //       totalDuty.value = 0;
  //       totalAdvance.value = 0;
  //       totalPenalty.value = 0;
  //       totalDed.value = 0;
  //       totalUniform.value = 0;
  //       total.value = 0;
  //       totalBasic.value = 0;
  //       totalHra.value = 0;
  //       totalDa.value = 0;
  //       tEsi.value = 0;
  //       tPf.value = 0;
  //       totalEarned.value = 0;
  //
  //       for (var i = 0; i < pyrlCtr.users.length; i++) {
  //         if (pyrlCtr.users[i].active == "1") {
  //           int duty = parseIntOrZero(pyrlCtr.users[i].duty.text);
  //           int ot = parseIntOrZero(pyrlCtr.users[i].ot.text);
  //
  //           totalDuty.value += duty + ot;
  //           totalAdvance.value += parseDoubleOrZero(pyrlCtr.users[i].advance.text);
  //           totalPenalty.value += parseDoubleOrZero(pyrlCtr.users[i].penalty.text);
  //           totalUniform.value += parseDoubleOrZero(pyrlCtr.users[i].uniform.text);
  //           totalDed.value += parseDoubleOrZero(pyrlCtr.users[i].deduction.text);
  //           total.value += parseDoubleOrZero(pyrlCtr.users[i].netAmount);
  //
  //           totalBasic.value += parseDoubleOrZero(pyrlCtr.users[i].basic);
  //           totalHra.value += parseDoubleOrZero(pyrlCtr.users[i].hra);
  //           totalDa.value += parseDoubleOrZero(pyrlCtr.users[i].da);
  //           tEsi.value += parseDoubleOrZero(pyrlCtr.users[i].esi);
  //           tPf.value += parseDoubleOrZero(pyrlCtr.users[i].pf);
  //           totalEarned.value += parseDoubleOrZero(pyrlCtr.users[i].total.text);
  //         }
  //       }
  //     });
  //
  //     log(
  //         "Payroll for ${pyrlCtr.users[index].name}: DutyDays=$dutyDays, Earned=$earned, "
  //             "Deduction=$deduction, Net=$netSalary, ESI=$totalEsi, PF=$totalPf");
  //
  //   // } catch (e) {
  //   //   log("Error in calculatePayroll: $e");
  //   // }
  // }

  /// First corrected code
  // void calculatePayroll(int index) {
  //   try {
  //     var salary=0.0;
  //     var perSalary=0.0;
  //     var totalEarning=0.0;
  //     var basicCalc=0.0;
  //     var daCalc=0.0;
  //     var hraCalc=0.0;
  //     var esiCalc=0.0;
  //     var pfCalc=0.0;
  //     var workingDay=0;
  //
  //     // flag to check if role matched
  //     bool roleFound = false;
  //
  //     // loop through roles
  //     for (var i = 0; i < rolesL!.length; i++) {
  //       if (rolesL![i] == pyrlCtr.users[index].rank) {
  //         // Role matched: assign values
  //         salary = double.parse(salaryL![i].toString());
  //         perSalary = double.parse(perSalaryL![i].toString());
  //         pyrlCtr.users[index].salary=salary.toString();
  //         basicCalc = double.parse(basicCalcL![i].toString());
  //         hraCalc = double.parse(hraCalcL![i].toString());
  //         daCalc = double.parse(daCalcL![i].toString());
  //         esiCalc = double.parse(esiCalcL![i].toString());
  //         pfCalc = double.parse(pfCalcL![i].toString());
  //         workingDay = workingDaysL![i].toString()=="0"?int.parse(workingDaysL![i].toString()):pyrlCtr.lastDate;
  //
  //         roleFound = true; // mark match
  //         break; // stop loop after finding match
  //       }
  //     }
  //
  //     // Show toast ONLY if no match found
  //     if (!roleFound) {
  //       utils.toast(
  //         context: Get.context!,
  //         text: "No settings found for this role",
  //         color: Colors.red,
  //       );
  //       if(pyrlCtr.users[index].newE=="1"){
  //         setState(() {
  //           pyrlCtr.users.removeAt(index);
  //         });
  //       }
  //     }
  //
  //
  //
  //     print("index ${index}");
  //     // 1. Per-day salary components
  //     double perDayBasic = basicCalc / workingDay;
  //     double perDayDa = daCalc / workingDay;
  //     double perDayHra = hraCalc / workingDay;
  //
  //     // 2. Duty days + OT
  //     int dutyDays = parseIntOrZero(pyrlCtr.users[index].duty.text) +parseIntOrZero(pyrlCtr.users[index].ot.text);
  //     int dedutionDutyDays = parseIntOrZero(pyrlCtr.users[index].duty.text);
  //
  //     // 3. Earned salary components
  //     double earnedBasic = perDayBasic * dutyDays;
  //     double earnedDa = perDayDa * dutyDays;
  //     double earnedHra = perDayHra * dutyDays;
  //     double earned = earnedBasic + earnedDa + earnedHra;
  //
  //     // 4. ESI & PF scaled by duty days
  //     double perDayEsi = esiCalc / workingDay;
  //     double perDayPf = pfCalc / workingDay;
  //     double totalEsi = perDayEsi * dedutionDutyDays;
  //     double totalPf = perDayPf * dedutionDutyDays;
  //
  //     // 5. Deductions
  //     double advance = parseDoubleOrZero(pyrlCtr.users[index].advance.text);
  //     double uniform = parseDoubleOrZero(pyrlCtr.users[index].uniform.text);
  //     double penalty = parseDoubleOrZero(pyrlCtr.users[index].penalty.text);
  //
  //     double deduction = totalEsi + totalPf + advance + uniform + penalty;
  //
  //     // 6. Net salary
  //     double netSalary = earned - deduction;
  //
  //     // 7. Save back to user model (rounded)
  //     pyrlCtr.users[index].basic = earnedBasic.round().toString();
  //     pyrlCtr.users[index].da = earnedDa.round().toString();
  //     pyrlCtr.users[index].hra = earnedHra.round().toString();
  //     pyrlCtr.users[index].esi = totalEsi.round().toString();
  //     pyrlCtr.users[index].pf = totalPf.round().toString();
  //     pyrlCtr.users[index].total.text = earned.round().toString();
  //     pyrlCtr.users[index].deduction.text = deduction.round().toString();
  //     pyrlCtr.users[index].netAmount = netSalary.round().toString();
  //
  //     // 8. Update totals for UI
  //     setState(() {
  //       totalDuty.value = 0;
  //       totalAdvance.value = 0;
  //       totalPenalty.value = 0;
  //       totalDed.value = 0;
  //       totalUniform.value = 0;
  //       total.value = 0;   // Net
  //       totalBasic.value = 0;
  //       totalHra.value = 0;
  //       totalDa.value = 0;
  //       tEsi.value = 0;
  //       tPf.value = 0;
  //       totalEarned.value = 0;
  //
  //       for (var i = 0; i < pyrlCtr.users.length; i++) {
  //         if(pyrlCtr.users[i].active=="1"){
  //           int duty = parseIntOrZero(pyrlCtr.users[i].duty.text);
  //           int ot = parseIntOrZero(pyrlCtr.users[i].ot.text);
  //
  //           totalDuty.value += duty + ot;
  //           totalAdvance.value += parseDoubleOrZero(pyrlCtr.users[i].advance.text);
  //           totalPenalty.value += parseDoubleOrZero(pyrlCtr.users[i].penalty.text);
  //           totalUniform.value += parseDoubleOrZero(pyrlCtr.users[i].uniform.text);
  //           totalDed.value += parseDoubleOrZero(pyrlCtr.users[i].deduction.text);
  //           total.value += parseDoubleOrZero(pyrlCtr.users[i].netAmount);
  //
  //           totalBasic.value += parseDoubleOrZero(pyrlCtr.users[i].basic);
  //           totalHra.value += parseDoubleOrZero(pyrlCtr.users[i].hra);
  //           totalDa.value += parseDoubleOrZero(pyrlCtr.users[i].da);
  //           tEsi.value += parseDoubleOrZero(pyrlCtr.users[i].esi);
  //           tPf.value += parseDoubleOrZero(pyrlCtr.users[i].pf);
  //           totalEarned.value += parseDoubleOrZero(pyrlCtr.users[i].total.text);
  //         }
  //       }
  //     });
  //
  //     // 9. Debug log
  //     log(
  //         "Payroll for ${pyrlCtr.users[index].name}: DutyDays=$dutyDays, "
  //             "Earned=$earned, Deduction=$deduction, Net=$netSalary, "
  //             "ESI=$totalEsi, PF=$totalPf"
  //     );
  //
  //   } catch (e) {
  //     log("Error in calculatePayroll: $e");
  //   }
  // }

  double parseIntOrZero(String? value) {
    if (value == null || value.trim().isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  double parseDoubleOrZero(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }
  Future<void> exportPayrollToPdf(List<PayrollUserModel> users) async {
    final imageByteData = await rootBundle.load(assets.logo);
    final imageList = imageByteData.buffer
        .asUint8List(imageByteData.offsetInBytes, imageByteData.lengthInBytes);
    final image = pw.MemoryImage(imageList);
    final pdf = pw.Document();

    // Define table headers
    final headers = [
      'S.No',
      'ID',
      'Rank',
      'Name',
      'Duty',
      'OT',
      'Basic',
      'DA',
      'HRA',
      'Earned',
      'Advance',
      'Uniform',
      'Penalty',
      'Bonus',
      'Food Charges',
      'ESI',
      'PF',
      'Deduction',
      'Net Amount'
    ];

    // Build rows
    final data = <List<String>>[];

    for (int i = 0; i < users.length; i++) {
      final u = users[i];
      data.add([
        (i + 1).toString(),
        u.code.toString(),
        u.rank.toString(),
        u.name,
        u.duty.text,
        u.ot.text,
        u.basic,
        u.da,
        u.hra,
        u.total.text,
        u.advance.text,
        u.uniform.text,
        u.penalty.text,
        u.bonus2.text,
        u.food.text,
        u.esi,
        u.pf,
        u.deduction.text,
        u.netAmount,
      ]);
    }

    // Totals row
    data.add([
      "",
      "",
      "",
      "Total",
      users.fold<double>(0, (p, e) => p + (double.tryParse(e.duty.text) ?? 0)).toString(),
      users.fold<double>(0, (p, e) => p + (double.tryParse(e.ot.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.basic) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.da) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.hra) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.total.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.advance.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.uniform.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.penalty.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.bonus2.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.food.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.esi) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.pf) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.deduction.text) ?? 0)).toString(),
      users.fold<int>(0, (p, e) => p + (int.tryParse(e.netAmount) ?? 0)).toString(),
    ]);


    // Add table to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Center(
            child: pw.Text("MUSTER ROLL",
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text("Form No XVI",
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Image(
                image,
                width: 100,
                height: 100,
              ),
              pw.Row(
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Thirumal facilitiies service",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            "Address: 44/1, V.V. Koil Street, Tambaram Sanatorium,\nChennai-600 045, Tamilnadu, India."),
                      ]
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Client Name"),
                        pw.Text("Month")
                      ]
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(" : ${controllers.storage.read("p_unit_name")}"),
                        pw.Text(" : ${pyrlCtr.month.value}")
                      ]
                  )
                ]
              )
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            cellAlignment: pw.Alignment.center,
          )
        ],
      ),
    );

    if (kIsWeb) {
      // Web: just download/share
      await Printing.sharePdf(bytes: await pdf.save(), filename: '${controllers.storage.read("p_unit_name")} Muster Roll - ${pyrlCtr.month.value}.pdf');
    } else {
      // Mobile: save to device
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${controllers.storage.read("p_unit_name")} Muster Roll - ${pyrlCtr.month.value}.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    }

    // // Save to file
    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/payroll_report.pdf');
    // await file.writeAsBytes(await pdf.save());
    //
    // // Open PDF
    // await Printing.sharePdf(bytes: await pdf.save(), filename: 'payroll_report.pdf');
  }

  Future<void> generateExcel(List<PayrollUserModel> users) async {
    // Create a new Excel workbook
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Header row
    final headers = [
      'S.No',
      'ID',
      'Rank',
      'Name',
      'Duty',
      'OT',
      'Advance',
      'Uniform',
      'Penalty',
      'Food Charges',
      'Bonus',
      'Basic',
      'DA',
      'HRA',
      'ESI',
      'PF',
      'Total',
      'Deduction',
      'Net Amount'
    ];
    sheet.getRangeByName("A1").setText("MUSTER ROLL - Form No XVI");
    sheet.getRangeByName('A1:S1').merge();
    sheet.getRangeByName('A2:I2').merge();
    sheet.getRangeByName('J2:S2').merge();
    sheet.getRangeByName("A2:S2").rowHeight = 60;
    sheet.getRangeByName("A2").setText(
        "${controllers.storage.read("com_name")}\n Address : 44/1, V.V. Koil Street, Tambaram Sanatorium,Chennai-600 045,Tamilnadu, India.");
    sheet.getRangeByName("J2").setText(
        "Client Name : ${controllers.storage.read("p_unit_name")}\nMonth : ${pyrlCtr.month.value}");
    sheet.getRangeByName('A1:S1').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A2:S2').cellStyle.hAlign = HAlignType.center;
    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(3, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(3, i + 1).cellStyle.bold = true;
      sheet.getRangeByIndex(3, i + 1).cellStyle.backColor = '#CA1617';
      sheet.getRangeByIndex(3, i + 1).cellStyle.fontColor = '#ffffff';
    }

    // Data rows
    for (int i = 0; i < users.length; i++) {
      final u = users[i];
      sheet.getRangeByIndex(i + 4, 1).setNumber(i + 1); // S.No
      sheet.getRangeByIndex(i + 4, 2).setText(u.code ?? "");
      sheet.getRangeByIndex(i + 4, 3).setText(u.rank ?? "");
      sheet.getRangeByIndex(i + 4, 4).setText(u.name ?? "");
      sheet.getRangeByIndex(i + 4, 5).setText(u.duty.text);
      sheet.getRangeByIndex(i + 4, 6).setText(u.ot.text);
      sheet.getRangeByIndex(i + 4, 7).setText(u.advance.text);
      sheet.getRangeByIndex(i + 4, 8).setText(u.uniform.text);
      sheet.getRangeByIndex(i + 4, 9).setText(u.penalty.text);
      sheet.getRangeByIndex(i + 4, 10).setText(u.food.text);
      sheet.getRangeByIndex(i + 4, 11).setText(u.bonus2.text);
      sheet.getRangeByIndex(i + 4, 12).setText(u.basic ?? "0");
      sheet.getRangeByIndex(i + 4, 13).setText(u.da ?? "0");
      sheet.getRangeByIndex(i + 4, 14).setText(u.hra ?? "0");
      sheet.getRangeByIndex(i + 4, 15).setText(u.esi ?? "0");
      sheet.getRangeByIndex(i + 4, 16).setText(u.pf ?? "0");
      sheet.getRangeByIndex(i + 4, 17).setText(u.total.text);
      sheet.getRangeByIndex(i + 4, 18).setText(u.deduction.text);
      sheet.getRangeByIndex(i + 4, 19).setText(u.netAmount ?? "0");
    }

    // Save as bytes
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', '${controllers.storage.read("p_unit_name")} Muster Roll - ${pyrlCtr.month.value}.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/${controllers.storage.read("p_unit_name")} Muster Roll - ${pyrlCtr.month.value}.xlsx';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }
}
