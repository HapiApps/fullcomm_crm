import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/constant/default_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_sidebar_text.dart';
import 'package:fullcomm_crm/controller/controller.dart';
import '../common/constant/api.dart';
import '../common/constant/assets_constant.dart';
import '../components/custom_appbar.dart';
import '../components/custom_lead_tile.dart';
import '../components/custom_text.dart';
import '../models/lead_obj.dart';
import '../models/new_lead_obj.dart';
import '../services/api_services.dart';
import 'leads/add_lead.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ScrollController scrollController;
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController=ScrollController();
    controllers.allCustomerFuture=apiService.allCustomerDetails();
    controllers.allProductFuture=apiService.allProductDetails();
    apiService.allLeadsDetails();
    controllers.allEmployeeFuture=apiService.allEmployeeDetails();
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth = screenSize.width-380.0;
    final double partWidth = minPartWidth / 7;
    // var d=MediaQuery.of(context).size.width-130;
    // var iD=MediaQuery.of(context).size.width-250;
    // print("width $d");
    // if(MediaQuery.of(context).size.width-130==1349){
    //   print("in width $iD");
    // }
    final double adjustedPartWidth = partWidth;
    return Scaffold(
        backgroundColor:Colors.grey.shade100,
        appBar:const PreferredSize(
          preferredSize:Size.fromHeight(60),
          child:CustomAppbar(text: appName,),
        ),


         body:Stack(
           children: [
             Positioned(
               top: 0,
               left: 0,
               child: Container(
                 width:130,
                 height: MediaQuery.of(context).size.height,
                 color: colorsConst.primary,
                 child: SingleChildScrollView(
                   child: Column(
                     children: [
                       Container(
                         height: 0.5,
                         color: Colors.white,
                       ),
                       Obx(() =>  CustomSideBarText(
                           text: constValue.dashboard,
                           textColor:controllers.selectedIndex.value==0?const Color(0xffF5CB39):Colors.white,
                           onClicked: (){
                             controllers.selectedIndex.value=0;
                           }),),

                       const Divider(
                         color: Colors.white,
                         thickness: 0.5,
                       ),
                       Obx(() =>  CustomSideBarText(
                           textColor:controllers.selectedIndex.value==1?const Color(0xffF5CB39):Colors.white,

                           text: constValue.lead,
                           onClicked: (){
                             controllers.isLead.value=true;
                             controllers.selectedIndex.value=1;
                           }),),

                       const Divider(
                         color: Colors.white,
                         thickness: 0.5,
                       ),
                       Obx(() =>  CustomSideBarText(
                           textColor:controllers.selectedIndex.value==2?const Color(0xffF5CB39):Colors.white,

                           text: constValue.customer,
                           onClicked: (){
                             controllers.isCustomer.value=true;
                             controllers.selectedIndex.value=2;
                           }),
                       ),

                       const Divider(
                         color: Colors.white,
                         thickness: 0.5,
                       ),
                       Obx(() => CustomSideBarText(
                           textColor:controllers.selectedIndex.value==3?const Color(0xffF5CB39):Colors.white,

                           text: constValue.hr,
                           onClicked: (){
                             controllers.isEmployee.value=true;
                             controllers.selectedIndex.value=3;
                           }),),
                       const Divider(
                         color: Colors.white,
                         thickness: 0.5,
                       ),
                       Obx(() => CustomSideBarText(
                           textColor:controllers.selectedIndex.value==4?const Color(0xffF5CB39):Colors.white,

                           text: constValue.products,
                           onClicked: (){
                             controllers.isProduct.value=true;
                             controllers.selectedIndex.value=4;
                           }),),
                       100.height

                     ],
                   ),
                 ),
               ),
             ),
             Positioned(
               left:130,
               child: Obx(() => controllers.isLead.value==false? const AddLead():
               Container(
                            width: 1349>MediaQuery.of(context).size.width-130?1349:MediaQuery.of(context).size.width-130,
                             alignment: Alignment.center,
                             child: SingleChildScrollView(
                              // keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,
                              //  controller: scrollController,
                               physics: const AlwaysScrollableScrollPhysics(),
                               scrollDirection: Axis.horizontal,
                               child: SizedBox(
                                 width: 1230>MediaQuery.of(context).size.width-250?1230:MediaQuery.of(context).size.width-250,
                                 height: MediaQuery.of(context).size.height,
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children:[
                                     30.height,
                                     CustomText(
                                       text: "Leads(2)",
                                       colors: colorsConst.primary,
                                       size:23,isBold: true,
                                     ),
                                     20.height,
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         SizedBox(
                                           child: Row(
                                             children: [
                                               SvgPicture.asset(assets.delete,width: 25,height: 25,),
                                               10.width,
                                               SvgPicture.asset(assets.edit,width: 18,height: 18,),
                                             ],
                                           ),

                                         ),
                                         SizedBox(
                                           child:
                                           Row(
                                             children: [
                                               GestureDetector(
                                                 onTap:(){
                                                   controllers.isLead.value=false;
                                                   //Get.to(const AddLead());
                                                 },
                                                 child: CustomText(
                                                   text: "Add Lead",
                                                   colors: colorsConst.primary,
                                                   size: 20,
                                                 ),
                                               ),
                                               CustomText(
                                                 text: "|",
                                                 colors: colorsConst.secondary,
                                                 size: 20,
                                               ),
                                               CustomText(
                                                 text: "Import",
                                                 colors: colorsConst.primary,
                                                 size: 20,
                                               )
                                             ],
                                           ),

                                         ),
                                       ],
                                     ),
                                     20.height,
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.end,
                                       children:[
                                         SvgPicture.asset(assets.manageColumn),
                                         20.width,
                                         SizedBox(
                                           width: 1230>MediaQuery.of(context).size.width-250?1100:MediaQuery.of(context).size.width-300,
                                           height: 50,
                                           child: TextField(

                                             textCapitalization:TextCapitalization.words,
                                             keyboardType:TextInputType.text,
                                             onChanged: (value){
                                               setState(() {
                                                 controllers.searchText=value.trim();
                                               });
                                             },
                                             decoration: InputDecoration(
                                               hoverColor:Colors.white,
                                               hintText: "Search",
                                               hintStyle: TextStyle(
                                                 color:colorsConst.secondary,
                                                 fontSize: 15,
                                                 fontFamily:"Lato",
                                               ),
                                               //prefixIcon: SvgPicture.asset(assets.search,width: 1,height: 1,),
                                               prefixIcon: IconButton(
                                                   onPressed: (){},
                                                   icon:SvgPicture.asset(assets.search,width: 15,height: 15)),
                                               fillColor:Colors.white,
                                               filled: true,
                                               enabledBorder: OutlineInputBorder(
                                                   borderSide:  BorderSide(color:Colors.grey.shade300,),
                                                   borderRadius: BorderRadius.circular(10)
                                               ),
                                               focusedBorder: OutlineInputBorder(
                                                   borderSide:  BorderSide(color:Colors.grey.shade300,),
                                                   borderRadius: BorderRadius.circular(10)
                                               ),
                                               contentPadding:const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                             ),
                                           ),
                                         )
                                       ],
                                     ),
                                     Divider(
                                       color:Colors.grey.shade300,
                                       thickness: 1,
                                     ),
                                     10.height,
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.end,
                                       children:[
                                         SizedBox(
                                           width:1230>MediaQuery.of(context).size.width-250?1000:MediaQuery.of(context).size.width-380,
                                           child: Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                             children: [
                                               SizedBox(
                                                 width:adjustedPartWidth,
                                                 child: CustomText(
                                                   textAlign: TextAlign.start,
                                                   text:"Name",
                                                   size: 15,
                                                   colors: colorsConst.primary,
                                                   //isBold: true,
                                                 ),
                                               ),
                                               SizedBox(
                                                 width:adjustedPartWidth,
                                                 child: CustomText(
                                                   textAlign: TextAlign.start,
                                                   text:"Mobile no.",
                                                   size: 15,
                                                   colors: colorsConst.primary,
                                                   //isBold: true,
                                                 ),
                                               ),
                                               SizedBox(
                                                 width:adjustedPartWidth,
                                                 child: CustomText(
                                                   textAlign: TextAlign.start,
                                                   text:"Email",
                                                   size: 15,
                                                   colors: colorsConst.primary,
                                                   // isBold: true,
                                                 ),
                                               ),
                                               SizedBox(
                                                 width:adjustedPartWidth,
                                                 child: CustomText(
                                                   textAlign: TextAlign.start,
                                                   text:"Company Name",
                                                   size: 15,
                                                   colors: colorsConst.primary,
                                                   //isBold: true,
                                                 ),
                                               ),
                                               SizedBox(
                                                 width: minPartWidth / 11,
                                                 child: Center(
                                                   child: CustomText(
                                                     textAlign: TextAlign.start,
                                                     text:"Status",
                                                     size: 15,
                                                     colors: colorsConst.primary,
                                                     //isBold: true,
                                                   ),
                                                 ),
                                               ),
                                               SizedBox(
                                                 width: minPartWidth / 11,
                                                 child: Center(
                                                   child: CustomText(
                                                     text:"Rating",
                                                     size: 15,
                                                     colors: colorsConst.primary,
                                                     //isBold: true,
                                                   ),
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ],
                                     ),
                                     // Expanded(
                                     //   child: FutureBuilder<List<NewLeadObj>>(
                                     //     future:controllers.allLeadFuture,
                                     //     builder:(context, snapshot){
                                     //       if(snapshot.hasData){
                                     //         return ListView.builder(
                                     //             itemCount: snapshot.data!.length,
                                     //             itemBuilder:(context, index){
                                     //               if (snapshot.data![index].firstname.toString().toLowerCase().contains(controllers.searchText.toLowerCase())){
                                     //                 return CustomLeadTile(
                                     //                   name: snapshot.data![index].firstname.toString(),
                                     //                   mobileNumber:snapshot.data![index].mobileNumber.toString(),
                                     //                   email:snapshot.data![index].emailId.toString(),
                                     //                   companyName:snapshot.data![index].companyName.toString(),
                                     //                   status:snapshot.data![index].status.toString(),
                                     //                   rating:snapshot.data![index].rating.toString(),
                                     //                   updatedTs: snapshot.data![index].updatedTs ?? "",
                                     //                 );
                                     //               }
                                     //               return const SizedBox();
                                     //
                                     //             }
                                     //         );
                                     //       }else if(snapshot.hasError){
                                     //         return Text("${snapshot.error}");
                                     //       }
                                     //       return  const Center(child:CircularProgressIndicator());
                                     //     },
                                     //   ),
                                     // ),


                                     20.height,
                                   ],
                                 ),
                               ),
                             ),
                           ),
               ),
               // child: Obx(() => controllers.selectedIndex.value==0?const Dashboard()
               //     :controllers.selectedIndex.value==1?const ViewLead()
               //     :controllers.selectedIndex.value==2?const ViewCustomer()
               //     :controllers.selectedIndex.value==3?const ViewEmployees()
               //     :const ViewProduct(),),
             )
           ],
         ),


    );
  }
}
