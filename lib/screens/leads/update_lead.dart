import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
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
import '../../components/custom_sidebar.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';



class UpdateLead extends StatefulWidget {
  final String type;
  final String? id;
  final String? mainName;
  final String? mainMobile;
  final String? mainEmail;
  final String? mainWhatsApp;
  final String? companyName;
  final String? status;
  final String? rating;
  final String? emailUpdate;
  final String? name;
  final String? title;
  final String? mobileNumber;
  final String? whatsappNumber;
  final String? email;
  final String? mainTitle;
  final String? addressId;
  final String? companyWebsite;
  final String? companyNumber;
  final String? companyEmail;
  final String? industry;
  final String? productServices;
  final String? source;
  final String? owner;
  final String? budget;
  final String? timelineDecision;
  final String? serviceInterest;
  final String? description;
  final String? leadStatus;
  final String? active;
  final String? addressLine1;
  final String? addressLine2;
  final String? area;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;
  final String? linkedin;
  final String? x;
  final String? quotationStatus;
  final String? productDiscussion;
  final String? discussionPoint;
  String notes;
  final String? quotationRequired;
  final String? arpuValue;
  String sourceDetails;
  final String? prospectEnrollmentDate;
  final String? expectedConvertionDate;
  final String? statusUpdate;
  final String? numOfHeadcount;
  final String? expectedBillingValue;
  final String? detailsOfRequired;
  final String? points;
  final String visitType;
  String updateTs;
  UpdateLead({super.key,
    this.id,
    this.mainName,
    this.mainMobile,
    this.mainEmail,
    this.companyName,
    this.status,
    this.rating,
    this.mainWhatsApp,
    this.emailUpdate,
    this.name,
    this.title,
    this.mobileNumber,
    this.whatsappNumber,
    this.email,
    this.mainTitle,
    this.addressId,
    this.companyWebsite,
    this.companyNumber,
    this.companyEmail,
    this.industry,
    this.productServices,
    this.source,
    this.owner,
    this.budget,
    this.timelineDecision,
    this.serviceInterest,
    this.description,
    this.leadStatus,
    this.active,
    this.addressLine1,
    this.addressLine2,
    this.area,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.linkedin,
    this.points,
    this.x, this.quotationStatus,
    this.productDiscussion, this.discussionPoint,
    this.quotationRequired, this.arpuValue,
    this.prospectEnrollmentDate, this.expectedConvertionDate,
    this.statusUpdate, this.numOfHeadcount, this.expectedBillingValue,
    required this.notes,required this.sourceDetails,required this.updateTs, this.detailsOfRequired, required this.visitType, required this.type
  });


  @override
  State<UpdateLead> createState() => _UpdateLeadState();
}

class _UpdateLeadState extends State<UpdateLead> {
  String safeValue(dynamic value) {
    if (value == null) return "";
    final v = value.toString().trim();
    if (v.toLowerCase() == "null") return "";
    return v;
  }

