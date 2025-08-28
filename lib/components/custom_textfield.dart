import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/colors_constant.dart';
import '../common/styles/styles.dart';
import 'custom_text.dart';

class CustomTextField extends StatefulWidget {
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
  final VoidCallback? onPressed;
  final VoidCallback? onEdit;

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
      this.isOptional});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }
}

class _CustomTextFieldState extends State<CustomTextField> {
  // late FocusNode _focusNode;
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   _focusNode = widget.focusNode ?? FocusNode();
  //   _focusNode.addListener(() {
  //     setState(() {
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.hintText!.isEmpty
            ? 0.height
            : Row(
                children: [
                  CustomText(
                    text: widget.text,
                    textAlign: TextAlign.start,
                    colors: Color(0xff4B5563),
                    size: 15,
                  ),
                  widget.isOptional! == true
                      ? const CustomText(
                          text: "*",
                          colors: Colors.red,
                          size: 25,
                        )
                      : 0.width
                ],
              ),
        SizedBox(
          width: widget.width,
          //height:80,
          child: Center(
            child: TextFormField(
                key: ValueKey(widget.text),
                maxLines: null,
                style: const TextStyle(
                    color: Colors.black, fontSize: 15, fontFamily: "Lato"),
                // readOnly: widget.controller==controllers.upDOBController||widget.controller==controllers.upDOBController?true:false,
                //obscureText: widget.controller==controllers.loginPassword||widget.controller==controllers.signupPasswordController?!controllers.isEyeOpen.value:false,
                // focusNode: FocusNode(),
                cursorColor: colorsConst.primary,
                focusNode: widget.focusNode,
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
          ),
        ),
        widget.hintText!.isEmpty ? 10.height : 20.height,
      ],
    );
  }
}
