import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/assets_constant.dart';
import '../common/constant/colors_constant.dart';

class CustomSearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<Object?>? onChanged;
  final VoidCallback? onTap;
  final String? hintText;
  //Santhiya
  final FocusNode? focusNode;

  const CustomSearchTextField(
      {super.key,
      this.onChanged,
      required this.controller,
      this.onTap,
      this.hintText = "Search Name", this.focusNode});

  @override
  State<CustomSearchTextField> createState() => _CustomSearchTextFieldState();
}

class _CustomSearchTextFieldState extends State<CustomSearchTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      height: 50,
      child: TextField(
        focusNode: widget.focusNode,
        textCapitalization: TextCapitalization.words,
        keyboardType: TextInputType.text,
        controller: widget.controller,
        style: TextStyle(
          color: colorsConst.textColor,
        ),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hoverColor: Colors.white,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Color(0xff526B81),
            fontSize: 13,
            fontFamily: "Lato",
          ),
          prefixIcon: IconButton(
              onPressed: null,
              icon: SvgPicture.asset(assets.search, width: 15, height: 15,
                colorFilter: const ColorFilter.mode(
                Color(0xff526B81),
                BlendMode.srcIn,
              ),)),
          suffixIcon: widget.controller.text.isEmpty?0.height:IconButton(
            focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed: () {
                widget.controller.clear();
                if (widget.onChanged != null) {
                  widget.onChanged!("");
                }
              },
              icon: Icon(
                Icons.clear,
                color: Color(0xff526B81),
              )),
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorsConst.primary,
              ),
              borderRadius: BorderRadius.circular(5)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
