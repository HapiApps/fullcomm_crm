
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/default_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_appbar.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../controller/controller.dart';

class TFSAddProducts extends StatefulWidget {
  const TFSAddProducts({super.key});

  @override
  State<TFSAddProducts> createState() => _TFSAddProductsState();
}

class _TFSAddProductsState extends State<TFSAddProducts> {
  @override
  Widget build(BuildContext context){
    double textFieldSize=(MediaQuery.of(context).size.width-350)/3.5;
    return SelectionArea(
      child: Scaffold(
          appBar: const PreferredSize(
            preferredSize:  Size.fromHeight(60),
            child:  CustomAppbar(text: appName,),
          ),
          body: Stack(
            children:[
              utils.sideBarFunction(context),
              Positioned(
                left:130,
                top: 0,
                bottom: 0,
                right: 0,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 1349>MediaQuery.of(context).size.width-130?1349:MediaQuery.of(context).size.width-130,
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          30.height,
                          CustomText(
                            text: "Add Product",
                            colors: colorsConst.primary,
                            size:23,isBold: true,
                          ),
                          30.height,
                          Center(
                            child: Container(
                              alignment: Alignment.center,
                              width:MediaQuery.of(context).size.width-300,
                              height:500,
                              decoration:BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: SizedBox(
                                width:MediaQuery.of(context).size.width-400,
                                child: Column(
                                  children:[
                                    50.height,
                                    const Row(
                                      children:[
                                        CustomText(
                                          text:"Product Details",
                                          colors: Colors.black,
                                          size: 20,

                                        ),
                                      ],
                                    ),
                                    10.height,
                                    Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 1,
                                    ),
                                    20.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children:[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children:[
                                            CustomDropDown(
                                              saveValue: controllers.category,
                                              valueList: controllers.categoryList,
                                              text:"Category",
                                              width:textFieldSize,

                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged:(value) async {
                                                setState(() {
                                                  controllers.category= value;
                                                });
                                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                                sharedPref.setString("category", value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }

                                            ),
                                            25.height,
                                            CustomTextField(
                                              hintText:"Quantity Range",
                                              text:"Quantity Range",
                                              controller: controllers.comparePriceController,
                                              width:textFieldSize,
                                              keyboardType: TextInputType.text,
                                              textInputAction: TextInputAction.next,
                                              inputFormatters: constInputFormatters.numberInput,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged:(value) async {
                                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                                sharedPref.setString("quantityRange", value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }

                                            ),
                                            25.height,
                                            CustomTextField(
                                              hintText:"Amount",
                                              text:"Amount",
                                              controller: controllers.productPriceController,
                                              width:textFieldSize,
                                              keyboardType: TextInputType.text,

                                              inputFormatters: constInputFormatters.numberInput,
                                              onChanged:(value) async {
                                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                                sharedPref.setString("amount", value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }

                                            ),
                                            25.height,

                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children:[
                                            15.height,
                                            CustomDropDown(
                                              saveValue: controllers.designation,
                                              valueList: controllers.designationList,
                                              text:"Designation",
                                              width:textFieldSize,
                                              //inputFormatters: constInputFormatters.textInput,
                                              onChanged:(value) async {
                                                setState(() {
                                                  controllers.designation= value;
                                                });
                                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                                sharedPref.setString("designation", value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }

                                            ),


                                            20.height,
                                            CustomTextField(
                                              hintText:"Location",
                                              text:"Location",
                                              controller: controllers.discountOnMRPController,
                                              width:textFieldSize,
                                              keyboardType: TextInputType.text,
                                              inputFormatters: constInputFormatters.numberInput,
                                              onChanged:(value) async {
                                                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                                                sharedPref.setString("location", value.toString().trim());
                                              },
                                              // validator:(value){
                                              //   if(value.toString().isEmpty){
                                              //     return "This field is required";
                                              //   }else if(value.toString().trim().length!=10){
                                              //     return "Check Your Phone Number";
                                              //   }else{
                                              //     return null;
                                              //   }
                                              // }

                                            ),
                                            125.height
                                          ],
                                        ),
                                      ],
                                    ),

                                    10.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children:[
                                        CustomLoadingButton(
                                            callback: (){
                                              if(controllers.prodNameController.text.isEmpty){
                                                utils.snackBar(msg: "Please add product name",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.categoryController.text.isEmpty){
                                                utils.snackBar(msg: "Please add category",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.comparePriceController.text.isEmpty){
                                                utils.snackBar(msg: "Please add compare price",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.productPriceController.text.isEmpty){
                                                utils.snackBar(msg: "Please add product price",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.netPriceController.text.isEmpty){
                                                utils.snackBar(msg: "Please add net price",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.hsnController.text.isEmpty){
                                                utils.snackBar(msg: "Please add HSN/SAC code",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.prodBrandController.text.isEmpty){
                                                utils.snackBar(msg: "Please add brand",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.subCategory==null){
                                                utils.snackBar(msg: "Please add sub category",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.tax==null){
                                                utils.snackBar(msg: "Please add tax",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else if(controllers.discountController.text.isEmpty){
                                                utils.snackBar(msg: "Please add discount",
                                                    color: colorsConst.primary,context:Get.context!);
                                              }else{
                                                apiService.insertProductAPI(context);
                                              }

                                            },
                                            text: "Save Product",
                                            height: 60,
                                            controller: controllers.productCtr,
                                            isLoading:true,
                                            backgroundColor: colorsConst.primary,
                                            radius: 10,
                                            width: 200),
                                        30.width
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          20.height,
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}
