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
import 'package:fullcomm_crm/components/custom_checkbox.dart';
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
    await utils.getStates();

    controllers.selectedState.value = "Tamil Nadu";
    await utils.getCities();

    //setState(() => controllers.selectedCity = controllers.coCityController.text);
  }

  Future<void> getStringValue() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      //setState(() {
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
      controllers.leadFieldName[0].text = "";
      controllers.leadFieldValue[0].text = "";
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
    });
    //});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      setDefaults();
    });
  }

  @override
  Widget build(BuildContext context) {
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 3.5;
    return Scaffold(
        backgroundColor: colorsConst.primary,
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
              child: Column(
                children: [
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
                            text:
                                "Add your ${controllers.leadCategoryList[0]["value"]} Information",
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
                                  for (int i = 0;
                                      i < controllers.leadPersonalItems.value;
                                      i++) {
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
                              textColor: Colors.black,
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
                                } else if (controllers
                                        .leadMobileCrt[0].text.length !=
                                    10) {
                                  utils.snackBar(
                                      msg: "Invalid Mobile Number",
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
                                } else {
                                  apiService.insertSingleCustomer(context);
                                  // if (controllers.leadEmailCrt[0].text.isEmail) {
                                  //   if (controllers.leadCoEmailCrt.text.isEmail) {
                                  //     apiService.insertLeadAPI(context);
                                  //   } else {
                                  //     utils.snackBar(
                                  //         msg: "Invalid Company Email",
                                  //         color: colorsConst.primary,
                                  //         context: context);
                                  //     controllers.leadCtr.reset();
                                  //   }
                                  // } else {
                                  //   utils.snackBar(
                                  //       msg: "Invalid Email",
                                  //       color: colorsConst.primary,
                                  //       context: context);
                                  //   controllers.leadCtr.reset();
                                  // }
                                  // else if(controllers.leadTitleCrt[0].text.isEmpty){
                                  //   utils.snackBar(msg: "Please add title",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadCoNameCrt.text.isEmpty){
                                  //   utils.snackBar(msg: "Please add company name",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadCoMobileCrt.text.length!=10){
                                  //   utils.snackBar(msg: "Invalid Company Mobile Number",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.industry==null){
                                  //   utils.snackBar(msg: "Please add industry",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadProduct.text.isEmpty){
                                  //   utils.snackBar(msg: "Please add product/services",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.pinCode==null){
                                  //   utils.snackBar(msg: "Please add pin code",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.selectedCity.isEmpty){
                                  //   utils.snackBar(msg: "Please add city",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.status==null){
                                  //   utils.snackBar(msg: "Please add status",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadOwnerNameCrt.text.isEmpty){
                                  //   utils.snackBar(msg: "Please add lead owner",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else{
                                  //   if(controllers.leadEmailCrt[0].text.isEmail){
                                  //     if(controllers.leadCoEmailCrt.text.isEmail){
                                  //       apiService.insertLeadAPI(context);
                                  //     }else{
                                  //       utils.snackBar(msg: "Invalid Company Email",
                                  //           color: colorsConst.primary,context:context);
                                  //       controllers.leadCtr.reset();
                                  //     }
                                  //
                                  //   }else{
                                  //     utils.snackBar(msg: "Invalid Email",
                                  //         color: colorsConst.primary,context:context);
                                  //     controllers.leadCtr.reset();
                                  //   }
                                }
                              },
                              text: "Save Lead",
                              height: 45,
                              controller: controllers.leadCtr,
                              isLoading: true,
                              textColor: Colors.black,
                              backgroundColor: colorsConst.third,
                              radius: 10,
                              width: 160),
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
                          Obx(
                            () => ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controllers.leadPersonalItems.value,
                                itemBuilder: (context, index) {
                                  controllers.leadNameCrt
                                      .add(TextEditingController());
                                  controllers.leadMobileCrt
                                      .add(TextEditingController());
                                  controllers.leadTitleCrt
                                      .add(TextEditingController());
                                  controllers.leadEmailCrt
                                      .add(TextEditingController());
                                  controllers.leadWhatsCrt
                                      .add(TextEditingController());
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                  controller: controllers
                                                      .groupController,
                                                  options: GroupButtonOptions(
                                                    //borderRadius: BorderRadius.circular(20),
                                                    spacing: 1,
                                                    elevation: 0,
                                                    selectedTextStyle:
                                                        customStyle.textStyle(
                                                            colors: colorsConst
                                                                .third,
                                                            size: 16,
                                                            isBold: true),
                                                    selectedBorderColor: Colors.transparent,
                                                    selectedColor: Colors.transparent,
                                                    unselectedBorderColor:
                                                        Colors.transparent,
                                                    unselectedColor:
                                                        Colors.transparent,
                                                    unselectedTextStyle:
                                                        customStyle.textStyle(
                                                            colors: colorsConst
                                                                .textColor,
                                                            size: 16,
                                                            isBold: true),
                                                  ),
                                                  onSelected: (name, index,
                                                      isSelected) async {
                                                    setState(() {
                                                      controllers.leadCategory =
                                                          name;
                                                    });
                                                  },
                                                  buttons: controllers
                                                      .leadCategoryGrList,
                                                )
                                              : 0.width,
                                          index !=
                                                  controllers.leadPersonalItems
                                                          .value -
                                                      1
                                              ? 0.width
                                              : InkWell(
                                                  onTap: () async {
                                                    controllers
                                                        .leadPersonalItems++;
                                                    controllers.isMainPersonList
                                                        .add(false);
                                                    controllers
                                                        .isCoMobileNumberList
                                                        .add(false);
                                                    SharedPreferences
                                                        sharedPref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    sharedPref.setInt(
                                                        "leadCount",
                                                        controllers
                                                            .leadPersonalItems
                                                            .value);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.add,
                                                        color:
                                                            colorsConst.third,
                                                        size: 15,
                                                      ),
                                                      CustomText(
                                                        text:
                                                            "Add more personnel",
                                                        colors:
                                                            colorsConst.third,
                                                        size: 15,
                                                        isCopy: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ],
                                      ),
                                      10.height,
                                      Divider(
                                        color: Colors.grey.shade400,
                                        thickness: 1,
                                      ),
                                      5.height,
                                      controllers.leadPersonalItems.value ==
                                                  1 &&
                                              index == 0
                                          ? 0.width
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    controllers.isMainPersonList
                                                        .remove(controllers
                                                            .leadPersonalItems);
                                                    controllers
                                                        .isCoMobileNumberList
                                                        .remove(controllers
                                                            .leadPersonalItems);
                                                    controllers
                                                        .leadPersonalItems--;

                                                    controllers.leadNameCrt
                                                        .removeAt(index);
                                                    controllers.leadMobileCrt
                                                        .removeAt(index);
                                                    controllers.leadTitleCrt
                                                        .removeAt(index);
                                                    controllers.leadEmailCrt
                                                        .removeAt(index);

                                                    SharedPreferences
                                                        sharedPref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    sharedPref.setInt(
                                                        "leadCount",
                                                        controllers
                                                            .leadPersonalItems
                                                            .value);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.remove,
                                                        color:
                                                            colorsConst.third,
                                                        size: 15,
                                                      ),
                                                      CustomText(
                                                        text:
                                                            "Remove personnel",
                                                        colors:
                                                            colorsConst.third,
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
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                isOptional: false,
                                                controller: controllers
                                                    .leadNameCrt[index],
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .textInput,

                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "leadName$index",
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

                                              10.height,
                                              CustomText(
                                                text: "Whatsapp No",
                                                colors: colorsConst.headColor,
                                                size: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  20.width,
                                                  SizedBox(
                                                    width: textFieldSize,
                                                    height: 50,
                                                    child: TextFormField(
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontFamily: "Lato"),
                                                        cursorColor:
                                                            Colors.white,
                                                        onChanged:
                                                            (value) async {
                                                          SharedPreferences
                                                              sharedPref =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          sharedPref.setString(
                                                              "leadMobileNumber$index",
                                                              value
                                                                  .toString()
                                                                  .trim());
                                                        },
                                                        onTap: () {},
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters:
                                                            constInputFormatters
                                                                .mobileNumberInput,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .none,
                                                        controller: controllers
                                                                .leadMobileCrt[
                                                            index],
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        decoration:
                                                            InputDecoration(
                                                          // hintText:"Mobile No.",
                                                          // hintStyle: TextStyle(
                                                          //     color:Colors.grey.shade400,
                                                          //     fontSize: 13,
                                                          //     fontFamily:"Lato"
                                                          // ),
                                                          fillColor: Colors
                                                              .transparent,
                                                          filled: true,
                                                          //prefixIcon:IconButton(onPressed: (){}, icon: SvgPicture.asset(assets.gPhone,width:15,height:15) ),

                                                          suffixIcon: Obx(
                                                            () => Checkbox(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                ),
                                                                side: MaterialStateBorderSide
                                                                    .resolveWith(
                                                                  (states) => BorderSide(
                                                                      width:
                                                                          1.0,
                                                                      color: colorsConst
                                                                          .textColor),
                                                                ),
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                activeColor:
                                                                    colorsConst
                                                                        .third,
                                                                value: controllers
                                                                        .isCoMobileNumberList[
                                                                    index],
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    controllers.isCoMobileNumberList[
                                                                            index] =
                                                                        value!;
                                                                    if (controllers
                                                                            .isCoMobileNumber
                                                                            .value ==
                                                                        true) {
                                                                      controllers
                                                                          .leadWhatsCrt[
                                                                              index]
                                                                          .text = controllers.leadMobileCrt[index].text;
                                                                    } else {
                                                                      controllers
                                                                          .leadWhatsCrt[
                                                                              index]
                                                                          .text = "";
                                                                    }
                                                                  });
                                                                }),
                                                          ),
                                                          enabledBorder:
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
                                                          focusedErrorBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          // errorStyle: const TextStyle(height:0.05,fontSize: 12),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      10.0,
                                                                  horizontal:
                                                                      10.0),
                                                          errorBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              10.height,
                                              CustomTextField(
                                                hintText: "Whatsapp No",
                                                text: "Whats",
                                                controller: controllers
                                                    .leadWhatsCrt[index],
                                                width: textFieldSize,
                                                isOptional: false,
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .mobileNumberInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "leadWhats$index",
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
                                          SizedBox(
                                            width: (MediaQuery.of(context).size.width - 500) / 4.5,
                                          ),
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
                                                controller: controllers
                                                    .leadTitleCrt[index],
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .textInput,
                                                isOptional: false,
                                                onChanged: (value) async {
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
                                                controller: controllers
                                                    .leadEmailCrt[index],
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .emailInput,
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
                                              Obx(
                                                () => CustomDateBox(
                                                  text: "Date of Connection",
                                                  value:
                                                      controllers.empDOB.value,
                                                  width: textFieldSize,
                                                  onTap: () {
                                                    utils.datePicker(
                                                        context: context,
                                                        textEditingController:
                                                            controllers
                                                                .dateOfConCtr,
                                                        pathVal: controllers.empDOB);
                                                  },
                                                ),
                                              ),
                                              15.height,
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
                          ),
                          10.height,
                          Divider(
                            color: Colors.grey.shade400,
                            thickness: 1,
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              // 5.width,
                              Column(
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
                                    inputFormatters:
                                        constInputFormatters.textInput,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadCoName",
                                          value.toString().trim());
                                    },
                                  ),
                                  CustomTextField(
                                    hintText: "Company Phone No.",
                                    text: "Company\n Phone No.",
                                    controller: controllers.leadCoMobileCrt,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
                                    inputFormatters:
                                        constInputFormatters.mobileNumberInput,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadCoMobile",
                                          value.toString().trim());
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
                                  10.height,
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
                                      sharedPref.setString("leadLinkedin",
                                          value.toString().trim());
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 400) /
                                        4.5,
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
                                      sharedPref.setString("leadCoEmail",
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
                                    hintText: "Product/Services (Optional)",
                                    text: "Product/Services (Optional)",
                                    controller: controllers.leadProduct,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadProduct",
                                          value.toString().trim());
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
                                    inputFormatters:
                                        constInputFormatters.textInput,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadWebsite",
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
                          ),
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
                          ),
                          10.height,
                          Divider(
                            color: Colors.grey.shade400,
                            thickness: 1,
                          ),
                          20.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                              //     utils.textFieldNearText(
                              //         'Actions to be taken', false),
                              //     10.height,
                              //     utils.textFieldNearText(
                              //         'Source Of Prospect', false),
                              //     10.height,
                              //     utils.textFieldNearText(
                              //         'Product Discussed', false),
                              //     10.height,
                              //     utils.textFieldNearText(
                              //         'Expected Monthly Billing Value', false),
                              //     10.height,
                              //     utils.textFieldNearText('ARPU Value', false),
                              //     // 10.height,
                              //     // utils.textFieldNearText('Source Of Details',false),
                              //     10.height,
                              //     utils.textFieldNearText(
                              //         'Prospect Grading', false),
                              //   ],
                              // ),
                              // 5.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
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
                                    controller:
                                        controllers.prodDescriptionController,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
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
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "leadExMonthBillingVal",
                                          value.toString().trim());
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
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
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
                                    hintText: "",
                                    text: "Prospect Grading",
                                    controller: controllers.prospectGradingCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadSource",
                                          value.toString().trim());
                                    },
                                    // }
                                  ),
                                ],
                              ),
                              SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 400) /
                                        4.5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //utils.textFieldNearText('Points',false),
                                  utils.textFieldNearText(
                                      'Call Visit Type', true),
                                  10.height,
                                  utils.textFieldNearText(
                                      'Total Number Of Head Count', false),
                                  8.height,
                                  utils.textFieldNearText(
                                      'Expected Conversion Date', false),
                                  8.height,
                                  utils.textFieldNearText(
                                      'Details of Service Required', false),
                                  8.height,
                                  utils.textFieldNearText(
                                      'Prospect Enrollment Date', false),
                                  8.height,
                                  utils.textFieldNearText(
                                      'Status Update', false),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
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
                                  10.height,
                                  CustomTextField(
                                    hintText: "",
                                    text: "Total Number Of Head Count",
                                    controller: controllers.noOfHeadCountCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadNoOfHeadCount",
                                          value.toString().trim());
                                    },
                                    // }
                                  ),
                                  CustomTextField(
                                    hintText: "",
                                    text: "Expected Conversion Date",
                                    controller:
                                        controllers.expectedConversionDateCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "Expected Conversion Date",
                                          value.toString().trim());
                                    },
                                    // }
                                  ),
                                  CustomTextField(
                                    hintText: "",
                                    text: "Details of Service Required",
                                    controller: controllers.sourceCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "Prospect Source Details",
                                          value.toString().trim());
                                    },
                                    // }
                                  ),
                                  CustomTextField(
                                    hintText: "",
                                    text: "Prospect Enrollment Date",
                                    controller:
                                        controllers.prospectEnrollmentDateCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "Prospect Enrollment Date",
                                          value.toString().trim());
                                    },
                                    // }
                                  ),
                                  CustomTextField(
                                    hintText: "",
                                    text: "Status Update",
                                    controller: controllers.statusCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("statusUpdate",
                                          value.toString().trim());
                                    },
                                    // }
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CustomText(
                                text: constValue.addressInfo,
                                colors: colorsConst.textColor,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  30.height,
                                  utils.textFieldNearText('Door No', false),
                                  20.height,
                                  utils.textFieldNearText('Area', false),
                                  10.height,
                                  utils.textFieldNearText('City', false),
                                  10.height,
                                  utils.textFieldNearText('Country', false),
                                  10.height
                                ],
                              ),
                              5.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomTextField(
                                    hintText: "",
                                    text: "Door No (Optional)",
                                    controller:
                                        controllers.doorNumberController,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "leadDNo", value.toString().trim());
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
                                    hintText: "",
                                    text: "Area (Optional)",
                                    controller: controllers.areaController,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
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
                                    hintText: "",
                                    text: "City (Optional)",
                                    controller: controllers.cityController,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "leadCity", value.toString().trim());
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
                                  // CustomDropDown(
                                  //   saveValue: controllers.selectedCity,
                                  //   valueList: controllers.selectCityList,
                                  //   text: "City",
                                  //   width: textFieldSize,
                                  //   //inputFormatters: constInputFormatters.textInput,
                                  //   onChanged: (value) async {
                                  //     setState(() {
                                  //       controllers.selectedCity = value.toString();
                                  //       //if (value != controllers.selectedCity){
                                  //       controllers.selectPinCodeList = [];
                                  //       controllers.pinCode = null;
                                  //       controllers.selectedCity = value.toString();
                                  //       controllers.selectPinCodeList =
                                  //           controllers.pinCodeList.where((location) =>
                                  //           location["STATE"] == controllers.selectedState &&
                                  //               location["DISTRICT"] == controllers.selectedCity)
                                  //               .map((location) => location["PINCODE"].toString()).toList();
                                  //
                                  //       //}
                                  //       print("city name ${controllers.selectedCity} State name ${controllers.selectedState}");
                                  //       //print("Pincode ${controllers.selectPinCodeList}");
                                  //     });
                                  //
                                  //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  //     sharedPref.setString("leadCity", value.toString().trim());
                                  //   },
                                  // ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      25.width,
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          width: textFieldSize,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.grey.shade200)),
                                          child: Obx(
                                            () => CustomText(
                                              text:
                                                  "    ${controllers.selectedCountry.value}",
                                              colors: Colors.white,
                                              size: 15,
                                            ),
                                          ))
                                    ],
                                  ),
                                  // CustomDropDown(
                                  //   saveValue: controllers.pinCode,
                                  //   valueList: controllers.selectPinCodeList,
                                  //   text: "Pin Code (Optional)",
                                  //   width: textFieldSize,
                                  //   //inputFormatters: constInputFormatters.textInput,
                                  //   onChanged: (value) async {
                                  //     setState((){
                                  //       controllers.pinCode = value;
                                  //     });
                                  //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  //     sharedPref.setString("leadPinCode", value.toString().trim());
                                  //   },
                                  // ),
                                ],
                              ),
                              SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 400) /
                                        4.5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  utils.textFieldNearText('Street', false),
                                  10.height,
                                  utils.textFieldNearText('Pin Code', false),
                                  10.height,
                                  utils.textFieldNearText('State', false),
                                  80.height
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomTextField(
                                    hintText: "",
                                    text: "Street (Optional)",
                                    controller:
                                        controllers.streetNameController,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadStreet",
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
                                  10.height,
                                  CustomTextField(
                                    hintText: "",
                                    text: "PIN",
                                    controller: controllers.pinCodeController,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters:
                                        constInputFormatters.pinCodeInput,
                                    onChanged: (value) async {
                                      if (controllers.pinCodeController.text
                                              .trim()
                                              .length ==
                                          6) {
                                        apiService.fetchPinCodeData(controllers
                                            .pinCodeController.text
                                            .trim());
                                      }
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadPinCode",
                                          value.toString().trim());
                                    },
                                  ),

                                  20.height,
                                  CustomTextField(
                                    hintText: "",
                                    text: "State (Optional)",
                                    controller: controllers.stateController,
                                    width: textFieldSize,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    isOptional: false,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "leadState", value.toString().trim());
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
                                  // utils.stateDropdown(
                                  //     textFieldSize,controllers.cityController,
                                  //     controllers.stateController,
                                  //     controllers.countryController),

                                  // CustomDropDown(
                                  //   saveValue: controllers.selectedState,
                                  //   valueList: controllers.selectStateList,
                                  //   text: "State (Optional)",
                                  //   width: textFieldSize,
                                  //   //inputFormatters: constInputFormatters.textInput,
                                  //   onChanged: (value) async {
                                  //     setState(() {
                                  //       controllers.selectedState = value.toString();
                                  //       controllers.selectCityList = [];
                                  //       for (var entry in controllers.pinCodeList){
                                  //         if (entry['STATE'] == controllers.selectedState && entry['DISTRICT'] is String){
                                  //           if (!controllers.selectCityList.contains(entry['DISTRICT'])){
                                  //             controllers.selectCityList.add(entry['DISTRICT']);
                                  //           }
                                  //         }
                                  //       }
                                  //     });
                                  //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  //     sharedPref.setString("leadState", value.toString().trim());
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

                                  // utils.countryDropdown(
                                  //     textFieldSize,
                                  //     controllers.cityController,
                                  //     controllers.stateController,
                                  //     controllers.countryController),

                                  // CustomTextField(
                                  //   hintText:"City",
                                  //   text:"City",
                                  //   controller: controllers.cityController,
                                  //   width:textFieldSize,
                                  //   keyboardType: TextInputType.text,
                                  //   textInputAction: TextInputAction.next,
                                  //   inputFormatters: constInputFormatters.addressInput,
                                  //   onChanged:(value) async {
                                  //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                  //     sharedPref.setString("leadCity", value.toString().trim());
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
                                  90.height,
                                  // CustomTextField(
                                  //   hintText:"Location Link",
                                  //   text:"Location Link",
                                  //   controller: controllers.l,
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
                                ],
                              ),
                            ],
                          ),
                          // 20.height,
                          // Row(
                          //   children:[
                          //     CustomText(
                          //       text: constValue.leadDetails,
                          //       colors: colorsConst.textColor,
                          //       size: 20,
                          //     ),
                          //   ],
                          // ),
                          // 10.height,
                          // Divider(
                          //   color: Colors.grey.shade400,
                          //   thickness: 1,
                          // ),
                          // 20.height,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //   children:[
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         utils.textFieldNearText('Source',false),
                          //         16.height,
                          //         utils.textFieldNearText('Status',false),
                          //         // 16.height,
                          //         // utils.textFieldNearText('Category'),
                          //       ],
                          //     ),
                          //     5.width,
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.end,
                          //       children:[
                          //         CustomDropDown(
                          //           saveValue: controllers.source,
                          //           valueList: controllers.sourceList,
                          //           text: "Source",
                          //           width: textFieldSize,
                          //
                          //           //inputFormatters: constInputFormatters.textInput,
                          //           onChanged: (value) async {
                          //             setState(() {
                          //               controllers.source = value;
                          //             });
                          //             SharedPreferences sharedPref =
                          //                 await SharedPreferences.getInstance();
                          //             sharedPref.setString(
                          //                 "source", value.toString().trim());
                          //           },
                          //         ),
                          //         40.height,
                          //         CustomDropDown(
                          //           saveValue: controllers.status,
                          //           valueList: controllers.statusList,
                          //           text: "Status",
                          //           width: textFieldSize,
                          //           //inputFormatters: constInputFormatters.textInput,
                          //           onChanged: (value) async {
                          //             setState(() {
                          //               controllers.status = value;
                          //             });
                          //             SharedPreferences sharedPref =
                          //                 await SharedPreferences.getInstance();
                          //             sharedPref.setString(
                          //                 "status", value.toString().trim());
                          //           },
                          //         ),
                          //         // 40.height,
                          //         // CustomDropDown(
                          //         //   saveValue: controllers.leadCategory,
                          //         //   valueList: controllers.leadCategoryList,
                          //         //   text: "Category",
                          //         //   width: textFieldSize,
                          //         //   //inputFormatters: constInputFormatters.textInput,
                          //         //   onChanged: (value) async {
                          //         //     setState(() {
                          //         //       controllers.leadCategory = value.toString();
                          //         //     });
                          //         //     // SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          //         //     // sharedPref.setString("status", value.toString().trim());
                          //         //   },
                          //         // ),
                          //       ],
                          //     ),
                          //     SizedBox(
                          //       width:(MediaQuery.of(context).size.width - 400) / 4.5,
                          //     ),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children:[
                          //         utils.textFieldNearText('Source Details',false),
                          //         16.height,
                          //         utils.textFieldNearText('Lead Owner',false),
                          //         //80.height
                          //       ],
                          //     ),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.end,
                          //       children:[
                          //         CustomTextField(
                          //           hintText: "",
                          //           text: "Source Details",
                          //           isOptional: false,
                          //           controller: controllers.leadSourceCrt,
                          //           width: textFieldSize,
                          //           keyboardType: TextInputType.text,
                          //           textInputAction: TextInputAction.next,
                          //           inputFormatters:
                          //           constInputFormatters.textInput,
                          //           onChanged: (value) async {
                          //             SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          //             sharedPref.setString("leadSourceDetails", value.toString().trim());
                          //           },
                          //         ),
                          //         10.height,
                          //         CustomTextField(
                          //           hintText: "",
                          //           text: "Lead Owner",
                          //           controller: controllers.leadOwnerNameCrt,
                          //           width: textFieldSize,
                          //           isOptional: false,
                          //           keyboardType: TextInputType.text,
                          //           textInputAction: TextInputAction.next,
                          //           inputFormatters:
                          //               constInputFormatters.textInput,
                          //           onChanged: (value) async {
                          //             SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          //             sharedPref.setString("leadOwnerName", value.toString().trim());
                          //           },
                          //           // validator:(value){
                          //           //   if(value.toString().isEmpty){
                          //           //     return "This field is required";
                          //           //   }else if(value.toString().trim().length!=10){
                          //           //     return "Check Your Phone Number";
                          //           //   }else{
                          //           //     return null;
                          //           //   }
                          //           // }
                          //         ),
                          //         //80.height
                          //         // CustomTextField(
                          //         //   hintText:"Lead Owner",
                          //         //   text:"Lead Owner",
                          //         //   controller: controllers.leadMobileCrt,
                          //         //   width:textFieldSize,
                          //         //   keyboardType: TextInputType.text,
                          //         //
                          //         //   //inputFormatters: constInputFormatters.textInput,
                          //         //   onChanged:(value) async {
                          //         //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          //         //     sharedPref.setString("eventName", value.toString().trim());
                          //         //   },
                          //         //   // validator:(value){
                          //         //   //   if(value.toString().isEmpty){
                          //         //   //     return "This field is required";
                          //         //   //   }else if(value.toString().trim().length!=10){
                          //         //   //     return "Check Your Phone Number";
                          //         //   //   }else{
                          //         //   //     return null;
                          //         //   //   }
                          //         //   // }
                          //         //
                          //         // ),
                          //         // Row(
                          //         //   children: [
                          //         //     Radio<String>(
                          //         //       value: 'Warm',
                          //         //       groupValue:controllers.selectedRating,
                          //         //       activeColor: Color(0xffFF0000),
                          //         //       onChanged:(value){
                          //         //         setState((){
                          //         //           controllers.selectedRating = value!;
                          //         //         });
                          //         //       },
                          //         //     ),
                          //         //     CustomText(
                          //         //       text: "Warm",
                          //         //       colors: Color(0xffFF0000),
                          //         //       size: 14,
                          //         //     ),
                          //         //     70.width,
                          //         //     Radio<String>(
                          //         //       value: 'Cold',
                          //         //       groupValue:controllers.selectedRating,
                          //         //       activeColor: Color(0xff0000FF),
                          //         //       onChanged:(value){
                          //         //         setState((){
                          //         //           controllers.selectedRating = value!;
                          //         //         });
                          //         //       },
                          //         //     ),
                          //         //     CustomText(
                          //         //       text: "Cold",
                          //         //       colors: Color(0xff0000FF),
                          //         //       size: 14,
                          //         //     ),
                          //         //     70.width,
                          //         //     Radio<String>(
                          //         //       value: 'Hot',
                          //         //       groupValue:controllers.selectedRating,
                          //         //       activeColor: Color(0xffFFA500),
                          //         //       onChanged:(value){
                          //         //         setState((){
                          //         //           controllers.selectedRating = value!;
                          //         //         });
                          //         //       },
                          //         //     ),
                          //         //     CustomText(
                          //         //       text: "Hot",
                          //         //       colors: Color(0xffFFA500),
                          //         //       size: 14,
                          //         //     ),
                          //         //   ],
                          //         // ),
                          //         // Row(
                          //         //   children: [
                          //         //     CustomText(
                          //         //       //text:"Rating",
                          //         //       text: "",
                          //         //       colors: colorsConst.secondary,
                          //         //       size: 15,
                          //         //     ),
                          //         //     25.width,
                          //         //   ],
                          //         // ),
                          //         // CustomDropDown(
                          //         //   text:"Rating",
                          //         //   saveValue: controllers.rating,
                          //         //   valueList: controllers.ratingLis,
                          //         //   width:textFieldSize,
                          //         //
                          //         //   //inputFormatters: constInputFormatters.textInput,
                          //         //   onChanged:(value) async {
                          //         //     setState(() {
                          //         //       controllers.rating=value;
                          //         //     });
                          //         //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          //         //     sharedPref.setString("rating", value.toString().trim());
                          //         //   },
                          //         //   // validator:(value){
                          //         //   //   if(value.toString().isEmpty){
                          //         //   //     return "This field is required";
                          //         //   //   }else if(value.toString().trim().length!=10){
                          //         //   //     return "Check Your Phone Number";
                          //         //   //   }else{
                          //         //   //     return null;
                          //         //   //   }
                          //         //   // }
                          //         //
                          //         // ),
                          //       ],
                          //     ),
                          //   ],
                          // ),
                          20.height,
                          Row(
                            children: [
                              CustomText(
                                text: constValue.leadGst,
                                colors: colorsConst.textColor,
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  utils.textFieldNearText('GST Number', false),
                                  16.height,
                                  utils.textFieldNearText(
                                      'Place Of Business', false),
                                  // 16.height,
                                  // utils.textFieldNearText('Category'),
                                ],
                              ),
                              5.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  CustomTextField(
                                    hintText: "",
                                    text: "GST Number",
                                    controller: controllers.leadGstNumCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(15),
                                    ],
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString(
                                          "leadGST", value.toString().trim());
                                    },
                                  ),
                                  40.height,
                                  CustomTextField(
                                    hintText: "",
                                    text: "Location",
                                    controller: controllers.leadGstLocationCrt,
                                    width: textFieldSize,
                                    isOptional: false,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (value) async {
                                      SharedPreferences sharedPref =
                                          await SharedPreferences.getInstance();
                                      sharedPref.setString("leadGSTLocation",
                                          value.toString().trim());
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 400) /
                                        4.5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  utils.textFieldNearText(
                                      'Date Of Registration', false),
                                  80.height
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Obx(
                                    () => CustomDateBox(
                                      text: "Date of Registration",
                                      value: controllers.leadDOR.value,
                                      width: textFieldSize,
                                      onTap: () {
                                        utils.datePicker(
                                            context: context,
                                            textEditingController:
                                                controllers.leadGstDORCrt,
                                            pathVal: controllers.leadDOR);
                                      },
                                    ),
                                  ),
                                  90.height,
                                ],
                              ),
                            ],
                          ),
                          20.height,
                          // Row(
                          //   children:[
                          //     CustomText(
                          //       text: constValue.additionalInfo,
                          //       colors: colorsConst.textColor,
                          //       size: 20,
                          //     ),
                          //   ],
                          // ),
                          // 10.height,
                          // Divider(
                          //   color: Colors.grey.shade400,
                          //   thickness: 1,
                          // ),
                          // 20.height,
                          // UnconstrainedBox(
                          //   child: Container(
                          //     width: MediaQuery.of(context).size.width - 180,
                          //     alignment: Alignment.topLeft,
                          //     child:GridView.builder(
                          //         shrinkWrap: true,
                          //         physics: const NeverScrollableScrollPhysics(),
                          //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          //             crossAxisCount: 2,
                          //             crossAxisSpacing: 10.0,
                          //             mainAxisSpacing: 10.0,
                          //             mainAxisExtent: 100
                          //
                          //         ),
                          //         primary: false,
                          //         itemCount: controllers.leadFieldItems.value,
                          //         itemBuilder:(context, index){
                          //           controllers.leadFieldName.add(TextEditingController());
                          //           controllers.leadFieldValue.add(TextEditingController());
                          //           return Container(
                          //             width: MediaQuery.of(context).size.width - 2.5,
                          //             alignment: index.isEven?Alignment.topRight:Alignment.topLeft,
                          //             child: Row(
                          //               mainAxisAlignment: index.isEven?MainAxisAlignment.start:MainAxisAlignment.end,
                          //               children: [
                          //                 Column(
                          //                   crossAxisAlignment: CrossAxisAlignment.start,
                          //                   children:[
                          //                     Row(
                          //                       children: [
                          //                         25.width,
                          //                         CustomText(
                          //                           text: "Field Name",
                          //                           textAlign: TextAlign.start,
                          //                           colors:colorsConst.headColor,
                          //                           size:15,
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     CustomTextField(
                          //                       hintText: "Field Name",
                          //                       text: "Field Name",
                          //                       controller: controllers.leadFieldName[index],
                          //                       width: 210,
                          //                       keyboardType: TextInputType.text,
                          //                       textInputAction: TextInputAction.next,
                          //                       onChanged: (value) async {
                          //                         // SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          //                         // sharedPref.setString("budget", value.toString().trim());
                          //                       },
                          //                     ),
                          //                   ],
                          //                 ),
                          //                 Column(
                          //                   crossAxisAlignment: CrossAxisAlignment.start,
                          //                   children:[
                          //                     Row(
                          //                       children:[
                          //                         25.width,
                          //                         CustomText(
                          //                           text: "Field Value",
                          //                           textAlign: TextAlign.start,
                          //                           colors:colorsConst.headColor,
                          //                           size:15,
                          //                         ),
                          //                       ],
                          //                     ),
                          //                     CustomTextField(
                          //                       hintText: "Field Value",
                          //                       text: "Field Value",
                          //                       controller: controllers.leadFieldValue[index],
                          //                       width: textFieldSize,
                          //                       keyboardType: TextInputType.text,
                          //                       textInputAction: TextInputAction.next,
                          //                       onChanged: (value) async {
                          //                         // SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          //                         // sharedPref.setString("budget", value.toString().trim());
                          //                       },
                          //                     ),
                          //                   ],
                          //                 ),
                          //                 IconButton(onPressed:(){
                          //                   setState(() {
                          //                     if(index+1==controllers.leadFieldItems.value){
                          //                       controllers.leadFieldItems++;
                          //                     }else{
                          //                       controllers.leadFieldItems--;
                          //                       controllers.leadFieldName.removeAt(index);
                          //                       controllers.leadFieldValue.removeAt(index);
                          //                     }
                          //                   });
                          //                 },
                          //                     icon: Icon(index+1==controllers.leadFieldItems.value?Icons.add:Icons.remove,
                          //                       color: colorsConst.third,))
                          //               ],
                          //             ),
                          //           );
                          //         }
                          //     ),
                          //   ),
                          // ),
                          // 20.height,
                          // Row(
                          //   children: [
                          //     CustomText(
                          //       text: constValue.customFields,
                          //       colors: colorsConst.textColor,
                          //       size: 20,
                          //     ),
                          //   ],
                          // ),
                          // 10.height,
                          // Divider(
                          //   color: Colors.grey.shade400,
                          //   thickness: 1,
                          // ),
                          // 20.height,
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //   children: [
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         10.height,
                          //         utils.textFieldNearText('Budget'),
                          //         25.height,
                          //         utils.textFieldNearText('Service Interest'),
                          //       ],
                          //     ),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.end,
                          //       children: [
                          //         CustomTextField(
                          //           hintText: "Budget",
                          //           text: "Budget",
                          //           controller: controllers.budgetCrt,
                          //           width: textFieldSize,
                          //           keyboardType: TextInputType.text,
                          //           textInputAction: TextInputAction.next,
                          //           inputFormatters:
                          //               constInputFormatters.numberInput,
                          //           onChanged: (value) async {
                          //             SharedPreferences sharedPref =
                          //                 await SharedPreferences.getInstance();
                          //             sharedPref.setString(
                          //                 "budget", value.toString().trim());
                          //           },
                          //           // validator:(value){
                          //           //   if(value.toString().isEmpty){
                          //           //     return "This field is required";
                          //           //   }else if(value.toString().trim().length!=10){
                          //           //     return "Check Your Phone Number";
                          //           //   }else{
                          //           //     return null;
                          //           //   }
                          //           // }
                          //         ),
                          //         40.height,
                          //         CustomDropDown(
                          //           saveValue: controllers.service,
                          //           valueList: controllers.serviceList,
                          //           text: "Service Interest",
                          //           width: textFieldSize,
                          //
                          //           //inputFormatters: constInputFormatters.textInput,
                          //           onChanged: (value) async {
                          //             setState(() {
                          //               controllers.service = value;
                          //             });
                          //             SharedPreferences sharedPref =
                          //                 await SharedPreferences.getInstance();
                          //             sharedPref.setString(
                          //                 "service", value.toString().trim());
                          //           },
                          //           // validator:(value){
                          //           //   if(value.toString().isEmpty){
                          //           //     return "This field is required";
                          //           //   }else if(value.toString().trim().length!=10){
                          //           //     return "Check Your Phone Number";
                          //           //   }else{
                          //           //     return null;
                          //           //   }
                          //           // }
                          //         ),
                          //       ],
                          //     ),
                          //     SizedBox(
                          //       width:
                          //           (MediaQuery.of(context).size.width - 400) /
                          //               4.5,
                          //     ),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         utils.textFieldNearText(
                          //             'Timeline for\n Decision'),
                          //         16.height,
                          //         utils.textFieldNearText('Description'),
                          //       ],
                          //     ),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.end,
                          //       children: [
                          //         CustomTextField(
                          //           hintText: "Timeline for\n Decision",
                          //           text: "Timeline for\n Decision",
                          //           controller: controllers.leadTime,
                          //           width: textFieldSize,
                          //           keyboardType: TextInputType.text,
                          //           textInputAction: TextInputAction.next,
                          //           //inputFormatters: constInputFormatters.textInput,
                          //           onChanged: (value) async {
                          //             SharedPreferences sharedPref =
                          //                 await SharedPreferences.getInstance();
                          //             sharedPref.setString(
                          //                 "leadTime", value.toString().trim());
                          //           },
                          //           // validator:(value){
                          //           //   if(value.toString().isEmpty){
                          //           //     return "This field is required";
                          //           //   }else if(value.toString().trim().length!=10){
                          //           //     return "Check Your Phone Number";
                          //           //   }else{
                          //           //     return null;
                          //           //   }
                          //           // }
                          //         ),
                          //         20.height,
                          //         CustomTextField(
                          //           hintText: "Description",
                          //           text: "Description",
                          //           controller: controllers.leadDescription,
                          //           width: textFieldSize,
                          //           keyboardType: TextInputType.text,
                          //           textInputAction: TextInputAction.next,
                          //           inputFormatters: constInputFormatters.textInput,
                          //           onChanged: (value) async {
                          //             SharedPreferences sharedPref =
                          //                 await SharedPreferences.getInstance();
                          //             sharedPref.setString("leadDescription",
                          //                 value.toString().trim());
                          //           },
                          //           // validator:(value){
                          //           //   if(value.toString().isEmpty){
                          //           //     return "This field is required";
                          //           //   }else if(value.toString().trim().length!=10){
                          //           //     return "Check Your Phone Number";
                          //           //   }else{
                          //           //     return null;
                          //           //   }
                          //           // }
                          //         ),
                          //
                          //       ],
                          //     ),
                          //   ],
                          // ),
                          20.height,
                          CustomLoadingButton(
                              callback: () {
                                if (controllers.leadNameCrt[0].text.isEmpty) {
                                  utils.snackBar(
                                      msg: "Please add name",
                                      color: Colors.red,
                                      context: context);
                                  controllers.leadCtr.reset();
                                } else if (controllers
                                        .leadMobileCrt[0].text.length !=
                                    10) {
                                  utils.snackBar(
                                      msg: "Invalid Mobile Number",
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
                                } else {
                                  apiService.insertSingleCustomer(context);
                                  // if (controllers.leadEmailCrt[0].text.isEmail) {
                                  //   if (controllers.leadCoEmailCrt.text.isEmail) {
                                  //     apiService.insertLeadAPI(context);
                                  //   } else {
                                  //     utils.snackBar(
                                  //         msg: "Invalid Company Email",
                                  //         color: colorsConst.primary,
                                  //         context: context);
                                  //     controllers.leadCtr.reset();
                                  //   }
                                  // } else {
                                  //   utils.snackBar(
                                  //       msg: "Invalid Email",
                                  //       color: colorsConst.primary,
                                  //       context: context);
                                  //   controllers.leadCtr.reset();
                                  // }
                                  // else if(controllers.leadTitleCrt[0].text.isEmpty){
                                  //   utils.snackBar(msg: "Please add title",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadCoNameCrt.text.isEmpty){
                                  //   utils.snackBar(msg: "Please add company name",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadCoMobileCrt.text.length!=10){
                                  //   utils.snackBar(msg: "Invalid Company Mobile Number",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.industry==null){
                                  //   utils.snackBar(msg: "Please add industry",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadProduct.text.isEmpty){
                                  //   utils.snackBar(msg: "Please add product/services",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.pinCode==null){
                                  //   utils.snackBar(msg: "Please add pin code",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.selectedCity.isEmpty){
                                  //   utils.snackBar(msg: "Please add city",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.status==null){
                                  //   utils.snackBar(msg: "Please add status",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else if(controllers.leadOwnerNameCrt.text.isEmpty){
                                  //   utils.snackBar(msg: "Please add lead owner",
                                  //       color: colorsConst.primary,context:context);
                                  //   controllers.leadCtr.reset();
                                  // }else{
                                  //   if(controllers.leadEmailCrt[0].text.isEmail){
                                  //     if(controllers.leadCoEmailCrt.text.isEmail){
                                  //       apiService.insertLeadAPI(context);
                                  //     }else{
                                  //       utils.snackBar(msg: "Invalid Company Email",
                                  //           color: colorsConst.primary,context:context);
                                  //       controllers.leadCtr.reset();
                                  //     }
                                  //
                                  //   }else{
                                  //     utils.snackBar(msg: "Invalid Email",
                                  //         color: colorsConst.primary,context:context);
                                  //     controllers.leadCtr.reset();
                                  //   }
                                }
                              },
                              text: "Save Lead",
                              height: 60,
                              controller: controllers.leadCtr,
                              isLoading: true,
                              textColor: Colors.black,
                              backgroundColor: colorsConst.third,
                              radius: 10,
                              width: 180),
                          50.height,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
