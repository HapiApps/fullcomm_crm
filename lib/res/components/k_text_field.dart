import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.inputFormatters,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onTap,  // ✅ ADD HERE
    this.height,
    this.labelText,
    this.width,
    this.prefixIcon,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization,
    this.enabled,
    this.autofocus,
    this.obscureText,
    this.autofillHints,
    this.textAlign,
    this.maxLines,
    this.minLines,
    this.labelRedText,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final double? height;
  final String? labelText;
  final String? labelRedText;
  final String? hintText;
  final double? width;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final bool? autofocus;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextCapitalization? textCapitalization;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final void Function()? onTap;   // ✅ ADD HERE
  final Iterable<String>? autofillHints;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height ?? screenHeight * 0.07,
      width: width ?? screenWidth * 0.35,
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.lato(
          fontSize: 15,color: Colors.black
        ),
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction ?? TextInputAction.next,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autofocus: autofocus ?? false,
        obscureText: obscureText ?? false,
        obscuringCharacter: '•',
        textAlign: textAlign ?? TextAlign.start,

        onTap: onTap,   // ✅ ADD THIS LINE

        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          label: labelRedText != null
              ? RichText(
            text: TextSpan(
              text: labelText ?? '',
              style: GoogleFonts.lato(
                color: Colors.black,
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: GoogleFonts.lato(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
              : Text(
            labelText ?? '',
            style: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          hintText: hintText,

          hintStyle: GoogleFonts.lato(color: Colors.black,
              fontSize: 15),
          labelStyle:  GoogleFonts.lato(color: Colors.black,
              fontSize: 15),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          contentPadding: const EdgeInsets.fromLTRB(10, 30, 5, 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.shade300, // 👈 normal state
              width: 1.5,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: colorsConst.primary, // 👈 focus ஆனப்போ
              width: 2,
            ),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),

        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        enabled: enabled ?? true,
        maxLines: maxLines,
        minLines: minLines,
        autofillHints: autofillHints,
      ),
    );
  }
}

