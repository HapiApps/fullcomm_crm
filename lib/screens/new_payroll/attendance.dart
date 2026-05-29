import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/screens/new_payroll/search_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../billing_utils/sized_box.dart';
import '../../common/constant/api.dart' as assets;
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/jwt_storage.dart';
import '../../components/Customtext.dart';
import '../../components/action_button.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_textfield.dart';
import '../../components/emp_drop.dart';
import '../../components/keyboard_search.dart';
import '../../components/month_calender.dart';
import '../../controller/new_payroll_controller.dart';
import '../../models/employee_details.dart';
import '../../models/payroll/monthly_unit_payroll.dart';
import '../../models/payroll/payroll_user_model.dart';
import '../../models/payroll/unit_model.dart';
import '../../provider/employee_provider.dart';
import '../../services/new_payroll_api_services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;
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
  // List<String>? rolesL;
  // List<String>? salaryL;
  // List<String>? perSalaryL;
  // List<String>? totalEarningL;
  // List<String>? basicCalcL;
  // List<String>? daCalcL;
  // List<String>? hraCalcL;
  // List<String>? esiCalcL;
  // List<String>? pfCalcL;
  // List<String>? esiWagesCalcL;
  // List<String>? pfWagesCalcL;
  // List<String>? workingDaysL;
  // List<String>? weekOffL;
  // List<String>? monthlyWagesL;
  // List<String>? adCL;
  // List<String>? bonusCL;
  // List<String>? oPCL;
  bool isRole=true;
  bool isDep=false;
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
  var services=NewPayrollApiServices.instance;
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  @override
  void initState() {
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      employeeData.staffRoleDetailsData(context: context);
      services.getRoleSettings(context);
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
      getPyrlAtt();
    });
    super.initState();
  }
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      const double horizontalScrollAmount = 60.0;
      const double verticalScrollAmount = 50.0; // Adjust for row height

      // --- HORIZONTAL SCROLLING ---
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _horizontalController.animateTo(
          (_horizontalController.offset + horizontalScrollAmount).clamp(0.0, _horizontalController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _horizontalController.animateTo(
          (_horizontalController.offset - horizontalScrollAmount).clamp(0.0, _horizontalController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }

      // --- VERTICAL SCROLLING (Add this part) ---
      else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _controller.animateTo(
          (_controller.offset + verticalScrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _controller.animateTo(
          (_controller.offset - verticalScrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final activeUsers = pyrlCtr.users.where((u) => u.active != "2").toList();
    var webSize= MediaQuery.of(context).size.width*0.8;
    return Consumer<EmployeeProvider>(builder: (context, employeeProvider, _) {
      return SelectionArea(
      child: Scaffold(
        backgroundColor: colorsConst.backgroundColor,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  20.height,
                  Row(
                    children: [
                      // IconButton(onPressed: (){
                      //   Get.back();
                      // }, icon: Icon(Icons.arrow_back)),
                      CustomText(
                        text: "Payroll Attendance",
                        colors: colorsConst.textColor,
                        size: 20,
                        isBold: true,
                        isCopy: true,
                      ),
                    ],
                  ),10.height,
                  Divider(
                    thickness: 1.5,
                    color: colorsConst.secondary,
                  ),
                  10.height,
                  pyrlCtr.getData.value==false?const CircularProgressIndicator():
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            10.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                EmpDropdown(
                                  custList: employeeProvider.filteredStaff,
                                  onChanged: (Staff? selectedEmployee) {
                                    // Save selected employee details
                                    controllers.storage.write("p_emp_id", selectedEmployee?.id);
                                    controllers.storage.write("p_emp_name", selectedEmployee?.sName);

                                    // Check if employee already exists in the list
                                    bool alreadyExists = pyrlCtr.users.any(
                                          (user) => user.empId == selectedEmployee?.id.toString(),
                                    );

                                    if (!alreadyExists) {
                                      // Add to payroll users only if not already in the list
                                      pyrlCtr.users.add(
                                        PayrollUserModel(
                                          empId: selectedEmployee!.id.toString(),
                                          name: selectedEmployee.sName.toString(),
                                          rank: selectedEmployee.roleTitle.toString(),
                                          department: selectedEmployee.department.toString(),
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
                                      utils.snackBar(context: Get.context!, msg: "${selectedEmployee?.sName} already added ",color: Colors.red);
                                    }
                                  },),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        const CustomText(text:"Role",colors:Colors.grey,isCopy: false),10.width,
                                        SizedBox(
                                          width: 20,
                                          child: Checkbox(
                                              activeColor:colorsConst.primary,
                                              value: isRole,
                                              onChanged: (value){
                                                setState((){
                                                  isRole=value!;
                                                  if(isRole==true){
                                                    isDep=false;
                                                  }
                                                });
                                              }),
                                        ),
                                      ],
                                    ),
                                    20.width,
                                    Row(
                                      children: [
                                        const CustomText(text:"Department",colors:Colors.grey,isCopy: false),10.width,
                                        SizedBox(
                                          width: 20,
                                          child: Checkbox(
                                              activeColor:colorsConst.primary,
                                              value: isDep,
                                              onChanged: (value){
                                                setState((){
                                                  isDep=value!;
                                                  if(isDep==true){
                                                    isRole=false;
                                                  }
                                                });
                                              }),
                                        ),
                                      ],
                                    ),
                                    20.width,
                                    SizedBox(
                                        height: 35,
                                        child: Obx(()=>ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:colorsConst.secondary,
                                              shadowColor: Colors.transparent,
                                            ),
                                            onPressed: (){
                                              showMonthPicker2(
                                                  context: context,
                                                  month: pyrlCtr.month,
                                                  function: (){
                                                    getPyrlAtt();
                                                  }
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                CustomText(
                                                  text:pyrlCtr.month.value,isCopy: false,colors: Colors.black,
                                                ),
                                                5.width,
                                                const Icon(Icons.calendar_today,
                                                    color: Colors.black, size: 17),
                                                10.width,
                                              ],
                                            )
                                        ),)
                                    ),
                                    Row(
                                      children: [
                                        20.width,
                                        CustomLoadingButton(
                                            height: 45,
                                            controller: pyrlCtr.submit,text: "Save",
                                            callback: (){
                                              checkValue(context);
                                            },
                                            isLoading: true, backgroundColor: colorsConst.primary,
                                            radius: 10, width: 100),
                                        20.width,
                                        CustomLoadingButton(
                                          callback: (){
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
                                          },
                                          isLoading: false,
                                          height: 35,
                                          backgroundColor: Colors.white,
                                          radius: 2,
                                          width: 100,
                                          isImage: false,
                                          text: "Excel",
                                          textColor: colorsConst.primary,
                                        ),
                                        20.width,
                                        CustomLoadingButton(
                                          callback: (){
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
                                          },
                                          isLoading: false,
                                          height: 35,
                                          backgroundColor: Colors.white,
                                          radius: 2,
                                          width: 100,
                                          isImage: false,
                                          text: "PDF",
                                          textColor: colorsConst.primary,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            10.height,
                            if(pyrlCtr.users.isNotEmpty)
                              KeyboardListener(
                                focusNode: _focusNode,
                                autofocus: true,
                                onKeyEvent: _handleKeyEvent,
                                child: Scrollbar(
                                  controller: _horizontalController,
                                  thumbVisibility: true,
                                  child: NotificationListener<ScrollNotification>(
                                    onNotification: (scrollNotification) {
                                      _focusNode.requestFocus();
                                      return false;
                                    },
                                    child: SingleChildScrollView(
                                      controller: _horizontalController,
                                      scrollDirection: Axis.horizontal,
                                      child: Obx(() => Table(
                                        defaultColumnWidth: const IntrinsicColumnWidth(),
                                        border: TableBorder(
                                          horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                          verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                        ),
                                        columnWidths: {
                                          0: FixedColumnWidth(MediaQuery.of(context).size.width * 0.03),
                                          12: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          1: FixedColumnWidth(MediaQuery.of(context).size.width * 0.1),
                                          2: FixedColumnWidth(MediaQuery.of(context).size.width * 0.25),
                                          3: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          4: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          5: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          6: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          7: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          8: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          9: FixedColumnWidth(MediaQuery.of(context).size.width * 0.07),
                                          10: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                          11: FixedColumnWidth(MediaQuery.of(context).size.width * 0.05),
                                        },
                                        children: [
                                          // Header row
                                          TableRow(
                                            decoration: BoxDecoration(
                                                color: colorsConst.primary,
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(5),
                                                    topRight: Radius.circular(5))),
                                            children: [
                                              textBox("S.No"),
                                              textBox("Action"),
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
                                            ],
                                          ),

                                          // Data rows
                                          ...List.generate(pyrlCtr.users.length, (index) {
                                            final user = pyrlCtr.users[index];
                                            if (user.active == "2") {
                                              return TableRow(
                                                  decoration: BoxDecoration(
                                                    color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                  ),
                                                  children: [
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
                                              decoration: BoxDecoration(
                                                color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                              ),
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: valueBox((index + 1).toString()),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: IconButton(
                                                      onPressed: (){
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                content: CustomText(
                                                                  text: "Are you sure delete this user?",
                                                                  size: 16,
                                                                  isCopy: false,
                                                                  isBold: true,
                                                                  colors: colorsConst.textColor,
                                                                ),
                                                                actions: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            border: Border.all(color: colorsConst.primary),
                                                                            color: Colors.white),
                                                                        width: 80,
                                                                        height: 25,
                                                                        child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                              shape: const RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.zero,
                                                                              ),
                                                                              backgroundColor: Colors.white,
                                                                            ),
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child: CustomText(
                                                                              text: "Cancel",
                                                                              isCopy: false,
                                                                              colors: colorsConst.primary,
                                                                              size: 14,
                                                                            )),
                                                                      ),
                                                                      10.width,
                                                                      CustomLoadingButton(
                                                                        callback: (){
                                                                          setState(() {
                                                                            user.active = "2";
                                                                            calculatePayroll(index);
                                                                            Navigator.pop(context);
                                                                          });
                                                                        },
                                                                        height: 35,
                                                                        isLoading: false,
                                                                        backgroundColor: colorsConst.primary,
                                                                        radius: 2,
                                                                        width: 80,
                                                                        isImage: false,
                                                                        text: "Delete",
                                                                        textColor: Colors.white,
                                                                      ),
                                                                      5.width
                                                                    ],
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      icon: SvgPicture.asset("assets/images/a_delete.svg",width: 20,height: 20,)),
                                                ),
                                                valueBox(pyrlCtr.users[index].rank.toString()),
                                                valueBox(pyrlCtr.users[index].name.toString()),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: UnderLineTextField(
                                                    width: 70,
                                                    controller: user.duty,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (_) => calculatePayroll(index),
                                                    isRequired: true,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: UnderLineTextField(
                                                    width: 70,
                                                    controller: user.ot,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                    ],
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (_) => user.ot.text.isNotEmpty?calculatePayroll(index):null,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: UnderLineTextField(
                                                    width: 70,
                                                    controller: user.advance,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (_) => calculatePayroll(index),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: UnderLineTextField(
                                                    width: 70,
                                                    controller: user.uniform,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (_) => calculatePayroll(index),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: UnderLineTextField(
                                                    width: 70,
                                                    controller: user.penalty,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (_) => calculatePayroll(index),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: UnderLineTextField(
                                                    width: 70,
                                                    controller: user.bonus2,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (_) => calculatePayroll(index),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: UnderLineTextField(
                                                    width: 70,
                                                    controller: user.food,
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (_) => calculatePayroll(index),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: valueBox(user.total.text),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: valueBox(user.deduction.text),
                                                )
                                              ],
                                            );
                                          }),
                                          // Totals row
                                          TableRow(
                                            decoration: BoxDecoration(color: colorsConst.primary),
                                            children: [
                                              textBox(""),
                                              textBox(""),
                                              textBox("Total", width: 150),
                                              textBox(totalDuty.value.toString()),
                                              textBox(totalOT.value.toString()),
                                              textBox(totalAdvance.value.toStringAsFixed(2)),
                                              textBox(totalUniform.value.toStringAsFixed(2)),
                                              textBox(totalPenalty.value.toStringAsFixed(2)),
                                              textBox(totalBonus2.value.toStringAsFixed(2)),
                                              textBox(totalFood.value.toStringAsFixed(2)),
                                              textBox(totalEarned.value.toStringAsFixed(2)),
                                              textBox(totalDed.value.toStringAsFixed(2)),
                                              textBox(""),
                                            ],
                                          ),
                                        ],
                                      )),
                                    ),
                                  ),
                                ),
                              ),
                            20.height,
                            if(pyrlCtr.users.isEmpty)
                              const CustomText(text: "\n\n\n\n\nSelect Employee",colors: Colors.grey,size:15,isBold: true, isCopy: true,),
                            50.height
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        )
      ),
    );
    });
  }

  Widget textBox(String text, {double? width = 70}){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: CustomText(text: text, isCopy: true,colors: Colors.white,isBold: true,size: 15,),
    );
  }
  Widget valueBox(String value, {double? width = 90}){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomText(text: value,isCopy: true,),
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
        newPyrlServ.updatePayrollList(context, pyrlCtr.users,pyrlCtr.isStored.value);
      }else{
        newPyrlServ.insertPayrollList(context, pyrlCtr.users);
      }
    }
  }

  Future<List<UnitPayroll>> getPyrlAtt() async {
    try{
      pyrlCtr.getData.value=false;
      pyrlCtr.isStored.value="";
      pyrlCtr.users.clear();
      Map data = {
        "action":"get_data",
        "cos_id":controllers.storage.read("cos_id"),
        // "com_id":controllers.storage.read("com_id"),
        "search_type":"new_monthly_payroll",
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
      print(data);
      print(request.body);
      final List dataValue= json.decode(request.body);
      // print(data);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getPyrlAtt();
        } else {
          controllers.setLogOut();
        }
      }
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
  void calculatePayroll(int index,) {
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
      bool depFound = false;

      // -------- ROLE SETTINGS --------
      for (var i = 0; i < pyrlCtr.settingList.length; i++) {
        if (isRole==true&&pyrlCtr.settingList[i].roleName == pyrlCtr.users[index].rank) {
          print("Matched list: ${pyrlCtr.settingList[i]}");
          print("Matched list: ${pyrlCtr.settingList[i].perDay}");

          monthlyWage = pyrlCtr.settingList[i].monthlyWages;

          salary = safeDouble(pyrlCtr.settingList[i].salary.text);
          perSalary = safeDouble(pyrlCtr.settingList[i].perDay.text);

          basicCalc = safeDouble(pyrlCtr.settingList[i].basic.text);
          daCalc = safeDouble(pyrlCtr.settingList[i].da.text);
          hraCalc = safeDouble(pyrlCtr.settingList[i].hra.text);

          adCalc = safeDouble(pyrlCtr.settingList[i].adminCharges.text);
          bonusCalc = safeDouble(pyrlCtr.settingList[i].bonus.text);
          oPCalc = safeDouble(pyrlCtr.settingList[i].optionSalary.text);

          print("Salary: $salary");
          print("Per Salary: $perSalary");
          print("Monthly Wage: $monthlyWage");

          if (pyrlCtr.settingList[i].weekOff==true&&pyrlCtr.settingList[i].saturday==true&&pyrlCtr.settingList[i].sunday==true) {
            workingDay = pyrlCtr.lastDate;
          } else if (pyrlCtr.settingList[i].weekOff==true&&pyrlCtr.settingList[i].saturday==true&&pyrlCtr.settingList[i].sunday==false) {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("1");
          } else if (pyrlCtr.settingList[i].weekOff==true&&pyrlCtr.settingList[i].saturday==false&&pyrlCtr.settingList[i].sunday==true) {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("2");
          } else {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("3");
          }

          print("Working Days: $workingDay");

          roleFound = true;
          break;
        }
        else if (isDep==true&&pyrlCtr.settingList[i].dName == pyrlCtr.users[index].department) {
          print("Matched list: ${pyrlCtr.settingList[i]}");
          print("Matched list: ${pyrlCtr.settingList[i].perDay}");

          monthlyWage = pyrlCtr.settingList[i].monthlyWages;

          salary = safeDouble(pyrlCtr.settingList[i].salary.text);
          perSalary = safeDouble(pyrlCtr.settingList[i].perDay.text);

          basicCalc = safeDouble(pyrlCtr.settingList[i].basic.text);
          daCalc = safeDouble(pyrlCtr.settingList[i].da.text);
          hraCalc = safeDouble(pyrlCtr.settingList[i].hra.text);

          adCalc = safeDouble(pyrlCtr.settingList[i].adminCharges.text);
          bonusCalc = safeDouble(pyrlCtr.settingList[i].bonus.text);
          oPCalc = safeDouble(pyrlCtr.settingList[i].optionSalary.text);

          print("Salary: $salary");
          print("Per Salary: $perSalary");
          print("Monthly Wage: $monthlyWage");

          if (pyrlCtr.settingList[i].weekOff==true&&pyrlCtr.settingList[i].saturday==true&&pyrlCtr.settingList[i].sunday==true) {
            workingDay = pyrlCtr.lastDate;
          } else if (pyrlCtr.settingList[i].weekOff==true&&pyrlCtr.settingList[i].saturday==true&&pyrlCtr.settingList[i].sunday==false) {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("1");
          } else if (pyrlCtr.settingList[i].weekOff==true&&pyrlCtr.settingList[i].saturday==false&&pyrlCtr.settingList[i].sunday==true) {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("2");
          } else {
            workingDay = pyrlCtr.lastDate - countSaturdaysAndSundays("3");
          }

          print("Working Days: $workingDay");

          depFound = true;
          break;
        }
      }

      if (isRole==true&&!roleFound) {
        print("❌ Role not found");
        utils.snackBar(context: context, msg: "“This role has no payroll setting", color: Colors.red);
        pyrlCtr.users.removeAt(index);
        return;
      }
      if (isDep==true&&!depFound) {
        print("❌ Department not found");
        utils.snackBar(context: context, msg: "“This department has no payroll setting", color: Colors.red);
        pyrlCtr.users.removeAt(index);
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
                        pw.Text(controllers.comName.text,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            "${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
                                " ${controllers.comCountry.text}, ${controllers.comPincode.text}"),
                      ]
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Month")
                      ]
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
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
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'Muster Roll - ${pyrlCtr.month.value}.pdf');
    } else {
      // Mobile: save to device
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Muster Roll - ${pyrlCtr.month.value}.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    }
  }

  Future<void> generateExcel(List<PayrollUserModel> users) async {
    // Create a new Excel workbook
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Header row
    final headers = [
      'S.No',
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
    sheet.getRangeByName('A1:R1').merge();
    sheet.getRangeByName('A2:I2').merge();
    sheet.getRangeByName('J2:R2').merge();
    sheet.getRangeByName("A2:R2").rowHeight = 60;
    sheet.getRangeByName("A2").setText(
        "${controllers.comName.text}\n Address : ${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
    " ${controllers.comCountry.text}, ${controllers.comPincode.text}");
    sheet.getRangeByName("J2").setText("Month : ${pyrlCtr.month.value}");
    sheet.getRangeByName('A1:R1').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A2:R2').cellStyle.hAlign = HAlignType.center;
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
        ..setAttribute('download', 'Muster Roll - ${pyrlCtr.month.value}.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/Muster Roll - ${pyrlCtr.month.value}.xlsx';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }
}
