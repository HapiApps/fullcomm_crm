import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';

import 'Customtext.dart';

/// Two alternating colors
const Color colorA = Color(0xff6366F1);
const Color colorB = Color(0xff3B82F6);

class CustomerStatusItem {
  final String label;
  final int value;
  final double percentage; // 0.0 - 1.0

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
            text: "Customer Status",
            isCopy: false,
            size: 14,
            isBold: true,
            colors: Colors.black,
          ),

          4.height,
          CustomText(
            text: "Breakdown by engagement status",
            isCopy: false,
            size: 12,
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
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                /// Alternate color logic
                final dynamicColor =
                index.isEven ? colorA : colorB;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _StatusRow(
                    item: item,
                    color: dynamicColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final CustomerStatusItem item;
  final Color color;

  const _StatusRow({
    required this.item,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child:  CustomText(
            text: item.label,
            isCopy: false,
            size: 12,
            isBold: true,
            colors: Color(0xff888888),
          ),

        ),
       5.width,
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              /// Background grid lines
              Row(
                children: List.generate(
                  5,
                      (_) => Expanded(
                    child: Container(
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xffE5E7EB),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// Animated hover bar
              _HoverBar(
                label: item.label,
                value: item.value,
                percentage: item.percentage,
                color: color,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HoverBar extends StatefulWidget {
  final String label;
  final int value;
  final double percentage;
  final Color color;

  const _HoverBar({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
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
            width:
            constraints.maxWidth * widget.percentage,
            height: 14,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
      ),
    );
  }
}
