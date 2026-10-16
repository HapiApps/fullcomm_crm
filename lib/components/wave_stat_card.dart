import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/utilities/animated_wave_painter.dart';
import 'Customtext.dart';

class WaveStatCard extends StatefulWidget {
  final String title;
  final int numericValue;
  final int maxValue;
  final String iconPath;
  final Color valueColor;
  final String? amt;
  final VoidCallback callback;

  const WaveStatCard({
    super.key,
    required this.title,
    required this.numericValue,
    required this.maxValue,
    required this.iconPath,
    required this.valueColor, required this.callback, this.amt,
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
    double percentage = 0.0;

    if (widget.numericValue > 0) {

      percentage = 0.19 + (math.log(widget.numericValue + 1) / math.log(widget.maxValue + 1)) * 0.80;
    }
    percentage = percentage.clamp(0.0, 1.0);
    return InkWell(
      onTap:widget.callback,
      child: Container(
        height: 120,
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
                  builder: (_, __) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        painter: AnimatedWavePainter(
                          color: widget.valueColor,
                          percentage: percentage,
                          waveShift: _controller.value,
                        ),
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
                        )
                      ],
                    ),
                  ),
                  5.height,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text:widget.numericValue.toString(),size: 20,colors: widget.valueColor,isCopy: false,isBold: true,
                        ),
                        if(widget.amt!="")
                        CustomText(
                          text:widget.amt.toString(),size: 15,isCopy: false,isBold: true,
                        ),
                      ],
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