import 'package:flutter/material.dart';

class Toasts {

  static void showToastBar({
    required BuildContext context,
    required String text,
    Color? color,
    IconData? icon,
    int? milliseconds,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 60,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color ?? Colors.black87,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                InkWell(
                  onTap: () => entry.remove(),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Auto-dismiss after 3 seconds (optional)
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (entry.mounted) entry.remove();
    });
  }


}