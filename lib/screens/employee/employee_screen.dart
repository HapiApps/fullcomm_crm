import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/employee/update_employee.dart';
import 'package:provider/provider.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      await employeeData.fetchRoleList();
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
        body: Row(
          children: [
            utils.sideBarFunction(context),
            Container(
              width: MediaQuery.of(context).size.width - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
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
                                  child: CustomSearchTextField(
                                      hintText: "Search Employee...",
                                      controller: employeeProvider.vendorSearchController,
                                      onChanged:  (value){
                                      }
                                  ),
                                ),
                                20.width,
                                if (employeeProvider.hasSelectedEmployee)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18.0),
                                    child: ElevatedButton.icon(
                                      icon:  Icon(Icons.delete, color: Colors.red),
                                      label:  Text("Delete", style: TextStyle(color: colorsConst.textColor)),
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
                                              content: CustomText(
                                                text: "Are you sure delete this employees?",
                                                size: 16,
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
                                                            colors: colorsConst.primary,
                                                            size: 14,
                                                          )),
                                                    ),
                                                    10.width,
                                                    CustomLoadingButton(
                                                      callback: ()async{
                                                        employeeProvider.employeeDelete(
                                                          context: context,
                                                          eIds: employeeProvider.selectedEmployeeIds,
                                                        );
                                                      },
                                                      height: 35,
                                                      isLoading: true,
                                                      backgroundColor: colorsConst.primary,
                                                      radius: 2,
                                                      width: 80,
                                                      controller: controllers.productCtr,
                                                      isImage: false,
                                                      text: "Delete",
                                                      textColor: Colors.white,
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
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: colorsConst.primary, width: 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5), // Rounded corners
                                      ),
                                    ),
                                    child:  CustomText(text:"Add Employee",isBold: true,colors: colorsConst.primary,),
                                  ),
                                ),
                              ],
                            ),
                            // OutlinedButton(
                            //   onPressed: () {
                            //     final headers = [
                            //       "ID",
                            //       "Name",
                            //       "Mobile",
                            //       "Email",
                            //       "Address",
                            //       "Salary",
                            //       "Bonus",
                            //       "DOB",
                            //       "Other Roles",
                            //       "WhatsApp",
                            //       "Role",
                            //       "Role Title",
                            //       "Password",
                            //       "Joining Date",
                            //       "Platform",
                            //       "Updated Platform",
                            //       "Active",
                            //       "Updated Timestamp",
                            //       "Created Timestamp",
                            //       "Updated By",
                            //       "Created By",
                            //       "COS ID"
                            //     ];
                            //     // List<List<dynamic>> csvData = [
                            //     //   headers,
                            //     //   ...employeeProvider.staffRoleData.map((staffRoleData) => staffRoleData.toCsvRow()),
                            //     // ];
                            //
                            //     //importExportProvider.exportCSV(csvData, 'employee.csv');
                            //
                            //   },
                            //   style: OutlinedButton.styleFrom(
                            //     side: BorderSide(color: colorsConst.backgroundColor, width: 1),
                            //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(5), // Rounded corners
                            //     ),
                            //   ),
                            //   child: const CustomText(text:"Export",isBold: true,),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  30.height,
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),//S.No
                      1: FlexColumnWidth(3.5),//Employee Name
                      2: FlexColumnWidth(3),//Role.
                      3: FlexColumnWidth(3),//Mobile No
                      4: FlexColumnWidth(3.5),//Action
                      //6: FlexColumnWidth(4.5),//Actions
                    },
                    border: TableBorder(
                      horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                      verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                    ),
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                              color: colorsConst.primary,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5))),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "S.No",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                // Obx(() => GestureDetector(
                                //   onTap: (){
                                //     controllers.sortField.value = 'date';
                                //     controllers.sortOrder.value = 'asc';
                                //   },
                                //   child: Icon(
                                //     Icons.arrow_upward,
                                //     size: 16,
                                //     color: (controllers.sortField.value == 'date' &&
                                //         controllers.sortOrder.value == 'asc')
                                //         ? Colors.white
                                //         : Colors.grey,
                                //   ),
                                // )),
                                // Obx(() => GestureDetector(
                                //   onTap: (){
                                //     controllers.sortField.value = 'date';
                                //     controllers.sortOrder.value = 'desc';
                                //   },
                                //   child: Icon(
                                //     Icons.arrow_downward,
                                //     size: 16,
                                //     color: (controllers.sortField.value == 'date' &&
                                //         controllers.sortOrder.value == 'desc')
                                //         ? Colors.white
                                //         : Colors.grey,
                                //   ),
                                // )
                                // ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomText(//1
                                textAlign: TextAlign.left,
                                text: "Employee Name",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomText(//2
                                textAlign: TextAlign.left,
                                text: "Role",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomText(
                                textAlign: TextAlign.left,
                                text: "Mobile No",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomText(
                                textAlign: TextAlign.left,
                                text: "Action",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(10.0),
                            //   child: CustomText(//9
                            //     textAlign: TextAlign.center,
                            //     text: "Actions",
                            //     size: 15,
                            //     isBold: true,
                            //     colors: Colors.white,
                            //   ),
                            // ),
                          ]),
                    ],
                  ),
                  Expanded(
                    //width: isWebView ? screenWidth * 0.80 : screenWidth,
                    child: SingleChildScrollView(
                      child: LayoutBuilder(builder: (context, constraints){
                        return employeeProvider.filteredStaff.isNotEmpty ? ListView.builder(
                          itemCount: employeeProvider.filteredStaff.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final staffData = employeeProvider.filteredStaff[index];
                            final staffId =  employeeProvider.filteredStaff[index].id;
                            return InkWell(
                              onTap: (){
                                employeeProvider.setSelectedEmployeeIndex(index);
                              },
                              child: Table(
                                columnWidths:const {
                                  0: FlexColumnWidth(2),//date
                                  1: FlexColumnWidth(3.5),//Customer Name
                                  2: FlexColumnWidth(3),//Mobile No.
                                  3: FlexColumnWidth(3),//Call Type
                                  4: FlexColumnWidth(3.5),
                                },
                                border: TableBorder(
                                  horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                  verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                  bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                ),
                                children:[
                                  TableRow(
                                      decoration: BoxDecoration(
                                        color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                      ),
                                      children:[
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
                                        Tooltip(
                                          message: staffData.sName.toString()=="null"?"":staffData.sName.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: "${staffData.sName}",
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text:employeeProvider.getRoleName(staffData.role.toString()=="null"?"1":staffData.role.toString()),
                                            size: 14,
                                            colors: colorsConst.textColor,
                                          ),
                                        ),
                                        Tooltip(
                                          message: staffData.sMobile.toString()=="null"?"":staffData.sMobile.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: staffData.sMobile.toString(),
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      IconButton(
                                                          onPressed: (){
                                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateEmployee(
                                                              employeeData :staffData ,
                                                            )));
                                                          },
                                                          icon: Icon(Icons.edit,color: Colors.green,)),
                                                      IconButton(
                                                          onPressed: (){
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return AlertDialog(
                                                                  content: CustomText(
                                                                    text: "Are you sure delete this employees?",
                                                                    size: 16,
                                                                    isBold: true,
                                                                    colors: colorsConst.textColor,
                                                                  ),                                                                  actions: [
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
                                                                                colors: colorsConst.primary,
                                                                                size: 14,
                                                                              )),
                                                                        ),
                                                                        10.width,
                                                                        CustomLoadingButton(
                                                                          callback: ()async{
                                                                            employeeProvider.employeeDelete(
                                                                                eId:staffData.id,
                                                                                context: context
                                                                            );

                                                                          },
                                                                          height: 35,
                                                                          isLoading: true,
                                                                          backgroundColor: colorsConst.primary,
                                                                          radius: 2,
                                                                          width: 80,
                                                                          controller: controllers.productCtr,
                                                                          isImage: false,
                                                                          text: "Delete",
                                                                          textColor: Colors.white,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                          icon: Icon(Icons.delete_outline_sharp,color: Colors.red,))
                                                    ],
                                                  ),
                                        ),

                                        // Visibility(
                                        //   visible: employeeProvider.selectedEmployeeIndex == index,
                                        //   child: Column(
                                        //     crossAxisAlignment: CrossAxisAlignment.start,
                                        //     children: [
                                        //       const Divider(),
                                        //       Padding(
                                        //         padding: const EdgeInsets.all(20.0),
                                        //         child: Column(
                                        //           children: [
                                        //             Row(
                                        //               children: [
                                        //                 Padding(
                                        //                   padding: const EdgeInsets.all(4.0),
                                        //                   child: SizedBox(
                                        //                     width: screenWidth * 0.70,
                                        //                     child: Row(
                                        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                       children: [
                                        //                         Padding(
                                        //                           padding: const EdgeInsets.all(8.0),
                                        //                           child: Row(
                                        //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //                             children: [
                                        //                               SizedBox(
                                        //                                 child: const CustomText(text: "Email", isBold:true,),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                                 child: const Center(child: CustomText(text: ":", isBold:true)),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 child: CustomText(text: staffData.email ?? '-',),
                                        //                               ),
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                         Padding(
                                        //                           padding: const EdgeInsets.all(4.0),
                                        //                           child: Row(
                                        //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //                             children: [
                                        //                               SizedBox(
                                        //                                 child: const CustomText(text: "Address", isBold:true,),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                                 child: const Center(child: CustomText(text: ":", isBold:true)),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 child: CustomText(text: staffData.sAddress?.isNotEmpty == true ? staffData.sAddress! : '-',),
                                        //                               ),
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                         Padding(
                                        //                           padding: const EdgeInsets.all(4.0),
                                        //                           child: Row(
                                        //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //                             children: [
                                        //                               SizedBox(
                                        //                                 child: const CustomText(text: "Whatsapp No", isBold:true,),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                                 child: const Center(child: CustomText(text: ":", isBold:true)),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 child: CustomText(text: staffData.whatsapp?.isNotEmpty == true ? staffData.whatsapp! : '-'),
                                        //                               ),
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                         Row(
                                        //                           crossAxisAlignment: CrossAxisAlignment.start,
                                        //                           children: [
                                        //                             SizedBox(
                                        //                               child: CustomText(text: "Joining Date", isBold:true,),
                                        //                             ),
                                        //                             SizedBox(
                                        //                               width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                               child: Center(child: CustomText(text: ":", isBold:true)),
                                        //                             ),
                                        //                             SizedBox(
                                        //                               child: CustomText(text: staffData.joiningDate?.isNotEmpty == true ?
                                        //                               DateFormat('dd-MM-yyyy').format(DateTime.parse("${staffData.joiningDate!}")): '-'),
                                        //                             ),
                                        //                           ],
                                        //                         ),
                                        //                       ],
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //               ],
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       )
                                        //     ],
                                        //   ),
                                        // ),
                                      ]
                                  ),

                                ],
                              ),
                            );
                          },
                        ) : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            100.height,
                            Center(
                                child: SvgPicture.asset(
                                    "assets/images/noDataFound.svg")),
                          ],
                        );
                      }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
    );
  }
}