  Future<void> setDefaults() async {
    setState(() => controllers.selectedCountry.value = "India");

    // setState(() =>controllers.selectedState.value = "Tamil Nadu");
    // await utils.getCities();

    setState(() => controllers.selectedCity.value = controllers.coCityController.text);

  }
  Future<void> getStringValue() async {
    setState(() {
      controllers.numberList.clear();
      controllers.infoNumberList.clear();
      var list=widget.mainMobile.toString().split("||");
      for(var i=0;i<list.length;i++){
        controllers.numberList.add(TextEditingController(text: list[i]));
      }

      var list2=widget.companyNumber.toString().split("||");
      for(var i=0;i<list2.length;i++){
        controllers.infoNumberList.add(TextEditingController(text: list2[i]));
      }

      controllers.leadNameCrt.clear();
      controllers.leadMobileCrt.clear();
      controllers.leadTitleCrt.clear();
      controllers.leadEmailCrt.clear();
      controllers.leadWhatsCrt.clear();
      controllers.leadNameCrt.add(TextEditingController());
      controllers.leadMobileCrt.add(TextEditingController());
      controllers.leadTitleCrt.add(TextEditingController());
      controllers.leadEmailCrt.add(TextEditingController());
      controllers.leadWhatsCrt.add(TextEditingController());
      controllers.leadNameCrt[0].text  = safeValue(widget.mainName);
      controllers.leadMobileCrt[0].text = safeValue(widget.mainMobile);
      controllers.leadEmailCrt[0].text  = safeValue(widget.mainEmail);
      controllers.leadWhatsCrt[0].text  = safeValue(widget.mainWhatsApp);
      controllers.leadTitleCrt[0].text  = safeValue(widget.owner);
      controllers.visitType = widget.visitType.isEmpty
          ? "Call"
          : controllers.callNameList.contains(widget.visitType)
          ? widget.visitType
          : "Call";
      controllers.leadCoNameCrt.text     = safeValue(widget.companyName);
      controllers.leadCoMobileCrt.text   = safeValue(widget.companyNumber);
      controllers.leadWebsite.text       = safeValue(widget.companyWebsite);
      controllers.leadCoEmailCrt.text    = safeValue(widget.companyEmail);
      controllers.leadProduct.text       = safeValue(widget.productServices);
      controllers.leadOwnerNameCrt.text  = safeValue(widget.owner);
      controllers.prodDescriptionController.text = safeValue(widget.productDiscussion);
      controllers.statusCrt.text           = safeValue(widget.statusUpdate);
      controllers.leadDisPointsCrt.text    = safeValue(widget.source);
      controllers.prospectGradingCrt.text  = safeValue(widget.rating);
      controllers.exMonthBillingValCrt.text     = safeValue(widget.expectedBillingValue);
      controllers.noOfHeadCountCrt.text         = safeValue(widget.numOfHeadcount);
      controllers.sourceCrt.text                = safeValue(widget.detailsOfRequired);
      controllers.additionalNotesCrt.text       = safeValue(widget.notes);
      controllers.arpuCrt.text                  = safeValue(widget.arpuValue);
      controllers.expectedConversionDateCrt.text = safeValue(widget.expectedConvertionDate);
      controllers.prospectEnrollmentDateCrt.text = safeValue(widget.prospectEnrollmentDate);
      controllers.prospectDate.value = safeValue(widget.prospectEnrollmentDate);
      controllers.exDate.value       = safeValue(widget.expectedConvertionDate);
      controllers.industry = safeValue(widget.industry).isEmpty ? null : safeValue(widget.industry);
      controllers.source   = safeValue(widget.source).isEmpty ? null : safeValue(widget.source);
      controllers.status   = safeValue(widget.status).isEmpty ? null : safeValue(widget.status);
      controllers.rating   = safeValue(widget.rating).isEmpty ? null : safeValue(widget.rating);
      controllers.service  = safeValue(widget.serviceInterest).isEmpty ? null : safeValue(widget.serviceInterest);
      controllers.doorNumberController.text = safeValue(widget.addressLine1);
      controllers.streetNameController.text = safeValue(widget.addressLine2);
      controllers.areaController.text       = safeValue(widget.area);
      controllers.cityController.text       = safeValue(widget.city);
      controllers.selectedCity.value        = safeValue(widget.city);
      controllers.pinCodeController.text    = safeValue(widget.pinCode);
      controllers.pinCode                   = safeValue(widget.pinCode);
      controllers.stateController.text      = safeValue(widget.state.toString().isEmpty ? "Tamil Nadu" : widget.state);
      controllers.selectedState.value       = safeValue(widget.state.toString().isEmpty ? "Tamil Nadu" : widget.state);
      controllers.countryController.text    = safeValue(widget.country.toString().isEmpty ? "India" : widget.country);
      controllers.leadXCrt.text        = safeValue(widget.x);
      controllers.leadLinkedinCrt.text = safeValue(widget.linkedin);
      controllers.leadDescription.text = safeValue(widget.description);
      controllers.leadTime.text        = safeValue(widget.timelineDecision);
      controllers.budgetCrt.text       = safeValue(widget.budget);
      controllers.leadActions.text     = safeValue(widget.points);
      controllers.selectPinCodeList = [];
    });
  }

