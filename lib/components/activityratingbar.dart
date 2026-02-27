import 'package:flutter/material.dart';

import 'Customtext.dart';

class ActivityRatingBar extends StatefulWidget {
  final int hot;
  final int warm;
  final int cold;
  final double totalWidth;

  const ActivityRatingBar({
    required this.hot,
    required this.warm,
    required this.cold,
    required this.totalWidth,
  });

  @override
  State<ActivityRatingBar> createState() => ActivityRatingBarState();
}

class ActivityRatingBarState extends State<ActivityRatingBar> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(BuildContext context, Offset position) {
    _removeTooltip();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + 10,
        top: position.dy - 70,
        child: Material(
          elevation: 8,
          // borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tooltipRow("Hot", widget.hot, const Color(0xffEF4444)),
                _tooltipRow("Warm", widget.warm, const Color(0xffF59E0B)),
                _tooltipRow("Cold", widget.cold, const Color(0xff3B82F6)),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.hot + widget.warm + widget.cold;
    final hotWidth = widget.totalWidth * (widget.hot / total);
    final warmWidth = widget.totalWidth * (widget.warm / total);
    final coldWidth = widget.totalWidth * (widget.cold / total);

    return MouseRegion(
      onHover: (event) {
        _showTooltip(context, event.position);
      },
      onExit: (_) {
        _removeTooltip();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            _segment(hotWidth, const Color(0xffEF4444)),
            _segment(warmWidth, const Color(0xffF59E0B)),
            _segment(coldWidth, const Color(0xff3B82F6)),
          ],
        ),
      ),
    );
  }

  Widget _segment(double width, Color color) {
    return Container(
      width: width,
      height: 28,
      color: color,
    );
  }

  Widget _tooltipRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child:CustomText(
        text: "$label: $value",
        isCopy: false,
        size: 12,
        isBold: true,
        colors: color,
      ),
    );
  }
}