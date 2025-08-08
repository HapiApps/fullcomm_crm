import 'dart:convert';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_date_box.dart';
import 'package:fullcomm_crm/components/custom_employee_dropdown.dart';
import 'package:fullcomm_crm/components/custom_employee_textfield.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import 'package:fullcomm_crm/controller/image_controller.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/assets_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../components/custom_appbar.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      controllers.groupController.selectIndex(0);
      controllers.employeeHeading.value = "Employee Information";
    });
  }

  @override
  Widget build(BuildContext context) {
    //
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
            utils.sideBarFunction(context),
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
                  color: Colors.grey.shade100,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        10.height,
                        utils.headingBox(
                            width:
                                1230 > MediaQuery.of(context).size.width - 200
                                    ? 1150
                                    : MediaQuery.of(context).size.width - 200,
                            text: "Add Employee"),
                        10.height,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              20.width,
                              GroupButton(
                                isRadio: true,
                                controller: controllers.groupController,
                                options: GroupButtonOptions(
                                    //borderRadius: BorderRadius.circular(20),
                                    spacing: 40,
                                    elevation: 0,
                                    selectedColor: colorsConst.primary,
                                    unselectedBorderColor: Colors.transparent,
                                    unselectedColor: Colors.transparent,
                                    unselectedTextStyle:
                                        TextStyle(color: colorsConst.primary)),
                                onSelected: (name, index, isSelected) async {
                                  controllers.employeeHeading.value = name;
                                },
                                buttons: const [
                                  "Employee Information",
                                  "Address",
                                  "Job Details",
                                  "Salary and Compensation",
                                  "Education",
                                  "Personal Information",
                                  "Documents"
                                ],
                              ),
                              20.width,
                            ],
                          ),
                        ),
                        10.height,
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Obx(() => controllers.employeeHeading.value ==
                                    "Employee Information"
                                ? SizedBox(
                                    width: 1230 >
                                            MediaQuery.of(context).size.width -
                                                250
                                        ? 750
                                        : MediaQuery.of(context).size.width -
                                            500,
                                    height: MediaQuery.of(context).size.height,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          10.height,
                                          InkWell(
                                            onTap: () {
                                              utils.chooseFile(
                                                  mediaDataV: imageController
                                                      .empMediaData,
                                                  fileName: imageController
                                                      .empFileName,
                                                  pathName:
                                                      imageController.photo1);
                                              // html.File? imageFile = (await ImagePickerWeb.getMultiImagesAsFile())?[0];
                                              // print("imageFile ${imageFile!.relativePath}");
                                              // var mediaData = await ImagePickerWeb.getImageInfo;
                                              // print("mediaData ${mediaData!.data}");
                                              // print("mediaData ${mediaData.fileName}");
                                              // String? mimeType = mime(Path.basename(mediaData.fileName??""));
                                              // print("mimeType $mimeType");
                                              // html.File mediaFile =
                                              // html.File(mediaData.data!.toList(), mediaData.fileName.toString(), {'type': mimeType});
                                              // print("mediaFile ${mediaFile}");
                                              //imageController.photo1.value = base64.encode(mediaData.data!.toList());
                                              //insertStallEmployee(mediaData.data!.toList(),mediaData.fileName.toString(),mimeType.toString());
                                              //pathName?.value=fileName!.path;
                                            },
                                            child: imageController
                                                    .photo1.value.isEmpty
                                                ? Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: Colors
                                                            .grey.shade300),
                                                    child: Center(
                                                      child: SvgPicture.asset(
                                                        assets.choosePerson,
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                    ),
                                                  )
                                                : Image.memory(
                                                    base64Decode(imageController
                                                        .photo1.value),
                                                    fit: BoxFit.cover,
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                          ),
                                          10.height,
                                          CustomText(
                                            text: "Choose Image",
                                            size: 15,
                                            isBold: true,
                                            colors: colorsConst.primary,
                                          ),
                                          20.height,
                                          CustomEmployeeTextField(
                                            hintText: "Full Name",
                                            text: "Full Name",

                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                850,
                                            keyboardType: TextInputType.text,
                                            controller:
                                                controllers.emNameController,
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters:
                                                constInputFormatters.textInput,
                                            onChanged: (value) async {
                                              controllers.empName.value =
                                                  value.toString();

                                              SharedPreferences sharedPref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              sharedPref.setString("eventName",
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
                                          CustomEmployeeTextField(
                                            hintText: "Employee ID",
                                            text: "Employee ID",
                                            controller:
                                                controllers.emIDController,
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters:
                                                constInputFormatters
                                                    .addressInput,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                850,
                                            keyboardType: TextInputType.text,

                                            //inputFormatters: constInputFormatters.textInput,
                                            onChanged: (value) async {
                                              controllers.empId.value =
                                                  value.toString();

                                              SharedPreferences sharedPref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              sharedPref.setString("eventName",
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
                                          CustomEmployeeTextField(
                                            hintText: "Email",
                                            text: "Email",
                                            controller:
                                                controllers.emEmailController,
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters:
                                                constInputFormatters.emailInput,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                850,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            onChanged: (value) async {
                                              controllers.empEmail.value =
                                                  value.toString();

                                              SharedPreferences sharedPref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              sharedPref.setString("eventName",
                                                  value.toString().trim());
                                            },
                                          ),
                                          CustomEmployeeTextField(
                                            hintText: "Phone Number",
                                            text: "Phone Number",
                                            controller:
                                                controllers.emPhoneController,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                850,
                                            keyboardType: TextInputType.text,
                                            inputFormatters:
                                                constInputFormatters
                                                    .mobileNumberInput,
                                            textInputAction:
                                                TextInputAction.next,
                                            onChanged: (value) async {
                                              controllers.empPhone.value =
                                                  value.toString();

                                              SharedPreferences sharedPref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              sharedPref.setString("eventName",
                                                  value.toString().trim());
                                            },
                                          ),
                                          Obx(
                                            () => CustomDateBox(
                                              text: "Date of birth",
                                              value: controllers.empDOB.value,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  850,
                                              onTap: () {
                                                utils.datePicker(
                                                  context: context,
                                                  textEditingController:
                                                      controllers
                                                          .emDOBController,
                                                );
                                              },
                                            ),
                                          ),
                                          controllers.empDOB.value.isNotEmpty
                                              ? SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      850,
                                                  child: CustomText(
                                                    textAlign: TextAlign.start,
                                                    text: utils.isAdult() ==
                                                            false
                                                        ? "Age should be above 18 years"
                                                        : "",
                                                    colors: Colors.red,
                                                    size: 15,
                                                  ),
                                                )
                                              : 0.height,
                                          // CustomEmployeeTextField(
                                          //   hintText:"Nationality",
                                          //   text:"Nationality",
                                          //   controller: controllers.leadNameCrt,
                                          //   width:MediaQuery.of(context).size.width-850,
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
                                          20.height,
                                          SizedBox(
                                            width: 100,
                                            height: 40,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .zero),
                                                  backgroundColor:
                                                      colorsConst.primary,
                                                ),
                                                onPressed: () {
                                                  if (imageController
                                                      .photo1.value.isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add employee photo",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .emDOBController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add employee date of birth",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .emNameController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add employee name",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .emIDController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add employee ID",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .emEmailController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add employee email",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else if (controllers
                                                      .emPhoneController
                                                      .text
                                                      .isEmpty) {
                                                    utils.snackBar(
                                                        msg:
                                                            "Please add employee phone number",
                                                        color:
                                                            colorsConst.primary,
                                                        context: Get.context!);
                                                  } else {
                                                    if (controllers
                                                        .emDOBController
                                                        .text
                                                        .isNotEmpty) {
                                                      if (utils.isAdult() ==
                                                          false) {
                                                        utils.snackBar(
                                                            msg:
                                                                "Age should be above 18 years",
                                                            color: colorsConst
                                                                .primary,
                                                            context:
                                                                Get.context!);
                                                      } else {
                                                        controllers
                                                            .groupController
                                                            .selectIndex(1);
                                                        controllers
                                                            .employeeHeading
                                                            .value = "Address";
                                                      }
                                                    } else {
                                                      utils.snackBar(
                                                          msg:
                                                              "Please add date of birth",
                                                          color: colorsConst
                                                              .primary,
                                                          context:
                                                              Get.context!);
                                                    }
                                                  }
                                                },
                                                child: const CustomText(
                                                  text: "Next",
                                                  colors: Colors.white,
                                                  size: 16,
                                                  isBold: true,
                                                )),
                                          ),
                                          50.height
                                        ],
                                      ),
                                    ),
                                  )
                                : controllers.employeeHeading.value == "Address"
                                    ? SizedBox(
                                        width: 1230 >
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    250
                                            ? 750
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                500,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              40.height,
                                              CustomEmployeeTextField(
                                                hintText: "Door No",
                                                text: "Door No",
                                                controller: controllers
                                                    .emDoorNoController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    850,
                                                keyboardType:
                                                    TextInputType.text,

                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  controllers.empDoorNo.value =
                                                      value.toString();

                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "eventName",
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
                                              CustomEmployeeTextField(
                                                hintText: "Street",
                                                text: "Street",
                                                controller: controllers
                                                    .emStreetController,
                                                textInputAction:
                                                    TextInputAction.next,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    850,
                                                keyboardType:
                                                    TextInputType.text,

                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  controllers.empStreet.value =
                                                      value.toString();

                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "eventName",
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
                                              CustomEmployeeTextField(
                                                hintText: "Area",
                                                text: "Area",
                                                controller: controllers
                                                    .emAreaController,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    850,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  controllers.empArea.value =
                                                      value.toString();

                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "eventName",
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
                                              CustomEmployeeTextField(
                                                hintText: "City",
                                                text: "City",
                                                controller: controllers
                                                    .emCityController,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    850,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  controllers.empCity.value =
                                                      value.toString();
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "eventName",
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
                                              CustomEmployeeDropDown(
                                                saveValue: controllers.emState,
                                                valueList:
                                                    controllers.stateList,
                                                text: "State",
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    850,

                                                //inputFormatters: constInputFormatters.textInput,
                                                onChanged: (value) async {
                                                  setState(() {
                                                    controllers.emState = value;
                                                  });

                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "eventName",
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
                                              CustomEmployeeTextField(
                                                hintText: "Country",
                                                text: "Country",
                                                controller: controllers
                                                    .emCountryController,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    850,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  controllers.empCountry.value =
                                                      value.toString();

                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "eventName",
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
                                              CustomEmployeeTextField(
                                                hintText: "Pin Code",
                                                text: "Pin Code",
                                                controller: controllers
                                                    .emPinCodeController,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    850,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .pinCodeInput,
                                                onChanged: (value) async {
                                                  controllers.empPinCode.value =
                                                      value.toString();

                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "eventName",
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
                                              SizedBox(
                                                width: 100,
                                                height: 40,
                                                child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero),
                                                      backgroundColor:
                                                          colorsConst.primary,
                                                    ),
                                                    onPressed: () {
                                                      if (controllers
                                                          .emCityController
                                                          .text
                                                          .isEmpty) {
                                                        utils.snackBar(
                                                            msg:
                                                                "Please add employee city",
                                                            color: colorsConst
                                                                .primary,
                                                            context:
                                                                Get.context!);
                                                      } else if (controllers
                                                          .emPinCodeController
                                                          .text
                                                          .isEmpty) {
                                                        utils.snackBar(
                                                            msg:
                                                                "Please add employee pin code",
                                                            color: colorsConst
                                                                .primary,
                                                            context:
                                                                Get.context!);
                                                      } else {
                                                        controllers
                                                            .groupController
                                                            .selectIndex(2);
                                                        controllers
                                                                .employeeHeading
                                                                .value =
                                                            "Job Details";
                                                      }
                                                    },
                                                    child: const CustomText(
                                                      text: "Next",
                                                      colors: Colors.white,
                                                      size: 16,
                                                      isBold: true,
                                                    )),
                                              ),
                                              50.height
                                            ],
                                          ),
                                        ),
                                      )
                                    : controllers.employeeHeading.value ==
                                            "Job Details"
                                        ? SizedBox(
                                            width: 1230 >
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        250
                                                ? 750
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    500,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  50.height,
                                                  CustomEmployeeDropDown(
                                                    saveValue:
                                                        controllers.department,
                                                    valueList: controllers
                                                        .departmentList,
                                                    text: "Department",
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            850,

                                                    //inputFormatters: constInputFormatters.textInput,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        controllers.position =
                                                            null;
                                                        controllers.department =
                                                            value;
                                                      });
                                                      SharedPreferences
                                                          sharedPref =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      sharedPref.setString(
                                                          "eventName",
                                                          value
                                                              .toString()
                                                              .trim());
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
                                                  CustomEmployeeDropDown(
                                                    saveValue:
                                                        controllers.position,
                                                    valueList: controllers
                                                                .department ==
                                                            "Design"
                                                        ? controllers
                                                            .designDepList
                                                        : controllers
                                                                    .department ==
                                                                "Production"
                                                            ? controllers
                                                                .productionDepList
                                                            : controllers
                                                                        .department ==
                                                                    "Marketing"
                                                                ? controllers
                                                                    .marketingDepList
                                                                : controllers
                                                                            .department ==
                                                                        "Sales"
                                                                    ? controllers
                                                                        .salesDepList
                                                                    : controllers.department ==
                                                                            "Finance"
                                                                        ? controllers
                                                                            .financeDepList
                                                                        : controllers.department ==
                                                                                "Human Resources"
                                                                            ? controllers.hrDepList
                                                                            : controllers.department == "Customer Service"
                                                                                ? controllers.customerServiceDepList
                                                                                : controllers.chainManagementDepList,
                                                    text: "Position/Title",
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            850,

                                                    //inputFormatters: constInputFormatters.textInput,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        controllers.position =
                                                            value;
                                                      });
                                                      SharedPreferences
                                                          sharedPref =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      sharedPref.setString(
                                                          "eventName",
                                                          value
                                                              .toString()
                                                              .trim());
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
                                                  CustomEmployeeDropDown(
                                                    saveValue: controllers
                                                        .employeeType,
                                                    valueList: controllers
                                                        .employmentList,
                                                    text:
                                                        "Employment Type(Optional)",
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            850,

                                                    //inputFormatters: constInputFormatters.textInput,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        controllers
                                                                .employeeType =
                                                            value;
                                                      });
                                                      SharedPreferences
                                                          sharedPref =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      sharedPref.setString(
                                                          "eventName",
                                                          value
                                                              .toString()
                                                              .trim());
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
                                                  Obx(
                                                    () => CustomDateBox(
                                                      text: "Date of joining",
                                                      value: controllers
                                                          .empDOJ.value,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              850,
                                                      onTap: () {
                                                        print("Click");
                                                        utils.datePicker(
                                                          context: context,
                                                          textEditingController:
                                                              controllers
                                                                  .emDOJController,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  20.height,
                                                  CustomEmployeeTextField(
                                                    hintText:
                                                        "Manager Name(Optional)",
                                                    text:
                                                        "Manager Name(Optional)",
                                                    controller: controllers
                                                        .emManagerController,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            850,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    inputFormatters:
                                                        constInputFormatters
                                                            .textInput,
                                                    onChanged: (value) async {
                                                      controllers.empManagerName
                                                              .value =
                                                          value.toString();

                                                      SharedPreferences
                                                          sharedPref =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      sharedPref.setString(
                                                          "eventName",
                                                          value
                                                              .toString()
                                                              .trim());
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
                                                  SizedBox(
                                                    width: 100,
                                                    height: 40,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero),
                                                          backgroundColor:
                                                              colorsConst
                                                                  .primary,
                                                        ),
                                                        onPressed: () {
                                                          if (controllers
                                                                  .department ==
                                                              null) {
                                                            utils.snackBar(
                                                                msg:
                                                                    "Please add employee department",
                                                                color:
                                                                    colorsConst
                                                                        .primary,
                                                                context: Get
                                                                    .context!);
                                                          } else if (controllers
                                                                  .position ==
                                                              null) {
                                                            utils.snackBar(
                                                                msg:
                                                                    "Please add employee position",
                                                                color:
                                                                    colorsConst
                                                                        .primary,
                                                                context: Get
                                                                    .context!);
                                                          } else if (controllers
                                                              .emDOJController
                                                              .text
                                                              .isEmpty) {
                                                            utils.snackBar(
                                                                msg:
                                                                    "Please add employee date of joining",
                                                                color:
                                                                    colorsConst
                                                                        .primary,
                                                                context: Get
                                                                    .context!);
                                                          } else {
                                                            controllers
                                                                .groupController
                                                                .selectIndex(3);
                                                            controllers
                                                                    .employeeHeading
                                                                    .value =
                                                                "Salary and Compensation";
                                                          }
                                                        },
                                                        child: const CustomText(
                                                          text: "Next",
                                                          colors: Colors.white,
                                                          size: 16,
                                                          isBold: true,
                                                        )),
                                                  ),
                                                  50.height
                                                ],
                                              ),
                                            ),
                                          )
                                        : controllers.employeeHeading.value ==
                                                "Salary and Compensation"
                                            ? SizedBox(
                                                width: 1230 >
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            250
                                                    ? 750
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        500,
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      60.height,
                                                      CustomEmployeeTextField(
                                                        hintText: "Salary",
                                                        text: "Salary",
                                                        controller: controllers
                                                            .emSalaryController,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            850,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        inputFormatters:
                                                            constInputFormatters
                                                                .numberInput,
                                                        onChanged:
                                                            (value) async {
                                                          controllers.empSalary
                                                                  .value =
                                                              value.toString();

                                                          SharedPreferences
                                                              sharedPref =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          sharedPref.setString(
                                                              "eventName",
                                                              value
                                                                  .toString()
                                                                  .trim());
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
                                                      CustomEmployeeTextField(
                                                        hintText:
                                                            "Bonus(Optional)",
                                                        text: "Bonus(Optional)",
                                                        controller: controllers
                                                            .emBonusController,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            850,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        inputFormatters:
                                                            constInputFormatters
                                                                .numberInput,
                                                        onChanged:
                                                            (value) async {
                                                          controllers.empBonus
                                                                  .value =
                                                              value.toString();

                                                          SharedPreferences
                                                              sharedPref =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          sharedPref.setString(
                                                              "eventName",
                                                              value
                                                                  .toString()
                                                                  .trim());
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
                                                      CustomEmployeeDropDown(
                                                        saveValue: controllers
                                                            .benefits,
                                                        valueList: controllers
                                                            .benefitsList,
                                                        text:
                                                            "Benefits(Optional)",
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            850,

                                                        //inputFormatters: constInputFormatters.textInput,
                                                        onChanged:
                                                            (value) async {
                                                          setState(() {
                                                            controllers
                                                                    .benefits =
                                                                value;
                                                          });
                                                          SharedPreferences
                                                              sharedPref =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          sharedPref.setString(
                                                              "eventName",
                                                              value
                                                                  .toString()
                                                                  .trim());
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
                                                      SizedBox(
                                                        width: 100,
                                                        height: 40,
                                                        child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .zero),
                                                              backgroundColor:
                                                                  colorsConst
                                                                      .primary,
                                                            ),
                                                            onPressed: () {
                                                              if (controllers
                                                                  .emSalaryController
                                                                  .text
                                                                  .isEmpty) {
                                                                utils.snackBar(
                                                                    msg:
                                                                        "Please add employee salary",
                                                                    color: colorsConst
                                                                        .primary,
                                                                    context: Get
                                                                        .context!);
                                                              } else {
                                                                controllers
                                                                    .groupController
                                                                    .selectIndex(
                                                                        4);
                                                                controllers
                                                                        .employeeHeading
                                                                        .value =
                                                                    "Education";
                                                              }
                                                            },
                                                            child:
                                                                const CustomText(
                                                              text: "Next",
                                                              colors:
                                                                  Colors.white,
                                                              size: 16,
                                                              isBold: true,
                                                            )),
                                                      ),
                                                      50.height
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : controllers.employeeHeading
                                                        .value ==
                                                    "Education"
                                                ? SizedBox(
                                                    width: 1230 >
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                250
                                                        ? 750
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            500,
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          60.height,
                                                          CustomEmployeeTextField(
                                                            hintText:
                                                                "Highest Degree",
                                                            text:
                                                                "Highest Degree",
                                                            controller: controllers
                                                                .emDegreeController,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                850,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            inputFormatters:
                                                                constInputFormatters
                                                                    .textInput,
                                                            onChanged:
                                                                (value) async {
                                                              controllers
                                                                      .empDegree
                                                                      .value =
                                                                  value
                                                                      .toString();

                                                              SharedPreferences
                                                                  sharedPref =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              sharedPref.setString(
                                                                  "eventName",
                                                                  value
                                                                      .toString()
                                                                      .trim());
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
                                                          CustomEmployeeTextField(
                                                            hintText:
                                                                "Institution(Optional)",
                                                            text:
                                                                "Institution(Optional)",
                                                            controller: controllers
                                                                .emInstitutionController,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                850,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            inputFormatters:
                                                                constInputFormatters
                                                                    .textInput,
                                                            onChanged:
                                                                (value) async {
                                                              controllers
                                                                      .empInstitution
                                                                      .value =
                                                                  value
                                                                      .toString();

                                                              SharedPreferences
                                                                  sharedPref =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              sharedPref.setString(
                                                                  "eventName",
                                                                  value
                                                                      .toString()
                                                                      .trim());
                                                            },
                                                          ),
                                                          CustomEmployeeTextField(
                                                            hintText:
                                                                "Graduation Year(Optional)",
                                                            text:
                                                                "Graduation Year(Optional)",
                                                            controller: controllers
                                                                .emGraduationYearController,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                850,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            inputFormatters:
                                                                constInputFormatters
                                                                    .textInput,
                                                            onChanged:
                                                                (value) async {
                                                              controllers
                                                                      .empGraYear
                                                                      .value =
                                                                  value
                                                                      .toString();

                                                              SharedPreferences
                                                                  sharedPref =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              sharedPref.setString(
                                                                  "eventName",
                                                                  value
                                                                      .toString()
                                                                      .trim());
                                                            },
                                                          ),
                                                          20.height,
                                                          SizedBox(
                                                            width: 100,
                                                            height: 40,
                                                            child:
                                                                ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      shape: const RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.zero),
                                                                      backgroundColor:
                                                                          colorsConst
                                                                              .primary,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      if (controllers
                                                                          .emDegreeController
                                                                          .text
                                                                          .isEmpty) {
                                                                        utils.snackBar(
                                                                            msg:
                                                                                "Please add employee degree",
                                                                            color:
                                                                                colorsConst.primary,
                                                                            context: Get.context!);
                                                                      } else {
                                                                        controllers
                                                                            .groupController
                                                                            .selectIndex(5);
                                                                        controllers
                                                                            .employeeHeading
                                                                            .value = "Personal Information";
                                                                      }
                                                                    },
                                                                    child:
                                                                        const CustomText(
                                                                      text:
                                                                          "Next",
                                                                      colors: Colors
                                                                          .white,
                                                                      size: 16,
                                                                      isBold:
                                                                          true,
                                                                    )),
                                                          ),
                                                          50.height
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : controllers.employeeHeading
                                                            .value ==
                                                        "Personal Information"
                                                    ? SizedBox(
                                                        width: 1230 >
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    250
                                                            ? 750
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                500,
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              70.height,
                                                              Row(
                                                                children: [
                                                                  200.width,
                                                                  const CustomText(
                                                                    text:
                                                                        "Gender",
                                                                    colors: Colors
                                                                        .grey,
                                                                    size: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  190.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Male',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedGender,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedGender =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Male",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                  10.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Female',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedGender,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedGender =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Female",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                  10.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Other',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedGender,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedGender =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Other",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                              30.height,
                                                              Row(
                                                                children: [
                                                                  200.width,
                                                                  const CustomText(
                                                                    text:
                                                                        "Marital Status",
                                                                    colors: Colors
                                                                        .grey,
                                                                    size: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  190.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Single',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedMarital,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedMarital =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Single",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                  10.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Married',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedMarital,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedMarital =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Married",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                  10.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Divorced',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedMarital,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedMarital =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Divorced",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                              30.height,
                                                              Row(
                                                                children: [
                                                                  200.width,
                                                                  const CustomText(
                                                                    text:
                                                                        "RelationShip(Optional)",
                                                                    colors: Colors
                                                                        .grey,
                                                                    size: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  190.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Spouse',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedRelationShip,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedRelationShip =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Spouse",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                  10.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Father',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedRelationShip,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedRelationShip =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Father",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                  10.width,
                                                                  Radio<String>(
                                                                    value:
                                                                        'Mother',
                                                                    groupValue:
                                                                        controllers
                                                                            .selectedRelationShip,
                                                                    activeColor:
                                                                        colorsConst
                                                                            .primary,
                                                                    onChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        controllers.selectedRelationShip =
                                                                            value!;
                                                                      });
                                                                    },
                                                                  ),
                                                                  CustomText(
                                                                    text:
                                                                        "Mother",
                                                                    colors: colorsConst
                                                                        .primary,
                                                                    size: 14,
                                                                  ),
                                                                ],
                                                              ),
                                                              50.height,
                                                              SizedBox(
                                                                width: 100,
                                                                height: 40,
                                                                child:
                                                                    ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                                                          backgroundColor:
                                                                              colorsConst.primary,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          controllers
                                                                              .groupController
                                                                              .selectIndex(6);
                                                                          controllers
                                                                              .employeeHeading
                                                                              .value = "";
                                                                        },
                                                                        child:
                                                                            const CustomText(
                                                                          text:
                                                                              "Next",
                                                                          colors:
                                                                              Colors.white,
                                                                          size:
                                                                              16,
                                                                          isBold:
                                                                              true,
                                                                        )),
                                                              ),
                                                              50.height
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: 1230 >
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    250
                                                            ? 750
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                500,
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            children: [
                                                              50.height,
                                                              Row(
                                                                children: [
                                                                  180.width,
                                                                  CustomText(
                                                                    text:
                                                                        "Resume(Optional)",
                                                                    colors: Colors
                                                                        .grey
                                                                        .shade400,
                                                                    size: 14,
                                                                    isBold:
                                                                        true,
                                                                  ),
                                                                ],
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  utils.chooseFile(
                                                                      mediaDataV:
                                                                          imageController
                                                                              .resumeMediaData,
                                                                      fileName:
                                                                          imageController
                                                                              .resumeFileName,
                                                                      pathName:
                                                                          imageController
                                                                              .resume);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width -
                                                                      850,
                                                                  height: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      // 10.width,
                                                                      Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        //width: 100,
                                                                        height:
                                                                            50,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          //borderRadius: BorderRadius.circular(5)
                                                                        ),
                                                                        child:
                                                                            const CustomText(
                                                                          text:
                                                                              "  Choose File   ",
                                                                          colors:
                                                                              Colors.black,
                                                                          size:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                      10.width,
                                                                      Obx(
                                                                        () =>
                                                                            CustomText(
                                                                          text: imageController
                                                                              .resumeFileName
                                                                              .value,
                                                                          colors:
                                                                              Colors.black,
                                                                          size:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              30.height,
                                                              Row(
                                                                children: [
                                                                  180.width,
                                                                  CustomText(
                                                                    text:
                                                                        "ID Card(Optional)",
                                                                    colors: Colors
                                                                        .grey
                                                                        .shade400,
                                                                    size: 14,
                                                                    isBold:
                                                                        true,
                                                                  ),
                                                                ],
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    850,
                                                                height: 50,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    //  10.width,
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        utils.chooseFile(
                                                                            mediaDataV:
                                                                                imageController.idCardMediaData,
                                                                            fileName: imageController.idCardFileName,
                                                                            pathName: imageController.idCard);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        //width: 100,
                                                                        height:
                                                                            50,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          // borderRadius: BorderRadius.circular(5)
                                                                        ),
                                                                        child:
                                                                            const CustomText(
                                                                          text:
                                                                              "  Choose File   ",
                                                                          colors:
                                                                              Colors.black,
                                                                          size:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    10.width,
                                                                    Obx(() =>
                                                                        CustomText(
                                                                          text: imageController
                                                                              .idCardFileName
                                                                              .value,
                                                                          colors:
                                                                              Colors.black,
                                                                          size:
                                                                              13,
                                                                        ))
                                                                  ],
                                                                ),
                                                              ),
                                                              100.height,
                                                              CustomLoadingButton(
                                                                callback: () {
                                                                  apiService
                                                                      .insertEmployeeApi(
                                                                          context);
                                                                },
                                                                isLoading: true,
                                                                backgroundColor:
                                                                    colorsConst
                                                                        .primary,
                                                                radius: 0,
                                                                width: 100,
                                                                height: 40,
                                                                controller:
                                                                    controllers
                                                                        .employeeCtr,
                                                                text: "Save",
                                                              ),
                                                              50.height
                                                            ],
                                                          ),
                                                        ),
                                                      )),
                            Container(
                              width: 300,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.white,
                              child: SingleChildScrollView(
                                  child: Obx(
                                () => Column(
                                  children: [
                                    10.height,
                                    Obx(
                                      () => imageController.photo1.value.isEmpty
                                          ? Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(80),
                                                  color: Colors.grey.shade300),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  assets.choosePerson,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                              ),
                                            )
                                          : Image.memory(
                                              base64Decode(
                                                  imageController.photo1.value),
                                              fit: BoxFit.cover,
                                              width: 80,
                                              height: 80,
                                            ),
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        10.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              //textAlign: TextAlign.start,
                                              text: "Full Name",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              //textAlign: TextAlign.start,
                                              text: "Employee ID",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Email",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Phone Number",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Date of birth",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Address \n \n ",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                        30.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text: controllers
                                                      .empName.value.isEmpty
                                                  ? " "
                                                  : controllers.empName.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                      .empId.value.isEmpty
                                                  ? " "
                                                  : controllers.empId.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                      .empEmail.value.isEmpty
                                                  ? " "
                                                  : controllers.empEmail.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                      .empPhone.value.isEmpty
                                                  ? " "
                                                  : controllers.empPhone.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                      .empDOB.value.isEmpty
                                                  ? " "
                                                  : controllers.empDOB.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              textAlign: TextAlign.start,
                                              text:
                                                  "${controllers.empDoorNo.value.isEmpty ? " " : controllers.empDoorNo.value}${controllers.empDoorNo.value.isNotEmpty ? "," : ""}${controllers.empStreet.value.isEmpty ? " " : controllers.empStreet.value}${controllers.empStreet.value.isNotEmpty ? "," : ""}\n ${controllers.empArea.value.isEmpty ? " " : controllers.empArea.value}${controllers.empArea.value.isNotEmpty ? "," : ""}\n ${controllers.empCity.value.isEmpty ? " " : controllers.empCity.value}${controllers.empCity.value.isNotEmpty ? "," : ""} ${controllers.emState ?? ""}${controllers.emState == null ? "" : ","}\n ${controllers.empCountry.value.isEmpty ? " " : controllers.empCountry.value}${controllers.empCountry.value.isNotEmpty ? "-" : ""}${controllers.empPinCode.value.isEmpty ? " " : controllers.empPinCode.value}",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        10.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: "Job Details",
                                              colors: Colors.black,
                                              size: 13,
                                              isBold: true,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Department",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Position/Title",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Employment Type",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Date of Joining",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Manager Name",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                        20.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: "",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text:
                                                  controllers.department ?? " ",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers.position ?? " ",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers.employeeType ??
                                                  " ",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                      .empDOJ.value.isEmpty
                                                  ? " "
                                                  : controllers.empDOJ.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers.empManagerName
                                                      .value.isEmpty
                                                  ? " "
                                                  : controllers
                                                      .empManagerName.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        10.width,
                                        const CustomText(
                                          text: "Salary and Compensation",
                                          colors: Colors.black,
                                          size: 13,
                                          isBold: true,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        10.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            10.height,
                                            CustomText(
                                              text: "Salary",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Bonus",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Benefits",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                        80.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              text:
                                                  "\u{20B9}${controllers.empSalary}",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text:
                                                  "\u{20B9}${controllers.empBonus}",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers.benefits ?? "",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        10.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: "Education",
                                              colors: Colors.black,
                                              size: 13,
                                              isBold: true,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Highest Degree",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Institution",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Graduation Year",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                        30.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: "",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                      .empDegree.value.isEmpty
                                                  ? " "
                                                  : controllers.empDegree.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers.empInstitution
                                                      .value.isEmpty
                                                  ? " "
                                                  : controllers
                                                      .empInstitution.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                      .empGraYear.value.isEmpty
                                                  ? " "
                                                  : controllers
                                                      .empGraYear.value,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    20.height,
                                    Row(
                                      children: [
                                        10.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: "Personal Information",
                                              colors: Colors.black,
                                              size: 13,
                                              isBold: true,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Gender",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Marital Status",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: "Relationship",
                                              colors: Colors.grey.shade400,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CustomText(
                                              text: "",
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers.selectedGender,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers.selectedMarital,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                            10.height,
                                            CustomText(
                                              text: controllers
                                                  .selectedRelationShip,
                                              colors: Colors.black,
                                              size: 13,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    20.height,
                                  ],
                                ),
                              )),
                            )
                          ],
                        )
                        // Obx(() =>  imageController.photo1.value.isNotEmpty?CircleAvatar(
                        //   radius: 45,
                        //   backgroundImage:MemoryImage(base64Decode(imageController.photo1.value)),
                        // ):CustomText(text: "Image"),),
                        // ElevatedButton(onPressed: () async {
                        //   final ImagePicker _picker = ImagePicker();
                        //
                        //   // html.File? imageFile = (await ImagePickerWeb.getMultiImagesAsFile())?[0];
                        //   // print("imageFile ${imageFile!.relativePath}");
                        //   var mediaData = await ImagePickerWeb.getImageInfo;
                        //   print("mediaData ${mediaData!.data}");
                        //   print("mediaData ${mediaData.fileName}");
                        //   String? mimeType = mime(Path.basename(mediaData.fileName??""));
                        //   print("mimeType $mimeType");
                        //   html.File mediaFile =
                        //   html.File(mediaData.data!.toList(), mediaData.fileName.toString(), {'type': mimeType});
                        //   print("mediaFile ${mediaFile}");
                        //   imageController.photo1.value = base64.encode(mediaData.data!.toList());
                        //   insertStallEmployee(mediaData.data!.toList(),mediaData.fileName.toString(),mimeType.toString());
                        //   //pathName?.value=fileName!.path;
                        // }, child: Text("Click Me"))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
