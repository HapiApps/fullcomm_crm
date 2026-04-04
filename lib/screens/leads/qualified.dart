// import 'package:flutter/services.dart';
// import 'package:fullcomm_crm/common/constant/colors_constant.dart';
// import 'package:fullcomm_crm/common/extentions/extensions.dart';
// import 'package:fullcomm_crm/components/custom_no_data.dart';
// import 'package:fullcomm_crm/components/customer_name_tile.dart';
// import 'package:fullcomm_crm/services/api_services.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../common/utilities/mail_utils.dart';
// import '../../components/custom_filter_seaction.dart';
// import '../../components/custom_header_seaction.dart';
// import '../../components/custom_lead_tile.dart';
// import '../../components/custom_loading_button.dart';
// import '../../components/custom_sidebar.dart';
// import '../../components/dynamic_table_header.dart';
// import '../../components/custom_text.dart';
// import '../../components/customer_name_header.dart';
// import '../../controller/controller.dart';
//
// class Qualified extends StatefulWidget {
//   const Qualified({super.key});
//
//   @override
//   State<Qualified> createState() => _QualifiedState();
// }
//
// class _QualifiedState extends State<Qualified> {
//   final ScrollController _controller = ScrollController();
//   final ScrollController _horizontalController = ScrollController();
//   final ScrollController _leftController = ScrollController();
//   final ScrollController _rightController = ScrollController();
//   late FocusNode _focusNode;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _focusNode = FocusNode();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//     Future.delayed(Duration.zero, () {
//       apiService.currentVersion();
//       controllers.selectedIndex.value = 3;
//       controllers.groupController.selectIndex(0);
//       setState(() {
//         controllers.search.clear();
//         apiService.customerList = [];
//         apiService.customerList.clear();
//         //Santhiya
//         controllers.isAllSelected.value = false;
//         final ids = controllers.isGoodLeadList.map((e) => e["lead_id"]).toSet();
//
//         controllers.isGoodLeadList.forEach((e) => e["isSelect"] = false);
//
//         apiService.customerList.removeWhere(
//               (e) => ids.contains(e["lead_id"]),
//         );
//       });
//     });
//     _leftController.addListener(() {
//       if (_rightController.hasClients &&
//           (_rightController.offset != _leftController.offset)) {
//         _rightController.jumpTo(_leftController.offset);
//       }
//     });
//     _rightController.addListener(() {
//       if (_leftController.hasClients &&
//           (_leftController.offset != _rightController.offset)) {
//         _leftController.jumpTo(_rightController.offset);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _horizontalController.dispose();
//     _leftController.dispose();
//     _rightController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     double tableWidth;
//     if (screenWidth >= 1600) {
//       tableWidth = 4000;
//     } else if (screenWidth >= 1200) {
//       tableWidth = 3000;
//     } else if (screenWidth >= 900) {
//       tableWidth = 2400;
//     } else {
//       tableWidth = 2000;
//     }
//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) {
//           controllers.selectedIndex.value = controllers.oldIndex.value;
//         }
//       },
//       child: SelectionArea(
//         child: Scaffold(
//           body: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SideBar(),
//               Obx(()=>Container(
//                 width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
//                 height: MediaQuery.of(context).size.height,
//                 alignment: Alignment.center,
//                 padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header Section
//                     HeaderSection(
//                       title: "Good Leads - ${controllers.leadCategoryList[2]["value"]}",
//                       subtitle: "View all of your ${controllers.leadCategoryList[2]["value"]} Information",
//                       list: controllers.allQualifiedLeadFuture,
//                     ),
//                     20.height,
//                     // Filter Section
//                     FilterSection(
//                       //Santhiya
//                       leadIndex: "0",
//                       itemCount: controllers.paginatedQualifiedLeads.length,
//                       focusNode: _focusNode,
//                       leadFuture: controllers.allQualifiedLeadFuture,
//                       title: "Qualified",
//                       count: controllers.allGoodLeadsLength.value,
//                       itemList: apiService.customerList,
//                       onDelete: () {
//                         _focusNode.requestFocus();
//                         showDialog(
//                             context: context,
//                             barrierDismissible: false,
//                             builder: (context) {
//                               return AlertDialog(
//                                 content: CustomText(
//                                   text: "Are you sure delete this customers?",
//                                   size: 16,
//                                   isCopy: false,
//                                   isBold: true,
//                                   colors: colorsConst.textColor,
//                                 ),
//                                 actions: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Container(
//                                         decoration: BoxDecoration(
//                                             border: Border.all(color: colorsConst.primary),
//                                             color: Colors.white),
//                                         width: 80,
//                                         height: 25,
//                                         child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               shape: const RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.zero,
//                                               ),
//                                               backgroundColor: Colors.white,
//                                             ),
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             child: CustomText(
//                                               text: "Cancel",
//                                               isCopy: false,
//                                               colors: colorsConst.primary,
//                                               size: 14,
//                                             )),
//                                       ),
//                                       10.width,
//                                       CustomLoadingButton(
//                                         callback: ()async{
//                                           _focusNode.requestFocus();
//                                           await apiService.deleteCustomersAPI(context, apiService.customerList);
//                                           setState(() {
//                                             apiService.customerList.clear();
//                                           });
//                                         },
//                                         height: 35,
//                                         isLoading: true,
//                                         backgroundColor: colorsConst.primary,
//                                         radius: 2,
//                                         width: 80,
//                                         controller: controllers.productCtr,
//                                         isImage: false,
//                                         text: "Delete",
//                                         textColor: Colors.white,
//                                       ),
//                                       5.width
//                                     ],
//                                   ),
//                                 ],
//                               );
//                             });
//                       },
//                       onMail: () {
//                         mailUtils.bulkEmailDialog(_focusNode, list: apiService.customerList);
//                       },
//                       onPromote: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             String selectedStage="Customers";
//                             bool isEdit=false;
//                             TextEditingController reasonController = TextEditingController();
//                             setState(() {
//                                selectedStage = "Customers";
//                             });
//                             return StatefulBuilder(
//                               builder: (context, setState) {
//                                 return AlertDialog(
//                                   title: CustomText(
//                                     text: "Move to Next Level",
//                                     size: 18,
//                                     isBold: true,
//                                     isCopy: false,
//                                     colors: colorsConst.textColor,
//                                   ),
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       CustomText(
//                                         text: "Select Stage",
//                                         size: 14,
//                                         isBold: true,
//                                         isCopy: false,
//                                       ),
//                                       8.height,
//                                       Container(
//                                         padding: EdgeInsets.symmetric(horizontal: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: colorsConst.primary),
//                                           borderRadius: BorderRadius.circular(4),
//                                         ),
//                                         child: DropdownButton<String>(
//                                           value: selectedStage,
//                                           isExpanded: true,
//                                           focusColor: Colors.transparent,
//                                           underline: SizedBox(),
//                                           items: [
//                                             "Suspects",
//                                             "Prospects",
//                                             "Customers",
//                                           ].map((value) {
//                                             return DropdownMenuItem(
//                                               value: value,
//                                               child: Text(value),
//                                             );
//                                           }).toList(),
//                                           onChanged: (value) {
//                                             setState(() {
//                                               selectedStage = value!;
//                                               isEdit=true;
//                                             });
//                                           },
//                                         ),
//                                       ),
//                                       15.height,
//                                       TextField(
//                                         controller: reasonController,
//                                         decoration: InputDecoration(
//                                           labelText: "Reason",
//                                           border: OutlineInputBorder(),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   actions: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         Container(
//                                           decoration: BoxDecoration(
//                                               border: Border.all(color: colorsConst.primary),
//                                               color: Colors.white),
//                                           width: 80,
//                                           height: 25,
//                                           child: ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                 shape: const RoundedRectangleBorder(
//                                                   borderRadius: BorderRadius.zero,
//                                                 ),
//                                                 backgroundColor: Colors.white,
//                                               ),
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                               },
//                                               child: CustomText(
//                                                 text: "Cancel",
//                                                 isCopy: false,
//                                                 colors: colorsConst.primary,
//                                                 size: 14,
//                                               )),
//                                         ),
//                                         10.width,
//                                         CustomLoadingButton(
//                                           callback: () async {
//                                             if (selectedStage == "Suspects") {
//                                               await apiService.insertLeadPromoteAPI(context, apiService.customerList);
//                                             }else if (selectedStage == "Prospects") {
//                                               await apiService.insertProspectsAPI(context, apiService.customerList);
//                                             }else if (selectedStage == "Customers") {
//                                               await apiService.insertPromoteCustomerAPI(context, apiService.customerList);
//                                             }
//                                             // else {
//                                             //   await apiService.insertProspectsAPI(context, [deleteData]);
//                                             // }
//                                             setState(() {
//                                               apiService.customerList.clear();
//                                             });
//                                           },
//                                           height: 35,
//                                           isLoading: true,
//                                           backgroundColor:
//                                           colorsConst.primary,
//                                           radius: 2,
//                                           width: 80,
//                                           controller:
//                                           controllers.productCtr,
//                                           isImage: false,
//                                           text: "Promote",
//                                           textColor: Colors.white,
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                         );
//                         // showDialog(
//                         //     context: context,
//                         //     barrierDismissible: false,
//                         //     builder: (context) {
//                         //       return AlertDialog(
//                         //         content: CustomText(
//                         //           text: "Are you moving to the next level?",
//                         //           size: 16,
//                         //           isCopy: false,
//                         //           isBold: true,
//                         //           colors: colorsConst.textColor,
//                         //         ),
//                         //         actions: [
//                         //           Row(
//                         //             mainAxisAlignment: MainAxisAlignment.end,
//                         //             children: [
//                         //               Container(
//                         //                 decoration: BoxDecoration(
//                         //                     border: Border.all(color: colorsConst.primary),
//                         //                     color: Colors.white),
//                         //                 width: 80,
//                         //                 height: 25,
//                         //                 child: ElevatedButton(
//                         //                     style: ElevatedButton.styleFrom(
//                         //                       shape: const RoundedRectangleBorder(
//                         //                         borderRadius: BorderRadius.zero,
//                         //                       ),
//                         //                       backgroundColor: Colors.white,
//                         //                     ),
//                         //                     onPressed: () {
//                         //                       Navigator.pop(context);
//                         //                     },
//                         //                     child: CustomText(
//                         //                       text: "Cancel",
//                         //                       isCopy: false,
//                         //                       colors: colorsConst.primary,
//                         //                       size: 14,
//                         //                     )),
//                         //               ),
//                         //               10.width,
//                         //               CustomLoadingButton(
//                         //                 callback: ()async{
//                         //                   _focusNode.requestFocus();
//                         //                   await apiService.insertPromoteCustomerAPI(context,apiService.customerList);
//                         //                   setState(() {
//                         //                     apiService.customerList.clear();
//                         //                   });
//                         //                 },
//                         //                 height: 35,
//                         //                 isLoading: true,
//                         //                 backgroundColor: colorsConst.primary,
//                         //                 radius: 2,
//                         //                 width: 80,
//                         //                 controller: controllers.productCtr,
//                         //                 isImage: false,
//                         //                 text: "Move",
//                         //                 textColor: Colors.white,
//                         //               ),
//                         //               5.width
//                         //             ],
//                         //           ),
//                         //         ],
//                         //       );
//                         //     });
//                       },
//                       onDemote: () {
//                         // showDialog(
//                         //     context: context,
//                         //     barrierDismissible: true,
//                         //     builder: (context) {
//                         //       return AlertDialog(
//                         //         content: CustomText(
//                         //           text: "Are you sure demote this customers?",
//                         //           size: 16,
//                         //           isCopy: false,
//                         //           isBold: true,
//                         //           colors: colorsConst.textColor,
//                         //         ),
//                         //         actions: [
//                         //           Row(
//                         //             mainAxisAlignment: MainAxisAlignment.end,
//                         //             children: [
//                         //               Container(
//                         //                 decoration: BoxDecoration(
//                         //                     border: Border.all(color: colorsConst.primary),
//                         //                     color: Colors.white),
//                         //                 width: 80,
//                         //                 height: 25,
//                         //                 child: ElevatedButton(
//                         //                     style: ElevatedButton.styleFrom(
//                         //                       shape: const RoundedRectangleBorder(
//                         //                         borderRadius: BorderRadius.zero,
//                         //                       ),
//                         //                       backgroundColor: Colors.white,
//                         //                     ),
//                         //                     onPressed: () {
//                         //                       Navigator.pop(context);
//                         //                     },
//                         //                     child: CustomText(
//                         //                       text: "Cancel",
//                         //                       isCopy: false,
//                         //                       colors: colorsConst.primary,
//                         //                       size: 14,
//                         //                     )),
//                         //               ),
//                         //               10.width,
//                         //               CustomLoadingButton(
//                         //                 callback: (){
//                         //                   _focusNode.requestFocus();
//                         //                   apiService.insertProspectsAPI(
//                         //                       context, apiService.customerList);
//                         //                 },
//                         //                 height: 35,
//                         //                 isLoading: true,
//                         //                 backgroundColor:
//                         //                 colorsConst.primary,
//                         //                 radius: 2,
//                         //                 width: 100,
//                         //                 controller: controllers.productCtr,
//                         //                 isImage: false,
//                         //                 text: "Demote",
//                         //                 textColor:Colors.white,
//                         //               ),
//                         //               5.width
//                         //             ],
//                         //           ),
//                         //         ],
//                         //       );
//                         //     });
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             String selectedStage="Prospects";
//                             bool isEdit=false;
//                             TextEditingController reasonController = TextEditingController();
//                             // setState(() {
//                             //   selectedStage = "Prospects";
//                             // });
//                             return StatefulBuilder(
//                               builder: (context, setState) {
//                                 return AlertDialog(
//                                   title: CustomText(
//                                     text: "Move to Next Level",
//                                     size: 18,
//                                     isBold: true,
//                                     isCopy: false,
//                                     colors: colorsConst.textColor,
//                                   ),
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       CustomText(
//                                         text: "Select Stage",
//                                         size: 14,
//                                         isBold: true,
//                                         isCopy: false,
//                                       ),
//                                       8.height,
//                                       Container(
//                                         padding: EdgeInsets.symmetric(horizontal: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: colorsConst.primary),
//                                           borderRadius: BorderRadius.circular(4),
//                                         ),
//                                         child: DropdownButton<String>(
//                                           value: selectedStage,
//                                           isExpanded: true,
//                                           focusColor: Colors.transparent,
//                                           underline: SizedBox(),
//                                           items: [
//                                             "Suspects",
//                                             "Prospects",
//                                             "Customers",
//                                           ].map((value) {
//                                             return DropdownMenuItem(
//                                               value: value,
//                                               child: Text(value),
//                                             );
//                                           }).toList(),
//                                           onChanged: (value) {
//                                             setState(() {
//                                               selectedStage = value!;
//                                               isEdit=true;
//                                             });
//                                           },
//                                         ),
//                                       ),
//                                       15.height,
//                                       TextField(
//                                         controller: reasonController,
//                                         decoration: InputDecoration(
//                                           labelText: "Reason",
//                                           border: OutlineInputBorder(),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   actions: [
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         Container(
//                                           decoration: BoxDecoration(
//                                               border: Border.all(color: colorsConst.primary),
//                                               color: Colors.white),
//                                           width: 80,
//                                           height: 25,
//                                           child: ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                 shape: const RoundedRectangleBorder(
//                                                   borderRadius: BorderRadius.zero,
//                                                 ),
//                                                 backgroundColor: Colors.white,
//                                               ),
//                                               onPressed: () {
//                                                 Navigator.pop(context);
//                                               },
//                                               child: CustomText(
//                                                 text: "Cancel",
//                                                 isCopy: false,
//                                                 colors: colorsConst.primary,
//                                                 size: 14,
//                                               )),
//                                         ),
//                                         10.width,
//                                         CustomLoadingButton(
//                                           callback: () async {
//                                             // if (selectedStage == "Suspects") {
//                                             //   await apiService.insertSuspectsAPI(context, apiService.customerList);
//                                             // }else if (selectedStage == "Prospects") {
//                                             //   await apiService.insertProspectsAPI(context, apiService.customerList);
//                                             // }else if (selectedStage == "Customers") {
//                                             //   await apiService.insertPromoteCustomerAPI(context, apiService.customerList);
//                                             // }
//                                             // else {
//                                             //   await apiService.insertProspectsAPI(context, [deleteData]);
//                                             // }
//                                             String status="0";
//                                             if (selectedStage == "Suspects") {
//                                               status="1";
//                                             } else if (selectedStage == "Prospects") {
//                                               status="2";
//                                             } else if (selectedStage == "Customers") {
//                                               status="4";
//                                             }
//                                             await apiService.updateLeadStatus(context, apiService.customerList,status);
//                                             setState(() {
//                                               apiService.customerList.clear();
//                                             });
//                                           },
//                                           height: 35,
//                                           isLoading: true,
//                                           backgroundColor:
//                                           colorsConst.primary,
//                                           radius: 2,
//                                           width: 80,
//                                           controller:
//                                           controllers.productCtr,
//                                           isImage: false,
//                                           text: "Promote",
//                                           textColor: Colors.white,
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                       searchController: controllers.search,
//                       onSearchChanged: (value) {
//                         controllers.searchQualified.value = value.toString();
//                       },
//                       onSelectMonth: () {
//                         controllers.selectMonth(
//                             context, controllers.selectedQualifiedSortBy, controllers.selectedPMonth);
//                       },
//                       selectedMonth: controllers.selectedPMonth,
//                       selectedSortBy: controllers.selectedQualifiedSortBy,
//                       isMenuOpen: controllers.isMenuOpen,
//                     ),
//                     10.height,
//                     Scrollbar(
//                       controller: _horizontalController,
//                       thumbVisibility: true,
//                       trackVisibility: true,
//                       interactive: true,
//                       thickness: 8,
//                       radius: const Radius.circular(8),
//                       scrollbarOrientation: ScrollbarOrientation.bottom,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: 300,
//                             child: Column(
//                               children: [
//                                 LeftTableHeader(
//                                   showCheckbox: true,
//                                   isAllSelected: controllers.isAllSelected.value,
//                                   onSelectAll: (value) {
//                                     if (controllers.paginatedQualifiedLeads.isEmpty) return;
//                                     controllers.isAllSelected.value = value ?? false;
//                                     if (value == true) {
//                                       apiService.customerList.clear();
//                                       for (var lead in controllers.isGoodLeadList) {
//                                         lead["isSelect"] = true;
//                                         apiService.customerList.add({
//                                           "lead_id": lead["lead_id"].toString(),
//                                           "user_id": controllers.storage.read("id").toString(),
//                                           "rating": lead["rating"].toString(),
//                                           "cos_id": controllers.storage.read("cos_id").toString(),
//                                         });
//                                       }
//                                     } else {
//                                       for (var lead in controllers.isGoodLeadList) {
//                                         lead["isSelect"] = false;
//                                       }
//                                       apiService.customerList.clear();
//                                     }
//                                     setState(() {});
//                                   },
//                                   onSortDate: () {
//                                     controllers.sortField.value = 'date';
//                                     controllers.sortOrder.value =
//                                     controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: MediaQuery.of(context).size.height - 345,
//                                   child: Obx(() => controllers.isLead.value == false?0.height:controllers.paginatedQualifiedLeads.isNotEmpty?
//                                   ScrollConfiguration(
//                                     behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//                                     child: ListView.builder(
//                                       controller: _leftController,
//                                       shrinkWrap: true,
//                                       physics: const ScrollPhysics(),
//                                       itemCount: controllers.paginatedQualifiedLeads.length,
//                                       itemBuilder: (context, index) {
//                                         final billing_data = controllers.paginatedQualifiedLeads[index];
//                                         return Obx(()=>LeftLeadTile(
//                                           leadIndex: "0",
//                                           pageName: "Qualified",
//                                           saveValue: controllers.isGoodLeadList[index]["isSelect"],
//                                           onChanged: (value) {
//                                             controllers.isAllSelected.value = false;
//                                             final lead = controllers.isGoodLeadList[index];
//                                             final leadId = billing_data.userId.toString();
//                                             if (lead["isSelect"] == true) {
//                                               lead["isSelect"] = false;
//                                               apiService.customerList.removeWhere((e) => e["lead_id"] == leadId);
//                                             } else {
//                                               lead["isSelect"] = true;
//                                               apiService.customerList.add({
//                                                 "lead_id": leadId,
//                                                 "user_id": controllers.storage.read("id").toString(),
//                                                 "rating": billing_data.rating ?? "Warm",
//                                                 "cos_id": controllers.storage.read("cos_id").toString(),
//                                               });
//                                             }
//                                             setState(() {});
//                                           },
//                                           visitType: billing_data.visitType.toString(),
//                                           detailsOfServiceReq: billing_data.detailsOfServiceRequired.toString(),
//                                           statusUpdate: billing_data.statusUpdate.toString(),
//                                           index: index,
//                                           points: billing_data.points.toString(),
//                                           quotationStatus: billing_data.quotationStatus.toString(),
//                                           quotationRequired: billing_data.quotationRequired.toString(),
//                                           productDiscussion: billing_data.productDiscussion.toString(),
//                                           discussionPoint: billing_data.discussionPoint.toString(),
//                                           notes: billing_data.notes.toString(),
//                                           linkedin: billing_data.linkedin,
//                                           x: billing_data.x,
//                                           name: billing_data.firstname.toString().split("||")[0],
//                                           mobileNumber: billing_data.mobileNumber.toString().split("||")[0],
//                                           email: billing_data.email.toString().split("||")[0],
//                                           companyName: billing_data.companyName.toString(),
//                                           mainWhatsApp: billing_data.whatsapp.toString().split("||")[0],
//                                           emailUpdate: billing_data.quotationUpdate.toString(),
//                                           id: billing_data.userId.toString(),
//                                           status: billing_data.leadStatus ?? "UnQualified",
//                                           rating: billing_data.rating ?? "Warm",
//                                           mainName: billing_data.firstname.toString().split("||")[0],
//                                           mainMobile: billing_data.mobileNumber.toString().split("||")[0],
//                                           mainEmail: billing_data.email.toString().split("||")[0],
//                                           title: "",
//                                           whatsappNumber: billing_data.whatsapp.toString().split("||")[0],
//                                           mainTitle: "",
//                                           addressId: billing_data.addressId ?? "",
//                                           companyWebsite: billing_data.companyWebsite ?? "",
//                                           companyNumber: billing_data.companyNumber ?? "",
//                                           companyEmail: billing_data.companyEmail ?? "",
//                                           industry: billing_data.industry ?? "",
//                                           productServices: billing_data.product ?? "",
//                                           source:billing_data.source ?? "",
//                                           owner: billing_data.owner ?? "",
//                                           timelineDecision: "",
//                                           serviceInterest: "",
//                                           description: "",
//                                           leadStatus: billing_data.leadStatus ?? "",
//                                           active: billing_data.active ?? "",
//                                           addressLine1: billing_data.doorNo ?? "",
//                                           addressLine2: billing_data.landmark1 ?? "",
//                                           area: billing_data.area ?? "",
//                                           city: billing_data.city ?? "",
//                                           state: billing_data.state ?? "",
//                                           country: billing_data.country ?? "",
//                                           pinCode: billing_data.pincode ?? "",
//                                           prospectEnrollmentDate: billing_data.prospectEnrollmentDate ?? "",
//                                           expectedConvertionDate: billing_data.expectedConvertionDate ?? "",
//                                           numOfHeadcount: billing_data.numOfHeadcount ?? "",
//                                           expectedBillingValue: billing_data.expectedBillingValue ?? "",
//                                           arpuValue: billing_data.arpuValue ?? "",
//                                           updatedTs: billing_data.updatedTs ?? "",
//                                           sourceDetails: billing_data.sourceDetails ?? "",
//                                         ));
//                                       },
//                                     ),
//                                   ):0.height
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           Expanded(
//                             child: Focus(
//                               autofocus: true,
//                               focusNode: _focusNode,
//                               onKey: (node, event) {
//                                 if (event is RawKeyDownEvent) {
//                                   if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
//                                     _leftController.animateTo(
//                                       _leftController.offset + 100,
//                                       duration: const Duration(milliseconds: 200),
//                                       curve: Curves.easeInOut,
//                                     );
//                                     return KeyEventResult.handled;
//                                   } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
//                                     _rightController.animateTo(
//                                       _rightController.offset - 100,
//                                       duration: const Duration(milliseconds: 200),
//                                       curve: Curves.easeInOut,
//                                     );
//                                     return KeyEventResult.handled;
//                                   } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
//                                     _horizontalController.animateTo(
//                                       _horizontalController.offset + 100,
//                                       duration: const Duration(milliseconds: 200),
//                                       curve: Curves.easeInOut,
//                                     );
//                                     return KeyEventResult.handled;
//                                   } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
//                                     _horizontalController.animateTo(
//                                       _horizontalController.offset - 100,
//                                       duration: const Duration(milliseconds: 200),
//                                       curve: Curves.easeInOut,
//                                     );
//                                     return KeyEventResult.handled;
//                                   }
//                                 }
//                                 return KeyEventResult.ignored;
//                               },
//                               child: SingleChildScrollView(
//                                 controller: _horizontalController,
//                                 scrollDirection: Axis.horizontal,
//                                 child: Column(
//                                   children: [
//                                     SizedBox(
//                                       height: 45,
//                                       width: tableWidth,
//                                       child: CustomTableHeader(
//                                         onSortName: () {
//                                           controllers.sortField.value = 'name';
//                                           controllers.sortOrderN.value =
//                                           controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
//                                         },
//                                         onSortDate: () {
//                                           controllers.sortField.value = 'date';
//                                           controllers.sortOrder.value =
//                                           controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
//                                         },
//                                       ),
//                                     ),
//                                     Container(
//                                       alignment: Alignment.topLeft,
//                                       height: MediaQuery.of(context).size.height - 345,
//                                       width: tableWidth,
//                                       child: Obx(
//                                               () => controllers.isLead.value == false
//                                               ? Container(
//                                                   alignment: Alignment.centerLeft,
//                                                   width: MediaQuery.of(context).size.width,
//                                                   height: MediaQuery.of(context).size.height,
//                                                   padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
//                                                   child: const Center(child: CircularProgressIndicator()))
//                                               : controllers.paginatedQualifiedLeads.isNotEmpty?
//                                           ListView.builder(
//                                             controller: _rightController,
//                                             shrinkWrap: true,
//                                             physics: const ScrollPhysics(),
//                                             itemCount: controllers.paginatedQualifiedLeads.length,
//                                             itemBuilder: (context, index) {
//                                               final billing_data = controllers.paginatedQualifiedLeads[index];
//                                               return Obx(()=>CustomLeadTile(
//                                                 pageName: "Qualified",
//                                                 saveValue: controllers.isGoodLeadList[index]["isSelect"],
//                                                 onChanged: (value){
//                                                   setState(() {
//                                                     if(controllers.isGoodLeadList[index]["isSelect"]==true){
//                                                       controllers.isGoodLeadList[index]["isSelect"]=false;
//                                                       var i=apiService.customerList.indexWhere((element) => element["lead_id"]==billing_data.userId.toString());
//                                                       apiService.customerList.removeAt(i);
//                                                     }else{
//                                                       controllers.isGoodLeadList[index]["isSelect"]=true;
//                                                       apiService.customerList.add({
//                                                         "lead_id":billing_data.userId.toString(),
//                                                         "user_id":controllers.storage.read("id"),
//                                                         "rating":billing_data.rating ?? "Warm",
//                                                         "cos_id":controllers.storage.read("cos_id"),
//                                                       });
//                                                     }
//                                                   });
//                                                 },
//                                                 visitType: billing_data.visitType.toString(),
//                                                 detailsOfServiceReq: billing_data.detailsOfServiceRequired.toString(),
//                                                 statusUpdate: billing_data.statusUpdate.toString(),
//                                                 index: index,
//                                                 points: billing_data.points.toString(),
//                                                 quotationStatus: billing_data.quotationStatus.toString(),
//                                                 quotationRequired: billing_data.quotationRequired.toString(),
//                                                 productDiscussion: billing_data.productDiscussion.toString(),
//                                                 discussionPoint: billing_data.discussionPoint.toString(),
//                                                 notes: billing_data.notes.toString(),
//                                                 linkedin: billing_data.linkedin,
//                                                 x: billing_data.x,
//                                                 name: billing_data.firstname.toString().split("||")[0],
//                                                 mobileNumber: billing_data.mobileNumber.toString().split("||")[0],
//                                                 email: billing_data.email.toString().split("||")[0],
//                                                 companyName: billing_data.companyName.toString(),
//                                                 mainWhatsApp: billing_data.whatsapp.toString().split("||")[0],
//                                                 emailUpdate: billing_data.quotationUpdate.toString(),
//                                                 id: billing_data.userId.toString(),
//                                                 status: billing_data.leadStatus ?? "UnQualified",
//                                                 rating: billing_data.rating ?? "Warm",
//                                                 mainName: billing_data.firstname.toString().split("||")[0],
//                                                 mainMobile: billing_data.mobileNumber.toString().split("||")[0],
//                                                 mainEmail: billing_data.email.toString().split("||")[0],
//                                                 title: "",
//                                                 whatsappNumber: billing_data.whatsapp.toString().split("||")[0],
//                                                 mainTitle: "",
//                                                 addressId: billing_data.addressId ?? "",
//                                                 companyWebsite: billing_data.companyWebsite ?? "",
//                                                 companyNumber: billing_data.companyNumber ?? "",
//                                                 companyEmail: billing_data.companyEmail ?? "",
//                                                 industry: billing_data.industry ?? "",
//                                                 productServices: billing_data.product ?? "",
//                                                 source:billing_data.source ?? "",
//                                                 owner: billing_data.owner ?? "",
//                                                 timelineDecision: "",
//                                                 serviceInterest: "",
//                                                 description: "",
//                                                 leadStatus: billing_data.leadStatus ?? "",
//                                                 active: billing_data.active ?? "",
//                                                 addressLine1: billing_data.doorNo ?? "",
//                                                 addressLine2: billing_data.landmark1 ?? "",
//                                                 area: billing_data.area ?? "",
//                                                 city: billing_data.city ?? "",
//                                                 state: billing_data.state ?? "",
//                                                 country: billing_data.country ?? "",
//                                                 pinCode: billing_data.pincode ?? "",
//                                                 prospectEnrollmentDate: billing_data.prospectEnrollmentDate ?? "",
//                                                 expectedConvertionDate: billing_data.expectedConvertionDate ?? "",
//                                                 numOfHeadcount: billing_data.numOfHeadcount ?? "",
//                                                 expectedBillingValue: billing_data.expectedBillingValue ?? "",
//                                                 arpuValue: billing_data.arpuValue ?? "",
//                                                 updatedTs: billing_data.updatedTs ?? "",
//                                                 sourceDetails: billing_data.sourceDetails ?? "",
//                                               ));
//                                             },
//                                           ):
//                                               CustomNoData()
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     20.height,
//                   ],
//                 ),
//               ),)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
