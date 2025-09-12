import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';



class UpdateLead extends StatefulWidget {
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
    this.x, this.quotationStatus,
    this.productDiscussion, this.discussionPoint,
    this.quotationRequired, this.arpuValue,
    this.prospectEnrollmentDate, this.expectedConvertionDate,
    this.statusUpdate, this.numOfHeadcount, this.expectedBillingValue,
    required this.notes,required this.sourceDetails,required this.updateTs, this.detailsOfRequired
  });


  @override
  State<UpdateLead> createState() => _UpdateLeadState();
}

class _UpdateLeadState extends State<UpdateLead> {

  Future<void> setDefaults() async {
    setState(() => controllers.selectedCountry.value = "India");
    await utils.getStates();

    // setState(() =>controllers.selectedState.value = "Tamil Nadu");
    // await utils.getCities();

    setState(() => controllers.selectedCity.value = controllers.coCityController.text);

  }

  Future<void> getStringValue()async{
    setState((){
      final whatsApp=widget.mainWhatsApp??"";
      final companyName=widget.companyName ?? "";
      final companyPhone=widget.companyNumber ?? "";
      final webSite=widget.companyWebsite ?? "";
      final coEmail=widget.companyEmail ?? "";
      final product=widget.productServices ?? "";
      final ownerName= widget.owner?? "";
      final industry=widget.industry;
      final source=widget.source;
      final status=widget.status;
      final rating=widget.rating;
      final service=widget.serviceInterest;
      final doorNo=widget.addressLine1 ?? "";
      final street=widget.addressLine2 ?? "";
      final area=widget.area ?? "";
      final city=widget.city ?? "";
      final pinCode=widget.pinCode ?? "";
      final budget=widget.budget ?? "";
      final state=widget.state ?? "Tamil Nadu";
      final country=widget.country ?? "India";
      final twitter=widget.x=="null"?"":widget.x;
      final linkedin=widget.linkedin=="null"?"":widget.linkedin;
      final time=widget.timelineDecision ?? "";
      final leadDescription=widget.description ?? "";

      controllers.leadCoNameCrt.text=companyName.toString();
      controllers.leadCoMobileCrt.text=companyPhone.toString();
      controllers.leadWebsite.text=webSite.toString();
      controllers.leadCoEmailCrt.text=coEmail.toString();
      controllers.leadProduct.text=product.toString();
      controllers.leadOwnerNameCrt.text=ownerName.toString();
      controllers.prodDescriptionController.text = widget.productDiscussion.toString()=="null"?"":widget.productDiscussion.toString();
      controllers.statusCrt.text = widget.status .toString()=="null"?"":widget.status.toString();
      controllers.exMonthBillingValCrt.text = widget.expectedBillingValue.toString()=="null"?"":widget.expectedBillingValue.toString();
      controllers.noOfHeadCountCrt.text = widget.numOfHeadcount.toString()=="null"?"":widget.numOfHeadcount.toString();
      controllers.sourceCrt.text = widget.detailsOfRequired.toString()=="null"?"":widget.detailsOfRequired.toString();
      controllers.additionalNotesCrt.text = widget.notes.toString()=="null"?"":widget.notes.toString();
      controllers.arpuCrt.text = widget.arpuValue.toString()=="null"?"":widget.arpuValue.toString();
      controllers.expectedConversionDateCrt.text = widget.expectedConvertionDate.toString()=="null"?"":widget.expectedConvertionDate.toString();
      controllers.prospectEnrollmentDateCrt.text = widget.prospectEnrollmentDate.toString()=="null"?"":widget.prospectEnrollmentDate.toString();
      controllers.statusCrt.text = widget.statusUpdate.toString()=="null"?"":widget.statusUpdate.toString();
      controllers.leadDisPointsCrt.text = widget.source.toString()=="null"?"":widget.source.toString();
      controllers.industry = (industry == null || industry == "null" || industry.toString().trim().isEmpty) ? null : industry;
      controllers.source = (source == null || source == "null" || source.toString().trim().isEmpty) ? null : source;
      controllers.status = (status == null || status == "null" || status.toString().trim().isEmpty) ? null : status;
      controllers.rating = (rating == null || rating == "null" || rating.toString().trim().isEmpty) ? null : rating;
      controllers.service = (service == null || service == "null" || service.toString().trim().isEmpty) ? null : service;
      controllers.doorNumberController.text=doorNo.toString();
      controllers.leadDescription.text=leadDescription.toString();
      controllers.leadTime.text=time.toString();
      controllers.budgetCrt.text=budget.toString();
      controllers.streetNameController.text=street.toString();
      controllers.areaController.text=area.toString();
      controllers.selectedCity.value=city.toString();
      controllers.cityController.text=city.toString();
      controllers.pinCode=pinCode.toString();
      controllers.selectedState.value=state.toString();
      controllers.countryController.text=country.toString();
      controllers.leadXCrt.text=twitter.toString();
      controllers.leadLinkedinCrt.text=linkedin.toString();
      controllers.selectPinCodeList=[];
      controllers.selectPinCodeList = controllers.pinCodeList
          .where((location) =>
      location["STATE"] == controllers.selectedState &&
          location["DISTRICT"] == controllers.selectedCity)
          .map((location) => location["PINCODE"].toString())
          .toList();
      controllers.leadNameCrt.clear();
      controllers.leadMobileCrt.clear();
      controllers.leadTitleCrt.clear();
      controllers.leadEmailCrt.clear();
      // if(widget.name.toString().contains("||")){
      //   leadPersonalCount=widget.name.toString().split("||").length;
      //
      //   controllers.leadPersonalItems.value=leadPersonalCount;
      //   controllers.isMainPersonList.value=[];
      //   controllers.isCoMobileNumberList.value=[];
      //   for(int i=0;i<leadPersonalCount;i++){
      //     controllers.leadNameCrt.add(TextEditingController());
      //     controllers.leadMobileCrt.add(TextEditingController());
      //     controllers.leadTitleCrt.add(TextEditingController());
      //     controllers.leadEmailCrt.add(TextEditingController());
      //     controllers.isMainPersonList.add(false);
      //     controllers.isCoMobileNumberList.add(false);
      //     final name=widget.name.toString().split("||")[i];
      //     final email=widget.email.toString().split("||")[i];
      //     final title=widget.title.toString().split("||")[i];
      //     controllers.leadNameCrt[i].text=name;
      //     final mobile=widget.mobileNumber.toString().split("||")[i];
      //     controllers.leadMobileCrt[i].text=mobile.toString();
      //     controllers.leadEmailCrt[i].text=email.toString();
      //     controllers.leadTitleCrt[i].text=title.toString();
      //   }
      // }else{
      //   leadPersonalCount=1;
      //   print("lead count error $leadPersonalCount");
      //   controllers.leadPersonalItems.value=leadPersonalCount;
      //   controllers.isMainPersonList.value=[];
      //   controllers.isCoMobileNumberList.value=[];
      //   for(int i=0;i<leadPersonalCount;i++){
      controllers.leadNameCrt.add(TextEditingController());
      controllers.leadMobileCrt.add(TextEditingController());
      controllers.leadTitleCrt.add(TextEditingController());
      controllers.leadEmailCrt.add(TextEditingController());
      controllers.leadNameCrt[0].text=widget.mainName.toString();
      controllers.leadMobileCrt[0].text=widget.mainMobile.toString();
      controllers.leadEmailCrt[0].text=widget.mainEmail.toString();
      controllers.leadTitleCrt[0].text=widget.owner.toString();
      controllers.leadWhatsCrt[0].text=whatsApp.toString();
    });
  }
  final ScrollController _controller = ScrollController();
  late FocusNode _focusNode;
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getStringValue();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    //setDefaults();
  }
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    double textFieldSize=(MediaQuery.of(context).size.width-400)/3.5;
    return SelectionArea(
      child: Scaffold(
          // appBar: PreferredSize(
          //   preferredSize: const Size.fromHeight(60),
          //   child:  CustomAppbar(text: appName,),
          // ),
          body: Row(
            children:[
              utils.sideBarFunction(context),
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
                          text: "New Leads - Suspects",
                          colors: colorsConst.textColor,
                          size:23,
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
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          hintText:"Name",
                                          text:"Name",
                                          isOptional: false,
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children:[
                                            SizedBox(
                                              width:textFieldSize,
                                              height: 50,
                                              child: TextFormField(
                                                  style: TextStyle(
                                                      color:colorsConst.textColor,fontSize: 14,
                                                      fontFamily:"Lato"
                                                  ),
                                                  cursorColor: colorsConst.primary,
                                                  onChanged:(value) async {
                                                    SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                                    //sharedPref.setString("leadMobileNumber$index", value.toString().trim());
                                                  },
                                                  onTap:(){},
                                                  keyboardType: TextInputType.number,
                                                  inputFormatters: constInputFormatters.mobileNumberInput,
                                                  textCapitalization: TextCapitalization.none,
                                                  controller: controllers.leadMobileCrt[0],
                                                  textInputAction: TextInputAction.next,
                                                  decoration:InputDecoration(
                                                    fillColor:Colors.transparent,
                                                    filled: true,
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey.shade400, fontSize: 13, fontFamily: "Lato"),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide:  BorderSide(color:Colors.grey.shade200,),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide:  BorderSide(color:colorsConst.primary,),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    focusedErrorBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(color:Colors.grey.shade200),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    // errorStyle: const TextStyle(height:0.05,fontSize: 12),
                                                    contentPadding:const EdgeInsets.symmetric(vertical:10.0, horizontal: 10.0),
                                                    errorBorder: OutlineInputBorder(
                                                        borderSide:  BorderSide(color:Colors.grey.shade200),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                  )
                                              ),
                                            ),
                                          ],
                                        ),
                                        15.height,
                                      ],
                                    ),
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width-400)/4.5,
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          hintText:"Account Manager (Optional)",
                                          text:"Account Manager (Optional)",
                                          isOptional: false,
                                          controller: controllers.leadTitleCrt[0],
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                          },
                                        ),
                                        CustomTextField(
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
                                        15.height,
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
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
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
                                        CustomTextField(
                                          hintText:"Company Phone No",
                                          text:"Company\n Phone No.",
                                          controller: controllers.leadCoMobileCrt,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.mobileNumberInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadCoMobile", value.toString().trim());
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
                                        CustomDropDown(
                                          saveValue: controllers.industry,
                                          valueList: controllers.industryList,
                                          text:"Industry",
                                          width:textFieldSize,

                                          //inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            setState((){
                                              controllers.industry= value;
                                            });
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("industry", value.toString().trim());
                                          },
                                        ),
                                        10.height,
                                        CustomTextField(
                                          hintText:"Linkedin(Optional)",
                                          text:"Linkedin(Optional)",
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
                                        15.height,
                                      ],
                                    ),
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width-400)/4.5,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
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
                                        15.height,
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
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
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
                                        // utils.stateDropdown(
                                        //     MediaQuery.of(context).size.width/2-30,
                                        //     controllers.cityController,
                                        //     controllers.stateController,
                                        //     controllers.countryController),
                                        CustomTextField(
                                          hintText:"PIN",
                                          text:"PIN",
                                          controller: controllers.pinCodeController,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.pinCodeInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadPinCode", value.toString().trim());
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width-400)/4.5,
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          hintText:"Street(Optional)",
                                          text:"Street(Optional)",
                                          controller: controllers.streetNameController,
                                          width:textFieldSize,
                                          isOptional: false,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.addressInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadStreet", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          hintText: "City (Optional)",
                                          text: "City (Optional)",
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
                                        // utils.cityDropdown(MediaQuery.of(context).size.width/2-30,
                                        //   controllers.cityController,
                                        //   controllers.stateController,
                                        //   controllers.countryController,
                                        //       (value){
                                        //     //print("cityChanged $value $_selectedCity");
                                        //     value != null ? utils.onSelectedCity(value,controllers.cityController)
                                        //         : utils.onSelectedCity(controllers.selectedCity.value,controllers.cityController);
                                        //   },
                                        // ),
                                        Container(
                                            alignment: Alignment.centerLeft,
                                            width: textFieldSize,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.grey.shade200
                                                )
                                            ),
                                            child:Obx(() =>  CustomText(
                                              text: "    ${controllers.selectedCountry.value}",
                                              colors:colorsConst.textColor,
                                              size: 15,
                                            ),
                                            )
                                        )
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
                                //       colors:colorsConst.textColor,
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
                                //       children:[
                                //         utils.updateTextFieldNearText('Source(Optional)',false),
                                //         16.height,
                                //         utils.updateTextFieldNearText('Status',false),
                                //       ],
                                //     ),
                                //     5.width,
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.end,
                                //       children:[
                                //
                                //         CustomDropDown(
                                //           saveValue: controllers.source,
                                //           valueList: controllers.sourceList,
                                //           text:"Source(Optional)",
                                //           width:textFieldSize,
                                //
                                //           //inputFormatters: constInputFormatters.textInput,
                                //           onChanged:(value) async {
                                //             setState(() {
                                //               controllers.source= value;
                                //             });
                                //             SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                //             sharedPref.setString("source", value.toString().trim());
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
                                //
                                //         ),
                                //         40.height,
                                //         CustomDropDown(
                                //           saveValue: controllers.status,
                                //           valueList: controllers.statusList,
                                //           text:"Status",
                                //           width:textFieldSize,
                                //
                                //           //inputFormatters: constInputFormatters.textInput,
                                //           onChanged:(value) async {
                                //             setState(() {
                                //               controllers.status= value;
                                //             });
                                //             SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                //             sharedPref.setString("status", value.toString().trim());
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
                                //
                                //         ),
                                //       ],
                                //     ),
                                //     SizedBox(
                                //       width: (MediaQuery.of(context).size.width-400)/4.5,
                                //     ),
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       children:[
                                //         utils.updateTextFieldNearText('Lead Owner',false),
                                //         85.height
                                //       ],
                                //     ),
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.end,
                                //       children:[
                                //         CustomTextField(
                                //           hintText:"",
                                //           text:"Lead Owner",
                                //           isOptional: false,
                                //           controller: controllers.leadOwnerNameCrt,
                                //           width:textFieldSize,
                                //           keyboardType: TextInputType.text,
                                //           textInputAction: TextInputAction.next,
                                //           inputFormatters: constInputFormatters.textInput,
                                //           onChanged:(value) async {
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
                                //
                                //         ),
                                //         70.height,
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
                                //         Row(
                                //           children: [
                                //             CustomText(
                                //               //text:"Rating",
                                //               text:"",
                                //               colors:colorsConst.secondary,
                                //               size:15,
                                //             ),
                                //             25.width,
                                //
                                //           ],
                                //         ),
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
                                //
                                //       ],
                                //     ),
                                //   ],
                                // ),
                                20.height,
                                Row(
                                  children:[
                                    CustomText(
                                      text: constValue.customFields,
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
                                  children:[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomTextField(
                                          hintText:"Actions to be taken",
                                          text:"Actions to be taken",
                                          isOptional: false,
                                          controller: controllers.leadActions,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                          },
                                        ),
                                        CustomTextField(
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
                                        // CustomDropDown(
                                        //   saveValue: controllers.service,
                                        //   valueList: controllers.serviceList,
                                        //   text:"Service Interest(Optional)",
                                        //   width:textFieldSize,
                                        //
                                        //   //inputFormatters: constInputFormatters.textInput,
                                        //   onChanged:(value) async {
                                        //     setState(() {
                                        //       controllers.service= value;
                                        //     });
                                        //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                        //     sharedPref.setString("service", value.toString().trim());
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
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width-400)/4.5,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        CustomDropDown(
                                          saveValue: controllers.visitType,
                                          valueList: controllers.callNameList,
                                          text: "Call Visit Type",
                                          width: textFieldSize,
                                          //inputFormatters: constInputFormatters.textInput,
                                          onChanged: (value) async {
                                            setState((){
                                              controllers.visitType = value;
                                            });
                                            SharedPreferences sharedPref =
                                            await SharedPreferences.getInstance();
                                            sharedPref.setString("callVisitType", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          hintText:"Total Number Of Head Count",
                                          text:"Total Number Of Head Count",
                                          isOptional: false,
                                          controller: controllers.noOfHeadCountCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadDescription", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
                                          hintText:"Expected Conversion Date",
                                          text:"Expected Conversion Date",
                                          isOptional: false,
                                          controller: controllers.expectedConversionDateCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadDescription", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
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
                                        CustomTextField(
                                          hintText:"Prospect Enrollment Date",
                                          text:"Prospect Enrollment Date",
                                          isOptional: false,
                                          controller: controllers.prospectEnrollmentDateCrt,
                                          width:textFieldSize,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: constInputFormatters.textInput,
                                          onChanged:(value) async {
                                            SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                            sharedPref.setString("leadDescription", value.toString().trim());
                                          },
                                        ),
                                        CustomTextField(
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
                                      apiService.updateLeadAPI(context,widget.id.toString(),widget.addressId.toString());
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
                                    textColor: Colors.black,
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
