
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import '../common/constant/colors_constant.dart';
import '../controller/controller.dart';
import 'custom_text.dart';

class CustomAreaTextField extends StatefulWidget {
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
  final String? name;
  final String? prefixText;
  final VoidCallback? onPressed;
  final TextEditingController? dNoC;
  final TextEditingController? streetC;
  final TextEditingController? areaC;
  final TextEditingController? cityC;
  final String? stateC;
  final TextEditingController? countryC;
  final TextEditingController? pinCodeC;

  const CustomAreaTextField({Key? key, required this.text, this.height=70, this.width=270,
    required this.controller, this.focusNode, this.onChanged, this.onTap, this.keyboardType=TextInputType.text,
    this.textInputAction=TextInputAction.next, this.textCapitalization=TextCapitalization.words, this.validator,
    this.inputFormatters,
    this.hintText, this.isIcon, this.iconData,
    this.isShadow=false, this.isLogin=false,this.image,
    this.onPressed,this.prefixText,this.areaC,this.cityC,this.countryC,this.dNoC,this.pinCodeC,this.stateC,
    this.streetC,this.name
  }) : super(key: key);

  @override
  State<CustomAreaTextField> createState() => _CustomAreaTextFieldState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties){
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed));
  }
}

class _CustomAreaTextFieldState extends State<CustomAreaTextField> {

  Future<void> getAddressFromLatLng () async{
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
   // List<Placemark> placeMark=await placemarkFromCoordinates(position.latitude, position.longitude);
    //Placemark place = placeMark[0];
    //print("place..............${place}");

    setState(() {
      controllers.lng.value=position.longitude;
      // controllers.etAreaController.text="${place.subLocality}";
      // controllers.etPinCodeController.text="${place.postalCode}";
      // controllers.etCityController.text="${place.locality}";
      //controllers.eventState="${place.administrativeArea}";
      // controllers.etCountryController.text="${place.country}";
      // controllers.etStreetController.text="${place.street}";
      // controllers.etAreaController.text="${place.subLocality},${place.thoroughfare}";
    });

  }


  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        CustomText(
          text:widget.text,
          colors:colorsConst.secondary,
          size: 15,
        ),
        25.width,
        SizedBox(
          width: widget.width,
          height: 50,
          child: Center(
            child: TextFormField(
                style: const TextStyle(
                    color:Colors.black,fontSize: 14,
                    fontFamily:"Lato"
                ),
                // readOnly: widget.controller==controllers.upDOBController||widget.controller==controllers.upDOBController?true:false,
                // obscureText: widget.controller==controllers.loginPassword||widget.controller==controllers.signupPasswordController?!controllers.isEyeOpen.value:false,
                // focusNode: FocusNode(),
                cursorColor: Colors.white,
                onChanged:widget.onChanged,
                onTap:widget.onTap,
                inputFormatters: widget.inputFormatters,
                textCapitalization: widget.textCapitalization!,
                textInputAction: widget.textInputAction,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                controller: widget.controller,
                decoration:InputDecoration(
                  hoverColor:Colors.white,
                 // focusColor: Colors.transparent,
                  hintText:"",
                  hintStyle: TextStyle(
                      color:Colors.grey.shade400,
                      fontSize: 15,
                      fontFamily:"Lato"
                  ),
                  // fillColor:Colors.white,
                  // filled: true,
                  suffixIcon:Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      // Obx(()=>
                      IconButton(
                          onPressed:(){

                          },
                          icon:const Icon(Icons.location_on,color: Colors.red,size: 15,)
                      ),
                      //),
                      IconButton(
                          onPressed:(){
                            setState((){
                              widget.dNoC!.clear();
                              widget.streetC!.clear();
                              widget.areaC!.clear();
                              widget.cityC!.clear();
                              widget.stateC!=null;
                              widget.countryC!.clear();
                              widget.pinCodeC!.clear();
                            });
                          },
                          icon:const Icon(Icons.refresh,color:Colors.grey,size:15,)),
                    ],
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide:  BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  // errorStyle: const TextStyle(height:0.05,fontSize: 12),
                  contentPadding:const EdgeInsets.symmetric(vertical:10.0, horizontal: 10.0),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color:Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10)
                  ),
                )
            ),
          ),
        ),
      ],
    );
  }

}
