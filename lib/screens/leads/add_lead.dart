///NEW LEAD PAGE
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
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
import '../../components/custom_appbar.dart';
import '../../components/custom_date_box.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';
import '../../models/new_lead_obj.dart';

class AddLead extends StatefulWidget {
  final RxList<NewLeadObj> list;
  final RxList<NewLeadObj> list2;
  const AddLead({super.key, required this.list, required this.list2});

  @override
  State<AddLead> createState() => _AddLeadState();
}

class _AddLeadState extends State<AddLead> {
  List<FocusNode> phoneFocusList = [];
  List<bool> checkList = [];
  List<FocusNode> phoneFocusList2 = [];
  void getStringValue()  {
    Future.delayed(Duration.zero, () {
      setState(() {
        controllers.visitType="Call";
        controllers.throughBy.clear();
        controllers.numberList.clear();
        controllers.infoNumberList.clear();
        controllers.numberList.add(TextEditingController());
        phoneFocusList.add(FocusNode());
        checkList.add(false);
        phoneFocusList2.add(FocusNode());
        controllers.infoNumberList.add(TextEditingController());
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
        controllers.empDOB.value =DateFormat('dd-MM-yyyy').format(DateTime.now());
        controllers.exDate.value = "";
        controllers.prospectDate.value = "";
        for (int i = 0;
        i < controllers.leadPersonalItems.value;
        i++) {
          controllers.leadNameCrt[i].text = "";
          controllers.leadMobileCrt[i].text = "";
          controllers.leadEmailCrt[i].text = "";
          controllers.leadTitleCrt[i].text = "";
          controllers.leadWhatsCrt[i].text = "";
          controllers.isCoMobileNumberList[i] = false;
        }
        controllers.selectedCountry.value = "India";
        controllers.selectedState.value = "Tamil Nadu";
      });
    });
  }
  String _formatHeading(String heading) {
    String cleaned = heading.replaceAll(",", "").trim();
    return cleaned
        .split(" ")
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : "")
        .join(" ");
  }
  //santhiya2
  final FocusNode name = FocusNode();
  final FocusNode phone = FocusNode();
  final FocusNode whatsApp = FocusNode();
  final FocusNode account = FocusNode();
  final FocusNode email = FocusNode();
  final FocusNode date = FocusNode();
  final FocusNode cName = FocusNode();
  final FocusNode cNo = FocusNode();
  final FocusNode linkedin = FocusNode();
  final FocusNode cEmail = FocusNode();
  final FocusNode cProduct = FocusNode();
  final FocusNode cServices = FocusNode();
  final FocusNode website = FocusNode();
  final FocusNode cX = FocusNode();

  final FocusNode ob1 = FocusNode();
  final FocusNode ob2 = FocusNode();
  final FocusNode ob3 = FocusNode();
  final FocusNode ob4 = FocusNode();
  final FocusNode ob5 = FocusNode();
  final FocusNode ob6 = FocusNode();
  final FocusNode ob7 = FocusNode();
  final FocusNode ob8 = FocusNode();
  final FocusNode ob9 = FocusNode();

  final FocusNode door = FocusNode();
  final FocusNode area = FocusNode();
  final FocusNode city = FocusNode();
  final FocusNode state = FocusNode();
  final FocusNode pincode = FocusNode();
  final FocusNode throughByF = FocusNode();
  final FocusNode ins = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(name);
    });
    getStringValue();
  }
  @override
  void dispose() {
    ins.dispose();
    name.dispose();
    throughByF.dispose();
    phone.dispose();
    whatsApp.dispose();
    account.dispose();
    email.dispose();
    date.dispose();
    cName.dispose();
    cNo.dispose();
    linkedin.dispose();
    cEmail.dispose();
    cProduct.dispose();
    cServices.dispose();
    website.dispose();
    cX.dispose();

    ob1.dispose();
    ob2.dispose();
    ob3.dispose();
    ob4.dispose();
    ob5.dispose();
    ob6.dispose();
    ob7.dispose();
    ob8.dispose();
    ob9.dispose();

    door.dispose();
    area.dispose();
    city.dispose();
    state.dispose();
    pincode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 1.8;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Row(children: [
      SideBar(),
      20.width,
      Container(
          width: controllers.isLeftOpen.value==true?screenWidth-200:screenWidth-60,
          alignment: Alignment.center,
          child: Column(
            children: [
              CustomAppbar(text:"New Leads - ${controllers.leadCategoryList[0].value}",
                subText: "Add your ${controllers.leadCategoryList[0].value} Information",
                actionsWidget: Row(
                  children: [
                    CustomLoadingButton(
                        callback: () {
                          setState(() {
                            controllers.visitType="Call";
                            controllers.numberList.clear();
                            phoneFocusList.clear();
                            checkList.clear();
                            phoneFocusList2.clear();
                            controllers.infoNumberList.clear();
                            controllers.numberList.add(TextEditingController());
                            controllers.infoNumberList.add(TextEditingController());
                            phoneFocusList.add(FocusNode());
                            checkList.add(false);
                            phoneFocusList2.add(FocusNode());
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
                            controllers.visitType = "Call";
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
                            for (int i = 0;
                            i < controllers.leadPersonalItems.value;
                            i++) {
                              controllers.leadNameCrt[i].text = "";
                              controllers.leadMobileCrt[i].text = "";
                              controllers.leadEmailCrt[i].text = "";
                              controllers.leadTitleCrt[i].text = "";
                              controllers.leadWhatsCrt[i].text = "";
                              controllers.isCoMobileNumberList[i] = false;
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

                        bool isMistake = false;
                        Set<String> uniqueNumbers = {};
                        bool isMistake2 = false;
                        Set<String> uniqueNumbers2 = {};
                        for (var i = 0; i < controllers.numberList.length; i++) {
                          String number = controllers.numberList[i].text.trim();
                          if (number.isEmpty || number.length != 10) {
                            isMistake = true;
                            utils.snackBar(
                              context: context,
                              msg: "Enter valid 10 digit ${_formatHeading(
                                  controllers.getUserHeading(
                                      "mobile_name") ??
                                      "Mobile No")}",
                              color: Colors.red,
                            );
                            break;
                          }
                          if (uniqueNumbers.contains(number)) {
                            isMistake = true;
                            utils.snackBar(
                              context: context,
                              msg: "Same ${_formatHeading(
                                  controllers.getUserHeading(
                                      "mobile_name") ??
                                      "Mobile No")} already added",
                              color: Colors.red,
                            );
                            break;
                          }
                          uniqueNumbers.add(number);
                        }
                        if (isMistake) {
                          controllers.leadCtr.reset();
                          return;
                        }
                        if(controllers.infoNumberList[0].text.isNotEmpty){
                          for (var i = 0; i < controllers.infoNumberList.length; i++) {
                            String number = controllers.infoNumberList[i].text.trim();
                            if (number.isEmpty || number.length != 10) {
                              isMistake2 = true;
                              utils.snackBar(
                                context: context,
                                msg: "Enter valid 10 digit mobile number",
                                color: Colors.red,
                              );
                              break;
                            }
                            if (uniqueNumbers2.contains(number)) {
                              isMistake2 = true;
                              utils.snackBar(
                                context: context,
                                msg: "Same company phone number already added",
                                color: Colors.red,
                              );
                              break;
                            }
                            uniqueNumbers2.add(number);
                          }
                          if (isMistake2) {
                            controllers.leadCtr.reset();
                            return;
                          }
                        }
                        if (controllers.leadLinkedinCrt.text.trim().isNotEmpty&&!utils.isValidLinkedInId(controllers.leadLinkedinCrt.text.trim())) {
                          utils.snackBar(
                            context: context,
                            msg: "Enter valid LinkedIn ID",
                            color: Colors.red,
                          );
                          controllers.leadCtr.reset();
                          return;
                        }
                        if (controllers.leadWebsite.text.trim().isNotEmpty&&!utils.validateWebsite(controllers.leadWebsite.text.trim())) {
                          utils.snackBar(
                            context: context,
                            msg: "Enter valid Website",
                            color: Colors.red,
                          );
                          controllers.leadCtr.reset();
                          return;
                        }
                        if (controllers.leadXCrt.text.trim().isNotEmpty&&!utils.isValidXId(controllers.leadXCrt.text.trim())) {
                          utils.snackBar(
                            context: context,
                            msg: "Enter valid X ID",
                            color: Colors.red,
                          );
                          controllers.leadCtr.reset();
                          return;
                        }

                        if (controllers.leadNameCrt[0].text.isEmpty) {
                          utils.snackBar(
                              msg: "Please add ${_formatHeading(
                                  controllers.getUserHeading(
                                      "name") ??
                                      "Name")}",
                              color: Colors.red,
                              context: context);
                          controllers.leadCtr.reset();
                        }
                        else if (controllers
                            .leadWhatsCrt[0].text.isNotEmpty &&
                            controllers.leadWhatsCrt[0].text.length != 10) {
                          utils.snackBar(
                              msg: "Invalid WhatsApp No",
                              color: Colors.red,
                              context: context);
                          controllers.leadCtr.reset();
                        } else if (controllers.visitType == null ||
                            controllers.visitType.toString().isEmpty) {
                          utils.snackBar(
                              msg: "Please Select Incoming Source",
                              color: Colors.red,
                              context: context);
                          controllers.leadCtr.reset();
                        } else if (controllers
                            .leadWhatsCrt[0].text.isNotEmpty &&
                            controllers.leadWhatsCrt[0].text.length != 10) {
                          utils.snackBar(
                              msg: "Invalid Whats No",
                              color: Colors.red,
                              context: context);
                          controllers.leadCtr.reset();
                        }
                        else if (controllers.leadCoEmailCrt.text.isNotEmpty &&
                            !controllers.leadCoEmailCrt.text.isEmail) {
                          utils.snackBar(
                              msg: "Please add valid Company Email",
                              color: Colors.red,
                              context: context);
                          controllers.leadCtr.reset();
                        } else {
                          if (controllers.leadEmailCrt[0].text.isNotEmpty) {
                            if (controllers.leadEmailCrt[0].text.isEmail) {
                              if (controllers.pinCodeController.text.isEmpty) {
                                apiService.insertSingleCustomer(context,widget.list,widget.list2);
                              } else {
                                if (controllers.pinCodeController.text.length ==
                                    6) {
                                  apiService.insertSingleCustomer(context,widget.list,widget.list2);
                                } else {
                                  utils.snackBar(
                                      msg: "Please add 6 digits pin code",
                                      color: Colors.red,
                                      context: context);
                                  controllers.leadCtr.reset();
                                }
                              }
                            } else {
                              ///Santhiya
                              utils.snackBar(
                                  msg: "Please add valid email",
                                  color: Colors.red,
                                  context: context);
                              controllers.leadCtr.reset();
                            }
                          } else {
                            if (controllers.pinCodeController.text.isEmpty) {
                              apiService.insertSingleCustomer(context,widget.list,widget.list2);
                            } else {
                              if (controllers.pinCodeController.text.length ==
                                  6) {
                                apiService.insertSingleCustomer(context,widget.list,widget.list2);
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
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 180,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(children: [
                    Obx(
                      () => ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controllers.leadPersonalItems.value,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    index == 0
                                        ? CustomText(
                                            text: "New Lead Information",
                                            colors: colorsConst.textColor,
                                            size: 20,
                                            isCopy: true,
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
                                              selectedTextStyle:
                                                  customStyle.textStyle(
                                                      colors: colorsConst.third,
                                                      size: 16,
                                                      isBold: true),
                                              selectedBorderColor:
                                                  Colors.transparent,
                                              selectedColor: Colors.transparent,
                                              unselectedBorderColor:
                                                  Colors.transparent,
                                              unselectedColor: Colors.transparent,
                                              unselectedTextStyle:
                                                  customStyle.textStyle(
                                                      colors:
                                                          colorsConst.textColor,
                                                      size: 16,
                                                      isBold: true),
                                            ),
                                            onSelected:
                                                (name, index, isSelected) async {
                                              setState(() {
                                                controllers.leadCategory = name;
                                              });
                                            },
                                            buttons:
                                                controllers.leadCategoryGrList,
                                          )
                                        : 0.width,
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
                                              controllers.isMainPersonList.remove(
                                                  controllers.leadPersonalItems);
                                              controllers.isCoMobileNumberList
                                                  .remove(controllers
                                                      .leadPersonalItems);
                                              controllers.leadPersonalItems--;

                                              controllers.leadNameCrt
                                                  .removeAt(index);
                                              controllers.leadMobileCrt
                                                  .removeAt(index);
                                              controllers.leadTitleCrt
                                                  .removeAt(index);
                                              controllers.leadEmailCrt
                                                  .removeAt(index);

                                              SharedPreferences sharedPref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              sharedPref.setInt(
                                                  "leadCount",
                                                  controllers
                                                      .leadPersonalItems.value);
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          hintText: _formatHeading(
                                              controllers.getUserHeading(
                                                  "name") ??
                                                  "Name"),
                                          focusNode: name,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(phoneFocusList.last);
                                          },
                                          text: _formatHeading(
                                              controllers.getUserHeading(
                                                  "name") ??
                                                  "Name"),
                                          isOptional: true,
                                          controller:
                                              controllers.leadNameCrt[index],
                                          width: textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          inputFormatters:
                                              constInputFormatters.textInput,
                                          onChanged: (value) async {
                                            if (value.toString().isNotEmpty) {
                                              String newValue = value
                                                      .toString()[0]
                                                      .toUpperCase() +
                                                  value.toString().substring(1);
                                              if (newValue != value) {
                                                controllers.leadNameCrt[index]
                                                        .value =
                                                    controllers
                                                        .leadNameCrt[index].value
                                                        .copyWith(
                                                  text: newValue,
                                                  selection:
                                                      TextSelection.collapsed(
                                                          offset:
                                                              newValue.length),
                                                );
                                              }
                                            }
                                            SharedPreferences sharedPref =
                                                await SharedPreferences
                                                    .getInstance();
                                            sharedPref.setString("leadName$index",
                                                value.toString().trim());
                                          },
                                        ),
                                        Obx((){
                                          return SizedBox(
                                            width: textFieldSize,
                                            child: ListView.builder(
                                                shrinkWrap:true,
                                                reverse: true,
                                                itemCount:controllers.numberList.length,
                                                itemBuilder: (context,index){
                                                  return Column(
                                                      children:[
                                                        if(index==controllers.numberList.length-1)
                                                          Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                CustomText(text: _formatHeading(
                                                                    controllers.getUserHeading(
                                                                        "mobile_name") ??
                                                                        "Mobile No"), isCopy: false),
                                                                CustomText(text: "*",size: 18,colors: Colors.red, isCopy: false),
                                                              ],
                                                            ),
                                                            InkWell(
                                                                onTap: () {
                                                                  bool isMistake = false;
                                                                  Set<String> uniqueNumbers = {};

                                                                  for (var i = 0; i < controllers.numberList.length; i++) {
                                                                    String number = controllers.numberList[i].text.trim();

                                                                    // Empty or not 10 digits
                                                                    if (number.isEmpty || number.length != 10) {
                                                                      isMistake = true;
                                                                      utils.snackBar(
                                                                        context: context,
                                                                        msg: "Enter valid 10 digit ${_formatHeading(
                                                                            controllers.getUserHeading(
                                                                                "mobile_name") ??
                                                                                "Mobile No")}",
                                                                        color: Colors.red,
                                                                      );
                                                                      break;
                                                                    }

                                                                    // Duplicate check
                                                                    if (uniqueNumbers.contains(number)) {
                                                                      isMistake = true;
                                                                      utils.snackBar(
                                                                        context: context,
                                                                        msg: "Same ${_formatHeading(
                                                                            controllers.getUserHeading(
                                                                                "mobile_name") ??
                                                                                "Mobile No")} already added",
                                                                        color: Colors.red,
                                                                      );
                                                                      break;
                                                                    }

                                                                    uniqueNumbers.add(number);
                                                                  }

                                                                  if (!isMistake) {
                                                                    controllers.numberList.add(TextEditingController());
                                                                    phoneFocusList.add(FocusNode());
                                                                    checkList.add(false);
                                                                    FocusScope.of(context).requestFocus(phoneFocusList.last);
                                                                    controllers.update();
                                                                  }
                                                                },
                                                                child: Icon(Icons.add),
                                                              ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children:[
                                                              SizedBox(
                                                                width: textFieldSize-40,
                                                                child: TextFormField(
                                                                  controller:controllers.numberList[index],
                                                                  focusNode: phoneFocusList[index],
                                                                  style: const TextStyle(
                                                                    color: Colors.black,
                                                                    fontSize: 15,
                                                                    fontFamily: "Lato",
                                                                  ),
                                                                  cursorColor: colorsConst.primary,
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      if(checkList[index]==true){
                                                                        controllers.leadWhatsCrt[0].text =controllers.numberList[index].text;
                                                                      }
                                                                    });
                                                                  },
                                                                  onEditingComplete: () {
                                                                    FocusScope.of(context)
                                                                        .requestFocus(whatsApp);
                                                                  },
                                                                  inputFormatters: constInputFormatters.mobileNumberInput,
                                                                  textInputAction: TextInputAction.next,
                                                                  decoration: InputDecoration(
                                                                    hoverColor: Colors.transparent,
                                                                    focusColor: Colors.transparent,
                                                                    hintText:_formatHeading(
                                                                        controllers.getUserHeading(
                                                                            "mobile_name") ??
                                                                            "Mobile No"),
                                                                    errorStyle: TextStyle(color: Colors.red, fontSize: 13, fontFamily: "Lato"),
                                                                    hintStyle: TextStyle(
                                                                        color: Colors.grey.shade400, fontSize: 13, fontFamily: "Lato"),
                                                                    fillColor:Colors.white,
                                                                    filled: true,
                                                                    suffixIcon: InkWell(
                                                                        onTap: () {
                                                                          setState(() {
                                                                            bool newValue = !checkList[index];
                                                                            for (int i = 0; i < checkList.length; i++) {
                                                                              checkList[i] = false;
                                                                            }
                                                                            checkList[index] = newValue;
                                                                            if (newValue) {
                                                                              controllers.leadWhatsCrt[0].text =
                                                                                  controllers.numberList[index].text;
                                                                            } else {
                                                                              controllers.leadWhatsCrt[0].clear();
                                                                            }
                                                                          });
                                                                        },
                                                                        child: Icon(Icons.check_circle, color: checkList[index]==false?Colors.grey:Colors.green)),
                                                                    enabledBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: Colors.grey.shade400,
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(5)),
                                                                    focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                          color: colorsConst.primary,
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(5)),
                                                                    focusedErrorBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: const Color(0xffE1E5FA)),
                                                                        borderRadius: BorderRadius.circular(5)),
                                                                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                                    errorBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: const Color(0xffE1E5FA)),
                                                                        borderRadius: BorderRadius.circular(5)),
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                  onTap:(){
                                                                    if (controllers.numberList.length > 1) {
                                                                      controllers.numberList.removeAt(index);
                                                                      phoneFocusList[index].dispose();
                                                                      phoneFocusList.removeAt(index);
                                                                      checkList.removeAt(index);
                                                                      controllers.update();
                                                                    }else{
                                                                      utils.snackBar(context: context, msg: "Enter at least one ${_formatHeading(
                                                                          controllers.getUserHeading(
                                                                              "mobile_name") ??
                                                                              "Mobile No")}", color: Colors.red);
                                                                    }
                                                                  },
                                                                  child:SvgPicture.asset("assets/images/delete.svg",width: 20,height: 20,)
                                                              )
                                                            ]
                                                        ),5.height
                                                      ]
                                                  );
                                                }),
                                          );
                                        }),10.height,
                                        CustomTextField(
                                          onEdit: () {
                                            FocusScope.of(context)
                                                .requestFocus(account);
                                          },
                                          focusNode: whatsApp,
                                          hintText: "Whatsapp No",
                                          text: "Whatsapp",
                                          controller:
                                              controllers.leadWhatsCrt[index],
                                          width: textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters
                                              .mobileNumberInput,
                                          onChanged: (value) async {
                                            SharedPreferences sharedPref =
                                                await SharedPreferences
                                                    .getInstance();
                                            sharedPref.setString(
                                                "leadWhats$index",
                                                value.toString().trim());
                                          },
                                        ),
                                        SizedBox(
                                          width: textFieldSize,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CustomText(
                                                    text: "Incoming Source",
                                                    colors: colorsConst.textColor,
                                                    size: 13,
                                                    textAlign: TextAlign.start,
                                                    isCopy: false,
                                                  ),
                                                  const CustomText(
                                                    text: "*",
                                                    colors: Colors.red,
                                                    size: 25,
                                                    isCopy: false,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          onEdit: () {
                                            FocusScope.of(context)
                                                .requestFocus(email);
                                          },
                                          focusNode: account,
                                          hintText: _formatHeading(
                                              controllers.getUserHeading(
                                                  "owner") ??
                                                  "Account Manager"),
                                          text: _formatHeading(
                                              controllers.getUserHeading(
                                                  "owner") ??
                                                  "Account Manager"),
                                          controller:
                                              controllers.leadTitleCrt[index],
                                          width: textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters:
                                              constInputFormatters.textInput,
                                          isOptional: false,
                                          onChanged: (value) async {
                                            if (value.toString().isNotEmpty) {
                                              String newValue = value
                                                      .toString()[0]
                                                      .toUpperCase() +
                                                  value.toString().substring(1);
                                              if (newValue != value) {
                                                controllers.leadTitleCrt[index]
                                                        .value =
                                                    controllers
                                                        .leadTitleCrt[index].value
                                                        .copyWith(
                                                  text: newValue,
                                                  selection:
                                                      TextSelection.collapsed(
                                                          offset:
                                                              newValue.length),
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
                                        ),
                                        CustomTextField(
                                            focusNode: email,
                                            hintText: _formatHeading(
                                                controllers.getUserHeading(
                                                    "email") ??
                                                    "Email id"),
                                            text: _formatHeading(
                                                controllers.getUserHeading(
                                                    "email") ??
                                                    "Email id"),
                                            controller:
                                                controllers.leadEmailCrt[index],
                                            width: textFieldSize,
                                            keyboardType: TextInputType.text,
                                            textInputAction: TextInputAction.next,
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
                                            onFieldSubmitted: (value) {
                                              utils.datePicker(
                                                  isFutureDate: false,
                                                  context: context,
                                                  textEditingController:
                                                      controllers.dateOfConCtr,
                                                  pathVal: controllers.empDOB);
                                              FocusScope.of(context)
                                                  .requestFocus(cName);
                                            }
                                            ),
                                        Obx(
                                          () => CustomDateBox(
                                            text: "Date of Connection",
                                            value: controllers.empDOB.value,
                                            width: textFieldSize,
                                            isOptional: false,
                                            onTap: () {
                                              utils.datePicker(
                                                  isFutureDate: false,
                                                  context: context,
                                                  textEditingController:
                                                      controllers.dateOfConCtr,
                                                  pathVal: controllers.empDOB);
                                              FocusScope.of(context)
                                                  .requestFocus(cName);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: (controllers.callNameList)
                                      .map<Widget>((type) {
                                    return Row(
                                      children: [
                                        Radio<String>(
                                          value: type,
                                          groupValue: controllers.visitType,
                                          activeColor: colorsConst.primary,
                                          onChanged: (value) async{
                                            setState(() {
                                              controllers.visitType = value;
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                  account);
                                            });
                                            SharedPreferences sharedPref =
                                            await SharedPreferences
                                                .getInstance();
                                            sharedPref.setString("callVisitType",
                                                value.toString().trim());
                                          },
                                        ),
                                        CustomText(
                                          text: type,
                                          size: 14,
                                          isCopy: false,
                                        ),
                                        20.width,
                                      ],
                                    );
                                  }).toList(),
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
                          isCopy: false,
                        ),
                      ],
                    ), //Todo:Company details
                    10.height,
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                    ),
                    20.height,
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(phoneFocusList2.last);
                                },
                                focusNode: cName,
                                hintText: _formatHeading(controllers.getUserHeading
                                  ("company_name") ?? "Company Name"),
                                text: _formatHeading(controllers.getUserHeading
                                  ("company_name") ?? "Company Name"),
                                controller: controllers.leadCoNameCrt,
                                width: textFieldSize,
                                textInputAction: TextInputAction.next,
                                isOptional: false,
                                inputFormatters: constInputFormatters.textInput,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue =
                                        value.toString()[0].toUpperCase() +
                                            value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.leadCoNameCrt.value =
                                          controllers.leadCoNameCrt.value
                                              .copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(
                                            offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadCoName", value.toString().trim());
                                },
                              ),
                              Obx((){
                                return SizedBox(
                                  width: textFieldSize,
                                  child: ListView.builder(
                                      shrinkWrap:true,
                                      itemCount:controllers.infoNumberList.length,
                                      reverse: true,
                                      itemBuilder: (context,index){
                                        return Column(
                                            children:[
                                              if(index==controllers.infoNumberList.length-1)
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomText(text: "Company Phone No", isCopy: false),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        bool isMistake = false;
                                                        Set<String> uniqueNumbers = {};

                                                        for (var i = 0; i < controllers.infoNumberList.length; i++) {
                                                          String number = controllers.infoNumberList[i].text.trim();

                                                          // Empty or not 10 digits
                                                          if (number.isEmpty || number.length != 10) {
                                                            isMistake = true;
                                                            utils.snackBar(
                                                              context: context,
                                                              msg: "Enter valid 10 digit mobile number",
                                                              color: Colors.red,
                                                            );
                                                            break;
                                                          }

                                                          // Duplicate check
                                                          if (uniqueNumbers.contains(number)) {
                                                            isMistake = true;
                                                            utils.snackBar(
                                                              context: context,
                                                              msg: "Same company phone number already added",
                                                              color: Colors.red,
                                                            );
                                                            break;
                                                          }

                                                          uniqueNumbers.add(number);
                                                        }

                                                        if (!isMistake) {
                                                          controllers.infoNumberList.add(TextEditingController());
                                                          phoneFocusList2.add(FocusNode());
                                                          FocusScope.of(context).requestFocus(phoneFocusList2.last);
                                                          controllers.update();
                                                        }
                                                      },
                                                      child: Icon(Icons.add),
                                                    ),
                                                  ],
                                                ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children:[
                                                    SizedBox(
                                                      width: textFieldSize-40,
                                                      child: CustomTextField(
                                                        focusNode: phoneFocusList2[index],
                                                        onEdit: () {
                                                          FocusScope.of(context).requestFocus(linkedin);
                                                        },
                                                        hintText: "",
                                                        text: "",
                                                        controller: controllers.infoNumberList[index],
                                                        width: textFieldSize,
                                                        keyboardType: TextInputType.number,
                                                        textInputAction: TextInputAction.next,
                                                        isOptional: true,
                                                        inputFormatters: constInputFormatters.mobileNumberInput,
                                                        onChanged: (value) async {
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                        onTap:(){
                                                          if (controllers.infoNumberList.length > 1) {
                                                            controllers.infoNumberList.removeAt(index);
                                                            phoneFocusList2[index].dispose();
                                                            phoneFocusList2.removeAt(index);
                                                            controllers.update();
                                                          }else{
                                                            utils.snackBar(context: context, msg: "Enter at least one mobile number.", color: Colors.red);
                                                          }
                                                        },
                                                        child:SvgPicture.asset("assets/images/delete.svg",width: 20,height: 20,)
                                                    )
                                                  ]
                                              ),5.height
                                            ]
                                        );
                                      }),
                                );
                              }),10.height,
                              Obx(()=>controllers.refreshValue.value==false?
                              CircularProgressIndicator():
                              IndustryDropdown(
                                width: textFieldSize,
                                items: controllers.industriesList,
                                onChanged: (val) {
                                  setState(() {
                                    controllers.industry = val?['value'];
                                  });
                                },
                                onAdd: () {
                                  FocusScope.of(context).requestFocus(ins);
                                  controllers.industryValueCtr.clear();
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        title: const CustomText(
                                          text:"Add New Industry",isCopy: false,isBold: true,
                                        ),
                                        content: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 150, // 👈 adjust here
                                            minHeight: 100,
                                          ),
                                          child: SizedBox(
                                            width: 350,
                                            child: CustomTextField(
                                              focusNode: ins,
                                              hintText: "Industry",
                                              text: "Industry",
                                              controller: controllers.industryValueCtr,
                                              width: textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction: TextInputAction.done,
                                              isOptional: true,
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 120,
                                                height: 40,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      minimumSize: const Size.fromHeight(40),
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5),
                                                          side: BorderSide(color: colorsConst.third))),
                                                  onPressed: () {
                                                    controllers.industryValueCtr.clear();
                                                    Navigator.pop(context);
                                                  },
                                                  child: CustomText(
                                                    text: "Cancel",
                                                    isBold: true,
                                                    size: 15,
                                                    colors: colorsConst.third,
                                                    isCopy: false,
                                                  ),
                                                ),
                                              ),
                                              CustomLoadingButton(
                                                callback: () {
                                                  if (controllers.industryValueCtr.text.trim().isNotEmpty) {
                                                    controllers.insertIndustries(context);
                                                  } else {
                                                    controllers.productCtr.reset();
                                                    utils.showToast("Please enter industry value",Colors.red);
                                                  }
                                                },
                                                controller: controllers.productCtr,
                                                isImage: false,
                                                isLoading: true,
                                                backgroundColor: colorsConst.primary,
                                                radius: 5,
                                                width: 90,
                                                height: 45,
                                                text: "Save",
                                                textColor: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )),
                              CustomTextField(
                                focusNode: linkedin,
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(cEmail);
                                },
                                hintText: "Linkedin (Optional)",
                                text: "Linkedin (Optional)",
                                controller: controllers.leadLinkedinCrt,
                                width: textFieldSize,
                                keyboardType: TextInputType.text,
                                isOptional: false,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.socialInput,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              onEdit: () {
                                FocusScope.of(context).requestFocus(cServices);
                              },
                              focusNode: cEmail,
                              hintText: "Company Email",
                              text: "Company Email",
                              controller: controllers.leadCoEmailCrt,
                              width: textFieldSize,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              isOptional: false,
                              inputFormatters: constInputFormatters.emailInput,
                              onChanged: (value) async {
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString(
                                    "leadCoEmail", value.toString().trim());
                              },
                            ),
                            CustomTextField(
                              focusNode: cServices,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(website);
                              },
                              hintText: "Product/Services (Optional)",
                              text: "Product/Services (Optional)",
                              controller: controllers.leadProduct,
                              width: textFieldSize,
                              textInputAction: TextInputAction.next,
                              isOptional: false,
                              onChanged: (value) async {
                                if (value.toString().isNotEmpty) {
                                  String newValue =
                                      value.toString()[0].toUpperCase() +
                                          value.toString().substring(1);
                                  if (newValue != value) {
                                    controllers.leadProduct.value =
                                        controllers.leadProduct.value.copyWith(
                                      text: newValue,
                                      selection: TextSelection.collapsed(
                                          offset: newValue.length),
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
                              focusNode: website,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(cX);
                              },
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
                            ),
                            CustomTextField(
                              focusNode: cX,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(ob1);
                              },
                              hintText: "X (Optional)",
                              text: "X (Optional)",
                              controller: controllers.leadXCrt,
                              width: textFieldSize,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              isOptional: false,
                              inputFormatters: constInputFormatters.socialInput,
                              onChanged: (value) async {
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString(
                                    "leadX", value.toString().trim());
                              },
                            ),
                          ],
                        ),
                      ],
                    ), //Todo:Company details
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "Observations (Optional)",
                          colors: colorsConst.textColor,
                          size: 20,
                          isCopy: false,
                        ),
                      ],
                    ), //Todo:Observation
                    10.height,
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                    ),
                    20.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                focusNode: ob1,
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(ob2);
                                },
                                hintText: "Actions to be taken",
                                text: "Actions to be taken",
                                controller: controllers.leadActions,
                                width: textFieldSize,
                                isOptional: false,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.textInput,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue =
                                        value.toString()[0].toUpperCase() +
                                            value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.leadActions.value =
                                          controllers.leadActions.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(
                                            offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadActions", value.toString().trim());
                                },
                              ),
                              CustomTextField(
                                focusNode: ob2,
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(ob3);
                                },
                                hintText: _formatHeading(controllers
                                    .getUserHeading("source") ??
                                    "SOURCE OF PROSPECT"),
                                text: _formatHeading(controllers
                                    .getUserHeading("source") ??
                                    "SOURCE OF PROSPECT"),
                                controller: controllers.leadDisPointsCrt,
                                width: textFieldSize,
                                isOptional: false,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue =
                                        value.toString()[0].toUpperCase() +
                                            value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.leadDisPointsCrt.value =
                                          controllers.leadDisPointsCrt.value
                                              .copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(
                                            offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadDisPoints", value.toString().trim());
                                },
                                // }
                              ),
                              CustomTextField(
                                focusNode: ob3,
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(ob4);
                                },
                                hintText: _formatHeading(controllers
                                    .getUserHeading(
                                    "product_discussion") ??
                                    "Product Discussed"),
                                text: _formatHeading(controllers
                                    .getUserHeading(
                                    "product_discussion") ??
                                    "Product Discussed"),
                                controller: controllers.prodDescriptionController,
                                width: textFieldSize,
                                isOptional: false,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue =
                                        value.toString()[0].toUpperCase() +
                                            value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers
                                              .prodDescriptionController.value =
                                          controllers
                                              .prodDescriptionController.value
                                              .copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(
                                            offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadProdDis", value.toString().trim());
                                },
                                // }
                              ),
                              CustomTextField(
                                focusNode: ob4,
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(ob5);
                                },
                                hintText: _formatHeading(controllers
                                    .getUserHeading(
                                    "expected_billing_value") ??
                                    "Expected Monthly Billing Value"),
                                text: _formatHeading(controllers
                                    .getUserHeading(
                                    "expected_billing_value") ??
                                    "Expected Monthly Billing Value"),
                                controller: controllers.exMonthBillingValCrt,
                                width: textFieldSize,
                                isOptional: false,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue =
                                        value.toString()[0].toUpperCase() +
                                            value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.exMonthBillingValCrt.value =
                                          controllers.exMonthBillingValCrt.value
                                              .copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(
                                            offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  sharedPref.setString("leadExMonthBillingVal",
                                      value.toString().trim());
                                },
                              ),
                              CustomTextField(
                                focusNode: ob5,
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(ob6);
                                },
                                hintText: "ARPU Value",
                                text: "ARPU Value",
                                controller: controllers.arpuCrt,
                                width: textFieldSize,
                                isOptional: false,
                                textInputAction: TextInputAction.next,
                                inputFormatters: constInputFormatters.numberInput,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue =
                                        value.toString()[0].toUpperCase() +
                                            value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.arpuCrt.value =
                                          controllers.arpuCrt.value.copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(
                                            offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadARPU", value.toString().trim());
                                },
                              ),
                              CustomTextField(
                                focusNode: ob6,
                                onEdit: () {
                                  FocusScope.of(context).requestFocus(ob7);
                                },
                                hintText: _formatHeading(controllers
                                    .getUserHeading("rating") ??
                                    "Prospect Grading"),
                                text: _formatHeading(controllers
                                    .getUserHeading("rating") ??
                                    "Prospect Grading"),
                                controller: controllers.prospectGradingCrt,
                                width: textFieldSize,
                                isOptional: false,
                                textInputAction: TextInputAction.next,
                                onChanged: (value) async {
                                  if (value.toString().isNotEmpty) {
                                    String newValue =
                                        value.toString()[0].toUpperCase() +
                                            value.toString().substring(1);
                                    if (newValue != value) {
                                      controllers.prospectGradingCrt.value =
                                          controllers.prospectGradingCrt.value
                                              .copyWith(
                                        text: newValue,
                                        selection: TextSelection.collapsed(
                                            offset: newValue.length),
                                      );
                                    }
                                  }
                                  SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  sharedPref.setString(
                                      "leadSource", value.toString().trim());
                                },
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              focusNode: ob7,
                              onEdit: () {
                                utils.datePicker(
                                    isFutureDate: true,
                                    context: context,
                                    textEditingController:
                                        controllers.dateOfConCtr,
                                    pathVal: controllers.exDate);
                                FocusScope.of(context).requestFocus(ob8);
                              },
                              hintText: _formatHeading(controllers
                                  .getUserHeading(
                                  "num_of_headcount") ??
                                  "Total Number Of Head Count"),
                              text: _formatHeading(controllers
                                  .getUserHeading(
                                  "num_of_headcount") ??
                                  "Total Number Of Head Count"),
                              controller: controllers.noOfHeadCountCrt,
                              width: textFieldSize,
                              isOptional: false,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9]")),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              textInputAction: TextInputAction.next,
                              onChanged: (value) async {
                                final prefs = await SharedPreferences
                                    .getInstance();
                                prefs.setString(
                                  "leadNoOfHeadCount",
                                  value.toString().trim(),
                                );
                              },
                            ),
                            Obx(
                              () => CustomDateBox(
                                isOptional: false,
                                text: _formatHeading(controllers.getUserHeading(
                                    "expected_convertion_date") ??
                                    "Expected Conversion Date"),
                                value: controllers.exDate.value,
                                width: textFieldSize,
                                onTap: () {
                                  utils.datePicker(
                                      isFutureDate: true,
                                      context: context,
                                      textEditingController:
                                          controllers.dateOfConCtr,
                                      pathVal: controllers.exDate);
                                  FocusScope.of(context).requestFocus(ob8);
                                },
                              ),
                            ),
                            CustomTextField(
                              focusNode: ob8,
                              onEdit: () {
                                utils.datePicker(
                                    isFutureDate: false,
                                    context: context,
                                    textEditingController:
                                        controllers.dateOfConCtr,
                                    pathVal: controllers.prospectDate);
                                FocusScope.of(context).requestFocus(ob9);
                              },
                              hintText: _formatHeading(controllers
                                  .getUserHeading(
                                  "details_of_service_required") ??
                                  "Details of Service Required"),
                              text: _formatHeading(controllers
                                  .getUserHeading(
                                  "details_of_service_required") ??
                                  "Details of Service Required"),
                              controller: controllers.sourceCrt,
                              width: textFieldSize,
                              isOptional: false,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) async {
                                if (value.toString().isNotEmpty) {
                                  String newValue =
                                      value.toString()[0].toUpperCase() +
                                          value.toString().substring(1);
                                  if (newValue != value) {
                                    controllers.sourceCrt.value =
                                        controllers.sourceCrt.value.copyWith(
                                      text: newValue,
                                      selection: TextSelection.collapsed(
                                          offset: newValue.length),
                                    );
                                  }
                                }
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString("Prospect Source Details",
                                    value.toString().trim());
                              },
                            ),
                            Obx(
                              () => CustomDateBox(
                                text: _formatHeading(controllers
                                    .getUserHeading(
                                    "prospect_enrollment_date") ??
                                    "Prospect Enrollment Date"),
                                isOptional: false,
                                value: controllers.prospectDate.value,
                                width: textFieldSize,
                                onTap: () {
                                  utils.datePicker(
                                      isFutureDate: false,
                                      context: context,
                                      textEditingController:
                                          controllers.dateOfConCtr,
                                      pathVal: controllers.prospectDate);
                                  FocusScope.of(context).requestFocus(ob9);
                                },
                              ),
                            ),
                            CustomTextField(
                              focusNode: ob9,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(throughByF);
                              },
                              hintText: _formatHeading(controllers
                                  .getUserHeading("status_update") ??
                                  "Status Update"),
                              text: _formatHeading(controllers
                                  .getUserHeading("status_update") ??
                                  "Status Update"),
                              controller: controllers.statusCrt,
                              width: textFieldSize,
                              isOptional: false,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) async {
                                if (value.toString().isNotEmpty) {
                                  String newValue =
                                      value.toString()[0].toUpperCase() +
                                          value.toString().substring(1);
                                  if (newValue != value) {
                                    controllers.statusCrt.value =
                                        controllers.statusCrt.value.copyWith(
                                      text: newValue,
                                      selection: TextSelection.collapsed(
                                          offset: newValue.length),
                                    );
                                  }
                                }
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString(
                                    "statusUpdate", value.toString().trim());
                              },
                            ),
                            CustomTextField(
                              focusNode: throughByF,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(door);
                              },
                              hintText: "Added through person",
                              text: "Added through person",
                              controller: controllers.throughBy,
                              width: textFieldSize,
                              isOptional: false,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) async {
                                if (value.toString().isNotEmpty) {
                                  String newValue =
                                      value.toString()[0].toUpperCase() +
                                          value.toString().substring(1);
                                  if (newValue != value) {
                                    controllers.throughBy.value =
                                        controllers.throughBy.value
                                            .copyWith(
                                          text: newValue,
                                          selection: TextSelection.collapsed(
                                              offset: newValue.length),
                                        );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ), ////Todo:Observation details
                    20.height,
                    Row(
                      children: [
                        CustomText(
                          text: constValue.addressInfo,
                          colors: colorsConst.textColor,
                          size: 20,
                          isCopy: false,
                        ),
                      ],
                    ), ////Todo:Address details
                    10.height,
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                    ),
                    20.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              focusNode: door,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(area);
                              },
                              hintText: "Door No (Optional)",
                              text: "Door No (Optional)",
                              controller: controllers.doorNumberController,
                              width: textFieldSize,
                              // keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              isOptional: false,
                              onChanged: (value) async {
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString(
                                    "leadDNo", value.toString().trim());
                              },
                            ),
                            CustomTextField(
                              focusNode: area,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(city);
                              },
                              hintText: "Area (Optional)",
                              text: "Area (Optional)",
                              controller: controllers.areaController,
                              width: textFieldSize,
                              isOptional: false,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) async {
                                if (value.toString().isNotEmpty) {
                                  String newValue =
                                      value.toString()[0].toUpperCase() +
                                          value.toString().substring(1);
                                  if (newValue != value) {
                                    controllers.areaController.value =
                                        controllers.areaController.value.copyWith(
                                      text: newValue,
                                      selection: TextSelection.collapsed(
                                          offset: newValue.length),
                                    );
                                  }
                                }
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString(
                                    "leadArea", value.toString().trim());
                              },
                            ),
                            CustomTextField(
                              focusNode: city,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(pincode);
                              },
                              hintText: "City (Optional)",
                              text: "City (Optional)",
                              controller: controllers.cityController,
                              width: textFieldSize,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              isOptional: false,
                              onChanged: (value) async {
                                if (value.toString().isNotEmpty) {
                                  String newValue =
                                      value.toString()[0].toUpperCase() +
                                          value.toString().substring(1);
                                  if (newValue != value) {
                                    controllers.cityController.value =
                                        controllers.cityController.value.copyWith(
                                      text: newValue,
                                      selection: TextSelection.collapsed(
                                          offset: newValue.length),
                                    );
                                  }
                                }
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString(
                                    "leadCity", value.toString().trim());
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              focusNode: pincode,
                              onEdit: () {
                                FocusScope.of(context).requestFocus(state);
                              },
                              hintText: "Pincode",
                              text: "Pincode",
                              controller: controllers.pinCodeController,
                              width: textFieldSize,
                              isOptional: false,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: constInputFormatters.pinCodeInput,
                              onChanged: (value) async {
                                if (controllers.pinCodeController.text
                                        .trim()
                                        .length ==
                                    6) {
                                  apiService.fetchPinCodeData(
                                      controllers.pinCodeController.text.trim());
                                }
                                SharedPreferences sharedPref =
                                    await SharedPreferences.getInstance();
                                sharedPref.setString(
                                    "leadPinCode", value.toString().trim());
                              },
                            ),
                            CustomTextField(
                              focusNode: state,
                              onEdit: () {
                                controllers.leadCtr.start();
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
                                } else if (controllers.leadMobileCrt[0].text.length !=
                                    10) {
                                  utils.snackBar(
                                      msg: "Invalid Phone No",
                                      color: Colors.red,
                                      context: context);
                                  controllers.leadCtr.reset();
                                } else if (controllers
                                    .leadWhatsCrt[0].text.isNotEmpty &&
                                    controllers.leadWhatsCrt[0].text.length != 10) {
                                  utils.snackBar(
                                      msg: "Invalid WhatsApp No",
                                      color: Colors.red,
                                      context: context);
                                  controllers.leadCtr.reset();
                                } else if (controllers.visitType == null ||
                                    controllers.visitType.toString().isEmpty) {
                                  utils.snackBar(
                                      msg: "Please Select Incoming Source",
                                      color: Colors.red,
                                      context: context);
                                  controllers.leadCtr.reset();
                                } else if (controllers
                                    .leadWhatsCrt[0].text.isNotEmpty &&
                                    controllers.leadWhatsCrt[0].text.length != 10) {
                                  utils.snackBar(
                                      msg: "Invalid Whats No",
                                      color: Colors.red,
                                      context: context);
                                  controllers.leadCtr.reset();
                                } else if (controllers
                                    .leadCoMobileCrt.text.isNotEmpty &&
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
                                } else {
                                  if (controllers.leadEmailCrt[0].text.isNotEmpty) {
                                    if (controllers.leadEmailCrt[0].text.isEmail) {
                                      if (controllers.pinCodeController.text.isEmpty) {
                                        apiService.insertSingleCustomer(context,widget.list,widget.list2);
                                      } else {
                                        if (controllers.pinCodeController.text.length ==
                                            6) {
                                          apiService.insertSingleCustomer(context,widget.list,widget.list2);
                                        } else {
                                          utils.snackBar(
                                              msg: "Please add 6 digits pin code",
                                              color: Colors.red,
                                              context: context);
                                          controllers.leadCtr.reset();
                                        }
                                      }
                                    } else {
                                      utils.snackBar(
                                          msg: "Please add valid email",
                                          color: Colors.red,
                                          context: context);
                                      controllers.leadCtr.reset();
                                    }
                                  } else {
                                    if (controllers.pinCodeController.text.isEmpty) {
                                      apiService.insertSingleCustomer(context,widget.list,widget.list2);
                                    } else {
                                      if (controllers.pinCodeController.text.length ==
                                          6) {
                                        apiService.insertSingleCustomer(context,widget.list,widget.list2);
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
                              hintText: "State (Optional)",
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
                            ),
                            SizedBox(
                              width: textFieldSize,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: "Country",
                                    size: 13,
                                    colors: Color(0xff4B5563),
                                    isCopy: false,
                                  ),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      width: textFieldSize,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey.shade400)),
                                      child: Obx(
                                            () => CustomText(
                                          text:
                                          "    ${controllers.selectedCountry.value}",
                                          colors: colorsConst.textColor,
                                          size: 15,
                                          isCopy: false,
                                        ),
                                      )),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    20.height,
                    Row(
                      children: [
                        CustomText(
                          text: "Additional Information",
                          colors: colorsConst.textColor,
                          size: 20,
                          isCopy: false,
                        ),
                        IconButton(
                            tooltip: "Add Column",
                            onPressed: (){
                              utils.showAddColumnDialog(context);
                            },
                            icon: Icon(Icons.add))
                      ],
                    ), ////Todo:Address details
                    10.height,
                    Divider(
                      color: Colors.grey.shade400,
                      thickness: 1,
                    ),
                    20.height,
                    Obx(()=>controllers.getColumn.value==false?
                    CircularProgressIndicator():
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controllers.addList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 items per row
                        crossAxisSpacing: 50,
                        mainAxisSpacing: 10,
                        childAspectRatio: 10,
                      ),
                      itemBuilder: (context, index) {
                        final info = controllers.addList[index];
                        return CustomTextField(
                            hintText:info.fieldName.toString(),
                            text:info.fieldName.toString(),width: textFieldSize,
                            controller: info.controller!);
                      },
                    )),
                    15.height,
                  ]),
                ),
              ),
            ],
          )),
    ]));
  }
}