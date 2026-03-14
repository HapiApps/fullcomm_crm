import 'package:flutter/material.dart';


// class WaveStatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String iconPath;
//   final String waveImage;
//   final Color valueColor;
//
//   const WaveStatCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.iconPath,
//     required this.waveImage,
//     required this.valueColor,
//   });
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Flexible(
//       child: Container(
//         height: 120,
//         margin: const EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             /// 🔵 WAVE IMAGE
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(20),
//                 ),
//                 child: Image.asset(
//                   waveImage,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//
//             /// 🧾 CONTENT
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       8.width,
//                       Image.asset(
//                         iconPath,
//                         width: 20,
//                         height: 20,
//                       ),
//                     ],
//                   ),
//
//                  5.height,
//                   CustomText(
//                     text: value,
//                     isCopy: false,
//                     size: 20,
//                     isBold: true,
//                     colors:  valueColor,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';

import '../common/utilities/animated_wave_painter.dart';
import 'Customtext.dart';

class WaveStatCard extends StatefulWidget {
  final String title;
  final int numericValue;
  final int maxValue;
  final String iconPath;
  final Color valueColor;
  final VoidCallback callback;

  const WaveStatCard({
    super.key,
    required this.title,
    required this.numericValue,
    required this.maxValue,
    required this.iconPath,
    required this.valueColor, required this.callback,
  });

  @override
  State<WaveStatCard> createState() => _WaveStatCardState();
}

class _WaveStatCardState extends State<WaveStatCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double percentage = 0.0;

    if (widget.numericValue > 0) {

      percentage = 0.19 + (math.log(widget.numericValue + 1) / math.log(widget.maxValue + 1)) * 0.80;
    }
    percentage = percentage.clamp(0.0, 1.0);
    return InkWell(
      onTap:widget.callback,
      child: Container(
        height: 120,
        width: screenWidth/7.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Animated Wave
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: AnimatedWavePainter(
                        color: widget.valueColor,
                        percentage: percentage,
                        waveShift: _controller.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            /// Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Image.asset(
                          widget.iconPath,
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  5.height,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: CustomText(
                      text:widget.numericValue.toString(),size: 20,colors: widget.valueColor,isCopy: false,isBold: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}