import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_search_textfield.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';

class CallComments extends StatefulWidget {
  const CallComments({super.key});

  @override
  State<CallComments> createState() => _CallCommentsState();
}

class _CallCommentsState extends State<CallComments> {
  bool dateCheck() {
    return controllers.stDate.value !=
        "${DateTime.now().day.toString().padLeft(2, "0")}"
            "-${DateTime.now().month.toString().padLeft(2, "0")}"
            "-${DateTime.now().year.toString()}";
  }

  String searchText = "";
  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.height,
                  Row(
                    children: [
                      Column(
                        children: [
                          CustomText(
                            text: "Call Activity Report",
                            colors: colorsConst.textColor,
                            size: 20,
                            isBold: true,
                          ),
                          10.height,
                          CustomText(
                            text: "View all Call Activity Report ",
                            colors: colorsConst.textColor,
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                  10.height,
                  Row(
                    children: [
                      //
                      Container(
                        width: 130,
                        height: 50,
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            CustomText(
                              text: "Direct Visit",
                              colors: colorsConst.third,
                              size: 15,
                            ),
                            10.width,
                            CircleAvatar(
                                backgroundColor:
                                    const Color(0xffFFC700).withOpacity(0.10),
                                radius: 15,
                                child: Obx(
                                  () => CustomText(
                                    text: controllers.allDirectVisit.value,
                                    colors: colorsConst.third,
                                    size: 15,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      10.width,
                      Container(
                        width: 1,
                        height: 30,
                        color: colorsConst.secondary,
                      ),
                      20.width,
                      Container(
                        width: 150,
                        height: 50,
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            CustomText(
                              text: "Telephonic Call",
                              colors: colorsConst.third,
                              size: 15,
                            ),
                            10.width,
                            CircleAvatar(
                                backgroundColor:
                                    const Color(0xffFFC700).withOpacity(0.10),
                                radius: 15,
                                child: Obx(
                                  () => CustomText(
                                    text: controllers.allTelephoneCalls.value,
                                    colors: colorsConst.third,
                                    size: 15,
                                  ),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                  5.height,
                  Divider(
                    thickness: 1.5,
                    color: colorsConst.secondary,
                  ),
                  5.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomSearchTextField(
                        controller: controllers.search,
                        hintText:
                            "Search Name, Customer Name, Company Name, Mobile",
                        onChanged: (value) {
                          setState(() {
                            searchText = value.toString().trim();
                          });
                        },
                      ),
                      10.width,
                      Obx(
                        () => Radio(
                            activeColor: colorsConst.third,
                            value: "All",
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              return colorsConst.third;
                            }),
                            groupValue: controllers.shortBy.value,
                            onChanged: (value) {
                              controllers.shortBy.value =
                                  value.toString().trim();
                            }),
                      ),
                      CustomText(
                        text: "All",
                        colors: colorsConst.textColor,
                      ),
                      Obx(
                        () => Radio(
                            activeColor: colorsConst.third,
                            value: "Name",
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              return colorsConst.third;
                            }),
                            groupValue: controllers.shortBy.value,
                            onChanged: (value) {
                              controllers.shortBy.value =
                                  value.toString().trim();
                            }),
                      ),
                      CustomText(
                        text: "Name",
                        colors: colorsConst.textColor,
                      ),
                      Obx(
                        () => Radio(
                            activeColor: colorsConst.third,
                            value: "Company Name",
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              return colorsConst.third;
                            }),
                            groupValue: controllers.shortBy.value,
                            onChanged: (value) {
                              controllers.shortBy.value =
                                  value.toString().trim();
                            }),
                      ),
                      CustomText(
                        text: "Company Name",
                        colors: colorsConst.textColor,
                      ),
                      Obx(
                        () => Radio(
                            activeColor: colorsConst.third,
                            value: "Customer Name",
                            fillColor: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                              return colorsConst.third;
                            }),
                            groupValue: controllers.shortBy.value,
                            onChanged: (value) {
                              controllers.shortBy.value =
                                  value.toString().trim();
                            }),
                      ),
                      CustomText(
                        text: "Customer Name",
                        colors: colorsConst.textColor,
                      ),
                      20.width,
                      Container(
                        decoration: BoxDecoration(
                            color: colorsConst.secondary,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  // controllers.isAllContacts.value=true;
                                  controllers.isCommentsLoading.value = false;
                                  var data = DateTime.parse(
                                          "${controllers.stDate.value.split("-").last}-${controllers.stDate.value.split("-")[1]}-${controllers.stDate.value.split("-").first}")
                                      .subtract(const Duration(days: 1));
                                  controllers.stDate.value =
                                      "${data.day.toString().padLeft(2, "0")}"
                                      "-${data.month.toString().padLeft(2, "0")}"
                                      "-${data.year.toString()}";
                                  controllers.isCommentsLoading.value = true;
                                  if (controllers.shortBy.value == "all") {
                                    controllers.shortBy.value = "";
                                  }
                                },
                                hoverColor: Colors.transparent,
                                icon: Icon(Icons.arrow_back_ios,
                                    size: 17, color: colorsConst.third)),
                            // ),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: colorsConst.textColor,
                            ),
                            InkWell(
                              onTap: () {
                                if (context.mounted) {
                                  DateFormat inputFormat =
                                      DateFormat("dd-MM-yyyy");
                                  DateTime parsedDate = inputFormat
                                      .parse(controllers.stDate.value);
                                  controllers.dateTime = parsedDate;
                                  showDatePicker(
                                    context: context,
                                    initialDate: controllers.dateTime,
                                    firstDate: DateTime(2021),
                                    lastDate: DateTime.now(),
                                  ).then((value) {
                                    //controllers.isAllContacts.value=true;
                                    controllers.dateTime = value!;
                                    controllers.isCommentsLoading.value = false;
                                    controllers.stDate.value =
                                        "${controllers.dateTime.day.toString().padLeft(2, "0")}"
                                        "-${controllers.dateTime.month.toString().padLeft(2, "0")}"
                                        "-${controllers.dateTime.year.toString()}";
                                    controllers.isCommentsLoading.value = true;
                                    if (controllers.shortBy.value == "all") {
                                      controllers.shortBy.value = "";
                                    }
                                  });
                                }
                              },
                              child: Container(
                                height: 30,
                                padding: const EdgeInsets.fromLTRB(6, 2, 4, 2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: colorsConst.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: colorsConst.secondary)),
                                child: Obx(
                                  () => CustomText(
                                    text: " ${controllers.stDate.value}  ",
                                    colors: colorsConst.textColor,
                                    size: 12,
                                    isBold: true,
                                  ),
                                ),
                              ),
                            ),
                            // Container(
                            //   width:30,
                            //   height: 30,
                            //   alignment: Alignment.center,
                            //   decoration: BoxDecoration(
                            //       color: dateCheck()?colorsConst.secondary:colorsConst.primary,
                            //       borderRadius: BorderRadius.circular(8),
                            //       border: Border.all(
                            //           color: colorsConst.secondary
                            //       )
                            //   ),
                            //   child:
                            Obx(
                              () => IconButton(
                                  onPressed: () {
                                    if (dateCheck()) {
                                      // controllers.isAllContacts.value=true;
                                      controllers.isCommentsLoading.value =
                                          false;
                                      var data = DateTime.parse(
                                              "${controllers.stDate.value.split("-").last}-${controllers.stDate.value.split("-")[1]}-${controllers.stDate.value.split("-").first}")
                                          .add(const Duration(days: 1));
                                      controllers.stDate.value =
                                          "${data.day.toString().padLeft(2, "0")}"
                                          "-${data.month.toString().padLeft(2, "0")}"
                                          "-${data.year.toString()}";
                                      controllers.isCommentsLoading.value =
                                          true;
                                      if (controllers.shortBy.value == "all") {
                                        controllers.shortBy.value = "";
                                      }
                                    }
                                  },
                                  hoverColor: Colors.transparent,
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: dateCheck()
                                        ? colorsConst.third
                                        : Colors.grey,
                                  )),
                            ),
                            //)
                          ],
                        ),
                      ),
                    ],
                  ),
                  15.height,
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2.5),
                      3: FlexColumnWidth(2.5),
                      4: FlexColumnWidth(2.5),
                      5: FlexColumnWidth(2.5),
                      6: FlexColumnWidth(2.5),
                      7: FlexColumnWidth(3),
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
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nReport Date\n",
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
                              text: "\nCompany Name.\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nCustomer Name\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nMobile Number\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: "\nComments\n",
                              size: 15,
                              isBold: true,
                              colors: colorsConst.textColor,
                            ),
                          ]),
                    ],
                  ),
                  8.height,
                  Obx(
                    () => controllers.isCommentsLoading.value == false
                        ? Center(
                            child: CircularProgressIndicator(
                            color: colorsConst.third,
                          ))
                        : Expanded(
                            //height: MediaQuery.of(context).size.height/1.5,
                            child: FutureBuilder<List<CommentsObj>>(
                              future: controllers.customCommentsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  DateTime startDate = DateFormat('dd-MM-yyyy')
                                      .parse(controllers.stDate.value);
                                  DateTime currentDate = DateTime.now();
                                  List<CommentsObj> filteredComments = [];
                                  filteredComments = snapshot.data!.toList();
                                  // if(controllers.shortBy.value=="All"){
                                  //   filteredComments = filteredComments;
                                  // }else{
                                  //   if(controllers.shortBy.value=="Name"){
                                  //     filteredComments = List.from(filteredComments)
                                  //       ..sort((a, b) => b.firstname.toString().compareTo(a.name.toString()));
                                  //   }else if(controllers.shortBy.value=="Company Name"){
                                  //     filteredComments = List.from(filteredComments)
                                  //       ..sort((a, b) => b.companyName.toString().compareTo(a.name.toString()));
                                  //   }else{
                                  //     filteredComments = List.from(filteredComments)
                                  //       ..sort((a, b) => b.name.toString().compareTo(a.name.toString()));
                                  //   }
                                  // }
                                  if (controllers.stDate.value ==
                                      "${currentDate.day.toString().padLeft(2, "0")}"
                                          "-${currentDate.month.toString().padLeft(2, "0")}"
                                          "-${currentDate.year.toString()}") {
                                    filteredComments = filteredComments;
                                  } else {
                                    filteredComments =
                                        filteredComments.where((contact) {
                                      DateTime contactDate =
                                          DateFormat('yyyy-MM-dd').parse(contact
                                              .updateTs
                                              .toString()
                                              .split(' ')[0]);
                                      return contactDate.isAfter(startDate) &&
                                          contactDate.isBefore(currentDate) &&
                                          _isContactMatchingSearch(
                                              contact, searchText);
                                    }).toList();
                                  }

                                  // if(filteredComments.isNotEmpty){
                                  filteredComments =
                                      filteredComments.where((contact) {
                                    return _isContactMatchingSearch(
                                        contact, searchText);
                                  }).toList();
                                  //}
                                  //countCheck(filteredComments);

                                  return ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return 8.height;
                                      },
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics(),
                                      itemCount: filteredComments.length,
                                      itemBuilder: (context, index) {
                                        var data = filteredComments[index];
                                        String inputDate =
                                            data.createdTs.toString();
                                        DateTime parsedDate =
                                            DateTime.parse(inputDate);

                                        String formattedDate =
                                            DateFormat("MMM d, yyyy  hh:mm a")
                                                .format(parsedDate.toLocal());

                                        return Table(
                                          columnWidths: const {
                                            0: FlexColumnWidth(2.5),
                                            1: FlexColumnWidth(2),
                                            2: FlexColumnWidth(2.5),
                                            3: FlexColumnWidth(2.5),
                                            4: FlexColumnWidth(2.5),
                                            5: FlexColumnWidth(2.5),
                                            6: FlexColumnWidth(2.5),
                                            7: FlexColumnWidth(3),
                                          },
                                          // border:TableBorder.all(
                                          //     color: colorsConst.primary,
                                          //     width: 5
                                          // ),
                                          children: [
                                            TableRow(
                                                decoration: BoxDecoration(
                                                  color: colorsConst.secondary,
                                                ),
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            const Color(
                                                                0xffAFC8D9),
                                                        radius: 13,
                                                        child: Icon(
                                                          data.type == "1"
                                                              ? Icons
                                                                  .person_outline
                                                              : Icons.call,
                                                          color: colorsConst
                                                              .primary,
                                                          size: 13,
                                                        ),
                                                      ),
                                                      60.height,
                                                      8.width,
                                                      Container(
                                                        height: 30,
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                5, 5, 5, 5),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: const Color(
                                                                0xffAFC8D9),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                        child: CustomText(
                                                          //textAlign: TextAlign.start,
                                                          text: formattedDate,
                                                          colors: colorsConst
                                                              .primary,
                                                          size: 12,
                                                          isBold: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text:
                                                        "\n${data.firstname}\n",
                                                    size: 14,
                                                    colors:
                                                        const Color(0xffE1E5FA),
                                                  ),
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text:
                                                        "\n${data.companyName}\n",
                                                    size: 14,
                                                    colors:
                                                        const Color(0xffE1E5FA),
                                                  ),
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "\n${data.name}\n",
                                                    size: 14,
                                                    colors:
                                                        const Color(0xffE1E5FA),
                                                  ),
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "\n${data.phoneNo}\n",
                                                    size: 14,
                                                    colors:
                                                        const Color(0xffE1E5FA),
                                                  ),
                                                  Tooltip(
                                                    message: data.comments,
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20),
                                                    verticalOffset: -50,
                                                    textStyle: TextStyle(
                                                        color: colorsConst
                                                            .textColor,
                                                        fontSize: 12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      "\n${data.comments}\n",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xffE1E5FA),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          ],
                                        );
                                      });
                                } else if (snapshot.hasError) {
                                  print("error ${snapshot.error}");
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
                                return Center(
                                    child: CircularProgressIndicator(
                                  color: colorsConst.third,
                                ));
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

  bool _isContactMatchingSearch(CommentsObj contact, String searchText) {
    List<String> keywords = searchText.toLowerCase().split(' ');
    String firstName = contact.firstname.toString().toLowerCase();
    String coName = contact.companyName.toString().toLowerCase();
    String customerName = contact.name.toString().toLowerCase();
    String mobile = contact.phoneNo.toString().toLowerCase();
    String comment = contact.comments.toString().toLowerCase();

    return keywords.every((keyword) =>
        firstName.contains(keyword) ||
        coName.contains(keyword) ||
        customerName.contains(keyword) ||
        mobile.contains(keyword) ||
        comment.contains(keyword));
  }

  void countCheck(List<CommentsObj> contact) {
    if (contact.isNotEmpty) {
      var type1Count = contact.where((item) => item.type == "1").length;
      var type2Count = contact.where((item) => item.type == "2").length;
      controllers.allDirectVisit.value = type1Count.toString();
      controllers.allTelephoneCalls.value = type2Count.toString();
    }
  }
}
