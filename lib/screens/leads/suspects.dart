import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_search_textfield.dart';
import 'package:fullcomm_crm/components/delete_button.dart';
import 'package:fullcomm_crm/components/promote_button.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constant/api.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import 'add_lead.dart';

class Suspects extends StatefulWidget {
  const Suspects({super.key});

  @override
  State<Suspects> createState() => _SuspectsState();
}

class _SuspectsState extends State<Suspects> {
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  late FocusNode _focusNode;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

    });
    Future.delayed(Duration.zero, () {
      controllers.selectedIndex.value = 1;
      controllers.groupController.selectIndex(0);
      setState(() {
        apiService.prospectsList = [];
        apiService.prospectsList.clear();
        controllers.search.clear();
      });
      controllers.searchQuery.value = "";
    });
  }


  void _showSortPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // optional: no dark background
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.only(top: 200, right: 200),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: colorsConst.secondary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => RadioListTile<String>(
                    title: CustomText(
                      text: "Today",
                      colors: colorsConst.textColor,
                    ),
                    value: "Today",
                    groupValue: controllers.selectedProspectSortBy.value,
                    onChanged: (value) {
                      controllers.selectedProspectSortBy.value = value!;
                      Navigator.pop(context); // close popup
                    },
                    activeColor: colorsConst.third,
                  )),
                  Obx(() => RadioListTile<String>(
                    title: CustomText(
                        text: "Last 7 Days", colors: colorsConst.textColor),
                    value: "Last 7 Days",
                    groupValue: controllers.selectedProspectSortBy.value,
                    onChanged: (value) {
                      controllers.selectedProspectSortBy.value = value!;
                      Navigator.pop(context);
                    },
                    activeColor: colorsConst.third,
                  )),
                  Obx(() => RadioListTile<String>(
                    title: CustomText(
                        text: "Last 30 Days", colors: colorsConst.textColor),
                    value: "Last 30 Days",
                    groupValue: controllers.selectedProspectSortBy.value,
                    onChanged: (value) {
                      controllers.selectedProspectSortBy.value = value!;
                      Navigator.pop(context);
                    },
                    activeColor: colorsConst.third,
                  )),
                  Obx(() => RadioListTile<String>(
                    title:
                    CustomText(text: "All", colors: colorsConst.textColor),
                    value: "All",
                    groupValue: controllers.selectedProspectSortBy.value,
                    onChanged: (value) {
                      controllers.selectedProspectSortBy.value = "";
                      Navigator.pop(context);
                    },
                    activeColor: colorsConst.third,
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          controllers.selectedProspectSortBy.value = "";
                          Navigator.pop(context);
                        },
                        child: const CustomText(text: "Clear", colors: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: colorsConst.primary,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            utils.sideBarFunction(context),
            Obx(()=>Container(
              width: controllers.isLeftOpen.value==false&&controllers.isRightOpen.value==false?MediaQuery.of(context).size.width-200:MediaQuery.of(context).size.width - 445,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(()=>  CustomText(
                            text: "New Leads - ${controllers.leadCategoryList[0]["value"]}",
                            colors: colorsConst.textColor,
                            size: 25,
                            isBold: true,
                          ),),
                          10.height,
                          Obx(()=>  CustomText(
                            text: "View all of your ${controllers.leadCategoryList[0]["value"]} Information",
                            colors: colorsConst.textColor,
                            size: 14,
                          ),),
                        ],
                      ),
                      Row(
                        children: [
                          CustomLoadingButton(
                            callback: () async {
                              SharedPreferences sharedPref = await SharedPreferences.getInstance();
                              setState(() {
                                final whatsApp = sharedPref.getString("leadWhatsApp") ?? "";
                                final companyName = sharedPref.getString("leadCoName") ?? "";
                                final companyPhone = sharedPref.getString("leadCoMobile") ?? "";
                                final webSite = sharedPref.getString("leadWebsite") ?? "";
                                final coEmail = sharedPref.getString("leadCoEmail") ?? "";
                                final product = sharedPref.getString("leadProduct") ?? "";
                                final ownerName = sharedPref.getString("leadOwnerName") ?? "";
                                final industry = sharedPref.getString("industry");
                                final source = sharedPref.getString("source");
                                final status = sharedPref.getString("status");
                                final rating = sharedPref.getString("rating");
                                final service = sharedPref.getString("service");
                                final doorNo = sharedPref.getString("leadDNo") ?? "";
                                final street = sharedPref.getString("leadStreet") ?? "";
                                final area = sharedPref.getString("leadArea") ?? "";
                                final city = sharedPref.getString("leadCity") ?? "";
                                final pinCode = sharedPref.getString("leadPinCode") ?? "";
                                final budget = sharedPref.getString("budget") ?? "";
                                final state = sharedPref.getString("leadState") ?? "Tamil Nadu";
                                final country = sharedPref.getString("leadCountry") ?? "India";
                                final twitter = sharedPref.getString("leadX") ?? "";
                                final linkedin = sharedPref.getString("leadLinkedin") ?? "";
                                final time = sharedPref.getString("leadTime") ?? "";
                                final leadDescription = sharedPref.getString("leadDescription") ?? "";
                                final leadPersonalCount = sharedPref.getInt("leadCount") ?? 1;

                                controllers.leadPersonalItems.value = leadPersonalCount;
                                controllers.isMainPersonList.value = [];
                                controllers.isCoMobileNumberList.value = [];
                                for (int i = 0; i < leadPersonalCount; i++) {
                                  controllers.isMainPersonList.add(false);
                                  controllers.isCoMobileNumberList.add(false);
                                  // final name = sharedPref.getString("leadName$i") ?? "";
                                  // final email = sharedPref.getString("leadEmail$i") ?? "";
                                  // final title = sharedPref.getString("leadTitle$i") ?? "";
                                  // controllers.leadNameCrt[i].text = name;
                                  // final mobile = sharedPref.getString("leadMobileNumber$i") ?? "";
                                  // controllers.leadMobileCrt[i].text = mobile.toString();
                                  // controllers.leadEmailCrt[i].text  = email.toString();
                                  // controllers.leadTitleCrt[i].text  = title.toString();
                                  // controllers.leadWhatsCrt[i].text  = whatsApp.toString();
                                }
                                // controllers.leadFieldName[0].text = "";
                                // controllers.leadFieldValue[0].text = "";
                                controllers.leadCoNameCrt.text = companyName.toString();
                                controllers.leadCoMobileCrt.text = companyPhone.toString();
                                controllers.leadWebsite.text = webSite.toString();
                                controllers.leadCoEmailCrt.text = coEmail.toString();
                                controllers.leadProduct.text = product.toString();
                                controllers.leadOwnerNameCrt.text = ownerName.toString();
                                controllers.industry = industry;
                                controllers.source = source;
                                controllers.status = status;
                                controllers.rating = rating;
                                controllers.service = service;
                                controllers.doorNumberController.text = doorNo.toString();
                                controllers.leadDescription.text = leadDescription.toString();
                                controllers.leadTime.text = time.toString();
                                controllers.budgetCrt.text = budget.toString();
                                controllers.streetNameController.text = street.toString();
                                controllers.areaController.text = area.toString();
                                controllers.cityController.text = city.toString();
                                controllers.pinCodeController.text = pinCode.toString();
                                controllers.states = state.toString();
                                controllers.countryController.text = country.toString();
                                controllers.leadXCrt.text = twitter.toString();
                                controllers.leadLinkedinCrt.text = linkedin.toString();
                                controllers.selectPinCodeList = controllers.pinCodeList
                                    .where((location) => location["STATE"] ==
                                            controllers.selectedState && location["DISTRICT"] ==
                                            controllers.selectedCity)
                                    .map((location) => location["PINCODE"].toString())
                                    .toList();
                              });
                              Get.to(const AddLead(), duration: Duration.zero);
                            },
                            isLoading: false,
                            height: 35,
                            backgroundColor: colorsConst.third,
                            radius: 2,
                            width: 100,
                            isImage: false,
                            text: "Add Lead",
                            textColor: Colors.black,
                          ),
                          15.width,
                          CustomLoadingButton(
                            callback: () {
                              utils.showImportDialog(context);
                            },
                            height: 35,
                            isLoading: false,
                            backgroundColor: colorsConst.third,
                            radius: 2,
                            width: 100,
                            isImage: false,
                            text: "Import",
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                  10.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(()=>GroupButton(
                        //isRadio: true,
                        controller: controllers.groupController,
                        options: GroupButtonOptions(
                          //borderRadius: BorderRadius.circular(20),
                            spacing: 1,
                            elevation: 0,
                            selectedTextStyle:
                            TextStyle(color: colorsConst.third),
                            selectedBorderColor: Colors.transparent,
                            selectedColor: Colors.transparent,
                            unselectedBorderColor: Colors.transparent,
                            unselectedColor: Colors.transparent,
                            unselectedTextStyle:
                            TextStyle(color: colorsConst.textColor)),
                        onSelected: (name, index, isSelected) async {
                          controllers.employeeHeading.value = name;
                        },
                        // buttons:["All ${controllers.leadCategoryList.isEmpty?"":controllers.leadCategoryList[0]["value"]} ${controllers.allNewLeadsLength.value}",
                        //   "Contacted 10","Nurturing 10","Qualified 10","UnQualified 10"],
                        buttons: [
                          "All ${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[0]["value"]} ${controllers.allNewLeadsLength.value}"
                        ],
                      ),),
                      Row(
                        children: [
                          // IconButton(
                          //     onPressed: () {},
                          //     icon: SvgPicture.asset("assets/images/call.svg")),
                          // 5.width,
                          DeleteButton(
                            leadList: apiService.prospectsList,
                            callback: () {
                              apiService.deleteCustomersAPI(context,apiService.prospectsList);
                            },
                          ),
                          5.width,
                          Obx(()=>   PromoteButton(
                            headText: controllers.leadCategoryList[1]["value"],
                            leadList: apiService.prospectsList,
                            callback: () {
                              apiService.insertProspectsAPI(context,apiService.prospectsList);
                            },
                            text: "Promote",
                          ),),
                          // Tooltip(
                          //   message: "Promote To ${controllers.leadCategoryList[1]["value"]}",
                          //   child: InkWell(
                          //     onTap: () {
                          //       if (apiService.prospectsList.isEmpty) {
                          //         apiService.errorDialog(
                          //             context, "Please select lead");
                          //         //utils.snackBar(context: Get.context!, msg: "Please select lead",color:Colors.green,);
                          //       } else {
                          //         showDialog(
                          //             context: context,
                          //             barrierDismissible: false,
                          //             builder: (context) {
                          //               return AlertDialog(
                          //                 backgroundColor:
                          //                     colorsConst.secondary,
                          //                 content: CustomText(
                          //                   text: "Are you moving to the next level?",
                          //                   size: 16,
                          //                   isBold: true,
                          //                   colors: colorsConst.textColor,
                          //                 ),
                          //                 actions: [
                          //                   Row(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment.end,
                          //                     children: [
                          //                       Container(
                          //                         decoration: BoxDecoration(
                          //                             border: Border.all(
                          //                                 color: colorsConst.third),
                          //                             color: colorsConst.primary),
                          //                         width: 80,
                          //                         height: 25,
                          //                         child: ElevatedButton(
                          //                             style: ElevatedButton.styleFrom(
                          //                               shape: const RoundedRectangleBorder(
                          //                                       borderRadius: BorderRadius.zero),
                          //                               backgroundColor: colorsConst.primary,
                          //                             ),
                          //                             onPressed: () {
                          //                               Navigator.pop(context);
                          //                             },
                          //                             child: const CustomText(
                          //                               text: "Cancel",
                          //                               colors: Colors.white,
                          //                               size: 14,
                          //                             )),
                          //                       ),
                          //                       10.width,
                          //                       CustomLoadingButton(
                          //                         callback: () {
                          //                           apiService
                          //                               .insertProspectsAPI(
                          //                                   context);
                          //                         },
                          //                         height: 35,
                          //                         isLoading: true,
                          //                         backgroundColor:
                          //                             colorsConst.third,
                          //                         radius: 2,
                          //                         width: 80,
                          //                         controller:
                          //                             controllers.productCtr,
                          //                         isImage: false,
                          //                         text: "Move",
                          //                         textColor:
                          //                             colorsConst.primary,
                          //                       ),
                          //                       5.width
                          //                     ],
                          //                   ),
                          //                 ],
                          //               );
                          //             });
                          //       }
                          //     },
                          //     child: Container(
                          //       width: 100,
                          //       alignment: Alignment.center,
                          //       decoration: BoxDecoration(
                          //           color: colorsConst.secondary,
                          //           borderRadius: BorderRadius.circular(10)),
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Text(
                          //             "Promote",
                          //             style: TextStyle(
                          //               color: colorsConst.textColor,
                          //               fontSize: 12,
                          //               fontWeight: FontWeight.bold,
                          //             ),
                          //           ),
                          //           IconButton(
                          //               tooltip:
                          //                   "Promote To ${controllers.leadCategoryList[1]["value"]}",
                          //               onPressed: () {
                          //                 if (apiService
                          //                     .prospectsList.isEmpty) {
                          //                   apiService.errorDialog(
                          //                       context, "Please select lead");
                          //                   //utils.snackBar(context: Get.context!, msg: "Please select lead",color:Colors.green,);
                          //                 } else {
                          //                   showDialog(
                          //                       context: context,
                          //                       barrierDismissible: false,
                          //                       builder: (context) {
                          //                         return AlertDialog(
                          //                           backgroundColor:
                          //                               colorsConst.secondary,
                          //                           content: CustomText(
                          //                             text:
                          //                                 "Are you moving to the next level?",
                          //                             size: 16,
                          //                             isBold: true,
                          //                             colors:
                          //                                 colorsConst.textColor,
                          //                           ),
                          //                           actions: [
                          //                             Row(
                          //                               mainAxisAlignment:
                          //                                   MainAxisAlignment
                          //                                       .end,
                          //                               children: [
                          //                                 Container(
                          //                                   decoration: BoxDecoration(
                          //                                       border: Border.all(
                          //                                           color: colorsConst
                          //                                               .third),
                          //                                       color: colorsConst
                          //                                           .primary),
                          //                                   width: 80,
                          //                                   height: 25,
                          //                                   child:
                          //                                       ElevatedButton(
                          //                                           style: ElevatedButton
                          //                                               .styleFrom(
                          //                                             shape: const RoundedRectangleBorder(
                          //                                                 borderRadius:
                          //                                                     BorderRadius.zero),
                          //                                             backgroundColor:
                          //                                                 colorsConst
                          //                                                     .primary,
                          //                                           ),
                          //                                           onPressed: () {
                          //                                             Navigator.pop(context);
                          //                                           },
                          //                                           child: const CustomText(
                          //                                             text: "Cancel",
                          //                                             colors: Colors.white,
                          //                                             size: 14,
                          //                                           )),
                          //                                 ),
                          //                                 10.width,
                          //                                 CustomLoadingButton(
                          //                                   callback: () {
                          //                                     apiService
                          //                                         .insertProspectsAPI(
                          //                                             context);
                          //                                   },
                          //                                   height: 35,
                          //                                   isLoading: true,
                          //                                   backgroundColor:
                          //                                       colorsConst
                          //                                           .third,
                          //                                   radius: 2,
                          //                                   width: 80,
                          //                                   controller:
                          //                                       controllers
                          //                                           .productCtr,
                          //                                   isImage: false,
                          //                                   text: "Move",
                          //                                   textColor:
                          //                                       colorsConst
                          //                                           .primary,
                          //                                 ),
                          //                                 5.width
                          //                               ],
                          //                             ),
                          //                           ],
                          //                         );
                          //                       });
                          //                 }
                          //               },
                          //               icon: SvgPicture.asset(
                          //                   "assets/images/move.svg")),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          5.width
                        ],
                      )
                    ],
                  ),
                  10.height,
                  Divider(
                    thickness: 2,
                    color: colorsConst.secondary,
                  ),
                  10.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomSearchTextField(
                        hintText: "Search Name, Company, Mobile No.",
                        controller: controllers.search,
                        onChanged: (value){
                        controllers.searchQuery.value = value.toString();
                        },
                      ),
                      Row(
                        children: [
                          // SizedBox(
                          //   height: 40,
                          //   child: ElevatedButton(
                          //       style: ElevatedButton.styleFrom(
                          //           backgroundColor: colorsConst.secondary,
                          //           shape: RoundedRectangleBorder(
                          //               borderRadius:
                          //               BorderRadius.circular(5))),
                          //       onPressed: () {},
                          //       child: Row(
                          //         children: [
                          //           SvgPicture.asset(
                          //               "assets/images/filter.svg"),
                          //           5.width,
                          //           CustomText(
                          //             text: "Filter",
                          //             colors: colorsConst.textColor,
                          //             size: 15,
                          //           ),
                          //         ],
                          //       )
                          //       ),
                          // ),
                          // CompositedTransformTarget(
                          //   link: _layerLink,
                          //   child: SizedBox(
                          //     height: 40,
                          //     child: ElevatedButton(
                          //             style: ElevatedButton.styleFrom(
                          //                 backgroundColor: colorsConst.secondary,
                          //                 shape: RoundedRectangleBorder(
                          //                     borderRadius:
                          //                     BorderRadius.circular(5))),
                          //       onPressed: _showFilterPopup,
                          //             child: Row(
                          //               children: [
                          //                 SvgPicture.asset(
                          //                     "assets/images/filter.svg"),
                          //                 5.width,
                          //                 CustomText(
                          //                   text: "Filter",
                          //                   colors: colorsConst.textColor,
                          //                   size: 15,
                          //                 ),
                          //               ],
                          //             )
                          //     ),
                          //   ),
                          // ),
                          10.width,
                          PopupMenuButton<String>(
                            offset: const Offset(0, 40), // position below button
                            color: colorsConst.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onSelected: (value) {
                              controllers.selectedProspectSortBy.value = value;
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: "Today",
                                child: Text("Today", style: TextStyle(color: colorsConst.textColor)),
                              ),
                              PopupMenuItem(
                                value: "Last 7 Days",
                                child: Text("Last 7 Days", style: TextStyle(color: colorsConst.textColor)),
                              ),
                              PopupMenuItem(
                                value: "Last 30 Days",
                                child: Text("Last 30 Days", style: TextStyle(color: colorsConst.textColor)),
                              ),
                              PopupMenuItem(
                                value: "All",
                                child: Text("All", style: TextStyle(color: colorsConst.textColor)),
                              ),
                            ],
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorsConst.secondary,
                              ),
                              onPressed: null, // must be null when using PopupMenuButton as child
                              child: Row(
                                children: [
                                  SvgPicture.asset("assets/images/sort.svg"),
                                  const SizedBox(width: 6),
                                  Obx(()=> CustomText(
                                      text: controllers.selectedProspectSortBy.value.isEmpty?"Sort by":controllers.selectedProspectSortBy.value,
                                      colors: colorsConst.textColor,
                                      size: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     _showSortPopup(context);
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: colorsConst.secondary,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(5),
                          //     ),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       SvgPicture.asset("assets/images/sort.svg"),
                          //       const SizedBox(width: 6),
                          //       CustomText(
                          //         text: "Sort by",
                          //         colors: colorsConst.textColor,
                          //         size: 15,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // CompositedTransformTarget(
                          //   link: _dateLayerLink,
                          //   child: SizedBox(
                          //     height: 40,
                          //     child: ElevatedButton(
                          //         style: ElevatedButton.styleFrom(
                          //             backgroundColor: colorsConst.secondary,
                          //             shape: RoundedRectangleBorder(
                          //                 borderRadius:
                          //                 BorderRadius.circular(5))),
                          //         onPressed: _showDateWisePopup,
                          //         child: Row(
                          //           children: [
                          //             SvgPicture.asset("assets/images/sort.svg"),
                          //             6.width,
                          //             CustomText(
                          //               text: "Sort by",
                          //               colors: colorsConst.textColor,
                          //               size: 15,
                          //             ),
                          //           ],
                          //         )),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  10.height,

                  // Container(
                  //   height: 60,
                  //   decoration: BoxDecoration(
                  //     color: colorsConst.secondary,
                  //     borderRadius: const BorderRadius.only(
                  //       topLeft: Radius.circular(10),
                  //       topRight: Radius.circular(10)
                  //     )
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children:[
                  //       Container(
                  //         width:minPartWidth/21,
                  //         alignment: Alignment.center,
                  //         child: const CustomText(text: "",),
                  //         // child: CustomCheckBox(
                  //         //     text: "",
                  //         //     onChanged: (value){
                  //         //       controllers.isMainPerson.value=!controllers.isMainPerson.value;
                  //         //     },
                  //         //     saveValue: controllers.isMainPerson.value),
                  //       ),
                  //       SizedBox(
                  //         width: minPartWidth / 11,
                  //         child: Center(
                  //           child: CustomText(
                  //             textAlign: TextAlign.start,
                  //             text:"Last Quotation",
                  //             size: 15,
                  //             colors: colorsConst.textColor,
                  //             isBold: true,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width:adjustedPartWidth,
                  //         child: CustomText(
                  //           textAlign: TextAlign.start,
                  //           text:"Name",
                  //           size: 15,
                  //           colors: colorsConst.textColor,
                  //           isBold: true,
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width:adjustedPartWidth,
                  //         child: CustomText(
                  //           textAlign: TextAlign.start,
                  //           text:"Mobile no.",
                  //           size: 15,
                  //           colors: colorsConst.textColor,
                  //           isBold: true,
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width:adjustedPartWidth,
                  //         child: CustomText(
                  //           textAlign: TextAlign.start,
                  //           text:"Email",
                  //           size: 15,
                  //           colors: colorsConst.textColor,
                  //           isBold: true,
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width:adjustedPartWidth,
                  //         child: CustomText(
                  //           textAlign: TextAlign.start,
                  //           text:"Company Name",
                  //           size: 15,
                  //           colors: colorsConst.textColor,
                  //           isBold: true,
                  //         ),
                  //       ),
                  //
                  //       SizedBox(
                  //         width: minPartWidth / 11,
                  //         child: Center(
                  //           child: CustomText(
                  //             textAlign: TextAlign.start,
                  //             text:"Status",
                  //             size: 15,
                  //             colors: colorsConst.textColor,
                  //             isBold: true,
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(
                  //         width: minPartWidth / 11,
                  //         child: Center(
                  //           child: CustomText(
                  //             text:"Rating",
                  //             size: 15,
                  //             colors: colorsConst.textColor,
                  //             isBold: true,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(1.5),
                      4: FlexColumnWidth(2.5),
                      5: FlexColumnWidth(2),
                      6: FlexColumnWidth(3),
                      7: FlexColumnWidth(2),
                      8: FlexColumnWidth(2),
                      9: FlexColumnWidth(3),
                      // 9: FlexColumnWidth(3),
                      // 10: FlexColumnWidth(3),
                    },
                    // border:TableBorder.all(
                    //     color: colorsConst.primary,
                    //     width: 5
                    // ),
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                              color: colorsConst.secondary,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          children: [
                            Row(
                              children: [
                                5.width,
                                Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: Obx(
                                        () => CustomCheckBox(
                                        text: "",
                                        onChanged: (value) {
                                          if (controllers.isAllSelected.value == true) {
                                            controllers.isAllSelected.value = false;
                                            for (int j = 0;
                                            j < controllers.isNewLeadList.length;
                                            j++) {
                                              controllers.isNewLeadList[j]
                                              ["isSelect"] = false;
                                              setState(() {
                                                var i = apiService.prospectsList
                                                    .indexWhere((element) =>
                                                element["lead_id"] == controllers.isNewLeadList[j]["lead_id"]);
                                                apiService.prospectsList.removeAt(i);
                                              });
                                            }
                                          } else {
                                            controllers.isAllSelected.value = true;
                                            setState(() {
                                              for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                                controllers.isNewLeadList[j]["isSelect"] = true;
                                                apiService.prospectsList.add(
                                                    {
                                                      "lead_id": controllers.isNewLeadList[j]["lead_id"],
                                                      "user_id": controllers.storage.read("id"),
                                                      "rating": controllers.isNewLeadList[j]["rating"],
                                                      "cos_id": cosId,
                                                    });
                                                print(apiService.prospectsList);
                                              }
                                            });
                                          }
                                          //controllers.isMainPerson.value=!controllers.isMainPerson.value;
                                        },
                                        saveValue: controllers.isAllSelected.value),
                                  ),
                                ),
                              ],
                            ),
                            // CustomText(
                            //   textAlign: TextAlign.center,
                            //   text: "\nLast Comment\n",
                            //   size: 15,
                            //   isBold: true,
                            //   colors: colorsConst.textColor,
                            // ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nName\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nMobile No.\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            // CustomText(
                            //   textAlign: TextAlign.center,
                            //   text: "\nEmail\n",
                            //   size: 15,
                            //   isBold: true,
                            //   colors: colorsConst.textColor,
                            // ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nCity\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nCompany Name\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            // CustomText(
                            //   textAlign: TextAlign.center,
                            //   text: "\nStatus\n",
                            //   size: 15,
                            //   isBold: true,
                            //   colors: colorsConst.textColor,
                            // ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nSource\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                textAlign: TextAlign.center,
                                text: "Details of Service\nRequired",
                                size: 15,
                                isBold: true,
                                colors: colorsConst.textColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                textAlign: TextAlign.center,
                                text: "Source Of \nProspect",
                                size: 15,
                                isBold: true,
                                colors: colorsConst.textColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                textAlign: TextAlign.center,
                                text: "Added\nDateTime",
                                size: 15,
                                isBold: true,
                                colors: colorsConst.textColor,
                              ),
                            ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nStatus Update\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            // CustomText(
                            //   textAlign: TextAlign.center,
                            //   text: "\nExpected Conversion Date\n",
                            //   size: 15,
                            //   isBold: true,
                            //   colors: colorsConst.textColor,
                            // ),
                            // CustomText(
                            //   textAlign: TextAlign.center,
                            //   text: "\nProspect Enrollment Date\n",
                            //   size: 15,
                            //   isBold: true,
                            //   colors: colorsConst.textColor,
                            // ),
                          ]),
                    ],
                  ),
                  Expanded(
                    //height: MediaQuery.of(context).size.height/1.5,
                    child: Obx(
                          () => controllers.isLead.value == false
                          ? const Center(child: CircularProgressIndicator())
                          : controllers.paginatedLeads.isNotEmpty?
                          GestureDetector(
                            onTap: () {
                              _focusNode.requestFocus();
                            },
                            child: KeyboardListener(
                              focusNode: _focusNode,
                              autofocus: true,
                              onKeyEvent: (event) {
                                if (event is RawKeyDownEvent) {
                                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                    _controller.animateTo(
                                      _controller.offset + 100,
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                    _controller.animateTo(
                                      _controller.offset - 100,
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                }
                              },
                              child:  ScrollbarTheme(
                                data: ScrollbarThemeData(
                                  thumbColor: MaterialStateProperty.all(const Color(0xff2C3557)),
                                  trackColor: MaterialStateProperty.all(const Color(0xff465271)),
                                  radius: const Radius.circular(10),
                                  thickness: MaterialStateProperty.all(20),
                                ),
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  thickness: 10,
                                  trackVisibility: true,
                                  radius: const Radius.circular(10),
                                  controller: _controller,
                                  child: ListView.builder(
                                    controller: _controller,
                                    shrinkWrap: true,
                                    physics: const ScrollPhysics(),
                                    itemCount: controllers.paginatedLeads.length,
                                    itemBuilder: (context, index) {
                                      final data = controllers.paginatedLeads[index];
                                      return CustomLeadTile(
                                        visitType: data.visitType.toString(),
                                        detailsOfServiceReq: data.detailsOfServiceRequired.toString(),
                                        statusUpdate: data.statusUpdate.toString(),
                                        index: index,
                                        points: data.points.toString(),
                                        quotationStatus: data.quotationStatus.toString(),
                                        quotationRequired: data.quotationRequired.toString(),
                                        productDiscussion: data.productDiscussion.toString(),
                                        discussionPoint: data.discussionPoint.toString(),
                                        notes: data.notes.toString(),
                                        linkedin: "",
                                        x: "",
                                        name: data.firstname.toString().split("||")[0],
                                        mobileNumber: data.mobileNumber.toString().split("||")[0],
                                        email: data.emailId.toString().split("||")[0],
                                        companyName: data.companyName.toString(),
                                        mainWhatsApp: data.mobileNumber.toString().split("||")[0],
                                        emailUpdate: data.quotationUpdate.toString(),
                                        id: data.userId.toString(),
                                        status: data.leadStatus ?? "UnQualified",
                                        rating: data.rating ?? "Warm",
                                        mainName: data.firstname.toString().split("||")[0],
                                        mainMobile: data.mobileNumber.toString().split("||")[0],
                                        mainEmail: data.emailId.toString().split("||")[0],
                                        title: "",
                                        whatsappNumber: data.mobileNumber.toString().split("||")[0],
                                        mainTitle: "",
                                        addressId: data.addressId ?? "",
                                        companyWebsite: "",
                                        companyNumber: "",
                                        companyEmail: "",
                                        industry: "",
                                        productServices: "",
                                        source:data.source ?? "",
                                        owner: "",
                                        budget: "",
                                        timelineDecision: "",
                                        serviceInterest: "",
                                        description: "",
                                        leadStatus: data.quotationStatus ?? "",
                                        active: data.active ?? "",
                                        addressLine1: data.doorNo ?? "",
                                        addressLine2: data.landmark1 ?? "",
                                        area: data.area ?? "",
                                        city: data.city ?? "",
                                        state: data.state ?? "",
                                        country: data.country ?? "",
                                        pinCode: data.pincode ?? "",

                                        prospectEnrollmentDate: data.prospectEnrollmentDate ?? "",
                                        expectedConvertionDate: data.expectedConvertionDate ?? "",
                                        numOfHeadcount: data.numOfHeadcount ?? "",
                                        expectedBillingValue: data.expectedBillingValue ?? "",
                                        arpuValue: data.arpuValue ?? "",
                                        updatedTs: data.createdTs ?? "",
                                        sourceDetails: data.sourceDetails ?? "",
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ):
                         Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                100.height,
                                Center(
                                    child: SvgPicture.asset(
                                        "assets/images/noDataFound.svg")),
                              ],
                            )
                    ),
                  ),
                  // Obx(() {
                  //   final totalPages = controllers.totalPages;
                  //   final currentPage = controllers.currentPage.value;
                  //
                  //   return Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Container(
                  //         decoration:BoxDecoration(
                  //       color: colorsConst.secondary,
                  //           borderRadius: BorderRadius.circular(10)
                  //   ),
                  //         child: IconButton(
                  //           icon:  Icon(Icons.chevron_left,color: colorsConst.textColor,),
                  //           onPressed: currentPage > 1
                  //               ? () => controllers.currentPage.value--
                  //               : null,
                  //         ),
                  //       ),
                  //       ...List.generate(totalPages, (index) {
                  //         int pageNum = index + 1;
                  //         bool isCurrent = pageNum == currentPage;
                  //         return Padding(
                  //           padding: const EdgeInsets.symmetric(horizontal: 4),
                  //           child: GestureDetector(
                  //             onTap: () => controllers.currentPage.value = pageNum,
                  //             child: Container(
                  //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  //               decoration: BoxDecoration(
                  //                 color: isCurrent ? colorsConst.third : colorsConst.secondary,
                  //                 borderRadius: BorderRadius.circular(4),
                  //               ),
                  //               child: Text(
                  //                 pageNum.toString().padLeft(2, '0'),
                  //                 style: TextStyle(
                  //                   color: isCurrent ? Colors.black : Colors.white,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         );
                  //       }),
                  //       Container(
                  //         decoration:BoxDecoration(
                  //             color: colorsConst.secondary,
                  //             borderRadius: BorderRadius.circular(10)
                  //         ),
                  //         child: IconButton(
                  //           icon: Icon(Icons.chevron_right,color: colorsConst.textColor,),
                  //           onPressed: currentPage < totalPages
                  //               ? () => controllers.currentPage.value++
                  //               : null,
                  //         ),
                  //       ),
                  //     ],
                  //   );
                  // }),
                  Obx(() {
                    final totalPages = controllers.totalPages == 0 ? 1 : controllers.totalPages;
                    final currentPage = controllers.currentPage.value;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colorsConst.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.chevron_left, color: colorsConst.textColor),
                            onPressed: currentPage > 1
                                ? () => controllers.currentPage.value--
                                : null,
                          ),
                        ),
                        ...buildPagination(totalPages, currentPage),
                        Container(
                          decoration: BoxDecoration(
                            color: colorsConst.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.chevron_right, color: colorsConst.textColor),
                            onPressed: currentPage < totalPages
                                ? () => controllers.currentPage.value++
                                : null,
                          ),
                        ),
                      ],
                    );
                  }),


                  20.height,
                ],
              ),
            ),),
            utils.funnelContainer(context)
          ],
        ),
      ),
    );
  }
  List<Widget> buildPagination(int totalPages, int currentPage) {
    const maxVisiblePages = 5;
    List<Widget> pageButtons = [];

    int startPage = (currentPage - (maxVisiblePages ~/ 2)).clamp(1, totalPages);
    int endPage = (startPage + maxVisiblePages - 1).clamp(1, totalPages);

    if (startPage > 1) {
      pageButtons.add(pageButton(1, currentPage));
      if (startPage > 2) {
        pageButtons.add(ellipsis());
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(pageButton(i, currentPage));
    }

    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageButtons.add(ellipsis());
      }
      pageButtons.add(pageButton(totalPages, currentPage));
    }

    return pageButtons;
  }

  Widget pageButton(int pageNum, int currentPage) {
    bool isCurrent = pageNum == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => controllers.currentPage.value = pageNum,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent ? colorsConst.third : colorsConst.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            pageNum.toString().padLeft(2, '0'),
            style: TextStyle(
              color: isCurrent ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget ellipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text('...', style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

}
