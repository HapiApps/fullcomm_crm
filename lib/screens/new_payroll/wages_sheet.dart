import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column,Row;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:security/services/new_payroll_api_services.dart';
import 'package:security/source/extentions/extensions.dart';
import '../../component/custom_text.dart';
import '../../component/emp_drop.dart';
import '../../component/loading.dart';
import '../../component/map_dropdown.dart';
import '../../component/month_calender.dart';
import '../../constant/assets_constant.dart';
import '../../constant/color_constant.dart';
import '../../constant/local_data.dart';
import '../../controller/employee_controller.dart';
import '../../controller/monthly_unit_payroll.dart';
import '../../controller/new_payroll_controller.dart';
import '../../controller/unit_controller.dart';
import '../../model/unit_model.dart';
import '../../services/employee_api_services.dart';
import '../../styles/decoration.dart';
import '../../widgets/widgets_functions.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dashboard.dart';
import 'dart:io' as io;
import 'dart:typed_data';

class UnitSlip extends StatefulWidget {
  const UnitSlip({super.key});

  @override
  State<UnitSlip> createState() => _UnitSlipState();
}

class _UnitSlipState extends State<UnitSlip> {
  var newPyrlServ = NewPayrollApiServices.instance;
  var empServ=EmpApiServices.instance;
  var unitname,unitId;

