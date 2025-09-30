import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/components/custom_textfield.dart';
import 'package:fullcomm_crm/components/password_text_field.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:web/web.dart';

import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../common/styles/decoration.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      employeeData.clearAllEmployeeControllers();
      employeeData.fetchRoleList();
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
                                  CustomTextField(
                                    width: textFieldSize,
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
                                    width: textFieldSize,
                                    text: "Phone No",
                                    hintText: "Enter Phone No",
                                    inputFormatters: constInputFormatters.mobileNumberInput,
                                    controller: employeeProvider.mobileController,
                                    textInputAction: TextInputAction.next,
                                    isOptional: true,
                                  ),
                                  10.height,
                                  CustomPasswordTextField(
                                    width: textFieldSize,
                                    text: "Password",
                                    hintText: "Enter Password",
                                    controller: employeeProvider.password,
                                    inputFormatters: constInputFormatters.passwordInput,
                                    textInputAction: TextInputAction.next,
                                    isOptional: true,
                                    iconData : employeeProvider.isVisible ?
                                    Icons.visibility_off : Icons.visibility,
                                  ),
                                  10.height,
                              //     SizedBox(
                              //   width: isWebView ? textFieldSize : screenWidth * 0.90,
                              //   child: CustomTextField(
                              //     text: 'Expected Joining Date',
                              //     hintText: 'Expected Joining Date',
                              //     isOptional: false,
                              //     controller:
                              //     employeeProvider.date,
                              //     textInputAction: TextInputAction.next,
                              //     textCapitalization: TextCapitalization.sentences,
                              //     onChanged: (value){
                              //       employeeProvider.selectDate(context);
                              //     },
                              //
                              //   ),
                              // ),
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
                                  20.height,
                                ],
                              ),
                            ),
                            20.width,
                            /// Right Column
                            Expanded(
                              child: Column(
                                children: [
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Whatsapp No",
                                    hintText: "Enter Whatsapp No",
                                    isOptional: false,
                                    controller: employeeProvider.WhatsappController,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.mobileNumberInput,
                                  ),
                                  10.height,
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Email",
                                    hintText: "Enter Email",
                                    isOptional: false,
                                    controller: employeeProvider.emailController,
                                    inputFormatters: constInputFormatters.emailInput,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  10.height,
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Address",
                                    hintText: "Enter Address",
                                    controller: employeeProvider.door,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
                                    inputFormatters: constInputFormatters.addressInput,
                                  ),

                                  CustomTextField(
                                    text: "Salary",
                                    width: textFieldSize,
                                    isOptional: false,
                                    hintText: "Enter Salary",
                                    controller: employeeProvider.salary,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.numberInput,
                                  ),
                                  10.height,
                                  CustomTextField(
                                    width: textFieldSize,
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
                                onPressed: () {
                                 if(employeeProvider.nameController.text.isEmpty){
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Name",
                                      color: Colors.red,
                                    );
                                  }
                                  else if(employeeProvider.mobileController.text.isEmpty){
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Mobile Number",
                                      color: Colors.red,
                                    );
                                  }else if(employeeProvider.mobileController.text.length!=10){
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter 10 digit Mobile Number",
                                      color: Colors.red,
                                    );
                                  }
                                  else if(employeeProvider.password.text.isEmpty){
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Password",
                                      color: Colors.red,
                                    );
                                  }
                                  else if(employeeProvider.password.text.length<8) {
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter above 8 digit Password",
                                      color: Colors.red,
                                    );
                                  }
                                  else if(employeeProvider.roleId==null){
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Role",
                                      color: Colors.red,
                                    );
                                  } else {
                                   if (employeeProvider.filteredStaff.length >= int.parse(controllers.currentUserCount.value)) {
                                     print("Only after making a payment, you can add employees.");
                                     utils.expiredEmpDialog();
                                     employeeProvider.addEmployeeButtonController.reset();
                                   }else{
                                     employeeProvider.employeeInsert(
                                       context: context,
                                       empName: employeeProvider.nameController.text.toString(),
                                       empMobile: employeeProvider.mobileController.text.toString(),
                                       empAddress: employeeProvider.door.text.toString(),
                                       empBonus: employeeProvider.bonus.text.toString(),
                                       empEmail: employeeProvider.emailController.text.toString(),
                                       empPassword: employeeProvider.password.text.toString(),
                                       empJoinDate: employeeProvider.date.text.toString(),
                                       empRole:employeeProvider.roleId,
                                       empSalary: employeeProvider.salary.text.toString(),
                                       empWhatsapp: employeeProvider.mobileController.text.trim().toString(),
                                       active: employeeProvider.selectedPublication ?? "1",
                                     );
                                   }
                                  }
                                },
                                child: CustomText(
                                  text: "Save",
                                  colors: Colors.white,
                                  isBold: true,
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
