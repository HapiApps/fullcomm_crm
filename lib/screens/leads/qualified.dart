import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_search_textfield.dart';
import 'package:fullcomm_crm/components/delete_button.dart';
import 'package:fullcomm_crm/components/lead_con.dart';
import 'package:fullcomm_crm/models/good_lead_obj.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import '../../common/constant/api.dart';
import '../../common/constant/default_constant.dart';
import '../../components/custom_text.dart';
import '../../components/promote_button.dart';
import '../../controller/controller.dart';
import '../../models/new_lead_obj.dart';

class Qualified extends StatefulWidget {
  const Qualified({super.key});

  @override
  State<Qualified> createState() => _QualifiedState();
}

class _QualifiedState extends State<Qualified> {
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      controllers.selectedIndex.value = 3;
      controllers.groupController.selectIndex(0);
      setState(() {
        controllers.search.clear();
        apiService.customerList = [];
        apiService.customerList.clear();
      });
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
        backgroundColor: colorsConst.primary,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            utils.sideBarFunction(context),
            Obx(
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
                            Obx(
                              () => CustomText(
                                text:
                                    "Good Leads - ${controllers.leadCategoryList[2]["value"]}",
                                colors: colorsConst.textColor,
                                size: 25,
                                isBold: true,
                              ),
                            ),
                            10.height,
                            Obx(
                              () => CustomText(
                                text:
                                    "View all of your ${controllers.leadCategoryList[2]["value"]} Information",
                                colors: colorsConst.textColor,
                                size: 14,
                              ),
                            ),
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
                            // buttons: ["All ${controllers.leadCategoryList.isEmpty?"":controllers.leadCategoryList[2]["value"]} ${controllers.allGoodLeadsLength.value}",
                            //   "Contacted 10","Closed 10","UnHold 10","Follow-up 10","Engaged 10"],
                            buttons: [
                              "All ${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[2]["value"]} ${controllers.allGoodLeadsLength.value}"
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DeleteButton(
                              leadList: apiService.customerList,
                              callback: () {
                                apiService.deleteCustomersAPI(
                                    context, apiService.customerList);
                              },
                            ),
                            5.width,
                            Obx(
                              () => PromoteButton(
                                headText: controllers.leadCategoryList[1]
                                    ["value"],
                                leadList: apiService.customerList,
                                callback: () {
                                  apiService.insertProspectsAPI(
                                      context, apiService.customerList);
                                },
                                text: "Demote",
                              ),
                            ),
                            5.width,
                            PromoteButton(
                              headText: "Customers",
                              leadList: apiService.customerList,
                              callback: () {
                                apiService.insertPromoteCustomerAPI(context);
                              },
                              text: "Promote",
                            ),
                          ],
                        )
                        // Row(
                        //   children:[
                        //     CustomText(
                        //       text: "Promote",
                        //       colors: colorsConst.textColor,
                        //       size: 12,
                        //       isBold: true,
                        //     ),
                        //     IconButton(
                        //         tooltip: "Promote To Customers",
                        //         onPressed: (){
                        //           if(apiService.customerList.isEmpty){
                        //             apiService.errorDialog(context, "Please select lead");
                        //             //utils.snackBar(context: Get.context!, msg: "Please select lead",color:Colors.green,);
                        //           }else{
                        //             showDialog(context: context,
                        //                 barrierDismissible: false,
                        //                 builder:(context){
                        //                   return AlertDialog(
                        //                     backgroundColor: colorsConst.secondary,
                        //                     content:CustomText(
                        //                       text: "Are you moving to the next level?",
                        //                       size: 16,
                        //                       isBold: true,
                        //                       colors: colorsConst.textColor,
                        //                     ),
                        //                     actions:[
                        //                       Row(
                        //                         mainAxisAlignment: MainAxisAlignment.end,
                        //                         children:[
                        //                           Container(
                        //                             decoration: BoxDecoration(
                        //                                 border: Border.all(
                        //                                     color: colorsConst.third
                        //                                 ),
                        //                                 color: colorsConst.primary
                        //                             ),
                        //                             width: 80,
                        //                             height: 25,
                        //                             child: ElevatedButton(
                        //                                 style: ElevatedButton.styleFrom(
                        //                                   shape: const RoundedRectangleBorder(
                        //                                       borderRadius: BorderRadius.zero
                        //                                   ),
                        //                                   backgroundColor: colorsConst.primary,
                        //                                 ),
                        //                                 onPressed:(){
                        //                                   Navigator.pop(context);
                        //                                 },
                        //                                 child:  const Text(
                        //                                   "Cancel",
                        //                                   style: TextStyle(
                        //                                     color: Colors.white,
                        //                                     fontSize: 14,
                        //                                   ),
                        //
                        //                                 )
                        //                             ),
                        //                           ),
                        //                           10.width,
                        //                           CustomLoadingButton(
                        //                             callback: (){
                        //                               //apiService.insertCustomerAPI(context);
                        //                             },
                        //                             height: 35,
                        //                             isLoading: true,
                        //                             backgroundColor: colorsConst.third,
                        //                             radius: 2,
                        //                             width: 80,
                        //                             controller: controllers.productCtr,
                        //                             isImage: false,
                        //                             text: "Move",
                        //                             textColor: colorsConst.primary,
                        //                           ),
                        //                           5.width
                        //                         ],
                        //                       ),
                        //                     ],
                        //                   );
                        //                 }
                        //             );
                        //           }
                        //         },
                        //         icon: SvgPicture.asset("assets/images/move.svg")),
                        //     5.width
                        //   ],
                        // )
                      ],
                    ),
                    10.height,
                    Divider(
                      thickness: 2,
                      color: colorsConst.secondary,
                    ),
                    // 10.height,
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children:[
                    //     CustomSearchTextField(controller: controllers.search,
                    //       hintText: "Search Name, Company, Mobile No.",
                    //     ),
                    //     Row(
                    //       children: [
                    //         SizedBox(
                    //           height:40,
                    //           child: ElevatedButton(
                    //               style: ElevatedButton.styleFrom(
                    //                   backgroundColor: colorsConst.secondary,
                    //                   shape:  RoundedRectangleBorder(
                    //                       borderRadius: BorderRadius.circular(5)
                    //                   )
                    //               ),
                    //               onPressed: (){},
                    //               child:Row(
                    //                 children:[
                    //                   SvgPicture.asset("assets/images/filter.svg"),
                    //                   5.width,
                    //                   CustomText(
                    //                     text: "Filter",
                    //                     colors: colorsConst.textColor,
                    //                     size: 15,
                    //
                    //                   ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //         10.width,
                    //         SizedBox(
                    //           height: 40,
                    //           child: ElevatedButton(
                    //               style: ElevatedButton.styleFrom(
                    //                   backgroundColor: colorsConst.secondary,
                    //                   shape:  RoundedRectangleBorder(
                    //                       borderRadius: BorderRadius.circular(5)
                    //                   )
                    //               ),
                    //               onPressed: (){},
                    //               child:Row(
                    //                 children: [
                    //                   SvgPicture.asset("assets/images/sort.svg"),
                    //                   6.width,
                    //                   CustomText(
                    //                     text: "Sort by",
                    //                     colors: colorsConst.textColor,
                    //                     size: 15,
                    //
                    //                   ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //
                    //   ],
                    // ),
                    15.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message:
                              'All the leads in the prospects will be selected',
                          child: TextButton(
                            onPressed: () {
                              if (controllers.isAllSelected.value == true) {
                                controllers.isAllSelected.value = false;
                                for (int j = 0;
                                    j < controllers.isGoodLeadList.length;
                                    j++) {
                                  controllers.isGoodLeadList[j]["isSelect"] =
                                      false;
                                  setState(() {
                                    var i = apiService.customerList.indexWhere(
                                        (element) =>
                                            element["lead_id"] ==
                                            controllers.isGoodLeadList[j]
                                                ["lead_id"]);
                                    apiService.customerList.removeAt(i);
                                  });
                                }
                              } else {
                                controllers.isAllSelected.value = true;
                                setState(() {
                                  for (int j = 0;
                                      j < controllers.isGoodLeadList.length;
                                      j++) {
                                    controllers.isGoodLeadList[j]["isSelect"] =
                                        true;
                                    apiService.customerList.add({
                                      "lead_id": controllers.isGoodLeadList[j]
                                          ["lead_id"],
                                      "user_id": controllers.storage.read("id"),
                                      "rating": controllers.isGoodLeadList[j]
                                          ["rating"],
                                      "cos_id": cosId,
                                    });
                                    print(apiService.customerList);
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
                    15.height,

                    Expanded(
                      child: Obx(
                        () => controllers.isLead.value == false
                            ? const Center(child: CircularProgressIndicator())
                            : FutureBuilder<List<NewLeadObj>>(
                                future: controllers.allGoodLeadFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ScrollbarTheme(
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
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            primary: false,
                                            itemCount: snapshot.data!.length,
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
                                              return Center(
                                                  child: LeadCon(
                                                index: index,
                                                quotationStatus: snapshot
                                                    .data![index]
                                                    .quotationStatus
                                                    .toString(),
                                                quotationRequired: snapshot
                                                    .data![index]
                                                    .quotationRequired
                                                    .toString(),
                                                productDiscussion: snapshot
                                                    .data![index]
                                                    .productDiscussion
                                                    .toString(),
                                                discussionPoint: snapshot
                                                    .data![index]
                                                    .discussionPoint
                                                    .toString(),
                                                notes: snapshot
                                                    .data![index].notes
                                                    .toString(),
                                                linkedin: "",
                                                x: "",
                                                name: snapshot
                                                    .data![index].firstname
                                                    .toString()
                                                    .split("||")[0],
                                                mobileNumber: snapshot
                                                    .data![index].mobileNumber
                                                    .toString()
                                                    .split("||")[0],
                                                email: snapshot
                                                    .data![index].emailId
                                                    .toString()
                                                    .split("||")[0],
                                                companyName: snapshot
                                                    .data![index].companyName
                                                    .toString(),
                                                mainWhatsApp: snapshot
                                                    .data![index].mobileNumber
                                                    .toString()
                                                    .split("||")[0],
                                                emailUpdate: snapshot
                                                    .data![index]
                                                    .quotationUpdate
                                                    .toString(),
                                                id: snapshot.data![index].userId
                                                    .toString(),
                                                status: snapshot.data![index]
                                                            .leadStatus ==
                                                        null
                                                    ? "UnQualified"
                                                    : snapshot
                                                        .data![index].leadStatus
                                                        .toString(),
                                                rating: snapshot.data![index]
                                                            .rating ==
                                                        null
                                                    ? "Warm"
                                                    : snapshot
                                                        .data![index].rating
                                                        .toString(),
                                                mainName: snapshot
                                                    .data![index].firstname
                                                    .toString()
                                                    .split("||")[0],
                                                mainMobile: snapshot
                                                    .data![index].mobileNumber
                                                    .toString()
                                                    .split("||")[0],
                                                mainEmail: snapshot
                                                    .data![index].emailId
                                                    .toString()
                                                    .split("||")[0],
                                                title: "",
                                                whatsappNumber: snapshot
                                                    .data![index].mobileNumber
                                                    .toString()
                                                    .split("||")[0],
                                                mainTitle: "",
                                                addressId: snapshot.data![index]
                                                        .addressId ??
                                                    "",
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
                                                leadStatus: snapshot
                                                        .data![index]
                                                        .leadStatus ??
                                                    "",
                                                active: snapshot
                                                        .data![index].active ??
                                                    "",
                                                addressLine1: snapshot
                                                        .data![index].doorNo ??
                                                    "",
                                                addressLine2: snapshot
                                                        .data![index]
                                                        .landmark1 ??
                                                    "",
                                                area: snapshot
                                                        .data![index].area ??
                                                    "",
                                                city: snapshot
                                                        .data![index].city ??
                                                    "",
                                                state: snapshot
                                                        .data![index].state ??
                                                    "",
                                                country: snapshot
                                                        .data![index].country ??
                                                    "",
                                                pinCode: snapshot
                                                        .data![index].pincode ??
                                                    "",
                                                prospectEnrollmentDate: snapshot
                                                        .data![index]
                                                        .prospectEnrollmentDate ??
                                                    "",
                                                expectedConvertionDate: snapshot
                                                        .data![index]
                                                        .expectedConvertionDate ??
                                                    "",
                                                numOfHeadcount: snapshot
                                                        .data![index]
                                                        .numOfHeadcount ??
                                                    "",
                                                expectedBillingValue: snapshot
                                                        .data![index]
                                                        .expectedBillingValue ??
                                                    "",
                                                arpuValue: snapshot.data![index]
                                                        .arpuValue ??
                                                    "",
                                                updateTs: snapshot.data![index]
                                                        .updatedTs ??
                                                    "",
                                                sourceDetails: snapshot
                                                        .data![index]
                                                        .sourceDetails ??
                                                    "",
                                              ));
                                            }),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        150.height,
                                        Center(
                                            child: SvgPicture.asset(
                                                "assets/images/noDataFound.svg")),
                                      ],
                                    );
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              ),
                      ),
                    ),
                    20.height,
                  ],
                ),
              ),
            ),
            utils.funnelContainer(context)
          ],
        ),
      ),
    );
  }
}
