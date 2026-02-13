import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
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
import '../utilities/utils.dart';
import 'otp_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver{
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var isEyeOpen = false;
  var isLoading = false.obs;
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
        controllers.loginPassword.text = isRelease==false?"a1b2CC##":"Mahesh@123";
      }
    });
  }
  //santhiya2
  final FocusNode mobileFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Initial page load focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && mobileFocus.canRequestFocus) {
        mobileFocus.requestFocus();
      }
    });

    readValue();
  }

  //santhiya2
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mobileFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     FocusScope.of(context).requestFocus(mobileFocus);
    //   }
    // });
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
                        //Santhiya
                        onEdit: () {
                          controllers.loginCtr.start();
                          if (controllers.loginNumber.text.isEmpty) {
                            mobileUtils.snackBar(
                                context: Get.context!,
                                msg: "Please enter your mobile number",
                                color: Colors.red);
                            controllers.loginCtr.reset();
                            FocusScope.of(context).requestFocus(mobileFocus);
                          }
                          else if (controllers.loginNumber.text.length != 10) {
                            mobileUtils.snackBar(
                                context: Get.context!,
                                msg: "Please enter 10 digits mobile number",
                                color: Colors.red);
                            controllers.loginCtr.reset();
                            FocusScope.of(context).requestFocus(mobileFocus);
                          }
                          else if (controllers.loginPassword.text.isEmpty) {
                            mobileUtils.snackBar(
                                context: Get.context!,
                                msg: "Please enter your password",
                                color: Colors.red);
                            controllers.loginCtr.reset();
                            FocusScope.of(context).requestFocus(passwordFocus);
                          }
                          else if (controllers.loginPassword.text.length < 8 ||
                              controllers.loginPassword.text.length > 16) {
                            mobileUtils.snackBar(
                                context: Get.context!,
                                msg: "Password must be 8–16 characters",
                                color: Colors.red);
                            controllers.loginCtr.reset();
                            FocusScope.of(context).requestFocus(passwordFocus);
                          }
                          else {
                            FocusScope.of(context).unfocus();
                            apiService.loginCApi(context);
                          }
                          controllers.loginCtr.reset();
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(()=>TextButton(
                          onPressed: isLoading.value==true
                              ? null // ⭐ button disable
                              : () async {
                            if (controllers.loginNumber.text.isEmpty) {
                              mobileUtils.snackBar(
                                context: Get.context!,
                                msg: "Please enter your mobile number",
                                color: Colors.red,
                              );
                              FocusScope.of(context).requestFocus(mobileFocus);
                            }

                            await checkMobileAPI(
                              mobile: controllers.loginNumber.text.trim(),
                            );
                          },
                          child: CustomText(
                            text: "Forgot Password?",
                            colors: colorsConst.primary,
                            size: 14,
                            isCopy: false,
                          ),
                        )),
                      ],
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
                        }
                        else if (controllers.loginNumber.text.length != 10) {
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Please enter 10 digits mobile number",
                              color: Colors.red);
                          controllers.loginCtr.reset();
                          FocusScope.of(context).requestFocus(mobileFocus);
                        }
                        else if (controllers.loginPassword.text.isEmpty) {
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Please enter your password",
                              color: Colors.red);
                          controllers.loginCtr.reset();
                          FocusScope.of(context).requestFocus(passwordFocus);
                        }
                        else if (controllers.loginPassword.text.length < 8 ||
                            controllers.loginPassword.text.length > 16) {
                          mobileUtils.snackBar(
                              context: Get.context!,
                              msg: "Password must be 8–16 characters",
                              color: Colors.red);
                          controllers.loginCtr.reset();
                          FocusScope.of(context).requestFocus(passwordFocus);
                        }
                        else {
                          FocusScope.of(context).unfocus();
                          apiService.loginCApi(context);
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
  Future<bool> checkMobileAPI({required String mobile})  async {
    try {
      isLoading.value=true;
      Map data = {
        "mobile_number": mobile,
        "action": "check_mobile"
      };
      log(data.toString());
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      log("res ${request.body}");

      Map<String, dynamic> response = json.decode(request.body.trim());
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return checkMobileAPI(mobile: mobile);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200 && response.containsKey("s_name")) {
        // log("res $response");
        if (isRelease) {

          await apiService.sendOtpAPI(
            mobile: controllers.loginNumber.text.trim(),
          );

          showOtpDialog(
            context,
            mobile: controllers.loginNumber.text.trim(),
          );

        } else {
          await showForgotPasswordDialog(
            context,
            controllers.loginNumber.text.trim(),
          );
        }
        return true;
      } else {
        //Santhiya
        utils.snackBar(
            msg: "Mobile number not registered", color: Colors.red, context: Get.context!);
        isLoading.value=false;
        return false;
      }
    } catch (e) {
      //Santhiya
      utils.snackBar(
          msg: "Mobile number not registered", color: Colors.red, context: Get.context!);
      isLoading.value=false;
      return false;
    }
  }

  Future<void> showForgotPasswordDialog(BuildContext context,String mobile) async {
    mobileFocus.unfocus();
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    String? errorMessage;
    final FocusNode passwordFocus1 = FocusNode();
    final FocusNode passwordFocus2 = FocusNode();
    bool isStrongPassword(String password) {
      final regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
      );
      return regex.hasMatch(password);
    }
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (passwordFocus1.canRequestFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
                mobileFocus.unfocus();
                passwordFocus1.requestFocus();
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: CustomText(
                text: "Reset Password",
                isBold: true,
                size: 17,
                isCopy: false,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    autofocus: true,
                    focusNode: passwordFocus1,
                    controller: passwordController,
                    text: 'New Password',
                    hintText: 'Enter Your New Password',
                    width: MediaQuery.of(context).size.width / 3.5,
                    //height: 40,
                    textInputAction: TextInputAction.next,
                    inputFormatters: constInputFormatters.passwordInput,
                    keyboardType: TextInputType.number,
                    isOptional: true,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(passwordFocus2);
                    },
                  ),
                  CustomTextField(
                    focusNode: passwordFocus2,
                    controller: confirmPasswordController,
                    text: 'Confirm Password',
                    hintText: 'Re-enter Password',
                    width: MediaQuery.of(context).size.width / 3.5,
                    //height: 40,
                    //errorText: errorMessage,
                    textInputAction: TextInputAction.next,
                    inputFormatters: constInputFormatters.passwordInput,
                    keyboardType: TextInputType.number,
                    isOptional: true,
                    onEdit: () {
                      controllers.loginCtr.start();

                      String pass = passwordController.text.trim();
                      String confirm = confirmPasswordController.text.trim();

                      if (pass.isEmpty || confirm.isEmpty) {
                        controllers.loginCtr.reset();

                        setState(() {
                          errorMessage = "Please fill both password fields";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }
                      if (pass.length < 8 ||
                          pass.length > 16) {
                        controllers.loginCtr.reset();

                        setState(() {
                          errorMessage =
                          "Password must be 8–16 characters";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }

                      if (pass != confirm) {
                        controllers.loginCtr.reset();

                        setState(() {
                          errorMessage = "Passwords do not match";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }

                      // ✅ Strong password validation
                      if (!isStrongPassword(pass)) {
                        controllers.loginCtr.reset();

                        setState(() {
                          errorMessage =
                          "Password must contain at least 8 characters, one uppercase letter,one lowercase letter, one number and one special character";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }

                      // ✅ Clear error
                      setState(() {
                        errorMessage = "";
                      });

                      FocusScope.of(context).unfocus();

                      apiService.resetPasswordAPI(
                        mobile: mobile.trim(),
                        pass: pass,
                      );
                    },
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3.5,
                      child: CustomText(
                        text: errorMessage!,
                        colors: Colors.red,
                        textAlign: TextAlign.start, // 👈 add this
                        size: 14,
                        isCopy: false,
                      ),
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    isLoading.value = false;
                    Navigator.pop(context);
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (mounted && mobileFocus.canRequestFocus) {
                        mobileFocus.requestFocus();
                      }
                    });
                  },
                  child: Text("Cancel"),
                ),
                CustomLoadingButton(
                    callback: () {
                      String pass = passwordController.text.trim();
                      String confirm = confirmPasswordController.text.trim();

                      if (pass.isEmpty || confirm.isEmpty) {
                        controllers.loginCtr.reset();

                        setState(() {
                          errorMessage = "Please fill both password fields";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }
                      if (pass.length < 8 ||
                          pass.length > 16) {
                        controllers.loginCtr.reset();

                        setState(() {
                          errorMessage =
                          "Password must be 8–16 characters";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }

                      if (pass != confirm) {
                        controllers.loginCtr.reset();

                        setState(() {
                          errorMessage = "Passwords do not match";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }

                      // ✅ Strong password validation
                      if (!isStrongPassword(pass)) {
                        controllers.loginCtr.reset();

                        setState(() {//one
                          errorMessage =
                          "Password must contain at least 8 characters, one uppercase letter, one lowercase letter, one number and one special character";
                        });

                        FocusScope.of(context).requestFocus(passwordFocus1);
                        return;
                      }

                      // ✅ Clear error
                      setState(() {
                        errorMessage = "";
                      });

                      FocusScope.of(context).unfocus();

                      apiService.resetPasswordAPI(
                        mobile: mobile.trim(),
                        pass: pass,
                      );
                    },
                    isLoading: true,
                    text: "Reset",
                    textSize: 20,
                    textColor: Colors.white,
                    controller: controllers.loginCtr,
                    backgroundColor: colorsConst.primary,
                    radius: 5,
                    height: 60,
                    width: 140
                ),
              ],
            );
          },
        );
      },
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
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {

      // If dialog open, don't steal focus
      if (Get.isDialogOpen == true) return;

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && mobileFocus.canRequestFocus) {
          mobileFocus.requestFocus();
        }
      });
    }
  }

}