import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/colors_constant.dart';
import '../common/styles/styles.dart';
import 'custom_text.dart';

class CustomTextField extends StatelessWidget {

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
  final bool isOptional;
  final bool? isLogin;
  final bool? isShadow;
  final IconData? iconData;
  final String? image;
  final String? prefixText;
  final String? errorText;
  final VoidCallback? onPressed;
  final VoidCallback? onEdit;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;

  const CustomTextField({
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
    this.onPressed,
    this.prefixText,
    this.onEdit,
    this.errorText,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {

    final String safeHint = hintText ?? "";
    final bool showOptional = isOptional == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        safeHint.isEmpty
            ? const SizedBox(height: 2)
            : Row(
          children: [
            CustomText(
              text: text,
              colors: const Color(0xff4B5563),
              size: 13,
              isCopy: false,
            ),

            if (showOptional)
              const CustomText(
                text: "*",
                colors: Colors.red,
                size: 20,
                isCopy: false,
              ),
          ],
        ),

        showOptional ? const SizedBox(height: 0) : const SizedBox(height: 5),

        SizedBox(
          width: width,
          height: 40,

          child: TextFormField(

            key: ValueKey(text),

            controller: controller,
            focusNode: focusNode,

            autofocus: autofocus, // ✅ SAFE

            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: "Lato",
            ),

            cursorColor: colorsConst.primary,

            onChanged: onChanged,
            onTap: onTap,

            onFieldSubmitted: onFieldSubmitted,
            onEditingComplete: onEdit,

            inputFormatters: inputFormatters,

            textCapitalization: textCapitalization!,
            textInputAction: textInputAction,
            keyboardType: keyboardType,

            validator: validator,

            decoration: customStyle.inputDecoration(
              text: safeHint,
              iconData: iconData,
              image: image,
              isIcon: isIcon,
              isLogin: isLogin,
              errorText: errorText,
              onPressed: onPressed,
            ),
          ),
        ),

        safeHint.isEmpty
            ? const SizedBox(height: 10)
            : const SizedBox(height: 20),
      ],
    );
  }
}
