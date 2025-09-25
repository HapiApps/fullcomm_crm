import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  const CardContainer({super.key, this.elevation, this.width, this.height, this.color,this.borderRadius, this.child,});

final double? elevation;
final double?  width;
final double?  height;
final Color? color;
final BorderRadius? borderRadius;
final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      child: ClipRRect(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
