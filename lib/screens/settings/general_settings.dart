import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/screens/settings/add_office_hours.dart';
import 'package:get/get.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';
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
    apiService.getAllEmployees();
    controllers.selectedSortBy.value = controllers.storage.read("selectedSortBy") ?? "All";
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
                                      text: "Lead Categories",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Manage the order and structure of categories used",
                                  isCopy: true,
                                ),5.height,
                                CustomText(
                                  text: "across the dashboard views.",
                                  isCopy: true,
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
                                      text: "Default Date Range",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Choose the default time filter applied to",
                                  isCopy: true,
                                ),5.height,
                                CustomText(
                                  text: "dashboard records and analytics views.",
                                  isCopy: true,
                                ),5.height,
                                Divider(thickness: 0.2,color: Colors.grey,),5.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset("assets/images/setting3.png",width: 15,height: 15,),5.width,
                                        Obx(()=>CustomText(
                                          text: controllers.selectedSortBy.value,
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

                          List<FocusNode> focusList =
                          List.generate(controllers.statusList.length, (index) => FocusNode());

                          List<TextEditingController> ctrList =
                          List.generate(controllers.statusList.length, (index) =>
                              TextEditingController(text: controllers.statusList[index]));
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Color(0xFFF1F5F9),
                                titlePadding: EdgeInsets.zero,
                                contentPadding: EdgeInsets.zero,
                                content: SizedBox(
                                  width: 420,
                                  child: Column(
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
                                                    text: "Record Status",
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
                                        children: List.generate(controllers.statusList.length, (index) {
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
                                                    focusNode: focusList[editIndex.value],
                                                    controller: ctrList[editIndex.value],
                                                    decoration: InputDecoration(
                                                      border: UnderlineInputBorder(),
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 14,
                                                      ),
                                                    ),
                                                    onEditingComplete: (){
                                                      if (controllers.emailMessageCtr.text.trim().isEmpty) {
                                                        utils.snackBar(
                                                          context: context,
                                                          msg: "Please enter lead category",
                                                          color: Colors.red,
                                                        );
                                                        controllers.productCtr.reset();
                                                        return;
                                                      }else{
                                                        // addCategories(context,"update",data.id,index);
                                                      }
                                                    },
                                                  ),
                                                ):
                                                CustomText(
                                                  text: controllers.statusList[index],
                                                  isCopy: false,
                                                  size: 14,
                                                ),
                                                InkWell(
                                                  onTap: (){
                                                    editIndex.value=index;
                                                    FocusScope.of(context).requestFocus(focusList[index]);
                                                  },
                                                  child: Icon(Icons.edit_outlined,
                                                      size: 18, color: Colors.grey.shade600),
                                                )
                                              ],
                                            ),
                                          );
                                        }),
                                      ),

                                      /// ADD STATUS
                                      Obx(() => isAdd.value
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
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorsConst.primary),
                                              onPressed: () {

                                                if (addCtr.text.trim().isEmpty) return;

                                                /// add new status
                                                controllers.statusList.add(addCtr.text);

                                                /// create new controller & focus
                                                ctrList.add(TextEditingController(text: addCtr.text));
                                                focusList.add(FocusNode());

                                                addCtr.clear();
                                              },
                                              child: const CustomText(
                                                text: "Add",
                                                isCopy: false,
                                                colors: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                          : const SizedBox()),

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
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: colorsConst.primary),
                                              onPressed: () {},
                                              child: const CustomText(
                                                text: "Save Changes",
                                                isCopy: false,
                                                colors: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
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
                                      text: "Record Status",
                                      colors: colorsConst.textColor,size: 20,
                                      isBold: true,
                                      isCopy: true,
                                    ),
                                  ],
                                ),10.height,
                                CustomText(
                                  text: "Customize customer engagement status labels",
                                  isCopy: true,
                                ),5.height,
                                CustomText(
                                  text: "used across records and pipelines.",
                                  isCopy: true,
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
                CustomText(text: "\nEmployee Shifts", isCopy: false,size: 20,isBold: true,),5.height,
                CustomText(text: "Manage working hours and shift schedules for your team.\n", isCopy: false,colors: Colors.grey,),
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
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation1, animation2) =>
                                    const AddOfficeHours(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
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
}
