// import 'package:flutter/services.dart';
// import 'package:fullcomm_crm/common/constant/colors_constant.dart';
// import 'package:fullcomm_crm/common/extentions/extensions.dart';
// import 'package:fullcomm_crm/components/custom_loading_button.dart';
// import 'package:flutter/material.dart';
// import 'package:fullcomm_crm/components/custom_no_data.dart';
// import 'package:fullcomm_crm/components/customer_name_tile.dart';
// import 'package:get/get.dart';
// import '../../common/utilities/mail_utils.dart';
// import '../../components/custom_filter_seaction.dart';
// import '../../components/custom_header_seaction.dart';
// import '../../components/custom_lead_tile.dart';
// import '../../components/custom_sidebar.dart';
// import '../../components/dynamic_table_header.dart';
// import '../../components/custom_text.dart';
// import '../../components/customer_name_header.dart';
// import '../../controller/controller.dart';
// import '../../services/api_services.dart';
//
// class ViewCustomer extends StatefulWidget {
//   const ViewCustomer({super.key});
//
//   @override
//   State<ViewCustomer> createState() => _ViewCustomerState();
// }
//
// class _ViewCustomerState extends State<ViewCustomer> {
//   var refreshKey = GlobalKey<RefreshIndicatorState>();
//   final ScrollController _controller = ScrollController();
//   final ScrollController _horizontalController = ScrollController();
//   final ScrollController _leftController = ScrollController();
//   final ScrollController _rightController = ScrollController();
//   late FocusNode _focusNode;
//   Future refresh() async {
//     refreshKey.currentState?.show(atTop: false);
//     controllers.allCustomerFuture = apiService.allCustomerDetails();
//     //await Future.delayed(const Duration(seconds: 3));
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _focusNode = FocusNode();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _focusNode.requestFocus();
//     });
//     Future.delayed(Duration.zero, () {
//       controllers.search.clear();
//       controllers.selectedIndex.value = 4;
//       controllers.groupController.selectIndex(0);
//       //Santhiya
//       controllers.isAllSelected.value = false;
//       setState(() {
//         for (var item in controllers.isCustomerList) {
//           item["isSelect"] = false;
//         }
//         apiService.prospectsList.clear();
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
//     _focusNode.dispose();
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
//                 padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
//                 child: Column(
//                   children: [
//                     // Header Section
//                     HeaderSection(
//                       title: "Customers",
//                       subtitle: "View all of your Customer Information",
//                       list: controllers.allCustomerLeadFuture,
//                     ),
//                     // Filter Section
//                     FilterSection(
//                       //Santhiya
//                       leadIndex: "0",
//                       itemCount: controllers.paginatedCustomerLeads.length,
//                       focusNode: _focusNode,
//                       title: "Customers",
//                       leadFuture: controllers.allCustomerLeadFuture,
//                       count: controllers.allCustomerLength.value,
//                       itemList: apiService.prospectsList,
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
//                                           await apiService.deleteCustomersAPI(context, apiService.prospectsList);
//                                           setState(() {
//                                             apiService.prospectsList.clear();
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
//                         mailUtils.bulkEmailDialog(_focusNode, list: apiService.prospectsList);
//                       },
//                       onPromote: () {
//                       },
//                       onDisqualify: () {
//                         showDialog(
//                             context: context,
//                             barrierDismissible: true,
//                             builder: (context) {
//                               return AlertDialog(
//                                 content: CustomText(
//                                   text: "Are you sure disqualify this customers?",
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
//                                         callback: (){
//                                           _focusNode.requestFocus();
//                                           apiService.disqualifiedCustomersAPI(context, apiService.prospectsList);
//                                         },
//                                         height: 35,
//                                         isLoading: true,
//                                         backgroundColor:
//                                         colorsConst.primary,
//                                         radius: 2,
//                                         width: 100,
//                                         controller: controllers.productCtr,
//                                         isImage: false,
//                                         text: "No Matches",
//                                         textColor:Colors.white,
//                                       ),
//                                       5.width
//                                     ],
//                                   ),
//                                 ],
//                               );
//                             });
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
//                         //                 callback: () async {
//                         //                   _focusNode.requestFocus();
//                         //                   await apiService.insertQualifiedAPI(context,apiService.prospectsList);
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
//                             String selectedStage="Qualified";
//                             bool isEdit=false;
//                             TextEditingController reasonController = TextEditingController();
//                             // setState(() {
//                             //   selectedStage = "Qualified";
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
//                                             "Qualified",
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
//                                             String status="0";
//                                             if (selectedStage == "Suspects") {
//                                               status="1";
//                                             } else if (selectedStage == "Prospects") {
//                                               status="2";
//                                             } else if (selectedStage == "Qualified") {
//                                               status="3";
//                                             }
//                                             await apiService.updateLeadStatus(context, apiService.prospectsList,status);
//                                             setState(() {
//                                               apiService.prospectsList.clear();
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
//                         controllers.searchCustomers.value = value.toString();
//                       },
//                       onSelectMonth: () {
//                         controllers.selectMonth(
//                             context, controllers.selectedCustomerSortBy, controllers.selectedQPMonth);
//                       },
//                       selectedMonth: controllers.selectedQPMonth,
//                       selectedSortBy: controllers.selectedCustomerSortBy,
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
//                                 isAllSelected: apiService.prospectsList.isEmpty?false:controllers.isAllSelected.value,
//                                   onSelectAll: (value) {
//                                     controllers.isAllSelected.value = value ?? false;
//                                     if (value == true) {
//                                       apiService.prospectsList.clear();
//                                       for (var item in controllers.isCustomerList) {
//                                         item["isSelect"] = true;
//                                         apiService.prospectsList.add({
//                                           "lead_id": item["lead_id"].toString(),
//                                           "user_id": controllers.storage.read("id").toString(),
//                                           "rating": item["rating"] ?? "Warm",
//                                           "cos_id": controllers.storage.read("cos_id").toString(),
//                                           "mail_id": (item["email_id"] ?? "").toString(),
//                                         });
//                                       }
//                                     } else {
//                                       for (var item in controllers.isCustomerList) {
//                                         item["isSelect"] = false;
//                                       }
//                                       apiService.prospectsList.clear();
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
//                                   child: Obx(() => controllers.paginatedCustomerLeads.isNotEmpty?
//                                   ScrollConfiguration(
//                                     behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
//                                     child: ListView.builder(
//                                       controller: _leftController,
//                                       shrinkWrap: true,
//                                       physics: const ScrollPhysics(),
//                                       itemCount: controllers.paginatedCustomerLeads.length,
//                                       itemBuilder: (context, index) {
//                                         final billing_data = controllers.paginatedCustomerLeads[index];
//                                         return Obx(()=>LeftLeadTile(
//                                           leadIndex: "0",
//                                           pageName: "Customers",
//                                           showCheckbox: true,
//                                           saveValue: controllers.isCustomerList[index]["isSelect"],
//                                             onChanged: (value) {
//                                               setState(() {
//                                                 controllers.isAllSelected.value = false;
//                                                 final isSelected = value ?? false;
//                                                 final leadId = billing_data.userId?.toString() ?? "";
//                                                 controllers.isCustomerList[index]["isSelect"] = isSelected;
//                                                 if (isSelected) {
//                                                   final exists = apiService.prospectsList.any(
//                                                         (e) => e["lead_id"] == leadId,
//                                                   );
//                                                   if (!exists) {
//                                                     apiService.prospectsList.add({
//                                                       "lead_id": leadId,
//                                                       "user_id": controllers.storage.read("id").toString(),
//                                                       "rating": billing_data.rating ?? "Warm",
//                                                       "cos_id": controllers.storage.read("cos_id").toString(),
//                                                       "mail_id": billing_data.email ?? "",
//                                                     });
//                                                   }
//                                                 } else {
//                                                   apiService.prospectsList.removeWhere(
//                                                         (e) => e["lead_id"] == leadId,
//                                                   );
//                                                 }
//                                               });
//                                             },
//                                             visitType: billing_data.visitType.toString(),
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
//                                       child: Obx(() => controllers.isLead.value == false
//                                           ? Container(
//                                           alignment: Alignment.centerLeft,
//                                           width: MediaQuery.of(context).size.width,
//                                           height: MediaQuery.of(context).size.height,
//                                           padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
//                                           child: const Center(child: CircularProgressIndicator()))
//                                           : controllers.paginatedCustomerLeads.isNotEmpty?
//                                       ListView.builder(
//                                         controller: _rightController,
//                                         shrinkWrap: true,
//                                         physics: const ScrollPhysics(),
//                                         itemCount: controllers.paginatedCustomerLeads.length,
//                                         itemBuilder: (context, index) {
//                                           final billing_data = controllers.paginatedCustomerLeads[index];
//                                           return Obx(()=>CustomLeadTile(
//                                             pageName: "Customers",
//                                             showCheckbox: false,
//                                             saveValue: controllers.isCustomerList[index]["isSelect"],
//                                             onChanged: (value){
//                                               setState(() {
//                                                 if(controllers.isCustomerList[index]["isSelect"]==true){
//                                                   controllers.isCustomerList[index]["isSelect"]=false;
//                                                   var i=apiService.prospectsList.indexWhere((element) => element["lead_id"]==billing_data.userId.toString());
//                                                   apiService.prospectsList.removeAt(i);
//                                                 }else{
//                                                   controllers.isCustomerList[index]["isSelect"]=true;
//                                                   apiService.prospectsList.add({
//                                                     "lead_id":billing_data.userId.toString(),
//                                                     "user_id":controllers.storage.read("id"),
//                                                     "rating":billing_data.rating ?? "Warm",
//                                                     "cos_id":controllers.storage.read("cos_id"),
//                                                     "mail_id":billing_data.email.toString().split("||")[0]
//                                                   });
//                                                 }
//                                               });
//                                             },
//                                             visitType: billing_data.visitType.toString(),
//                                             detailsOfServiceReq: billing_data.detailsOfServiceRequired.toString(),
//                                             statusUpdate: billing_data.statusUpdate.toString(),
//                                             index: index,
//                                             points: billing_data.points.toString(),
//                                             quotationStatus: billing_data.quotationStatus.toString(),
//                                             quotationRequired: billing_data.quotationRequired.toString(),
//                                             productDiscussion: billing_data.productDiscussion.toString(),
//                                             discussionPoint: billing_data.discussionPoint.toString(),
//                                             notes: billing_data.notes.toString(),
//                                             linkedin: billing_data.linkedin,
//                                             x: billing_data.x,
//                                             name: billing_data.firstname.toString().split("||")[0],
//                                             mobileNumber: billing_data.mobileNumber.toString().split("||")[0],
//                                             email: billing_data.email.toString().split("||")[0],
//                                             companyName: billing_data.companyName.toString(),
//                                             mainWhatsApp: billing_data.whatsapp.toString().split("||")[0],
//                                             emailUpdate: billing_data.quotationUpdate.toString(),
//                                             id: billing_data.userId.toString(),
//                                             status: billing_data.leadStatus ?? "UnQualified",
//                                             rating: billing_data.rating ?? "Warm",
//                                             mainName: billing_data.firstname.toString().split("||")[0],
//                                             mainMobile: billing_data.mobileNumber.toString().split("||")[0],
//                                             mainEmail: billing_data.email.toString().split("||")[0],
//                                             title: "",
//                                             whatsappNumber: billing_data.whatsapp.toString().split("||")[0],
//                                             mainTitle: "",
//                                             addressId: billing_data.addressId ?? "",
//                                             companyWebsite: billing_data.companyWebsite ?? "",
//                                             companyNumber: billing_data.companyNumber ?? "",
//                                             companyEmail: billing_data.companyEmail ?? "",
//                                             industry: billing_data.industry ?? "",
//                                             productServices: billing_data.product ?? "",
//                                             source:billing_data.source ?? "",
//                                             owner: billing_data.owner ?? "",
//                                             timelineDecision: "",
//                                             serviceInterest: "",
//                                             description: "",
//                                             leadStatus: billing_data.leadStatus ?? "",
//                                             active: billing_data.active ?? "",
//                                             addressLine1: billing_data.doorNo ?? "",
//                                             addressLine2: billing_data.landmark1 ?? "",
//                                             area: billing_data.area ?? "",
//                                             city: billing_data.city ?? "",
//                                             state: billing_data.state ?? "",
//                                             country: billing_data.country ?? "",
//                                             pinCode: billing_data.pincode ?? "",
//                                             prospectEnrollmentDate: billing_data.prospectEnrollmentDate ?? "",
//                                             expectedConvertionDate: billing_data.expectedConvertionDate ?? "",
//                                             numOfHeadcount: billing_data.numOfHeadcount ?? "",
//                                             expectedBillingValue: billing_data.expectedBillingValue ?? "",
//                                             arpuValue: billing_data.arpuValue ?? "",
//                                             updatedTs: billing_data.updatedTs ?? "",
//                                             sourceDetails: billing_data.sourceDetails ?? "",
//                                           ));
//                                         },
//                                       ):
//                                      CustomNoData()
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
