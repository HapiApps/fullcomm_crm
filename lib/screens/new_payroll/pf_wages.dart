import 'dart:convert';
import 'dart:io';
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
import '../../component/loading.dart';
import '../../component/month_calender.dart';
import '../../constant/color_constant.dart';
import '../../constant/local_data.dart';
import '../../controller/new_payroll_controller.dart';
import '../../controller/payroll_controller.dart';
import '../../styles/decoration.dart';
import '../../utills/utilities.dart';
import '../../widgets/widgets_functions.dart';
import 'dashboard.dart';

class PFWages extends StatefulWidget {
  const PFWages({super.key});

  @override
  State<PFWages> createState() => _PFWagesState();
}

class _PFWagesState extends State<PFWages> {
  var newPyrlServ = NewPayrollApiServices.instance;

  @override
  void initState() {
    newPyrlServ.getPfWages();
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
            child: app_bar(text: "PF Wages", callback1: () {
              Get.to(const NewPayroll(),
                  transition: Transition.rightToLeftWithFade,
                  duration: const Duration(seconds: 1));
            })),
        body: Obx(() =>
            Column(
              children: [
                InkWell(
                    onTap: () {
                      showMonthPicker(
                        context: context,
                        month: pyrlCtr.month,
                        function: (){
                          newPyrlServ.getPfWages();
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
                10.height,
                pyrlCtr.getData.value == false ?
                const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Loading(),
                ) :
                pyrlCtr.unitPayrollList.isEmpty ?
                const CustomText(text: "\n\n\n\n\n\nNo data Found") :
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: kIsWeb ? webSize : mobileSize,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  pfWagesPayrollExport();
                                },
                                child: const CustomText(
                                  text: "Download",
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: Container(
                              width: kIsWeb ? webSize : mobileSize,
                              decoration: customDecoration
                                  .baseBackgroundDecoration(
                                color: Colors.white,
                                radius: 10,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [

                                    Table(
                                      border: TableBorder.all(
                                          color: Colors.grey.shade300),
                                      columnWidths: const {
                                        0: FlexColumnWidth(0.7), // S.No
                                        1: FlexColumnWidth(1.5), // Site
                                        2: FlexColumnWidth(1.2), // ID
                                        3: FlexColumnWidth(2.2), // Name
                                        4: FlexColumnWidth(1.5), // UAN No
                                        5: FlexColumnWidth(1.3), // Working Days
                                        6: FlexColumnWidth(1.5), // Salary Wages
                                        7: FlexColumnWidth(1.5), // PF Wages
                                        8: FlexColumnWidth(1.5), // Pay Amount
                                        9: FlexColumnWidth(1.5), // DOB
                                        10: FlexColumnWidth(1.5), // DOJ
                                        11: FlexColumnWidth(1.5), // Age
                                        12: FlexColumnWidth(1.5), // Father Name
                                        13: FlexColumnWidth(1.5), // Phone Number
                                      },
                                      children: [
                                        // Header Row
                                        TableRow(
                                          decoration: const BoxDecoration(
                                              color: Colors.black12),
                                          children: [
                                            customWid("S.No", bold: true),
                                            customWid("Site Name", bold: true),
                                            customWid("ID No", bold: true),
                                            customWid("Name", bold: true),
                                            customWid("UAN No", bold: true),
                                            customWid("Working Days", bold: true),
                                            customWid("Salary Wages", bold: true),
                                            customWid("PF Wages", bold: true),
                                            customWid("Pay Amount", bold: true),
                                            customWid("Date Of Birth", bold: true),
                                            customWid("Date Of Joining", bold: true),
                                            customWid("Age", bold: true),
                                            customWid("Father Name", bold: true),
                                            customWid("Phone Number", bold: true),
                                          ],
                                        ),

                                        // Data Rows
                                        for (int i = 0; i < pyrlCtr.unitPayrollList.length; i++)
                                          TableRow(
                                            children: [
                                              customWid((i + 1).toString()),
                                              customWid(pyrlCtr.unitPayrollList[i].unitName ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].empcd ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].name ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].pfNo ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].duty ?? ''),
                                              // customWid(
                                              //     "${((int.parse(pyrlCtr.unitPayrollList[i].pfWages.toString()) /
                                              //         int.parse(payrollCtr.lastDate.toString())) *
                                              //         int.parse(pyrlCtr.unitPayrollList[i].duty.toString()))
                                              //         .round()}"
                                              // ),
                                              customWid(pyrlCtr.unitPayrollList[i].total ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].pfWagesAmt ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].pf ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].dob.toString()=="null"?"":utils.formatDob(pyrlCtr.unitPayrollList[i].dob.toString())),
                                              customWid(pyrlCtr.unitPayrollList[i].doj.toString()=="null"?"":utils.formatDob(pyrlCtr.unitPayrollList[i].doj.toString())),
                                              customWid(calculateAge(pyrlCtr.unitPayrollList[i].dob.toString())),
                                              customWid(pyrlCtr.unitPayrollList[i].fn ?? ''),
                                              customWid(pyrlCtr.unitPayrollList[i].phoneNo ?? ''),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ))
    );
  }
  String calculateAge(String dob) {
    if (dob.isEmpty) return '';

    try {
      DateTime birthDate;

      // Try parsing as yyyy-MM-dd first
      if (dob.contains('-')) {
        List<String> parts = dob.split('-');

        if (parts[0].length == 4) {
          // Format: yyyy-MM-dd
          int year = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int day = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        } else {
          // Format: dd-MM-yyyy
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        }
      } else if (dob.contains('/')) {
        // Handle yyyy/MM/dd or dd/MM/yyyy
        List<String> parts = dob.split('/');
        if (parts[0].length == 4) {
          int year = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int day = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        } else {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        }
      } else {
        return '';
      }

      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age.toString();
    } catch (e) {
      return '';
    }
  }

  Widget customWid(String value, {double? width = 8,bool? bold = false}){
    return Padding(
        padding: const EdgeInsets.all(8),
        child: CustomText(text: value,isBold: bold,));
  }

  Future<void> pfWagesPayrollExport() async {
    String clean(String? value) {
      if (value == null || value.toLowerCase() == "null") {
        return "";
      }
      return value;
    }

    String getSafe(List<String> list, int idx) {
      return idx < list.length ? clean(list[idx]) : '';
    }

    final Workbook workbook = Workbook();
    final Worksheet worksheet = workbook.worksheets[0];

    // Header format
    worksheet.getRangeByName('A1:N1').merge();
    worksheet
        .getRangeByName('A1:N1')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet.getRangeByName('A2:H2').merge();
    worksheet.getRangeByName('I2:N2').merge();
    worksheet
        .getRangeByName('A2:N2')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet
        .getRangeByName('A2:N2')
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
        .getRangeByName('A3:N3')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A3')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A3:N3')
        .cellStyle
        .backColor = '#CA1617';
    worksheet
        .getRangeByName('A3:N3')
        .cellStyle
        .fontColor = '#ffffff';

    // Report Title
    worksheet.getRangeByName("A1").setText("PF Wages Sheet");
    worksheet
        .getRangeByName("A2:H2")
        .rowHeight = 60; // height adjust pannalam


    worksheet.getRangeByName("A2").setText(
        "${localData.storage.read("com_name")}\n Address : 44/1, V.V. Koil Street, Tambaram Sanatorium,Chennai-600 045,Tamilnadu, India.");
    worksheet.getRangeByName("I2").setText(
        "Month : ${pyrlCtr.month.value}");

    // Headers`
    List<String> headers = [
      "S.No",
      "Site Name",
      "ID No",
      "Name",
      "UAN No",
      "Working Days",
      "Salary wages",
      "PF Wages",
      "Pay Amount",
      "Date Of Birth",
      "Date Of Joining",
      "Age",
      "Father Name",
      "Phone Number",
    ];
    for (int j = 0; j < headers.length; j++) {
      worksheet.getRangeByIndex(3, j + 1).setText(headers[j]);
    }


    // Fill data
    for (int i = 0; i < pyrlCtr.unitPayrollList.length; i++) {
      worksheet.getRangeByIndex(i + 4, 1).setText("${i + 1}"); // S.No
      worksheet.getRangeByIndex(i + 4, 2).setText(pyrlCtr.unitPayrollList[i].unitName); // Site Name
      worksheet.getRangeByIndex(i + 4, 3).setText(pyrlCtr.unitPayrollList[i].empcd); // ID No
      worksheet.getRangeByIndex(i + 4, 4).setText(pyrlCtr.unitPayrollList[i].name); // ID No
      worksheet.getRangeByIndex(i + 4, 5).setText(pyrlCtr.unitPayrollList[i].pfNo); // ID No
      worksheet.getRangeByIndex(i + 4, 6).setText(pyrlCtr.unitPayrollList[i].duty); // ID No
      worksheet.getRangeByIndex(i + 4, 7).setText(pyrlCtr.unitPayrollList[i].total); // ID No
      // worksheet.getRangeByIndex(i + 4, 7).setText("${((int.parse(pyrlCtr.unitPayrollList[i].pfWages.toString()) /
      //     int.parse(payrollCtr.lastDate.toString())) *
      //     int.parse(pyrlCtr.unitPayrollList[i].duty.toString())).round()}"); // ID No
      worksheet.getRangeByIndex(i + 4, 8).setText(pyrlCtr.unitPayrollList[i].pfWagesAmt); // ID No
      worksheet.getRangeByIndex(i + 4, 9).setText(pyrlCtr.unitPayrollList[i].pf); // ID No
      worksheet.getRangeByIndex(i + 4, 10).setText(pyrlCtr.unitPayrollList[i].dob.toString()=="null"?"":utils.formatDob(pyrlCtr.unitPayrollList[i].dob.toString())); // ID No
      worksheet.getRangeByIndex(i + 4, 11).setText(pyrlCtr.unitPayrollList[i].doj.toString()=="null"?"":utils.formatDob(pyrlCtr.unitPayrollList[i].doj.toString())); // ID No
      worksheet.getRangeByIndex(i + 4, 12).setText(calculateAge(pyrlCtr.unitPayrollList[i].dob.toString())); // ID No
      worksheet.getRangeByIndex(i + 4, 13).setText(pyrlCtr.unitPayrollList[i].fn); // ID No
      worksheet.getRangeByIndex(i + 4, 14).setText(pyrlCtr.unitPayrollList[i].phoneNo); // ID No
    }

    // Save
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', '${pyrlCtr.month.value} PF Wages Sheet.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/${pyrlCtr.month.value} PF Wages Sheet.xlsx';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }

}
