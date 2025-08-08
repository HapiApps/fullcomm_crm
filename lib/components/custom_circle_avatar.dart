import 'package:flutter/material.dart';

import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';

class CustomCircleAvatar extends StatelessWidget {
  final ImageProvider? image;
  const CustomCircleAvatar({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(children: <Widget>[
        CircleAvatar(
            backgroundColor: Colors.white,
            radius: 70.0,
            backgroundImage: image),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: InkWell(
            onTap: () {
              utils.showImagePickerDialog(context);
            },
            child: Icon(
              Icons.camera_alt,
              color: colorsConst.primary,
              size: 28.0,
            ),
          ),
        ),
      ]),
    );
  }
}
