import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:get/state_manager.dart';
import '../common/constant/colors_constant.dart';
import '../common/styles/styles.dart';
import '../controller/controller.dart';

class CustomEmployeeTextField extends StatefulWidget {
  final String text;
  final String? hintText;
  final double? height;
  final double? width;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<Object?>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? isIcon;
  final bool? isLogin;
  final bool? isShadow;
  final IconData? iconData;
  final String? image;
  final String? prefixText;
  final void Function()? onPressed;
  final void Function()? onEdit;

  const CustomEmployeeTextField(
      {Key? key,
      required this.text,
      this.height = 70,
      this.width = 270,
      required this.controller,
      this.focusNode,
      this.onChanged,
      this.onTap,
      this.keyboardType = TextInputType.text,
      this.textInputAction = TextInputAction.next,
      this.textCapitalization = TextCapitalization.words,
      this.validator,
      this.inputFormatters,
      this.hintText,
      this.isIcon,
      this.iconData,
      this.isShadow = false,
      this.isLogin = false,
      this.image,
      this.onPressed,
      this.prefixText,
      this.onEdit})
      : super(key: key);

  @override
  State<CustomEmployeeTextField> createState() =>
      _CustomEmployeeTextFieldState();
}

class _CustomEmployeeTextFieldState extends State<CustomEmployeeTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: widget.text,
          colors: colorsConst.secondary,
          size: 15,
        ),
        SizedBox(
            width: widget.width,
            height: 50,
            child: Obx(
              () => TextFormField(
                  style: const TextStyle(
                      color: Colors.black, fontSize: 15, fontFamily: "Lato"),
                  // readOnly: widget.controller==controllers.upDOBController||widget.controller==controllers.upDOBController?true:false,
                  obscureText: widget.controller == controllers.loginPassword ||
                          widget.controller == controllers.signPassword
                      ? !controllers.isEyeOpen.value
                      : controllers.isPanel.value,
                  // focusNode: FocusNode(),
                  cursorColor: Colors.black,
                  cursorHeight: 20,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  inputFormatters: widget.inputFormatters,
                  textCapitalization: widget.textCapitalization!,
                  textInputAction: widget.textInputAction,
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  controller: widget.controller,
                  onEditingComplete: widget.onEdit,
                  decoration: customStyle.inputDecoration(
                      text: widget.hintText,
                      iconData: widget.iconData,
                      image: widget.image,
                      isIcon: widget.isIcon,
                      isLogin: widget.isLogin,
                      onPressed: widget.onPressed)),
            )),
        25.height
      ],
    );
  }
}
