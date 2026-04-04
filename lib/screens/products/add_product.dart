// import 'package:flutter/material.dart';
// import 'package:fullcomm_crm/common/extentions/extensions.dart';
// import 'package:fullcomm_crm/common/utilities/billing_utils.dart';
// import 'package:fullcomm_crm/components/custom_loading_button.dart';
// import 'package:get/get.dart';
//
// import '../../common/constant/api.dart';
// import '../../common/constant/colors_constant.dart';
// import '../../common/constant/key_constant.dart';
// import '../../components/Customtext.dart';
// import '../../components/custom_sidebar.dart';
// import '../../components/custom_textfield.dart';
// import '../../controller/product_controller.dart';
// import '../../billing_models/product_model.dart';
//
// class AddProduct extends StatefulWidget {
//   const AddProduct({super.key});
//
//   @override
//   State<AddProduct> createState() => _AddProductState();
// }
//
// class _AddProductState extends State<AddProduct> {
//   final FocusNode title = FocusNode();
//   final FocusNode description = FocusNode();
//   final FocusNode availability = FocusNode();
//   final FocusNode condition = FocusNode();
//   final FocusNode price = FocusNode();
//   final FocusNode brand = FocusNode();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(title);
//       productCtr.title.clear();
//       productCtr.description.clear();
//       productCtr.availability.clear();
//       productCtr.condition.clear();
//       productCtr.price.clear();
//       productCtr.brand.clear();
//       productCtr.selectedFile.value = null;
//     });
//   }
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     title.dispose();
//     description.dispose();
//     availability.dispose();
//     condition.dispose();
//     price.dispose();
//     brand.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     double textFieldSize = MediaQuery.of(context).size.width*0.7;
//     return Scaffold(
//         body: Row(children: [
//           SideBar(),
//           20.width,
//           Container(
//               width: MediaQuery.of(context).size.width*0.8,
//               alignment: Alignment.center,
//               child: Column(children: [
//                 22.height,
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             InkWell(
//                               onTap:(){
//                                 Get.back();
//                               },
//                               child: Icon(Icons.arrow_back),
//                             ),10.width,
//                             CustomText(
//                               text:
//                               "New Product",
//                               colors: colorsConst.textColor,
//                               size: 23,
//                               isBold: true,
//                               isCopy: true,
//                             ),
//                           ],
//                         ),
//                         5.height,
//                         CustomText(
//                           text:
//                           "Add your Products Information\n\n",
//                           colors: colorsConst.textColor,
//                           size: 15,
//                           isCopy: true,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 10.height,
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomTextField(
//                           hintText: "Tittle",
//                           focusNode: title,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(description);
//                           },
//                           text: "Tittle",
//                           isOptional: true,
//                           controller: productCtr.title,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.title);
//                           },
//                         ),
//                         CustomTextField(
//                           hintText: "Description",
//                           focusNode: description,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(availability);
//                           },
//                           text: "Description",
//                           isOptional: true,
//                           controller: productCtr.description,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.description);
//                           },
//                         ),
//                       ],
//                     ),
//                     10.height,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomTextField(
//                           hintText: "Availability",
//                           focusNode: availability,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(condition);
//                           },
//                           text: "Availability",
//                           isOptional: true,
//                           controller: productCtr.availability,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.availability);
//                           },
//                         ),
//                         CustomTextField(
//                           hintText: "Condition",
//                           focusNode: condition,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(price);
//                           },
//                           text: "Condition",
//                           isOptional: true,
//                           controller: productCtr.condition,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.condition);
//                           },
//                         ),
//                       ],
//                     ),
//                     10.height,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomTextField(
//                           hintText: "Price",
//                           focusNode: price,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(brand);
//                           },
//                           text: "Price",
//                           isOptional: true,
//                           controller: productCtr.price,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.numberInput,
//                         ),
//                         CustomTextField(
//                           hintText: "Brand",
//                           focusNode: brand,
//                           onEdit: () {
//                             // FocusScope.of(context).requestFocus(price);
//                           },
//                           text: "Brand",
//                           isOptional: true,
//                           controller: productCtr.brand,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.brand);
//                           },
//                         ),
//                       ],
//                     ),
//                     /// IMAGE VIEW
//                     Row(
//                       children: [
//                         Obx(() {
//                             if (productCtr.selectedFile.value == null) {
//                               return InkWell(
//                                 onTap: (){
//                                   productCtr.pickImage();
//                                 },
//                                 child: Container(
//                                   height: 100,
//                                   width: 100,
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.grey.shade300),
//                                   ),
//                                   child: CustomText(
//                                     text: "Select Image",
//                                     isCopy: false,
//                                   ),
//                                 ),
//                               );
//                             }
//
//                             return InkWell(
//                               onTap: (){
//                                 productCtr.pickImage();
//                               },
//                               child: Image.memory(
//                                 productCtr.selectedFile.value!.bytes!,
//                                 height: 100,
//                                 width: 100,
//                                 fit: BoxFit.cover,
//                               ),
//                             );
//
//                         }),
//                         50.width,
//                         CustomLoadingButton(
//                             callback: (){
//                               if(productCtr.title.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product title", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.description.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product description", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.availability.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product availability", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.condition.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product condition", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.price.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product price", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.brand.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product brand", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.selectedFile.value==null){
//                                 billing_utils.snackBar(context: context, msg: "Please add product image", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else{
//                                 productCtr.addProduct(context);
//                               }
//                             }, isLoading: true, controller: productCtr.saveCtr,text: "Save",
//                             backgroundColor: colorsConst.primary, radius: 10, width: 100)
//                       ],
//                     ),
//                   ],
//                 ),
//               ])),
//         ]));
//   }
// }
//
//
//
// class UpdateProduct extends StatefulWidget {
//   final ProductModel billing_data;
//   const UpdateProduct({super.key, required this.billing_data});
//
//   @override
//   State<UpdateProduct> createState() => _UpdateProductState();
// }
//
// class _UpdateProductState extends State<UpdateProduct> {
//   final FocusNode title = FocusNode();
//   final FocusNode description = FocusNode();
//   final FocusNode availability = FocusNode();
//   final FocusNode condition = FocusNode();
//   final FocusNode price = FocusNode();
//   final FocusNode brand = FocusNode();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(title);
//       // productCtr.title.text=widget.billing_data.title.toString();
//       // productCtr.description.text=widget.billing_data.description.toString();
//       // productCtr.availability.text=widget.billing_data.availability.toString();
//       // productCtr.condition.text=widget.billing_data.condition.toString();
//       // productCtr.price.text=widget.billing_data.price.toString();
//       // productCtr.brand.text=widget.billing_data.brand.toString();
//       // productCtr.selectedFile.value = null;
//     });
//   }
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     title.dispose();
//     description.dispose();
//     availability.dispose();
//     condition.dispose();
//     price.dispose();
//     brand.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     double textFieldSize = MediaQuery.of(context).size.width*0.7;
//     return Scaffold(
//         body: Row(children: [
//           SideBar(),
//           20.width,
//           Container(
//               width: MediaQuery.of(context).size.width*0.8,
//               alignment: Alignment.center,
//               child: Column(children: [
//                 22.height,
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             InkWell(
//                               onTap:(){
//                                 Get.back();
//                               },
//                               child: Icon(Icons.arrow_back),
//                             ),10.width,
//                             CustomText(
//                               text:
//                               "Update Product",
//                               colors: colorsConst.textColor,
//                               size: 23,
//                               isBold: true,
//                               isCopy: true,
//                             ),
//                           ],
//                         ),
//                         5.height,
//                         CustomText(
//                           text:
//                           "Update your Products Information\n\n",
//                           colors: colorsConst.textColor,
//                           size: 15,
//                           isCopy: true,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 10.height,
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomTextField(
//                           hintText: "Tittle",
//                           focusNode: title,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(description);
//                           },
//                           text: "Tittle",
//                           isOptional: true,
//                           controller: productCtr.title,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.title);
//                           },
//                         ),
//                         CustomTextField(
//                           hintText: "Description",
//                           focusNode: description,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(availability);
//                           },
//                           text: "Description",
//                           isOptional: true,
//                           controller: productCtr.description,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.description);
//                           },
//                         ),
//                       ],
//                     ),
//                     10.height,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomTextField(
//                           hintText: "Availability",
//                           focusNode: availability,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(condition);
//                           },
//                           text: "Availability",
//                           isOptional: true,
//                           controller: productCtr.availability,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.availability);
//                           },
//                         ),
//                         CustomTextField(
//                           hintText: "Condition",
//                           focusNode: condition,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(price);
//                           },
//                           text: "Condition",
//                           isOptional: true,
//                           controller: productCtr.condition,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.condition);
//                           },
//                         ),
//                       ],
//                     ),
//                     10.height,
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomTextField(
//                           hintText: "Price",
//                           focusNode: price,
//                           onEdit: () {
//                             FocusScope.of(context).requestFocus(brand);
//                           },
//                           text: "Price",
//                           isOptional: true,
//                           controller: productCtr.price,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.numberInput,
//                         ),
//                         CustomTextField(
//                           hintText: "Brand",
//                           focusNode: brand,
//                           onEdit: () {
//                             // FocusScope.of(context).requestFocus(price);
//                           },
//                           text: "Brand",
//                           isOptional: true,
//                           controller: productCtr.brand,
//                           width: textFieldSize/2,
//                           textInputAction: TextInputAction.next,
//                           inputFormatters:constInputFormatters.textInput,
//                           onChanged: (value) {
//                             billing_utils.caps(value.toString(),productCtr.brand);
//                           },
//                         ),
//                       ],
//                     ),
//                     /// IMAGE VIEW
//                     Row(
//                       children: [
//                         // Obx(() {
//                         //   if (widget.billing_data.link!="null"&&widget.billing_data.link!=""&&productCtr.selectedFile.value==null) {
//                         //     return InkWell(
//                         //       onTap: (){
//                         //         productCtr.pickImage();
//                         //       },
//                         //       child: Container(
//                         //         height: 100,
//                         //         width: 100,
//                         //         alignment: Alignment.center,
//                         //         decoration: BoxDecoration(
//                         //           border: Border.all(color: Colors.grey.shade300),
//                         //         ),
//                         //         child: Image.network(
//                         //           '$imageFile?path=${widget.billing_data.link}',
//                         //           fit: BoxFit.cover,width: 50,height: 50,
//                         //         ),
//                         //       ),
//                         //     );
//                         //   }
//                         //   if (productCtr.selectedFile.value == null) {
//                         //     return InkWell(
//                         //       onTap: (){
//                         //         productCtr.pickImage();
//                         //       },
//                         //       child: Container(
//                         //         height: 100,
//                         //         width: 100,
//                         //         alignment: Alignment.center,
//                         //         decoration: BoxDecoration(
//                         //           border: Border.all(color: Colors.grey.shade300),
//                         //         ),
//                         //         child: CustomText(
//                         //           text: "Select Image",
//                         //           isCopy: false,
//                         //         ),
//                         //       ),
//                         //     );
//                         //   }
//                         //
//                         //   return InkWell(
//                         //     onTap: (){
//                         //       productCtr.pickImage();
//                         //     },
//                         //     child: Image.memory(
//                         //       productCtr.selectedFile.value!.bytes!,
//                         //       height: 100,
//                         //       width: 100,
//                         //       fit: BoxFit.cover,
//                         //     ),
//                         //   );
//                         //
//                         // }),
//                         50.width,
//                         CustomLoadingButton(
//                             callback: (){
//                               if(productCtr.title.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product title", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.description.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product description", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.availability.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product availability", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.condition.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product condition", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.price.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product price", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }else if(productCtr.brand.text.trim().isEmpty){
//                                 billing_utils.snackBar(context: context, msg: "Please add product brand", color: Colors.red);
//                                 productCtr.saveCtr.reset();
//                               }
//                               // else if(productCtr.selectedFile.value==null){
//                               //   billing_utils.snackBar(context: context, msg: "Please add product image", color: Colors.red);
//                               //   productCtr.saveCtr.reset();
//                               // }
//                               else{
//                                 productCtr.updateProduct(context,widget.billing_data.id.toString(),widget.billing_data.imageLink.toString(),widget.billing_data.link.toString());
//                               }
//                             }, isLoading: true, controller: productCtr.saveCtr,text: "Save",
//                             backgroundColor: colorsConst.primary, radius: 10, width: 100)
//                       ],
//                     ),
//                   ],
//                 ),
//               ])),
//         ]));
//   }
// }
