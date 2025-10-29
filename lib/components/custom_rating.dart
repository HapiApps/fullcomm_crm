import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../common/constant/colors_constant.dart';

class RatingIndicator extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final double percentage;
  final TextStyle? labelStyle;

  const RatingIndicator({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 13.0,
          animation: true,
          percent: percentage,
          reverse: true,
          center: Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: colorsConst.textColor,
            ),
          ),
          circularStrokeCap: CircularStrokeCap.square,
          progressColor: color,
          backgroundColor: const Color(0xffF9FAFB),
        ),
        10.height,
        Text(
          label,
          style: labelStyle ??
              TextStyle(
                color: colorsConst.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}