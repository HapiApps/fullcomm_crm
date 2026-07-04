import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/employee/report_page.dart';
import 'package:fullcomm_crm/screens/employee/update_employee.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_appbar.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/settings_controller.dart';
import '../../provider/employee_provider.dart';
import 'add_employee.dart';

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/controller/product_controller.dart';
import 'package:fullcomm_crm/screens/quotation/quotation_history.dart';
import 'package:get/get.dart';
import '../../billing/billing_view/new_billing_screen.dart';
import '../../components/custom_sidebar.dart';
import '../../controller/controller.dart';
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
      settingsController.allRoles();
      await employeeData.fetchDepList();
      employeeData.staffRoleDetailsData(context: context);
    });
  }
  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // bool isWebView = screenWidth > screenHeight;

    return  Consumer<EmployeeProvider>(
        builder: (context,employeeProvider,_) {
      return Scaffold(
        body: Row(
          children: [
            SideBar(),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 160:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                        CustomAppbar(
                          text:"Employees",subText: "View all employees",
                          actionsWidget: CustomLoadingButton(callback: (){
                            String plan = controllers.planType.value.toLowerCase();
                            if(plan=="business essential"&&(employeeProvider.filteredStaff.length) < 2){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEmployeePage()));
                            }else if(plan=="business fit"&&(employeeProvider.filteredStaff.length) < 10){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEmployeePage()));
                            }else if(plan=="business pro"||plan=="enterprise"){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEmployeePage()));
                            }else if(plan==""){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEmployeePage()));
                            }else{
                              utils.snackBar(
                                context: context,
                                msg: "Update your business plan",
                                color: Colors.red,
                              );
                            }
                          }, isLoading: false, backgroundColor: colorsConst.primary, radius: 5, width: MediaQuery.of(context).size.width*0.08,height: 40,isImage: false,text: "Add Employee",)
                        ),
                        Row(
                          children: [
                            CustomText(
                              text: "Employees",
                              colors: colorsConst.primary,
                              isBold: true,
                              size: 15,
                              isCopy: false,
                            ),
                            10.width,
                            CircleAvatar(
                              backgroundColor: colorsConst.primary,
                              radius: 17,
                              child: CustomText(
                                text: employeeProvider.filteredStaff.length.toString(),
                                colors: Colors.white,
                                size: 13,
                                isCopy: false,
                              ),
                            ),
                          ],
                        ),
                        5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomSearchTextField(
                                hintText: "Search Employee Name Or Mobile Number",
                                controller: employeeProvider.vendorSearchController,
                                onChanged:  (value){
                                  employeeProvider.filterStaff(value.toString());
                                }
                            ),
                            employeeProvider.hasSelectedEmployee?
                            Row(
                              children: [
                                CustomText(text: "Selected Count: ${employeeProvider.selectedEmployeeIds.length}",isCopy: false,),
                                10.width,
                                InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onTap: (){
                                    utils.showDeleteDialog(
                                        context: context, name: 'delete this ${employeeProvider.selectedEmployeeIds.length==1?'employee':'employees'}',
                                        isDelete: true,
                                        callBack: (){
                                          employeeProvider.employeeDelete(
                                            context: context,
                                            eIds: employeeProvider.selectedEmployeeIds,
                                          );
                                        },
                                        controller: controllers.productCtr);
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: colorsConst.secondary,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child:  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset("assets/images/action_delete.png"),
                                        10.width,
                                        CustomText(
                                          text: "Delete",
                                          colors: colorsConst.textColor,
                                          size: 14,
                                          isBold: true,
                                          isCopy: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ):0.width,
                          ],
                        ),

                  30.height,
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),//S.No
                      1: FlexColumnWidth(2),//action
                      2: FlexColumnWidth(4),//emp
                      3: FlexColumnWidth(2),//role
                      4: FlexColumnWidth(2),//dep
                      5: FlexColumnWidth(3),//no
                      6: FlexColumnWidth(3),//email
                      7: FlexColumnWidth(3.5),//add
                      8: FlexColumnWidth(1.5),//sal
                      9: FlexColumnWidth(1.5),//bo
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
                            Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child:  Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    side: WidgetStateBorderSide.resolveWith(
                                          (states) => const BorderSide(width: 1.0, color: Colors.white),
                                    ),
                                    value: employeeProvider.selectedEmployeeIds.length == employeeProvider.filteredStaff.length && employeeProvider.filteredStaff.isNotEmpty,
                                    onChanged: (value) {
                                     employeeProvider.toggleSelectAllEmployees();
                                    },
                                    activeColor: Colors.white,
                                    checkColor: colorsConst.primary,
                                  ),
                                ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomText(
                                textAlign: TextAlign.left,
                                text: "Action",
                                size: 15,
                                isBold: true,
                                isCopy: false,
                                colors: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(//1
                                    textAlign: TextAlign.left,
                                    text: "Employee Name",
                                    size: 15,
                                    isBold: true,
                                    isCopy: false,
                                    colors: Colors.white,
                                  ),
                                 5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('name');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Role",
                                    size: 15,
                                    isBold: true,
                                    isCopy: false,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('role');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Department",
                                    size: 15,
                                    isBold: true,
                                    isCopy: false,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('dep');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Mobile No",
                                    size: 15,
                                    isBold: true,
                                    isCopy: false,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('mobile');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Email",
                                    size: 15,
                                    isBold: true,
                                    isCopy: false,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('email');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Address",
                                    size: 15,
                                    isBold: true,
                                    isCopy: false,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('address');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Salary",
                                    size: 15,
                                    isBold: true,
                                    isCopy: false,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('salary');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Bonus",
                                    size: 15,
                                    isCopy: false,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('bonus');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: LayoutBuilder(builder: (context, constraints){
                        return employeeProvider.filteredStaff.isNotEmpty ?
                        ListView.builder(
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
                                  0: FlexColumnWidth(2),//S.No
                                  1: FlexColumnWidth(2),//action
                                  2: FlexColumnWidth(4),//emp
                                  3: FlexColumnWidth(2),//role
                                  4: FlexColumnWidth(2),//dep
                                  5: FlexColumnWidth(3),//no
                                  6: FlexColumnWidth(3),//email
                                  7: FlexColumnWidth(3.5),//add
                                  8: FlexColumnWidth(1.5),//sal
                                  9: FlexColumnWidth(1.5),//bo
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
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Checkbox(
                                            value: employeeProvider.isCheckedEmployee(staffId!),
                                            onChanged: (value) {
                                              employeeProvider.toggleSelectionEmployee(staffId);
                                            },
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
                                                  icon: SvgPicture.asset(
                                                    "assets/images/a_edit.svg",
                                                    width: 16,
                                                    height: 16,
                                                  )),
                                              IconButton(
                                                  onPressed: (){
                                                    utils.showDeleteDialog(
                                                        context: context, name: 'delete this employee',
                                                        isDelete: true,
                                                        callBack: (){
                                                          employeeProvider.employeeDelete(
                                                              eId:staffData.id,
                                                              context: context
                                                          );
                                                        },
                                                        controller: controllers.productCtr);
                                                  },
                                                  icon: SvgPicture.asset(
                                                    "assets/images/a_delete.svg",
                                                    width: 16,
                                                    height: 16,
                                                  )),
                                              IconButton(
                                                  onPressed: (){
                                                    Get.to(EmployeeReportPage(id:staffData.id.toString()));
                                                  },
                                                  icon: Icon(Icons.report_gmailerrorred_rounded)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text: "${staffData.sName}",
                                            size: 14,
                                            isCopy: false,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            isCopy: false,
                                            text:staffData.roleTitle.toString(),
                                            // text:employeeProvider.getRoleName(staffData.role.toString()=="null"?"1":staffData.role.toString()),
                                            size: 14,
                                            colors: colorsConst.textColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            isCopy: false,
                                            text:staffData.department.toString(),
                                            size: 14,
                                            colors: colorsConst.textColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            isCopy: false,
                                            textAlign: TextAlign.left,
                                            text: staffData.sMobile.toString(),
                                            size: 14,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            isCopy: false,
                                            text: staffData.email.toString(),
                                            size: 14,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            isCopy: false,
                                            textAlign: TextAlign.left,
                                            text: staffData.sAddress.toString(),
                                            size: 14,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            isCopy: false,
                                            textAlign: TextAlign.left,
                                            text: staffData.salary.toString(),
                                            size: 14,
                                            colors:colorsConst.textColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            isCopy: false,
                                            textAlign: TextAlign.left,
                                            text: staffData.bonus.toString(),
                                            size: 14,
                                            colors:colorsConst.textColor,
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
                        ) :
                        Container(
                            alignment: Alignment.center,
                            height: 500,width: 500,
                            child: SvgPicture.asset(
                                "assets/images/noDataFound.svg"));
                      }
                      ),
                    ),
                  ),
                ],
              ),
            ),),
          ],
        ),
    );
  }
    );
  }
}

