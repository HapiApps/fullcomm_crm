import 'package:flutter/material.dart';

import '../../main.dart';

final Utils utils = Utils._();

class Utils {
  Utils._();

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
}