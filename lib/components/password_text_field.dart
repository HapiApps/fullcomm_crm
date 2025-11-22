import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/colors_constant.dart';
import '../common/styles/styles.dart';
import 'custom_text.dart';

class CustomPasswordTextField extends StatefulWidget {
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
  final bool isOptional;
  final bool? isShadow;
  final IconData? iconData;
  final String? image;
  final String? prefixText;
  final VoidCallback? onEdit;

  const CustomPasswordTextField({
    super.key,
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
    this.prefixText,
    this.onEdit,
    required this.isOptional,
  });

  @override
  State<CustomPasswordTextField> createState() => _CustomPasswordTextFieldState();
}

class _CustomPasswordTextFieldState extends State<CustomPasswordTextField> {
  bool isEyeOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            CustomText(
              text: widget.text,
              textAlign: TextAlign.start,
              colors: const Color(0xff4B5563),
              size: 13,
            ),
            widget.isOptional
                ? const CustomText(
              text: "*",
              colors: Colors.red,
              size: 25,
            )
                : 0.width,
          ],
        ),
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: Center(
            child: TextFormField(
              key: ValueKey(widget.text),
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: "Lato",
              ),
              cursorColor: colorsConst.primary,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              obscuringCharacter: "*",
              inputFormatters: widget.inputFormatters,
              textCapitalization: widget.textCapitalization!,
              textInputAction: widget.textInputAction,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onEditingComplete: widget.onEdit,
              obscureText: !isEyeOpen,
              decoration: customStyle.inputDecoration(
                text: widget.hintText,
                image: widget.image,
                isIcon: widget.isIcon,
                isLogin: widget.isLogin,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    isEyeOpen
                        ? Icons.remove_red_eye_outlined
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isEyeOpen = !isEyeOpen;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        //20.height,
      ],
    );
  }
}

