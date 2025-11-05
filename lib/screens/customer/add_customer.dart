import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/default_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_appbar.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  @override
  Widget build(BuildContext context) {
    double textFieldSize = (MediaQuery.of(context).size.width - 350) / 3.5;
    return SelectionArea(
      child: Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CustomAppbar(
              text: "Zengraf",
            ),
          ),
          body: Stack(
            children: [
              SideBar(
                controllers: controllers,
                colorsConst: colorsConst,
                logo: logo,
                constValue: constValue,
                versionNum: versionNum,
              ),
              Positioned(
                left: 130,
                top: 0,
                bottom: 0,
                right: 0,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 1349 > MediaQuery.of(context).size.width - 130
                        ? 1349
                        : MediaQuery.of(context).size.width - 130,
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          20.height,
                          CustomText(
                            text: "Add Customer",
                            colors: colorsConst.primary,
                            size: 23,
                            isBold: true,
                          ),
                          30.height,
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width - 300,
                              height: 1200,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 400,
                                child: Column(
                                  children: [
                                    50.height,
                                    const Row(
                                      children: [
                                        CustomText(
                                          text: "Contact Information",
                                          colors: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    10.height,
                                    Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                    20.height,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CustomTextField(
                                              hintText: "Customer ID",
                                              text: "Customer ID",
                                              controller: controllers
                                                  .customerIdController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              // inputFormatters: constInputFormatters.textInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerId",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            Row(
                                              children: [
                                                Obx(
                                                  () => CustomCheckBox(
                                                      text:
                                                          "Main Calling Person",
                                                      onChanged: (value) {
                                                        controllers.isMainPerson
                                                                .value =
                                                            !controllers
                                                                .isMainPerson
                                                                .value;
                                                      },
                                                      saveValue: controllers
                                                          .isMainPerson.value),
                                                ),
                                                SizedBox(
                                                  width: textFieldSize - 150,
                                                )
                                              ],
                                            ),
                                            350.width,
                                            10.height,
                                            CustomTextField(
                                              hintText: "Mobile No",
                                              text: "Mobile No",
                                              controller: controllers
                                                  .customerMobileController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .mobileNumberInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerMobile",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            25.height,
                                            CustomTextField(
                                              hintText: "Company Name",
                                              text: "Company Name",
                                              controller: controllers
                                                  .customerCoNameController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .textInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerCompanyName",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            15.height,
                                            CustomTextField(
                                              hintText: "Full Name",
                                              text: "Full Name",
                                              controller: controllers
                                                  .customerNameController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .textInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerName",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            40.height,
                                            CustomTextField(
                                              hintText: "Email Id",
                                              text: "Email Id",
                                              controller: controllers
                                                  .customerEmailController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .emailInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerEmail",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            100.height
                                          ],
                                        ),
                                      ],
                                    ),
                                    30.height,
                                    const Row(
                                      children: [
                                        CustomText(
                                          text: "Unit Information",
                                          colors: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    10.height,
                                    Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                    20.height,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CustomTextField(
                                              hintText: "Unit Name(Optional)",
                                              text: "Unit Name(Optional)",
                                              controller: controllers
                                                  .customerUnitNameController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .textInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerUnitName",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            CustomTextField(
                                              hintText: "Area",
                                              text: "Area",
                                              controller: controllers.customerAreaController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .addressInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerArea",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            CustomDropDown(
                                              saveValue: controllers.cusState,
                                              valueList: controllers.stateList,
                                              text: "State/Province",
                                              width: textFieldSize,

                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                setState(() {
                                                  controllers.cusState = value;
                                                });
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerState",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            CustomTextField(
                                              hintText: "ZIP/Postal Code",
                                              text: "ZIP/Postal Code",
                                              controller: controllers
                                                  .customerPinCodeController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .pinCodeInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerPinCode",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CustomTextField(
                                              hintText: "Street",
                                              text: "Street",
                                              controller: controllers
                                                  .customerStreetController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .addressInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerStreet",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            CustomTextField(
                                              hintText: "Country",
                                              text: "Country",
                                              controller: controllers
                                                  .customerCountryController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .addressInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerCountry",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            CustomTextField(
                                              hintText: "City",
                                              text: "City",
                                              controller: controllers
                                                  .customerCityController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .addressInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerCity",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            CustomTextField(
                                              hintText:
                                                  "Location Link(Optional)",
                                              text: "Location Link(Optional)",
                                              controller: controllers
                                                  .customerLocationLinkController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,

                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerLocationLink",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    const Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          text: "Billing Address",
                                          colors: Colors.black,
                                          size: 20,
                                        ),
                                        // GestureDetector(
                                        //   onTap:(){
                                        //
                                        //   },
                                        //   child: Row(
                                        //     children:[
                                        //       Icon(Icons.add,
                                        //         color: colorsConst.primary,
                                        //         size: 15,
                                        //       ),
                                        //       CustomText(
                                        //         text: "Add more info",
                                        //         colors: colorsConst.primary,
                                        //         size: 15,
                                        //       ),
                                        //
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    10.height,
                                    Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                    20.height,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            10.height,
                                            CustomTextField(
                                              hintText:
                                                  "No Of Unit Name(Optional)",
                                              text: "No Of Unit Name(Optional)",
                                              controller: controllers
                                                  .customerNoUnitController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,

                                              inputFormatters:
                                                  constInputFormatters
                                                      .textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "noOfUnitName",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            CustomTextField(
                                              hintText:
                                                  "Field Officer(Optional)",
                                              text: "Field Officer(Optional)",
                                              controller: controllers
                                                  .customerFieldOfficerController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "noOfUnitName",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            110.height,
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CustomTextField(
                                              hintText:
                                                  "No Of Employees(Optional)",
                                              text: "No Of Employees(Optional)",
                                              controller:
                                                  controllers.noOfEmpController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              inputFormatters:
                                                  constInputFormatters
                                                      .textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "noOfEmployees",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            20.height,
                                            // CustomTextField(
                                            //   hintText:"Lead Owner",
                                            //   text:"Lead Owner",
                                            //   controller: controllers.leadMobileCrt,
                                            //   width:textFieldSize,
                                            //   keyboardType: TextInputType.text,
                                            //
                                            //   //inputFormatters: constInputFormatters.textInput,
                                            //   onChanged:(value) async {
                                            //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            //     sharedPref.setString("eventName", value.toString().trim());
                                            //   },
                                            //   // validator:(value){
                                            //   //   if(value.toString().isEmpty){
                                            //   //     return "This field is required";
                                            //   //   }else if(value.toString().trim().length!=10){
                                            //   //     return "Check Your Phone Number";
                                            //   //   }else{
                                            //   //     return null;
                                            //   //   }
                                            //   // }
                                            //
                                            // ),
                                            CustomTextField(
                                              hintText: "Description(Optional)",
                                              text: "Description(Optional)",
                                              controller: controllers
                                                  .customerDescriptionController,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,

                                              inputFormatters:
                                                  constInputFormatters
                                                      .textInput,
                                              onChanged: (value) async {
                                                SharedPreferences sharedPref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                sharedPref.setString(
                                                    "customerDescription",
                                                    value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }
                                            ),
                                            50.height,
                                            CustomLoadingButton(
                                                callback: () {
                                                  if (controllers
                                                      .customerIdController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add customer id",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                          .customerMobileController
                                                          .text
                                                          .length !=
                                                      10) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add mobile number",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .customerCoNameController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add company name",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .customerNameController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg: "Please add name",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .customerAreaController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg: "Please add area",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .customerCityController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg: "Please add city",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else {
                                                    if (controllers
                                                        .customerEmailController
                                                        .text
                                                        .isEmail) {
                                                      //apiService.insertCustomerAPI(context);
                                                    } else {
                                                      utils.snackBar(
                                                          msg:
                                                              "Please add Email",
                                                          color: colorsConst
                                                              .primary,
                                                          context:
                                                              Get.context!);
                                                    }
                                                  }
                                                },
                                                text: "Save Customer",
                                                height: 60,
                                                controller:
                                                    controllers.customerCtr,
                                                isLoading: true,
                                                backgroundColor:
                                                    colorsConst.primary,
                                                radius: 10,
                                                width: 180),
                                          ],
                                        ),
                                      ],
                                    ),
                                    20.height,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          20.height,
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
