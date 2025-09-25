import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pss_web/common/extentions/extensions.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../api/color.dart';
import '../../common/component/k_text.dart';
import '../../common/component/k_text_form_field.dart';
import '../../common/extentions/input_formatter.dart';
import '../../common/util/toast.dart';
import '../../model/employee_details.dart';
import '../../model/role_details.dart';
import '../../view_model/employee_provider.dart';


class UpdateEmployee extends StatefulWidget {
  final double? screenWidth;
  final Staff? EmployeeData;
  const UpdateEmployee({super.key,  this.screenWidth, this.EmployeeData});

  @override
  State<UpdateEmployee> createState() => _UpdateEmployeeState();
}

class _UpdateEmployeeState extends State<UpdateEmployee> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final EmployeeData = Provider.of<EmployeeProvider>(context, listen: false);
    EmployeeData.roleDetailsData(context: context);
   // EmployeeData.clearAllEmployeeControllers();
    EmployeeData.nameController.text=widget.EmployeeData!.sName.toString();
    EmployeeData.mobileController.text=widget.EmployeeData!.sMobile.toString();
    EmployeeData.password.text=widget.EmployeeData!.password.toString();
    EmployeeData.date.text=widget.EmployeeData!.joiningDate.toString();
    EmployeeData.roleController.text=widget.EmployeeData!.role.toString();
    EmployeeData.otherRoleController.text=widget.EmployeeData!.otherRoles.toString();
    EmployeeData.emailController.text=widget.EmployeeData!.email.toString();
    EmployeeData.addressController.text=widget.EmployeeData!.sAddress.toString();
    EmployeeData.salary.text=widget.EmployeeData!.salary.toString();
    EmployeeData.bonus.text=widget.EmployeeData!.bonus.toString();
    EmployeeData.WhatsappController.text=widget.EmployeeData!.whatsapp.toString();
  }
  @override
  Widget build(BuildContext context) {

    final EmployeeData = Provider.of<EmployeeProvider>(context);
    return Consumer<EmployeeProvider>(builder: (context, employeeProvider, _) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      bool isWebView = screenWidth > screenHeight;

      return Scaffold(
        backgroundColor: colorsConst.bgColor,
        appBar: AppBar(
          backgroundColor: colorsConst.bgColor ,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
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
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Employee Name",
                                hintText: "Enter Employee Name",
                                controller: employeeProvider.nameController,
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                inputFormatters: InputFormatters.textInput,
                                isRequired: true,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Phone No",
                                hintText: "Enter Phone No",
                                inputFormatters: InputFormatters.mobileNumberInput,
                                controller: employeeProvider.mobileController,
                                textInputAction: TextInputAction.next,
                                isRequired: true,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Password",
                                hintText: "Enter Password",
                                controller: employeeProvider.password,
                                maxLines: 1,
                                inputFormatters: InputFormatters.passwordInput,
                                obscureText: employeeProvider.isVisible,
                                suffixIcon: IconButton(
                                  onPressed: (){
                                    employeeProvider.switchObscure();
                                  },
                                  icon: Icon(employeeProvider.isVisible ? Icons.visibility_off : Icons.visibility),
                                ),
                                textInputAction: TextInputAction.next,
                                isRequired: true,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Joining Date",
                                hintText: "Enter Joining Date",
                                controller: employeeProvider.date,
                                textInputAction: TextInputAction.next,
                                suffixIcon: Icon(Icons.calendar_today),
                                ReadOnly:true,
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                    employeeProvider.date.text = formattedDate;
                                  }
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
                                      CustomText(text: "Position/ Role",color: colorsConst.labelTextColor,fontSize: 13,),
                                      CustomText(text: "*",fontSize: 13,color: Colors.red,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: DropdownMenu<Role>(
                                controller: EmployeeData.roleController,
                                width: isWebView ? screenWidth * 0.25 : screenWidth * 0.65,
                                menuHeight: screenHeight * 0.30,
                                hintText: "Select Role",
                                requestFocusOnTap: true,
                                enableFilter: true,
                                initialSelection: EmployeeData.roleTitles.firstWhere(
                                      (role) => role.id == widget.EmployeeData!.id,
                                  orElse: () => EmployeeData.roleTitles.first,
                                ),
                                onSelected: (Role? value) {
                                  if (value != null) {
                                    final selectedRoleId = value.id;
                                    employeeProvider.selectedRoleSetter(value);
                                    employeeProvider.roleController.text = value.roleTitle!;
                                    print('Selected Role ID: $selectedRoleId');
                                  }
                                },
                                dropdownMenuEntries: EmployeeData.roleTitles.map((Role role) {
                                  return DropdownMenuEntry<Role>(
                                    value: role,
                                    label: role.roleTitle.toString(),
                                    leadingIcon: Icon(Icons.person_outline),
                                  );
                                }).toList(),
                              ),

                            ),
                            10.height,
                            SizedBox(
                                width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                                child: Row(
                                  children: [
                                    CustomText(text: "Other Roles",fontSize: 13,color: colorsConst.labelTextColor,),
                                  ],
                                )
                            ),
                            20.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: TextField(
                                controller: EmployeeData.otherRoleController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Select Roles",
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                  border: OutlineInputBorder(), // Default outline border
                                  enabledBorder: OutlineInputBorder( // When not focused
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder( // When focused
                                    borderSide: BorderSide(color: Colors.blue, width: 2),
                                  ),
                                ),
                                onTap: () => EmployeeData.showRoleMultiSelect(context),
                              ),

                            )
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
                              child: CustomTextFormField(
                                labelHead: "Whatsapp No",
                                hintText: "Enter Whatsapp No",
                                controller: employeeProvider.WhatsappController,
                                textInputAction: TextInputAction.next,
                                inputFormatters: InputFormatters.mobileNumberInput,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Email",
                                hintText: "Enter Email",
                                controller: employeeProvider.emailController,
                                inputFormatters: InputFormatters.emailInput,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Address",
                                hintText: "Address",
                                controller: employeeProvider.door,
                                textInputAction: TextInputAction.next,
                                inputFormatters: InputFormatters.addressInput,


                              ),
                            ),

                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Salary",
                                hintText: "Enter Salary",
                                controller: employeeProvider.salary,
                                textInputAction: TextInputAction.next,
                                inputFormatters: InputFormatters.numberInput,
                              ),
                            ),
                            10.height,
                            SizedBox(
                              width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                              child: CustomTextFormField(
                                labelHead: "Bonus",
                                hintText: "Enter Bonus",
                                controller: employeeProvider.bonus,
                                textInputAction: TextInputAction.next,
                                inputFormatters: InputFormatters.numberInput,
                              ),
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
                            final name = employeeProvider.nameController.text.trim();
                            final mobile = employeeProvider.mobileController.text.trim();
                            final password = employeeProvider.password.text.trim();
                            final primaryRoleId = EmployeeData.selectedRole?.id;
                            final otherRoleIds = EmployeeData.selectedRoles.map((e) => e.id).join(',');

                            // Basic validation
                            if (name.isEmpty) {
                              ToastMsg.showSnackbar(context: context, text: "Please Enter Name", backgroundColor: colorsConst.infoColor);
                              employeeProvider.addEmployeeButtonController.reset();
                              return;
                            }
                            if (mobile.isEmpty) {
                              ToastMsg.showSnackbar(context: context, text: "Please Enter Mobile Number", backgroundColor: colorsConst.infoColor);
                              employeeProvider.addEmployeeButtonController.reset();
                              return;
                            }
                            if (password.isEmpty) {
                              ToastMsg.showSnackbar(context: context, text: "Please Enter Password", backgroundColor: colorsConst.infoColor);
                              employeeProvider.addEmployeeButtonController.reset();
                              return;
                            }
                            if (primaryRoleId == null) {
                              ToastMsg.showSnackbar(context: context, text: "Please Enter Role", backgroundColor: colorsConst.infoColor);
                              employeeProvider.addEmployeeButtonController.reset();
                              return;
                            }

                            try {
                              // Optional: remove some excessive logs or keep minimal for debugging
                              log("Updating employee: $name ($mobile)");

                              await employeeProvider.employeeUpdate(
                                context: context,
                                id: widget.EmployeeData?.id.toString(),
                                emp_name: name,
                                emp_mobile: mobile,
                                emp_address: employeeProvider.door.text.trim(),
                                emp_bonus: employeeProvider.bonus.text.trim(),
                                emp_email: employeeProvider.emailController.text.trim(),
                                emp_password: password,
                                emp_join_date: employeeProvider.date.text.trim(),
                                emp_role: primaryRoleId,
                                emp_salary: employeeProvider.salary.text.trim(),
                                emp_whatsapp: mobile,
                                active: employeeProvider.selectedPublication ?? "1",
                                roles: otherRoleIds,
                              );

                              // On success
                              employeeProvider.addEmployeeButtonController.success();
                            } catch (e) {
                              // On error
                              employeeProvider.addEmployeeButtonController.error();
                              ToastMsg.showSnackbar(context: context, text: "Update failed. Please try again.", backgroundColor: Colors.red);
                            } finally {
                              await Future.delayed(Duration(seconds: 1)); // Optional: short delay before reset
                              employeeProvider.addEmployeeButtonController.reset();
                            }
                          },
                          child: CustomText(
                            text: "Update Employee",
                            color: colorsConst.fontWhite,
                            fontWeight: FontWeight.bold,
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
      );
    });
  }
}
