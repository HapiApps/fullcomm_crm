// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:lending_paisa/common/constant/assets_constant.dart';
// import 'package:lending_paisa/common/constant/colors_constant.dart';
// import 'package:lending_paisa/common/constant/default_constant.dart';
// import 'package:lending_paisa/common/styles/decoration.dart';
// import 'package:lending_paisa/components/custom_text.dart';
//
// class CustomImage extends StatefulWidget {
//   const CustomImage({Key? key, required this.height, required this.width, required this.image, required this.isBorder,
//     required this.isImage, this.text, this.textColor, this.containerColor, required this.isCase, this.callback, this.isNetwork=false, this.radius}) : super(key: key);
//   final String image;
//   final double height;
//   final double width;
//   final bool isBorder;
//   final bool isImage;
//   final bool isCase;
//   final bool? isNetwork;
//   final String? text;
//   final Color? textColor;
//   final Color? containerColor;
//   final VoidCallback? callback;
//   final double? radius;
//
//   @override
//   State<CustomImage> createState() => _CustomImageState();
// }
//
// class _CustomImageState extends State<CustomImage> {
//   @override
//   Widget build(BuildContext context) {
//     return  Stack(
//       key: const ValueKey("Image"),
//       children: [
//         if(!widget.isNetwork!)
//         GestureDetector(
//           onTap: widget.callback,
//           child: Container(
//             decoration: customDecoration.baseBackgroundDecoration(
//                 radius:widget.isBorder?widget.radius:0,color:widget.containerColor,
//             ),
//             height: widget.height,
//             width: widget.width,
//             child: widget.isImage?Image.asset(widget.image,width: 5,height: 5)
//                 :Center(child: CustomText(text: widget.text,colors: widget.textColor,size: 11,isBold:true)),
//           ),
//         ),
//         if(widget.isCase&&!widget.isNetwork!)
//         Positioned(
//             right: 0,
//             top: 0,
//             child: GestureDetector(
//               onTap: widget.callback,
//               child: Container(
//                 width: 25,
//                 height: 25,
//                 decoration: customDecoration.baseBackgroundDecoration(
//                     radius:25,color: colorsConst.primary
//                 ),
//                 child: Center(child: CustomText(text:constValue.caseCount,colors:Colors.white,size:10,isBold:true)),
//               ),
//             ),
//           ),
//         if(widget.isNetwork!)
//         GestureDetector(
//           onTap:widget.callback,
//         child: Container(
//           height: widget.height,
//           width: widget.width,
//           decoration: customDecoration.baseBackgroundDecoration(
//               radius:widget.isBorder?widget.width:0,color:widget.isBorder?Colors.grey.shade200:!widget.isImage?widget.containerColor:Colors.white
//           ),
//                 child:widget.image.substring(widget.image.length - 3)==constValue.checkPdf?Container(
//                   decoration: customDecoration.baseBackgroundDecoration(
//                       radius:widget.width,color:Colors.grey.shade200
//                   ),
//                     child: Image.asset(assets.pdf),
//                   ):CachedNetworkImage(
//                       imageUrl: widget.image,fit:BoxFit.cover ,
//                       imageBuilder: (context, imageProvider) =>
//                       Container(
//                       decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(widget.width),
//                       image: DecorationImage(
//                       image: imageProvider,
//                             fit: BoxFit.cover,
//                            ),
//                         ),
//                        ),
//                       errorWidget: (context,url,error)=>const Icon(Icons.error),
//                       placeholder: (context,url)=>Image.asset(assets.loadingGif,width: 50,height: 50,)
//                       ),
//     ),
//     )
//       ],
//     );
//   }
// }



// import 'package:anpace/common/styles/decoration.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:anpace/components/custom_text.dart';
// import '../common/constant/assets_constant.dart';
// import '../common/constant/colors_constant.dart';

//enum Shape { circle, rectangle, square }

// class CustomImage extends StatefulWidget {
//   const CustomImage(
//       {Key? key,
//         required this.height,
//         required this.width,
//         required this.image,
//         this.text,
//         this.textColor,
//         this.containerColor,
//         this.shape = Shape.square,
//         this.enableBatch = false,
//         this.isBorder = false,
//         this.callback,
//         this.isNetwork = false,
//         this.enableDottedBorder = false, this.countText, this.isText=false})
//       : super(key: key);
//   final String image;
//   final double height;
//   final double width;
//   final bool enableBatch;
//   final bool isNetwork;
//   final String? text;
//   final bool enableDottedBorder;
//   final bool isBorder;
//   final Shape shape;
//   final Color? textColor;
//   final Color? containerColor;
//   final bool? isText;
//   final VoidCallback? callback;
//   final int? countText;
//
//   @override
//   State<CustomImage> createState() => _CustomImageState();
// }
//
// class _CustomImageState extends State<CustomImage> {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       key: const ValueKey("Image"),
//       children: [
//         if (!widget.isNetwork)
//           GestureDetector(
//             onTap: widget.callback,
//             child: DottedBorder(
//               color: widget.enableDottedBorder
//                   ? Colors.grey.shade400
//                   : Colors.transparent,
//               strokeWidth: 0.5,
//               dashPattern: const [8, 3],
//               radius: const Radius.circular(5),
//               borderType: BorderType.RRect,
//               child: Container(
//                   decoration: customDecoration.baseBackgroundDecoration(
//                     radius:
//                     widget.shape == Shape.square ? 0 : widget.width * 0.5,
//                     color: widget.containerColor,
//                   ),
//                   height: widget.height,
//                   width: widget.width,
//                   child: widget.isText==true?Center(child: CustomText(text: widget.text,colors: widget.textColor,)):SvgPicture.asset(widget.image)),
//             ),
//           ),
//         if (widget.enableBatch)
//           Positioned(
//             right: 0,
//             top: 0,
//             child: GestureDetector(
//               onTap: widget.callback,
//               child: Container(
//                 width: widget.width * 0.5,
//                 height: widget.height * 0.5,
//                 decoration: customDecoration.baseBackgroundDecoration(
//                     radius: (widget.width * 0.5) * .50,
//                     color: colorsConst.primary),
//                 child: Center(
//                     child: CustomText(
//                         text: widget.countText.toString(),
//                         colors: Colors.white,
//                         size: 10,
//                         isBold: true)),
//               ),
//             ),
//           ),
//         if (widget.isNetwork)
//           GestureDetector(
//             onTap: widget.callback,
//             child: Container(
//               height: widget.height,
//               width: widget.width,
//               decoration: customDecoration.baseBackgroundDecoration(
//                   radius: widget.width,
//                   color: widget.isBorder
//                       ? Colors.grey.shade200
//                       : widget.containerColor),
//               child: widget.image.substring(widget.image.length - 3) ==
//                   constValue.checkPdf
//                   ? Container(
//                 decoration: customDecoration.baseBackgroundDecoration(
//                     radius: widget.width, color: Colors.grey.shade200),
//                 child: Image.asset(assets.pdf),
//               )
//                   : CachedNetworkImage(
//                   imageUrl: widget.image,
//                   fit: BoxFit.cover,
//                   imageBuilder: (context, imageProvider) => Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(widget.width),
//                       image: DecorationImage(
//                         image: imageProvider,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   errorWidget: (context, url, error) =>
//                   const Icon(Icons.error),
//                   placeholder: (context, url) => Image.asset(
//                     assets.loadingGif,
//                     width: 50,
//                     height: 50,
//                   )),
//             ),
//           )
//       ],
//     );
//   }
// }