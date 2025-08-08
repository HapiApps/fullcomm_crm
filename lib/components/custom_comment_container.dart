import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final VoidCallback? onTap;
  final Color? tColor;
  final double borderRadius;
  final Widget? child;
  final Decoration? decoration;
  final double? size;

  const CustomContainer({
    super.key,
    this.width,
    this.height,
    this.color,
    required this.text,
    this.fontWeight = FontWeight.bold,
    this.onTap,
    this.tColor,
    required this.borderRadius,
    this.child,
    this.decoration,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: fontWeight,
                fontSize: size,
                color: tColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
