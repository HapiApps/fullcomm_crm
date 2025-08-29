import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';


class ZoomBlocker extends StatefulWidget {
  final Widget child;
  const ZoomBlocker({super.key, required this.child});

  @override
  State<ZoomBlocker> createState() => _ZoomBlockerState();
}

class _ZoomBlockerState extends State<ZoomBlocker> {
  @override
  void initState() {
    super.initState();
    final viewport = web.window.visualViewport;
    if (viewport != null) {
      viewport.addEventListener(
        'resize',
        ((web.Event event) {
          final scale = viewport.scale;
          // Reset zoom → keep UI size fixed
          web.document.body?.style.zoom = "${1 / scale}";
        }).toJS,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
