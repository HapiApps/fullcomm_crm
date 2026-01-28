import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../main.dart';

final MobileUtils mobileUtils = MobileUtils._();

class MobileUtils {
  MobileUtils._();

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar({required BuildContext context,
    required String msg,
    required Color color}) {
    var snack = SnackBar(
      width: 500,
      content: Center(child: Text(msg)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      backgroundColor: color,
      elevation: 30,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
    return rootScaffoldMessengerKey.currentState!.showSnackBar(snack);
  }
//Santhiya
//   void toastBox({required BuildContext context, required String text}){
//     Fluttertoast.showToast(
//         msg: text,
//         // toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.CENTER,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 14.0
//     );
//   }
  void toastBox({required BuildContext context, required String text}) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,

      backgroundColor: Colors.red, // Android old versions
      textColor: Colors.white,
      fontSize: 14.0,

      webBgColor: "#FF0000", // IMPORTANT for Web
      // webPosition: "center",
    );
  }
}