  final ScrollController _controller = ScrollController();
  late FocusNode _focusNode;
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
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getStringValue();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      FocusScope.of(context)
          .requestFocus(
          name);
    });
    //setDefaults();
  }
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    name.dispose();
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
  Widget build(BuildContext context){
    double textFieldSize = (MediaQuery.of(context).size.width - 400) / 1.8;
    return SelectionArea(
      child: Scaffold(
          // appBar: PreferredSize(
          //   preferredSize: const Size.fromHeight(60),
          //   child:  CustomAppbar(text: appName,),
          // ),
          body: Row(
            children:[
              SideBar(),
              20.width,
              Container(
                width:MediaQuery.of(context).size.width-180,
                alignment: Alignment.center,
                child: Column(
                  children:[
                    10.height,
                    Row(
                      children: [
                        IconButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back,color: colorsConst.third,)),
                        CustomText(
                          text: "Leads",
                          colors: colorsConst.textColor,
                          size:23,
                          isCopy: true,
                          isBold: true,
                        ),
                      ],
                    ),
                    5.height,
                    Row(
                      children: [
                        CustomText(
                          text: "Update your Lead Information",
                          colors: colorsConst.textColor,
                          isCopy: true,
                          size:18,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height-80,
                      width: MediaQuery.of(context).size.width-180,
                      child: GestureDetector(
                        onTap: () {
                          _focusNode.requestFocus();
                        },
                        child: RawKeyboardListener(
                          focusNode: _focusNode,
                          autofocus: true,
                          onKey: (event) {
                            if (event is RawKeyDownEvent) {
                              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                _controller.animateTo(
                                  _controller.offset + 100,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                _controller.animateTo(
                                  _controller.offset - 100,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              }
                            }
                          },
                          child: SingleChildScrollView(
                            controller: _controller,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                30.height,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          hintText:"Name",
                                          text:"Name",
                                          focusNode: name,
                                          onEdit: () {
                                            FocusScope.of(context)
                                                .requestFocus(phone);
                                          },
                                          isOptional: true,
                                          controller: controllers.leadNameCrt[0],
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          textCapitalization: TextCapitalization.words,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            //sharedPref.setString("leadName$index", value.toString().trim());
                                          },
                                        ),
                                        Obx((){
                                          return SizedBox(
                                            width: textFieldSize,
                                            child: ListView.builder(
                                                shrinkWrap:true,
                                                itemCount:controllers.numberList.length,
                                                itemBuilder: (context,index){
                                                  return Column(
                                                      children:[
                                                        Row(
                                                            children:[
                                                              SizedBox(
                                                                width: textFieldSize-40,
                                                                // height: 80,
                                                                child: CustomTextField(
                                                                  onEdit: () {
                                                                    FocusScope.of(context)
                                                                        .requestFocus(account);
                                                                  },
                                                                  // focusNode: whatsApp,
                                                                  hintText: "Phone No",
                                                                  text: "Phone No",
                                                                  controller:controllers.numberList[index],
                                                                  width: textFieldSize,
                                                                  isOptional: true,
                                                                  keyboardType: TextInputType.number,
                                                                  textInputAction: TextInputAction.next,
                                                                  inputFormatters: constInputFormatters.mobileNumberInput,
                                                                  onChanged: (value) async {
                                                                    //   if (controllers.leadWhatsCrt[index].text !=controllers.leadMobileCrt[index].text) {
                                                                    //     controllers.isCoMobileNumberList[index] =false;
                                                                    //   } else {
                                                                    //     controllers.isCoMobileNumberList[index] =true;
                                                                    //   }
                                                                    //   SharedPreferences sharedPref =
                                                                    //   await SharedPreferences
                                                                    //       .getInstance();
                                                                    //   sharedPref.setString(
                                                                    //       "leadWhats$index",
                                                                    //       value.toString().trim());
                                                                  },
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  onPressed:(){
                                                                    if (controllers.numberList.length > 1) {
                                                                      controllers.numberList.removeAt(index);
                                                                    }else{
                                                                      utils.snackBar(context: context, msg: "Enter at least one mobile number.", color: Colors.red);
                                                                    }
                                                                  },
                                                                  icon:SvgPicture.asset("assets/images/delete.svg")
                                                              )
                                                            ]
                                                        ),
                                                        if(index==controllers.numberList.length-1)
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              IconButton(
                                                                onPressed: () {
                                                                  bool isMistake = false;
                                                                  Set<String> uniqueNumbers = {};

                                                                  for (var i = 0; i < controllers.numberList.length; i++) {
                                                                    String number = controllers.numberList[i].text.trim();

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
                                                                        msg: "Same phone number already added",
                                                                        color: Colors.red,
                                                                      );
                                                                      break;
                                                                    }

                                                                    uniqueNumbers.add(number);
                                                                  }

                                                                  if (!isMistake) {
                                                                    controllers.numberList.add(TextEditingController());
                                                                  }
                                                                },
                                                                icon: Icon(Icons.add),
                                                              ),
                                                            ],
                                                          )
                                                      ]
                                                  );
                                                }),
                                          );
                                        }),
                                        CustomTextField(
                                          onEdit: () {
                                            FocusScope.of(context)
                                                .requestFocus(account);
                                          },
                                          focusNode: whatsApp,
                                          hintText: "Whatsapp No",
                                          text: "Whatsapp",
                                          controller:
                                          controllers.leadWhatsCrt[0],
                                          width: textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.mobileNumberInput,
                                          onChanged: (value)  {
                                            if (controllers.leadWhatsCrt[0].text !=controllers.leadMobileCrt[0].text) {
                                              controllers.isCoMobileNumberList[0] =false;
                                            } else {
                                              controllers.isCoMobileNumberList[0] =true;
                                            }
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          onEdit: () {
                                            FocusScope.of(context)
                                                .requestFocus(email);
                                          },
                                          focusNode: account,
                                          hintText:"Account Manager (Optional)",
                                          text:"Account Manager (Optional)",
                                          isOptional: false,
                                          controller: controllers.leadTitleCrt[0],
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {},
                                        ),
                                        CustomTextField(
                                          focusNode: email,
                                          onEdit: () {
                                            FocusScope.of(context)
                                                .requestFocus(
                                                cName);
                                          },
                                          hintText:"Email Id (Optional)",
                                          text:"Email Id",
                                          controller: controllers.leadEmailCrt[0],
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.emailInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            //sharedPref.setString("leadEmail$index", value.toString().trim());
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
                                                    text: "Call Visit Type",
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
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: (controllers.callNameList)
                                                    .map<Widget>((type) {
                                                  return Row(
                                                    // mainAxisSize: MainAxisSize.min,
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
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    CustomText(
                                      text: constValue.companyInfo,
                                      colors: colorsConst.textColor,
                                      size: 20,
                                      isCopy: false,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(cNo);
                                          },
                                          focusNode: cName,
                                          hintText:"Company Name",
                                          text:"Company Name",
                                          controller: controllers.leadCoNameCrt,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadCoName", value.toString().trim());
                                          },
                                        ),
                                        Obx((){
                                          return SizedBox(
                                            width: textFieldSize,
                                            child: ListView.builder(
                                                shrinkWrap:true,
                                                itemCount:controllers.infoNumberList.length,
                                                itemBuilder: (context,index){
                                                  return Column(
                                                      children:[
                                                        Row(
                                                            children:[
                                                              SizedBox(
                                                                width: textFieldSize-40,
                                                                // height: 80,
                                                                child: CustomTextField(
                                                                  // focusNode: cNo,
                                                                  onEdit: () {
                                                                    FocusScope.of(context).requestFocus(linkedin);
                                                                  },
                                                                  hintText: "Company Phone No.",
                                                                  text: "Company Phone No.",
                                                                  controller: controllers.infoNumberList[index],
                                                                  width: textFieldSize,
                                                                  keyboardType: TextInputType.number,
                                                                  textInputAction: TextInputAction.next,
                                                                  isOptional: false,
                                                                  inputFormatters:
                                                                  constInputFormatters.mobileNumberInput,
                                                                  onChanged: (value) async {
                                                                    // if (value.toString().isNotEmpty) {
                                                                    //   String newValue =
                                                                    //       value.toString()[0].toUpperCase() +
                                                                    //           value.toString().substring(1);
                                                                    //   if (newValue != value) {
                                                                    //     controllers.leadCoMobileCrt.value =
                                                                    //         controllers.leadCoMobileCrt.value
                                                                    //             .copyWith(
                                                                    //           text: newValue,
                                                                    //           selection: TextSelection.collapsed(
                                                                    //               offset: newValue.length),
                                                                    //         );
                                                                    //   }
                                                                    // }
                                                                    // SharedPreferences sharedPref =
                                                                    // await SharedPreferences.getInstance();
                                                                    // sharedPref.setString(
                                                                    //     "leadCoMobile", value.toString().trim());
                                                                  },
                                                                  // }
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  onPressed:(){
                                                                    if (controllers.infoNumberList.length > 1) {
                                                                      controllers.infoNumberList.removeAt(index);
                                                                    }else{
                                                                      utils.snackBar(context: context, msg: "Enter at least one mobile number.", color: Colors.red);
                                                                    }
                                                                  },
                                                                  icon:SvgPicture.asset("assets/images/delete.svg")
                                                              )
                                                            ]
                                                        ),
                                                        if(index==controllers.infoNumberList.length-1)
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              IconButton(
                                                                onPressed: () {
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
                                                                  }
                                                                },
                                                                icon: Icon(Icons.add),
                                                              ),
                                                            ],
                                                          )
                                                      ]
                                                  );
                                                }),
                                          );
                                        }),
                                        IndustryDropdown(
                                          width: textFieldSize,
                                          items: controllers.industriesList,
                                          onChanged: (val) {
                                            setState(() {
                                              controllers.industry = val?['value'];
                                            });
                                            print(val?['id']);
                                            print(val?['value']);
                                          },
                                          onAdd: () {
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
                                                        focusNode: cNo,
                                                        hintText: "Industry",
                                                        text: "Industry",
                                                        controller: controllers.industryValueCtr,
                                                        width: textFieldSize,
                                                        keyboardType: TextInputType.text,
                                                        textInputAction: TextInputAction.done,
                                                        isOptional: false,
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
                                                              utils.snackBar(
                                                                context: context,
                                                                msg: "Please enter industry value",
                                                                color: Colors.red,
                                                              );
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
                                        ),
                                        CustomTextField(
                                          hintText:"Linkedin(Optional)",
                                          text:"Linkedin(Optional)",
                                          focusNode: linkedin,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(cEmail);
                                          },
                                          isOptional: false,
                                          controller: controllers.leadLinkedinCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.socialInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadLinkedin", value.toString().trim());
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(cServices);
                                          },
                                          focusNode: cEmail,
                                          hintText:"Company Email",
                                          text:"Company Email",
                                          controller: controllers.leadCoEmailCrt,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.emailInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadCoEmail", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: cServices,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(website);
                                          },
                                          hintText:"Product/Services",
                                          text:"Product/Services",
                                          isOptional: false,
                                          controller: controllers.leadProduct,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadProduct", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: website,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(cX);
                                          },
                                          hintText:"Website(Optional)",
                                          text:"Website(Optional)",
                                          isOptional: false,
                                          controller: controllers.leadWebsite,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadWebsite", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: cX,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(door);
                                          },
                                          hintText:"X(Optional)",
                                          text:"X(Optional)",
                                          controller: controllers.leadXCrt,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.socialInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadX", value.toString().trim());
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                20.height,
                                Row(
                                  children:[
                                    CustomText(
                                      text: constValue.addressInfo,
                                      colors: colorsConst.textColor,
                                      size: 20,
                                      isCopy: false,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          focusNode: door,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(area);
                                          },
                                          hintText:"Door No(Optional)",
                                          text:"Door No(Optional)",
                                          controller: controllers.doorNumberController,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.addressInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadDNo", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: area,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(city);
                                          },
                                          hintText:"Area(Optional)",
                                          text:"Area(Optional)",
                                          isOptional: false,
                                          controller: controllers.areaController,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.addressInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadArea", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          hintText: "City (Optional)",
                                          text: "City (Optional)",
                                          focusNode: city,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(pincode);
                                          },
                                          controller:controllers.cityController,
                                          width: textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          isOptional: false,
                                          onChanged: (value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadCity",value.toString().trim());
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          focusNode: pincode,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(state);
                                          },
                                          hintText:"Pincode",
                                          text:"Pincode",
                                          controller: controllers.pinCodeController,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.pinCodeInput,
                                          onChanged:(value) async {
                                            if (controllers.pinCodeController.text
                                                .trim()
                                                .length ==
                                                6) {
                                              apiService.fetchPinCodeData(
                                                  controllers.pinCodeController.text.trim());
                                            }
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadPinCode", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: state,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(ob1);
                                          },
                                          hintText: "State (Optional)",
                                          text: "State (Optional)",
                                          controller:controllers.stateController,
                                          width: textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          isOptional: false,
                                          onChanged: (value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadState",value.toString().trim());
                                          },
                                        ),
                                        SizedBox(
                                          width: textFieldSize,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                text:"Country",
                                                size: 13,
                                                isCopy: false,
                                                colors: Color(0xff4B5563),
                                              ),
                                              Container(
                                                  alignment: Alignment.centerLeft,
                                                  width: textFieldSize,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:BorderRadius.circular(5),
                                                      border: Border.all(
                                                          color: Colors.grey.shade200
                                                      )
                                                  ),
                                                  child:Obx(() =>  CustomText(
                                                    text: "    ${controllers.selectedCountry.value}",
                                                    colors:colorsConst.textColor,
                                                    isCopy: false,
                                                    size: 15,
                                                  ),
                                                  )
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                20.height,
                                Row(
                                  children:[
                                    CustomText(
                                      text: constValue.customFields,
                                      colors: colorsConst.textColor,
                                      size: 20,
                                      isCopy: false,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          focusNode: ob1,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(ob2);
                                          },
                                          hintText:"Actions to be taken",
                                          text:"Actions to be taken",
                                          isOptional: false,
                                          controller: controllers.leadActions,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {},
                                        ),
                                        CustomTextField(
                                          focusNode: ob2,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(ob3);
                                          },
                                          hintText:"Source Of Prospect",
                                          text:"Source Of Prospect",
                                          isOptional: false,
                                          controller: controllers.leadDisPointsCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          onChanged:(value) async {

                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: ob3,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(ob4);
                                          },
                                          hintText:"Product Discussed",
                                          text:"Product Discussed",
                                          isOptional: false,
                                          controller: controllers.prodDescriptionController,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          onChanged:(value) async {

                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: ob4,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(ob5);
                                          },
                                          hintText: "Expected Monthly Billing Value",
                                          text: "Expected Monthly Billing Value",
                                          controller: controllers.exMonthBillingValCrt,
                                          width: textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          onChanged: (value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadExMonthBillingVal", value.toString().trim());
                                          },
                                          // }
                                        ),
                                        CustomTextField(
                                          focusNode: ob5,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(ob6);
                                          },
                                          hintText:"ARPU Value",
                                          text:"ARPU Value",
                                          isOptional: false,
                                          controller: controllers.arpuCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.numberInput,
                                          onChanged:(value) async {
                                          },
                                        ),
                                        CustomTextField(
                                          focusNode: ob6,
                                          onEdit: () {
                                            FocusScope.of(context).requestFocus(ob7);
                                          },
                                          hintText:"Prospect Grading",
                                          text:"Prospect Grading",
                                          isOptional: false,
                                          controller: controllers.prospectGradingCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          onChanged:(value) async {

                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          focusNode: ob7,
                                          onEdit: () {
                                            utils.datePicker(
                                                context: context,
                                                textEditingController: controllers.dateOfConCtr,
                                                pathVal: controllers.exDate);
                                            FocusScope.of(context).requestFocus(ob8);
                                          },
                                          hintText:"Total Number Of Head Count",
                                          text:"Total Number Of Head Count",
                                          isOptional: false,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          controller: controllers.noOfHeadCountCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                        ),
                                        Obx(() => CustomDateBox(
                                          text: "Expected Conversion Date",
                                          isOptional: false,
                                          value: controllers.exDate.value,
                                          width: textFieldSize,
                                          onTap: () {
                                            utils.datePicker(
                                                context: context,
                                                textEditingController: controllers.dateOfConCtr,
                                                pathVal: controllers.exDate);
                                            FocusScope.of(context).requestFocus(ob8);
                                          },
                                        ),
                                        ),
                                        CustomTextField(
                                          focusNode: ob8,
                                          onEdit: () {
                                            utils.datePicker(
                                                context: context,
                                                textEditingController: controllers.dateOfConCtr,
                                                pathVal: controllers.prospectDate);
                                            FocusScope.of(context).requestFocus(ob9);
                                          },
                                          hintText:"Details of Service Required",
                                          text:"Details of Service Required",
                                          isOptional: false,
                                          controller: controllers.sourceCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadDescription", value.toString().trim());
                                          },
                                        ),
                                        Obx(() => CustomDateBox(
                                          text: "Prospect Enrollment Date",
                                          value: controllers.prospectDate.value,
                                          width: textFieldSize,
                                          isOptional: false,
                                          onTap: () {
                                            utils.datePicker(
                                                context: context,
                                                textEditingController: controllers.dateOfConCtr,
                                                pathVal: controllers.prospectDate);
                                            FocusScope.of(context).requestFocus(ob9);
                                          },
                                        ),
                                        ),
                                        CustomTextField(
                                          focusNode: ob9,
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
                                                  msg: "Please Add Mobile Number",
                                                  color: Colors.red,
                                                  context: context);
                                              controllers.leadCtr.reset();
                                            } else if (controllers.leadMobileCrt[0].text.length != 10) {
                                              utils.snackBar(
                                                  msg: "Invalid Mobile Number",
                                                  color: Colors.red,
                                                  context: context);
                                              controllers.leadCtr.reset();
                                            } else if (controllers.visitType == null || controllers.visitType.toString().isEmpty) {
                                              utils.snackBar(
                                                  msg: "Please Select Call Visit Type",
                                                  color: Colors.red,
                                                  context: context);
                                              controllers.leadCtr.reset();
                                            } else {
                                              if(controllers.leadEmailCrt[0].text.isNotEmpty){
                                                if (controllers.leadEmailCrt[0].text.isEmail) {
                                                  if(controllers.pinCodeController.text.isEmpty){
                                                    apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                                  }else{
                                                    if(controllers.pinCodeController.text.length==6){
                                                      apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                                    }else{
                                                      utils.snackBar(msg: "Please add 6 digits pin code",
                                                          color: colorsConst.primary,context:context);
                                                      controllers.leadCtr.reset();
                                                    }
                                                  }
                                                }else{
                                                  utils.snackBar(msg: "Please add valid email",
                                                      color: colorsConst.primary,context:context);
                                                  controllers.leadCtr.reset();
                                                }
                                              }else{
                                                if(controllers.pinCodeController.text.isEmpty){
                                                  apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                                }else{
                                                  if(controllers.pinCodeController.text.length==6){
                                                    apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                                  }else{
                                                    utils.snackBar(msg: "Please add 6 digits pin code",
                                                        color: colorsConst.primary,context:context);
                                                    controllers.leadCtr.reset();
                                                  }
                                                }
                                              }}
                                            },
                                          hintText: "Status Update",
                                          text: "Status Update",
                                          controller: controllers.statusCrt,
                                          width: textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          onChanged: (value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("statusUpdate", value.toString().trim());
                                          },
                                          // }
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                20.height,
                                CustomLoadingButton(
                                    callback: (){
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
                                            msg: "Enter valid 10 digit mobile number",
                                            color: Colors.red,
                                          );
                                          break;
                                        }
                                        if (uniqueNumbers.contains(number)) {
                                          isMistake = true;
                                          utils.snackBar(
                                            context: context,
                                            msg: "Same phone number already added",
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
                                      for (var i = 0; i < controllers.numberList.length; i++) {
                                        String number = controllers.numberList[i].text.trim();
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
                                      if (controllers.leadLinkedinCrt.text.trim().isNotEmpty&&!utils.isValidLinkedInId(controllers.leadLinkedinCrt.text.trim())) {
                                        utils.snackBar(
                                          context: context,
                                          msg: "Enter valid LinkedIn ID",
                                          color: Colors.red,
                                        );
                                        controllers.leadCtr.reset();
                                        return;
                                      }
                                      if (controllers.leadLinkedinCrt.text.trim().isNotEmpty&&!utils.isValidXId(controllers.leadXCrt.text.trim())) {
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
                                            msg: "Please add name",
                                            color: Colors.red,
                                            context: context);
                                        controllers.leadCtr.reset();
                                      } else if (controllers.leadMobileCrt[0].text.isEmpty) {
                                        utils.snackBar(
                                            msg: "Please Add Mobile Number",
                                            color: Colors.red,
                                            context: context);
                                        controllers.leadCtr.reset();
                                      } else if (controllers.leadMobileCrt[0].text.length != 10) {
                                        utils.snackBar(
                                            msg: "Invalid Mobile Number",
                                            color: Colors.red,
                                            context: context);
                                        controllers.leadCtr.reset();
                                      } else if (controllers.visitType == null || controllers.visitType.toString().isEmpty) {
                                        utils.snackBar(
                                            msg: "Please Select Call Visit Type",
                                            color: Colors.red,
                                            context: context);
                                        controllers.leadCtr.reset();
                                      } else {
                                        if(controllers.leadEmailCrt[0].text.isNotEmpty){
                                          if (controllers.leadEmailCrt[0].text.isEmail) {
                                            if(controllers.pinCodeController.text.isEmpty){
                                              apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                            }else{
                                              if(controllers.pinCodeController.text.length==6){
                                                apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                              }else{
                                                utils.snackBar(msg: "Please add 6 digits pin code",
                                                    color: colorsConst.primary,context:context);
                                                controllers.leadCtr.reset();
                                              }
                                            }
                                          }else{
                                            utils.snackBar(msg: "Please add valid email",
                                                color: colorsConst.primary,context:context);
                                            controllers.leadCtr.reset();
                                          }
                                        }else{
                                          if(controllers.pinCodeController.text.isEmpty){
                                            apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                          }else{
                                            if(controllers.pinCodeController.text.length==6){
                                              apiService.updateLeadAPI(context,widget.id.toString(),widget.type.toString(),widget.addressId.toString());
                                            }else{
                                              utils.snackBar(msg: "Please add 6 digits pin code",
                                                  color: colorsConst.primary,context:context);
                                              controllers.leadCtr.reset();
                                            }
                                          }
                                        }}
                                      // if(controllers.leadNameCrt[0].text.isEmpty){
                                      //   utils.snackBar(msg: "Please add name",
                                      //       color: colorsConst.primary,context:context);
                                      //   controllers.leadCtr.reset();
                                      // }else if(controllers.leadMobileCrt[0].text.length!=10){
                                      //   utils.snackBar(msg: "Invalid Mobile Number",
                                      //       color: colorsConst.primary,context:context);
                                      //   controllers.leadCtr.reset();
                                      // }else if(controllers.leadTitleCrt[0].text.isEmpty){
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
                                      print("lead id ${widget.id.toString()}");
                                      //controllers.leadCtr.reset();

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
                                      // }

                                    },
                                    text: "Save Lead",
                                    height: 60,
                                    controller: controllers.leadCtr,
                                    isLoading:true,
                                    textColor: Colors.white,
                                    backgroundColor: colorsConst.third,
                                    radius: 10,
                                    width: 180),
                                50.height,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              )
            ],
          )
      ),
    );
  }
}
