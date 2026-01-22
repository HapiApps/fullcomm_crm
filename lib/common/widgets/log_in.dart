import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:fullcomm_crm/components/password_text_field.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';
import '../constant/key_constant.dart';
import '../utilities/mobile_snackbar.dart';
import 'otp_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var isEyeOpen = false;
  DateTime? currentBackPressTime;
  var back = 0;
  Future<void> readValue() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final mobileNumber = sharedPref.getString("loginNumber") ?? "";
    final password = sharedPref.getString("loginPassword") ?? "";
    setState(() {
      controllers.loginNumber.text = mobileNumber.toString();
      controllers.loginPassword.text = password.toString();
      if (kDebugMode) {
        controllers.loginNumber.text = isRelease==false?"9999999991":"8220074826";
        controllers.loginPassword.text = isRelease==false?"12345678":"Mahesh@123";
      }
    });
  }
  //santhiya2
  final FocusNode mobileFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    readValue();
  }
  //santhiya2
  @override
  void dispose() {
    mobileFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (back == 0) {
          mobileUtils.snackBar(
              context: Get.context!,
              msg: "Press back button again to exit !",
              color: Colors.red);
          back = 1;
        } else {
          SystemNavigator.pop();
        }
        // if (!didPop) {
        //   final shouldExit = await utils.showExitDialog(context);
        //   if (shouldExit) {
        //     html.window.open("https://www.google.com", "_self");
        //   }
        // }
      },
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.3,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              //color: Colors.orange[50],
              //color: colorsConst.secondary,
              child: Image.asset("assets/images/login.png"),
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 2.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Image.asset("assets/images/ARUU.png"),
                  Image.asset(loginLogo,height: 100,),
                  //50.height,
                  Text("Login",
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )
                  ),
                  20.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextField(
                        focusNode: mobileFocus,
                        onChanged: (value) async {
                          SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          sharedPref.setString("loginNumber", value.toString().trim());
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(passwordFocus);
                        },
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 40,
                        textInputAction: TextInputAction.next,
                        inputFormatters: constInputFormatters.mobileNumberInput,
                        keyboardType: TextInputType.number,
                        controller: controllers.loginNumber,
                        text: MediaQuery.of(context).size.width <= 987
                            ? 'Mobile'
                            : 'Mobile Number',
                        hintText: MediaQuery.of(context).size.width <= 987
                            ? 'Mobile'
                            : 'Enter Your Mobile Number',
                        isOptional: true,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPasswordTextField(
                        focusNode: passwordFocus,
                        onChanged: (value) async {
                          SharedPreferences sharedPref = await SharedPreferences.getInstance();
                          sharedPref.setString("loginPassword", value.toString().trim());
                        },
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 40,
                        isLogin: true,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        controller: controllers.loginPassword,
                        inputFormatters: constInputFormatters.passwordInput,
                        text: 'Password',
                        hintText: 'Enter Your Password',
                        isOptional: true,
                      ),
                    ],
                  ),
                  InkWell(
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: ()async{
                      if(controllers.loginNumber.text.isEmpty) {
                        mobileUtils.snackBar(
                            context: Get.context!,
                            msg: "Please enter your mobile number",
                            color: Colors.red);
                      }else{
                        bool isCheck = await apiService.checkMobileAPI(mobile: controllers.loginNumber.text.trim());
                        if(!isCheck){
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Mobile number not registered",
                              color: Colors.red);
                          return;
                        }
                        if(isRelease) {
                          apiService.sendOtpAPI(mobile: controllers
                              .loginNumber.text.trim());
                          showOtpDialog(context, mobile: controllers
                              .loginNumber.text.trim());
                        }else{
                          showForgotPasswordDialog(context, controllers.loginNumber.text.trim());
                        }
                      }
                    },
                    child: Container(
                      alignment: Alignment.bottomRight,
                      width: MediaQuery.of(context).size.width / 3.5,
                      child: CustomText(text: "Forgot Password?",
                        colors: colorsConst.primary,
                        size: 14,
                        isCopy: false,
                      ),
                    ),
                  ),
                  70.height,
                  CustomLoadingButton(
                      callback: () {
                        if (controllers.loginNumber.text.isEmpty) {
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Please enter your mobile number",
                              color: Colors.red);
                          controllers.loginCtr.reset();
                          FocusScope.of(context).requestFocus(mobileFocus);
                        } else if (controllers.loginNumber.text.length != 10) {
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Please enter 10 digits mobile number",
                              color: Colors.red);
                          controllers.loginCtr.reset();
                          FocusScope.of(context).requestFocus(mobileFocus);
                        } else if (controllers.loginPassword.text.isEmpty) {
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Please enter your password",
                              color: Colors.red);
                          controllers.loginCtr.reset();
                          FocusScope.of(context).requestFocus(passwordFocus);
                        } else if (controllers.loginPassword.text.length < 8 ||
                            controllers.loginPassword.text.length > 16) {
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Password must be 8–16 characters",
                              color: Colors.red);
                          controllers.loginCtr.reset();
                          FocusScope.of(context).requestFocus(passwordFocus);
                        } else {
                          FocusScope.of(context).unfocus();
                          apiService.loginCApi();
                        }
                      },

                      isLoading: true,
                      text: "Login",
                      textSize: 20,
                      textColor: Colors.white,
                      controller: controllers.loginCtr,
                      backgroundColor: colorsConst.primary,
                      radius: 5,
                      height: 60,
                      width: 170),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showOtpDialog(BuildContext context, {required String mobile}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: OtpDialogContent(mobile: mobile),
        );
      },
    );
  }

}