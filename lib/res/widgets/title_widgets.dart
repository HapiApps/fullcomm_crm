import 'package:flutter/material.dart';
import 'package:fullcomm_crm/res/colors.dart';
import 'package:fullcomm_crm/billing_utils/text_formats.dart';

import '../components/k_text.dart';

class TitleWidgets {
  static Widget tableTitle(context,{required String title}) {
    return MyText(
      text: title,
      fontSize: TextFormat.responsiveFontSize(context, 14),
      color: AppColors.black,
    );
  }
}
