import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';

import 'Customtext.dart';

/// Two alternating colors
const Color colorA = Color(0xff6366F1);
const Color colorB = Color(0xff3B82F6);


const Color lightPurple = Color(0xffDED3FD);
const Color lightBlue   = Color(0xffD3E3FD);
class CustomerStatusItem {
  final String label;
  final int value;
  final double percentage;

  CustomerStatusItem({
    required this.label,
    required this.value,
    required this.percentage,
  });
}

class CustomerStatusCard extends StatelessWidget {
  final List<CustomerStatusItem> items;

  const CustomerStatusCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Call Status",
            isCopy: false,
            size: 15,
            isBold: true,
            colors: Colors.black,
          ),

          4.height,
          CustomText(
            text: "Breakdown by engagement status",
            isCopy: false,
            size: 13,
            isBold: false,
            colors: const Color(0xff666666),
          ),
          12.height,
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xffE5E7EB),
          ),
          16.height,

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  final bool isPurple = index % 2 == 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _StatusRow(
                      item: item,
                      fillColor: isPurple ? colorA : colorB,
                      bgColor: isPurple ? lightPurple : lightBlue,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _StatusRow extends StatelessWidget {
  final CustomerStatusItem item;
  final Color fillColor;
  final Color bgColor;

  const _StatusRow({
    required this.item,
    required this.fillColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// Label
        SizedBox(
          width: 110,
          child: CustomText(
            text: item.label,
            isCopy: false,
            size: 13,
            isBold: true,
            colors: const Color(0xff8A8A8A),
          ),
        ),

        10.width,

        /// Bar Section
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              /// FULL LIGHT BACKGROUND
              Container(
                height: 15,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
              ),
              /// Dotted Grid
              // Positioned.fill(
              //   child: CustomPaint(
              //     painter: _DottedVerticalPainter(),
              //   ),
              // ),

              /// DARK FILL
              LayoutBuilder(
                builder: (context, constraints) {
                  return _HoverBar(
                    label: item.label,
                    value: item.value,
                    percentage: item.percentage,
                    color: fillColor,
                    maxWidth: constraints.maxWidth,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class _DottedVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffD1D5DB)
      ..strokeWidth = 1;

    const int divisions = 4;
    final spacing = size.width / divisions;

    for (int i = 1; i < divisions; i++) {
      final x = spacing * i;

      double y = 0;
      while (y < size.height) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + 3),
          paint,
        );
        y += 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _HoverBar extends StatefulWidget {
  final String label;
  final int value;
  final double percentage;
  final Color color;
  final double maxWidth;

  const _HoverBar({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    required this.maxWidth,
  });

  @override
  State<_HoverBar> createState() => _HoverBarState();
}

class _HoverBarState extends State<_HoverBar> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(BuildContext context, Offset position) {
    _removeTooltip();

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: position.dx + 10,
        top: position.dy - 70,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color,
                width: 1.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                    text:  widget.label,
                    isCopy: false,
                    size: 12,
                    isBold: true,
                  colors: Color(0xff888888),
                ),
                16.width,
                CustomText(
                  text: "${widget.value}",
                  isCopy: false,
                  size: 18,
                  isBold: true,
                  colors:  widget.color,
                ),
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
    return MouseRegion(
      onEnter: (event) =>
          _showTooltip(context, event.position),
      onExit: (_) => _removeTooltip(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: widget.maxWidth * widget.percentage,
            height: 15,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          );
        },
      ),
    );
  }
}
