import 'package:flutter/material.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_loading_button.dart';
import '../components/custom_search_textfield.dart';
import '../components/custom_text.dart';
import '../components/keyboard_search.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        body: Container(
          width: controllers.isLeftOpen.value == false &&
              controllers.isRightOpen.value == false
              ? screenWidth - 200
              : screenWidth - 440,
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
                          CustomText(
                            text: "Calls",
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
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.add,color: Colors.white,),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorsConst.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: (){
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          text: "Add Call log",
                                          size: 16,
                                          isBold: true,
                                          colors: colorsConst.textColor,
                                        ),
                                        IconButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(Icons.clear,
                                              color: Colors.black,
                                            ))
                                      ],
                                    ),
                                    content: SizedBox(
                                      width: 500,
                                      height: 400,
                                      child: Column(
                                        children: [
                                          Divider(),
                                          SizedBox(
                                            width: 300,
                                            height: 50,
                                            child: KeyboardDropdownField<AllCustomersObj>(
                                              items: controllers.customers,
                                              borderRadius: 5,
                                              borderColor: Colors.grey.shade300,
                                              hintText: "Customers",
                                              labelText: "",
                                              labelBuilder: (customer) =>'${customer.name} - ${customer.phoneNo}',
                                              itemBuilder: (customer) =>
                                                  Container(
                                                    width: 300,
                                                    alignment: Alignment.topLeft,
                                                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                    child: CustomText(
                                                      text: '${customer.name} - ${customer.phoneNo}',
                                                      colors: Colors.black,
                                                      size: 14,
                                                      textAlign: TextAlign.start,
                                                    ),
                                                  ),
                                              textEditingController: controllers.cusController,
                                              onSelected: (value) {
                                                controllers.selectCustomer(value);
                                              },
                                              onClear: () {
                                                controllers.clearSelectedCustomer();
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: 300,
                                            height: 200,
                                            child: TextField(
                                              controller: controllers.callCommentCont,
                                              maxLines: null,
                                              expands: true,
                                              decoration: InputDecoration(
                                                hintText: "Enter your comments here",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                  borderSide: BorderSide(
                                                    color: colorsConst.textColor,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5),
                                                  borderSide: BorderSide(
                                                    color: colorsConst.textColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
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
                                                  size: 14,
                                                )),
                                          ),
                                          10.width,
                                          CustomLoadingButton(
                                            callback: (){
                                              apiService.insertCallCommentAPI(context, "7");
                                            },
                                            height: 35,
                                            isLoading: true,
                                            backgroundColor: colorsConst.primary,
                                            radius: 2,
                                            width: 80,
                                            controller: controllers.productCtr,
                                            isImage: false,
                                            text: "Save",
                                            textColor: Colors.white,
                                          ),
                                          5.width
                                        ],
                                      ),
                                    ],
                                  );
                                });
                          },
                          label: CustomText(
                            text: "Add Call log",
                            colors: Colors.white,
                            isBold :true,
                            size: 14,
                          ),),
                      )
                    ],
                  ),
                  10.height,
                  Row(
                    children: [
                      CustomText(
                        text: "Incoming",
                        colors: colorsConst.primary,
                        size: 15,
                      ),
                      10.width,
                      CircleAvatar(
                          backgroundColor: colorsConst.primary,
                          radius: 15,
                          child: Obx(
                                () => CustomText(
                              text: controllers.allDirectVisit.value,
                              colors: Colors.white,
                              size: 15,
                            ),
                          )),
                      10.width,
                      Container(
                        width: 1,
                        height: 22,
                        color: Colors.grey,
                      ),
                      10.width,
                      CustomText(
                        text: "Outgoing",
                        colors: colorsConst.textColor,
                        size: 15,
                      ),
                      10.width,
                      CircleAvatar(
                          backgroundColor: colorsConst.secondary,
                          radius: 15,
                          child: Obx(
                                () => CustomText(
                              text: controllers.allTelephoneCalls.value,
                              colors: colorsConst.primary,
                              size: 15,
                            ),
                          )),
                      10.width,
                      Container(
                        width: 1,
                        height: 22,
                        color: Colors.grey,
                      ),
                      10.width,
                      CustomText(
                        text: "Missed",
                        colors: colorsConst.textColor,
                        size: 15,
                      ),
                      10.width,
                      CircleAvatar(
                          backgroundColor: colorsConst.secondary,
                          radius: 15,
                          child: Obx(
                                () => CustomText(
                              text: controllers.allTelephoneCalls.value,
                              colors: colorsConst.primary,
                              size: 15,
                            ),
                          ))
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
                        hintText: "Search Name, Customer Name, Company Name, Mobile",
                        onChanged: (value) {
                          setState(() {
                            searchText = value.toString().trim();
                          });
                        },
                      ),
                      10.width,
                      // Obx(
                      //   () => Radio(
                      //       activeColor: colorsConst.third,
                      //       value: "All",
                      //       fillColor: WidgetStateProperty.resolveWith<Color?>(
                      //           (states) {
                      //         return colorsConst.third;
                      //       }),
                      //       groupValue: controllers.shortBy.value,
                      //       onChanged: (value) {
                      //         controllers.shortBy.value =
                      //             value.toString().trim();
                      //       }),
                      // ),
                      // CustomText(
                      //   text: "All",
                      //   colors: colorsConst.textColor,
                      // ),
                      Obx(
                        () => Radio(
                            activeColor: colorsConst.third,
                            value: "Completed",
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
                        text: "Completed",
                        colors: colorsConst.textColor,
                      ),
                      Obx(() => Radio(
                            activeColor: colorsConst.third,
                            value: "Missed",
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
                        text: "Missed",
                        colors: colorsConst.textColor,
                      ),
                      Obx(
                        () => Radio(
                            activeColor: colorsConst.third,
                            value: "Pending",
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
                        text: "Pending",
                        colors: colorsConst.textColor,
                      ),
                      20.width,
                      // Container(
                      //   decoration: BoxDecoration(
                      //       color: colorsConst.secondary,
                      //       borderRadius: BorderRadius.circular(10)),
                      //   child: Row(
                      //     children: [
                      //       IconButton(
                      //           onPressed: () {
                      //             // controllers.isAllContacts.value=true;
                      //             controllers.isCommentsLoading.value = false;
                      //             var data = DateTime.parse(
                      //                     "${controllers.stDate.value.split("-").last}-${controllers.stDate.value.split("-")[1]}-${controllers.stDate.value.split("-").first}")
                      //                 .subtract(const Duration(days: 1));
                      //             controllers.stDate.value =
                      //                 "${data.day.toString().padLeft(2, "0")}"
                      //                 "-${data.month.toString().padLeft(2, "0")}"
                      //                 "-${data.year.toString()}";
                      //             controllers.isCommentsLoading.value = true;
                      //             if (controllers.shortBy.value == "all") {
                      //               controllers.shortBy.value = "";
                      //             }
                      //           },
                      //           hoverColor: Colors.transparent,
                      //           icon: Icon(Icons.arrow_back_ios,
                      //               size: 17, color: colorsConst.third)),
                      //       // ),
                      //       Icon(
                      //         Icons.calendar_today_outlined,
                      //         size: 13,
                      //         color: colorsConst.textColor,
                      //       ),
                      //       InkWell(
                      //         onTap: () {
                      //           if (context.mounted) {
                      //             DateFormat inputFormat =
                      //                 DateFormat("dd-MM-yyyy");
                      //             DateTime parsedDate = inputFormat
                      //                 .parse(controllers.stDate.value);
                      //             controllers.dateTime = parsedDate;
                      //             showDatePicker(
                      //               context: context,
                      //               initialDate: controllers.dateTime,
                      //               firstDate: DateTime(2021),
                      //               lastDate: DateTime.now(),
                      //             ).then((value) {
                      //               //controllers.isAllContacts.value=true;
                      //               controllers.dateTime = value!;
                      //               controllers.isCommentsLoading.value = false;
                      //               controllers.stDate.value =
                      //                   "${controllers.dateTime.day.toString().padLeft(2, "0")}"
                      //                   "-${controllers.dateTime.month.toString().padLeft(2, "0")}"
                      //                   "-${controllers.dateTime.year.toString()}";
                      //               controllers.isCommentsLoading.value = true;
                      //               if (controllers.shortBy.value == "all") {
                      //                 controllers.shortBy.value = "";
                      //               }
                      //             });
                      //           }
                      //         },
                      //         child: Container(
                      //           height: 30,
                      //           padding: const EdgeInsets.fromLTRB(6, 2, 4, 2),
                      //           alignment: Alignment.center,
                      //           decoration: BoxDecoration(
                      //               color: colorsConst.secondary,
                      //               borderRadius: BorderRadius.circular(8),
                      //               border: Border.all(
                      //                   color: colorsConst.secondary)),
                      //           child: Obx(
                      //             () => CustomText(
                      //               text: " ${controllers.stDate.value}  ",
                      //               colors: colorsConst.textColor,
                      //               size: 12,
                      //               isBold: true,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       // Container(
                      //       //   width:30,
                      //       //   height: 30,
                      //       //   alignment: Alignment.center,
                      //       //   decoration: BoxDecoration(
                      //       //       color: dateCheck()?colorsConst.secondary:colorsConst.primary,
                      //       //       borderRadius: BorderRadius.circular(8),
                      //       //       border: Border.all(
                      //       //           color: colorsConst.secondary
                      //       //       )
                      //       //   ),
                      //       //   child:
                      //       Obx(
                      //         () => IconButton(
                      //             onPressed: () {
                      //               if (dateCheck()) {
                      //                 // controllers.isAllContacts.value=true;
                      //                 controllers.isCommentsLoading.value =
                      //                     false;
                      //                 var data = DateTime.parse(
                      //                         "${controllers.stDate.value.split("-").last}-${controllers.stDate.value.split("-")[1]}-${controllers.stDate.value.split("-").first}")
                      //                     .add(const Duration(days: 1));
                      //                 controllers.stDate.value =
                      //                     "${data.day.toString().padLeft(2, "0")}"
                      //                     "-${data.month.toString().padLeft(2, "0")}"
                      //                     "-${data.year.toString()}";
                      //                 controllers.isCommentsLoading.value =
                      //                     true;
                      //                 if (controllers.shortBy.value == "all") {
                      //                   controllers.shortBy.value = "";
                      //                 }
                      //               }
                      //             },
                      //             hoverColor: Colors.transparent,
                      //             icon: Icon(
                      //               Icons.arrow_forward_ios,
                      //               size: 16,
                      //               color: dateCheck()
                      //                   ? colorsConst.third
                      //                   : Colors.grey,
                      //             )),
                      //       ),
                      //       //)
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  15.height,
                      // Table Header
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                            color: colorsConst.primary,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5))
                        ),
                        //padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            utils.headerCell(width: 155, text: "Date",
                              isSortable: true,
                              fieldName: 'sourceOfProspect',
                              sortField: controllers.sortField,
                              sortOrder: controllers.sortOrder,
                              onSortAsc: () {
                                controllers.sortField.value = 'sourceOfProspect';
                                controllers.sortOrder.value = 'asc';
                              },
                              onSortDesc: () {
                                controllers.sortField.value = 'sourceOfProspect';
                                controllers.sortOrder.value = 'desc';
                              },
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              width: 1,
                            ),
                            utils.headerCell(
                              width: 160, text: "Customer Name",
                              isSortable: true,
                              fieldName: 'name',
                              sortField: controllers.sortField,
                              sortOrder: controllers.sortOrder,
                              onSortAsc: () {
                                controllers.sortField.value = 'name';
                                controllers.sortOrder.value = 'asc';
                              },
                              onSortDesc: () {
                                controllers.sortField.value = 'name';
                                controllers.sortOrder.value = 'desc';
                              },
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              width: 1,
                            ),
                            utils.headerCell(width: 140, text: "Mobile No.",
                              fieldName: 'companyName',
                              sortField: controllers.sortField,
                              sortOrder: controllers.sortOrder,
                              isSortable: true,
                              onSortAsc: () {
                                controllers.sortField.value = 'companyName';
                                controllers.sortOrder.value = 'asc';
                              },
                              onSortDesc: () {
                                controllers.sortField.value = 'companyName';
                                controllers.sortOrder.value = 'desc';
                              },
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              width: 1,
                            ),
                            utils.headerCell(width: 120, text: "Call Type",
                              fieldName: 'companyName',
                              sortField: controllers.sortField,
                              sortOrder: controllers.sortOrder,
                              isSortable: true,
                              onSortAsc: () {
                                controllers.sortField.value = 'companyName';
                                controllers.sortOrder.value = 'asc';
                              },
                              onSortDesc: () {
                                controllers.sortField.value = 'companyName';
                                controllers.sortOrder.value = 'desc';
                              },
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              width: 1,
                            ),
                            utils.headerCell(width: 200, text: "Message",
                              isSortable: true,
                              fieldName: 'serviceRequired',
                              sortField: controllers.sortField,
                              sortOrder: controllers.sortOrder,
                              onSortAsc: () {
                                controllers.sortField.value = 'serviceRequired';
                                controllers.sortOrder.value = 'asc';
                              },
                              onSortDesc: () {
                                controllers.sortField.value = 'serviceRequired';
                                controllers.sortOrder.value = 'desc';
                              },
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              width: 1,
                            ),
                            utils.headerCell(width: 90, text: "Status",
                              fieldName: 'companyName',
                              sortField: controllers.sortField,
                              sortOrder: controllers.sortOrder,
                              isSortable: true,
                              onSortAsc: () {
                                controllers.sortField.value = 'companyName';
                                controllers.sortOrder.value = 'asc';
                              },
                              onSortDesc: () {
                                controllers.sortField.value = 'companyName';
                                controllers.sortOrder.value = 'desc';
                              },
                            ),
                            VerticalDivider(
                              color: Colors.grey,
                              width: 1,
                            ),
                            CustomText(
                              text: "Actions",
                              size: 15,
                              isBold: true,
                              textAlign: TextAlign.center,
                              colors: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      // Table Body
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 400,
                        child: ListView.builder(
                          itemCount: controllers.callActivity.length,
                          itemBuilder: (context, index) {
                            final data = controllers.callActivity[index];
                            return Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: index % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                              ),
                              child: Row(
                                children: [
                                  utils.dataCell(width: 155, text: data.sentDate),
                                  VerticalDivider(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  utils.dataCell(width: 160, text: data.customerName),
                                  VerticalDivider(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  utils.dataCell(width: 140, text: data.toData),
                                  VerticalDivider(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  utils.dataCell(width: 120, text: "Incoming"),
                                  VerticalDivider(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  utils.dataCell(width: 200, text: data.message),
                                  VerticalDivider(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  utils.dataCell(width: 90, text: "Completed"),

                                ],
                              ),
                            );
                          },
                        ),
                      ),

                  20.height,
                ],
              ),
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
