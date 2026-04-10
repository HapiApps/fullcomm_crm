import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:get/get.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../services/api_services.dart';
import 'lead_categories.dart';

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      dashController.selectedSortBy.value = controllers.storage.read("selectedSortBy") ?? "Today";
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "\nGeneral Settings",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                          isCopy: true,
                        ),
                        10.height,
                        CustomText(
                          text: "Manage global settings across the application.  \n",
                          colors: colorsConst.textColor,
                          isCopy: true,
                          size: 14,
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     SizedBox(
                    //       height: 40,
                    //       child: ElevatedButton.icon(
                    //         icon: Icon(Icons.add,color: Colors.white,),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: colorsConst.primary,
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //         ),
                    //         onPressed: (){
                    //           Navigator.push(context, MaterialPageRoute(builder: (_)=>LeadCategories()));
                    //         },
                    //         label: CustomText(
                    //           text: "Lead Categories",
                    //           colors: Colors.white,
                    //           isBold :true,
                    //           isCopy: false,
                    //           size: 14,
                    //         ),),
                    //     ),
                    //     10.width,
                    //     SizedBox(
                    //       height: 40,
                    //       child: ElevatedButton.icon(
                    //         icon: Icon(Icons.add,color: Colors.white,),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: colorsConst.primary,
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //         ),
                    //         onPressed: (){
                    //           utils.showFilterDialog(context);
                    //         },
                    //         label: CustomText(
                    //           text: "Set Date Range",
                    //           colors: Colors.white,
                    //           isBold :true,
                    //           isCopy: false,
                    //           size: 14,
                    //         ),),
                    //     ),
                    //     10.width,
                    //     SizedBox(
                    //       height: 40,
                    //       child: ElevatedButton.icon(
                    //         icon: Icon(Icons.add,color: Colors.white,),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: colorsConst.primary,
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //         ),
                    //         onPressed: (){
                    //           utils.showLeadCategoryDialog(context);
                    //         },
                    //         label: CustomText(
                    //           text: "Set Labels",
                    //           colors: Colors.white,
                    //           isBold :true,
                    //           isCopy: false,
                    //           size: 14,
                    //         ),),
                    //     ),
                    //     10.width,
                    //     SizedBox(
                    //       height: 40,
                    //       child: ElevatedButton.icon(
                    //         icon: Icon(Icons.add,color: Colors.white,),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: colorsConst.primary,
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //         ),
                    //         onPressed: (){
                    //           Navigator.push(
                    //             context,
                    //             PageRouteBuilder(
                    //               pageBuilder: (context, animation1, animation2) =>
                    //               const AddOfficeHours(),
                    //               transitionDuration: Duration.zero,
                    //               reverseTransitionDuration: Duration.zero,
                    //             ),
                    //           );
                    //         },
                    //         label: CustomText(
                    //           text: "Add Office Hours",
                    //           colors: Colors.white,
                    //           isBold :true,
                    //           isCopy: false,
                    //           size: 14,
                    //         ),),
                    //     ),
                    //     10.width,
                    //     SizedBox(
                    //       height: 40,
                    //       child: ElevatedButton.icon(
                    //         icon: Icon(Icons.add,color: Colors.white,),
                    //         style: ElevatedButton.styleFrom(
                    //           backgroundColor: colorsConst.primary,
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(5),
                    //           ),
                    //         ),
                    //         onPressed: (){
                    //           Get.dialog(
                    //             Dialog(
                    //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    //               child: Container(
                    //                 width: 300,
                    //                 padding: const EdgeInsets.all(16),
                    //                 child: Column(
                    //                   mainAxisSize: MainAxisSize.min,
                    //                   children: [
                    //                     CustomText(
                    //                       text: "Record Status",
                    //                       colors: colorsConst.textColor,
                    //                       isBold: true,
                    //                       size: 18,
                    //                       isCopy: true,
                    //                     ),
                    //                     10.height,
                    //                     SizedBox(
                    //                       width: 300,
                    //                       child: ListView.builder(
                    //                         shrinkWrap: true,
                    //                         itemCount: controllers.hCallStatusList.length,
                    //                         itemBuilder: (context, index) {
                    //                           final item = controllers.hCallStatusList[index];
                    //                           return Row(
                    //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                             children: [
                    //                               CustomText(text: item["value"], isCopy: false),
                    //                               TextButton(
                    //                                 onPressed:(){
                    //                                   controllers.statusController.text=item["value"];
                    //                                     Get.dialog(
                    //                                       Dialog(
                    //                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    //                                         child: Container(
                    //                                           width: 300,
                    //                                           padding: const EdgeInsets.all(16),
                    //                                           child: Column(
                    //                                             mainAxisSize: MainAxisSize.min,
                    //                                             children: [
                    //                                               CustomText(
                    //                                                 text: "Update Record Status",
                    //                                                 colors: colorsConst.textColor,
                    //                                                 isBold: true,
                    //                                                 size: 18,
                    //                                                 isCopy: true,
                    //                                               ),
                    //                                               10.height,
                    //                                               SizedBox(
                    //                                                 width: 500,
                    //                                                 child: TextField(
                    //                                                   controller: controllers.statusController,
                    //                                                   style: TextStyle(
                    //                                                       fontSize: 15, color: colorsConst.textColor),
                    //                                                   decoration: const InputDecoration(
                    //                                                     border: UnderlineInputBorder(),
                    //                                                   ),
                    //                                                 ),
                    //                                               ),
                    //                                               20.height,
                    //                                               Row(
                    //                                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //                                                 children: [
                    //                                                   ElevatedButton(
                    //                                                     onPressed: () {
                    //                                                       Navigator.of(context).pop();
                    //                                                     },
                    //                                                     style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    //                                                     child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                    //                                                   ),
                    //                                                   CustomLoadingButton(
                    //                                                     callback: (){
                    //                                                       if(controllers.statusController.text.trim().isEmpty){
                    //                                                         utils.snackBar(context: context, msg: "Please fill status", color: Colors.red);
                    //                                                         controllers.productCtr.reset();
                    //                                                       }else{
                    //                                                         controllers.correctionStatus(context,"update",item["id"].toString());
                    //                                                       }
                    //                                                     },
                    //                                                     height: 35,
                    //                                                     isLoading: true,
                    //                                                     backgroundColor: colorsConst.primary,
                    //                                                     radius: 2,
                    //                                                     width: 80,
                    //                                                     controller: controllers.productCtr,
                    //                                                     isImage: false,
                    //                                                     text: "Save",
                    //                                                     textColor: Colors.white,
                    //                                                   ),
                    //                                                 ],
                    //                                               )
                    //                                             ],
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                     );
                    //                                 },
                    //                                 child: SvgPicture.asset(
                    //                                   "assets/images/a_edit.svg",
                    //                                   width: 16,
                    //                                   height: 16,
                    //                                 ),
                    //                               ),
                    //                             ],
                    //                           );
                    //                         },
                    //                       ),
                    //                     ),
                    //                     20.height,
                    //                     Row(
                    //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //                       children: [
                    //                         ElevatedButton(
                    //                           onPressed: () {
                    //                             Navigator.of(context).pop();
                    //                           },
                    //                           style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    //                           child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                    //                         ),
                    //                         ElevatedButton(
                    //                           onPressed: ()  {
                    //                             controllers.statusController.clear();
                    //                             Get.dialog(
                    //                               Dialog(
                    //                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    //                                 child: Container(
                    //                                   width: 300,
                    //                                   padding: const EdgeInsets.all(16),
                    //                                   child: Column(
                    //                                     mainAxisSize: MainAxisSize.min,
                    //                                     children: [
                    //                                       CustomText(
                    //                                         text: "Add Record Status",
                    //                                         colors: colorsConst.textColor,
                    //                                         isBold: true,
                    //                                         size: 18,
                    //                                         isCopy: true,
                    //                                       ),
                    //                                       10.height,
                    //                                       SizedBox(
                    //                                         width: 500,
                    //                                         child: TextField(
                    //                                           controller: controllers.statusController,
                    //                                           style: TextStyle(
                    //                                               fontSize: 15, color: colorsConst.textColor),
                    //                                           decoration: const InputDecoration(
                    //                                             border: UnderlineInputBorder(),
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                       20.height,
                    //                                       Row(
                    //                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //                                         children: [
                    //                                           ElevatedButton(
                    //                                             onPressed: () {
                    //                                               Navigator.of(context).pop();
                    //                                             },
                    //                                             style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    //                                             child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                    //                                           ),
                    //                                       CustomLoadingButton(
                    //                                         callback: (){
                    //                                             if(controllers.statusController.text.trim().isEmpty){
                    //                                               utils.snackBar(context: context, msg: "Please fill status", color: Colors.red);
                    //                                               controllers.productCtr.reset();
                    //                                             }else{
                    //                                               controllers.correctionStatus(context,"add","0");
                    //                                             }
                    //                                           },
                    //                                           height: 35,
                    //                                           isLoading: true,
                    //                                           backgroundColor: colorsConst.primary,
                    //                                           radius: 2,
                    //                                           width: 80,
                    //                                           controller: controllers.productCtr,
                    //                                           isImage: false,
                    //                                           text: "Add",
                    //                                           textColor: Colors.white,
                    //                                           ),
                    //                                         ],
                    //                                       )
                    //                                     ],
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                             );
                    //                             },
                    //                           child: const Text("Add Status"),
                    //                         ),
                    //                       ],
                    //                     )
                    //                   ],
                    //                 ),
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //         label: CustomText(
                    //           text: "Record Status",
                    //           colors: Colors.white,
                    //           isBold :true,
                    //           isCopy: false,
                    //           size: 14,
                    //         ),),
                    //     )
                    //   ],
                    // ),
                  ],
                ),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      InkWell(
                        onTap:(){
                          Navigator.push(context, MaterialPageRoute(builder: (_)=>LeadCategories()));
                        },
                        child: Container(
                          width:screenWidth/5,
                          decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,borderColor: Colors.grey.shade200,radius: 15,shadowColor: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width:35,height:35,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 5
                                        ),
                                        child: Center(child: Image.asset("assets/images/setting1.png"),)),10.width,
                                    CustomText(
                                      text: "1. Lead Categories",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Manage the order and structure of categories used across the dashboard billing.",
                                  isCopy: true,textAlign: TextAlign.start,
                                ),5.height,
                                Divider(thickness: 0.2,color: Colors.grey,),5.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("assets/images/setting4.png",width: 15,height: 15,),
                                        5.width,
                                        CustomText(
                                          text: "${controllers.leadCategoryList.length} categories",
                                          isCopy: true,
                                        ),
                                      ],
                                    ),
                                    Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 15
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text:"Manage Categories >",colors: colorsConst.primary,isCopy: false,),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          utils.showFilterDialog(context);
                        },
                        child: Container(
                          width:screenWidth/5,
                          decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,borderColor: Colors.grey.shade200,radius: 15,shadowColor: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width:35,height:35,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 5
                                        ),
                                        child: Center(child: Icon(Icons.calendar_today_outlined,color: colorsConst.primary,size: 20,))),10.width,
                                    CustomText(
                                      text: "2. Default Date Range",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Choose the default time filter applied to dashboard records and analytics billing.",
                                  isCopy: true,textAlign: TextAlign.start,
                                ),5.height,
                                Divider(thickness: 0.2,color: Colors.grey,),5.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("assets/images/setting3.png",width: 15,height: 15,),5.width,
                                        Obx(()=>CustomText(
                                          text: dashController.selectedSortBy.value,
                                          isCopy: true,
                                        )),
                                      ],
                                    ),
                                    Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 15
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text:"Configure Range >",colors: colorsConst.primary,isCopy: false,),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          var isAdd = false.obs;
                          var editIndex = 100.obs;
                          TextEditingController addCtr = TextEditingController();
                          FocusNode addFocus = FocusNode();
                          addCtr.clear();
                          List<FocusNode> focusList =
                          List.generate(controllers.hCallStatusList.length, (index) => FocusNode());

                          List<TextEditingController> ctrList =
                          List.generate(controllers.hCallStatusList.length, (index) =>
                              TextEditingController(text: controllers.hCallStatusList[index]["value"]));
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Color(0xFFF1F5F9),
                                titlePadding: EdgeInsets.zero,
                                contentPadding: EdgeInsets.zero,
                                content: SizedBox(
                                  width: 420,
                                  child: Obx(()=>Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      /// HEADER
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE5E7EB),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: customDecoration.baseBackgroundDecoration(
                                                color: colorsConst.primary,
                                                radius: 6,
                                              ),
                                              child: const Icon(Icons.folder_outlined,
                                                  color: Colors.white, size: 18),
                                            ),
                                            10.width,
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    text: "Call Record Status",
                                                    isCopy: false,
                                                    isBold: true,
                                                    size: 15,
                                                  ),
                                                  CustomText(
                                                    text:
                                                    "Manage customer engagement status types",
                                                    isCopy: false,
                                                    size: 12,
                                                    colors: Colors.grey.shade600,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                width: 26,
                                                height: 26,
                                                decoration: customDecoration.baseBackgroundDecoration(
                                                  color: Colors.transparent,
                                                  radius: 5,
                                                  borderColor: Colors.grey.shade400,
                                                ),
                                                child:  Center(
                                                    child: Icon(Icons.clear,color: Colors.grey,size: 15,)
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      /// STATUS LIST
                                      Column(
                                        children: List.generate(controllers.hCallStatusList.length, (index) {
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            decoration: customDecoration.baseBackgroundDecoration(
                                              color: Colors.white,
                                              borderColor: Colors.grey.shade300,
                                              radius: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                editIndex.value==index?
                                                SizedBox(
                                                  width:140,
                                                  child: TextField(
                                                    focusNode: focusList[index],
                                                    controller: ctrList[index],
                                                    decoration: InputDecoration(
                                                      border: UnderlineInputBorder(),
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 14,
                                                      ),
                                                    ),
                                                    onEditingComplete: (){
                                                      if (ctrList[index].text.trim().isEmpty) {
                                                        utils.snackBar(
                                                          context: context,
                                                          msg: "Please enter status type",
                                                          color: Colors.red,
                                                        );
                                                        controllers.productCtr.reset();
                                                        return;
                                                      }else if (ctrList[index].text.length>15) {
                                                        utils.snackBar(
                                                          context: context,
                                                          msg: "Status type must be 15 chars only",
                                                          color: Colors.red,
                                                        );
                                                        controllers.productCtr.reset();
                                                        return;
                                                      }else{
                                                        controllers.correctionStatus(context,"update",controllers.hCallStatusList[index]["id"].toString(),ctrList[index].text.trim());
                                                      }
                                                    },
                                                  ),
                                                ):
                                                CustomText(
                                                  text: controllers.hCallStatusList[index]["value"],
                                                  isCopy: false,
                                                  size: 14,
                                                ),
                                                InkWell(
                                                  onTap: (){
                                                    isAdd.value = false;
                                                    editIndex.value=index;
                                                    Future.delayed(const Duration(milliseconds: 100), () {
                                                      focusList[index].requestFocus();
                                                    });
                                                  },
                                                  child: Icon(Icons.edit_outlined,
                                                      size: 18, color: Colors.grey.shade600),
                                                )
                                              ],
                                            ),
                                          );
                                        }),
                                      ),                                      /// ADD STATUS
                                      isAdd.value
                                          ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 38,
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                decoration: customDecoration.baseBackgroundDecoration(
                                                    color: Colors.white,
                                                    borderColor: Colors.blue.shade400,
                                                    radius: 6),
                                                child: TextField(
                                                  controller: addCtr,
                                                  focusNode: addFocus,
                                                  decoration:
                                                  const InputDecoration(border: InputBorder.none),
                                                ),
                                              ),
                                            ),
                                            8.width,
                                            SizedBox(height: 35,
                                              child: CustomLoadingButton(
                                                callback: (){
                                                  if (addCtr.text.trim().isEmpty) {
                                                    utils.snackBar(
                                                      context: context,
                                                      msg: "Please enter status type",
                                                      color: Colors.red,
                                                    );
                                                    controllers.productCtr.reset();
                                                    return;
                                                  }else if (addCtr.text.length>15) {
                                                    utils.snackBar(
                                                      context: context,
                                                      msg: "Status type must be 15 chars only",
                                                      color: Colors.red,
                                                    );
                                                    controllers.productCtr.reset();
                                                    return;
                                                  }else{
                                                    controllers.correctionStatus(context,"add","0",addCtr.text.trim());
                                                  }
                                                }, isLoading: true, backgroundColor: colorsConst.primary,
                                                radius: 5, width: 70,text: "Add",controller: controllers.productCtr,),
                                            )
                                          ],
                                        ),
                                      )
                                          : const SizedBox(),
                                      const SizedBox(height: 10),
                                      /// FOOTER BUTTONS
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE5E7EB),
                                          borderRadius:
                                          BorderRadius.vertical(bottom: Radius.circular(12)),
                                        ),
                                        child: Row(
                                          children: [
                                            OutlinedButton(
                                              onPressed: () {
                                                isAdd.value = true;
                                                editIndex.value=100;
                                                Future.delayed(const Duration(milliseconds: 200), () {
                                                  addFocus.requestFocus();
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                  backgroundColor: Colors.white
                                              ),
                                              child: const CustomText(
                                                text: "+ Add Status",
                                                isCopy: false,
                                              ),
                                            ),
                                            const Spacer(),
                                            SizedBox(height: 35,width: 150,
                                              child: CustomLoadingButton(
                                                callback: (){
                                                  if (ctrList[editIndex.value].text.trim().isEmpty) {
                                                    utils.snackBar(
                                                      context: context,
                                                      msg: "Please enter status type",
                                                      color: Colors.red,
                                                    );
                                                    controllers.leadCtr.reset();
                                                  }else{
                                                    controllers.correctionStatus(context,"update",controllers.hCallStatusList[editIndex.value]["id"].toString(),ctrList[editIndex.value].text.trim());
                                                  }
                                                }, isLoading: true, backgroundColor: colorsConst.primary,
                                                radius: 5, width: 130,text: "Save Changes",controller: controllers.leadCtr,),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                                ),
                              );
                            },
                          );
                          // Get.dialog(
                          //   Dialog(
                          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          //     child: Container(
                          //       width: 300,
                          //       padding: const EdgeInsets.all(16),
                          //       child: Column(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           CustomText(
                          //             text: "Record Status",
                          //             colors: colorsConst.textColor,
                          //             isBold: true,
                          //             size: 18,
                          //             isCopy: true,
                          //           ),
                          //           10.height,
                          //           SizedBox(
                          //             width: 300,
                          //             child: ListView.builder(
                          //               shrinkWrap: true,
                          //               itemCount: controllers.hCallStatusList.length,
                          //               itemBuilder: (context, index) {
                          //                 final item = controllers.hCallStatusList[index];
                          //                 return Row(
                          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                   children: [
                          //                     CustomText(text: item["value"], isCopy: false),
                          //                     TextButton(
                          //                       onPressed:(){
                          //                         controllers.statusController.text=item["value"];
                          //                         Get.dialog(
                          //                           Dialog(
                          //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          //                             child: Container(
                          //                               width: 300,
                          //                               padding: const EdgeInsets.all(16),
                          //                               child: Column(
                          //                                 mainAxisSize: MainAxisSize.min,
                          //                                 children: [
                          //                                   CustomText(
                          //                                     text: "Update Record Status",
                          //                                     colors: colorsConst.textColor,
                          //                                     isBold: true,
                          //                                     size: 18,
                          //                                     isCopy: true,
                          //                                   ),
                          //                                   10.height,
                          //                                   SizedBox(
                          //                                     width: 500,
                          //                                     child: TextField(
                          //                                       controller: controllers.statusController,
                          //                                       style: TextStyle(
                          //                                           fontSize: 15, color: colorsConst.textColor),
                          //                                       decoration: const InputDecoration(
                          //                                         border: UnderlineInputBorder(),
                          //                                       ),
                          //                                     ),
                          //                                   ),
                          //                                   20.height,
                          //                                   Row(
                          //                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //                                     children: [
                          //                                       ElevatedButton(
                          //                                         onPressed: () {
                          //                                           Navigator.of(context).pop();
                          //                                         },
                          //                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          //                                         child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                          //                                       ),
                          //                                       CustomLoadingButton(
                          //                                         callback: (){
                          //                                           if(controllers.statusController.text.trim().isEmpty){
                          //                                             utils.snackBar(context: context, msg: "Please fill status", color: Colors.red);
                          //                                             controllers.productCtr.reset();
                          //                                           }else{
                          //                                             controllers.correctionStatus(context,"update",item["id"].toString());
                          //                                           }
                          //                                         },
                          //                                         height: 35,
                          //                                         isLoading: true,
                          //                                         backgroundColor: colorsConst.primary,
                          //                                         radius: 2,
                          //                                         width: 80,
                          //                                         controller: controllers.productCtr,
                          //                                         isImage: false,
                          //                                         text: "Save",
                          //                                         textColor: Colors.white,
                          //                                       ),
                          //                                     ],
                          //                                   )
                          //                                 ],
                          //                               ),
                          //                             ),
                          //                           ),
                          //                         );
                          //                       },
                          //                       child: SvgPicture.asset(
                          //                         "assets/images/a_edit.svg",
                          //                         width: 16,
                          //                         height: 16,
                          //                       ),
                          //                     ),
                          //                   ],
                          //                 );
                          //               },
                          //             ),
                          //           ),
                          //           20.height,
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //             children: [
                          //               ElevatedButton(
                          //                 onPressed: () {
                          //                   Navigator.of(context).pop();
                          //                 },
                          //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          //                 child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                          //               ),
                          //               ElevatedButton(
                          //                 onPressed: ()  {
                          //                   controllers.statusController.clear();
                          //                   Get.dialog(
                          //                     Dialog(
                          //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          //                       child: Container(
                          //                         width: 300,
                          //                         padding: const EdgeInsets.all(16),
                          //                         child: Column(
                          //                           mainAxisSize: MainAxisSize.min,
                          //                           children: [
                          //                             CustomText(
                          //                               text: "Add Record Status",
                          //                               colors: colorsConst.textColor,
                          //                               isBold: true,
                          //                               size: 18,
                          //                               isCopy: true,
                          //                             ),
                          //                             10.height,
                          //                             SizedBox(
                          //                               width: 500,
                          //                               child: TextField(
                          //                                 controller: controllers.statusController,
                          //                                 style: TextStyle(
                          //                                     fontSize: 15, color: colorsConst.textColor),
                          //                                 decoration: const InputDecoration(
                          //                                   border: UnderlineInputBorder(),
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                             20.height,
                          //                             Row(
                          //                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //                               children: [
                          //                                 ElevatedButton(
                          //                                   onPressed: () {
                          //                                     Navigator.of(context).pop();
                          //                                   },
                          //                                   style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          //                                   child: const Text("Cancel", style: TextStyle(color: Colors.black)),
                          //                                 ),
                          //                                 CustomLoadingButton(
                          //                                   callback: (){
                          //                                     if(controllers.statusController.text.trim().isEmpty){
                          //                                       utils.snackBar(context: context, msg: "Please fill status", color: Colors.red);
                          //                                       controllers.productCtr.reset();
                          //                                     }else{
                          //                                       controllers.correctionStatus(context,"add","0");
                          //                                     }
                          //                                   },
                          //                                   height: 35,
                          //                                   isLoading: true,
                          //                                   backgroundColor: colorsConst.primary,
                          //                                   radius: 2,
                          //                                   width: 80,
                          //                                   controller: controllers.productCtr,
                          //                                   isImage: false,
                          //                                   text: "Add",
                          //                                   textColor: Colors.white,
                          //                                 ),
                          //                               ],
                          //                             )
                          //                           ],
                          //                         ),
                          //                       ),
                          //                     ),
                          //                   );
                          //                 },
                          //                 child: const Text("Add Status"),
                          //               ),
                          //             ],
                          //           )
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // );
                        },
                        child: Container(
                          width:screenWidth/5,
                          decoration: customDecoration.baseBackgroundDecoration(
                            color: Colors.white,borderColor: Colors.grey.shade200,radius: 15,shadowColor: Colors.grey.shade300
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width:35,height:35,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 5
                                        ),
                                        child: Center(child: Image.asset("assets/images/setting2.png"),)),10.width,
                                    CustomText(
                                      text: "3. Call Record Status",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Customize customer engagement status labels used across records and pipelines.",
                                  isCopy: true,textAlign: TextAlign.start,
                                ),5.height,
                                Divider(thickness: 0.2,color: Colors.grey,),5.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("assets/images/setting2.png",width: 15,height: 15,),
                                        5.width,
                                        CustomText(
                                          text: "${controllers.hCallStatusList.length} status types",
                                          isCopy: true,
                                        ),
                                      ],
                                    ),
                                    Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: colorsConst.primary.withOpacity(0.2),radius: 15
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: CustomText(text:"Manage Status >",colors: colorsConst.primary,isCopy: false,),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Divider(color: Colors.grey.shade200,),
                CustomText(text: "\n4. Employee Shifts", isCopy: false,size: 20,isBold: true,),5.height,
                CustomText(text: "Manage working hours and shift schedules for your team.\n", isCopy: false),
                // 10.height,
                // Row(
                //   children: [
                //     CustomText(
                //       text: "Shift",
                //       isCopy: true,
                //       colors: colorsConst.primary,
                //       isBold: true,
                //       size: 15,
                //     ),
                //     10.width,
                //     CircleAvatar(
                //       backgroundColor: colorsConst.primary,
                //       radius: 17,
                //       child: Obx(()=>CustomText(
                //         isCopy: true,
                //         text: settingsController.officeHoursCount.value.toString(),
                //         colors: Colors.white,
                //         size: 13,
                //       ),)
                //     ),
                //   ],
                // ),
                // 5.height,
                // Divider(
                //   thickness: 1.5,
                //   color: colorsConst.secondary,
                // ),
                5.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomSearchTextField(
                      controller: controllers.search,
                      hintText: "Search Employee Name, Shift Name",
                      onChanged: (value) {
                        settingsController.searchOfficeText.value = value.toString().trim();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if(settingsController.selectedOfficeIds.isNotEmpty)
                        Row(
                          children: [
                            CustomText(text: "Selected Count : ${settingsController.selectedOfficeIds.length.toString()}", isCopy: false),5.width,
                            InkWell(
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: (){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: CustomText(
                                        text: "Are you sure delete this Office Hours?",
                                        size: 16,
                                        isCopy: true,
                                        isBold: true,
                                        colors: colorsConst.textColor,
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: colorsConst.primary),
                                                  color: Colors.white),
                                              width: 80,
                                              height: 25,
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.zero,
                                                    ),
                                                    backgroundColor: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: CustomText(
                                                    text: "Cancel",
                                                    colors: colorsConst.primary,
                                                    isCopy: false,
                                                    size: 14,
                                                  )),
                                            ),
                                            10.width,
                                            CustomLoadingButton(
                                              callback: ()async{
                                                settingsController.deleteOfficeHoursAPI(context);
                                              },
                                              height: 35,
                                              isLoading: true,
                                              backgroundColor: colorsConst.primary,
                                              radius: 2,
                                              width: 80,
                                              controller: controllers.productCtr,
                                              isImage: false,
                                              text: "Delete",
                                              textColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: colorsConst.secondary,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/action_delete.png"),
                                    10.width,
                                    CustomText(
                                      text: "Delete",
                                      colors: colorsConst.textColor,
                                      size: 14,
                                      isCopy: false,
                                      isBold: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),20.width,
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                              onPressed: (){
                                // Navigator.push(
                                //   context,
                                //   PageRouteBuilder(
                                //     pageBuilder: (context, animation1, animation2) =>
                                //     const AddOfficeHours(),
                                //     transitionDuration: Duration.zero,
                                //     reverseTransitionDuration: Duration.zero,
                                //   ),
                                // );
                                settingsController.time1.clear();
                                settingsController.time2.clear();

                                settingsController.shiftController.clear();
                                settingsController.daysController.clear();
                                var errMsg="".obs;
                                var errMsg2="".obs;
                                var errMsg3="".obs;
                                var errMsg4="".obs;
                                var errMsg5="".obs;
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      titlePadding: EdgeInsets.zero,
                                      contentPadding: EdgeInsets.zero,
                                      content: SizedBox(
                                        width: 420,
                                        child: Obx(()=>Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [

                                            /// HEADER
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFE5E7EB),
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                              ),
                                              child: Row(
                                                children: [

                                                  /// ICON
                                                  Container(
                                                    width: 34,
                                                    height: 34,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Icon(Icons.report_gmailerrorred_sharp, color: Colors.white,size:18),
                                                  ),

                                                  10.width,

                                                  /// TITLE
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomText(
                                                        text: "Add New Shift",
                                                        isCopy: false,
                                                        isBold: true,
                                                        size: 15,
                                                      ),
                                                      CustomText(
                                                        text: "Configure shift details for an employee",
                                                        isCopy: false,
                                                        size: 12,
                                                        colors: Colors.grey,
                                                      ),
                                                    ],
                                                  ),

                                                  const Spacer(),

                                                  /// CLOSE
                                                  InkWell(
                                                    onTap: (){
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      width: 26,
                                                      height: 26,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.grey.shade400),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: const Icon(Icons.clear,size:14),
                                                    ),
                                                  )

                                                ],
                                              ),
                                            ),

                                            /// BODY
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                children: [

                                                  /// STEPS
                                                  Container(
                                                    height: 35,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        color: Colors.grey.shade200,radius: 5,borderColor: Colors.grey.shade300
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          stepWidget("1","Employee",
                                                              controllers.selectedEmployeeId.value==""?Colors.grey.shade300:Colors.green,
                                                              controllers.selectedEmployeeId.value==""?Colors.grey:Colors.white
                                                          ),
                                                          Container(
                                                            height: 1,width: 50,color: Colors.grey.shade300,
                                                          ),
                                                          stepWidget("2","Schedule",
                                                              settingsController.time1.text.isEmpty&&settingsController.time1.text.isEmpty?Colors.grey.shade300:Colors.green,
                                                              settingsController.time1.text.isEmpty&&settingsController.time1.text.isEmpty?Colors.grey:Colors.white),
                                                          Container(
                                                            height: 1,width: 50,color: Colors.grey.shade300,
                                                          ),
                                                          stepWidget("3","Days",
                                                              settingsController.shiftController.text.isEmpty&&settingsController.daysController.text.isEmpty?Colors.grey.shade300:Colors.green,
                                                              settingsController.shiftController.text.isEmpty&&settingsController.daysController.text.isEmpty?Colors.grey:Colors.white),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height:20),

                                                  /// EMPLOYEE DROPDOWN
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.person_outline_outlined,color: Colors.grey,size: 15,),
                                                          6.width,
                                                          CustomText(
                                                            text: "Employee Name",
                                                            isCopy: false,
                                                            size: 13,
                                                          ),
                                                          CustomText(
                                                              text: "*",
                                                              isCopy: false,
                                                              size: 20,colors: Colors.red
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height:6),

                                                      KeyboardDropdownField<AllEmployeesObj>(
                                                        items: controllers.employees,
                                                        borderRadius: 5,
                                                        borderColor: Colors.grey.shade300,
                                                        hintText: "Select Employees",
                                                        labelText: "",
                                                        labelBuilder: (customer) =>
                                                        '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                                        itemBuilder: (customer) {
                                                          return Container(
                                                            width: 300,
                                                            alignment: Alignment.topLeft,
                                                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                            child: CustomText(
                                                              text:
                                                              '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                                              colors: Colors.black,
                                                              size: 14,
                                                              isCopy: false,
                                                              textAlign: TextAlign.start,
                                                            ),
                                                          );
                                                        },
                                                        textEditingController:
                                                        controllers.empController,
                                                        onSelected: (value) {
                                                          controllers.selectEmployee(value);
                                                        },
                                                        onClear: () {
                                                          controllers.clearSelectedCustomer();
                                                        },
                                                      ),
                                                      CustomText(text: errMsg.value, isCopy: false,colors: Colors.red,)
                                                    ],
                                                  ),
                                                  10.height,
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      ShiftCustomTextField(
                                                        readOnly: true,
                                                        onTap: () => settingsController.pickTime(context, true),
                                                        iconData: Icons.access_time_sharp,
                                                        // focusNode: passwordFocus2,
                                                        controller: settingsController.time1,
                                                        text: 'From',
                                                        hintText: settingsController.formatTime(settingsController.fromTime.value),
                                                        errorText: errMsg2.value,
                                                        width: 170,
                                                        validator: (value){
                                                          if(value.toString().isEmpty){
                                                            errMsg2.value="Start Time is Required";
                                                            return "Start Time is Required";
                                                          }else{
                                                            errMsg2.value="";
                                                            return null;
                                                          }
                                                        },
                                                      ),
                                                      ShiftCustomTextField(
                                                        readOnly: true,
                                                        onTap: () => settingsController.pickTime(context, false),
                                                        iconData: Icons.access_time_sharp,
                                                        // focusNode: passwordFocus2,
                                                        controller: settingsController.time2,
                                                        text: 'To',
                                                        hintText: settingsController.formatTime(settingsController.toTime.value),
                                                        errorText: errMsg3.value,
                                                        width: 170,
                                                        validator: (value){
                                                          if(value.toString().isEmpty){
                                                            errMsg3.value="End Time is Required";
                                                            return "End Time is Required";
                                                          }else{
                                                            errMsg3.value="";
                                                            return null;
                                                          }
                                                        },
                                                      ),

                                                    ],
                                                  ),
                                                  10.height,
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      ShiftCustomTextField(
                                                        iconData: Icons.calendar_today_outlined,
                                                        // focusNode: passwordFocus2,
                                                        controller: settingsController.shiftController,
                                                        text: 'Shift Name',
                                                        hintText: 'Shift Name',
                                                        width: 170,
                                                        errorText: errMsg4.value,
                                                        validator: (value){
                                                          if(value.toString().isEmpty){
                                                            errMsg4.value="Shift Name is Required";
                                                            return "Shift Name is Required";
                                                          }else{
                                                            errMsg4.value="";
                                                            return null;
                                                          }
                                                        },
                                                        textInputAction: TextInputAction.next,
                                                        inputFormatters: constInputFormatters.textInput,
                                                        keyboardType: TextInputType.number,
                                                      ),
                                                      ShiftCustomTextField(
                                                        iconData: Icons.calendar_today_outlined,
                                                        // focusNode: passwordFocus2,
                                                        controller: settingsController.daysController,
                                                        text: 'Working days',
                                                        hintText: 'Working days',
                                                        errorText: errMsg5.value,
                                                        width: 170,
                                                        validator: (value){
                                                          if(value.toString().isEmpty){
                                                            errMsg5.value="Working Days is Required";
                                                            return "Working days";
                                                          }else{
                                                            errMsg5.value="";
                                                            return null;
                                                          }
                                                        },
                                                        textInputAction: TextInputAction.done,
                                                        inputFormatters: constInputFormatters.numberInput,
                                                        keyboardType: TextInputType.number,
                                                      ),

                                                    ],
                                                  ),
                                                  10.height,

                                                ],
                                              ),
                                            ),

                                            /// FOOTER
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal:16,vertical:12),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFE5E7EB),
                                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                        backgroundColor: Colors.white
                                                    ),
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                    },
                                                    child: const CustomText(text:"Cancel",isCopy: false,colors: Colors.grey,),
                                                  ),10.width,
                                                  CustomLoadingButton(
                                                    callback: () async {
                                                      errMsg.value="";
                                                      errMsg2.value="";
                                                      errMsg3.value="";
                                                      errMsg4.value="";
                                                      errMsg5.value="";
                                                      if(controllers.selectedEmployeeId.value.isEmpty){
                                                        controllers.productCtr.reset();
                                                        errMsg.value="Please select any employee";
                                                      }else if(settingsController.time1.text.isEmpty) {
                                                        controllers.productCtr.reset();
                                                        errMsg2.value="Start Time is Required";
                                                      }else if(settingsController.time2.text.isEmpty){
                                                        controllers.productCtr.reset();
                                                        errMsg3.value="End Time is Required";
                                                      }else if(settingsController.shiftController.text.isEmpty) {
                                                        controllers.productCtr.reset();
                                                        errMsg4.value="Shift Name is Required";
                                                      }else if(settingsController.daysController.text.isEmpty){
                                                        controllers.productCtr.reset();
                                                        errMsg5.value="Working Days is Required";
                                                      }else{
                                                        await settingsController.insertOfficeHourAPI(context);
                                                      }
                                                    }, 
                                                    height: 40,
                                                    isLoading: true,
                                                    backgroundColor: colorsConst.primary,
                                                    radius: 7,
                                                    width: 120,
                                                    controller: controllers.productCtr,
                                                    isImage: false,
                                                    text: "Add Shift",
                                                    textColor: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            )

                                          ],
                                        )),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.add,color: Colors.white,),10.width,
                                  CustomText(text: "Add Shift", isCopy: false)
                                ],
                              )),
                        )
                      ],
                    ),
                  ],
                ),
                10.height,
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1.5),//Actions
                    2: FlexColumnWidth(2),//Employee
                    3: FlexColumnWidth(3),//Shift Name
                    4: FlexColumnWidth(2),//From
                    5: FlexColumnWidth(2),//To
                    6: FlexColumnWidth(2),//days
                    7: FlexColumnWidth(2),//Updated On
                  },
                  border: TableBorder(
                    horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                    verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                  ),
                  children: [
                    TableRow(
                        decoration: BoxDecoration(
                            color: colorsConst.primary,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5))),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child:  Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              side: WidgetStateBorderSide.resolveWith(
                                    (states) => const BorderSide(width: 1.0, color: Colors.white),
                              ),
                              value: settingsController.selectedOfficeIds.length == settingsController.officeHoursList.length && settingsController.officeHoursList.isNotEmpty,
                              onChanged: (value) {
                                settingsController.toggleSelectAllOffices();
                              },
                              activeColor: Colors.white,
                              checkColor: colorsConst.primary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Actions",//0
                              size: 15,
                              isCopy: true,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Employee",//1
                                  size: 15,
                                  isCopy: true,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(settingsController.sortOfficeHourField.value=='name' && settingsController.sortOfficeHourOrder.value=='asc'){
                                      settingsController.sortOfficeHourOrder.value='desc';
                                    }else{
                                      settingsController.sortOfficeHourOrder.value='asc';
                                    }
                                    settingsController.sortOfficeHourField.value='name';
                                    settingsController.sortOfficeHour();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortOfficeHourField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortOfficeHourOrder.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Shift Name",//2
                                  size: 15,
                                  isCopy: true,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(settingsController.sortOfficeHourField.value=='shift' && settingsController.sortOfficeHourOrder.value=='asc'){
                                      settingsController.sortOfficeHourOrder.value='desc';
                                    }else{
                                      settingsController.sortOfficeHourOrder.value='asc';
                                    }
                                    settingsController.sortOfficeHourField.value='shift';
                                    settingsController.sortOfficeHour();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortOfficeHourField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortOfficeHourOrder.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "From",//3
                                  size: 15,
                                  isBold: true,
                                  isCopy: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(settingsController.sortOfficeHourField.value=='from' && settingsController.sortOfficeHourOrder.value=='asc'){
                                      settingsController.sortOfficeHourOrder.value='desc';
                                    }else{
                                      settingsController.sortOfficeHourOrder.value='asc';
                                    }
                                    settingsController.sortOfficeHourField.value='from';
                                    settingsController.sortOfficeHour();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortOfficeHourField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortOfficeHourOrder.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "To",//4
                                  size: 15,
                                  isBold: true,
                                  isCopy: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(settingsController.sortOfficeHourField.value=='to' && settingsController.sortOfficeHourOrder.value=='asc'){
                                      settingsController.sortOfficeHourOrder.value='desc';
                                    }else{
                                      settingsController.sortOfficeHourOrder.value='asc';
                                    }
                                    settingsController.sortOfficeHourField.value='to';
                                    settingsController.sortOfficeHour();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortOfficeHourField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortOfficeHourOrder.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Days",//4
                                  size: 15,
                                  isBold: true,
                                  isCopy: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(settingsController.sortOfficeHourField.value=='days' && settingsController.sortOfficeHourOrder.value=='asc'){
                                      settingsController.sortOfficeHourOrder.value='desc';
                                    }else{
                                      settingsController.sortOfficeHourOrder.value='asc';
                                    }
                                    settingsController.sortOfficeHourField.value='days';
                                    settingsController.sortOfficeHour();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortOfficeHourField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortOfficeHourOrder.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Updated On",//4
                                  size: 15,
                                  isBold: true,
                                  isCopy: true,
                                  colors: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                GestureDetector(
                                  onTap: (){
                                    if(settingsController.sortOfficeHourField.value=='date' && settingsController.sortOfficeHourOrder.value=='asc'){
                                      settingsController.sortOfficeHourOrder.value='desc';
                                    }else{
                                      settingsController.sortOfficeHourOrder.value='asc';
                                    }
                                    settingsController.sortOfficeHourField.value='date';
                                    settingsController.sortOfficeHour();
                                  },
                                  child: Obx(() => Image.asset(
                                    settingsController.sortOfficeHourField.value.isEmpty
                                        ? "assets/images/arrow.png"
                                        : settingsController.sortOfficeHourOrder.value == 'asc'
                                        ? "assets/images/arrow_up.png"
                                        : "assets/images/arrow_down.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ],
                ),
                Expanded(
                  child: Obx(() {
                    final searchText = settingsController.searchOfficeText.value.toLowerCase();
                    final filteredList = settingsController.officeHoursList.where((activity) {
                      final matchesSearch = searchText.isEmpty ||
                          (activity.shiftName.toString().toLowerCase().contains(searchText)) ||
                          (activity.employeeName.toString().toLowerCase().contains(searchText));
                      return matchesSearch;
                    }).toList();
                    if (settingsController.isLoadingOfficeHours.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (filteredList.isEmpty) {
                      return const Center(child: Text("No shifts found"));
                    }
                    return ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final officeHour = filteredList[index];
                        return Table(
                          columnWidths:const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1.5),//Actions
                            2: FlexColumnWidth(2),//Employee
                            3: FlexColumnWidth(3),//Shift Name
                            4: FlexColumnWidth(2),//From
                            5: FlexColumnWidth(2),//To
                            6: FlexColumnWidth(2),//days
                            7: FlexColumnWidth(2),//Updated On
                          },
                          border: TableBorder(
                            horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                            verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                            bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                          ),
                          children:[
                            TableRow(
                                decoration: BoxDecoration(
                                  color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                ),
                                children:[
                                  Checkbox(
                                    value: settingsController.isCheckedOffice(officeHour.id),
                                    onChanged: (value) {
                                      setState(() {
                                        settingsController.toggleOfficeSelection(officeHour.id);
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                            onPressed: (){
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    content: CustomText(
                                                      text: "Are you sure delete this office hours?",
                                                      size: 16,
                                                      isBold: true,
                                                      isCopy: true,
                                                      colors: colorsConst.textColor,
                                                    ),                                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(color: colorsConst.primary),
                                                              color: Colors.white),
                                                          width: 80,
                                                          height: 25,
                                                          child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.zero,
                                                                ),
                                                                backgroundColor: Colors.white,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: CustomText(
                                                                text: "Cancel",
                                                                isCopy: false,
                                                                colors: colorsConst.primary,
                                                                size: 14,
                                                              )),
                                                        ),
                                                        10.width,
                                                        CustomLoadingButton(
                                                          callback: ()async{
                                                            settingsController.selectedOfficeIds.add(officeHour.id.toString());
                                                            settingsController.deleteOfficeHoursAPI(context);
                                                          },
                                                          height: 35,
                                                          isLoading: true,
                                                          backgroundColor: colorsConst.primary,
                                                          radius: 2,
                                                          width: 80,
                                                          controller: controllers.productCtr,
                                                          isImage: false,
                                                          text: "Delete",
                                                          textColor: Colors.white,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: SvgPicture.asset(
                                              "assets/images/a_delete.svg",
                                              width: 16,
                                              height: 16,
                                            ))
                                      ],
                                    ),
                                  ),
                                  Tooltip(
                                    message: officeHour.employeeName,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomText(
                                        textAlign: TextAlign.left,
                                        text:officeHour.employeeName,//1
                                        size: 14,
                                        isCopy: true,
                                        colors:colorsConst.textColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      textAlign: TextAlign.left,
                                      text: officeHour.shiftName,//2
                                      size: 14,
                                      isCopy: true,
                                      colors:colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      isCopy: true,
                                      textAlign: TextAlign.left,
                                      text:officeHour.fromTime,
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      isCopy: true,
                                      textAlign: TextAlign.left,
                                      text:officeHour.toTime,
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      isCopy: true,
                                      textAlign: TextAlign.left,
                                      text:officeHour.days,
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CustomText(
                                      isCopy: true,
                                      textAlign: TextAlign.left,
                                      text:controllers.formatDateTime(officeHour.updatedTs),
                                      size: 14,
                                      colors: colorsConst.textColor,
                                    ),
                                  ),
                                ]
                            ),
                          ],
                        );
                      },
                    );
                  }),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
  Widget stepWidget(String number,String title,Color bg,Color textClr){
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: bg,
          child: CustomText(text:number,size: 10,isCopy: false,colors: textClr,),
        ),
        const SizedBox(width:6),
        CustomText(text:title,size: 12, isCopy: false,colors: Colors.grey)
      ],
    );
  }

}
