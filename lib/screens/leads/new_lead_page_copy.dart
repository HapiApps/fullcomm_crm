// import 'dart:developer';
//
// import 'package:flutter/services.dart';
// import 'package:fullcomm_crm/common/constant/colors_constant.dart';
// import 'package:fullcomm_crm/common/extentions/extensions.dart';
// import 'package:fullcomm_crm/common/utilities/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:fullcomm_crm/components/customer_name_tile.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../common/utilities/mail_utils.dart';
// import '../../components/custom_filter_seaction.dart';
// import '../../components/custom_header_seaction.dart';
// import '../../components/custom_lead_tile.dart';
// import '../../components/custom_loading_button.dart';
// import '../../components/custom_no_data.dart';
// import '../../components/custom_sidebar.dart';
// import '../../components/dynamic_table_header.dart';
// import '../../components/custom_text.dart';
// import '../../components/customer_name_header.dart';
// import '../../controller/controller.dart';
// import '../../models/new_lead_obj.dart';
// import '../../services/api_services.dart';
//
// class NewLeadPage extends StatefulWidget {
//   final String index;
//   final int listIndex;
//   final String name;
//   final RxList<NewLeadObj> list;
//   final RxList<NewLeadObj> list2;
//   const NewLeadPage({super.key, required this.index, required this.name, required this.list, required this.list2, required this.listIndex});
//
//   @override
//   State<NewLeadPage> createState() => _NewLeadPageState();
// }
//
// class _NewLeadPageState extends State<NewLeadPage> {
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
//       apiService.changeList(widget.index);
//       controllers.selectRadio(widget.list);
//       apiService.currentVersion();
//       controllers.groupController.selectIndex(0);
//       setState(() {
//         // controllers.search.clear();
//         controllers.idList.clear();
//         for (var lead in widget.list) {
//           lead.select = false;
//         }
//         // apiService.newLeadList = [];
//         // apiService.newLeadList.clear();
//         // //Santhiya
//         controllers.isAllSelected.value = false;
//         // for (var item in controllers.isLeadsList) {
//         //   item["isSelect"] = false;
//         //
//         //   widget.list.removeWhere(
//         //         (e) => e.userId== item["lead_id"],
//         //   );
//         // }
//       });
//       controllers.searchProspects.value = "";
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
//      log("controllers.selectedIndex.value: ${controllers.selectedIndex.value}");
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
//     return SelectionArea(
//       child: Scaffold(
//         body: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SideBar(),
//             Obx(() => Container(
//               width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
//                 height: MediaQuery.of(context).size.height,
//                 alignment: Alignment.center,
//                 padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header Section
//                     HeaderSection(
//                       list: widget.list,list2: widget.list2,
//                       title: "Leads - ${widget.name}",
//                       subtitle: "View all of your ${widget.name} Information",
//                       // list: controllers.allLeadFuture,
//                     ),
//                     20.height,
//                     // Filter Section
//                     FilterSection(
//                       //Santhiya
//                       leadIndex: widget.index,
//                       itemCount: widget.list.length,
//                       count: controllers.allLeadList.length,
//                       focusNode: _focusNode,
//                       leadFuture: controllers.allLeadFuture,
//                       title: widget.name,
//                       itemList: controllers.idList,
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
//                                           await apiService.deleteCustomersAPI(context, controllers.idList.value,widget.list,widget.list2);
//                                           setState(() {
//                                             apiService.newLeadList.clear();
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
//                         // mailUtils.bulkEmailDialog(_focusNode, list: widget.list);
//                         mailUtils.bulkEmailDialog(_focusNode, list: apiService.newLeadList);
//                       },
//                       onPromote: () {
//                         debugPrint("onTapppp");
//                         // showDialog(
//                         //   context: context,
//                         //   builder: (context) {
//                         //     String selectedStage="";
//                         //     for (var i=0;i<controllers.leadCategoryList.length;i++){
//                         //       if(i==int.parse(widget.index)){
//                         //         selectedStage=controllers.leadCategoryList[i]["value"];
//                         //       }
//                         //     }
//                         //     bool isEdit=false;
//                         //     TextEditingController reasonController = TextEditingController();
//                         //     return StatefulBuilder(
//                         //       builder: (context, setState) {
//                         //         return AlertDialog(
//                         //           title: CustomText(
//                         //             text: "Move to Next Level",
//                         //             size: 18,
//                         //             isBold: true,
//                         //             isCopy: false,
//                         //             colors: colorsConst.textColor,
//                         //           ),
//                         //           content: Column(
//                         //             mainAxisSize: MainAxisSize.min,
//                         //             crossAxisAlignment: CrossAxisAlignment.start,
//                         //             children: [
//                         //               CustomText(
//                         //                 text: "Select Stage",
//                         //                 size: 14,
//                         //                 isBold: true,
//                         //                 isCopy: false,
//                         //               ),
//                         //               8.height,
//                         //               Container(
//                         //                 padding: EdgeInsets.symmetric(horizontal: 8),
//                         //                 decoration: BoxDecoration(
//                         //                   border: Border.all(color: colorsConst.primary),
//                         //                   borderRadius: BorderRadius.circular(4),
//                         //                 ),
//                         //                 child: DropdownButton<String>(
//                         //                   value: selectedStage,
//                         //                   isExpanded: true,
//                         //                   focusColor: Colors.transparent,
//                         //                   underline: SizedBox(),
//                         //                   items: controllers.leadCategoryList.map((item) {
//                         //                     return DropdownMenuItem<String>(
//                         //                       value: item.value,
//                         //                       child: Text(item.value),
//                         //                     );
//                         //                   }).toList(),
//                         //                   onChanged: (value) {
//                         //                     setState(() {
//                         //                       selectedStage = value!;
//                         //                       isEdit=true;
//                         //                     });
//                         //                   },
//                         //                 ),
//                         //               ),
//                         //               15.height,
//                         //               TextField(
//                         //                 controller: reasonController,
//                         //                 decoration: InputDecoration(
//                         //                   labelText: "Reason",
//                         //                   border: OutlineInputBorder(),
//                         //                 ),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //           actions: [
//                         //             Row(
//                         //               mainAxisAlignment: MainAxisAlignment.end,
//                         //               children: [
//                         //                 Container(
//                         //                   decoration: BoxDecoration(
//                         //                       border: Border.all(color: colorsConst.primary),
//                         //                       color: Colors.white),
//                         //                   width: 80,
//                         //                   height: 25,
//                         //                   child: ElevatedButton(
//                         //                       style: ElevatedButton.styleFrom(
//                         //                         shape: const RoundedRectangleBorder(
//                         //                           borderRadius: BorderRadius.zero,
//                         //                         ),
//                         //                         backgroundColor: Colors.white,
//                         //                       ),
//                         //                       onPressed: () {
//                         //                         Navigator.pop(context);
//                         //                       },
//                         //                       child: CustomText(
//                         //                         text: "Cancel",
//                         //                         isCopy: false,
//                         //                         colors: colorsConst.primary,
//                         //                         size: 14,
//                         //                       )),
//                         //                 ),
//                         //                 10.width,
//                         //                 CustomLoadingButton(
//                         //                   callback: () async {
//                         //                     if (selectedStage == "Suspects") {
//                         //                       await apiService.insertLeadPromoteAPI(context, apiService.newLeadList);
//                         //                     } else if (selectedStage == "Qualified") {
//                         //                       await apiService.insertQualifiedAPI(context, apiService.newLeadList);
//                         //                     } else if (selectedStage == "Customers") {
//                         //                       await apiService.insertPromoteCustomerAPI(context, apiService.newLeadList);
//                         //                     }
//                         //                     // else {
//                         //                     //   await apiService.insertProspectsAPI(context, [deleteData]);
//                         //                     // }
//                         //                     setState(() {
//                         //                       apiService.newLeadList.clear();
//                         //                     });
//                         //                   },
//                         //                   height: 35,
//                         //                   isLoading: true,
//                         //                   backgroundColor:
//                         //                   colorsConst.primary,
//                         //                   radius: 2,
//                         //                   width: 80,
//                         //                   controller:
//                         //                   controllers.productCtr,
//                         //                   isImage: false,
//                         //                   text: "Promote",
//                         //                   textColor: Colors.white,
//                         //                 ),
//                         //               ],
//                         //             )
//                         //           ],
//                         //         );
//                         //       },
//                         //     );
//                         //   },
//                         // );
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             String? stageId;
//                             String selectedStage = "";
//                             bool isEdit = false;
//
//                             TextEditingController reasonController =
//                             TextEditingController();
//
//                             int currentIndex = int.parse(widget.index.toString());
//                             int nextIndex = currentIndex + 1;
//
//                             // Safe default selection
//                             if (controllers.leadCategoryList.isNotEmpty) {
//                               if (nextIndex <
//                                   controllers.leadCategoryList.length) {
//                                 stageId = controllers
//                                     .leadCategoryList[nextIndex].leadStatus;
//                                 selectedStage = controllers
//                                     .leadCategoryList[nextIndex].value;
//                               } else {
//                                 stageId =
//                                     controllers.leadCategoryList[0].leadStatus;
//                                 selectedStage =
//                                     controllers.leadCategoryList[0].value;
//                               }
//                             }
//
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
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       CustomText(
//                                         text: "Select Stage",
//                                         size: 14,
//                                         isBold: true,
//                                         isCopy: false,
//                                       ),
//                                       const SizedBox(height: 8),
//
//                                       /// DROPDOWN
//                                       Container(
//                                         padding:
//                                         const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: colorsConst.primary),
//                                           borderRadius:
//                                           BorderRadius.circular(4),
//                                         ),
//                                         child: DropdownButton<String>(
//                                           value: controllers
//                                               .leadCategoryList
//                                               .any((e) =>
//                                           e.leadStatus ==
//                                               stageId)
//                                               ? stageId
//                                               : null,
//                                           isExpanded: true,
//                                           underline: const SizedBox(),
//                                           items: controllers
//                                               .leadCategoryList
//                                               .map((item) {
//                                             return DropdownMenuItem<String>(
//                                               value: item.leadStatus,
//                                               child: Text(item.value),
//                                             );
//                                           }).toList(),
//                                           onChanged: (value) {
//                                             setState(() {
//                                               stageId = value;
//                                               selectedStage = controllers
//                                                   .leadCategoryList
//                                                   .firstWhere((e) =>
//                                               e.leadStatus ==
//                                                   value)
//                                                   .value;
//                                               isEdit = true;
//                                             });
//                                           },
//                                         ),
//                                       ),
//
//                                       const SizedBox(height: 15),
//
//                                       /// REASON FIELD
//                                       TextField(
//                                         controller: reasonController,
//                                         decoration:
//                                         const InputDecoration(
//                                           labelText: "Reason",
//                                           border:
//                                           OutlineInputBorder(),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   /// ACTIONS
//                                   actions: [
//                                     Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.end,
//                                       children: [
//                                         /// CANCEL
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 color:
//                                                 colorsConst.primary),
//                                             color: Colors.white,
//                                           ),
//                                           width: 80,
//                                           height: 30,
//                                           child: ElevatedButton(
//                                             style:
//                                             ElevatedButton.styleFrom(
//                                               shape:
//                                               const RoundedRectangleBorder(
//                                                 borderRadius:
//                                                 BorderRadius.zero,
//                                               ),
//                                               backgroundColor:
//                                               Colors.white,
//                                               elevation: 0,
//                                             ),
//                                             onPressed: () {
//                                               Navigator.pop(
//                                                   context);
//                                             },
//                                             child: CustomText(
//                                               text: "Cancel",
//                                               isCopy: false,
//                                               colors:
//                                               colorsConst.primary,
//                                               size: 14,
//                                             ),
//                                           ),
//                                         ),
//
//                                         const SizedBox(width: 10),
//
//                                         /// PROMOTE BUTTON
//                                         CustomLoadingButton(
//                                           callback: () async {
//                                             if (stageId == null) return;
//
//                                             await apiService
//                                                 .insertPromoteListAPI(
//                                               context,
//                                               stageId.toString(),
//                                               selectedStage,
//                                               widget.list,
//                                               widget.list2,
//                                             );
//
//                                             Navigator.pop(context);
//                                           },
//                                           height: 35,
//                                           isLoading: true,
//                                           backgroundColor:
//                                           colorsConst.primary,
//                                           radius: 2,
//                                           width: 90,
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
//                       onDemote: () {
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             String? stageId;
//                             String selectedStage = "";
//                             bool isEdit = false;
//
//                             TextEditingController reasonController =
//                             TextEditingController();
//
//                             int currentIndex = int.parse(widget.index.toString());
//                             int nextIndex = currentIndex + 1;
//
//                             // Safe default selection
//                             if (controllers.leadCategoryList.isNotEmpty) {
//                               if (nextIndex <
//                                   controllers.leadCategoryList.length) {
//                                 stageId = controllers
//                                     .leadCategoryList[nextIndex].leadStatus;
//                                 selectedStage = controllers
//                                     .leadCategoryList[nextIndex].value;
//                               } else {
//                                 stageId =
//                                     controllers.leadCategoryList[0].leadStatus;
//                                 selectedStage =
//                                     controllers.leadCategoryList[0].value;
//                               }
//                             }
//
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
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       CustomText(
//                                         text: "Select Stage",
//                                         size: 14,
//                                         isBold: true,
//                                         isCopy: false,
//                                       ),
//                                       const SizedBox(height: 8),
//
//                                       /// DROPDOWN
//                                       Container(
//                                         padding:
//                                         const EdgeInsets.symmetric(
//                                             horizontal: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: colorsConst.primary),
//                                           borderRadius:
//                                           BorderRadius.circular(4),
//                                         ),
//                                         child: DropdownButton<String>(
//                                           value: controllers
//                                               .leadCategoryList
//                                               .any((e) =>
//                                           e.leadStatus ==
//                                               stageId)
//                                               ? stageId
//                                               : null,
//                                           isExpanded: true,
//                                           underline: const SizedBox(),
//                                           items: controllers
//                                               .leadCategoryList
//                                               .map((item) {
//                                             return DropdownMenuItem<String>(
//                                               value: item.leadStatus,
//                                               child: Text(item.value),
//                                             );
//                                           }).toList(),
//                                           onChanged: (value) {
//                                             setState(() {
//                                               stageId = value;
//                                               selectedStage = controllers
//                                                   .leadCategoryList
//                                                   .firstWhere((e) =>
//                                               e.leadStatus ==
//                                                   value)
//                                                   .value;
//                                               isEdit = true;
//                                             });
//                                           },
//                                         ),
//                                       ),
//
//                                       const SizedBox(height: 15),
//
//                                       /// REASON FIELD
//                                       TextField(
//                                         controller: reasonController,
//                                         decoration:
//                                         const InputDecoration(
//                                           labelText: "Reason",
//                                           border:
//                                           OutlineInputBorder(),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   /// ACTIONS
//                                   actions: [
//                                     Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.end,
//                                       children: [
//                                         /// CANCEL
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 color:
//                                                 colorsConst.primary),
//                                             color: Colors.white,
//                                           ),
//                                           width: 80,
//                                           height: 30,
//                                           child: ElevatedButton(
//                                             style:
//                                             ElevatedButton.styleFrom(
//                                               shape:
//                                               const RoundedRectangleBorder(
//                                                 borderRadius:
//                                                 BorderRadius.zero,
//                                               ),
//                                               backgroundColor:
//                                               Colors.white,
//                                               elevation: 0,
//                                             ),
//                                             onPressed: () {
//                                               Navigator.pop(
//                                                   context);
//                                             },
//                                             child: CustomText(
//                                               text: "Cancel",
//                                               isCopy: false,
//                                               colors:
//                                               colorsConst.primary,
//                                               size: 14,
//                                             ),
//                                           ),
//                                         ),
//
//                                         const SizedBox(width: 10),
//
//                                         /// PROMOTE BUTTON
//                                         CustomLoadingButton(
//                                           callback: () async {
//                                             if (stageId == null) return;
//
//                                             await apiService
//                                                 .insertPromoteListAPI(
//                                               context,
//                                               stageId.toString(),
//                                               selectedStage,
//                                               widget.list,
//                                               widget.list2,
//                                             );
//
//                                             Navigator.pop(context);
//                                           },
//                                           height: 35,
//                                           isLoading: true,
//                                           backgroundColor:
//                                           colorsConst.primary,
//                                           radius: 2,
//                                           width: 90,
//                                           controller:
//                                           controllers.productCtr,
//                                           isImage: false,
//                                           text: "Demote",
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
//
//                       searchController: controllers.search,
//                       onSearchChanged: (value) {
//                         controllers.searchProspects.value = value.toString();
//                         final suggestions = widget.list2.where(
//                                 (user) {
//                               final phone = user.mobileNumber.toString().toLowerCase();
//                               final name = user.firstname.toString().toLowerCase();
//                               final city = user.companyName.toString().toLowerCase();
//                               final input = value.toString().toLowerCase().trim();
//                               return phone.contains(input) ||name.contains(input) ||city.contains(input);
//                             }).toList();
//                         widget.list.value = suggestions;
//                         controllers.selectRadio(widget.list);
//                       },
//                       onSelectMonth: () {
//                         controllers.selectMonth(
//                             context, controllers.selectedQualifiedSortBy, controllers.selectedPMonth,widget.list,widget.list2);
//                       },
//                       selectedMonth: controllers.selectedPMonth,
//                       selectedSortBy: controllers.selectedQualifiedSortBy,
//                       isMenuOpen: controllers.isMenuOpen, list: widget.list, list2: widget.list2,
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
//                                 CustomerNameHeader(
//                                   showCheckbox: true,
//                                   isAllSelected: controllers.isAllSelected.value,
//                                   onSelectAll: (value) async {
//                                     if (widget.list.isEmpty) return;
//                                     await Future.microtask(() {
//                                       if (value == true) {
//                                         controllers.isAllSelected.value = true;
//                                         for (var lead in widget.list) {
//                                           lead.select = true;
//                                           controllers.idList.add(lead.userId);
//                                         }
//                                       } else {
//                                         controllers.isAllSelected.value = false;
//                                         for (var lead in widget.list) {
//                                           lead.select = false;
//                                           controllers.idList.remove(lead.userId);
//                                         }
//                                       }
//                                     });
//                                     setState(() {});
//                                     debugPrint("...${controllers.idList}");
//                                   },
//                                   onSortDate: () {
//                                     setState(() {
//                                       controllers.sortField.value = 'date';
//                                       controllers.sortOrder.value =
//                                       controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
//                                       if(controllers.sortOrder.value=="asc"){
//                                         widget.list.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
//                                         widget.list2.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
//                                       }else{
//                                         widget.list.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
//                                         widget.list2.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
//                                       }
//                                     });
//                                   },
//                                 ),
//                                 SizedBox(
//                                   height: MediaQuery.of(context).size.height - 345,
//                                   child: Obx(() => widget.list.isNotEmpty?
//                                   ScrollConfiguration(
//                                     behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//                                     child: ListView.builder(
//                                       controller: _leftController,
//                                       shrinkWrap: true,
//                                       physics: const ScrollPhysics(),
//                                       itemCount: widget.list.length,
//                                       itemBuilder: (context, index) {
//                                         final data = widget.list[index];
//                                         return Obx(()=>CustomerNameTile(
//                                           listIndex: index,
//                                           list: widget.list,list2: widget.list2,
//                                           leadIndex: widget.index,
//                                           pageName: "Prospects",
//                                           saveValue: widget.list[index].select==true?true:false,
//                                           onChanged: (value) {
//                                             controllers.isAllSelected.value = false;
//                                             final lead = widget.list[index];
//                                             if (lead.select == true) {
//                                               lead.select = false;
//                                               controllers.idList.remove(lead.userId);
//                                             } else {
//                                               lead.select = true;
//                                               controllers.idList.add(lead.userId);
//                                             }
//                                             setState(() {});
//                                             debugPrint("...${controllers.idList}");
//                                           },
//                                           visitType: data.visitType.toString(),
//                                           detailsOfServiceReq: data.detailsOfServiceRequired.toString(),
//                                           statusUpdate: data.statusUpdate.toString(),
//                                           index: index,
//                                           points: data.points.toString(),
//                                           quotationStatus: data.quotationStatus.toString(),
//                                           quotationRequired: data.quotationRequired.toString(),
//                                           productDiscussion: data.productDiscussion.toString(),
//                                           discussionPoint: data.discussionPoint.toString(),
//                                           notes: data.notes.toString(),
//                                           linkedin: data.linkedin,
//                                           x: data.x,
//                                           name: data.firstname.toString().split("||")[0],
//                                           mobileNumber: data.mobileNumber.toString(),
//                                           email: data.email.toString().split("||")[0],
//                                           companyName: data.companyName.toString(),
//                                           mainWhatsApp: data.whatsapp.toString().split("||")[0],
//                                           emailUpdate: data.quotationUpdate.toString(),
//                                           id: data.userId.toString(),
//                                           status: data.leadStatus ?? "UnQualified",
//                                           rating: data.rating ?? "Warm",
//                                           mainName: data.firstname.toString().split("||")[0],
//                                           mainMobile: data.mobileNumber.toString().split("||")[0],
//                                           mainEmail: data.email.toString().split("||")[0],
//                                           title: "",
//                                           whatsappNumber: data.whatsapp.toString().split("||")[0],
//                                           mainTitle: "",
//                                           addressId: data.addressId ?? "",
//                                           companyWebsite: data.companyWebsite ?? "",
//                                           companyNumber: data.companyNumber ?? "",
//                                           companyEmail: data.companyEmail ?? "",
//                                           industry: data.industry ?? "",
//                                           productServices: data.product ?? "",
//                                           source:data.source ?? "",
//                                           owner: data.owner ?? "",
//                                           timelineDecision: "",
//                                           serviceInterest: "",
//                                           description: "",
//                                           leadStatus: data.leadStatus ?? "",
//                                           active: data.active ?? "",
//                                           addressLine1: data.doorNo ?? "",
//                                           addressLine2: data.landmark1 ?? "",
//                                           area: data.area ?? "",
//                                           city: data.city ?? "",
//                                           state: data.state ?? "",
//                                           country: data.country ?? "",
//                                           pinCode: data.pincode ?? "",
//                                           prospectEnrollmentDate: data.prospectEnrollmentDate ?? "",
//                                           expectedConvertionDate: data.expectedConvertionDate ?? "",
//                                           numOfHeadcount: data.numOfHeadcount ?? "",
//                                           expectedBillingValue: data.expectedBillingValue ?? "",
//                                           arpuValue: data.arpuValue ?? "",
//                                           updatedTs: data.updatedTs ?? "",
//                                           sourceDetails: data.sourceDetails ?? "",
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
//                                       child: DynamicTableHeader(
//                                         onSortName: () {
//                                           controllers.sortField.value = 'name';
//                                           controllers.sortOrderN.value =
//                                           controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
//                                         },
//                                         onSortDate: () {
//                                           setState(() {
//                                             controllers.sortField.value = 'date';
//                                             controllers.sortOrder.value =
//                                             controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
//                                             if(controllers.sortOrder.value=="asc"){
//                                               widget.list.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
//                                               widget.list2.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
//                                             }else{
//                                               widget.list.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
//                                               widget.list2.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
//                                             }
//                                           });
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
//                                               : widget.list.isNotEmpty?
//                                           ListView.builder(
//                                             controller: _rightController,
//                                             shrinkWrap: true,
//                                             physics: const ScrollPhysics(),
//                                             itemCount: widget.list.length,
//                                             itemBuilder: (context, index) {
//                                               final data = widget.list[index];
//                                               return Obx(()=>CustomLeadTile(
//                                                 listIndex: index,
//                                                 list: widget.list,list2: widget.list2,
//                                                 pageName: "Prospects",
//                                                 // saveValue: controllers.isLeadsList[index]["isSelect"],
//                                                 // onChanged: (value){
//                                                 //   setState(() {
//                                                 //     if(controllers.isLeadsList[index]["isSelect"]==true){
//                                                 //       controllers.isLeadsList[index]["isSelect"]=false;
//                                                 //       var i=apiService.newLeadList.indexWhere((element) => element["lead_id"]==data.userId.toString());
//                                                 //       apiService.newLeadList.removeAt(i);
//                                                 //     }else{
//                                                 //       controllers.isLeadsList[index]["isSelect"]=true;
//                                                 //       apiService.newLeadList.add({
//                                                 //         "lead_id":data.userId.toString(),
//                                                 //         "user_id":controllers.storage.read("id"),
//                                                 //         "rating":data.rating ?? "Warm",
//                                                 //         "cos_id":controllers.storage.read("cos_id"),
//                                                 //       });
//                                                 //     }
//                                                 //   });
//                                                 // },
//                                                 saveValue: widget.list[index].select==true?true:false,
//                                                 onChanged: (value) {
//                                                   controllers.isAllSelected.value = false;
//                                                   final lead = widget.list[index];
//                                                   if (lead.select == true) {
//                                                     lead.select = false;
//                                                     controllers.idList.remove(lead.userId);
//                                                   } else {
//                                                     lead.select = true;
//                                                     controllers.idList.add(lead.userId);
//                                                   }
//                                                   setState(() {});
//                                                   debugPrint("...${controllers.idList}");
//                                                 },
//                                                 visitType: data.visitType.toString(),
//                                                 detailsOfServiceReq: data.detailsOfServiceRequired.toString(),
//                                                 statusUpdate: data.statusUpdate.toString(),
//                                                 index: index,
//                                                 points: data.points.toString(),
//                                                 quotationStatus: data.quotationStatus.toString(),
//                                                 quotationRequired: data.quotationRequired.toString(),
//                                                 productDiscussion: data.productDiscussion.toString(),
//                                                 discussionPoint: data.discussionPoint.toString(),
//                                                 notes: data.notes.toString(),
//                                                 linkedin: data.linkedin,
//                                                 x: data.x,
//                                                 name: data.firstname.toString().split("||")[0],
//                                                 mobileNumber: data.mobileNumber.toString().split("||")[0],
//                                                 email: data.email.toString().split("||")[0],
//                                                 companyName: data.companyName.toString(),
//                                                 mainWhatsApp: data.whatsapp.toString().split("||")[0],
//                                                 emailUpdate: data.quotationUpdate.toString(),
//                                                 id: data.userId.toString(),
//                                                 status: data.leadStatus ?? "UnQualified",
//                                                 rating: data.rating ?? "Warm",
//                                                 mainName: data.firstname.toString().split("||")[0],
//                                                 mainMobile: data.mobileNumber.toString().split("||")[0],
//                                                 mainEmail: data.email.toString().split("||")[0],
//                                                 title: "",
//                                                 whatsappNumber: data.whatsapp.toString().split("||")[0],
//                                                 mainTitle: "",
//                                                 addressId: data.addressId ?? "",
//                                                 companyWebsite: data.companyWebsite ?? "",
//                                                 companyNumber: data.companyNumber ?? "",
//                                                 companyEmail: data.companyEmail ?? "",
//                                                 industry: data.industry ?? "",
//                                                 productServices: data.product ?? "",
//                                                 source:data.source ?? "",
//                                                 owner: data.owner ?? "",
//                                                 timelineDecision: "",
//                                                 serviceInterest: "",
//                                                 description: "",
//                                                 leadStatus: data.leadStatus ?? "",
//                                                 active: data.active ?? "",
//                                                 addressLine1: data.doorNo ?? "",
//                                                 addressLine2: data.landmark1 ?? "",
//                                                 area: data.area ?? "",
//                                                 city: data.city ?? "",
//                                                 state: data.state ?? "",
//                                                 country: data.country ?? "",
//                                                 pinCode: data.pincode ?? "",
//                                                 prospectEnrollmentDate: data.prospectEnrollmentDate ?? "",
//                                                 expectedConvertionDate: data.expectedConvertionDate ?? "",
//                                                 numOfHeadcount: data.numOfHeadcount ?? "",
//                                                 expectedBillingValue: data.expectedBillingValue ?? "",
//                                                 arpuValue: data.arpuValue ?? "",
//                                                 updatedTs: data.updatedTs ?? "",
//                                                 sourceDetails: data.sourceDetails ?? "",
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
//                     widget.list.isNotEmpty? Obx(() {
//                       final totalPages = controllers.totalProspectPages == 0 ? 1 : controllers.totalProspectPages;
//                       final currentPage = controllers.currentProspectPage.value;
//                       return Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
//                             _focusNode.requestFocus();
//                             controllers.currentProspectPage.value--;
//                           }),
//                           ...utils.buildPagination(totalPages, currentPage),
//                           utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
//                             controllers.currentProspectPage.value++;
//                             _focusNode.requestFocus();
//                           }),
//                         ],
//                       );
//                     }):0.height,
//                     20.height,
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
