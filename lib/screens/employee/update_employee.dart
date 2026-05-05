import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../common/styles/decoration.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/password_text_field.dart';
import '../../controller/controller.dart';
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
  /// FOCUS NODES
  final FocusNode nameFocus = FocusNode();
  final FocusNode mobileFocus = FocusNode();
  final FocusNode whatsappFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode doorFocus = FocusNode();
  final FocusNode areaFocus = FocusNode();
  final FocusNode streetFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode stateFocus = FocusNode();
  final FocusNode salaryFocus = FocusNode();
  final FocusNode bonusFocus = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
    if(employeeData.roleList.isEmpty){
      employeeData.fetchRoleList();
    }
    if(employeeData.depList.isEmpty){
      employeeData.fetchDepList();
    }

    // EmployeeData.clearAllEmployeeControllers();

  Future.delayed(Duration.zero,(){
    setState(() {
      employeeData.nameController.text      = widget.employeeData!.sName.toString().isEmpty||widget.employeeData!.sName.toString()=='null'?"":widget.employeeData!.sName.toString();
      employeeData.mobileController.text    = widget.employeeData!.sMobile.toString().isEmpty||widget.employeeData!.sMobile.toString()=='null'?"":widget.employeeData!.sMobile.toString();
      employeeData.password.text            = widget.employeeData!.password.toString().isEmpty||widget.employeeData!.password.toString()=='null'?"":widget.employeeData!.password.toString();
      employeeData.date.text                = widget.employeeData!.joiningDate.toString().isEmpty||widget.employeeData!.joiningDate.toString()=='null'?"":widget.employeeData!.joiningDate.toString();
      employeeData.roleController.text      = widget.employeeData!.role.toString().isEmpty||widget.employeeData!.role.toString()=='null'?"":widget.employeeData!.role.toString();
      employeeData.otherRoleController.text = widget.employeeData!.otherRoles.toString().isEmpty||widget.employeeData!.otherRoles.toString()=='null'?"":widget.employeeData!.otherRoles.toString();
      employeeData.emailController.text     = widget.employeeData!.email.toString().isEmpty||widget.employeeData!.email.toString()=='null'?"":widget.employeeData!.email.toString();
      employeeData.door.text                = widget.employeeData!.sAddress.toString().isEmpty||widget.employeeData!.sAddress.toString()=='null'?"":widget.employeeData!.sAddress.toString();
      employeeData.salary.text              = widget.employeeData!.salary.toString().isEmpty||widget.employeeData!.salary.toString()=='null'?"":widget.employeeData!.salary.toString();
      employeeData.bonus.text               = widget.employeeData!.bonus.toString().isEmpty||widget.employeeData!.bonus.toString()=='null'?"":widget.employeeData!.bonus.toString();
      employeeData.WhatsappController.text  = widget.employeeData!.whatsapp.toString().isEmpty||widget.employeeData!.whatsapp.toString()=='null'?"":widget.employeeData!.whatsapp.toString();
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
      final depId = widget.employeeData!.dId?.toString();
      if (depId != null && depId != "null") {
        final match = employeeData.depList.firstWhere(
              (item) => item['id'].toString() == depId,
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          employeeData.dep = match;              // set whole map {id, role_name, u_id}
          employeeData.depId = match['id'];    // store u_id
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
                                  isCopy: false,
                                  colors: Colors.black,
                                  isBold:true,
                                ),
                              ),
                            ),
                          ],
                        ),

                        20.height,
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     /// Left Column
                        //     Expanded(
                        //       child: Column(
                        //         children: [
                        //           CustomTextField(
                        //             width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //             text: "Employee Name",
                        //             hintText: "Enter Employee Name",
                        //             controller: employeeProvider.nameController,
                        //             keyboardType: TextInputType.name,
                        //             textInputAction: TextInputAction.next,
                        //             inputFormatters: constInputFormatters.textInput,
                        //             isOptional: true,
                        //           ),
                        //           10.height,
                        //           CustomTextField(
                        //             width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //             text: "Phone No",
                        //             hintText: "Enter Phone No",
                        //             inputFormatters: constInputFormatters.mobileNumberInput,
                        //             controller: employeeProvider.mobileController,
                        //             textInputAction: TextInputAction.next,
                        //             isOptional: true,
                        //           ),
                        //           // 10.height,
                        //           // CustomPasswordTextField(
                        //           //   width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //           //   text: "Password",
                        //           //   hintText: "Enter Password",
                        //           //   controller: employeeProvider.password,
                        //           //   inputFormatters: constInputFormatters.passwordInput,
                        //           //   iconData : employeeProvider.isVisible ?
                        //           //   Icons.visibility_off : Icons.visibility,
                        //           //   textInputAction: TextInputAction.next,
                        //           //   isOptional: true,
                        //           // ),
                        //           // 10.height,
                        //           // SizedBox(
                        //           //   width: isWebView ? screenWidth * 0.25 : screenWidth * 0.90,
                        //           //   child: CustomTextField(
                        //           //     text: "Joining Date",
                        //           //     hintText: "Enter Joining Date",
                        //           //     controller: employeeProvider.date,
                        //           //     textInputAction: TextInputAction.next,
                        //           //     onTap: () async {
                        //           //       DateTime? pickedDate = await showDatePicker(
                        //           //         context: context,
                        //           //         initialDate: DateTime.now(),
                        //           //         firstDate: DateTime(2000),
                        //           //         lastDate: DateTime(2101),
                        //           //       );
                        //           //       if (pickedDate != null) {
                        //           //         String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        //           //         employeeProvider.date.text = formattedDate;
                        //           //       }
                        //           //     },
                        //           //   ),
                        //           // ),
                        //           // 5.height,
                        //           Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               Row(
                        //                 children: [
                        //                   CustomText(
                        //                     text: "Role",
                        //                     colors: const Color(0xff757575),
                        //                     size: 13,
                        //                     isCopy: false,
                        //                   ),
                        //                   const CustomText(
                        //                     text: "*",
                        //                     colors: Colors.red,
                        //                     size: 25,
                        //                     isCopy: false,
                        //                   )
                        //                 ],
                        //               ),
                        //               // 5.height,
                        //               Container(
                        //                 width: textFieldSize,
                        //                 height: 45,
                        //                 decoration: customDecoration.baseBackgroundDecoration(
                        //                     radius: 8,
                        //                     color: Colors.white,
                        //                     borderColor: Color(0xffD9D9D9)),
                        //                 child: DropdownButtonHideUnderline(
                        //                   child: ButtonTheme(
                        //                     alignedDropdown: true,
                        //                     child: DropdownButton(
                        //                       underline: const SizedBox(),
                        //                       isExpanded: true,
                        //                       value: employeeProvider.role,
                        //                       iconEnabledColor: Colors.black,
                        //                       hint: CustomText(
                        //                         text: "",
                        //                         colors: Colors.grey.shade400,
                        //                         size: 13,
                        //                         isBold: false,
                        //                         isStyle: true,
                        //                         isCopy: false,
                        //                       ),
                        //                       items: employeeProvider.roleList.map((item) {
                        //                         return DropdownMenuItem(
                        //                           value: item,
                        //                           child: CustomText(
                        //                               text: item["role_name"],
                        //                               colors: Colors.black,
                        //                               size: 13,
                        //                               isCopy: false,
                        //                               isBold: false),
                        //                         );
                        //                       }).toList(),
                        //                       onChanged: (value) {
                        //                         setState(() {
                        //                           employeeProvider.role = value!;
                        //                           var list = [];
                        //                           list.add(value);
                        //                           employeeProvider.roleId = list[0]["u_id"];
                        //                         });
                        //                         // userProvider.storage.write("roleId",list[0]["id"]);
                        //                       },
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ),
                        //               10.height,
                        //               CustomTextField(
                        //                 width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //                 text: "Bonus",
                        //                 isOptional: false,
                        //                 hintText: "Enter Bonus",
                        //                 controller: employeeProvider.bonus,
                        //                 textInputAction: TextInputAction.next,
                        //                 inputFormatters: constInputFormatters.numberInput,
                        //               ),
                        //             ],
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //
                        //     20.width,
                        //
                        //     /// Right Column
                        //     Expanded(
                        //       child: Column(
                        //         children: [
                        //
                        //           CustomTextField(
                        //             width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //             text: "Whatsapp No",
                        //             hintText: "Enter Whatsapp No",
                        //             isOptional: false,
                        //             controller: employeeProvider.WhatsappController,
                        //             textInputAction: TextInputAction.next,
                        //             inputFormatters: constInputFormatters.mobileNumberInput,
                        //           ),
                        //           10.height,
                        //           CustomTextField(
                        //             width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //             text: "Email",
                        //             hintText: "Enter Email",
                        //             isOptional: false,
                        //             controller: employeeProvider.emailController,
                        //             inputFormatters: constInputFormatters.emailInput,
                        //             textInputAction: TextInputAction.next,
                        //           ),
                        //           10.height,
                        //           CustomTextField(
                        //             width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //             text: "Address",
                        //             hintText: "Enter Address",
                        //             isOptional: false,
                        //             controller: employeeProvider.door,
                        //             textInputAction: TextInputAction.next,
                        //             inputFormatters: constInputFormatters.addressInput,
                        //           ),
                        //           CustomTextField(
                        //             width: isWebView ? textFieldSize : screenWidth * 0.90,
                        //             text: "Salary",
                        //             isOptional: false,
                        //             hintText: "Enter Salary",
                        //             controller: employeeProvider.salary,
                        //             textInputAction: TextInputAction.next,
                        //             inputFormatters: constInputFormatters.numberInput,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
                                    focusNode: nameFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(mobileFocus);
                                    },
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
                                    focusNode: mobileFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(whatsappFocus);
                                    },
                                    isOptional: true,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Whatsapp No",
                                    hintText: "Enter Whatsapp No",
                                    isOptional: false,
                                    focusNode: whatsappFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(emailFocus);
                                    },
                                    controller: employeeProvider.WhatsappController,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.mobileNumberInput,
                                  ),
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
                                  20.height,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            text: "Department",
                                            colors: const Color(0xff757575),
                                            size: 13,
                                            isCopy: false,
                                          ),
                                          const CustomText(
                                            text: "*",
                                            colors: Colors.red,
                                            size: 25,
                                            isCopy: false,
                                          ),
                                          IconButton(onPressed: (){
                                            employeeProvider.addDepartmentDialog(context);
                                          }, icon: Icon(Icons.add))
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
                                              value: employeeProvider.dep,
                                              iconEnabledColor: Colors.black,
                                              hint: CustomText(
                                                text: "",
                                                colors: Colors.grey.shade400,
                                                size: 13,
                                                isBold: false,
                                                isStyle: true,
                                                isCopy: true,
                                              ),
                                              items: employeeProvider.depList.map((item) {
                                                return DropdownMenuItem(
                                                  value: item,
                                                  child: CustomText(
                                                      text: item["department"],
                                                      colors: Colors.black,
                                                      size: 13,
                                                      isCopy: false,
                                                      isBold: false),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  employeeProvider.dep = value!;
                                                  var list = [];
                                                  list.add(value);
                                                  employeeProvider.depId = list[0]["id"];
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  20.height,
                                  CustomTextField(
                                    width: textFieldSize,
                                    focusNode: emailFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(salaryFocus);
                                    },
                                    text: "Email",
                                    hintText: "Enter Email",
                                    isOptional: false,
                                    controller: employeeProvider.emailController,
                                    inputFormatters: constInputFormatters.emailInput,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  CustomTextField(
                                    text: "Salary",
                                    width: textFieldSize,
                                    isOptional: false,
                                    focusNode: salaryFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(doorFocus);
                                    },
                                    hintText: "Enter Salary",
                                    controller: employeeProvider.salary,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.numberInput,
                                  ),
                                  10.height,
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
                                    text: "Door No",
                                    hintText: "Enter Door No",
                                    isOptional: false,
                                    focusNode: doorFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(areaFocus);
                                    },
                                    controller: employeeProvider.door,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Area",
                                    hintText: "Enter Area",
                                    isOptional: false,
                                    focusNode: areaFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(streetFocus);
                                    },
                                    controller: employeeProvider.area,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Street",
                                    hintText: "Enter Street",
                                    isOptional: false,
                                    focusNode: streetFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(cityFocus);
                                    },
                                    controller: employeeProvider.street,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "City",
                                    hintText: "Enter City",
                                    isOptional: false,
                                    focusNode: cityFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(stateFocus);
                                    },
                                    controller: employeeProvider.city,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.textInput,
                                  ),
                                  CustomTextField(
                                    hintText: "State",
                                    text: "State",
                                    focusNode: stateFocus,
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(bonusFocus);
                                    },
                                    controller: controllers.stateController,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
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
                                  ),
                                  20.height,
                                  CustomTextField(
                                    width: textFieldSize,
                                    text: "Bonus",
                                    focusNode: bonusFocus,
                                    onFieldSubmitted: (_) {
                                      if (employeeProvider.nameController.text.isEmpty) {
                                        utils.snackBar(
                                          context: context,
                                          msg: "Please Enter Employee Name",
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
                                      if(employeeProvider.WhatsappController.text.trim().isNotEmpty&&employeeProvider.WhatsappController.text.length!=10){
                                        employeeProvider.addEmployeeButtonController.reset();
                                        utils.snackBar(
                                          context: context,
                                          msg: "Please Enter 10 digit Whatsapp Number",
                                          color: Colors.red,
                                        );
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
                                      if (employeeProvider.role == null) {
                                        employeeProvider.addEmployeeButtonController.reset();
                                        utils.snackBar(
                                          context: context,
                                          msg: "Please Select Role",
                                          color: Colors.red,
                                        );
                                        return;
                                      }
                                      if (employeeProvider.dep == null) {
                                        employeeProvider.addEmployeeButtonController.reset();
                                        utils.snackBar(
                                          context: context,
                                          msg: "Please Select Role",
                                          color: Colors.red,
                                        );
                                        return;
                                      }
                                      if(employeeProvider.emailController.text.trim().isEmpty){
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
                                          empDep: employeeProvider.depId,
                                          empSalary: employeeProvider.salary.text
                                              .trim(),
                                          empWhatsapp: employeeProvider.WhatsappController.text.trim(),
                                          active: employeeProvider
                                              .selectedPublication ?? "1",
                                        );
                                      }
                                      else{
                                        if(!employeeProvider.emailController.text.trim().isEmail){
                                          employeeProvider.addEmployeeButtonController.reset();
                                          utils.snackBar(
                                            context: context,
                                            msg: "Please Enter Valid Email",
                                            color: Colors.red,
                                          );
                                          return;
                                        }else{
                                          employeeProvider.employeeUpdate(
                                            context: context,
                                            id: widget.employeeData?.id.toString(),
                                            empName: employeeProvider.nameController.text.trim(),
                                            empMobile: employeeProvider.mobileController.text.trim(),
                                            empAddress: employeeProvider.door.text.trim(),
                                            empBonus: employeeProvider.bonus.text.trim(),
                                            empEmail: employeeProvider.emailController.text.trim(),
                                            empPassword: employeeProvider.password.text.trim(),
                                            empJoinDate: employeeProvider.date.text.trim(),
                                            empRole: employeeProvider.roleId,
                                            empDep: employeeProvider.depId,
                                            empSalary: employeeProvider.salary.text.trim(),
                                            empWhatsapp: employeeProvider.WhatsappController.text.trim(),
                                            active: employeeProvider.selectedPublication ?? "1",
                                          );
                                        }
                                      }
                                    },
                                    isOptional: false,
                                    hintText: "Enter Bonus",
                                    controller: employeeProvider.bonus,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: constInputFormatters.numberInput,
                                  ),
                                  20.height,
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
                                      msg: "Please Enter Employee Name",
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
                                   if(employeeProvider.WhatsappController.text.trim().isNotEmpty&&employeeProvider.WhatsappController.text.length!=10){
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Enter 10 digit Whatsapp Number",
                                      color: Colors.red,
                                    );
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
                                      msg: "Please Select Role",
                                      color: Colors.red,
                                    );
                                    return;
                                  }
                                  if (employeeProvider.depId == null) {
                                    employeeProvider.addEmployeeButtonController.reset();
                                    utils.snackBar(
                                      context: context,
                                      msg: "Please Select Role",
                                      color: Colors.red,
                                    );
                                    return;
                                  }
                                 if(employeeProvider.emailController.text.trim().isEmpty){
                                   employeeProvider.employeeUpdate(
                                     context: context,
                                     empDep: employeeProvider.depId,
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
                                     empWhatsapp: employeeProvider.WhatsappController.text.trim(),
                                     active: employeeProvider
                                         .selectedPublication ?? "1",
                                   );
                                 }
                                 else{
                                   if(!employeeProvider.emailController.text.trim().isEmail){
                                     employeeProvider.addEmployeeButtonController.reset();
                                     utils.snackBar(
                                       context: context,
                                       msg: "Please Enter Valid Email",
                                       color: Colors.red,
                                     );
                                     return;
                                   }else{
                                     employeeProvider.employeeUpdate(
                                       context: context,
                                       id: widget.employeeData?.id.toString(),
                                       empName: employeeProvider.nameController.text.trim(),
                                       empMobile: employeeProvider.mobileController.text.trim(),
                                       empAddress: employeeProvider.door.text.trim(),
                                       empBonus: employeeProvider.bonus.text.trim(),
                                       empEmail: employeeProvider.emailController.text.trim(),
                                       empPassword: employeeProvider.password.text.trim(),
                                       empJoinDate: employeeProvider.date.text.trim(),
                                       empRole: employeeProvider.roleId,
                                       empDep: employeeProvider.depId,
                                       empSalary: employeeProvider.salary.text.trim(),
                                       empWhatsapp: employeeProvider.WhatsappController.text.trim(),
                                       active: employeeProvider.selectedPublication ?? "1",
                                     );
                                   }
                                 }
                                },
                                child: CustomText(
                                  text: "Update Employee",
                                  colors: Colors.white,
                                  isBold:true,
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
