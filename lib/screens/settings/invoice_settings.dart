import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/screens/settings/terms_conditions.dart';
import 'package:get/get.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/product_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../services/api_services.dart';
import 'lead_categories.dart';

class InvoiceSetting extends StatefulWidget {
  const InvoiceSetting({super.key});

  @override
  State<InvoiceSetting> createState() => _InvoiceSettingState();
}

class _InvoiceSettingState extends State<InvoiceSetting> {
  final FocusNode name = FocusNode();
  final FocusNode phone = FocusNode();
  final FocusNode email = FocusNode();
  final FocusNode gst = FocusNode();
  final FocusNode door = FocusNode();
  final FocusNode street = FocusNode();
  final FocusNode city = FocusNode();
  final FocusNode state = FocusNode();
  final FocusNode country = FocusNode();
  final FocusNode pincode = FocusNode();
  final FocusNode bank = FocusNode();
  final FocusNode branch = FocusNode();
  final FocusNode ifsc = FocusNode();
  final FocusNode acc = FocusNode();
  final FocusNode upi = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(name);
    });
  }
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    gst.dispose();
    door.dispose();
    street.dispose();
    city.dispose();
    state.dispose();
    country.dispose();
    pincode.dispose();
    bank.dispose();
    branch.dispose();
    ifsc.dispose();
    acc.dispose();
    upi.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: (){
                          Get.back();
                        },
                          icon: Icon(Icons.arrow_back)),
                      CustomText(
                        text: "Invoice Settings",
                        colors: colorsConst.textColor,
                        size: 20,
                        isBold: true,
                        isCopy: true,
                      ),
                    ],
                  ),
                  10.height,
                  CustomText(
                    text: "Manage global settings across the application.  \n",
                    colors: colorsConst.textColor,
                    isCopy: true,
                    size: 14,
                  ),
                  5.height,
                  Divider(
                      color: Colors.grey
                  ),
                  CustomText(text: "Company Information", isCopy:  false,isBold: true,size: 17,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            CustomTextField(
                                width: MediaQuery.of(context).size.width*0.3,
                                text: "Company Name",hintText: "Company Name",
                                controller: controllers.comName,
                                focusNode: name,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(phone);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "Company Name",hintText: "Company Name",
                              controller: controllers.comNumber,
                              width: MediaQuery.of(context).size.width*0.3,
                              focusNode: phone,
                              inputFormatters: constInputFormatters.mobileNumberInput,
                              onChanged: (value) {
                                controllers.firstCaps(value.toString(),controllers.iNo);
                              },
                              onFieldSubmitted: (value){
                                FocusScope.of(context).requestFocus(email);
                              },
                            ),
                            CustomTextField(text: "Email",hintText: "Email",
                                controller: controllers.comEmail,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: email,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(gst);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "GSTIN Number",hintText: "GSTIN Number",
                                controller: controllers.comGSTNo,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: gst,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(door);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(
                                width: MediaQuery.of(context).size.width*0.3,
                                text: "Door No",hintText: "Door No",
                                controller: controllers.comDoor,
                                focusNode: door,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(street);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            CustomTextField(text: "Street Name",hintText: "Street Name",
                              controller: controllers.comStreet,
                              width: MediaQuery.of(context).size.width*0.3,
                              focusNode: street,
                              onChanged: (value) {
                                controllers.firstCaps(value.toString(),controllers.iNo);
                              },
                              onFieldSubmitted: (value){
                                FocusScope.of(context).requestFocus(city);
                              },
                            ),
                            CustomTextField(text: "City",hintText: "City",
                                controller: controllers.comCity,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: city,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(state);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "State",hintText: "State",
                                controller: controllers.comState,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: state,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(country);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "Country",hintText: "Country",
                                controller: controllers.comCountry,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: country,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(pincode);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "Pincode",hintText: "Pincode",
                                controller: controllers.comPincode,
                                inputFormatters: constInputFormatters.pinCodeInput,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: pincode,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(bank);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                  if (controllers.comPincode.text.trim().length ==6) {
                                    apiService.fetchPinCodeData2(controllers.comPincode.text.trim());
                                  }
                                }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: "Bank Information", isCopy:  false,size: 17,isBold: true,),
                            CustomTextField(text: "Bank Name",hintText: "Bank Name",
                                controller: controllers.bankName,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: bank,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(branch);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "Branch Name",hintText: "Branch Name",
                                controller: controllers.branchName,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: branch,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(ifsc);
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "IFSC Code",hintText: "IFSC Code",
                                controller: controllers.ifscCode,
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: ifsc,
                                inputFormatters: [
                                  UpperCaseTextFormatter(),
                                  LengthLimitingTextInputFormatter(11),
                                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
                                ],
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(acc);
                                },
                                onChanged: (value) {
                                  controllers.fullCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "Account Number",hintText: "Account Number",
                                controller: controllers.accNo,
                                inputFormatters: [
                                  UpperCaseTextFormatter(),
                                  LengthLimitingTextInputFormatter(15),
                                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
                                ],
                                width: MediaQuery.of(context).size.width*0.3,
                                focusNode: acc,
                                onFieldSubmitted: (value){
                                  FocusScope.of(context).requestFocus(upi);
                                },
                                onChanged: (value) {
                                  controllers.fullCaps(value.toString(),controllers.iNo);
                                }
                            ),
                            CustomTextField(text: "UPI Number",hintText: "UPI Number",
                                width: MediaQuery.of(context).size.width*0.3,
                                controller: controllers.upiNo,
                                focusNode: upi,
                                onFieldSubmitted: (value){
                                  controllers.leadCtr.start();
                                  if(controllers.comName.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill company name", color: Colors.red);
                                  }else if(controllers.comNumber.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill phone number", color: Colors.red);
                                  }else if(controllers.comNumber.text.length!=10){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please check phone number", color: Colors.red);
                                  }else if(controllers.comEmail.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill email", color: Colors.red);
                                  }else if(!utils.isValidEmail(controllers.comEmail.text.trim())){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please check email", color: Colors.red);
                                  }else if(controllers.comGSTNo.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill GSTIN number", color: Colors.red);
                                  }else if(controllers.comDoor.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill door number", color: Colors.red);
                                  }else if(controllers.comStreet.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill street name", color: Colors.red);
                                  }else if(controllers.comCity.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill city", color: Colors.red);
                                  }else if(controllers.comState.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill state", color: Colors.red);
                                  }else if(controllers.comCountry.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill country", color: Colors.red);
                                  }else if(controllers.comPincode.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill pincode", color: Colors.red);
                                  }else if(controllers.comPincode.text.length!=6){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please check pincode", color: Colors.red);
                                  }else if(controllers.bankName.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill bank name", color: Colors.red);
                                  }else if(controllers.branchName.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill branch name", color: Colors.red);
                                  }else if(controllers.ifscCode.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill IFSC code", color: Colors.red);
                                  }else if(controllers.ifscCode.text.length!=11){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please check IFSC code", color: Colors.red);
                                  }else if(controllers.accNo.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill account number", color: Colors.red);
                                  }else if(controllers.upiNo.text.trim().isEmpty){
                                    controllers.leadCtr.reset();
                                    utils.snackBar(context: context, msg: "Please fill UPI number", color: Colors.red);
                                  }else{
                                    controllers.insertSeriesNo(context,false);
                                  }
                                },
                                onChanged: (value) {
                                  controllers.firstCaps(value.toString(),controllers.iNo);
                                }
                            ),
                          ],
                        ),
                        CustomLoadingButton(
                          callback: (){
                            if(controllers.comName.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill company name", color: Colors.red);
                            }else if(controllers.comNumber.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill phone number", color: Colors.red);
                            }else if(controllers.comNumber.text.length!=10){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please check phone number", color: Colors.red);
                            }else if(controllers.comEmail.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill email", color: Colors.red);
                            }else if(!utils.isValidEmail(controllers.comEmail.text.trim())){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please check email", color: Colors.red);
                            }else if(controllers.comGSTNo.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill GSTIN number", color: Colors.red);
                            }else if(controllers.comDoor.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill door number", color: Colors.red);
                            }else if(controllers.comStreet.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill street name", color: Colors.red);
                            }else if(controllers.comCity.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill city", color: Colors.red);
                            }else if(controllers.comState.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill state", color: Colors.red);
                            }else if(controllers.comCountry.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill country", color: Colors.red);
                            }else if(controllers.comPincode.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill pincode", color: Colors.red);
                            }else if(controllers.comPincode.text.length!=6){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please check pincode", color: Colors.red);
                            }else if(controllers.bankName.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill bank name", color: Colors.red);
                            }else if(controllers.branchName.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill branch name", color: Colors.red);
                            }else if(controllers.ifscCode.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill IFSC code", color: Colors.red);
                            }else if(controllers.ifscCode.text.length!=11){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please check IFSC code", color: Colors.red);
                            }else if(controllers.accNo.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill account number", color: Colors.red);
                            }else if(controllers.upiNo.text.trim().isEmpty){
                              controllers.leadCtr.reset();
                              utils.snackBar(context: context, msg: "Please fill UPI number", color: Colors.red);
                            }else{
                              controllers.insertSeriesNo(context,false);
                            }
                          }, isLoading: true, controller: controllers.leadCtr,
                          backgroundColor: colorsConst.primary, radius: 10, width: 200,text: "Save",)
                      ],
                    ),
                  ),
                  100.height
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
