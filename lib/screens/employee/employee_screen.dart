import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/employee/update_employee.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/constant/colors_constant.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/k_card_container.dart';
import '../../provider/employee_provider.dart';
import 'add_employee.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      employeeData.staffRoleDetailsData(context: context);

    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isWebView = screenWidth > screenHeight;

    return  Consumer<EmployeeProvider>(
        builder: (context,employeeProvider,_) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 20.0,right: 20.0,top: 10.0),
          child: Column(
            children: [
              // SizedBox(
              //   width: isWebView ? screenWidth * 0.80 : screenWidth * 0.90,
              //   child: Row(
              //     mainAxisAlignment:  MainAxisAlignment.start,
              //     children: [
              //       // Row(
              //       //   children: [
              //       //     IconButton(onPressed: (){
              //       //       Navigator.pop(context);
              //       //     }, icon: Icon(Icons.arrow_back,size: 30,color: colorsConst.fontBlack,)),
              //       //     50.width,
              //       CustomText(text: "${employeeProvider.staffRoleData.length} Employees",fontSize: 20,isBold:true,),
              //       //   ],
              //       // ),
              //       // Row(
              //       //   children: [
              //       //     OutlinedButton(
              //       //       onPressed: () {
              //       //         print("Import Button");
              //       //       },
              //       //       style: OutlinedButton.styleFrom(
              //       //         foregroundColor: colorsConst.fontBlack, // Text color
              //       //         side: BorderSide(color: colorsConst.inputBorderColor, width: 1),
              //       //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              //       //         shape: RoundedRectangleBorder(
              //       //           borderRadius: BorderRadius.circular(5), // Rounded corners
              //       //         ),
              //       //       ),
              //       //       child: const CustomText(text:"Import",isBold:true,),
              //       //     ),
              //       //     10.width,
              //
              //       //   ],
              //       // )
              //     ],
              //   ),
              // ),
              SizedBox(
                width: isWebView ? screenWidth * 0.80 : screenWidth,
                child: Flex(
                  direction: isWebView ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: isWebView ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: isWebView ? screenWidth * 0.35 : screenWidth,
                        child:  Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 18.0),
                              child: CustomText(text: "${employeeProvider.filteredStaff.length} Employees",size: 20,isBold: true,),
                            ),
                            10.width,
                            Expanded(
                              child: CustomTextField(
                                  text: "Search Employee...",
                                  controller: employeeProvider.vendorSearchController,
                                  textInputAction: TextInputAction.done,
                                  onChanged:  (value){
                                    employeeProvider.filterStaff(employeeProvider.vendorSearchController.text);
                                  }
                              ),
                            ),
                            20.width,
                            if (employeeProvider.hasSelectedEmployee)
                              Padding(
                                padding: const EdgeInsets.only(top: 18.0),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  label: const Text("Delete", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorsConst.primary, // Button color
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Delete Employee",
                                            style: GoogleFonts.lato(
                                              fontSize: 20,
                                              color: colorsConst.primary,
                                            ),
                                          ),
                                          content: Text(
                                            "Do you want to Delete this Employee?",
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  child: Text(
                                                    "Cancel",
                                                    style: GoogleFonts.lato(
                                                      fontSize: 14,
                                                      color: colorsConst.primary,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(
                                                    "Delete",
                                                    style: GoogleFonts.lato(
                                                      fontSize: 14,
                                                      color: colorsConst.primary,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    print('Delete selected Employee: ${employeeProvider.selectedEmployeeIds}');
                                                    employeeProvider.employeeDelete(
                                                      context: context,
                                                      eIds: employeeProvider.selectedEmployeeIds,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),

                          ],
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(

                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEmployeePage(

                                  )));
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: colorsConst.backgroundColor, width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5), // Rounded corners
                                  ),
                                ),
                                child: const CustomText(text:"Add Employee",isBold: true,),
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton(
                          onPressed: () {
                            final headers = [
                              "ID",
                              "Name",
                              "Mobile",
                              "Email",
                              "Address",
                              "Salary",
                              "Bonus",
                              "DOB",
                              "Other Roles",
                              "WhatsApp",
                              "Role",
                              "Role Title",
                              "Password",
                              "Joining Date",
                              "Platform",
                              "Updated Platform",
                              "Active",
                              "Updated Timestamp",
                              "Created Timestamp",
                              "Updated By",
                              "Created By",
                              "COS ID"
                            ];
                            // List<List<dynamic>> csvData = [
                            //   headers,
                            //   ...employeeProvider.staffRoleData.map((staffRoleData) => staffRoleData.toCsvRow()),
                            // ];

                            //importExportProvider.exportCSV(csvData, 'employee.csv');

                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorsConst.backgroundColor, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Rounded corners
                            ),
                          ),
                          child: const CustomText(text:"Export",isBold: true,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              10.height,
              isWebView ? SizedBox(
                width: isWebView ? screenWidth * 0.80 : screenWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width:screenWidth * 0.05,
                      child: const Row(
                        children: [
                          CustomText(text: "S.No",size: 17,isBold: true,textAlign: TextAlign.center,),
                        ],
                      ),
                    ),
                    10.width,
                    SizedBox(
                      width: screenWidth * 0.80 * 0.25,
                      child: const CustomText(text: "Employee Name",size: 17,isBold: true,textAlign: TextAlign.left,),
                    ),
                    10.width,
                    SizedBox(
                      width: screenWidth * 0.80 * 0.25,
                      child: const CustomText(text: "Role",size: 17,isBold: true,textAlign: TextAlign.left,),
                    ),
                    10.width,
                    SizedBox(
                      width: screenWidth * 0.80 * 0.15,
                      child: const CustomText(text: "Mobile No",size: 17,isBold: true,textAlign: TextAlign.left,),
                    ),
                    10.width,
                    SizedBox(
                      width: screenWidth * 0.80 * 0.15,
                      child: const CustomText(text: "Action",size: 17,isBold: true,textAlign: TextAlign.left,),
                    ),
                  ],
                ),
              ) : const SizedBox.shrink(),
              Expanded(
                //width: isWebView ? screenWidth * 0.80 : screenWidth,
                child: SingleChildScrollView(
                  child: LayoutBuilder(builder: (context, constraints){
                    return employeeProvider.filteredStaff.isNotEmpty ? ListView.builder(
                      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //   crossAxisCount: crossAxisCount,
                      //   mainAxisSpacing: 10,
                      //   crossAxisSpacing: 10,
                      //   childAspectRatio: 2.5,
                      // ),
                      itemCount: employeeProvider.filteredStaff.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final staffData = employeeProvider.filteredStaff[index];
                        final staffId =  employeeProvider.filteredStaff[index].id;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: (){
                            employeeProvider.setSelectedEmployeeIndex(index);
                          },
                          child: CardContainer(
                            color: colorsConst.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            child: isWebView ?
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width:screenWidth*0.05,
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: employeeProvider.isCheckedEmployee(staffId!),
                                              onChanged: (value) {
                                                employeeProvider.toggleSelectionEmployee(staffId);
                                              },
                                            ),
                                            CustomText(text: "${index + 1}"),
                                          ],
                                        ),
                                      ),
                                      10.width,
                                      SizedBox(
                                        width: screenWidth * 0.80 * 0.25,
                                        child: CustomText(text: "${staffData.sName}",isBold:true,),
                                      ),
                                      10.width,
                                      SizedBox(
                                        width: screenWidth * 0.80 * 0.25,
                                        child: CustomText(text: "${staffData.roleTitle}",isBold:true,),
                                      ),
                                      10.width,
                                      SizedBox(
                                        width: screenWidth * 0.80 * 0.15,
                                        child: CustomText(text: "${staffData.sMobile}",isBold:true,),
                                      ),
                                      10.width,
                                      SizedBox(
                                        width: screenWidth * 0.80 * 0.15,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: screenWidth * 0.80 * 0.10 * 0.50,
                                              child: TextButton(
                                                  onPressed: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateEmployee(
                                                      EmployeeData :staffData ,
                                                    )));
                                                    },
                                                  child: CustomText(text: "Update",size: 12,colors: colorsConst.primary,textAlign: TextAlign.center,)),
                                            ),
                                            10.width,
                                            SizedBox(
                                              width: screenWidth * 0.80 * 0.10 * 0.45,
                                              child: TextButton(
                                                onPressed: (){
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title:Text( "Delete Employee",style: GoogleFonts.lato(fontSize: 20,color: colorsConst.primary),),
                                                        content: Text( "Do you want to Delete this Employee?",style: GoogleFonts.lato(fontSize: 14,color: Colors.black),),
                                                        actions: [
                                                          Row(
                                                            children: [
                                                              TextButton(
                                                                child: Text( "Cancel",style: GoogleFonts.lato(fontSize: 14,color: colorsConst.primary),),
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },

                                                              ),
                                                              TextButton(
                                                                child: Text("Delete",style: GoogleFonts.lato(fontSize: 14,color: colorsConst.primary),),
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  employeeProvider.employeeDelete(
                                                                      eId:staffData.id,
                                                                      context: context
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child:CustomText(text: "Delete",size: ResponsiveFormats.responsiveFontSize(context, 12),color: colorsConst.productDeleteFgColor,textAlign: TextAlign.center,softWrap: false,),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: employeeProvider.selectedEmployeeIndex == index,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: SizedBox(
                                                    width: screenWidth * 0.70,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                child: const CustomText(text: "Email", isBold:true,softWrap: false,),
                                                              ),
                                                              SizedBox(
                                                                width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                                                child: const Center(child: CustomText(text: ":", isBold:true)),
                                                              ),
                                                              SizedBox(
                                                                child: CustomText(text: staffData.email ?? '-',),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(4.0),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                child: const CustomText(text: "Address", isBold:true,softWrap: false,),
                                                              ),
                                                              SizedBox(
                                                                width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                                                child: const Center(child: CustomText(text: ":", isBold:true)),
                                                              ),
                                                              SizedBox(
                                                                child: CustomText(text: staffData.sAddress?.isNotEmpty == true ? staffData.sAddress! : '-',),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.all(4.0),
                                                          child: Row(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                child: const CustomText(text: "Whatsapp No", isBold:true,softWrap: false,),
                                                              ),
                                                              SizedBox(
                                                                width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                                                child: const Center(child: CustomText(text: ":", isBold:true)),
                                                              ),
                                                              SizedBox(
                                                                child: CustomText(text: staffData.whatsapp?.isNotEmpty == true ? staffData.whatsapp! : '-'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              child: CustomText(text: "Joining Date", isBold:true,softWrap: false,),
                                                            ),
                                                            SizedBox(
                                                              width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                                              child: Center(child: CustomText(text: ":", isBold:true)),
                                                            ),
                                                            SizedBox(
                                                              child: CustomText(text: staffData.joiningDate?.isNotEmpty == true ?
                                                              DateFormat('dd-MM-yyyy').format(DateTime.parse("${staffData.joiningDate!}")): '-', maxLines: 2),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ) :
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: screenWidth * 0.80 * 0.80,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.80 * 0.80 * 0.80,
                                                    child: CustomText(text: "${staffData.sName}",isBold:true,),
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.80 * 0.80 * 0.20,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                            onTap: (){
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title:Text( "Delete Employee",style: GoogleFonts.lato(fontSize: 20,color: colorsConst.primary),),
                                                                    content: Text( "Do you want to Delete this Employee?",style: GoogleFonts.lato(fontSize: 14,color: Colors.black),),
                                                                    actions: [
                                                                      Row(
                                                                        children: [
                                                                          TextButton(
                                                                            child: Text( "Cancel",style: GoogleFonts.lato(fontSize: 14,color: colorsConst.primary),),
                                                                            onPressed: () {
                                                                              Navigator.pop(context);
                                                                            },

                                                                          ),
                                                                          TextButton(
                                                                            child: Text("Delete",style: GoogleFonts.lato(fontSize: 14,color: colorsConst.primary),),
                                                                            onPressed: () {
                                                                              Navigator.pop(context);

                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },child: Image.asset("assets/icons/delete_icon.png",width: 20,height: 20,)),
                                                        10.width,
                                                        TextButton(
                                                            onPressed: (){
                                                            //  employeeProvider.resetControllers(vendorData);
                                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateEmployee(
                                                                EmployeeData :staffData ,
                                                              )));
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context){
                                                                    return Consumer<EmployeeProvider>(
                                                                        builder: (context,employeeProvider,_) {
                                                                          return CustomEditDialogBox.showDialogBox(
                                                                            context: context,
                                                                            dialogTitle: "Update Employee Details",
                                                                            boxWidth: isWebView ? screenWidth * 0.20 : screenWidth * 0.70,
                                                                            boxWidgets: [
                                                                              //copy from vendor add and modify it
                                                                            ],
                                                                          );
                                                                        }
                                                                    );
                                                                  });
                                                            },
                                                            child: Image.asset(
                                                              "assets/icons/edit_icon.png",
                                                              width: 20,height: 20,
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // 10.height,
                                              // Row(
                                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              //   children: [
                                              //     SizedBox(
                                              //       width: screenWidth * 0.80 * 0.80 * 0.50,
                                              //       child: CustomText(text: "Mob.No: ${vendorData.vMobile?.isNotEmpty == true ? vendorData.vMobile! : '-'}"),
                                              //     ),
                                              //     SizedBox(
                                              //       width: screenWidth * 0.80 * 0.80 * 0.50,
                                              //       child: CustomText(text: "Whatsapp No: ${vendorData.vWhatsapp?.isNotEmpty == true ? vendorData.vWhatsapp! : '-'}"),
                                              //     ),
                                              //   ],
                                              // ),
                                              // 10.height,
                                              // SizedBox(
                                              //   width: screenWidth * 0.80 * 0.80,
                                              //   child: CustomText(text: "Designation: ${vendorData.businessName?.isNotEmpty == true ? vendorData.businessName! : '-'}"),
                                              // ),
                                              // 10.height,
                                              // SizedBox(
                                              //   width: screenWidth * 0.80 * 0.80,
                                              //   child: CustomText(text: "Contact Person: ${vendorData.contactPerson?.isNotEmpty == true ? vendorData.contactPerson! : '-'}"),
                                              // ),
                                              // 10.height,
                                              // SizedBox(
                                              //   width: screenWidth * 0.80 * 0.80,
                                              //   child: CustomText(text: "GST No: ${vendorData.gstNo?.isNotEmpty == true ? vendorData.gstNo! : '-'}"),
                                              // ),
                                              // 10.height,
                                              // SizedBox(
                                              //   width: screenWidth * 0.80 * 0.80,
                                              //   child: CustomText(text: "Address: ${vendorData.vAddress?.isNotEmpty == true ? vendorData.vAddress! : '-'}", maxLines: 2),
                                              // ),
                                              // 10.height,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ) : Column(
                      children: [
                        10.height,
                        Container(
                          width: isWebView ? screenWidth * 0.80 : screenWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: colorsConst.productCardColor,
                          ),
                          child: const Center(child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: CustomText(text: "No Employee Found",fontSize: 20, isBold:true,),
                          )),
                        ),
                      ],
                    );
                  }
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
    );
  }
}

