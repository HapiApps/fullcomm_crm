import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomNoData extends StatelessWidget {
  const CustomNoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SvgPicture.asset(
          "assets/images/noDataFound.svg"),
    );
  }
}
