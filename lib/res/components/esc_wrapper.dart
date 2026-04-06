import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../view_models/billing_provider.dart';

class EscBackWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onEscPressed;

  const EscBackWrapper({
    Key? key,
    required this.child,
    this.onEscPressed,
  }) : super(key: key);

  @override
  State<EscBackWrapper> createState() => _EscBackWrapperState();
}

class _EscBackWrapperState extends State<EscBackWrapper> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    final billingProvider = Provider.of<BillingProvider>(
        context, listen: false);
    billingProvider.mobileController.clear();
    billingProvider.nameController.clear();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {

          // 🔥 Custom ESC handler
          if (widget.onEscPressed != null) {
            widget.onEscPressed!();
            return;
          }

          // 🔥 Default back
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      },
      child: widget.child,
    );
  }
}
