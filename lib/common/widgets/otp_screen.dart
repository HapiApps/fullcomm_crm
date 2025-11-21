import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';

import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';
import '../../services/api_services.dart';
import '../constant/colors_constant.dart';
import '../constant/key_constant.dart';
import '../utilities/utils.dart';

class OtpDialogContent extends StatefulWidget {
  final String mobile;

  const OtpDialogContent({super.key,required this.mobile});

  @override
  State<OtpDialogContent> createState() => _OtpDialogContentState();
}

class _OtpDialogContentState extends State<OtpDialogContent> {
  late OtpFieldControllerV2 otpController;

  @override
  void initState() {
    super.initState();
    otpController = OtpFieldControllerV2();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 430,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
             CustomText(
              text: "OTP Verification",
              colors: colorsConst.primary,
              size: 22,
              isBold: true,
            ),
            20.height,
            CustomText(
              text: "Enter the OTP sent to ........${widget.mobile.substring(8)}",
              colors: Colors.black,
            ),
            20.height,
            OTPTextFieldV2(
              controller: otpController,
              length: 6,
              width: MediaQuery.of(context).size.width,
              textFieldAlignment: MainAxisAlignment.spaceEvenly,
              fieldWidth: 40,
              fieldStyle: FieldStyle.box,
              keyboardType: const TextInputType.numberWithOptions(),
              inputFormatter: constInputFormatters.mobileNumberInput,
              outlineBorderRadius: 5,
              otpFieldStyle: OtpFieldStyle(
                focusBorderColor: colorsConst.primary,
                disabledBorderColor: Colors.grey,
                enabledBorderColor: colorsConst.primary,
              ),
              style: const TextStyle(color: Colors.black),
              onCompleted: (pin) {
                if (controllers.otp.value == pin) {
                  Navigator.pop(context);
                  showForgotPasswordDialog(context,widget.mobile);
                } else {
                  utils.snackBar(
                      context: context,
                      msg: 'OTP does not match',
                      color: Colors.red);
                }
              },
            ),

            20.height,

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(text: "Didn't receive OTP?", colors: Colors.grey, size: 15),
                TextButton(
                    onPressed: () {
                      apiService.sendOtpAPI(mobile: widget.mobile);
                    },
                    child: CustomText(
                      text: "RESEND",
                      colors: colorsConst.primary,
                      size: 13,
                      isBold: true,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

}
void showForgotPasswordDialog(BuildContext context,String mobile) {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String? errorMessage;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: CustomText(
              text: "Reset Password",
              isBold: true,
              size: 17,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: passwordController,
                  text: 'New Password',
                  hintText: 'Enter Your New Password',
                  width: MediaQuery.of(context).size.width / 3.5,
                  //height: 40,
                  textInputAction: TextInputAction.next,
                  inputFormatters: constInputFormatters.mobileNumberInput,
                  keyboardType: TextInputType.number,
                  isOptional: true,
                ),
                CustomTextField(
                  controller: confirmPasswordController,
                  text: 'Confirm Password',
                  hintText: 'Re-enter Password',
                  width: MediaQuery.of(context).size.width / 3.5,
                  //height: 40,
                  //errorText: errorMessage,
                  textInputAction: TextInputAction.next,
                  inputFormatters: constInputFormatters.mobileNumberInput,
                  keyboardType: TextInputType.number,
                  isOptional: true,
                ),
                if (errorMessage != null) ...[
                  CustomText(
                    text: errorMessage!,
                    colors: Colors.red,
                    size: 14,
                  ),
          ]
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              CustomLoadingButton(
                  callback: () {
                    String pass = passwordController.text.trim();
                    String confirm = confirmPasswordController.text.trim();
                    if (pass.isEmpty || confirm.isEmpty) {
                      controllers.loginCtr.reset();
                      setState(() {
                        errorMessage = "Please fill both fields";
                      });
                      return;
                    }
                    if (pass != confirm) {
                      controllers.loginCtr.reset();
                      setState(() {
                        errorMessage = "Passwords do not match";
                      });
                      return;
                    }
                    apiService.resetPasswordAPI(
                      mobile: mobile.trim(),
                      pass: pass,
                    );
                    //Navigator.pop(context);
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
