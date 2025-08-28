import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../common/constant/colors_constant.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../common/styles/styles.dart';
import 'custom_text.dart';

class CustomLoadingButton extends StatefulWidget {
  const CustomLoadingButton(
      {super.key,
      this.height = 50,
      required this.callback,
      this.controller,
      this.text,
      required this.isLoading,
      this.textColor = Colors.white,
      required this.backgroundColor,
      required this.radius,
      this.textSize = 14,
      this.image,
      this.isImage,
      required this.width});
  final String? text;
  final String? image;
  final bool? isImage;
  final double height;
  final double width;
  final bool isLoading;
  final Color backgroundColor;
  final double radius;
  final Color? textColor;
  final double? textSize;
  final RoundedLoadingButtonController? controller;
  final VoidCallback callback;
  @override
  State<CustomLoadingButton> createState() => _CustomLoadingButtonState();
}

class _CustomLoadingButtonState extends State<CustomLoadingButton> {
  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ?

        /// Change this line
        RoundedLoadingButton(
            width: widget.width,
            height: widget.height,
            borderRadius: 3,
            color: widget.backgroundColor,
            successColor: colorsConst.primary,
            valueColor: Colors.white,
            onPressed: widget.callback,
            controller: widget.controller!,
            child: Text(
              widget.text.toString(),
              style: GoogleFonts.libreFranklin(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: widget.textSize),
            ),
          )
        : SizedBox(
            height: widget.height,
            width: widget.width,
            child: ElevatedButton(
              style: customStyle.buttonStyle(
                  color: widget.backgroundColor, radius: widget.radius),
              onPressed: widget.callback,
              child: !widget.isImage!
                  ? Text(
                      widget.text.toString(),
                      style: TextStyle(
                          color: widget.textColor,
                          fontSize: widget.textSize!,
                          fontWeight: FontWeight.bold),
                    )
                  : SvgPicture.asset(
                      widget.image!,
                      width: 50,
                      height: 50,
                    ),
            ),
          );
  }
}
