import 'package:fullcomm_crm/common/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/constant/default_constant.dart';
import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_dropdown.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/key_constant.dart';
import '../../components/custom_date_box.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';

class AddLead extends StatefulWidget {
  const AddLead({super.key});

  @override
  State<AddLead> createState() => _AddLeadState();
}

class _AddLeadState extends State<AddLead> {
  Future<void> setDefaults() async {
    controllers.selectedCountry.value = "India";

    controllers.selectedState.value = "Tamil Nadu";
    //setState(() => controllers.selectedCity = controllers.coCityController.text);
  }

  Future<void> getStringValue() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      setState(() {
      final whatsApp = sharedPref.getString("leadWhatsApp") ?? "";
      final companyName = sharedPref.getString("leadCoName") ?? "";
      final companyPhone = sharedPref.getString("leadCoMobile") ?? "";
      final webSite = sharedPref.getString("leadWebsite") ?? "";
      final coEmail = sharedPref.getString("leadCoEmail") ?? "";
      final product = sharedPref.getString("leadProduct") ?? "";
      final ownerName = sharedPref.getString("leadOwnerName") ?? "";
      final industry = sharedPref.getString("industry");
      final source = sharedPref.getString("source");
      final status = sharedPref.getString("status");
      final rating = sharedPref.getString("rating");
      final service = sharedPref.getString("service");
      final doorNo = sharedPref.getString("leadDNo") ?? "";
      final street = sharedPref.getString("leadStreet") ?? "";
      final area = sharedPref.getString("leadArea") ?? "";
      final city = sharedPref.getString("leadCity") ?? "";
      final pinCode = sharedPref.getString("leadPinCode") ?? "";
      final budget = sharedPref.getString("budget") ?? "";
      final state = sharedPref.getString("leadState") ?? "Tamil Nadu";
      final country = sharedPref.getString("leadCountry") ?? "India";
      final twitter = sharedPref.getString("leadX") ?? "";
      final linkedin = sharedPref.getString("leadLinkedin") ?? "";
      final time = sharedPref.getString("leadTime") ?? "";
      final leadDescription = sharedPref.getString("leadDescription") ?? "";
      final leadPersonalCount = sharedPref.getInt("leadCount") ?? 1;

      controllers.leadPersonalItems.value = leadPersonalCount;
      controllers.isMainPersonList.value = [];
      controllers.isCoMobileNumberList.value = [];
      for (int i = 0; i < leadPersonalCount; i++) {
        controllers.isMainPersonList.add(false);
        controllers.isCoMobileNumberList.add(false);
        // final name = sharedPref.getString("leadName$i") ?? "";
        // final email = sharedPref.getString("leadEmail$i") ?? "";
        // final title = sharedPref.getString("leadTitle$i") ?? "";
        // controllers.leadNameCrt[i].text = name;
        // final mobile = sharedPref.getString("leadMobileNumber$i") ?? "";
        // controllers.leadMobileCrt[i].text = mobile.toString();
        // controllers.leadEmailCrt[i].text  = email.toString();
        // controllers.leadTitleCrt[i].text  = title.toString();
        // controllers.leadWhatsCrt[i].text  = whatsApp.toString();
      }
      // controllers.leadFieldName[0].text = "";
      // controllers.leadFieldValue[0].text = "";
      controllers.leadCoNameCrt.text = companyName.toString();
      controllers.leadCoMobileCrt.text = companyPhone.toString();
      controllers.leadWebsite.text = webSite.toString();
      controllers.leadCoEmailCrt.text = coEmail.toString();
      controllers.leadProduct.text = product.toString();
      controllers.leadOwnerNameCrt.text = ownerName.toString();
      controllers.industry = industry;
      controllers.source = source;
      controllers.status = status;
      controllers.rating = rating;
      controllers.service = service;
      controllers.doorNumberController.text = doorNo.toString();
      controllers.leadDescription.text = leadDescription.toString();
      controllers.leadTime.text = time.toString();
      controllers.budgetCrt.text = budget.toString();
      controllers.streetNameController.text = street.toString();
      controllers.areaController.text = area.toString();
      controllers.cityController.text = city.toString();
      controllers.pinCodeController.text = pinCode.toString();
      controllers.states = state.toString();
      controllers.countryController.text = country.toString();
      controllers.leadXCrt.text = twitter.toString();
      controllers.leadLinkedinCrt.text = linkedin.toString();
      controllers.leadNameCrt[0].text = "";
      controllers.leadMobileCrt[0].text = "";
      controllers.leadEmailCrt[0].text = "";
      controllers.leadTitleCrt[0].text = "";
      controllers.leadWhatsCrt[0].text = "";
    });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();
  }

  @override
  Widget build(BuildContext context) {
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 1.8;
    return Scaffold(
        // appBar: PreferredSize(
        //   preferredSize: const Size.fromHeight(60),
        //   child:  CustomAppbar(text: appName,),
        // ),
        body: Row(
            children: [
          utils.sideBarFunction(context),
          20.width,
          Container(
              width: MediaQuery.of(context).size.width - 180,
              alignment: Alignment.center,
              child: Column(children: [
                22.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text:
                          "New Leads - ${controllers.leadCategoryList[0]["value"]}",
                          colors: colorsConst.textColor,
                          size: 23,
                          isBold: true,
                        ),
                        5.height,
                        CustomText(
                          text: "Add your ${controllers.leadCategoryList[0]["value"]} Information",
                          colors: colorsConst.textColor,
                          size: 12,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomLoadingButton(
                            callback: () {
                              setState(() {
                                controllers.leadCoNameCrt.text = "";
                                controllers.leadCoMobileCrt.text = "";
                                controllers.leadWebsite.text = "";
                                controllers.leadCoEmailCrt.text = "";
                                controllers.leadProduct.text = "";
                                controllers.leadOwnerNameCrt.text = "";
                                controllers.industry = null;
                                controllers.source = null;
                                controllers.status = null;
                                controllers.rating = null;
                                controllers.service = null;
                                controllers.visitType = null;
                                controllers.stateController.text = "";
                                controllers.doorNumberController.text = "";
                                controllers.leadDescription.text = "";
                                controllers.leadTime.text = "";
                                controllers.budgetCrt.text = "";
                                controllers.streetNameController.text = "";
                                controllers.areaController.text = "";
                                controllers.cityController.text = "";
                                controllers.pinCodeController.text = "";
                                controllers.states = "";
                                controllers.countryController.text = "";
                                controllers.leadXCrt.text = "";
                                controllers.leadLinkedinCrt.text = "";
                                controllers.leadActions.clear();
                                controllers.leadDisPointsCrt.clear();
                                controllers.prodDescriptionController.clear();
                                controllers.exMonthBillingValCrt.clear();
                                controllers.arpuCrt.clear();
                                controllers.prospectGradingCrt.clear();
                                controllers.noOfHeadCountCrt.clear();
                                controllers.expectedConversionDateCrt.clear();
                                controllers.sourceCrt.clear();
                                controllers.prospectEnrollmentDateCrt.clear();
                                controllers.statusCrt.clear();
                                controllers.empDOB.value = "";
                                controllers.exDate.value = "";
                                controllers.prospectDate.value = "";
                                for (int i = 0; i < controllers.leadPersonalItems.value; i++) {
                                  controllers.leadNameCrt[i].text = "";
                                  controllers.leadMobileCrt[i].text = "";
                                  controllers.leadEmailCrt[i].text = "";
                                  controllers.leadTitleCrt[i].text = "";
                                  controllers.leadWhatsCrt[i].text = "";
                                }
                              });
                            },
                            text: "Clear",
                            height: 35,
                            isLoading: false,
                            isImage: false,
                            textSize: 15,
                            textColor: Colors.white,
                            backgroundColor: colorsConst.third,
                            radius: 3,
                            width: 160),
                        10.width,
                        CustomLoadingButton(
                          callback: () {
                            if (controllers.leadNameCrt[0].text.isEmpty) {
                              utils.snackBar(
                                  msg: "Please add name",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            } else if (controllers.leadMobileCrt[0].text.isEmpty) {
                              utils.snackBar(
                                  msg: "Please Add Phone No",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            } else if (controllers.leadMobileCrt[0].text.length != 10) {
                              utils.snackBar(
                                  msg: "Invalid Phone No",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            } else if (controllers.visitType == null ||
                                controllers.visitType.toString().isEmpty) {
                              utils.snackBar(
                                  msg: "Please Select Call Visit Type",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            } else if (controllers.leadWhatsCrt[0].text.isNotEmpty &&
                                controllers.leadWhatsCrt[0].text.length != 10) {
                              utils.snackBar(
                                  msg: "Invalid Whats No",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            }
                            else if (controllers.leadCoMobileCrt.text.isNotEmpty &&
                                controllers.leadCoMobileCrt.text.length != 10) {
                              utils.snackBar(
                                  msg: "Invalid Company Phone No",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            } else if (controllers.leadCoEmailCrt.text.isNotEmpty &&
                                !controllers.leadCoEmailCrt.text.isEmail) {
                              utils.snackBar(
                                  msg: "Please add valid Company Email",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            }
                            else {
                              if (controllers.leadEmailCrt[0].text.isNotEmpty) {
                                if (controllers.leadEmailCrt[0].text.isEmail) {
                                  if (controllers.pinCodeController.text.isEmpty) {
                                    apiService.insertSingleCustomer(context);
                                  } else {
                                    if (controllers.pinCodeController.text.length == 6) {
                                      apiService.insertSingleCustomer(context);
                                    } else {
                                      utils.snackBar(
                                          msg: "Please add 6 digits pin code",
                                          color: colorsConst.primary,
                                          context: context);
                                      controllers.leadCtr.reset();
                                    }
                                  }
                                } else {
                                  utils.snackBar(
                                      msg: "Please add valid email",
                                      color: colorsConst.primary,
                                      context: context);
                                  controllers.leadCtr.reset();
                                }
                              } else {
                                if (controllers.pinCodeController.text.isEmpty) {
                                  apiService.insertSingleCustomer(context);
                                } else {
                                  if (controllers.pinCodeController.text.length == 6) {
                                    apiService.insertSingleCustomer(context);
                                  } else {
                                    utils.snackBar(
                                        msg: "Please add 6 digits pin code",
                                        color: colorsConst.primary,
                                        context: context);
                                    controllers.leadCtr.reset();
                                  }
                                }
                              }
                            }
                          },
                          text: "Save Lead",
                          height: 45,
                          controller: controllers.leadCtr,
                          isLoading: true,
                          textColor: Colors.white,
                          backgroundColor: colorsConst.third,
                          radius: 10,
                          width: 160,
                        )
                      ],
                    ),
                  ],
                ),
                10.height,
                SizedBox(
                  height: MediaQuery.of(context).size.height - 80,
                  width: MediaQuery.of(context).size.width - 180,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                        children: [
                      30.height,
                      Obx(() => ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controllers.leadPersonalItems.value,
                            itemBuilder: (context, index) {
                              controllers.leadNameCrt.add(TextEditingController());
                              controllers.leadMobileCrt.add(TextEditingController());
                              controllers.leadTitleCrt.add(TextEditingController());
                              controllers.leadEmailCrt.add(TextEditingController());
                              controllers.leadWhatsCrt.add(TextEditingController());
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // index==0?CustomText(
                                      //   text: constValue.newLead,
                                      //   colors: Colors.black,
                                      //   size: 20,
                                      //
                                      // ):20.width,
                                      // index==0?ToggleSwitch(
                                      //   initialLabelIndex: 1,
                                      //   minHeight: 35,
                                      //
                                      //   minWidth:textFieldSize/3,
                                      //   borderWidth: 2,
                                      //   borderColor: const [Colors.blueAccent,Colors.orange,Colors.green],
                                      //   activeBgColors: const [[Colors.blueAccent],[Colors.orange],[Colors.green]],
                                      //   //activeBgColor:  [[Color(0xffFF0000)],[Color(0xff0000FF)],[Color(0xffFFA500)]],
                                      //   activeFgColor: Colors.grey.shade100,
                                      //   inactiveBgColor: Colors.white,
                                      //   inactiveFgColor: Colors.black,
                                      //   totalSwitches: 3,
                                      //   labels: controllers.ratingLis,
                                      //   onToggle:(index){
                                      //     controllers.selectedRating=controllers.ratingLis[index!];
                                      //   },
                                      // ):100.width,
                                      index == 0
                                          ? CustomText(
                                        text: "New Lead Information",
                                        colors: colorsConst.textColor,
                                        size: 20,
                                      )
                                          : 0.width,
                                      index == 0
                                          ? GroupButton(
                                        //isRadio: true,
                                        controller:
                                        controllers.groupController,
                                        options: GroupButtonOptions(
                                          //borderRadius: BorderRadius.circular(20),
                                          spacing: 1,
                                          elevation: 0,
                                          selectedTextStyle: customStyle.textStyle(
                                              colors: colorsConst.third,
                                              size: 16,
                                              isBold: true),
                                          selectedBorderColor: Colors.transparent,
                                          selectedColor: Colors.transparent,
                                          unselectedBorderColor: Colors.transparent,
                                          unselectedColor: Colors.transparent,
                                          unselectedTextStyle:
                                          customStyle.textStyle(
                                              colors: colorsConst.textColor,
                                              size: 16,
                                              isBold: true),
                                        ),
                                        onSelected: (name, index, isSelected) async {
                                          setState(() {
                                            controllers.leadCategory = name;
                                          });
                                        },
                                        buttons: controllers.leadCategoryGrList,
                                      )
                                          : 0.width,
                                      // index != controllers.leadPersonalItems.value - 1
                                      //     ? 0.width
                                      //     : InkWell(
                                      //   onTap: () async {
                                      //     controllers.leadPersonalItems++;
                                      //     controllers.isMainPersonList.add(false);
                                      //     controllers.isCoMobileNumberList.add(false);
                                      //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                      //     sharedPref.setInt("leadCount", controllers.leadPersonalItems.value);
                                      //   },
                                      //   child: Row(
                                      //     children: [
                                      //       Icon(
                                      //         Icons.add,
                                      //         color: colorsConst.third,
                                      //         size: 15,
                                      //       ),
                                      //       CustomText(
                                      //         text: "Add more personnel",
                                      //         colors: colorsConst.third,
                                      //         size: 15,
                                      //         isCopy: false,
                                      //       ),
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
                                  5.height,
                                  controllers.leadPersonalItems.value == 1 &&
                                      index == 0
                                      ? 0.width
                                      : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          controllers.isMainPersonList.remove(controllers.leadPersonalItems);
                                          controllers.isCoMobileNumberList.remove(controllers.leadPersonalItems);
                                          controllers.leadPersonalItems--;

                                          controllers.leadNameCrt.removeAt(index);
                                          controllers.leadMobileCrt.removeAt(index);
                                          controllers.leadTitleCrt.removeAt(index);
                                          controllers.leadEmailCrt.removeAt(index);

                                          SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                          sharedPref.setInt("leadCount", controllers.leadPersonalItems.value);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.remove,
                                              color: colorsConst.third,
                                              size: 15,
                                            ),
                                            CustomText(
                                              text: "Remove personnel",
                                              colors: colorsConst.third,
                                              size: 13,
                                              isCopy: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  15.height,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   mainAxisAlignment: MainAxisAlignment.start,
                                      //   children: [
                                      //     utils.textFieldNearText(
                                      //         'Name', true),
                                      //     30.height,
                                      //     utils.textFieldNearText(
                                      //         'Mobile Number', true),
                                      //     10.height,
                                      //     utils.textFieldNearText(
                                      //         'Whatsapp Number', true),
                                      //     10.height,
                                      //   ],
                                      // ),
                                      // 1.width,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          CustomTextField(
                                            hintText: "Name",
                                            text: "Name",
                                            isOptional: true,
                                            controller:
                                            controllers.leadNameCrt[index],
                                            width: textFieldSize,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                            TextInputAction.next,
                                            textCapitalization:
                                            TextCapitalization.words,
                                            inputFormatters:
                                            constInputFormatters.textInput,
                                            onChanged: (value) async {
                                              if (value.toString().isNotEmpty) {
                                                String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                                if (newValue != value) {
                                                  controllers.leadNameCrt[index].value = controllers.leadNameCrt[index].value.copyWith(
                                                    text: newValue,
                                                    selection: TextSelection.collapsed(offset: newValue.length),
                                                  );
                                                }
                                              }
                                              SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                              sharedPref.setString("leadName$index", value.toString().trim());
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
                                          // Row(
                                          //   children: [
                                          //     Obx(() => CustomCheckBox(
                                          //           text: "Main Calling Person",
                                          //           onChanged: (value){
                                          //             if (controllers.isMainPersonList[index] == true){
                                          //               controllers.isMainPersonList[index] = false;
                                          //             } else {
                                          //               controllers.isMainPersonList[index] = true;
                                          //             }
                                          //             //controllers.isMainPerson.value=!controllers.isMainPerson.value;
                                          //           },
                                          //           saveValue: controllers.isMainPersonList[index]),
                                          //     ),
                                          //     SizedBox(
                                          //       width: textFieldSize - 150,
                                          //     )
                                          //   ],
                                          // ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomText(
                                                text: "Phone No",
                                                colors: colorsConst.textColor,
                                                size: 13,
                                                textAlign: TextAlign.start,
                                              ),
                                              const CustomText(
                                                text: "*",
                                                colors: Colors.red,
                                                size: 25,
                                              ),
                                              SizedBox(
                                                width: textFieldSize-150,
                                              ),
                                              CustomText(
                                                text: "Whatsapp No",
                                                colors: colorsConst.textColor,
                                                size: 13,
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              20.width,
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    width: textFieldSize,
                                                    height: 50,
                                                    child: TextFormField(
                                                        style: TextStyle(
                                                            color: colorsConst.textColor,
                                                            fontSize: 14,
                                                            fontFamily: "Lato"),
                                                        cursorColor: colorsConst.primary,
                                                        onChanged: (value) async {
                                                          SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                                          sharedPref.setString("leadMobileNumber$index", value.toString().trim());
                                                        },
                                                        onTap: () {},
                                                        keyboardType: TextInputType.number,
                                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                                        textCapitalization: TextCapitalization.none,
                                                        controller: controllers.leadMobileCrt[index],
                                                        textInputAction: TextInputAction.next,
                                                        decoration: InputDecoration(
                                                          hoverColor: Colors.transparent,
                                                          focusColor: Colors.transparent,
                                                          hintText:"Phone No",
                                                          fillColor: Colors.white,
                                                          filled: true,
                                                          hintStyle: TextStyle(
                                                              color: Colors.grey.shade400,
                                                              fontSize: 13, fontFamily: "Lato"),
                                                          suffixIcon: Obx(() => Checkbox(
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                ),
                                                                side: MaterialStateBorderSide.resolveWith(
                                                                      (states) => BorderSide(
                                                                      width: 1.0,
                                                                      color: colorsConst.textColor),
                                                                ),
                                                                hoverColor: Colors.transparent,
                                                                activeColor: colorsConst.third,
                                                                value: controllers.isCoMobileNumberList[index],
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    controllers.isCoMobileNumberList[index] = value!;
                                                                    if (controllers.isCoMobileNumberList[index] == true) {
                                                                      controllers.leadWhatsCrt[index].text = controllers.leadMobileCrt[index].text;
                                                                    } else {
                                                                      print("in");
                                                                      controllers.leadWhatsCrt[index].text = "";
                                                                    }
                                                                  });
                                                                }),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                color: Colors.grey.shade200,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  5)),
                                                          focusedBorder:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .grey
                                                                    .shade200,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  5)),
                                                          focusedErrorBorder:
                                                          OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200),
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  5)),
                                                          // errorStyle: const TextStyle(height:0.05,fontSize: 12),
                                                          contentPadding: const EdgeInsets.symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 10.0),
                                                          errorBorder:
                                                          OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors.grey.shade200),
                                                              borderRadius: BorderRadius.circular(5)),
                                                        )),
                                                  ),
                                                  15.height,
                                                ],
                                              ),

                                            ],
                                          ),
                                          CustomTextField(
                                            hintText: "Whatsapp No",
                                            text: "Whatsapp",
                                            controller:
                                            controllers.leadWhatsCrt[index],
                                            width: textFieldSize,
                                            isOptional: false,
                                            keyboardType: TextInputType.number,
                                            textInputAction: TextInputAction.next,
                                            inputFormatters: constInputFormatters.mobileNumberInput,
                                            onChanged: (value) async {
                                              SharedPreferences sharedPref =
                                              await SharedPreferences.getInstance();
                                              sharedPref.setString("leadWhats$index",
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
                                          // CustomTextField(
                                          //   hintText:"Mobile No.",
                                          //   text:"Mobile No.",
                                          //   controller: controllers.leadMobileCrt,
                                          //   width:textFieldSize,
                                          //   keyboardType: TextInputType.number,
                                          //   textInputAction: TextInputAction.next,
                                          //   inputFormatters: constInputFormatters.mobileNumberInput,
                                          //   onChanged:(value) async {
                                          //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                          //     sharedPref.setString("leadMobileNumber", value.toString().trim());
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
                                          15.height,
                                        ],
                                      ),
                                      // SizedBox(
                                      //   width: 50,
                                      // ),
                                      // Column(
                                      //   crossAxisAlignment:
                                      //       CrossAxisAlignment.start,
                                      //   children: [
                                      //     utils.textFieldNearText(
                                      //         'Account Manager (Optional)',
                                      //         false),
                                      //     utils.textFieldNearText(
                                      //         'Email Id (Optional)', false),
                                      //     10.height,
                                      //     utils.textFieldNearText(
                                      //         'Date Of Connection', false),
                                      //     10.height,
                                      //   ],
                                      // ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          CustomTextField(
                                            hintText: "Account Manager (Optional)",
                                            text: "Account Manager (Optional)",
                                            controller: controllers.leadTitleCrt[index],
                                            width: textFieldSize,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                            TextInputAction.next,
                                            inputFormatters:
                                            constInputFormatters.textInput,
                                            isOptional: false,
                                            onChanged: (value) async {
                                              if (value.toString().isNotEmpty) {
                                                String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                                if (newValue != value) {
                                                  controllers.leadTitleCrt[index].value = controllers.leadTitleCrt[index].value.copyWith(
                                                    text: newValue,
                                                    selection: TextSelection.collapsed(offset: newValue.length),
                                                  );
                                                }
                                              }
                                              SharedPreferences sharedPref =
                                              await SharedPreferences
                                                  .getInstance();
                                              sharedPref.setString(
                                                  "leadTitle$index",
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
                                          CustomTextField(
                                            hintText: "Email Id (Optional)",
                                            text: "Email Id (Optional)",
                                            controller:
                                            controllers.leadEmailCrt[index],
                                            width: textFieldSize,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                            TextInputAction.next,
                                            inputFormatters:
                                            constInputFormatters.emailInput,
                                            isOptional: false,
                                            onChanged: (value) async {
                                              SharedPreferences sharedPref =
                                              await SharedPreferences
                                                  .getInstance();
                                              sharedPref.setString(
                                                  "leadEmail$index",
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
                                          Obx(() => CustomDateBox(
                                              text: "Date of Connection",
                                              value: controllers.empDOB.value,
                                              width: textFieldSize,
                                            isOptional: false,
                                              onTap: () {
                                                utils.datePicker(
                                                    context: context,
                                                    textEditingController: controllers.dateOfConCtr,
                                                    pathVal: controllers.empDOB
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  30.height,
                                ],
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: constValue.companyInfo,
                            colors: colorsConst.textColor,
                            size: 20,
                          ),
                        ],
                      ),//Todo:Company details
                      10.height,
                      Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     utils.textFieldNearText(
                          //         'Company Name', false),
                          //     utils.textFieldNearText(
                          //         'Company Phone No', false),
                          //     utils.textFieldNearText('Industry', false),
                          //     utils.textFieldNearText('Linkedin', false),
                          //   ],
                          // ),

                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomTextField(
                                  hintText: "Company Name",
                                  text: "Company Name",
                                  controller: controllers.leadCoNameCrt,
                                  width: textFieldSize,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  isOptional: false,
                                  inputFormatters: constInputFormatters.textInput,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.leadCoNameCrt.value = controllers.leadCoNameCrt.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                    sharedPref.setString("leadCoName", value.toString().trim());
                                  },
                                ),
                                CustomTextField(
                                  hintText: "Company Phone No.",
                                  text: "Company Phone No.",
                                  controller: controllers.leadCoMobileCrt,
                                  width: textFieldSize,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  isOptional: false,
                                  inputFormatters: constInputFormatters.mobileNumberInput,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.leadCoMobileCrt.value = controllers.leadCoMobileCrt.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                    sharedPref.setString(
                                        "leadCoMobile", value.toString().trim());
                                  },
                                  // }
                                ),
                                CustomDropDown(
                                  saveValue: controllers.industry,
                                  valueList: controllers.industryList,
                                  text: "Industry",
                                  width: textFieldSize,
                                  //inputFormatters: constInputFormatters.textInput,
                                  onChanged: (value) async {
                                    setState(() {
                                      controllers.industry = value;
                                    });
                                    SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                    sharedPref.setString(
                                        "industry", value.toString().trim());
                                  },
                                ),
                                CustomTextField(
                                  hintText: "Linkedin (Optional)",
                                  text: "Linkedin (Optional)",
                                  controller: controllers.leadLinkedinCrt,
                                  width: textFieldSize,
                                  keyboardType: TextInputType.text,
                                  isOptional: false,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters:
                                  constInputFormatters.socialInput,
                                  onChanged: (value) async {
                                    SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                    sharedPref.setString(
                                        "leadLinkedin", value.toString().trim());
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     utils.textFieldNearText(
                          //         'Company Email', false),
                          //     utils.textFieldNearText(
                          //         'Product/Services', false),
                          //     utils.textFieldNearText('Website', false),
                          //     utils.textFieldNearText('X', false),
                          //   ],
                          // ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomTextField(
                                hintText: "Company Email",
                                text: "Company Email",
                                controller: controllers.leadCoEmailCrt,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                inputFormatters:
                                constInputFormatters.emailInput,
                                onChanged: (value) async {
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadCoEmail", value.toString().trim());
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
                              CustomTextField(
                                hintText: "Product/Services (Optional)",
                                text: "Product/Services (Optional)",
                                controller: controllers.leadProduct,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.leadProduct.value = controllers.leadProduct.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadProduct", value.toString().trim());
                                },
                              ),
                              CustomTextField(
                                hintText: "Website (Optional)",
                                text: "Website (Optional)",
                                controller: controllers.leadWebsite,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                inputFormatters: constInputFormatters.textInput,
                                onChanged: (value) async {
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadWebsite", value.toString().trim());
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
                              CustomTextField(
                                hintText: "X (Optional)",
                                text: "X (Optional)",
                                controller: controllers.leadXCrt,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                inputFormatters:
                                constInputFormatters.socialInput,
                                onChanged: (value) async {
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadX", value.toString().trim());
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
                      ),//Todo:Company details
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "Observations (Optional)",
                            colors: colorsConst.textColor,
                            size: 20,
                          ),
                        ],
                      ),//Todo:Observation
                      10.height,
                      Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomTextField(
                                  hintText: "Actions to be taken",
                                  text: "Actions to be taken",
                                  controller: controllers.leadActions,
                                  width: textFieldSize,
                                  keyboardType: TextInputType.text,
                                  isOptional: false,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters:
                                  constInputFormatters.textInput,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.leadActions.value = controllers.leadActions.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                    sharedPref.setString("leadActions",
                                        value.toString().trim());
                                  },
                                ),
                                CustomTextField(
                                  hintText: "Source Of Prospect",
                                  text: "Source Of Prospect",
                                  controller: controllers.leadDisPointsCrt,
                                  width: textFieldSize,
                                  isOptional: false,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.leadDisPointsCrt.value = controllers.leadDisPointsCrt.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                    sharedPref.setString("leadDisPoints",
                                        value.toString().trim());
                                  },
                                  // }
                                ),
                                CustomTextField(
                                  hintText: "Product Discussed",
                                  text: "Product Discussed",
                                  controller: controllers.prodDescriptionController,
                                  width: textFieldSize,
                                  isOptional: false,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.prodDescriptionController.value = controllers.prodDescriptionController.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                    sharedPref.setString("leadProdDis",
                                        value.toString().trim());
                                  },
                                  // }
                                ),
                                CustomTextField(
                                  hintText: "Expected Monthly Billing Value",
                                  text: "Expected Monthly Billing Value",
                                  controller:
                                  controllers.exMonthBillingValCrt,
                                  width: textFieldSize,
                                  isOptional: false,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.exMonthBillingValCrt.value =  controllers.exMonthBillingValCrt.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                    sharedPref.setString("leadExMonthBillingVal", value.toString().trim());
                                  },
                                  // }
                                ),
                                CustomTextField(
                                  hintText: "ARPU Value",
                                  text: "ARPU Value",
                                  controller: controllers.arpuCrt,
                                  width: textFieldSize,
                                  isOptional: false,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.arpuCrt.value = controllers.arpuCrt.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                    sharedPref.setString(
                                        "leadARPU", value.toString().trim());
                                  },
                                  // }
                                ),
                                // CustomTextField(
                                //   hintText: "",
                                //   text: "Source Of Details",
                                //   controller: controllers.sourceCrt,
                                //   width: textFieldSize,
                                //   isOptional: false,
                                //   keyboardType: TextInputType.text,
                                //   textInputAction: TextInputAction.next,
                                //   onChanged: (value) async {
                                //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                //     sharedPref.setString("leadSource", value.toString().trim());
                                //   },
                                //   // }
                                // ),
                                CustomTextField(
                                  hintText: "Prospect Grading",
                                  text: "Prospect Grading",
                                  controller: controllers.prospectGradingCrt,
                                  width: textFieldSize,
                                  isOptional: false,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) async {
                                    if (value.toString().isNotEmpty) {
                                      String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                      if (newValue != value) {
                                        controllers.prospectGradingCrt.value = controllers.prospectGradingCrt.value.copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(offset: newValue.length),
                                        );
                                      }
                                    }
                                    SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                    sharedPref.setString("leadSource", value.toString().trim());
                                  },
                                  // }
                                ),
                                15.height,
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // CustomTextField(
                              //   hintText: "",
                              //   text: "Points",
                              //   controller: controllers.leadPointsCrt,
                              //   width: textFieldSize,
                              //   keyboardType: TextInputType.text,
                              //   isOptional: false,
                              //   textInputAction: TextInputAction.next,
                              //   onChanged: (value) async {
                              //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                              //     sharedPref.setString("leadPoints", value.toString().trim());
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
                              // ),
                              CustomDropDown(
                                saveValue: controllers.visitType,
                                valueList: controllers.callNameList,
                                text: "Call Visit Type",
                                width: textFieldSize,
                              isOptional : true,
                                //inputFormatters: constInputFormatters.textInput,
                                onChanged: (value) async {
                                  setState(() {
                                    controllers.visitType = value;
                                  });
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString("callVisitType",
                                      value.toString().trim());
                                },
                              ),
                              CustomTextField(
                                hintText: "Total Number Of Head Count",
                                text: "Total Number Of Head Count",
                                controller: controllers.noOfHeadCountCrt,
                                width: textFieldSize,
                                isOptional: false,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString("leadNoOfHeadCount",
                                      value.toString().trim());
                                },
                                // }
                              ),
                              Obx(() => CustomDateBox(
                                isOptional: false,
                                  text: "Expected Conversion Date",
                                  value: controllers.exDate.value,
                                  width: textFieldSize,
                                  onTap: () {
                                    utils.datePicker(
                                        context: context,
                                        textEditingController: controllers.dateOfConCtr,
                                        pathVal: controllers.exDate);
                                  },
                                ),
                              ),
                              // CustomTextField(
                              //   hintText: "Expected Conversion Date",
                              //   text: "Expected Conversion Date",
                              //   controller:
                              //   controllers.expectedConversionDateCrt,
                              //   width: textFieldSize,
                              //   isOptional: false,
                              //   keyboardType: TextInputType.text,
                              //   textInputAction: TextInputAction.next,
                              //   onChanged: (value) async {
                              //     SharedPreferences sharedPref =
                              //     await SharedPreferences.getInstance();
                              //     sharedPref.setString(
                              //         "Expected Conversion Date",
                              //         value.toString().trim());
                              //   },
                              //   // }
                              // ),
                              CustomTextField(
                                hintText: "Details of Service Required",
                                text: "Details of Service Required",
                                controller: controllers.sourceCrt,
                                width: textFieldSize,
                                isOptional: false,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.sourceCrt.value = controllers.sourceCrt.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "Prospect Source Details",
                                      value.toString().trim());
                                },
                                // }
                              ),
                              Obx(() => CustomDateBox(
                                text: "Prospect Enrollment Date",
                                isOptional: false,
                                value: controllers.prospectDate.value,
                                width: textFieldSize,
                                onTap: () {
                                  utils.datePicker(
                                      context: context,
                                      textEditingController: controllers.dateOfConCtr,
                                      pathVal: controllers.prospectDate);
                                },
                              ),
                              ),
                              // CustomTextField(
                              //   hintText: "Prospect Enrollment Date",
                              //   text: "Prospect Enrollment Date",
                              //   controller:
                              //   controllers.prospectEnrollmentDateCrt,
                              //   width: textFieldSize,
                              //   isOptional: false,
                              //   keyboardType: TextInputType.text,
                              //   textInputAction: TextInputAction.next,
                              //   onChanged: (value) async {
                              //     SharedPreferences sharedPref =
                              //     await SharedPreferences.getInstance();
                              //     sharedPref.setString(
                              //         "Prospect Enrollment Date",
                              //         value.toString().trim());
                              //   },
                              //   // }
                              // ),
                              CustomTextField(
                                hintText: "Status Update",
                                text: "Status Update",
                                controller: controllers.statusCrt,
                                width: textFieldSize,
                                isOptional: false,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.statusCrt.value = controllers.statusCrt.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString("statusUpdate",
                                      value.toString().trim());
                                },
                                // }
                              ),

                              15.height,
                            ],
                          ),
                        ],
                      ),////Todo:Observation details
                      20.height,
                      Row(
                        children: [
                          CustomText(
                            text: constValue.addressInfo,
                            colors: colorsConst.textColor,
                            size: 20,
                          ),
                        ],
                      ),////Todo:Address details
                      10.height,
                      Divider(
                        color: Colors.grey.shade400,
                        thickness: 1,
                      ),
                      20.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomTextField(
                                hintText: "Door No (Optional)",
                                text: "Door No (Optional)",
                                controller:
                                controllers.doorNumberController,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                onChanged: (value) async {
                                  SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  sharedPref.setString("leadDNo", value.toString().trim());
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
                              CustomTextField(
                                hintText: "Area (Optional)",
                                text: "Area (Optional)",
                                controller: controllers.areaController,
                                width: textFieldSize,
                                isOptional: false,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.areaController.value = controllers.areaController.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                  await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadArea", value.toString().trim());
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
                              CustomTextField(
                                hintText: "City (Optional)",
                                text: "City (Optional)",
                                controller: controllers.cityController,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue = value.toString()[0].toUpperCase() + value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.cityController.value = controllers.cityController.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  sharedPref.setString("leadCity", value.toString().trim());
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // CustomTextField(
                              //   hintText: "Street (Optional)",
                              //   text: "Street (Optional)",
                              //   controller:
                              //   controllers.streetNameController,
                              //   width: textFieldSize,
                              //   keyboardType: TextInputType.text,
                              //   textInputAction: TextInputAction.next,
                              //   isOptional: false,
                              //   onChanged: (value) async {
                              //     SharedPreferences sharedPref =
                              //     await SharedPreferences.getInstance();
                              //     sharedPref.setString("leadStreet",
                              //         value.toString().trim());
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
                              // ),
                              CustomTextField(
                                hintText: "Pincode",
                                text: "Pincode",
                                controller: controllers.pinCodeController,
                                width: textFieldSize,
                                isOptional: false,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters:
                                constInputFormatters.pinCodeInput,
                                onChanged: (value) async {
                                  if (controllers.pinCodeController.text.trim().length == 6) {
                                    apiService.fetchPinCodeData(controllers.pinCodeController.text.trim());
                                  }
                                  SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  sharedPref.setString("leadPinCode", value.toString().trim());
                                },
                              ),
                              CustomTextField(
                                hintText: "State (Optional)",
                                text: "State (Optional)",
                                controller: controllers.stateController,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                onChanged: (value) async {
                                  SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  sharedPref.setString("leadState", value.toString().trim());
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  25.width,
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text:"Country",
                                        size: 13,
                                        colors: Color(0xff4B5563),
                                      ),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          width: textFieldSize,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: Colors.grey.shade200)),
                                          child: Obx(() => CustomText(
                                              text: "    ${controllers.selectedCountry.value}",
                                              colors: colorsConst.textColor,
                                              size: 15,
                                            ),
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                          15.height,
                    ]),
                  ),
                ),
              ])),
        ]));
  }
}