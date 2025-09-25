import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/components/custom_textfield.dart';
import 'package:fullcomm_crm/components/password_text_field.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../provider/employee_provider.dart';

class AddEmployeePage extends StatefulWidget {
  final double? screenWidth;

  const AddEmployeePage({super.key,  this.screenWidth});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
    employeeData.roleDetailsData(context: context);
    employeeData.clearAllEmployeeControllers();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(builder: (context, employeeProvider, _) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      bool isWebView = screenWidth > screenHeight;
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: screenWidth * 0.80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CustomText(
                      text: "Add Employee Details",
                      size: 20,
                      colors: Colors.black,
                      isBold: true,
                    ),
                  ),
                  20.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Left Column
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextField(
                                text: "Employee Name",
                                hintText: "Enter Employee Name",
                                controller: employeeProvider.nameController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.textInput,
                                isOptional: true,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextField(
                                text: "Phone No",
                                hintText: "Enter Phone No",
                                inputFormatters: constInputFormatters.mobileNumberInput,
                                controller: employeeProvider.mobileController,
                                textInputAction: TextInputAction.next,
                                isOptional: true,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomPasswordTextField(
                                text: "Password",
                                hintText: "Enter Password",
                                controller: employeeProvider.password,
                                inputFormatters: constInputFormatters.passwordInput,
                                textInputAction: TextInputAction.next,
                                isOptional: true,
                                iconData : employeeProvider.isVisible ?
                                Icons.visibility_off : Icons.visibility,
                              ),
                            ),
                            10.height,
                            SizedBox(
                          width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                          child: CustomTextField(
                            text: 'Expected Joining Date',
                            hintText: 'Expected Joining Date',
                            controller:
                            employeeProvider.date,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (value){
                              employeeProvider.selectDate(context);
                            },

                          ),
                        ),
                            10.height,
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: isWebView ? screenWidth * 0.25  : screenWidth * 0.65,
                                  child: Row(
                                    children: [
                                      CustomText(text: "Position/ Role",colors: colorsConst.backgroundColor,size: 13,),
                                      CustomText(text: "*",colors: Colors.red,size: 13,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // 10.height,
                            // SizedBox(
                            //   width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                            //   child: DropdownMenu<Role>(
                            //     controller: EmployeeData.roleController,
                            //     width: isWebView ? screenWidth * 0.25 : screenWidth * 0.65,
                            //     menuHeight: screenHeight * 0.30,
                            //     hintText: "Select Role",
                            //     requestFocusOnTap: true,
                            //     enableFilter: true,
                            //       onSelected: (Role? value) {
                            //         if (value != null) {
                            //           final selectedRoleId = value.id;
                            //           employeeProvider.selectedRoleSetter(value); // use the method
                            //           employeeProvider.roleController.text = value.roleTitle!;
                            //           print('Selected Role ID: $selectedRoleId');
                            //         }
                            //       },
                            //     dropdownMenuEntries: EmployeeData.roleTitles.map((Role role) {
                            //       return DropdownMenuEntry<Role>(
                            //         value: role,
                            //         label: role.roleTitle.toString(),
                            //         leadingIcon: Icon(Icons.person_outline),
                            //       );
                            //     }).toList(),
                            //   ),
                            // ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomText(text: "Other Roles",size: 13,colors: colorsConst.backgroundColor,)
                            ),
                            20.height,
                            // SizedBox(
                            //   width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                            //   child: TextField(
                            //     controller: EmployeeData.otherRoleController,
                            //     readOnly: true,
                            //     decoration: InputDecoration(
                            //       hintText: "Select Roles",
                            //       suffixIcon: Icon(Icons.arrow_drop_down),
                            //       border: OutlineInputBorder(), // Default outline border
                            //       enabledBorder: OutlineInputBorder( // When not focused
                            //         borderSide: BorderSide(color: Colors.grey),
                            //       ),
                            //       focusedBorder: OutlineInputBorder( // When focused
                            //         borderSide: BorderSide(color: Colors.blue, width: 2),
                            //       ),
                            //     ),
                            //     onTap: () => EmployeeData.showRoleMultiSelect(context),
                            //   ),
                            //
                            // )
                          ],
                        ),
                      ),

                      20.width,

