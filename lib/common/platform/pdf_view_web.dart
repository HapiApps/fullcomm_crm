import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Future<void> showPdfDialogImpl(BuildContext context, String url) async {
  final viewId = 'pdf-view-${DateTime.now().millisecondsSinceEpoch}';

  ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
    final iframe = web.HTMLIFrameElement()
      ..src = url
      ..width = '100%'
      ..height = '100%';
    iframe.style.border = 'none';
    return iframe;
  });

  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SizedBox(
        width: 800,
        height: 600,
        child: HtmlElementView(viewType: viewId),
      ),
    ),
  );
}