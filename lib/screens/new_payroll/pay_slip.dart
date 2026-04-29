import 'dart:io';
import 'package:fullcomm_crm/screens/new_payroll/search_bar.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../billing_utils/sized_box.dart';
import '../../common/constant/api.dart' as assets;
import '../../common/constant/colors_constant.dart';
import '../../common/styles/decoration.dart';
import '../../common/utilities/utils.dart';
import '../../components/Customtext.dart';
import '../../components/custom_sidebar.dart';
import '../../components/month_calender.dart';
import '../../controller/controller.dart';
import '../../controller/new_payroll_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../models/payroll/monthly_unit_payroll.dart';
import '../../services/new_payroll_api_services.dart';

class PaySlip extends StatefulWidget {
  const PaySlip({super.key});

  @override
  State<PaySlip> createState() => _PaySlipState();
}

class _PaySlipState extends State<PaySlip> {
  var newPyrlServ = NewPayrollApiServices.instance;
  String empId="";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pyrlCtr.unitPayrollList.clear();
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
                              text: "Pay Slip",
                              colors: colorsConst.textColor,
                              size: 20,
                              isBold: true,
                              isCopy: true,
                            ),
                          ],
                        ),
                        10.height,
                        InkWell(
                            onTap: () {
                              showMonthPicker(
                                context: context,
                                month: pyrlCtr.month,
                                function: (){
                                  if(empId!=""){
                                    newPyrlServ.getPaySlip(empId);
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
                                    size: 15, isCopy: true,),
                              ],
                            )),
                        EmployeeSearchBox(
                          allEmployees: pyrlCtr.allEmpList,
                          onEmployeeSelected: (selectedEmployee) {
                            setState(() {
                              // Save selected employee details
                              controllers.storage.write("p_emp_id", selectedEmployee.id);
                              controllers.storage.write("p_emp_name", selectedEmployee.fName);
                              empId=selectedEmployee.id.toString();
                              newPyrlServ.getPaySlip(empId);
                            });
                          },
                        ),
                        10.height,
                        pyrlCtr.getData.value == false ?
                        const Padding(
                          padding: EdgeInsets.all(25.0),
                          child: CircularProgressIndicator(),
                        ) :
                        pyrlCtr.unitPayrollList.isEmpty ?
                        const CustomText(text: "\n\n\n\n\n\nNo Data Found", isCopy: true,) :
                        Expanded(
                          child: SizedBox(
                            width: kIsWeb ? webSize : mobileSize,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(onPressed: () {
                                      generatePayrollPdf(pyrlCtr.unitPayrollList);
                                    },
                                        child: const CustomText(text: "PDF",
                                            isBold: true,
                                            colors: Colors.white, isCopy: true,)), 10.width
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
                                              15: FlexColumnWidth(1.7), // netAmt
                                            },
                                            children: [
                                              // Header Row
                                              TableRow(
                                                decoration: const BoxDecoration(
                                                    color: Colors.black12),
                                                children: [
                                                  customWid("S.No",bold: true,),
                                                  customWid("ID",bold: true,),
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
                                                  customWid("ESI",bold: true,),
                                                  customWid("PF",bold: true,),
                                                  customWid("Deduction",bold: true,),
                                                  customWid("Net Amt",bold: true,),
                                                ],
                                              ),

                                              // Data Rows
                                              for (int i = 0; i < pyrlCtr.unitPayrollList.length; i++)
                                                TableRow(
                                                  children: [
                                                    customWid((i+1).toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].empcd.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].roleName.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].name.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].duty.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].ot.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].basic.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].da.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].hra.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].total.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].advance.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].uniform.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].penalty.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].esi.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].pf.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].deduction.toString()),
                                                    customWid(pyrlCtr.unitPayrollList[i].netAmount.toString()),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
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

  Widget customWid(String value, {double? width = 8,bool? bold = false}){
    return Padding(
        padding: const EdgeInsets.all(8),
        child: CustomText(text: value,isBold: bold!, isCopy: true,));
  }
  // static Future<void> generatePayrollPdf(RxList<UnitPayroll> unitPayrollList) async {
  //   final pdf = pw.Document();
  //
  //   // Load logo
  //   final imageByteData = await rootBundle.load(assets.logo);
  //   final imageList = imageByteData.buffer.asUint8List(
  //       imageByteData.offsetInBytes, imageByteData.lengthInBytes);
  //   final image = pw.MemoryImage(imageList);
  //
  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       margin: const pw.EdgeInsets.all(20),
  //       build: (context) {
  //         return [
  //           // Header
  //           pw.Row(
  //             crossAxisAlignment: pw.CrossAxisAlignment.start,
  //             children: [
  //               pw.Image(image, width: 80, height: 80),
  //               pw.SizedBox(width: 10),
  //               pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: [
  //                   pw.Text(
  //                     "Thirumal Facilities Service",
  //                     style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
  //                   ),
  //                   pw.Text(
  //                     "Address: 44/1, V.V. Koil Street, Tambaram Sanatorium,\nChennai-600 045, Tamilnadu, India.",
  //                     style: pw.TextStyle(fontSize: 10),
  //                   ),
  //                 ],
  //               ),
  //               pw.Text(
  //                 pyrlCtr.month.value,
  //                 style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold),
  //               ),
  //             ],
  //           ),
  //           pw.SizedBox(height: 20),
  //
  //           // Payroll Table for each employee
  //           ...unitPayrollList.map((e) {
  //             final json = e.toJson();
  //
  //             return pw.Container(
  //               margin: const pw.EdgeInsets.only(bottom: 15),
  //               padding: const pw.EdgeInsets.all(8),
  //               decoration: pw.BoxDecoration(
  //                 border: pw.Border.all(color: PdfColor.fromInt(0xffcccccc)),
  //                 borderRadius: pw.BorderRadius.circular(4),
  //               ),
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: [
  //                   // Employee Info Table
  //                   pw.Table(
  //                     columnWidths: {
  //                       0: const pw.FlexColumnWidth(2),
  //                       1: const pw.FlexColumnWidth(3),
  //                       2: const pw.FlexColumnWidth(2),
  //                       3: const pw.FlexColumnWidth(3),
  //                     },
  //                     border: pw.TableBorder.all(color: PdfColor.fromInt(0xffcccccc)),
  //                     children: [
  //                       _tableRow("Name", json['name'], "Rank", json['role_name']),
  //                       _tableRow("Father Name", json['fathername'], "ESI No", json['esi_no']),
  //                       _tableRow("PF No", json['pf_no'], "Site Name", json['unit_name']),
  //                       _tableRow("ID No", json['emp_cd_1'], "Phone", json['phoneNo']),
  //                       _tableRow("D.O.B", json['dob'], "D.O.J", json['doj']),
  //                     ],
  //                   ),
  //                   pw.SizedBox(height: 8),
  //
  //                   // Salary Table
  //                   pw.Table(
  //                     columnWidths: {
  //                       0: const pw.FlexColumnWidth(2),
  //                       1: const pw.FlexColumnWidth(2),
  //                       2: const pw.FlexColumnWidth(2),
  //                       3: const pw.FlexColumnWidth(2),
  //                     },
  //                     border: pw.TableBorder.all(color: PdfColor.fromInt(0xffcccccc)),
  //                     children: [
  //                       _tableRow("Duty", json['duty'], "Basic", json['basic']),
  //                       _tableRow("DA", json['da'], "HRA", json['hra']),
  //                       _tableRow("NFH", json['nfh'], "SFH", json['sfh']),
  //                       _tableRow("Others", json['others'], "Total", json['total']),
  //                       _tableRow("Net Amount", json['net_amount'], "ESI", json['esi']),
  //                       _tableRow("PF", json['pf'], "PT", json['pt']),
  //                       _tableRow("Advance", json['advance'], "Uniform", json['uniform']),
  //                       _tableRow("Penalty", json['penalty'], "Deduction", json['deduction']),
  //                     ],
  //                   ),
  //                   pw.SizedBox(height: 5),
  //
  //                   // Bank Details
  //                   pw.Text('Bank Name: ${json['bank_name'] ?? ''}'),
  //                   pw.Text('A/C No: ${json['acc_no'] ?? ''}'),
  //                   pw.Text('IFSC Code: ${json['ifsc_code'] ?? ''}'),
  //                 ],
  //               ),
  //             );
  //           }).toList(),
  //         ];
  //       },
  //     ),
  //   );
  //
  //   // Mobile vs Web
  //   if (kIsWeb) {
  //     await Printing.sharePdf(
  //       bytes: await pdf.save(),
  //       filename: 'payroll_report.pdf',
  //     );
  //   } else {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final file = File('${dir.path}/payroll_report.pdf');
  //     await file.writeAsBytes(await pdf.save());
  //   }
  // }
  static Future<void> generatePayrollPdf(RxList<UnitPayroll> unitPayrollList) async {
    final pdf = pw.Document();

    // Load logo
    final imageByteData = await rootBundle.load(assets.logo);
    final imageList = imageByteData.buffer.asUint8List(
        imageByteData.offsetInBytes, imageByteData.lengthInBytes);
    final image = pw.MemoryImage(imageList);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(image, width: 80, height: 80),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      controllers.storage.read("com_name"),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Text(
                      "Address: 44/1, V.V. Koil Street, Tambaram Sanatorium,\n"
                          "Chennai-600 045, Tamilnadu, India.",
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                "Pay Slip",
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
              )
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                pyrlCtr.month.value,
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
              )
            ),
            pw.SizedBox(height: 5),

            // Loop through each payroll
            ...unitPayrollList.map((e) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xffcccccc)),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Employee Info
                    pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(2),
                        2: const pw.FlexColumnWidth(2),
                        3: const pw.FlexColumnWidth(2),
                      },
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffcccccc)),
                      children: [
                        _tableRow("Name", e.name ?? "", "Rank", e.roleName ?? ""),
                        _tableRow("Father Name", e.fn ?? "", "Site Name", e.unitName ?? ""),
                        _tableRow("ID No", e.empcd ?? "", "Phone", e.phoneNo ?? ""),
                        _tableRow("D.O.B", e.dob ?? "", "D.O.J", e.doj ?? ""),
                        _tableRow("PF No", e.pfNo ?? "", "ESI No", e.esiNo ?? ""),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // Salary Table
                    pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(2),
                        2: const pw.FlexColumnWidth(2),
                        3: const pw.FlexColumnWidth(2),
                      },
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffcccccc)),
                      children: [
                        _tableRow("Duty", e.duty ?? "","ESI", e.esi ?? ""),
                        _tableRow("Basic", e.basic ?? "","PF", e.pf ?? "",),
                        _tableRow("DA", e.da ?? "","PT", e.pt ?? "",),
                        _tableRow("HRA", e.hra ??"","Uniform", e.uniform ?? ""),
                        _tableRow("NFH", e.nH ??"","Advance", e.advance ?? ""),
                        _tableRow("SFH", e.sH ??"","Penalty", e.penalty ?? ""),
                        _tableRow("Others", e.oH ??"","Deduction", e.deduction ?? ""),
                        _tableRow("Total", e.total ??"","",""),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('Net Amount : '),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: PdfColors.black, // choose your color
                              width: 1,               // thickness of border
                            ),
                            borderRadius: pw.BorderRadius.circular(4), // optional rounded corners
                          ),
                          child: pw.Text(
                            e.netAmount ?? '',
                            style: pw.TextStyle( fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ]
                    ),
                    // Bank details
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Words in rupees',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text('Bank Name',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text('A/C No',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text('IFSC Code',style: pw.TextStyle(fontSize: 9)),
                              ]
                          ),pw.SizedBox(width: 10),
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                              ]
                          ),
                          pw.SizedBox(width: 10),
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('${NumberToWordsEnglish.convert(int.parse(e.netAmount.toString())).toString().capitalize}',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(e.bankName ?? '',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(e.accNo ?? '',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(e.ifscCode ?? '',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                              ]
                          ),
                        ]
                    ),
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    // Mobile vs Web handling
    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${unitPayrollList[0].name} ${pyrlCtr.month.value} Pay Slip.pdf',
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${unitPayrollList[0].name} ${pyrlCtr.month.value} Pay Slip.pdf');
      await file.writeAsBytes(await pdf.save());
    }
  }

// Helper row builder
  static pw.TableRow _tableRow(String key1, String val1, String key2, String val2) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(key1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(val1, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(key2, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(val2, style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
    );
  }

  static pw.Widget _tableCell(String? text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text ?? '',
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 9,
        ),
      ),
    );
  }
}
