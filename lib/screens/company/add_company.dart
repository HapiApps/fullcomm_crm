import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/constant/default_constant.dart';
import 'package:fullcomm_crm/common/extentions/lib_extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_area_textfield.dart';
import 'package:fullcomm_crm/components/custom_dropdown.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/api.dart';
import '../../common/constant/key_constant.dart';
import '../../components/custom_appbar.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';

class AddCompany extends StatefulWidget {
  const AddCompany({super.key});

  @override
  State<AddCompany> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  Future<void> getStringValue() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    setState(() {
      final companyName = sharedPref.getString("coName") ?? "";
      final companyPhone = sharedPref.getString("coMobile") ?? "";
      final webSite = sharedPref.getString("coWebsite") ?? "";
      final coEmail = sharedPref.getString("coEmail") ?? "";
      final product = sharedPref.getString("coProduct") ?? "";
      final industry = sharedPref.getString("coIndustry");

      final doorNo = sharedPref.getString("coDNo") ?? "";
      final street = sharedPref.getString("coStreet") ?? "";
      final area = sharedPref.getString("coArea") ?? "";
      final pinCode = sharedPref.getString("leadPinCode") ?? "";
      final twitter = sharedPref.getString("coX") ?? "";
      final linkedin = sharedPref.getString("coLinkedin") ?? "";

      controllers.coNameController.text = companyName.toString();
      controllers.coMobileController.text = companyPhone.toString();
      controllers.coWebSiteController.text = webSite.toString();
      controllers.coEmailController.text = coEmail.toString();
      controllers.coProductController.text = product.toString();
      controllers.coIndustry = industry;
      controllers.coDNoController.text = doorNo.toString();
      controllers.coStreetController.text = street.toString();
      controllers.coAreaController.text = area.toString();
      controllers.coPinCodeController.text = pinCode.toString();
      controllers.coXController.text = twitter.toString();
      controllers.coLinkedinController.text = linkedin.toString();
    });
  }

  Future<void> setDefaults() async {
    setState(() => controllers.selectedCountry.value = "India");
    await utils.getStates();

    // setState(() =>controllers.selectedState.value = "Tamil Nadu");
    // await utils.getCities();

    setState(() =>
        controllers.selectedCity.value = controllers.coCityController.text);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStringValue();
    Future.delayed(Duration.zero, () {
      setDefaults();
      utils.getCountries();
      controllers.lng.value = 78.1312452;
    });
  }

  @override
  Widget build(BuildContext context) {
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 3.5;
    return SelectionArea(
      child: Scaffold(
          appBar: const PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: CustomAppbar(
              text: appName,
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
                  // keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,
                  //  controller: scrollController,
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
                          30.height,
                          CustomText(
                            text: "Add Company",
                            colors: colorsConst.primary,
                            size: 23,
                            isBold: true,
                          ),
                          30.height,
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width - 350,
                              height: 1000,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 450,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      20.height,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText(
                                            text: constValue.companyInfo,
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
                                          //         text: "Add social media",
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              CustomTextField(
                                                hintText: "Company Name",
                                                text: "Company Name",
                                                controller: controllers
                                                    .coNameController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .textInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString("coName",
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
                                                hintText: "Company\n Phone No.",
                                                text: "Company\n Phone No.",
                                                controller: controllers
                                                    .coMobileController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
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
                                                      "coMobile",
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
                                                saveValue:
                                                    controllers.coIndustry,
                                                valueList:
                                                    controllers.industryList,
                                                text: "Industry",
                                                width: textFieldSize,

                                                //inputFormatters: constInputFormatters.textInput,
                                                onChanged: (value) async {
                                                  setState(() {
                                                    controllers.coIndustry =
                                                        value;
                                                  });
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "coIndustry",
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
                                              15.height,
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              CustomTextField(
                                                hintText: "Company Email",
                                                text: "Company Email",
                                                controller: controllers
                                                    .coEmailController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .emailInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "coEmail",
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
                                                hintText: "Product/Services",
                                                text: "Product/Services",
                                                controller: controllers
                                                    .coProductController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
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
                                                      "coProduct",
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
                                              100.height,
                                            ],
                                          ),
                                        ],
                                      ),
                                      20.height,
                                      Row(
                                        children: [
                                          CustomText(
                                            text: constValue.addressInfo,
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
                                                hintText: "Door No(Optional)",
                                                text: "Door No(Optional)",
                                                controller:
                                                    controllers.coDNoController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString("coDNo",
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
                                              CustomAreaTextField(
                                                hintText: "Area(Optional)",
                                                text: "Area(Optional)",
                                                controller: controllers
                                                    .coAreaController,
                                                width: textFieldSize,
                                                dNoC:
                                                    controllers.areaController,
                                                streetC: controllers
                                                    .streetNameController,
                                                areaC:
                                                    controllers.areaController,
                                                stateC: controllers.states,
                                                countryC: controllers
                                                    .countryController,
                                                pinCodeC: controllers
                                                    .pinCodeController,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString("coArea",
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
                                              utils.stateDropdown(
                                                  textFieldSize,
                                                  controllers.cityController,
                                                  controllers.stateController,
                                                  controllers
                                                      .countryController),
                                              // CustomDropDown(
                                              //   saveValue: controllers.coState,
                                              //   valueList: controllers.stateList,
                                              //   text:"State",
                                              //   width:textFieldSize,
                                              //   onChanged:(value) async {
                                              //     setState(() {
                                              //       controllers.coState= value;
                                              //     });
                                              //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                              //     sharedPref.setString("leadState", value.toString().trim());
                                              //   },
                                              // ),
                                              20.height,
                                              CustomTextField(
                                                hintText: "PIN",
                                                text: "PIN",
                                                controller: controllers
                                                    .coPinCodeController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .pinCodeInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "coPinCode",
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
                                                hintText: "Street(Optional)",
                                                text: "Street(Optional)",
                                                controller: controllers
                                                    .coStreetController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .addressInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "coStreet",
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
                                              utils.cityDropdown(
                                                textFieldSize,
                                                controllers.cityController,
                                                controllers.stateController,
                                                controllers.countryController,
                                                (value) {
                                                  //print("cityChanged $value $_selectedCity");
                                                  value != null
                                                      ? utils.onSelectedCity(
                                                          value,
                                                          controllers
                                                              .cityController)
                                                      : utils.onSelectedCity(
                                                          controllers
                                                              .selectedCity
                                                              .value,
                                                          controllers
                                                              .cityController);
                                                },
                                              ),
                                              // CustomTextField(
                                              //   hintText:"City",
                                              //   text:"City",
                                              //   controller: controllers.coCityController,
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

                                              20.height,
                                              utils.countryDropdown(
                                                  textFieldSize,
                                                  controllers.coCityController,
                                                  controllers.coStateController,
                                                  controllers
                                                      .coCountryController),
                                              // CustomTextField(
                                              //   hintText:"Country",
                                              //   text:"Country",
                                              //   controller: controllers.coCountryController,
                                              //   width:textFieldSize,
                                              //   keyboardType: TextInputType.text,
                                              //   textInputAction: TextInputAction.next,
                                              //   inputFormatters: constInputFormatters.addressInput,
                                              //   onChanged:(value) async {
                                              //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                              //     sharedPref.setString("leadCountry", value.toString().trim());
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
                                              75.height,
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
                                      20.height,
                                      Row(
                                        children: [
                                          CustomText(
                                            text: constValue.socialInfo,
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
                                                hintText: "Website(Optional)",
                                                text: "Website(Optional)",
                                                controller: controllers
                                                    .coWebSiteController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
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
                                                      "coWebsite",
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
                                                hintText: "X(Optional)",
                                                text: "X(Optional)",
                                                controller:
                                                    controllers.coXController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .socialInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString("coX",
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
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              CustomTextField(
                                                hintText: "Linkedin(Optional)",
                                                text: "Linkedin(Optional)",
                                                controller: controllers
                                                    .coLinkedinController,
                                                width: textFieldSize,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                inputFormatters:
                                                    constInputFormatters
                                                        .socialInput,
                                                onChanged: (value) async {
                                                  SharedPreferences sharedPref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  sharedPref.setString(
                                                      "coLinkedin",
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
                                              80.height,
                                            ],
                                          ),
                                        ],
                                      ),
                                      20.height,
                                      CustomLoadingButton(
                                          callback: () {
                                            if (controllers.coNameController
                                                .text.isEmpty) {
                                              utils.snackBar(
                                                  msg:
                                                      "Please add company name",
                                                  color: colorsConst.primary,
                                                  context: Get.context!);
                                              controllers.leadCtr.reset();
                                            } else if (controllers
                                                    .coMobileController
                                                    .text
                                                    .length !=
                                                10) {
                                              utils.snackBar(
                                                  msg:
                                                      "Invalid Company Mobile Number",
                                                  color: colorsConst.primary,
                                                  context: Get.context!);
                                              controllers.leadCtr.reset();
                                            } else if (controllers.coIndustry ==
                                                null) {
                                              utils.snackBar(
                                                  msg:
                                                      "Please add company industry",
                                                  color: colorsConst.primary,
                                                  context: Get.context!);
                                              controllers.leadCtr.reset();
                                            } else if (controllers
                                                .coProductController
                                                .text
                                                .isEmpty) {
                                              utils.snackBar(
                                                  msg:
                                                      "Please add product/services",
                                                  color: colorsConst.primary,
                                                  context: Get.context!);
                                              controllers.leadCtr.reset();
                                            } else if (controllers
                                                .coPinCodeController
                                                .text
                                                .isEmpty) {
                                              utils.snackBar(
                                                  msg: "Please add pin code",
                                                  color: colorsConst.primary,
                                                  context: Get.context!);
                                              controllers.leadCtr.reset();
                                            } else if (controllers
                                                .selectedCity.isEmpty) {
                                              utils.snackBar(
                                                  msg: "Please add city",
                                                  color: colorsConst.primary,
                                                  context: Get.context!);
                                              controllers.leadCtr.reset();
                                            } else {
                                              if (controllers.coEmailController
                                                  .text.isEmail) {
                                                apiService
                                                    .insertCompanyAPI(context);
                                              } else {
                                                utils.snackBar(
                                                    msg:
                                                        "Invalid Company Email",
                                                    color: colorsConst.primary,
                                                    context: Get.context!);
                                                controllers.leadCtr.reset();
                                              }
                                            }
                                          },
                                          text: "Save Company",
                                          height: 60,
                                          controller: controllers.leadCtr,
                                          isLoading: true,
                                          backgroundColor: colorsConst.primary,
                                          radius: 10,
                                          width: 180),
                                      50.height,
                                    ],
                                  ),
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