  @override
  void initState() {
    pyrlCtr.users.clear();
    pyrlCtr.unitPayrollList.clear();
    unitCtr.selectTeam=null;
    empServ.getTeams();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mobileSize = MediaQuery
        .of(context)
        .size
        .width * 0.95;
    var webSize = MediaQuery
        .of(context)
        .size
        .width * 0.97;
    return Scaffold(
        backgroundColor: colorsConst.backGroundColor,
        appBar: PreferredSize(preferredSize: const Size(300, 70),
            child: app_bar(text: "Wages Sheet", callback1: () {
              Get.to(const NewPayroll(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(seconds: 1));
            })),
        body: Obx(() =>
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () {
                          showMonthPicker2(
                            context: context,
                            month: pyrlCtr.month,
                            function: (){
                              if(unitCtr.selectTeam==null){
                                if(pyrlCtr.unitName!=null){
                                  newPyrlServ.getUnitPayroll(unitId);
                                }
                              }else{
                                newPyrlServ.getTeamUnitPayroll(localData.storage.read("team_report_id"));
                              }
                            }
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                                Icons.calendar_month, color: Colors.blueGrey),
                            10.width,
                            CustomText(text: pyrlCtr.month.value,
                                colors: Colors.lightBlueAccent,
                                size: 15),
                          ],
                        )),
                    MapDropDown(
                      color: Colors.white,
                      width: webSize/5,
                      value: unitCtr.selectTeam,
                      hintText: "Team",
                      items: empCtr.teamList.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: CustomText(text: value["name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          pyrlCtr.unitName =null;
                          var list=[];
                          list.add(value);
                          unitCtr.selectTeam = value;
                          localData.storage.write("team_report_id", list[0]["id"]);
                          localData.storage.write("team_report_name", list[0]["name"]);
                          newPyrlServ.getTeamUnitPayroll(localData.storage.read("team_report_id"));
                        });
                      },
                    ),

                    // MapDropDown(
                    //   color: Colors.white,
                    //   width: webSize/5,
                    //   value: unitCtr.selectTeam,
                    //   hintText: "Team",
                    //   items: empCtr.teamList.map((value) {
                    //     return DropdownMenuItem(
                    //       value: value,
                    //       child: CustomText(text: value["name"]),
                    //     );
                    //   }).toList(),
                    //   onChanged: (value) {
                    //     setState(() {
                    //       unitCtr.selectTeam = value;
                    //       var list=[];
                    //       list.add(value);
                    //       print("list");
                    //       print(list);
                    //       newPyrlServ.getTeamUnitPayroll(list[0]["id"]);
                    //     });
                    //   },
                    // ),
                  ],
                ),
                10.height,
                Center(
                  child: pyrlCtr.getUnits.value == false ?
                  const Loading() :
                  pyrlCtr.unitList.isEmpty ?
                  const CustomText(text: "No Unit Found") :
                  PayrollUnitDropDown(
                    size: kIsWeb ? webSize : mobileSize,
                    color: Colors.white,
                    text: "Unit Name",
                    unitList: pyrlCtr.unitList,
                    onChanged: (units? unit) {
                      setState(() {
                        pyrlCtr.unitName = unit;
                        if (unit != null) {
                          unitCtr.selectTeam =null;
                          unitname = unit.unit_name.toString();
                          unitId = unit.id.toString();
                          newPyrlServ.getUnitPayroll(unitId);
                        }
                      });
                    },),
                ),
                pyrlCtr.getData.value == false ?
                const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Loading(),
                ) :
                pyrlCtr.unitPayrollList.isEmpty ?
                const CustomText(text: "\n\n\n\n\n\nNo Data Found") :
                Expanded(
                  child: SizedBox(
                    width: kIsWeb ? webSize : mobileSize,
                    child: ListView.builder(
                      itemCount: pyrlCtr.unitPayrollList.length,
                      itemBuilder: (context, index) {
                        var namesList = pyrlCtr.unitPayrollList[index].name.toString().split(',');
                        var codeList = pyrlCtr.unitPayrollList[index].empcd.toString().split(',');
                        var roleList = pyrlCtr.unitPayrollList[index].roleName.toString().split(',');
                        var dutyList = pyrlCtr.unitPayrollList[index].duty.toString().split(',');
                        var otList = pyrlCtr.unitPayrollList[index].ot.toString().split(',');
                        var basicList = pyrlCtr.unitPayrollList[index].basic.toString().split(',');
                        var hraList = pyrlCtr.unitPayrollList[index].hra.toString().split(',');
                        var daList = pyrlCtr.unitPayrollList[index].da.toString().split(',');
                        var netAmtList = pyrlCtr.unitPayrollList[index].netAmount.toString().split(',');
                        var advanceList = pyrlCtr.unitPayrollList[index].advance.toString().split(',');
                        var uniformList = pyrlCtr.unitPayrollList[index].uniform.toString().split(',');
                        var penaltyList = pyrlCtr.unitPayrollList[index].penalty.toString().split(',');
                        var esiList = pyrlCtr.unitPayrollList[index].esi.toString().split(',');
                        var pfList = pyrlCtr.unitPayrollList[index].pf.toString().split(',');
                        var deductionList = pyrlCtr.unitPayrollList[index].deduction.toString().split(',');
                        var totalList = pyrlCtr.unitPayrollList[index].total.toString().split(',');
                        var acList = pyrlCtr.unitPayrollList[index].aC.toString().split(',');
                        var bonusList = pyrlCtr.unitPayrollList[index].bonus.toString().split(',');
                        var bonus2List = pyrlCtr.unitPayrollList[index].bonus2.toString().split(',');
                        var foodList = pyrlCtr.unitPayrollList[index].food.toString().split(',');
                        var opList = pyrlCtr.unitPayrollList[index].op.toString().split(',');

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Container(
                            width: kIsWeb ? webSize : mobileSize,
                            decoration: customDecoration
                                .baseBackgroundDecoration(
                              color: Colors.white,
                              radius: 10,
                            ),
                            child: Column(
                              children: [
                                if(index==0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // ElevatedButton(onPressed: () {
                                      //   esiWagesPayrollExport(index, unitname);
                                      // },
                                      //     child: const CustomText(text: "ESI Wages",
                                      //       isBold: true,
                                      //       colors: Colors.white,)),
                                      // 10.width,
                                      // ElevatedButton(onPressed: () {
                                      //   pfWagesPayrollExport(index, unitname);
                                      // },
                                      //     child: const CustomText(text: "PF Wages",
                                      //         isBold: true,
                                      //         colors: Colors.white)), 10.width,
                                      ElevatedButton(onPressed: () {
                                        // generateSinglePayrollPdf(pyrlCtr.unitPayrollList[index]);
                                        unitPayrollExport(index, unitName: unitCtr.selectTeam==null?unitname:"");
                                      },
                                          child: const CustomText(text: "Excel",
                                            isBold: true,
                                            colors: Colors.white,)),
                                      10.width,
                                      ElevatedButton(onPressed: () {
                                        unitPayrollPreviewPdf(index, unitName: unitCtr.selectTeam==null?unitname:"");
                                      },
                                          child: const CustomText(text: "PDF",
                                              isBold: true,
                                              colors: Colors.white)), 10.width
                                    ],
                                  ),
                                Table(
                                  border: TableBorder.all(
                                      color: Colors.grey.shade300),
                                  columnWidths: unitCtr.selectTeam==null&&localData.storage.read("com_id")=="1"? {
                                    0: FlexColumnWidth(0.5), // no
                                    1: FlexColumnWidth(1), // id
                                    2: FlexColumnWidth(1.2), // role
                                    3: FlexColumnWidth(2.5), // name
                                    4: FlexColumnWidth(1), // duty
                                    5: FlexColumnWidth(1.2), // basic
                                    6: FlexColumnWidth(1.3), // da
                                    7: FlexColumnWidth(1.2), // hra
                                    8: FlexColumnWidth(1.3), // total
                                    9: FlexColumnWidth(1.3), // Advance
                                    10: FlexColumnWidth(1.3), // pe
                                    11: FlexColumnWidth(1.3), // un
                                    12: FlexColumnWidth(1), // esi
                                    13: FlexColumnWidth(1), // pf
                                    14: FlexColumnWidth(1.3), // Deduction
                                    15: FlexColumnWidth(1.7), // netAmt 16 c
                                    16: FlexColumnWidth(1.7), // netAmt 16 c
                                    17: FlexColumnWidth(1.7), // netAmt 16 c
                                  }:
                                  unitCtr.selectTeam!=null&&localData.storage.read("com_id")=="1"?
                                  {
                                    0: FlexColumnWidth(0.7), // no
                                    1: FlexColumnWidth(2), // unit Name
                                    2: FlexColumnWidth(1), // id
                                    3: FlexColumnWidth(1.2), // role
                                    4: FlexColumnWidth(2), // name
                                    5: FlexColumnWidth(1), // duty
                                    6: FlexColumnWidth(1.1), // basic
                                    7: FlexColumnWidth(1.2), // da
                                    8: FlexColumnWidth(1.1), // hra
                                    9: FlexColumnWidth(1.3), // total
                                    10: FlexColumnWidth(1.3), // Advance
                                    11: FlexColumnWidth(1.3), // pe
                                    12: FlexColumnWidth(1.2), // un
                                    13: FlexColumnWidth(1), // esi
                                    14: FlexColumnWidth(1), // pf
                                    15: FlexColumnWidth(1.1), // Deduction
                                    16: FlexColumnWidth(1.7), // netAmt 17 c
                                    17: FlexColumnWidth(1.7), // netAmt 17 c
                                    18: FlexColumnWidth(1.7), // netAmt 17 c
                                  }:
                                  unitCtr.selectTeam==null&&localData.storage.read("com_id")!="1"? {
                                    0: FlexColumnWidth(0.5), // no
                                    1: FlexColumnWidth(1), // id
                                    2: FlexColumnWidth(1.2), // role
                                    3: FlexColumnWidth(2.5), // name
                                    4: FlexColumnWidth(1), // duty
                                    5: FlexColumnWidth(1.2), // basic
                                    6: FlexColumnWidth(1.3), // da
                                    7: FlexColumnWidth(1.2), // hra
                                    8: FlexColumnWidth(1.3), // total
                                    9: FlexColumnWidth(1.3), // Advance
                                    10: FlexColumnWidth(1.3), // pe
                                    11: FlexColumnWidth(1.3), // un
                                    12: FlexColumnWidth(1), // esi
                                    13: FlexColumnWidth(1), // pf
                                    14: FlexColumnWidth(1), // admin charges
                                    15: FlexColumnWidth(1.3), // Deduction
                                    16: FlexColumnWidth(1.3), // Deduction
                                    17: FlexColumnWidth(1.3), // Deduction
                                    // 16: FlexColumnWidth(1.7), // netAmt
                                  }:
                                  {
                                    0: FlexColumnWidth(0.7), // no
                                    1: FlexColumnWidth(2), // unit Name
                                    2: FlexColumnWidth(1), // id
                                    3: FlexColumnWidth(1.2), // role
                                    4: FlexColumnWidth(2), // name
                                    5: FlexColumnWidth(1), // duty
                                    6: FlexColumnWidth(1.1), // basic
                                    7: FlexColumnWidth(1.2), // da
                                    8: FlexColumnWidth(1.1), // hra
                                    9: FlexColumnWidth(1.3), // total
                                    10: FlexColumnWidth(1.3), // Advance
                                    11: FlexColumnWidth(1.3), // pe
                                    12: FlexColumnWidth(1.2), // un
                                    13: FlexColumnWidth(1), // esi
                                    14: FlexColumnWidth(1), // pf
                                    15: FlexColumnWidth(1), // pf
                                    16: FlexColumnWidth(1.1), // Deduction
                                    17: FlexColumnWidth(1.7), // netAmt
                                    18: FlexColumnWidth(1.7), // netAmt
                                    19: FlexColumnWidth(1.7), // netAmt
                                  },
                                  children: [
                                    // Header Row
                                    if(index==0)
                                      TableRow(
                                        decoration: const BoxDecoration(
                                            color: Colors.black12),
                                        children: [
                                          customWid("S.No",bold: true,),
                                          if(unitCtr.selectTeam!=null)
                                          customWid("Unit Name",bold: true,),
                                          customWid("ID",bold: true,),
                                          customWid("Rank",bold: true,),
                                          customWid("Name",bold: true,),
                                          customWid("Duty",bold: true,),
                                          customWid("OT",bold: true,),
                                          if(localData.storage.read("com_id")=="1")
                                          customWid("Basic",bold: true,),
                                          if(localData.storage.read("com_id")=="1")
                                          customWid("DA",bold: true,),
                                          if(localData.storage.read("com_id")=="1")
                                          customWid("HRA",bold: true,),
                                          if(localData.storage.read("com_id")!="1")
                                          customWid("Optional Salary",bold: true,),
                                          if(localData.storage.read("com_id")!="1")
                                          customWid("Bonus",bold: true,),
                                          customWid("Earning",bold: true,),
                                          customWid("Advance",bold: true,),
                                          customWid("Uniform",bold: true,),
                                          customWid("Penalty",bold: true,),
                                          customWid("Bonus",bold: true,),
                                          customWid("Food Charges",bold: true,),
                                          customWid("ESI",bold: true,),
                                          customWid("PF",bold: true,),
                                          if(localData.storage.read("com_id")!="1")
                                          customWid("Admin\nCharges",bold: true,),
                                          customWid("Deduction",bold: true,),
                                          customWid("Net Amt",bold: true,),
                                        ],
                                      ),

                                    // Data Rows
                                    if(unitCtr.selectTeam==null)
                                      for (int i = 0; i < namesList.length; i++)
                                        TableRow(
                                          children: [
                                            customWid((i+1).toString()),
                                            customWid(codeList[i]),
                                            customWid(roleList[i]),
                                            customWid(namesList[i]),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: CustomText(
                                                text: dutyList[i],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: CustomText(
                                                text: otList[i],
                                              ),
                                            ),
                                            // customWid(dutyList[i]),
                                            // customWid(otList[i]),
                                            if(localData.storage.read("com_id")=="1")
                                            customWid(basicList[i]),
                                            if(localData.storage.read("com_id")=="1")
                                            customWid(daList[i]),
                                            if(localData.storage.read("com_id")=="1")
                                            customWid(hraList[i]),
                                            if(localData.storage.read("com_id")!="1")
                                            customWid("${double.parse(opList[i])*double.parse(dutyList[i])}"),
                                            if(localData.storage.read("com_id")!="1")
                                            customWid("${double.parse(bonusList[i])*double.parse(dutyList[i])}"),
                                            customWid(totalList[i]),
                                            customWid(advanceList[i]),
                                            customWid(uniformList[i]),
                                            customWid(penaltyList[i]),
                                            customWid(bonus2List[i]),
                                            customWid(foodList[i]),
                                            customWid(esiList[i]),
                                            customWid(pfList[i]),
                                            if(localData.storage.read("com_id")!="1")
                                            customWid("${double.parse(acList[i]=="null"||acList[i]==""?"0":acList[i])*int.parse(dutyList[i])}"),
                                            customWid(deductionList[i]),
                                            customWid(netAmtList[i]),
                                          ],
                                        ),
                                    if(unitCtr.selectTeam!=null)
                                      // for (int i = 0; i < pyrlCtr.unitPayrollList.length; i++)
                                        TableRow(
                                          children: [
                                            customWid((index+1).toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].unitName.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].empcd.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].roleName.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].name.toString()),
                                            // customWid(pyrlCtr.unitPayrollList[index].duty.toString()),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: CustomText(
                                                text: pyrlCtr.unitPayrollList[index].duty.toString(),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: CustomText(
                                                text: pyrlCtr.unitPayrollList[index].ot.toString(),
                                              ),
                                            ),
                                            // customWid(pyrlCtr.unitPayrollList[index].ot.toString()),
                                            if(localData.storage.read("com_id")=="1")
                                            customWid(pyrlCtr.unitPayrollList[index].basic.toString()),
                                            if(localData.storage.read("com_id")=="1")
                                            customWid(pyrlCtr.unitPayrollList[index].da.toString()),
                                            if(localData.storage.read("com_id")=="1")
                                            customWid(pyrlCtr.unitPayrollList[index].hra.toString()),
                                            if(localData.storage.read("com_id")!="1")
                                            customWid("${double.parse(pyrlCtr.unitPayrollList[index].op.toString())*double.parse(pyrlCtr.unitPayrollList[index].duty.toString())}"),
                                            if(localData.storage.read("com_id")!="1")
                                            customWid("${double.parse(pyrlCtr.unitPayrollList[index].bonus.toString())*double.parse(pyrlCtr.unitPayrollList[index].duty.toString())}"),
                                            customWid(pyrlCtr.unitPayrollList[index].total.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].advance.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].uniform.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].penalty.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].bonus2.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].food.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].esi.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].pf.toString()),
                                            if(localData.storage.read("com_id")!="1")
                                            customWid("${double.parse(pyrlCtr.unitPayrollList[index].aC.toString())*double.parse(pyrlCtr.unitPayrollList[index].duty.toString())}"),
                                            customWid(pyrlCtr.unitPayrollList[index].deduction.toString()),
                                            customWid(pyrlCtr.unitPayrollList[index].netAmount.toString()),
                                          ],
                                        ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ))
    );
  }

  // Widget customWid(String value, {double? width = 8,bool? bold = false}){
  //   return Padding(
  //       padding: const EdgeInsets.all(8),
  //       child: CustomText(text: value,isBold: bold,));
  // }

  Widget customWid(String? value, {double width = 8, bool bold = false}) {
    // value null or empty na show panna empty
    if (value == null || value.trim().isEmpty) {
      return const SizedBox(); // or return Text('') if needed
    }

    // number format
    String formattedValue = value;

    // Try to parse value as number
    final number = num.tryParse(value.replaceAll(',', ''));

    if (number != null) {
      formattedValue = NumberFormat('#,##0').format(number);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomText(
        text: formattedValue,
        isBold: bold,
      ),
    );
  }


  pw.TableRow _row(String title, String value, pw.Font baseFont) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(title, style: pw.TextStyle(font: baseFont)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: pw.TextStyle(font: baseFont)),
        ),
      ],
    );
  }

  Future<void> unitPayrollExport(int index, {required String unitName}) async {
    String clean(String? value, {bool? isName=false}) {
      if (value == null || value.trim().isEmpty || value.toLowerCase() == "null") {
        return "";
      }

      // Try converting to number & format it
      final number = num.tryParse(value);
      if (number != null&&isName==false) {
        return NumberFormat('#,##0').format(number);

        // 👉 If you want INDIAN format:
        // return NumberFormat.decimalPattern('en_IN').format(number);
      }

      return value;
    }
    String getSafe(List<String> list, int idx,{bool? isName=false}) {
      return idx < list.length ? clean(list[idx],isName: isName) : "";
    }
    String getSafe2(String? value,{bool? isName=false}) {
      return clean(value,isName: isName);
    }


    final Workbook workbook = Workbook();
    final Worksheet worksheet = workbook.worksheets[0];

    // Header format
    worksheet.getRangeByName('A1:X1').merge();
    worksheet
        .getRangeByName('A1:X1')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet.getRangeByName('A2:X2').merge();
    worksheet.getRangeByName('A3:K3').merge();
    worksheet.getRangeByName('L3:X3').merge();
    worksheet
        .getRangeByName('A2:X2')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet
        .getRangeByName('A3:X3')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet
        .getRangeByName('A4:X4')
        .cellStyle
        .hAlign = HAlignType.center;

    worksheet
        .getRangeByName('A1')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A2')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A3:X3')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A4')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A4:X4')
        .cellStyle
        .backColor = '#CA1617';
    worksheet
        .getRangeByName('A4:X4')
        .cellStyle
        .fontColor = '#ffffff';

    // Report Title
    worksheet.getRangeByName("A1").setText("Register Of Wages");
    worksheet.getRangeByName("A2").setText("Form No XVII");
    worksheet
        .getRangeByName("A3:X3")
        .rowHeight = 60; // height adjust pannalam


    worksheet.getRangeByName("A3").setText(
        "${localData.storage.read("com_name")}\n Address : 44/1, V.V. Koil Street, Tambaram Sanatorium,Chennai-600 045,Tamilnadu, India.");
    worksheet.getRangeByName("L3").setText(
        "Client Name : ${unitName==""?"Team ${localData.storage.read("team_report_name")}":unitName}\nMonth : ${pyrlCtr.month.value}");
    List<String> headers=[];
    if(localData.storage.read("com_id")=="1"){
      headers = [
        "S.No",
        "ID No",
        "Rank",
        "Unit Name",
        "Name",
        "Site Salary",
        "Duty",
        "OT",
        "Basic",
        "DA",
        "HRA",
        "Earning",
        "ESI",
        "PF",
        "Advance",
        "Penalty",
        "Uniform",
        "Bonus",
        "Food charges",
        "Deduction",
        "Net salary",
        "A/C Name",
        "A/C No",
        "IFSC Code"
      ];
    }else{
      headers = [
        "S.No",
        "ID No",
        "Rank",
        "Unit Name",
        "Name",
        "Site Salary",
        "Duty",
        "OT",
        "Optional Salary",
        "Bonus",
        "Earning",
        "ESI",
        "PF",
        "Admin charges",
        "Advance",
        "Penalty",
        "Uniform",
        "Bonus",
        "Food Charges",
        "Deduction",
        "Net salary",
        "A/C Name",
        "A/C No",
        "IFSC Code"
      ];
    }
    // Headers`
    for (int j = 0; j < headers.length; j++) {
      worksheet.getRangeByIndex(4, j + 1).setText(headers[j]);
    }
    // Data lists (comma separated)
    var namesList = pyrlCtr.unitPayrollList[index].name.toString().split(',');
    var empcdList = pyrlCtr.unitPayrollList[index].empcd.toString().split(',');
    var roleList = pyrlCtr.unitPayrollList[index].roleName.toString().split(
        ',');
    var dutyList = pyrlCtr.unitPayrollList[index].duty.toString().split(',');
    var otList = pyrlCtr.unitPayrollList[index].ot.toString().split(',');
    var netAmtList = pyrlCtr.unitPayrollList[index].netAmount.toString().split(
        ',');
    var advanceList = pyrlCtr.unitPayrollList[index].advance.toString().split(
        ',');
    var uniformList = pyrlCtr.unitPayrollList[index].uniform.toString().split(
        ',');
    var penaltyList = pyrlCtr.unitPayrollList[index].penalty.toString().split(
        ',');
    var deductionList = pyrlCtr.unitPayrollList[index].deduction
        .toString()
        .split(',');
    var totalList = pyrlCtr.unitPayrollList[index].total.toString().split(',');
    var basicList = pyrlCtr.unitPayrollList[index].basic.toString().split(',');
    var hraList = pyrlCtr.unitPayrollList[index].hra.toString().split(',');
    var daList = pyrlCtr.unitPayrollList[index].da.toString().split(',');
    var esiList = pyrlCtr.unitPayrollList[index].esi.toString().split(',');
    var pfList = pyrlCtr.unitPayrollList[index].pf.toString().split(',');
    var acList = pyrlCtr.unitPayrollList[index].aC.toString().split(',');
    var accNoList = pyrlCtr.unitPayrollList[index].accNo.toString().split(',');
    var opList = pyrlCtr.unitPayrollList[index].op.toString().split(',');
    var bonusList = pyrlCtr.unitPayrollList[index].bonus.toString().split(',');
    var bonus2List = pyrlCtr.unitPayrollList[index].bonus2.toString().split(',');
    var foodList = pyrlCtr.unitPayrollList[index].food.toString().split(',');
    var ifscList = pyrlCtr.unitPayrollList[index].ifscCode.toString().split(
        ',');
    var bkNameList = pyrlCtr.unitPayrollList[index].bankName.toString().split(
        ',');
    var salaryList = pyrlCtr.unitPayrollList[index].salary.toString().split(
        ',');
    int rowCountEx;
    if(localData.storage.read("com_id")=="1"){
      rowCountEx = [
        namesList.length,
        empcdList.length,
        roleList.length,
        dutyList.length,
        otList.length,
        netAmtList.length,
        advanceList.length,
        uniformList.length,
        penaltyList.length,
        deductionList.length,
        totalList.length,
        basicList.length,
        daList.length,
        hraList.length,
        totalList.length,
        totalList.length,//
        totalList.length,//
        esiList.length,
        pfList.length,
        accNoList.length,
        ifscList.length,
        bkNameList.length
      ].reduce((a, b) => a > b ? a : b);
    }else{
      rowCountEx = [
        namesList.length,
        empcdList.length,
        roleList.length,
        dutyList.length,
        otList.length,
        netAmtList.length,
        advanceList.length,
        uniformList.length,
        penaltyList.length,
        deductionList.length,
        totalList.length,
        // basicList.length,
        opList.length,
        bonusList.length,
        totalList.length,
        esiList.length,
        pfList.length,
        pfList.length,//
        pfList.length,//
        acList.length,
        accNoList.length,
        ifscList.length,
        bkNameList.length
      ].reduce((a, b) => a > b ? a : b);
    }
    if(localData.storage.read("com_id")=="1"){
      // Fill data
      if(unitName!=""){
        for (int i = 0; i < rowCountEx; i++) {
          worksheet.getRangeByIndex(i + 5, 1).setText("${i + 1}");
          worksheet.getRangeByIndex(i + 5, 2).setText(getSafe(empcdList, i));
          worksheet.getRangeByIndex(i + 5, 3).setText(getSafe(roleList, i));
          worksheet.getRangeByIndex(i + 5, 4).setText(
              pyrlCtr.unitPayrollList[index].unitName.toString());
          worksheet.getRangeByIndex(i + 5, 5).setText(getSafe(namesList, i));
          worksheet.getRangeByIndex(i + 5, 6).setText(getSafe(salaryList, i));
          worksheet.getRangeByIndex(i + 5, 7).setText(getSafe(dutyList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 8).setText(getSafe(otList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 9).setText(getSafe(basicList, i));
          worksheet.getRangeByIndex(i + 5, 10).setText(getSafe(daList, i));
          worksheet.getRangeByIndex(i + 5, 11).setText(getSafe(hraList, i));
          worksheet.getRangeByIndex(i + 5, 12).setText(getSafe(totalList, i));
          worksheet.getRangeByIndex(i + 5, 13).setText(getSafe(esiList, i));
          worksheet.getRangeByIndex(i + 5, 14).setText(getSafe(pfList, i));
          worksheet.getRangeByIndex(i + 5, 15).setText(getSafe(advanceList, i));
          worksheet.getRangeByIndex(i + 5, 16).setText(getSafe(penaltyList, i));
          worksheet.getRangeByIndex(i + 5, 17).setText(getSafe(uniformList, i));
          worksheet.getRangeByIndex(i + 5, 18).setText(getSafe(bonus2List, i));
          worksheet.getRangeByIndex(i + 5, 19).setText(getSafe(foodList, i));
          worksheet.getRangeByIndex(i + 5, 20).setText(getSafe(deductionList, i));
          worksheet.getRangeByIndex(i + 5, 21).setText(getSafe(netAmtList, i));
          worksheet.getRangeByIndex(i + 5, 22).setText(getSafe(bkNameList, i));
          worksheet.getRangeByIndex(i + 5, 23).setText(getSafe(accNoList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 24).setText(getSafe(ifscList, i));
        }
      }else{
        for (int i = 0; i < pyrlCtr.unitPayrollList.length; i++) {
          worksheet.getRangeByIndex(i + 5, 1).setText("${i + 1}");
          worksheet.getRangeByIndex(i + 5, 2).setText(getSafe2(pyrlCtr.unitPayrollList[i].empcd.toString()));
          worksheet.getRangeByIndex(i + 5, 3).setText(getSafe2(pyrlCtr.unitPayrollList[i].roleName.toString()));
          worksheet.getRangeByIndex(i + 5, 4).setText(getSafe2(pyrlCtr.unitPayrollList[i].unitName.toString()));
          worksheet.getRangeByIndex(i + 5, 5).setText(getSafe2(pyrlCtr.unitPayrollList[i].name.toString()));
          worksheet.getRangeByIndex(i + 5, 6).setText(getSafe2(pyrlCtr.unitPayrollList[i].salary.toString()));
          worksheet.getRangeByIndex(i + 5, 7).setText(getSafe2(pyrlCtr.unitPayrollList[i].duty.toString(),isName: true));
          worksheet.getRangeByIndex(i + 5, 8).setText(getSafe2(pyrlCtr.unitPayrollList[i].ot.toString(),isName: true));
          worksheet.getRangeByIndex(i + 5, 9).setText(getSafe2(pyrlCtr.unitPayrollList[i].basic.toString()));
          worksheet.getRangeByIndex(i + 5, 10).setText(getSafe2(pyrlCtr.unitPayrollList[i].da.toString()));
          worksheet.getRangeByIndex(i + 5, 11).setText(getSafe2(pyrlCtr.unitPayrollList[i].hra.toString()));
          worksheet.getRangeByIndex(i + 5, 12).setText(getSafe2(pyrlCtr.unitPayrollList[i].total.toString()));
          worksheet.getRangeByIndex(i + 5, 13).setText(getSafe2(pyrlCtr.unitPayrollList[i].esi.toString()));
          worksheet.getRangeByIndex(i + 5, 14).setText(getSafe2(pyrlCtr.unitPayrollList[i].pf.toString()));
          worksheet.getRangeByIndex(i + 5, 15).setText(getSafe2(pyrlCtr.unitPayrollList[i].advance.toString()));
          worksheet.getRangeByIndex(i + 5, 16).setText(getSafe2(pyrlCtr.unitPayrollList[i].penalty.toString()));
          worksheet.getRangeByIndex(i + 5, 17).setText(getSafe2(pyrlCtr.unitPayrollList[i].uniform.toString()));
          worksheet.getRangeByIndex(i + 5, 18).setText(getSafe2(pyrlCtr.unitPayrollList[i].bonus2.toString()));
          worksheet.getRangeByIndex(i + 5, 19).setText(getSafe2(pyrlCtr.unitPayrollList[i].food.toString()));
          worksheet.getRangeByIndex(i + 5, 20).setText(getSafe2(pyrlCtr.unitPayrollList[i].deduction.toString()));
          worksheet.getRangeByIndex(i + 5, 21).setText(getSafe2(pyrlCtr.unitPayrollList[i].netAmount.toString()));
          worksheet.getRangeByIndex(i + 5, 22).setText(getSafe2(pyrlCtr.unitPayrollList[i].bankName.toString()));
          worksheet.getRangeByIndex(i + 5, 23).setText(getSafe2(pyrlCtr.unitPayrollList[i].accNo.toString(),isName: true));
          worksheet.getRangeByIndex(i + 5, 24).setText(getSafe2(pyrlCtr.unitPayrollList[i].ifscCode.toString()));
        }
      }
    }
    else{
      // Fill data
      if(unitName!=""){
        for (int i = 0; i < rowCountEx; i++) {
          worksheet.getRangeByIndex(i + 5, 1).setText("${i + 1}");
          worksheet.getRangeByIndex(i + 5, 2).setText(getSafe(empcdList, i));
          worksheet.getRangeByIndex(i + 5, 3).setText(getSafe(roleList, i));
          worksheet.getRangeByIndex(i + 5, 4).setText(
              pyrlCtr.unitPayrollList[index].unitName.toString());
          worksheet.getRangeByIndex(i + 5, 5).setText(getSafe(namesList, i));
          worksheet.getRangeByIndex(i + 5, 6).setText(getSafe(salaryList, i));
          worksheet.getRangeByIndex(i + 5, 7).setText(getSafe(dutyList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 8).setText(getSafe(otList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 9).setText("${double.parse(opList[i])*double.parse(dutyList[i])}");
          worksheet.getRangeByIndex(i + 5, 10).setText("${double.parse(bonusList[i])*double.parse(dutyList[i])}");
          worksheet.getRangeByIndex(i + 5, 11).setText(getSafe(totalList, i));
          worksheet.getRangeByIndex(i + 5, 12).setText(getSafe(esiList, i));
          worksheet.getRangeByIndex(i + 5, 13).setText(getSafe(pfList, i));
          worksheet.getRangeByIndex(i + 5, 14).setText("${double.parse(acList[i])*double.parse(dutyList[i])}");
          worksheet.getRangeByIndex(i + 5, 15).setText(getSafe(advanceList, i));
          worksheet.getRangeByIndex(i + 5, 16).setText(getSafe(penaltyList, i));
          worksheet.getRangeByIndex(i + 5, 17).setText(getSafe(uniformList, i));
          worksheet.getRangeByIndex(i + 5, 18).setText(getSafe(bonus2List, i));
          worksheet.getRangeByIndex(i + 5, 19).setText(getSafe(foodList, i));
          worksheet.getRangeByIndex(i + 5, 20).setText(getSafe(deductionList, i));
          worksheet.getRangeByIndex(i + 5, 21).setText(getSafe(netAmtList, i));
          worksheet.getRangeByIndex(i + 5, 22).setText(getSafe(bkNameList, i));
          worksheet.getRangeByIndex(i + 5, 23).setText(getSafe(accNoList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 24).setText(getSafe(ifscList, i));
        }
      }else{
        for (int i = 0; i < pyrlCtr.unitPayrollList.length; i++) {
          worksheet.getRangeByIndex(i + 5, 1).setText("${i + 1}");
          worksheet.getRangeByIndex(i + 5, 2).setText(getSafe2(pyrlCtr.unitPayrollList[i].empcd.toString()));
          worksheet.getRangeByIndex(i + 5, 3).setText(getSafe2(pyrlCtr.unitPayrollList[i].roleName.toString()));
          worksheet.getRangeByIndex(i + 5, 4).setText(getSafe2(pyrlCtr.unitPayrollList[i].unitName.toString()));
          worksheet.getRangeByIndex(i + 5, 5).setText(getSafe2(pyrlCtr.unitPayrollList[i].name.toString()));
          worksheet.getRangeByIndex(i + 5, 6).setText(getSafe2(pyrlCtr.unitPayrollList[i].salary.toString()));
          worksheet.getRangeByIndex(i + 5, 7).setText(getSafe2(pyrlCtr.unitPayrollList[i].duty.toString(),isName: true));
          worksheet.getRangeByIndex(i + 5, 8).setText(getSafe2(pyrlCtr.unitPayrollList[i].ot.toString(),isName: true));
          // worksheet.getRangeByIndex(i + 5, 9).setText(getSafe2(pyrlCtr.unitPayrollList[i].basic.toString()));
          worksheet.getRangeByIndex(i + 5, 9).setText(getSafe2("${double.parse(pyrlCtr.unitPayrollList[i].op.toString())*double.parse(pyrlCtr.unitPayrollList[i].duty.toString())}"));
          worksheet.getRangeByIndex(i + 5, 10).setText(getSafe2("${double.parse(pyrlCtr.unitPayrollList[i].bonus.toString())*double.parse(pyrlCtr.unitPayrollList[i].duty.toString())}"));
          worksheet.getRangeByIndex(i + 5, 11).setText(getSafe2(pyrlCtr.unitPayrollList[i].total.toString()));
          worksheet.getRangeByIndex(i + 5, 12).setText(getSafe2(pyrlCtr.unitPayrollList[i].esi.toString()));
          worksheet.getRangeByIndex(i + 5, 13).setText(getSafe2(pyrlCtr.unitPayrollList[i].pf.toString()));
          worksheet.getRangeByIndex(i + 5, 14).setText(getSafe2("${double.parse(pyrlCtr.unitPayrollList[i].aC.toString())*double.parse(pyrlCtr.unitPayrollList[i].duty.toString())}"));
          worksheet.getRangeByIndex(i + 5, 15).setText(getSafe2(pyrlCtr.unitPayrollList[i].advance.toString()));
          worksheet.getRangeByIndex(i + 5, 16).setText(getSafe2(pyrlCtr.unitPayrollList[i].penalty.toString()));
          worksheet.getRangeByIndex(i + 5, 17).setText(getSafe2(pyrlCtr.unitPayrollList[i].uniform.toString()));
          worksheet.getRangeByIndex(i + 5, 18).setText(getSafe2(pyrlCtr.unitPayrollList[i].bonus2.toString()));
          worksheet.getRangeByIndex(i + 5, 19).setText(getSafe2(pyrlCtr.unitPayrollList[i].food.toString()));
          worksheet.getRangeByIndex(i + 5, 20).setText(getSafe2(pyrlCtr.unitPayrollList[i].deduction.toString()));
          worksheet.getRangeByIndex(i + 5, 21).setText(getSafe2(pyrlCtr.unitPayrollList[i].netAmount.toString()));
          worksheet.getRangeByIndex(i + 5, 22).setText(getSafe2(pyrlCtr.unitPayrollList[i].bankName.toString()));
          worksheet.getRangeByIndex(i + 5, 23).setText(getSafe2(pyrlCtr.unitPayrollList[i].accNo.toString(),isName: true));
          worksheet.getRangeByIndex(i + 5, 24).setText(getSafe2(pyrlCtr.unitPayrollList[i].ifscCode.toString()));
        }
      }
    }

    // Save
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', '${unitName==""?"Team ${localData.storage.read("team_report_name")}":unitName} Register Of Wages - ${pyrlCtr.month.value}.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/${unitName==""?"Team ${localData.storage.read("team_report_name")}":unitName} Register Of Wages - ${pyrlCtr.month.value}.xlsx';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }


  Future<void> unitPayrollPreviewPdf(int index, {required String unitName}) async {
    final pdf = pw.Document();
    final imageByteData = await rootBundle.load(assets.logo);
    final imageList = imageByteData.buffer
        .asUint8List(imageByteData.offsetInBytes, imageByteData.lengthInBytes);
    final image = pw.MemoryImage(imageList);
    String clean(String? value, {bool? isName=false}) {
      if (value == null || value.trim().isEmpty || value.toLowerCase() == "null") {
        return "";
      }

      // Try converting to number & format it
      final number = num.tryParse(value);
      if (number != null&&isName==false) {
        return NumberFormat('#,##0').format(number);

        // 👉 If you want INDIAN format:
        // return NumberFormat.decimalPattern('en_IN').format(number);
      }

      return value;
    }
    String getSafe(List<String> list, int idx,{bool? isName=false}) {
      return idx < list.length ? clean(list[idx],isName: isName) : "";
    }
    String getSafe2(String? value,{bool? isName=false}) {
      return clean(value,isName: isName);
    }
    // Data lists
    var namesList = pyrlCtr.unitPayrollList[index].name.toString().split(',');
    var empcdList = pyrlCtr.unitPayrollList[index].empcd.toString().split(',');
    var roleList = pyrlCtr.unitPayrollList[index].roleName.toString().split(',');
    var dutyList = pyrlCtr.unitPayrollList[index].duty.toString().split(',');
    var otList = pyrlCtr.unitPayrollList[index].ot.toString().split(',');
    var netAmtList = pyrlCtr.unitPayrollList[index].netAmount.toString().split(',');
    var advanceList = pyrlCtr.unitPayrollList[index].advance.toString().split(',');
    var uniformList = pyrlCtr.unitPayrollList[index].uniform.toString().split(',');
    var penaltyList = pyrlCtr.unitPayrollList[index].penalty.toString().split(',');
    var deductionList = pyrlCtr.unitPayrollList[index].deduction.toString().split(',');
    var totalList = pyrlCtr.unitPayrollList[index].total.toString().split(',');
    var basicList = pyrlCtr.unitPayrollList[index].basic.toString().split(',');
    var hraList = pyrlCtr.unitPayrollList[index].hra.toString().split(',');
    var daList = pyrlCtr.unitPayrollList[index].da.toString().split(',');
    var esiList = pyrlCtr.unitPayrollList[index].esi.toString().split(',');
    var pfList = pyrlCtr.unitPayrollList[index].pf.toString().split(',');
    var accNoList = pyrlCtr.unitPayrollList[index].accNo.toString().split(',');
    var ifscList = pyrlCtr.unitPayrollList[index].ifscCode.toString().split(',');
    var bkNameList = pyrlCtr.unitPayrollList[index].bankName.toString().split(','); // ✅ Fix A/C Name
    var acList = pyrlCtr.unitPayrollList[index].aC.toString().split(','); // ✅ Fix A/C Name
    var opList = pyrlCtr.unitPayrollList[index].op.toString().split(','); // ✅ Fix A/C Name
    var bonusList = pyrlCtr.unitPayrollList[index].bonus.toString().split(','); // ✅ Fix A/C Name
    var bonus2List = pyrlCtr.unitPayrollList[index].bonus2.toString().split(','); // ✅ Fix A/C Name
    var foodList = pyrlCtr.unitPayrollList[index].food.toString().split(','); // ✅ Fix A/C Name
    var salaryList = pyrlCtr.unitPayrollList[index].salary.toString().split(
        ',');
    int rowCount;
    if(localData.storage.read("com_id")=="1"){
      rowCount = [
        namesList.length,
        empcdList.length,
        roleList.length,
        dutyList.length,
        otList.length,
        netAmtList.length,
        advanceList.length,
        uniformList.length,
        penaltyList.length,
        deductionList.length,
        totalList.length,
        basicList.length,
        hraList.length,
        daList.length,
        esiList.length,
        pfList.length,
        accNoList.length,
        accNoList.length,//
        accNoList.length,//
        ifscList.length,
        bkNameList.length
      ].reduce((a, b) => a > b ? a : b);
    }else{
      rowCount = [
        namesList.length,
        empcdList.length,
        roleList.length,
        dutyList.length,
        otList.length,
        netAmtList.length,
        advanceList.length,
        uniformList.length,
        penaltyList.length,
        deductionList.length,
        totalList.length,
        // basicList.length,
        hraList.length,
        daList.length,
        esiList.length,
        pfList.length,
        acList.length,
        accNoList.length,
        accNoList.length,//
        accNoList.length,//
        ifscList.length,
        bkNameList.length
      ].reduce((a, b) => a > b ? a : b);
    }

    // ✅ Totals calculation for all numeric fields
    double totalDuty = 0.0;
    double totalOt = 0.0;
    int totalEarning = 0;
    int totalAdvance = 0;
    int totalPenalty = 0;
    int totalUniform = 0;
    int totalDeduction = 0;
    int totalNetAmt = 0;

    int totalBasic = 0;
    int totalHra = 0;
    int totalDa = 0;
    int totalEsi = 0;
    int totalPf = 0;
    int totalOp = 0;
    int totalAd = 0;
    int totalB = 0;
    int totalB2 = 0;
    int totalFood = 0;

    if(unitName!=""){
       totalDuty = dutyList.fold(0.0, (sum, v) => sum + (double.tryParse(v) ?? 0.0));
       totalOt = otList.fold(0.0, (sum, v) => sum + (double.tryParse(v) ?? 0.0));
       totalEarning = totalList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalAdvance = advanceList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalPenalty = penaltyList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalUniform = uniformList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalDeduction = deductionList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalNetAmt = netAmtList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));

       totalBasic = basicList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalHra = hraList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalDa = daList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));

       totalAd = basicList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalB = hraList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalOp = daList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalEsi = esiList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalPf = pfList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalPf = pfList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalB2 = bonus2List.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
       totalFood = foodList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    }else{
       totalDuty = pyrlCtr.unitPayrollList.map((e) => double.tryParse(clean(e.duty.toString())) ?? 0.0).fold(0.0, (sum, v) => sum + v);
       totalOt = pyrlCtr.unitPayrollList.map((e) => double.tryParse(clean(e.ot.toString())) ?? 0.0).fold(0.0, (sum, v) => sum + v);
       totalEarning = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.total.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalAdvance = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.advance.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalPenalty = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.penalty.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalUniform = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.uniform.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalDeduction = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.deduction.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalNetAmt = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.netAmount.toString())) ?? 0).fold(0, (sum, v) => sum + v);

       totalBasic = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.basic.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalHra = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.hra.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalDa = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.da.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalEsi = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.esi.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalPf = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.pf.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalAd = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.aC.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalOp = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.op.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalB = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.bonus.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalB2 = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.bonus2.toString())) ?? 0).fold(0, (sum, v) => sum + v);
       totalFood = pyrlCtr.unitPayrollList.map((e) => int.tryParse(clean(e.food.toString())) ?? 0).fold(0, (sum, v) => sum + v);
    }

    // Build PDF content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(16),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                "Register Of Wages",
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                "Form No XVII",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 5),
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
                            pw.Text(localData.storage.read("com_name"),
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
                            pw.Text(" : ${unitName==""?"Team ${localData.storage.read("team_report_name")}":unitName}"),
                            pw.Text(" : ${pyrlCtr.month.value}")
                          ]
                      ),
                    ]
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            if(localData.storage.read("com_id")=="1")
           // Table
            unitName!=""?
            pw.Table.fromTextArray(
              headers: [
                "S.No",
                "Unit",
                "ID",
                "Name",
                "Rank",
                "Salary",
                "Duty",
                "OT",
                "Basic",
                "DA",
                "HRA",
                "Earning",
                "Advance",
                "Penalty",
                "Uniform",
                "Bonus",
                "Food Chg",
                "ESI",
                "PF",
                "Deduction",
                "Net salary",
                "A/C Name",  // ✅ Fixed
                "A/C No",
                "IFSC Code"
              ],
              data: List<List<String>>.generate(
                rowCount,
                    (i) => [
                  (i+1).toString(),
                  pyrlCtr.unitPayrollList[index].unitName.toString(),
                  getSafe(empcdList, i),
                  getSafe(namesList, i),
                  getSafe(roleList, i),
                  getSafe(salaryList, i),
                  getSafe(dutyList, i,isName: true),
                  getSafe(otList, i,isName: true),
                  getSafe(basicList, i),
                  getSafe(daList, i),
                  getSafe(hraList, i),
                  getSafe(totalList, i),
                  getSafe(advanceList, i),
                  getSafe(penaltyList, i),
                  getSafe(uniformList, i),
                  getSafe(bonus2List, i),
                  getSafe(foodList, i),
                  getSafe(esiList, i),
                  getSafe(pfList, i),
                  getSafe(deductionList, i),
                  getSafe(netAmtList, i),
                  getSafe(bkNameList, i), // ✅ A/C Name working
                  getSafe(accNoList, i,isName: true),
                  getSafe(ifscList, i),
                ],
              )..add([ // ✅ Total row update
                "",
                "",
                "",
                "",
                "Total",
                "",
                "$totalDuty",
                "$totalOt",
                "$totalBasic",
                "$totalDa",
                "$totalHra",
                "$totalEarning",
                "$totalAdvance",
                "$totalPenalty",
                "$totalUniform",
                "$totalB2",
                "$totalFood",
                "$totalEsi",
                "$totalPf",
                "$totalDeduction",
                "$totalNetAmt",
                "",
                "",
                ""
              ]),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9),
              cellStyle: pw.TextStyle(fontSize: 8),
              headerDecoration: pw.BoxDecoration(color: PdfColors.red),
              cellAlignment: pw.Alignment.center,
              cellPadding: const pw.EdgeInsets.all(2),
              border: pw.TableBorder.all(width: 0.5),

              // ✅ Adjust column widths properly
                columnWidths: {
                0: const pw.FixedColumnWidth(35),   // S.No
                1: const pw.FixedColumnWidth(50),   // Unit
                2: const pw.FixedColumnWidth(40),   // ID
                3: const pw.FixedColumnWidth(57),   // Name
                4: const pw.FixedColumnWidth(35),   // Rank
                5: const pw.FixedColumnWidth(45),   // Salary
                6: const pw.FixedColumnWidth(32),   // Duty
                7: const pw.FixedColumnWidth(25),   // OT
                8: const pw.FixedColumnWidth(40),   // Basic
                9: const pw.FixedColumnWidth(35),   // DA
                10: const pw.FixedColumnWidth(40),   // HRA
                11: const pw.FixedColumnWidth(50),  // Total
                12: const pw.FixedColumnWidth(54),  // Advance
                13: const pw.FixedColumnWidth(50),  // Penalty
                14: const pw.FixedColumnWidth(50),  // Uniform
                15: const pw.FixedColumnWidth(40),  // ESI
                16: const pw.FixedColumnWidth(35),  // PF
                17: const pw.FixedColumnWidth(25),  // Deduction
                18: const pw.FixedColumnWidth(25),  // Net Salary
                19: const pw.FixedColumnWidth(53),  // A/C Name
                20: const pw.FixedColumnWidth(50),  // A/C No
                21: const pw.FixedColumnWidth(50),  // IFSC Code
                22: const pw.FixedColumnWidth(50),  // IFSC Code
                23: const pw.FixedColumnWidth(50),  // IFSC Code
              },
            )
                :pw.Table.fromTextArray(
              headers: [
                "S.No",
                "Unit",
                "ID",
                "Name",
                "Rank",
                "Salary",
                "Duty",
                "OT",
                "Basic",
                "DA",
                "HRA",
                "Earning",
                "Advance",
                "Penalty",
                "Uniform",
                "Bonus",
                "Food Chg",
                "ESI",
                "PF",
                "Deduction",
                "Net salary",
                "A/C Name",  // ✅ Fixed
                "A/C No",
                "IFSC Code"
              ],
              data: List<List<String>>.generate(
                pyrlCtr.unitPayrollList.length,
                    (i) => [
                  (i+1).toString(),
                  pyrlCtr.unitPayrollList[i].unitName.toString(),
                  getSafe2(pyrlCtr.unitPayrollList[i].empcd.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].name.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].roleName.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].salary.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].duty.toString(),isName: true),
                  getSafe2(pyrlCtr.unitPayrollList[i].ot.toString(),isName: true),
                  getSafe2(pyrlCtr.unitPayrollList[i].basic.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].da.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].hra.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].total.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].advance.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].penalty.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].uniform.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].bonus2.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].food.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].esi.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].pf.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].deduction.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].netAmount.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].bankName.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].accNo.toString(),isName: true),
                  getSafe2(pyrlCtr.unitPayrollList[i].ifscCode.toString()),
                ],
              )..add([ // ✅ Total row update
                "",
                "",
                "",
                "",
                "Total",
                "",
                "$totalDuty",
                "$totalOt",
                "$totalBasic",
                "$totalDa",
                "$totalHra",
                "$totalEarning",
                "$totalAdvance",
                "$totalPenalty",
                "$totalUniform",
                "$totalB2",
                "$totalFood",
                "$totalEsi",
                "$totalPf",
                "$totalDeduction",
                "$totalNetAmt",
                "",
                "",
                ""
              ]),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9),
              cellStyle: pw.TextStyle(fontSize: 8),
              headerDecoration: pw.BoxDecoration(color: PdfColors.red),
              cellAlignment: pw.Alignment.center,
              cellPadding: const pw.EdgeInsets.all(2),
              border: pw.TableBorder.all(width: 0.5),

              // ✅ Adjust column widths properly
                columnWidths: {
                  0: const pw.FixedColumnWidth(35),   // S.No
                  1: const pw.FixedColumnWidth(50),   // Unit
                  2: const pw.FixedColumnWidth(40),   // ID
                  3: const pw.FixedColumnWidth(57),   // Name
                  4: const pw.FixedColumnWidth(35),   // Rank
                  5: const pw.FixedColumnWidth(45),   // Salary
                  6: const pw.FixedColumnWidth(32),   // Duty
                  7: const pw.FixedColumnWidth(25),   // OT
                  8: const pw.FixedColumnWidth(40),   // Basic
                  9: const pw.FixedColumnWidth(35),   // DA
                  10: const pw.FixedColumnWidth(40),   // HRA
                  11: const pw.FixedColumnWidth(50),  // Total
                  12: const pw.FixedColumnWidth(54),  // Advance
                  13: const pw.FixedColumnWidth(50),  // Penalty
                  14: const pw.FixedColumnWidth(50),  // Uniform
                  15: const pw.FixedColumnWidth(40),  // ESI
                  16: const pw.FixedColumnWidth(35),  // PF
                  17: const pw.FixedColumnWidth(25),  // Deduction
                  18: const pw.FixedColumnWidth(25),  // Net Salary
                  19: const pw.FixedColumnWidth(55),  // A/C Name
                  20: const pw.FixedColumnWidth(50),  // A/C No
                  21: const pw.FixedColumnWidth(50),  // IFSC Code
                  22: const pw.FixedColumnWidth(50),  // IFSC Code
                  23: const pw.FixedColumnWidth(50),  // IFSC Code
                },
            ),
            if(localData.storage.read("com_id")!="1")
           // Table
            unitName!=""?
            pw.Table.fromTextArray(
              headers: [
                "S.No",
                "Unit",
                "ID",
                "Name",
                "Rank",
                "Salary",
                "Duty",
                "OT",
                // "Basic",
                "Optional Salary",
                "Bonus",
                "Earning",
                "Advance",
                "Penalty",
                "Uniform",
                "Bonus",
                "Food Charges",
                "ESI",
                "PF",
                "Admin\nCharges",
                "Deduction",
                "Net salary",
                "A/C Name",  // ✅ Fixed
                "A/C No",
                "IFSC Code"
              ],
              data: List<List<String>>.generate(
                rowCount,
                    (i) => [
                  (i+1).toString(),
                  pyrlCtr.unitPayrollList[index].unitName.toString(),
                  getSafe(empcdList, i),
                  getSafe(namesList, i),
                  getSafe(roleList, i),
                  getSafe(salaryList, i),
                  getSafe(dutyList, i,isName: true),
                  getSafe(otList, i,isName: true),
                  // getSafe(basicList, i),
                  "${double.parse(opList[i])*double.parse(dutyList[i])}",
                  "${double.parse(bonusList[i])*double.parse(dutyList[i])}",
                  getSafe(totalList, i),
                  getSafe(advanceList, i),
                  getSafe(penaltyList, i),
                  getSafe(uniformList, i),
                  getSafe(bonus2List, i),
                  getSafe(foodList, i),
                  getSafe(esiList, i),
                  getSafe(pfList, i),
                  "${double.parse(acList[i])*double.parse(dutyList[i])}",
                  getSafe(deductionList, i),
                  getSafe(netAmtList, i),
                  getSafe(bkNameList, i), // ✅ A/C Name working
                  getSafe(accNoList, i,isName: true),
                  getSafe(ifscList, i),
                ],
              )..add([ // ✅ Total row update
                "",
                "",
                "",
                "",
                "Total",
                "",
                "$totalDuty",
                "$totalOt",
                // "$totalBasic",
                "",
                "",
                "$totalEarning",
                "$totalAdvance",
                "$totalPenalty",
                "$totalUniform",
                "$totalB2",
                "$totalFood",
                "$totalEsi",
                "$totalPf",
                "",
                "$totalDeduction",
                "$totalNetAmt",
                "",
                "",
                ""
              ]),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9),
              cellStyle: pw.TextStyle(fontSize: 8),
              headerDecoration: pw.BoxDecoration(color: PdfColors.red),
              cellAlignment: pw.Alignment.center,
              cellPadding: const pw.EdgeInsets.all(2),
              border: pw.TableBorder.all(width: 0.5),

              // ✅ Adjust column widths properly
                columnWidths: {
                0: const pw.FixedColumnWidth(35),   // S.No
                1: const pw.FixedColumnWidth(50),   // Unit
                2: const pw.FixedColumnWidth(40),   // ID
                3: const pw.FixedColumnWidth(57),   // Name
                4: const pw.FixedColumnWidth(35),   // Rank
                5: const pw.FixedColumnWidth(45),   // Salary
                6: const pw.FixedColumnWidth(32),   // Duty
                7: const pw.FixedColumnWidth(25),   // OT
                8: const pw.FixedColumnWidth(57),   // op
                9: const pw.FixedColumnWidth(42),   // b
                10: const pw.FixedColumnWidth(50),   // HRA
                11: const pw.FixedColumnWidth(57),  // Total
                12: const pw.FixedColumnWidth(54),  // Advance
                13: const pw.FixedColumnWidth(50),  // Penalty
                14: const pw.FixedColumnWidth(47),  // Uniform
                15: const pw.FixedColumnWidth(38),  // ESI
                16: const pw.FixedColumnWidth(70),  // PF
                17: const pw.FixedColumnWidth(25),  // PF
                18: const pw.FixedColumnWidth(25),  // Deduction
                19: const pw.FixedColumnWidth(38),  // Net Salary
                20: const pw.FixedColumnWidth(55),  // A/C Name
                21: const pw.FixedColumnWidth(50),  // A/C No
                22: const pw.FixedColumnWidth(50),  // IFSC Code
                23: const pw.FixedColumnWidth(50),  // IFSC Code
              },
            )
                :pw.Table.fromTextArray(
              headers: [
                "S.No",
                "Unit",
                "ID",
                "Name",
                "Rank",
                "Salary",
                "Duty",
                "OT",
                // "Basic",
                "Optional Salary",
                "Bonus",
                "Earning",
                "Advance",
                "Penalty",
                "Uniform",
                "Bonus",
                "Food Charges",
                "ESI",
                "PF",
                "Admin\nCharges",
                "Deduction",
                "Net salary",
                "A/C Name",  // ✅ Fixed
                "A/C No",
                "IFSC Code"
              ],
              data: List<List<String>>.generate(
                pyrlCtr.unitPayrollList.length,
                    (i) => [
                  (i+1).toString(),
                  pyrlCtr.unitPayrollList[i].unitName.toString(),
                  getSafe2(pyrlCtr.unitPayrollList[i].empcd.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].name.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].roleName.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].salary.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].duty.toString(),isName: true),
                  getSafe2(pyrlCtr.unitPayrollList[i].ot.toString(),isName: true),
                  // getSafe2(pyrlCtr.unitPayrollList[i].basic.toString()),
                  getSafe2("${double.parse(pyrlCtr.unitPayrollList[i].op.toString())*double.parse(pyrlCtr.unitPayrollList[i].duty.toString())}"),
                  getSafe2("${double.parse(pyrlCtr.unitPayrollList[i].bonus.toString())*double.parse(pyrlCtr.unitPayrollList[i].duty.toString())}"),
                  getSafe2(pyrlCtr.unitPayrollList[i].total.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].advance.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].penalty.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].uniform.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].bonus2.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].food.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].esi.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].pf.toString()),
                  getSafe2("${double.parse(pyrlCtr.unitPayrollList[i].aC.toString())*double.parse(pyrlCtr.unitPayrollList[i].duty.toString())}"),
                  getSafe2(pyrlCtr.unitPayrollList[i].deduction.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].netAmount.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].bankName.toString()),
                  getSafe2(pyrlCtr.unitPayrollList[i].accNo.toString(),isName: true),
                  getSafe2(pyrlCtr.unitPayrollList[i].ifscCode.toString()),
                ],
              )..add([ // ✅ Total row update
                "",
                "",
                "",
                "",
                "Total",
                "",
                "$totalDuty",
                "$totalOt",
                // "$totalBasic",
                "",
                "",
                "$totalEarning",
                "$totalAdvance",
                "$totalPenalty",
                "$totalUniform",
                "$totalB2",
                "$totalFood",
                "$totalEsi",
                "$totalPf",
                "",
                "$totalDeduction",
                "$totalNetAmt",
                "",
                "",
                ""
              ]),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9),
              cellStyle: pw.TextStyle(fontSize: 8),
              headerDecoration: pw.BoxDecoration(color: PdfColors.red),
              cellAlignment: pw.Alignment.center,
              cellPadding: const pw.EdgeInsets.all(2),
              border: pw.TableBorder.all(width: 0.5),

              // ✅ Adjust column widths properly
                columnWidths: {
                  0: const pw.FixedColumnWidth(35),   // S.No
                  1: const pw.FixedColumnWidth(50),   // Unit
                  2: const pw.FixedColumnWidth(40),   // ID
                  3: const pw.FixedColumnWidth(57),   // Name
                  4: const pw.FixedColumnWidth(35),   // Rank
                  5: const pw.FixedColumnWidth(45),   // Salary
                  6: const pw.FixedColumnWidth(32),   // Duty
                  7: const pw.FixedColumnWidth(25),   // OT
                  8: const pw.FixedColumnWidth(57),   // op
                  9: const pw.FixedColumnWidth(42),   // b
                  10: const pw.FixedColumnWidth(50),   // HRA
                  11: const pw.FixedColumnWidth(57),  // Total
                  12: const pw.FixedColumnWidth(54),  // Advance
                  13: const pw.FixedColumnWidth(50),  // Penalty
                  14: const pw.FixedColumnWidth(47),  // Uniform
                  15: const pw.FixedColumnWidth(38),  // ESI
                  16: const pw.FixedColumnWidth(70),  // PF
                  17: const pw.FixedColumnWidth(25),  // PF
                  18: const pw.FixedColumnWidth(25),  // Deduction
                  19: const pw.FixedColumnWidth(38),  // Net Salary
                  20: const pw.FixedColumnWidth(55),  // A/C Name
                  21: const pw.FixedColumnWidth(50),  // A/C No
                  22: const pw.FixedColumnWidth(50),  // IFSC Code
                  23: const pw.FixedColumnWidth(50),  // IFSC Code
                },
            ),
          ];
        },
      ),
    );

    // // Show PDF preview
    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );
    // Save PDF bytes
    Uint8List bytes = await pdf.save();
    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', '${unitName==""?"Team ${localData.storage.read("team_report_name")}":unitName} Register Of Wages - ${pyrlCtr.month.value}.pdf')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/${unitName==""?"Team ${localData.storage.read("team_report_name")}":unitName} Register Of Wages - ${pyrlCtr.month.value}.pdf';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }

}
