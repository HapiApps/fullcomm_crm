import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/services/api_services.dart';
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             CustomText(
                              text: "All Mails",
                              colors: colorsConst.textColor,
                              isBold: true,
                              size: 25,
                            ),
                            10.height,
                            CustomText(
                              text: "View all Mail Activity Report ",
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
                              utils.sendEmailDialog(id: "1", name: "Customer",
                                  mobile:"Customer", coName: "Customer");
                            },
                            label: CustomText(
                              text: "Compose Mail",
                              colors: Colors.white,
                              isBold :true,
                              size: 14,
                            ),),
                        )
                      ],
                    ),
                    20.height,
                    Row(
                      children: [
                        Obx(()=> utils.selectHeatingType("Sent", controllers.isSent.value, (){
                          apiService.getAllMailActivity();
                        }, false,controllers.allSentMails),),
                        10.width,
                        Obx(()=>utils.selectHeatingType("Opened", controllers.isOpened.value, (){
                          apiService.getOpenedMailActivity(false);
                        }, false,controllers.allOpenedMails),),
                        10.width,
                      Obx(()=> utils.selectHeatingType("Replied", controllers.isReplied.value, (){
                        apiService.getReplyMailActivity(false);
                      }, true,controllers.allReplyMails),)
                      ],
                    ),
                    15.height,
                    Divider(color: Colors.grey, height: 1,),
                    15.height,
                    // Table Header
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: colorsConst.primary,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5))
                      ),
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
                            width: 0.5,
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
                            width: 0.5,
                          ),
                          utils.headerCell(width: 160, text: "Sent Mail",
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
                            width: 0.5,
                          ),
                          utils.headerCell(width: 160, text: "Subject",
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
                            width: 0.5,
                          ),
                          utils.headerCell(width: 230, text: "Message",
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
                            width: 0.5,
                          ),

                          Container(
                            width: 160,
                            alignment: Alignment.center,
                            child: CustomText(
                              text: "Actions",
                              size: 15,
                              isBold: true,
                              textAlign: TextAlign.center,
                              colors: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Body
                    Obx(()=>controllers.isMailLoading.value?
                    Center(child:CircularProgressIndicator()):
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 400,
                      child: ListView.builder(
                        itemCount: controllers.mailActivity.length,
                        itemBuilder: (context, index) {
                          final data = controllers.mailActivity[index];
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
                                  width: 0.5,
                                ),
                                utils.dataCell(width: 160, text: data.customerName),
                                VerticalDivider(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                utils.dataCell(width: 160, text: data.toData),
                                VerticalDivider(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                utils.dataCell(width: 160, text: data.subject),
                                VerticalDivider(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                utils.dataCell(width: 230, text: data.message),
                                VerticalDivider(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: (){},
                                          icon: SvgPicture.asset("assets/images/reply.svg")),
                                      IconButton(
                                          onPressed: (){},
                                          icon: SvgPicture.asset("assets/images/forward.svg")),
                                      IconButton(
                                          onPressed: (){},
                                          icon: Icon(Icons.delete_outline_sharp,color: Colors.red,))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),)
                  ],
                ),
              ),
            ),

      ),
    );
  }
}
