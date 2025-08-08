import 'package:flutter/material.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import '../common/constant/colors_constant.dart';

class CustomCheckBox extends StatefulWidget {
  final bool saveValue;
  final ValueChanged<bool?> onChanged;
  final String? text;

  const CustomCheckBox(
      {super.key, required this.onChanged, required this.saveValue, this.text});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          side: MaterialStateBorderSide.resolveWith(
            (states) => BorderSide(width: 1.0, color: colorsConst.textColor),
          ),
          checkColor: Colors.black,
          activeColor: colorsConst.third,
          value: widget.saveValue,
          onChanged: widget.onChanged,
        ),
        CustomText(
          text: widget.text.toString(),
          colors: colorsConst.third,
          size: 13,
        )
      ],
    );
  }
}
