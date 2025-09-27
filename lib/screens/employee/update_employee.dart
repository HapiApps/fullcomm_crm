import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../common/styles/decoration.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/password_text_field.dart';
import '../../models/employee_details.dart';
import '../../provider/employee_provider.dart';


class UpdateEmployee extends StatefulWidget {
  final double? screenWidth;
  final Staff? employeeData;
  const UpdateEmployee({super.key,  this.screenWidth, this.employeeData});

  @override
  State<UpdateEmployee> createState() => _UpdateEmployeeState();
}

class _UpdateEmployeeState extends State<UpdateEmployee> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
   // EmployeeData.clearAllEmployeeControllers();
    employeeData.nameController.text      = widget.employeeData!.sName.toString();
    employeeData.mobileController.text    = widget.employeeData!.sMobile.toString();
    employeeData.password.text            = widget.employeeData!.password.toString();
    employeeData.date.text                = widget.employeeData!.joiningDate.toString();
    employeeData.roleController.text      = widget.employeeData!.role.toString();
    employeeData.otherRoleController.text = widget.employeeData!.otherRoles.toString();
    employeeData.emailController.text     = widget.employeeData!.email.toString();
    employeeData.addressController.text   = widget.employeeData!.sAddress.toString();
    employeeData.salary.text              = widget.employeeData!.salary.toString();
    employeeData.bonus.text               = widget.employeeData!.bonus.toString();
    employeeData.WhatsappController.text  = widget.employeeData!.whatsapp.toString();
  Future.delayed(Duration.zero,(){
    setState(() {
      final roleId = widget.employeeData!.role?.toString();
      if (roleId != null && roleId != "null") {
        final match = employeeData.roleList.firstWhere(
              (item) => item['u_id'].toString() == roleId,
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          employeeData.role = match;              // set whole map {id, role_name, u_id}
          employeeData.roleId = match['u_id'];    // store u_id
        }
      }
    });
  });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(builder: (context, employeeProvider, _) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      bool isWebView = screenWidth > screenHeight;
      double textFieldSize = (MediaQuery.of(context).size.width - 400) / 2.5;
      return Scaffold(
        body: Row(
          children: [
            utils.sideBarFunction(context),
            Container(
              width: MediaQuery.of(context).size.width - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: screenWidth * 0.80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Expanded(
                              child: Center(
                                child: CustomText(
                                  text:"Update Employee Details",
                                  size: 20,
                                  colors: Colors.black,
                                  isBold:true,
                                ),
                              ),
                            ),
                          ],
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
                                  CustomTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Employee Name",
                                    hintText: "Enter Employee Name",
                                    controller: employeeProvider.nameController,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.textInput,
                                    isOptional: true,
                                  ),
                                  10.height,
                                  CustomTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Phone No",
                                    hintText: "Enter Phone No",
                                    inputFormatters: constInputFormatters.mobileNumberInput,
                                    controller: employeeProvider.mobileController,
                                    textInputAction: TextInputAction.next,
                                    isOptional: true,
                                  ),
                                  10.height,
                                  CustomPasswordTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Password",
                                    hintText: "Enter Password",
                                    controller: employeeProvider.password,
                                    inputFormatters: constInputFormatters.passwordInput,
                                    iconData : employeeProvider.isVisible ?
                                    Icons.visibility_off : Icons.visibility,
                                    textInputAction: TextInputAction.next,
                                    isOptional: true,
                                  ),
                                  // 10.height,
                                  // SizedBox(
                                  //   width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                                  //   child: CustomTextField(
                                  //     text: "Joining Date",
                                  //     hintText: "Enter Joining Date",
                                  //     controller: employeeProvider.date,
                                  //     textInputAction: TextInputAction.next,
                                  //     onTap: () async {
                                  //       DateTime? pickedDate = await showDatePicker(
                                  //         context: context,
                                  //         initialDate: DateTime.now(),
                                  //         firstDate: DateTime(2000),
                                  //         lastDate: DateTime(2101),
                                  //       );
                                  //       if (pickedDate != null) {
                                  //         String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                  //         employeeProvider.date.text = formattedDate;
                                  //       }
                                  //     },
                                  //   ),
                                  // ),
                                  10.height,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            text: "Role",
                                            colors: const Color(0xff757575),
                                            size: 13,
                                          ),
                                          const CustomText(
                                            text: "*",
                                            colors: Colors.red,
                                            size: 25,
                                          )
                                        ],
                                      ),
                                      5.height,
                                      Container(
                                        width: textFieldSize,
                                        height: 50,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            radius: 8,
                                            color: Colors.white,
                                            borderColor: Color(0xffD9D9D9)),
                                        child: DropdownButtonHideUnderline(
                                          child: ButtonTheme(
                                            alignedDropdown: true,
                                            child: DropdownButton(
                                              underline: const SizedBox(),
                                              isExpanded: true,
                                              value: employeeProvider.role,
                                              iconEnabledColor: Colors.black,
                                              hint: CustomText(
                                                text: "",
                                                colors: Colors.grey.shade400,
                                                size: 13,
                                                isBold: false,
                                                isStyle: true,
                                              ),
                                              items: employeeProvider.roleList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item,
                                                  child: CustomText(
                                                      text: item["role_name"],
                                                      colors: Colors.black,
                                                      size: 13,
                                                      isBold: false),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  employeeProvider.role = value!;
                                                  var list = [];
                                                  list.add(value);
                                                  employeeProvider.roleId = list[0]["u_id"];
                                                });
                                                // userProvider.storage.write("roleId",list[0]["id"]);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            20.width,

                            /// Right Column
                            Expanded(
                              child: Column(
                                children: [

                                  CustomTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Whatsapp No",
                                    hintText: "Enter Whatsapp No",
                                    isOptional: false,
                                    controller: employeeProvider.WhatsappController,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.mobileNumberInput,
                                  ),
                                  10.height,
                                  CustomTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Email",
                                    hintText: "Enter Email",
                                    isOptional: false,
                                    controller: employeeProvider.emailController,
                                    inputFormatters: constInputFormatters.emailInput,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  10.height,
                                  CustomTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Address",
                                    hintText: "Enter Address",
                                    isOptional: false,
                                    controller: employeeProvider.door,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.addressInput,
                                  ),
                                  CustomTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Salary",
                                    isOptional: false,
                                    hintText: "Enter Salary",
                                    controller: employeeProvider.salary,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.numberInput,
                                  ),
                                  10.height,
                                  CustomTextField(
                                    width: isWebView ? textFieldSize : screenWidth * 0.90,
                                    text: "Bonus",
                                    isOptional: false,
                                    hintText: "Enter Bonus",
                                    controller: employeeProvider.bonus,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.numberInput,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        10.height,
                        /// Submit Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: RoundedLoadingButton(
                                borderRadius: 5,
                                color: colorsConst.primary,
                                controller: employeeProvider.addEmployeeButtonController,
                                onPressed: () async {
                                  if (employeeProvider.nameController.text.isEmpty) {
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Name",
                                      color: Colors.red,
                                    );
                                    employeeProvider.addEmployeeButtonController.reset();
                                    return;
                                  }
                                  if (employeeProvider.mobileController.text.isEmpty) {
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Mobile Number",
                                      color: Colors.red,
                                    );
                                    employeeProvider.addEmployeeButtonController.reset();
                                    return;
                                  }
                                  if (employeeProvider.mobileController.text.length != 10) {
                                    employeeProvider.addEmployeeButtonController
                                        .reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter 10 digit Mobile Number",
                                      color: Colors.red,
                                    );
                                    return;
                                  }
                                  if (employeeProvider.password.text.isEmpty) {
                                    employeeProvider.addEmployeeButtonController
                                        .reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Password",
                                      color: Colors.red,
                                    );
                                    return;
                                  }
                                  if (employeeProvider.password.text.length < 8) {
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter above 8 digit Password",
                                      color: Colors.red,
                                    );
                                    return;
                                  }
                                  if (employeeProvider.roleId == null) {
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Role",
                                      color: Colors.red,
                                    );
                                    return;
                                  }
                                  employeeProvider.employeeUpdate(
                                    context: context,
                                    id: widget.employeeData?.id.toString(),
                                    empName: employeeProvider.nameController
                                        .text.trim(),
                                    empMobile: employeeProvider.mobileController
                                        .text.trim(),
                                    empAddress: employeeProvider.door.text
                                        .trim(),
                                    empBonus: employeeProvider.bonus.text
                                        .trim(),
                                    empEmail: employeeProvider.emailController
                                        .text.trim(),
                                    empPassword: employeeProvider.password.text
                                        .trim(),
                                    empJoinDate: employeeProvider.date.text
                                        .trim(),
                                    empRole: employeeProvider.roleId,
                                    empSalary: employeeProvider.salary.text
                                        .trim(),
                                    empWhatsapp: employeeProvider
                                        .mobileController.text.trim(),
                                    active: employeeProvider
                                        .selectedPublication ?? "1",
                                  );

                                },
                                child: CustomText(
                                  text: "Update Employee",
                                  colors: Colors.white,
                                  isBold:true,
                                ),
                              ),
                            ),

                            150.width,
                          ],
                        ),
                        50.height,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
