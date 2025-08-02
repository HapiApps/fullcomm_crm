import 'dart:async';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/password_text_field.dart';
import '../../controller/controller.dart';
import '../../services/api_services.dart';
import '../constant/colors_constant.dart';
import '../constant/key_constant.dart';
import '../utilities/utils.dart';



class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {


  @override
  void initState(){
    super.initState();
   Future.delayed(Duration.zero,(){
     check();
   });
  }

  void check() async {
    controllers.oldIndex.value=controllers.selectedIndex.value;
    controllers.selectedIndex.value=6;
    final prefs =await SharedPreferences.getInstance();
      Future.delayed(Duration.zero,(){
        setState((){
          controllers.signFirstName.text=prefs.getString("sign_first_name")??"";
          controllers.signMobileNumber.text=prefs.getString("sign_mobile_number")??"";
          controllers.signWhatsappNumber.text=prefs.getString("sign_whatsapp_number")??"";
          controllers.signPassword.text=prefs.getString("sign_password")??"";
          controllers.signEmailID.text=prefs.getString("sign_email_id")??"";
        });
      });
  }
  DateTime? currentBackPressTime;
  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: ()async{
        controllers.selectedIndex.value=controllers.oldIndex.value;
        return true;
      },
      child: Scaffold(
        backgroundColor: colorsConst.primary,
        body:Row(
          children:[
            utils.sideBarFunction(context),
            20.width,
            MediaQuery.of(context).size.width<=987?0.width:Container(
              width: MediaQuery.of(context).size.width/2.2,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              color: colorsConst.secondary,
              child: SvgPicture.asset("assets/images/signUp.svg",
                  height: MediaQuery.of(context).size.height-300),
            ),
            Container(
              width: MediaQuery.of(context).size.width<=987?MediaQuery.of(context).size.width-200:MediaQuery.of(context).size.width/2.5,
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomText(
                      text: "Personal Information",
                      colors: colorsConst.textColor,
                      size: 25,
                      isBold: true,
                    ),
                    50.height,
                    // InkWell(
                    //   onTap:(){
                    //     utils.chooseFile(mediaDataV:controllers.empMediaData,
                    //         fileName:controllers.empFileName,pathName:controllers.photo1);
                    //   },
                    //   child: Obx(() => controllers.photo1.value.isEmpty?Container(
                    //     width: 100,
                    //     height: 100,
                    //     decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(100),
                    //         color: Colors.grey.shade300
                    //     ),
                    //     child: Center(
                    //       child:SvgPicture.asset(assets.choosePerson,
                    //         width: 50,height: 50,),
                    //     ),
                    //   ):Image.memory(base64Decode(controllers.photo1.value),
                    //     fit: BoxFit.cover,width: 80,height: 80,),
                    //   ),
                    // ),
                    // 20.height,

                    //utils.pre(controllers.prefix,Colors.grey),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            5.height,
                            utils.textFieldNearText('First Name',true),
                            utils.textFieldNearText('Last Name',false),
                            utils.textFieldNearText('E-mail',false),
                            utils.textFieldNearText('Mobile Number',true),
                            20.height,
                            //utils.textfieldNearText('WhatsApp Number'),
                            utils.textFieldNearText('Password',true),
                            utils.textFieldNearText('Role',true),
                            utils.textFieldNearText('Referred By',false),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomTextField(
                              text: "First Name",
                              controller: controllers.signFirstName,
                              width:MediaQuery.of(context).size.width/5,
                              textInputAction: TextInputAction.next,
                              inputFormatters: constInputFormatters.textInput,
                              keyboardType: TextInputType.text,
                              height:40,
                              onChanged:(value) async {
                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                sharedPref.setString("sign_first_name", value.toString().trim());
                              },
                            ),
                            CustomTextField(
                              text: "Last Name",
                              controller: controllers.signLastName,
                              width:MediaQuery.of(context).size.width/5,
                              textInputAction: TextInputAction.next,
                              inputFormatters: constInputFormatters.textInput,
                              keyboardType: TextInputType.text,
                              height:40,
                              onChanged:(value) async {
                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                sharedPref.setString("sign_last_name", value.toString().trim());
                              },
                            ),
                            CustomTextField(
                              text: "E-mail", controller: controllers.signEmailID,
                              width:MediaQuery.of(context).size.width/5,
                              height:40,
                              textInputAction: TextInputAction.next,
                              inputFormatters: constInputFormatters.emailInput,
                              keyboardType: TextInputType.emailAddress,
                              onChanged:(value) async {
                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                sharedPref.setString("sign_email_id", value.toString().trim());
                              },
                            ),
                            CustomText(
                              textAlign: TextAlign.end,
                              text:"Whatsapp No",
                              colors:colorsConst.headColor,
                              size:15,
                            ),
                            Row(
                              children:[
                                25.width,
                                SizedBox(
                                  width:MediaQuery.of(context).size.width/5,
                                  height: 80,
                                  child: TextFormField(
                                      style: const TextStyle(
                                          color:Colors.white,fontSize: 14,
                                          fontFamily:"Lato"
                                      ),
                                      cursorColor: Colors.white,
                                      onChanged:(value) async {
                                        SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                        sharedPref.setString("sign_mobile_number", value.toString().trim());
                                      },
                                      onTap:(){},
                                      keyboardType: TextInputType.number,
                                      inputFormatters: constInputFormatters.mobileNumberInput,
                                      textCapitalization: TextCapitalization.none,

                                      controller: controllers.signMobileNumber,
                                      textInputAction: TextInputAction.next,
                                      decoration:InputDecoration(
                                        // hintText:"Mobile No.",
                                        // hintStyle: TextStyle(
                                        //     color:Colors.grey.shade400,
                                        //     fontSize: 13,
                                        //     fontFamily:"Lato"
                                        // ),
                                        fillColor:Colors.transparent,
                                        filled: true,
                                        //prefixIcon:IconButton(onPressed: (){}, icon: SvgPicture.asset(assets.gPhone,width:15,height:15) ),

                                        suffixIcon:Obx(()=>Checkbox(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            side: MaterialStateBorderSide.resolveWith(
                                                  (states) => BorderSide(width: 1.0, color: colorsConst.textColor),
                                            ),
                                            hoverColor:Colors.transparent,
                                            focusColor:Colors.transparent,
                                            activeColor:colorsConst.third,
                                            value:controllers.isWhatsApp.value,
                                            onChanged:(value){
                                              //setState((){
                                              controllers.isWhatsApp.value=value!;
                                              if(controllers.isWhatsApp.value==true){
                                                controllers.signWhatsappNumber.text=controllers.signWhatsappNumber.text;
                                              }else{
                                                controllers.signWhatsappNumber.text="";
                                              }
                                              //});
                                            }),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide:  BorderSide(color:Colors.grey.shade200,),
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:  BorderSide(color:Colors.grey.shade200,),
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

                            // CustomTextField(
                            //   text: "WhatsApp Number",
                            //   controller: controllers.signWhatsappNumber,
                            //   width:MediaQuery.of(context).size.width/5,
                            //   height:40,
                            //   textInputAction: TextInputAction.next,
                            //   inputFormatters: constInputFormatters.mobileNumberInput,
                            //   keyboardType: TextInputType.number,
                            //   onChanged:(value) async {
                            //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
                            //     sharedPref.setString("sign_whatsapp_number", value.toString().trim());
                            //   },
                            // ),
                            //5.height,
                            CustomPasswordTextField(
                              text: "Password",
                              controller: controllers.signPassword,
                              width:MediaQuery.of(context).size.width/5,height:40,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.visiblePassword,
                              isLogin: true,
                              isOptional: true,
                              onChanged:(value) async {
                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                sharedPref.setString("sign_password", value.toString().trim());
                              },
                            ),
                            15.height,
                            CustomDropDown(
                              saveValue: controllers.role,
                              valueList: controllers.roleNameList,
                              text:"Role",
                              width:MediaQuery.of(context).size.width/5,
                              //inputFormatters: constInputFormatters.textInput,
                              onChanged:(value) async {
                                setState((){
                                  controllers.role= value;
                                });
                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                sharedPref.setString("role", value.toString().trim());
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
                              text: "Referred By",
                              controller: controllers.signReferBy,
                              width:MediaQuery.of(context).size.width/5,
                              textInputAction: TextInputAction.next,
                              inputFormatters: constInputFormatters.textInput,
                              keyboardType: TextInputType.text,
                              height:40,
                              onChanged:(value) async {
                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                sharedPref.setString("sign_referred", value.toString().trim());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),


                    50.height,
                    CustomLoadingButton(
                      callback:(){
                        if(controllers.signFirstName.text.isEmpty){
                          utils.snackBar(context: Get.context!, msg: "Please enter first name",color:colorsConst.primary);
                          controllers.loginCtr.reset();
                        }else if(controllers.signMobileNumber.text.isEmpty){
                          utils.snackBar(context: Get.context!, msg: "Please enter mobile",color:colorsConst.primary);
                          controllers.loginCtr.reset();
                        }else if(controllers.signPassword.text.isEmpty){
                          utils.snackBar(context: Get.context!, msg: "Please enter password",color:colorsConst.primary);
                          controllers.loginCtr.reset();
                        }else if(controllers.role==null){
                          utils.snackBar(context: Get.context!, msg: "Please enter role",color:colorsConst.primary);
                          controllers.loginCtr.reset();
                        }else{
                          if(controllers.signEmailID.text.isEmail){
                            apiService.insertUsersPHP(context);
                          }else{
                            utils.snackBar(context: Get.context!, msg: "Please enter Email",color:colorsConst.primary);
                             controllers.loginCtr.reset();
                          }
                         }
                      },
                      isLoading: true,
                      backgroundColor: colorsConst.primary,
                      textColor: Colors.white,
                      radius: 3,
                      width: 150,
                      text: "Add Profile",
                      height: 50,
                      controller: controllers.loginCtr,
                    ),
                    30.height
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}



