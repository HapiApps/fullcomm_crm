import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/delete_button.dart';
import 'package:fullcomm_crm/components/lead_con.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../common/constant/api.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../components/promote_button.dart';
import '../../controller/controller.dart';
import '../../models/lead_obj.dart';
import '../../models/new_lead_obj.dart';
import '../../services/api_services.dart';

class Prospects extends StatefulWidget {
  const Prospects({super.key});

  @override
  State<Prospects> createState() => _ProspectsState();
}

class _ProspectsState extends State<Prospects> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      controllers.selectedIndex.value = 2;
      controllers.groupController.selectIndex(0);
      setState(() {
        controllers.search.clear();
        apiService.qualifiedList = [];
        apiService.qualifiedList.clear();
      });
      controllers.searchProspects.value = "";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth = screenSize.width - 380.0;
    final double partWidth = minPartWidth / 10;
    final double adjustedPartWidth = partWidth;
    return SelectionArea(
      child: Scaffold(
        body: Obx(
          () => Container(
            width: controllers.isLeftOpen.value == false &&
                    controllers.isRightOpen.value == false
                ? MediaQuery.of(context).size.width - 200
                : MediaQuery.of(context).size.width - 490,
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
                        Obx(() => CustomText(
                            text: "Leads - ${controllers.leadCategoryList[1]["value"]}",
                            colors: colorsConst.textColor,
                            size: 25,
                            isBold: true,
                          ),
                        ),
                        10.height,
                        Obx(() => CustomText(
                            text: "View all of your ${controllers.leadCategoryList[1]["value"]} Information",
                            colors: colorsConst.textColor,
                            size: 14,
                          ),
                        )
                      ],
                    ),
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
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => GroupButton(
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
                        // buttons: ["All ${controllers.leadCategoryList[1]["value"]} ${controllers.allLeadsLength.value}",
                        //   "Contacted 10","Closed 10","UnHold 10","Follow-up 10","Engaged 10"],
                        buttons: [
                          "All ${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[1]["value"]} ${controllers.allLeadsLength.value}"
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // IconButton(
                        //     onPressed: (){},
                        //     icon: SvgPicture.asset("assets/images/call.svg")),
                        // 5.width,
                        // IconButton(
                        //     onPressed: (){},
                        //     icon: SvgPicture.asset("assets/images/email.svg")),
                        DeleteButton(
                          leadList: apiService.qualifiedList,
                          callback: () {
                            apiService.deleteCustomersAPI(
                                context, apiService.qualifiedList);
                          },
                        ),
                        5.width,
                        Obx(
                          () => PromoteButton(
                            headText: controllers.leadCategoryList[0]
                                ["value"],
                            leadList: apiService.qualifiedList,
                            callback: () {
                              apiService.insertSuspectsAPI(context);
                            },
                            text: "Demote",
                          ),
                        ),
                        5.width,
                        Obx(
                          () => PromoteButton(
                            headText: controllers.leadCategoryList[2]
                                ["value"],
                            leadList: apiService.qualifiedList,
                            callback: () {
                              apiService.insertQualifiedAPI(context);
                            },
                            text: "Promote",
                          ),
                        ),
                        // Container(
                        //   width: 100,
                        //   alignment: Alignment.center,
                        //   decoration: BoxDecoration(
                        //       color: colorsConst.secondary,
                        //       borderRadius: BorderRadius.circular(10)),
                        //   child: Row(
                        //     children: [
                        //       CustomText(
                        //         text: "Promote",
                        //         colors: colorsConst.textColor,
                        //         size: 12,
                        //         isBold: true,
                        //       ),
                        //       IconButton(
                        //           tooltip: "Promote To ${controllers.leadCategoryList[2]["value"]}",
                        //           onPressed:(){
                        //             if(apiService.qualifiedList.isEmpty){
                        //               apiService.errorDialog(context, "Please select lead");
                        //               // utils.snackBar(context: Get.context!, msg: "Please select lead",color:Colors.green,);
                        //             }else{
                        //               showDialog(context: context,
                        //                   barrierDismissible: false,
                        //                   builder:(context){
                        //                     return AlertDialog(
                        //                       backgroundColor: colorsConst.secondary,
                        //                       content:CustomText(
                        //                         text: "Are you moving to the next level?",
                        //                         size: 16,
                        //                         isBold: true,
                        //                         colors: colorsConst.textColor,
                        //                       ),
                        //                       actions:[
                        //                         Row(
                        //                           mainAxisAlignment: MainAxisAlignment.end,
                        //                           children:[
                        //                             Container(
                        //                               decoration: BoxDecoration(
                        //                                   border: Border.all(
                        //                                       color: colorsConst.third
                        //                                   ),
                        //                                   color: colorsConst.primary
                        //                               ),
                        //                               width: 80,
                        //                               height: 25,
                        //                               child: ElevatedButton(
                        //                                   style: ElevatedButton.styleFrom(
                        //                                     shape: const RoundedRectangleBorder(
                        //                                         borderRadius: BorderRadius.zero
                        //                                     ),
                        //                                     backgroundColor: colorsConst.primary,
                        //                                   ),
                        //                                   onPressed:(){
                        //                                     Navigator.pop(context);
                        //                                   },
                        //                                   child: const CustomText(
                        //                                     text: "Cancel",
                        //                                     colors: Colors.white,
                        //                                     size: 14,
                        //                                   )
                        //                               ),
                        //                             ),
                        //                             10.width,
                        //                             CustomLoadingButton(
                        //                               callback: (){
                        //                                 apiService.insertQualifiedAPI(context);
                        //                               },
                        //                               height: 35,
                        //                               isLoading: true,
                        //                               backgroundColor: colorsConst.third,
                        //                               radius: 2,
                        //                               width: 80,
                        //                               controller: controllers.productCtr,
                        //                               isImage: false,
                        //                               text: "Move",
                        //                               textColor: colorsConst.primary,
                        //                             ),
                        //                             5.width
                        //                           ],
                        //                         ),
                        //                       ],
                        //                     );
                        //                   }
                        //               );
                        //             }
                        //           },
                        //           icon: SvgPicture.asset("assets/images/move.svg")),
                        //     ],
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
                      controller: controllers.search,
                      hintText: "Search Name, Company, Mobile No.",
                      onChanged: (value) {
                        controllers.searchProspects.value = value.toString();
                      },
                    ),
                    Row(
                      children: [
                        // SizedBox(
                        //   height:40,
                        //   child: ElevatedButton(
                        //       style: ElevatedButton.styleFrom(
                        //           backgroundColor: colorsConst.secondary,
                        //           shape:  RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(5)
                        //           )
                        //       ),
                        //       onPressed: (){},
                        //       child:Row(
                        //         children:[
                        //           CompositedTransformTarget(
                        //             link: _layerLink,
                        //             child: SizedBox(
                        //               height: 40,
                        //               child: ElevatedButton(
                        //                   style: ElevatedButton.styleFrom(
                        //                       backgroundColor: colorsConst.secondary,
                        //                       shape: RoundedRectangleBorder(
                        //                           borderRadius:
                        //                           BorderRadius.circular(5))),
                        //                   onPressed: _showFilterPopup,
                        //                   child: Row(
                        //                     children: [
                        //                       SvgPicture.asset(
                        //                           "assets/images/filter.svg"),
                        //                       5.width,
                        //                       CustomText(
                        //                         text: "Filter",
                        //                         colors: colorsConst.textColor,
                        //                         size: 15,
                        //                       ),
                        //                     ],
                        //                   )
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //   ),
                        // ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorsConst.secondary,
                          ),
                          onPressed: () => controllers.selectMonth(
                              context,
                              controllers.selectedQualifiedSortBy,
                              controllers.selectedPMonth),
                          child: Text(
                            controllers.selectedPMonth.value != null
                                ? DateFormat('MMMM yyyy').format(
                                    controllers.selectedPMonth.value!)
                                : 'Select Month',
                          ),
                        ),
                        10.width,
                        PopupMenuButton<String>(
                          offset:
                              const Offset(0, 40), // position below button
                          color: colorsConst.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onSelected: (value) {
                            controllers.selectedQualifiedSortBy.value =
                                value;
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "Today",
                              child: Text("Today",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
                            PopupMenuItem(
                              value: "Last 7 Days",
                              child: Text("Last 7 Days",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
                            PopupMenuItem(
                              value: "Last 30 Days",
                              child: Text("Last 30 Days",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
                            PopupMenuItem(
                              value: "All",
                              child: Text("All",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
                          ],
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorsConst.secondary,
                            ),
                            onPressed: null,
                            child: Row(
                              children: [
                                SvgPicture.asset("assets/images/sort.svg"),
                                const SizedBox(width: 6),
                                Obx(() => CustomText(
                                      text: controllers.selectedQualifiedSortBy.value.isEmpty
                                          ? "Sort by"
                                          : controllers.selectedQualifiedSortBy.value,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message:
                          'All the leads in the ${controllers.leadCategoryList[1]["value"]} will be selected',
                      child: TextButton(
                        onPressed: () {
                          if (controllers.isAllSelected.value == true) {
                            controllers.isAllSelected.value = false;
                            for (int j = 0;
                                j < controllers.isLeadsList.length;
                                j++) {
                              controllers.isLeadsList[j]["isSelect"] =
                                  false;
                              setState(() {
                                var i = apiService.qualifiedList.indexWhere(
                                    (element) =>
                                        element["lead_id"] ==
                                        controllers.isLeadsList[j]
                                            ["lead_id"]);
                                apiService.qualifiedList.removeAt(i);
                              });
                            }
                          } else {
                            controllers.isAllSelected.value = true;
                            setState(() {
                              for (int j = 0; j < controllers.isLeadsList.length; j++) {
                                controllers.isLeadsList[j]["isSelect"] = true;
                                apiService.qualifiedList.add({
                                  "lead_id": controllers.isLeadsList[j]
                                      ["lead_id"],
                                  "user_id": controllers.storage.read("id"),
                                  "rating": controllers.isLeadsList[j]
                                      ["rating"],
                                  "cos_id": cosId,
                                });
                                print(apiService.qualifiedList);
                              }
                            });
                          }
                        },
                        child: CustomText(
                          text: "Select All",
                          size: 16,
                          colors: controllers.isAllSelected.value
                              ? colorsConst.third
                              : colorsConst.textColor,
                        ),
                      ),
                    )
                  ],
                ),
                // 10.height,
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children:[
                //         CustomText(
                //           text: "   Warm",
                //           size: 16,
                //           colors: colorsConst.textColor,
                //           isBold: true,
                //         ),
                //         10.height,
                //         Row(
                //           children: [
                //             LinearPercentIndicator(
                //                 width: MediaQuery.of(context).size.width/4.8,
                //                 lineHeight: 30.0,
                //                 percent:0.25,
                //                 backgroundColor: const Color(0xffCFE9FE),
                //                 progressColor: const Color(0xff0D9DDA)
                //             ),
                //             CustomText(
                //               text: "25%",
                //               colors: colorsConst.textColor,
                //               size: 14,
                //               isBold: true,
                //             )
                //           ],
                //         ),
                //
                //       ],
                //     ),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         CustomText(
                //           text: "   Hot",
                //           size: 16,
                //           colors: colorsConst.textColor,
                //           isBold: true,
                //         ),
                //         10.height,
                //         Row(
                //           children: [
                //             LinearPercentIndicator(
                //                 width:MediaQuery.of(context).size.width/4.8,
                //                 lineHeight: 30.0,
                //                 percent: 0.50,
                //                 backgroundColor: const Color(0xffFEDED8),
                //                 progressColor: const Color(0xffFE5C4C)
                //             ),
                //             CustomText(
                //               text: "50%",
                //               colors: colorsConst.textColor,
                //               size: 14,
                //               isBold: true,
                //             )
                //           ],
                //         ),
                //
                //       ],
                //     ),
                //
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children:[
                //         CustomText(
                //           text: "   Cold",
                //           size: 16,
                //           colors: colorsConst.textColor,
                //           isBold: true,
                //         ),
                //         10.height,
                //         Row(
                //           children:[
                //             LinearPercentIndicator(
                //                 width: MediaQuery.of(context).size.width/4.8,
                //                 lineHeight: 30.0,
                //                 percent: 0.25,
                //                 backgroundColor: const Color(0xffACF3E4),
                //                 progressColor: const Color(0xff06A59A)
                //             ),
                //             CustomText(
                //               text: "25%",
                //               colors: colorsConst.textColor,
                //               size: 14,
                //               isBold: true,
                //             )
                //           ],
                //         ),
                //
                //       ],
                //     ),
                //   ],
                // ),
                10.height,
                Expanded(
                  child: Obx(() => controllers.isLead.value == false
                      ? const Center(child: CircularProgressIndicator())
                      : controllers.paginatedProspectsLeads.isNotEmpty
                          ? ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor: MaterialStateProperty.all(
                                    const Color(0xff2C3557)),
                                trackColor: MaterialStateProperty.all(
                                    const Color(0xff465271)),
                                radius: const Radius.circular(10),
                                thickness: MaterialStateProperty.all(8),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                thickness: 5,
                                trackVisibility: true,
                                radius: const Radius.circular(10),
                                controller: _controller,
                                child: GridView.builder(
                                    //shrinkWrap: true,
                                    controller: _controller,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    primary: false,
                                    itemCount: controllers.paginatedProspectsLeads.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10.0,
                                            mainAxisSpacing: 10.0,
                                            mainAxisExtent: 250),
                                    // gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                                    //   //mainAxisExtent: 2,
                                    //   maxCrossAxisExtent: 300,
                                    //   crossAxisSpacing: 20.0,
                                    //   mainAxisSpacing: 20.0,
                                    // ),
                                    itemBuilder: (context, index) {
                                      final data = controllers.paginatedProspectsLeads[index];
                                      return Center(
                                          child: LeadCon(
                                        index: index,
                                        quotationStatus:
                                            data.quotationStatus.toString(),
                                        quotationRequired: data
                                            .quotationRequired
                                            .toString(),
                                        productDiscussion: data
                                            .productDiscussion
                                            .toString(),
                                        discussionPoint:
                                            data.discussionPoint.toString(),
                                        notes: data.notes.toString(),
                                        linkedin: "",
                                        x: "",
                                        name: data.firstname
                                            .toString()
                                            .split("||")[0],
                                        mobileNumber: data.mobileNumber
                                            .toString()
                                            .split("||")[0],
                                        email: data.emailId
                                            .toString()
                                            .split("||")[0],
                                        companyName:
                                            data.companyName.toString(),
                                        mainWhatsApp: data.mobileNumber
                                            .toString()
                                            .split("||")[0],
                                        emailUpdate:
                                            data.quotationUpdate.toString(),
                                        id: data.userId.toString(),
                                        status: data.leadStatus == null
                                            ? "UnQualified"
                                            : data.leadStatus.toString(),
                                        rating: data.rating == null
                                            ? "Warm"
                                            : data.rating.toString(),
                                        mainName: data.firstname
                                            .toString()
                                            .split("||")[0],
                                        mainMobile: data.mobileNumber
                                            .toString()
                                            .split("||")[0],
                                        mainEmail: data.emailId
                                            .toString()
                                            .split("||")[0],
                                        title: "",
                                        whatsappNumber: data.mobileNumber
                                            .toString()
                                            .split("||")[0],
                                        mainTitle: "",
                                        addressId: data.addressId ?? "",
                                        companyWebsite: "",
                                        companyNumber: "",
                                        companyEmail: "",
                                        industry: "",
                                        productServices: "",
                                        source: "",
                                        owner: "",
                                        budget: "",
                                        timelineDecision: "",
                                        serviceInterest: "",
                                        description: "",
                                        leadStatus: data.leadStatus ?? "",
                                        active: data.active ?? "",
                                        addressLine1: data.doorNo ?? "",
                                        addressLine2: data.landmark1 ?? "",
                                        area: data.area ?? "",
                                        city: data.city ?? "",
                                        state: data.state ?? "",
                                        country: data.country ?? "",
                                        pinCode: data.pincode ?? "",
                                        prospectEnrollmentDate:
                                            data.prospectEnrollmentDate ??
                                                "",
                                        expectedConvertionDate:
                                            data.expectedConvertionDate ??
                                                "",
                                        numOfHeadcount:
                                            data.numOfHeadcount ?? "",
                                        expectedBillingValue:
                                            data.expectedBillingValue ?? "",
                                        arpuValue: data.arpuValue ?? "",
                                        updateTs: data.updatedTs ?? "",
                                        sourceDetails:
                                            data.sourceDetails ?? "",
                                      ));
                                    }),
                                // child: ListView.builder(
                                //   //shrinkWrap: true,
                                //     controller: _controller,
                                //     physics: const AlwaysScrollableScrollPhysics(),
                                //     itemCount: snapshot.data!.length,
                                //     itemBuilder:(context, index){
                                //       if (snapshot.data![index].firstname.toString().toLowerCase().contains(controllers.searchText.toLowerCase())){
                                //         return Row(
                                //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //           children:[
                                //             Column(
                                //               children:[
                                //                 snapshot.data![index].rating.toString().toLowerCase() == "warm"?
                                //                 LeadCon(
                                //                   index: index,
                                //                   quotationStatus: snapshot.data![index].quotationStatus.toString(),
                                //                   quotationRequired: snapshot.data![index].quotationRequired.toString(),
                                //                   productDiscussion: snapshot.data![index].productDiscussion.toString(),
                                //                   discussionPoint: snapshot.data![index].discussionPoint.toString(),
                                //                   notes: snapshot.data![index].notes.toString(),
                                //                   linkedin: "",
                                //                   x: "",
                                //                   name: snapshot.data![index].firstname.toString().split("||")[0],
                                //                   mobileNumber: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   email: snapshot.data![index].emailId.toString().split("||")[0],
                                //                   companyName: snapshot.data![index].companyName.toString(),
                                //                   mainWhatsApp: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   emailUpdate: snapshot.data![index].quotationUpdate.toString(),
                                //                   id: snapshot.data![index].userId.toString(),
                                //                   status: snapshot.data![index].leadStatus == null ? "UnQualified" : snapshot.data![index].leadStatus.toString(),
                                //                   rating: snapshot.data![index].rating == null ? "Warm" : snapshot.data![index].rating.toString(),
                                //                   mainName: snapshot.data![index].firstname.toString().split("||")[0],
                                //                   mainMobile: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   mainEmail: snapshot.data![index].emailId.toString().split("||")[0],
                                //                   title: "",
                                //                   whatsappNumber: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   mainTitle: "",
                                //                   addressId: snapshot.data![index].addressId ?? "",
                                //                   companyWebsite: "",
                                //                   companyNumber: "",
                                //                   companyEmail: "",
                                //                   industry: "",
                                //                   productServices: "",
                                //                   source: "",
                                //                   owner: "",
                                //                   budget: "",
                                //                   timelineDecision: "",
                                //                   serviceInterest: "",
                                //                   description: "",
                                //                   leadStatus: snapshot.data![index].leadStatus ?? "",
                                //                   active: snapshot.data![index].active ?? "",
                                //                   addressLine1: snapshot.data![index].doorNo ?? "",
                                //                   addressLine2: snapshot.data![index].landmark1 ?? "",
                                //                   area: snapshot.data![index].area ?? "",
                                //                   city: snapshot.data![index].city ?? "",
                                //                   state: snapshot.data![index].state ?? "",
                                //                   country: snapshot.data![index].country ?? "",
                                //                   pinCode: snapshot.data![index].pincode ?? "",
                                //                   prospectEnrollmentDate: snapshot.data![index].prospectEnrollmentDate ?? "",
                                //                   expectedConvertionDate: snapshot.data![index].expectedConvertionDate ?? "",
                                //                   numOfHeadcount: snapshot.data![index].numOfHeadcount ?? "",
                                //                   expectedBillingValue: snapshot.data![index].expectedBillingValue ?? "",
                                //                   arpuValue: snapshot.data![index].arpuValue ?? "",
                                //                   updateTs: snapshot.data![index].updatedTs ?? "",
                                //                   sourceDetails: snapshot.data![index].sourceDetails ?? "",
                                //                 ):SizedBox(
                                //                   width: MediaQuery.of(context).size.width/4.5,
                                //                 ),
                                //                 10.height,
                                //               ],
                                //             ),
                                //             Column(
                                //               children: [
                                //                 snapshot.data![index].rating.toString().toLowerCase() == "hot"?
                                //                 LeadCon(
                                //                   index: index,
                                //                   quotationStatus: snapshot.data![index].quotationStatus.toString(),
                                //                   quotationRequired: snapshot.data![index].quotationRequired.toString(),
                                //                   productDiscussion: snapshot.data![index].productDiscussion.toString(),
                                //                   discussionPoint: snapshot.data![index].discussionPoint.toString(),
                                //                   notes: snapshot.data![index].notes.toString(),
                                //                   linkedin: "",
                                //                   x: "",
                                //                   name: snapshot.data![index].firstname.toString().split("||")[0],
                                //                   mobileNumber: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   email: snapshot.data![index].emailId.toString().split("||")[0],
                                //                   companyName: snapshot.data![index].companyName.toString(),
                                //                   mainWhatsApp: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   emailUpdate: snapshot.data![index].quotationUpdate.toString(),
                                //                   id: snapshot.data![index].userId.toString(),
                                //                   status: snapshot.data![index].leadStatus == null ? "UnQualified" : snapshot.data![index].leadStatus.toString(),
                                //                   rating: snapshot.data![index].rating == null ? "Warm" : snapshot.data![index].rating.toString(),
                                //                   mainName: snapshot.data![index].firstname.toString().split("||")[0],
                                //                   mainMobile: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   mainEmail: snapshot.data![index].emailId.toString().split("||")[0],
                                //                   title: "",
                                //                   whatsappNumber: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   mainTitle: "",
                                //                   addressId: snapshot.data![index].addressId ?? "",
                                //                   companyWebsite: "",
                                //                   companyNumber: "",
                                //                   companyEmail: "",
                                //                   industry: "",
                                //                   productServices: "",
                                //                   source: "",
                                //                   owner: "",
                                //                   budget: "",
                                //                   timelineDecision: "",
                                //                   serviceInterest: "",
                                //                   description: "",
                                //                   leadStatus: snapshot.data![index].quotationStatus ?? "",
                                //                   active: snapshot.data![index].active ?? "",
                                //                   addressLine1: snapshot.data![index].doorNo ?? "",
                                //                   addressLine2: snapshot.data![index].landmark1 ?? "",
                                //                   area: snapshot.data![index].area ?? "",
                                //                   city: snapshot.data![index].city ?? "",
                                //                   state: snapshot.data![index].state ?? "",
                                //                   country: snapshot.data![index].country ?? "",
                                //                   pinCode: snapshot.data![index].pincode ?? "",
                                //                   prospectEnrollmentDate: snapshot.data![index].prospectEnrollmentDate ?? "",
                                //                   expectedConvertionDate: snapshot.data![index].expectedConvertionDate ?? "",
                                //                   numOfHeadcount: snapshot.data![index].numOfHeadcount ?? "",
                                //                   expectedBillingValue: snapshot.data![index].expectedBillingValue ?? "",
                                //                   arpuValue: snapshot.data![index].arpuValue ?? "",
                                //                   updateTs: snapshot.data![index].updatedTs ?? "",
                                //                   sourceDetails: snapshot.data![index].sourceDetails ?? "",
                                //                 ):SizedBox(
                                //                   width: MediaQuery.of(context).size.width/4.5,
                                //                 ),
                                //                 10.height,
                                //               ],
                                //             ),
                                //             Column(
                                //               children:[
                                //                 snapshot.data![index].rating.toString().toLowerCase() == "cold"?
                                //                 LeadCon(
                                //                   updateTs: snapshot.data![index].updatedTs ?? "",
                                //                   index: index,
                                //                   quotationStatus: snapshot.data![index].quotationStatus.toString(),
                                //                   quotationRequired: snapshot.data![index].quotationRequired.toString(),
                                //                   productDiscussion: snapshot.data![index].productDiscussion.toString(),
                                //                   discussionPoint: snapshot.data![index].discussionPoint.toString(),
                                //                   notes: snapshot.data![index].notes.toString(),
                                //                   linkedin: "",
                                //                   x: "",
                                //                   name: snapshot.data![index].firstname.toString().split("||")[0],
                                //                   mobileNumber: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   email: snapshot.data![index].emailId.toString().split("||")[0],
                                //                   companyName: snapshot.data![index].companyName.toString(),
                                //                   mainWhatsApp: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   emailUpdate: snapshot.data![index].quotationUpdate.toString(),
                                //                   id: snapshot.data![index].userId.toString(),
                                //                   status: snapshot.data![index].leadStatus == null ? "UnQualified" : snapshot.data![index].leadStatus.toString(),
                                //                   rating: snapshot.data![index].rating == null ? "Warm" : snapshot.data![index].rating.toString(),
                                //                   mainName: snapshot.data![index].firstname.toString().split("||")[0],
                                //                   mainMobile: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   mainEmail: snapshot.data![index].emailId.toString().split("||")[0],
                                //                   title: "",
                                //                   whatsappNumber: snapshot.data![index].mobileNumber.toString().split("||")[0],
                                //                   mainTitle: "",
                                //                   addressId: snapshot.data![index].addressId ?? "",
                                //                   companyWebsite: "",
                                //                   companyNumber: "",
                                //                   companyEmail: "",
                                //                   industry: "",
                                //                   productServices: "",
                                //                   source: "",
                                //                   owner: "",
                                //                   budget: "",
                                //                   timelineDecision: "",
                                //                   serviceInterest: "",
                                //                   description: "",
                                //                   leadStatus: snapshot.data![index].quotationStatus ?? "",
                                //                   active: snapshot.data![index].active ?? "",
                                //                   addressLine1: snapshot.data![index].doorNo ?? "",
                                //                   addressLine2: snapshot.data![index].landmark1 ?? "",
                                //                   area: snapshot.data![index].area ?? "",
                                //                   city: snapshot.data![index].city ?? "",
                                //                   state: snapshot.data![index].state ?? "",
                                //                   country: snapshot.data![index].country ?? "",
                                //                   pinCode: snapshot.data![index].pincode ?? "",
                                //                   prospectEnrollmentDate: snapshot.data![index].prospectEnrollmentDate ?? "",
                                //                   expectedConvertionDate: snapshot.data![index].expectedConvertionDate ?? "",
                                //                   numOfHeadcount: snapshot.data![index].numOfHeadcount ?? "",
                                //                   expectedBillingValue: snapshot.data![index].expectedBillingValue ?? "",
                                //                   arpuValue: snapshot.data![index].arpuValue ?? "",
                                //                   sourceDetails: snapshot.data![index].sourceDetails ?? "",
                                //                 ):SizedBox(
                                //                   width: MediaQuery.of(context).size.width/4.5,
                                //                 ),
                                //                 10.height,
                                //               ],
                                //             ),
                                //           ],
                                //         );
                                //       }
                                //       return const SizedBox();
                                //     }
                                // ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                120.height,
                                Center(
                                    child: SvgPicture.asset(
                                        "assets/images/noDataFound.svg")),
                              ],
                            )),
                ),
                Obx(() {
                  // Ensure totalPages is at least 1
                  final totalPages = controllers.totalProspectPages == 0
                      ? 1
                      : controllers.totalProspectPages;
                  final currentPage = controllers.currentProspectPage.value;

                  // Clamp currentPage if needed (optional safeguard)
                  if (currentPage > totalPages) {
                    controllers.currentProspectPage.value = totalPages;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.chevron_left,
                              color: colorsConst.textColor),
                          onPressed: currentPage > 1
                              ? () =>
                                  controllers.currentProspectPage.value--
                              : null,
                        ),
                      ),
                      ...buildPagination(totalPages, currentPage),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.chevron_right,
                              color: colorsConst.textColor),
                          onPressed: currentPage < totalPages
                              ? () =>
                                  controllers.currentProspectPage.value++
                              : null,
                        ),
                      ),
                    ],
                  );
                }),

                20.height,
              ],
            ),
          ),
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
        onTap: () => controllers.currentProspectPage.value = pageNum,
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
