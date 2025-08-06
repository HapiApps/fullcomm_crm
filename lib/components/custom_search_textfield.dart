import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/constant/assets_constant.dart';
import '../common/constant/colors_constant.dart';

class CustomSearchTextField extends StatefulWidget {

  final TextEditingController controller;
  final ValueChanged<Object?>? onChanged;
  final VoidCallback? onTap;
  final String? hintText;

  const CustomSearchTextField({super.key,
    this.onChanged,required this.controller,this.onTap,this.hintText = "Search Name"
  });

  @override
  State<CustomSearchTextField> createState() => _CustomSearchTextFieldState();
}

class _CustomSearchTextFieldState extends State<CustomSearchTextField> {
  @override
  Widget build(BuildContext context){
    return  SizedBox(
      width: MediaQuery.of(context).size.width/3,
      height: 50,
      child: TextField(
        textCapitalization:TextCapitalization.words,
        keyboardType:TextInputType.text,
        controller: widget.controller,
        style: TextStyle(
          color:colorsConst.textColor,
        ),
        onChanged:widget.onChanged,
        decoration: InputDecoration(
          hoverColor:colorsConst.secondary,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color:colorsConst.textColor,
            fontSize: 12,
            fontFamily:"Lato",
          ),
          //prefixIcon: SvgPicture.asset(assets.search,width: 1,height: 1,),
          prefixIcon: IconButton(
              onPressed: null,
              icon:SvgPicture.asset(assets.search,
                  width: 15,height: 15)),
          suffixIcon: IconButton(
              onPressed: (){
                widget.controller.clear();
                if(widget.onChanged != null) {
                  widget.onChanged!(null);
                }
              }, icon: Icon(Icons.clear,color: Colors.white,)),
          fillColor:colorsConst.secondary,
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderSide:  BorderSide(color:colorsConst.secondary),
              borderRadius: BorderRadius.circular(5)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide:  BorderSide(color:colorsConst.secondary,),
              borderRadius: BorderRadius.circular(5)
          ),
          contentPadding:const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
