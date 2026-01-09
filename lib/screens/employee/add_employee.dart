import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/components/custom_textfield.dart';
import 'package:fullcomm_crm/components/password_text_field.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../common/styles/decoration.dart';
import '../../components/custom_sidebar.dart';
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
            SideBar(),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: (){
                                  Get.back();
                                },
                                icon: Icon(Icons.arrow_back,color: colorsConst.third,)),
                            20.width,
                            Center(
                              child: CustomText(
                                text: "Add Employee Details",
                                size: 20,
                                colors: Colors.black,
                                isBold: true,
                                isCopy: true,
                              ),
                            ),
                          ],
                        ),
                        50.height,
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
                                    onChanged: (value){
                                      if (value.toString().isNotEmpty) {
                                        String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                        if (newValue != value) {
                                          employeeProvider.nameController.value = employeeProvider.nameController.value.copyWith(
                                            text: newValue,
                                            selection: TextSelection.collapsed(offset: newValue.length),
                                          );
                                        }
                                      }
                                    },
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.textInput,
                                    isOptional: true,
                                  ),
                                  // SizedBox(
                                  //   width: textFieldSize,
                                  //   height: 50,
                                  //   child: TextFormField(
                                  //       style: TextStyle(
                                  //           color: colorsConst.textColor,
                                  //           fontSize: 14,
                                  //           fontFamily: "Lato"),
                                  //       cursorColor: colorsConst.primary,
                                  //       onTap: () {},
                                  //       keyboardType: TextInputType.number,
                                  //       inputFormatters: constInputFormatters.mobileNumberInput,
                                  //       textCapitalization: TextCapitalization.none,
                                  //       controller: employeeProvider.mobileController,
                                  //       textInputAction: TextInputAction.next,
                                  //       decoration: InputDecoration(
                                  //         hoverColor: Colors.transparent,
                                  //         focusColor: Colors.transparent,
                                  //         hintText:"Phone No",
                                  //         fillColor: Colors.white,
                                  //         filled: true,
                                  //         hintStyle: TextStyle(
                                  //             color: Colors.grey.shade400,
                                  //             fontSize: 13, fontFamily: "Lato"),
                                  //         suffixIcon: Obx(() => Checkbox(
                                  //             shape: RoundedRectangleBorder(
                                  //               borderRadius: BorderRadius.circular(5.0),
                                  //             ),
                                  //             side: MaterialStateBorderSide.resolveWith(
                                  //                   (states) => BorderSide(
                                  //                   width: 1.0,
                                  //                   color: colorsConst.textColor),
                                  //             ),
                                  //             hoverColor: Colors.transparent,
                                  //             activeColor: colorsConst.third,
                                  //             value: controllers.isCoMobileNumberList[index],
                                  //             onChanged: (value) {
                                  //               setState(() {
                                  //                 controllers.isCoMobileNumberList[index] = value!;
                                  //                 if (controllers.isCoMobileNumberList[index] == true) {
                                  //                   controllers.leadWhatsCrt[index].text = controllers.leadMobileCrt[index].text;
                                  //                 } else {
                                  //                   print("in");
                                  //                   controllers.leadWhatsCrt[index].text = "";
                                  //                 }
                                  //               });
                                  //             }),
                                  //         ),
                                  //         enabledBorder: OutlineInputBorder(
                                  //             borderSide: BorderSide(
                                  //               color: Colors.grey.shade200,
                                  //             ),
                                  //             borderRadius: BorderRadius.circular(5)),
                                  //         focusedBorder:
                                  //         OutlineInputBorder(
                                  //             borderSide: BorderSide(
                                  //               color: Colors.grey.shade200,
                                  //             ),
                                  //             borderRadius: BorderRadius.circular(5)),
                                  //         focusedErrorBorder: OutlineInputBorder(
                                  //             borderSide: BorderSide(
                                  //                 color: Colors.grey.shade200),
                                  //             borderRadius: BorderRadius.circular(5)),
                                  //         // errorStyle: const TextStyle(height:0.05,fontSize: 12),
                                  //         contentPadding: const EdgeInsets.symmetric(
                                  //             vertical: 10.0,
                                  //             horizontal: 10.0),
                                  //         errorBorder: OutlineInputBorder(
                                  //             borderSide: BorderSide(
                                  //                 color: Colors.grey.shade200),
                                  //             borderRadius: BorderRadius.circular(5)),
                                  //       )),
                                  // ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Phone No",
                                    hintText: "Enter Phone No",
                                    inputFormatters: constInputFormatters.mobileNumberInput,
                                    controller: employeeProvider.mobileController,
                                    textInputAction: TextInputAction.next,
                                    isOptional: true,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Whatsapp No",
                                    hintText: "Enter Whatsapp No",
                                    isOptional: false,
                                    controller: employeeProvider.WhatsappController,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.mobileNumberInput,
                                  ),
                                  CustomPasswordTextField(
                                    width: textFieldSize,
                                    height: 45,
                                    text: "Password",
                                    hintText: "Enter Password",
                                    controller: employeeProvider.password,
                                    inputFormatters: constInputFormatters.passwordInput,
                                    textInputAction: TextInputAction.next,
                                    isOptional: true,
                                    iconData : employeeProvider.isVisible ?
                                    Icons.visibility_off : Icons.visibility,
                                  ),
                                  20.height,
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Door No",
                                    hintText: "Enter Door No",
                                    isOptional: false,
                                    controller: employeeProvider.door,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Area",
                                    hintText: "Enter Area",
                                    isOptional: false,
                                    controller: employeeProvider.area,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  CustomTextField(
                                    hintText: "State",
                                    text: "State",
                                    controller: controllers.stateController,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            text: "Role",
                                            colors: const Color(0xff757575),
                                            size: 13,
                                            isCopy: false,
                                          ),
                                          const CustomText(
                                            text: "*",
                                            colors: Colors.red,
                                            size: 25,
                                            isCopy: false,
                                          )
                                        ],
                                      ),
                                      Container(
                                        width: textFieldSize,
                                        height: 40,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            radius: 8,
                                            color: Colors.white,
                                            borderColor: Colors.grey.shade400),
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
                                                isCopy: true,
                                              ),
                                              items: employeeProvider.roleList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item,
                                                  child: CustomText(
                                                      text: item["role_name"],
                                                      colors: Colors.black,
                                                      size: 13,
                                                      isCopy: false,
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
                                  25.height,
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
                                  // CustomTextField(
                                  //   width: textFieldSize,
                                  //   text: "Address",
                                  //   hintText: "Enter Address",
                                  //   controller: employeeProvider.door,
                                  //   textInputAction: TextInputAction.next,
                                  //   isOptional: false,
                                  //   inputFormatters: constInputFormatters.addressInput,
                                  // ),
                                  CustomTextField(
                                    text: "Salary",
                                    width: textFieldSize,
                                    isOptional: false,
                                    hintText: "Enter Salary",
                                    controller: employeeProvider.salary,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.numberInput,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Bonus",
                                    isOptional: false,
                                    hintText: "Enter Bonus",
                                    controller: employeeProvider.bonus,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.numberInput,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Street",
                                    hintText: "Enter Street",
                                    isOptional: false,
                                    controller: employeeProvider.street,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "City",
                                    hintText: "Enter City",
                                    isOptional: false,
                                    controller: employeeProvider.city,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.textInput,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            text:"Country",
                                            size: 13,
                                            colors: Color(0xff4B5563),
                                            isCopy: true,
                                          ),
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              width: textFieldSize,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(5),
                                                  border: Border.all(color: Colors.grey.shade400)),
                                              child: Obx(() => CustomText(
                                                text: "    ${controllers.selectedCountry.value}",
                                                isCopy: false,
                                                colors: colorsConst.textColor,
                                                size: 15,
                                              ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  )
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
                                  final addressParts = [
                                    employeeProvider.door.text,
                                    employeeProvider.street.text,
                                    employeeProvider.area.text,
                                    employeeProvider.city.text,
                                    controllers.stateController.text,
                                    controllers.selectedCountry.value,
                                  ];
                                  final filtered = addressParts.where((e) => e.trim().isNotEmpty).toList();
                                  final finalAddress = filtered.join(',');
                                 if(employeeProvider.nameController.text.isEmpty){
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter Employee Name",
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
                                  }else if(employeeProvider.WhatsappController.text.isNotEmpty&&employeeProvider.WhatsappController.text.length!=10){
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
                                   final int currentLimit = int.tryParse(controllers.currentUserCount.value) ?? 0;
                                   // if (employeeProvider.filteredStaff.length >= currentLimit) {
                                   //   print("Only after making a payment, you can add employees.");
                                   //   utils.expiredEmpDialog();
                                   //   employeeProvider.addEmployeeButtonController.reset();
                                   // }else{
                                     if(employeeProvider.emailController.text.isEmpty){
                                       employeeProvider.employeeInsert(
                                         context: context,
                                         empName: employeeProvider.nameController.text.toString(),
                                         empMobile: employeeProvider.mobileController.text.toString(),
                                         empAddress: finalAddress,
                                         empBonus: employeeProvider.bonus.text.toString(),
                                         empEmail: employeeProvider.emailController.text.toString(),
                                         empPassword: employeeProvider.password.text.toString(),
                                         empJoinDate: employeeProvider.date.text.toString(),
                                         empRole:employeeProvider.roleId,
                                         empSalary: employeeProvider.salary.text.toString(),
                                         empWhatsapp: employeeProvider.mobileController.text.trim().toString(),
                                         active: employeeProvider.selectedPublication ?? "1",
                                       );
                                     }else{
                                         if (employeeProvider.emailController.text.isEmpty) {
                                           employeeProvider.employeeInsert(
                                             context: context,
                                             empName: employeeProvider.nameController.text.toString(),
                                             empMobile: employeeProvider.mobileController.text.toString(),
                                             empAddress:finalAddress,
                                             empBonus: employeeProvider.bonus.text.toString(),
                                             empEmail: employeeProvider.emailController.text.toString(),
                                             empPassword: employeeProvider.password.text.toString(),
                                             empJoinDate: employeeProvider.date.text.toString(),
                                             empRole:employeeProvider.roleId,
                                             empSalary: employeeProvider.salary.text.toString(),
                                             empWhatsapp: employeeProvider.WhatsappController.text.trim().toString(),
                                             active: employeeProvider.selectedPublication ?? "1",
                                           );
                                         } else {
                                           if(employeeProvider.emailController.text.isEmail){
                                             employeeProvider.employeeInsert(
                                               context: context,
                                               empName: employeeProvider.nameController.text.toString(),
                                               empMobile: employeeProvider.mobileController.text.toString(),
                                               empAddress: finalAddress,
                                               empBonus: employeeProvider.bonus.text.toString(),
                                               empEmail: employeeProvider.emailController.text.toString(),
                                               empPassword: employeeProvider.password.text.toString(),
                                               empJoinDate: employeeProvider.date.text.toString(),
                                               empRole:employeeProvider.roleId,
                                               empSalary: employeeProvider.salary.text.toString(),
                                               empWhatsapp: employeeProvider.WhatsappController.text.trim().toString(),
                                               active: employeeProvider.selectedPublication ?? "1",
                                             );
                                           }else{
                                             employeeProvider.addEmployeeButtonController.reset();
                                             utils.snackBar(
                                               context: context,
                                               msg: "Please Enter Valid Email",
                                               color: Colors.red,
                                             );
                                           }
                                         }
                                     }
                                   }
                                  // }
                                },
                                child: CustomText(
                                  text: "Save",
                                  colors: Colors.white,
                                  isBold: true,
                                  isCopy: false,
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
