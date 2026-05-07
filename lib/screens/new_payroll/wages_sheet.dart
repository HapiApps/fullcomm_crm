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
import '../../billing_utils/sized_box.dart';
import '../../common/constant/api.dart' as assets;
import '../../common/constant/colors_constant.dart';
import '../../common/styles/decoration.dart';
import '../../common/utilities/utils.dart';
import '../../components/Customtext.dart';
import '../../components/custom_sidebar.dart';
import '../../components/emp_drop.dart';
import '../../components/month_calender.dart';
import '../../controller/controller.dart';
import '../../controller/new_payroll_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../models/payroll/unit_model.dart';
import '../../services/new_payroll_api_services.dart';
import 'dart:typed_data';

class UnitSlip extends StatefulWidget {
  const UnitSlip({super.key});

  @override
  State<UnitSlip> createState() => _UnitSlipState();
}

class _UnitSlipState extends State<UnitSlip> {
  var newPyrlServ = NewPayrollApiServices.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pyrlCtr.users.clear();
      pyrlCtr.unitPayrollList.clear();
      newPyrlServ.getUnitPayroll();
    });
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
                child: Obx(() =>
                    Column(
                      children: [
                        30.height,
                        Row(
                          children: [
                            IconButton(onPressed: (){
                              Get.back();
                            }, icon: Icon(Icons.arrow_back)),
                            CustomText(
                              text: "Wages Sheet",
                              colors: colorsConst.textColor,
                              size: 20,
                              isBold: true,
                              isCopy: true,
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade500,thickness: 0.5,),
                        10.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                                onTap: () {
                                  showMonthPicker2(
                                    context: context,
                                    month: pyrlCtr.month,
                                    function: (){
                                      newPyrlServ.getUnitPayroll();
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
                                        size: 15, isCopy: true,),
                                  ],
                                )),
                          ],
                        ),
                        10.height,
                        pyrlCtr.getData.value == false ?
                        const Padding(
                          padding: EdgeInsets.all(25.0),
                          child: CircularProgressIndicator(),
                        ):
                        pyrlCtr.unitPayrollList.isEmpty ?
                        const CustomText(text: "\n\n\n\n\n\nNo Data Found", isCopy: true,) :
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
                                              ElevatedButton(onPressed: () {
                                                // generateSinglePayrollPdf(pyrlCtr.unitPayrollList[index]);
                                                unitPayrollExport(index, unitName: "unitname");
                                              },
                                                  child: const CustomText(text: "Excel",
                                                    isBold: true,
                                                    colors: Colors.white, isCopy: true,)),
                                              10.width,
                                              ElevatedButton(onPressed: () {
                                                unitPayrollPreviewPdf(index, unitName: "unitname");
                                              },
                                                  child: const CustomText(text: "PDF",
                                                      isBold: true,
                                                      colors: Colors.white, isCopy: true,)), 10.width
                                            ],
                                          ),
                                        Table(
                                          border: TableBorder.all(
                                              color: Colors.grey.shade300),
                                          columnWidths: {
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
                                          },
                                          children: [
                                            // Header Row
                                            if(index==0)
                                              TableRow(
                                                decoration: const BoxDecoration(
                                                    color: Colors.black12),
                                                children: [
                                                  customWid("S.No",bold: true,),
                                                  customWid("Rank",bold: true,),
                                                  customWid("Name",bold: true,),
                                                  customWid("Duty",bold: true,),
                                                  customWid("OT",bold: true,),
                                                  customWid("Basic",bold: true,),
                                                  customWid("DA",bold: true,),
                                                  customWid("HRA",bold: true,),
                                                  customWid("Earning",bold: true,),
                                                  customWid("Advance",bold: true,),
                                                  customWid("Uniform",bold: true,),
                                                  customWid("Penalty",bold: true,),
                                                  customWid("Bonus",bold: true,),
                                                  customWid("Food Charges",bold: true,),
                                                  customWid("ESI",bold: true,),
                                                  customWid("PF",bold: true,),
                                                  customWid("Deduction",bold: true,),
                                                  customWid("Net Amt",bold: true,),
                                                ],
                                              ),
                
                                            // Data Rows
                                              for (int i = 0; i < namesList.length; i++)
                                                TableRow(
                                                  children: [
                                                    customWid((i+1).toString()),
                                                    customWid(roleList[i]),
                                                    customWid(namesList[i]),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: CustomText(
                                                        text: dutyList[i], isCopy: true,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8),
                                                      child: CustomText(
                                                        text: otList[i], isCopy: true,
                                                      ),
                                                    ),
                                                    customWid(basicList[i]),
                                                    customWid(daList[i]),
                                                    customWid(hraList[i]),
                                                    customWid(totalList[i]),
                                                    customWid(advanceList[i]),
                                                    customWid(uniformList[i]),
                                                    customWid(penaltyList[i]),
                                                    customWid(bonus2List[i]),
                                                    customWid(foodList[i]),
                                                    customWid(esiList[i]),
                                                    customWid(pfList[i]),
                                                    customWid(deductionList[i]),
                                                    customWid(netAmtList[i]),
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
                    )),
              ),
            ],
          )
      ),
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
        isBold: bold, isCopy: true,
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
        "${controllers.comName.text}\n Address : ${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
            " ${controllers.comCountry.text}, ${controllers.comPincode.text}");
    worksheet.getRangeByName("L3").setText(
        "Month : ${pyrlCtr.month.value}");
    List<String> headers = [
        "S.No",
        "Rank",
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
    int rowCountEx = [
      namesList.length,
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
        for (int i = 0; i < rowCountEx; i++) {
          worksheet.getRangeByIndex(i + 5, 1).setText("${i + 1}");
          worksheet.getRangeByIndex(i + 5, 2).setText(getSafe(roleList, i));
          worksheet.getRangeByIndex(i + 5, 3).setText(getSafe(namesList, i));
          worksheet.getRangeByIndex(i + 5, 4).setText(getSafe(salaryList, i));
          worksheet.getRangeByIndex(i + 5, 5).setText(getSafe(dutyList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 6).setText(getSafe(otList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 7).setText(getSafe(basicList, i));
          worksheet.getRangeByIndex(i + 5, 8).setText(getSafe(daList, i));
          worksheet.getRangeByIndex(i + 5, 9).setText(getSafe(hraList, i));
          worksheet.getRangeByIndex(i + 5, 10).setText(getSafe(totalList, i));
          worksheet.getRangeByIndex(i + 5, 11).setText(getSafe(esiList, i));
          worksheet.getRangeByIndex(i + 5, 12).setText(getSafe(pfList, i));
          worksheet.getRangeByIndex(i + 5, 13).setText(getSafe(advanceList, i));
          worksheet.getRangeByIndex(i + 5, 14).setText(getSafe(penaltyList, i));
          worksheet.getRangeByIndex(i + 5, 15).setText(getSafe(uniformList, i));
          worksheet.getRangeByIndex(i + 5, 16).setText(getSafe(bonus2List, i));
          worksheet.getRangeByIndex(i + 5, 17).setText(getSafe(foodList, i));
          worksheet.getRangeByIndex(i + 5, 18).setText(getSafe(deductionList, i));
          worksheet.getRangeByIndex(i + 5, 19).setText(getSafe(netAmtList, i));
          worksheet.getRangeByIndex(i + 5, 20).setText(getSafe(bkNameList, i));
          worksheet.getRangeByIndex(i + 5, 21).setText(getSafe(accNoList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 22).setText(getSafe(ifscList, i));
        }

    // Save
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', 'Register Of Wages - ${pyrlCtr.month.value}.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/Register Of Wages - ${pyrlCtr.month.value}.xlsx';
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
    int rowCount = [
      namesList.length,
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
                            pw.Text(controllers.comName.text,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                "Address: ${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
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
                      ),
                    ]
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Table.fromTextArray(
              headers: [
                "S.No",
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
               columnWidths: {
                0: const pw.FixedColumnWidth(35),   // S.No
                1: const pw.FixedColumnWidth(57),   // Name
                2: const pw.FixedColumnWidth(35),   // Rank
                3: const pw.FixedColumnWidth(45),   // Salary
                4: const pw.FixedColumnWidth(32),   // Duty
                5: const pw.FixedColumnWidth(25),   // OT
                6: const pw.FixedColumnWidth(40),   // Basic
                7: const pw.FixedColumnWidth(35),   // DA
                8: const pw.FixedColumnWidth(40),   // HRA
                9: const pw.FixedColumnWidth(50),  // Total
                10: const pw.FixedColumnWidth(54),  // Advance
                11: const pw.FixedColumnWidth(50),  // Penalty
                12: const pw.FixedColumnWidth(50),  // Uniform
                13: const pw.FixedColumnWidth(40),  // ESI
                14: const pw.FixedColumnWidth(35),  // PF
                15: const pw.FixedColumnWidth(25),  // Deduction
                16: const pw.FixedColumnWidth(25),  // Net Salary
                17: const pw.FixedColumnWidth(53),  // A/C Name
                18: const pw.FixedColumnWidth(50),  // A/C No
                19: const pw.FixedColumnWidth(50),  // IFSC Code
                20: const pw.FixedColumnWidth(50),  // IFSC Code
                21: const pw.FixedColumnWidth(50),  // IFSC Code
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
        ..setAttribute('download', 'Register Of Wages - ${pyrlCtr.month.value}.pdf')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/"Register Of Wages - ${pyrlCtr.month.value}.pdf';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }

}
