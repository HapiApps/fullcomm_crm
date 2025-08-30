import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/mail_receive_obj.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../components/custom_comment_container.dart';
import '../components/custom_text.dart';
import '../controller/controller.dart';

class MailComments extends StatefulWidget {
  final String? id;
  final String? mainName;
  final String? mainMobile;
  final String? mainEmail;
  final String? city;
  final String? companyName;
  const MailComments(
      {super.key,
      this.id,
      this.mainName,
      this.mainMobile,
      this.mainEmail,
      this.city,
      this.companyName});

  @override
  State<MailComments> createState() => _MailCommentsState();
}

class _MailCommentsState extends State<MailComments> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isWebView = screenWidth > screenHeight;
    screenWidth > screenHeight ? screenWidth * 0.30 : screenWidth * 0.90;
    return SelectionArea(
      child: Scaffold(
        body: Obx(() => Container(
                width: controllers.isLeftOpen.value == false &&
                        controllers.isRightOpen.value == false
                    ? MediaQuery.of(context).size.width - 200
                    : MediaQuery.of(context).size.width - 490,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.height,
                    const CustomText(
                      text: "Mail Activity Report",
                      colors: Color(0xffE1E5FA),
                      isBold: true,
                      size: 20,
                    ),
                    20.height,
                    CustomText(
                      text: "View all Mail Activity Report ",
                      colors: colorsConst.textColor,
                      size: 14,
                    ),
                    15.height,
                    // Table Header
                    Container(
                      decoration: BoxDecoration(
                          color: colorsConst.primary,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          utils.headerCell(
                            width: 150, text: "Customer Name",
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
                          utils.headerCell(width: 180, text: "To data",
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
                          utils.headerCell(width: 180, text: "From Data",
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
                          utils.headerCell(width: 260, text: "Comments",
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
                          utils.headerCell(width: 200, text: "Added Date",
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

                        ],
                      ),
                    ),
                    10.height,
                    // Table Body
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 400,
                      child: ListView.separated(
                        separatorBuilder: (context, index) {
                          return 5.height;
                        },
                        itemCount: controllers.mailActivity.length,
                        itemBuilder: (context, index) {
                          final data = controllers.mailActivity[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? Colors.white : const Color(0xffD9EEFF),
                            ),
                            child: Row(
                              children: [
                                utils.dataCell(width: 150, text: data.customerName),
                                utils.dataCell(width: 180, text: data.toData),
                                utils.dataCell(width: 180, text: data.fromData),
                                utils.dataCell(width: 260, text: data.message),
                                utils.dataCell(width: 200, text: data.sentDate)
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

      ),
    );
  }
}