                      /// Right Column
                      Expanded(
                        child: Column(
                          children: [

                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextField(
                                text: "Whatsapp No",
                                hintText: "Enter Whatsapp No",
                                controller: employeeProvider.WhatsappController,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.mobileNumberInput,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextField(
                                text: "Email",
                                hintText: "Enter Email",
                                controller: employeeProvider.emailController,
                                inputFormatters: constInputFormatters.emailInput,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextField(
                                text: "Address",
                                hintText: "Address",
                                controller: employeeProvider.door,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.addressInput,


                              ),
                            ),

                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextField(
                                text: "Salary",
                                hintText: "Enter Salary",
                                controller: employeeProvider.salary,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.numberInput,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextField(
                                text: "Bonus",
                                hintText: "Enter Bonus",
                                controller: employeeProvider.bonus,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.numberInput,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  10.height,

                  /// Submit Button
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     SizedBox(
                  //       width: 120,
                  //       height: 40,
                  //       child: RoundedLoadingButton(
                  //         borderRadius: 5,
                  //         color: colorsConst.primary,
                  //         controller: employeeProvider.addEmployeeButtonController,
                  //         onPressed: () {
                  //           if (employeeProvider.nameController.text.isNotEmpty &&
                  //               employeeProvider.mobileController.text.isNotEmpty &&
                  //               employeeProvider.password.text.isNotEmpty  &&
                  //               EmployeeData.selectedRole?.id!=null
                  //             ) {
                  //             final primaryRoleId = EmployeeData.selectedRole?.id ?? '';
                  //             final otherRoleIds = EmployeeData.selectedRoles.map((e) => e.id).join(',');
                  //             log("employeeProvider.nameController,${employeeProvider.nameController.text.toString()}");
                  //             log("employeeProvider.mobileController,${employeeProvider.mobileController.text.toString()}");
                  //             log("employeeProvider.door,${employeeProvider.door.text.toString()}");
                  //             log("employeeProvider.bonus${employeeProvider.bonus.text.toString()}");
                  //             log("employeeProvider.emailController,${employeeProvider.emailController.text.toString()}");
                  //             log("employeeProvider.password,${employeeProvider.password.text.toString()}");
                  //             log("employeeProvider.date${employeeProvider.date.text.toString()}");
                  //             log("employeeProvider.selectedRole${primaryRoleId}");
                  //             log(" employeeProvider.salary${ employeeProvider.salary.text.toString()}");
                  //             log("employeeProvider.mobileController${employeeProvider.mobileController.text.toString()}");
                  //             log("employeeProvider.selectedPublication${employeeProvider.selectedPublication}");
                  //             log("employeeProvider.selectedRadioRole,${otherRoleIds}");
                  //             employeeProvider.employeeInsert(
                  //               context: context,
                  //               emp_name: employeeProvider.nameController.text.toString(),
                  //               emp_mobile: employeeProvider.mobileController.text.toString(),
                  //               emp_address: employeeProvider.door.text.toString(),
                  //               emp_bonus: employeeProvider.bonus.text.toString(),
                  //               emp_email: employeeProvider.emailController.text.toString(),
                  //               emp_password: employeeProvider.password.text.toString(),
                  //               emp_join_date: employeeProvider.date.text.toString(),
                  //               emp_role:primaryRoleId ,
                  //               emp_salary: employeeProvider.salary.text.toString(),
                  //               emp_whatsapp: employeeProvider.mobileController.text.trim().toString(),
                  //               active: employeeProvider.selectedPublication ?? "1",
                  //               roles: otherRoleIds,
                  //
                  //             );
                  //           } else if(employeeProvider.nameController.text.isEmpty ){
                  //             employeeProvider.addEmployeeButtonController.reset();
                  //             utils.showSnackbar(
                  //               context: context,
                  //               text: "Please Enter Name",
                  //               backgroundColor: colorsConst.infoColor,
                  //             );
                  //           }
                  //           else if(employeeProvider.mobileController.text.isEmpty ){
                  //             employeeProvider.addEmployeeButtonController.reset();
                  //             ToastMsg.showSnackbar(
                  //               context: context,
                  //               text: "Please Enter Mobile Number",
                  //               backgroundColor: colorsConst.infoColor,
                  //             );
                  //           }
                  //           else if(employeeProvider.password.text.isEmpty ){
                  //             employeeProvider.addEmployeeButtonController.reset();
                  //             ToastMsg.showSnackbar(
                  //               context: context,
                  //               text: "Please Enter Password",
                  //               backgroundColor: colorsConst.infoColor,
                  //             );
                  //           }
                  //           else if(employeeProvider.password.text.length>8) {
                  //             employeeProvider.addEmployeeButtonController.reset();
                  //             ToastMsg.showSnackbar(
                  //               context: context,
                  //               text: "Please Enter above 8 digit Password",
                  //               backgroundColor: colorsConst.infoColor,
                  //             );
                  //
                  //           }
                  //           else if(employeeProvider.password.text.length<16) {
                  //             employeeProvider.addEmployeeButtonController.reset();
                  //             ToastMsg.showSnackbar(
                  //               context: context,
                  //               text: "Please Enter below 16 digit Password",
                  //               backgroundColor: colorsConst.infoColor,
                  //             );
                  //           }
                  //           else if(EmployeeData.selectedRole?.id==null){
                  //             employeeProvider.addEmployeeButtonController.reset();
                  //             ToastMsg.showSnackbar(
                  //               context: context,
                  //               text: "Please Enter Role",
                  //               backgroundColor: colorsConst.infoColor,
                  //             );
                  //           }
                  //
                  //           else {
                  //             employeeProvider.addEmployeeButtonController.reset();
                  //             ToastMsg.showSnackbar(
                  //               context: context,
                  //               text: "Please fill all required fields",
                  //               backgroundColor: colorsConst.infoColor,
                  //             );
                  //           }
                  //         },
                  //         child: CustomText(
                  //           text: "Add Employee",
                  //           color: colorsConst.fontWhite,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //     150.width,
                  //   ],
                  // ),
                  50.height,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
