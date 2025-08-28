import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_search_textfield.dart';
import 'package:fullcomm_crm/models/customer_obj.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../models/new_lead_obj.dart';
import '../../services/api_services.dart';
import '../leads/view_lead.dart';

class ViewCustomer extends StatefulWidget {
  const ViewCustomer({super.key});

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _controller = ScrollController();
  Future refresh() async {
    refreshKey.currentState?.show(atTop: false);
    controllers.allCustomerFuture = apiService.allCustomerDetails();
    //await Future.delayed(const Duration(seconds: 3));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      controllers.search.clear();
      controllers.selectedIndex.value = 4;
      controllers.groupController.selectIndex(0);
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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            utils.sideBarFunction(context),
            Container(
              width: MediaQuery.of(context).size.width - 490,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: "Customers",
                            colors: colorsConst.textColor,
                            size: 25,
                            isBold: true,
                          ),
                          10.height,
                          CustomText(
                            text: "View all of your Customer Information",
                            colors: colorsConst.textColor,
                            size: 14,
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
                  Divider(
                    thickness: 2,
                    color: colorsConst.secondary,
                  ),
                  10.height,
                  Row(
                    children: [
                      CustomSearchTextField(
                        controller: controllers.search,
                        onChanged: (value) {
                          setState(() {
                            controllers.searchText = value.toString().trim();
                          });
                        },
                      )
                    ],
                  ),
                  15.height,
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3.5),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(2.5),
                      4: FlexColumnWidth(1.5),
                      5: FlexColumnWidth(2),
                      6: FlexColumnWidth(1.5),
                      7: FlexColumnWidth(1.5),
                    },
                    border:
                        TableBorder.all(color: colorsConst.primary, width: 5),
                    children: [
                      TableRow(
                          decoration: BoxDecoration(
                              color: colorsConst.secondary,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))),
                          children: [
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                            //   children:[
                            // Obx(() =>  CustomCheckBox(
                            //     text: "",
                            //     onChanged: (value){
                            //       if(controllers.isAllSelected.value==true){
                            //         controllers.isAllSelected.value=false;
                            //       }else{
                            //         controllers.isAllSelected.value=true;
                            //       }
                            //       //controllers.isMainPerson.value=!controllers.isMainPerson.value;
                            //     },
                            //     saveValue: controllers.isAllSelected.value),
                            // ),

                            //   ],
                            // ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nLast Quotation\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
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

                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nEmail\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
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
                            //  CustomText(
                            //   textAlign: TextAlign.center,
                            //   text: "\nStatus\n",
                            //   size: 15,
                            //   isBold: true,
                            //   colors: colorsConst.textColor,
                            // ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nRating\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                          ]),
                    ],
                  ),
                  5.height,
                  Expanded(
                    child: Obx(
                      () => controllers.isLead.value == false
                          ? const Center(child: CircularProgressIndicator())
                          : FutureBuilder<List<NewLeadObj>>(
                              future: controllers.allCustomerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var originalData = snapshot.data!;
                                  var filteredData = originalData.where((item) {
                                    return item.firstname
                                            .toString()
                                            .toLowerCase()
                                            .contains(controllers.searchText
                                                .toLowerCase()) ||
                                        item.companyName
                                            .toString()
                                            .toLowerCase()
                                            .contains(controllers.searchText
                                                .toLowerCase());
                                  }).toList();
                                  if (filteredData.isEmpty) {
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
                                  return ScrollbarTheme(
                                    data: ScrollbarThemeData(
                                      thumbColor: MaterialStateProperty.all(
                                          const Color(
                                              0xff2C3557)), // 👈 Your color
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
                                      child: ListView.builder(
                                          controller: _controller,
                                          primary: false,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: filteredData.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                Get.to(
                                                    ViewLead(
                                                      quotationStatus: snapshot
                                                          .data![index]
                                                          .quotationStatus
                                                          .toString(),
                                                      quotationRequired:
                                                          snapshot.data![index]
                                                              .quotationRequired
                                                              .toString(),
                                                      productDiscussion:
                                                          snapshot.data![index]
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
                                                          .data![index]
                                                          .firstname
                                                          .toString()
                                                          .split("||")[0],
                                                      mobileNumber: snapshot
                                                          .data![index]
                                                          .mobileNumber
                                                          .toString()
                                                          .split("||")[0],
                                                      email: snapshot
                                                          .data![index].emailId
                                                          .toString()
                                                          .split("||")[0],
                                                      companyName: snapshot
                                                          .data![index]
                                                          .companyName
                                                          .toString(),
                                                      mainWhatsApp: snapshot
                                                          .data![index]
                                                          .mobileNumber
                                                          .toString()
                                                          .split("||")[0],
                                                      emailUpdate: snapshot
                                                          .data![index]
                                                          .quotationUpdate
                                                          .toString(),
                                                      id: snapshot
                                                          .data![index].userId
                                                          .toString(),
                                                      status: snapshot
                                                                  .data![index]
                                                                  .leadStatus ==
                                                              null
                                                          ? "UnQualified"
                                                          : snapshot
                                                              .data![index]
                                                              .leadStatus
                                                              .toString(),
                                                      rating: snapshot
                                                                  .data![index]
                                                                  .rating ==
                                                              null
                                                          ? "Warm"
                                                          : snapshot
                                                              .data![index]
                                                              .rating
                                                              .toString(),
                                                      mainName: snapshot
                                                          .data![index]
                                                          .firstname
                                                          .toString()
                                                          .split("||")[0],
                                                      mainMobile: snapshot
                                                          .data![index]
                                                          .mobileNumber
                                                          .toString()
                                                          .split("||")[0],
                                                      mainEmail: snapshot
                                                          .data![index].emailId
                                                          .toString()
                                                          .split("||")[0],
                                                      title: "",
                                                      whatsappNumber: snapshot
                                                          .data![index]
                                                          .mobileNumber
                                                          .toString()
                                                          .split("||")[0],
                                                      mainTitle: "",
                                                      addressId: snapshot
                                                              .data![index]
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
                                                              .quotationStatus ??
                                                          "",
                                                      active: snapshot
                                                              .data![index]
                                                              .active ??
                                                          "",
                                                      addressLine1: snapshot
                                                              .data![index]
                                                              .doorNo ??
                                                          "",
                                                      addressLine2: snapshot
                                                              .data![index]
                                                              .landmark1 ??
                                                          "",
                                                      area: snapshot
                                                              .data![index]
                                                              .area ??
                                                          "",
                                                      city: snapshot
                                                              .data![index]
                                                              .city ??
                                                          "",
                                                      state: snapshot
                                                              .data![index]
                                                              .state ??
                                                          "",
                                                      country: snapshot
                                                              .data![index]
                                                              .country ??
                                                          "",
                                                      pinCode: snapshot
                                                              .data![index]
                                                              .pincode ??
                                                          "",
                                                      prospectEnrollmentDate:
                                                          snapshot.data![index]
                                                                  .prospectEnrollmentDate ??
                                                              "",
                                                      expectedConvertionDate:
                                                          snapshot.data![index]
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
                                                      arpuValue: snapshot
                                                              .data![index]
                                                              .arpuValue ??
                                                          "",
                                                      updateTs: snapshot
                                                              .data![index]
                                                              .updatedTs ??
                                                          "",
                                                      sourceDetails: snapshot
                                                              .data![index]
                                                              .sourceDetails ??
                                                          "",
                                                    ),
                                                    duration: Duration.zero);
                                              },
                                              child: Table(
                                                columnWidths: const {
                                                  0: FlexColumnWidth(3.5),
                                                  1: FlexColumnWidth(1.5),
                                                  2: FlexColumnWidth(1.5),
                                                  3: FlexColumnWidth(2.5),
                                                  4: FlexColumnWidth(1.5),
                                                  5: FlexColumnWidth(2),
                                                  6: FlexColumnWidth(1.5),
                                                  7: FlexColumnWidth(1.5),
                                                },
                                                border: TableBorder.all(
                                                    color: colorsConst.primary,
                                                    width: 5),
                                                children: [
                                                  TableRow(
                                                      decoration: BoxDecoration(
                                                        color: colorsConst
                                                            .secondary,
                                                      ),
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            70.height,
                                                            10.width,
                                                            SvgPicture.asset(
                                                              "assets/images/paper.svg",
                                                              width: 13,
                                                              height: 13,
                                                            ),
                                                            10.width,
                                                            // Obx(() =>  CustomCheckBox(
                                                            //     text: "",
                                                            //     onChanged: (value){
                                                            //       if(controllers.isAllSelected.value==true){
                                                            //         controllers.isAllSelected.value=false;
                                                            //       }else{
                                                            //         controllers.isAllSelected.value=true;
                                                            //       }
                                                            //       //controllers.isMainPerson.value=!controllers.isMainPerson.value;
                                                            //     },
                                                            //     saveValue: controllers.isAllSelected.value),
                                                            // ),
                                                            10.width,
                                                            CircleAvatar(
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xffAFC8D9),
                                                              radius: 13,
                                                              child: Icon(
                                                                Icons.email,
                                                                color:
                                                                    colorsConst
                                                                        .primary,
                                                                size: 15,
                                                              ),
                                                            ),
                                                            4.width,
                                                            Container(
                                                              width: 120,
                                                              height: 30,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration: BoxDecoration(
                                                                  color: const Color(
                                                                      0xffAFC8D9),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15)),
                                                              child: CustomText(
                                                                //textAlign: TextAlign.start,
                                                                text: filteredData[index]
                                                                            .quotationUpdate
                                                                            .toString()
                                                                            .isEmpty ||
                                                                        filteredData[index].quotationUpdate ==
                                                                            null ||
                                                                        filteredData[index].quotationUpdate ==
                                                                            "null"
                                                                    ? "Not Sent"
                                                                    : filteredData[
                                                                            index]
                                                                        .quotationUpdate
                                                                        .toString(),
                                                                colors:
                                                                    colorsConst
                                                                        .primary,
                                                                size: 12,
                                                                isBold: true,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 25),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: filteredData[
                                                                    index]
                                                                .firstname
                                                                .toString()
                                                                .split("||")[0],
                                                            size: 14,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 25),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: filteredData[
                                                                    index]
                                                                .mobileNumber
                                                                .toString()
                                                                .split("||")[0],
                                                            size: 14,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),

                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 25),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: filteredData[
                                                                            index]
                                                                        .emailId
                                                                        .toString() ==
                                                                    "null"
                                                                ? ""
                                                                : filteredData[
                                                                        index]
                                                                    .emailId
                                                                    .toString()
                                                                    .split(
                                                                        "||")[0],
                                                            size: 14,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 25),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: filteredData[
                                                                            index]
                                                                        .city
                                                                        .toString() ==
                                                                    "null"
                                                                ? ""
                                                                : filteredData[
                                                                        index]
                                                                    .city
                                                                    .toString(),
                                                            size: 14,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 25),
                                                          child: CustomText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: filteredData[
                                                                    index]
                                                                .companyName
                                                                .toString(),
                                                            size: 14,
                                                            colors: colorsConst
                                                                .textColor,
                                                          ),
                                                        ),
                                                        // Padding(
                                                        //   padding: const EdgeInsets.only(top: 25),
                                                        //   child: CustomText(
                                                        //     textAlign: TextAlign.center,
                                                        //     text:filteredData[index].status==null?"UnQualified":filteredData[index].status.toString(),
                                                        //     size: 14,
                                                        //     colors: colorsConst.textColor,
                                                        //   ),
                                                        // ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 25),
                                                          child: Center(
                                                            child: Container(
                                                              width: 65,
                                                              height: 20,
                                                              decoration: BoxDecoration(
                                                                  color: const Color(
                                                                      0xffFEDED8),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: const Color(
                                                                          0xffFE5C4C))),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: CustomText(
                                                                text: filteredData[index]
                                                                            .rating ==
                                                                        null
                                                                    ? "Warm"
                                                                    : filteredData[
                                                                            index]
                                                                        .rating
                                                                        .toString(),
                                                                colors: const Color(
                                                                    0xffFE5C4C),
                                                                size: 12,
                                                                isBold: true,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
            utils.funnelContainer(context)
          ],
        ),
      ),
    );
  }
}
