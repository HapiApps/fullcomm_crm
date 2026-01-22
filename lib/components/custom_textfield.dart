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
  final bool? isOptional;
  final bool? isLogin;
  final bool? isShadow;
  final IconData? iconData;
  final String? image;
  final String? prefixText;
  final String? errorText;
  final VoidCallback? onPressed;
  final VoidCallback? onEdit;
  //Santhiys2
  final ValueChanged? onFieldSubmitted;

  const CustomTextField(
      {super.key,
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
        this.isOptional, this.onFieldSubmitted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        hintText!.isEmpty
            ? 2.height
            : Row(
          children: [
            CustomText(
              text: text,
              textAlign: TextAlign.start,
              colors: Color(0xff4B5563),
              size: 13,
              isCopy: false,
            ),
            isOptional! == true
                ? const CustomText(
              text: "*",
              colors: Colors.red,
              size: 25,
              isCopy: false,
            )
                : 0.width
          ],
        ),
        isOptional! == true ? 0.height : 5.height,
        SizedBox(
          width: width,
          height:40,
          child: Center(
            child: TextFormField(
              //santhiya2
                onFieldSubmitted: onFieldSubmitted,
                key: ValueKey(text),
                maxLines: null,
                style: const TextStyle(
                    color: Colors.black, fontSize: 15, fontFamily: "Lato"),
                // readOnly: widget.controller==controllers.upDOBController||widget.controller==controllers.upDOBController?true:false,
                //obscureText: widget.controller==controllers.loginPassword||widget.controller==controllers.signupPasswordController?!controllers.isEyeOpen.value:false,
                // focusNode: FocusNode(),
                cursorColor: colorsConst.primary,
                focusNode: focusNode,
                onChanged: onChanged,
                onTap: onTap,
                inputFormatters: inputFormatters,
                textCapitalization: textCapitalization!,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
                validator: validator,
                controller: controller,
                onEditingComplete: onEdit,
                decoration: customStyle.inputDecoration(
                    text: hintText,
                    iconData: iconData,
                    image: image,
                    isIcon: isIcon,
                    isLogin: isLogin,
                    errorText: errorText,
                    onPressed: onPressed)),
          ),
        ),

        hintText!.isEmpty ? 10.height : 20.height,
      ],
    );
  }
}