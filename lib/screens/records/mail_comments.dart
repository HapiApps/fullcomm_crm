import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/constant/api.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../components/date_filter_bar.dart';
import '../../controller/controller.dart';
import '../../controller/reminder_controller.dart';

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
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    Future.delayed(Duration.zero,(){
      apiService.currentVersion();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isWebView = screenWidth > screenHeight;
    screenWidth > screenHeight ? screenWidth * 0.30 : screenWidth * 0.90;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controllers.selectedIndex.value = controllers.oldIndex.value;
        }
      },
      child: SelectionArea(
        child: Scaffold(
          body: Container(
                  width:MediaQuery.of(context).size.width - 150,
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                 isCopy: true,
                              ),
                              5.height,
                              CustomText(
                                text: "View all Mail Activity Report ",
                                colors: colorsConst.textColor,
                                isCopy: true,
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
                                utils.showComposeMail(context);
                                // utils.sendEmailDialog(id: "1", name: "Customer",
                                //     mobile:"Customer", coName: "Customer");
                              },
                              label: CustomText(
                                text: "Compose Mail",
                                colors: Colors.white,
                                isBold :true,
                                size: 14,
                                isCopy: false,
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
                        }, true,controllers.allReplyMails),),

                          remController.selectedRecordMailIds.isNotEmpty?
                          InkWell(
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: (){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: CustomText(
                                      text: "Are you sure delete this Mail record?",
                                      size: 16,
                                      isBold: true,
                                      isCopy: true,
                                      colors: colorsConst.textColor,
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
                                                  isCopy: false,
                                                )),
                                          ),
                                          10.width,
                                          CustomLoadingButton(
                                            callback: ()async{
                                              remController.deleteRecordMailAPI(context);
                                            },
                                            height: 35,
                                            isLoading: true,
                                            backgroundColor: colorsConst.primary,
                                            radius: 2,
                                            width: 80,
                                            controller: controllers.productCtr,
                                            isImage: false,
                                            text: "Delete",
                                            textColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 100,
                              decoration: BoxDecoration(
                                color: colorsConst.secondary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/action_delete.png"),
                                  10.width,
                                  CustomText(
                                    text: "Delete",
                                    colors: colorsConst.textColor,
                                    size: 14,
                                    isBold: true,
                                    isCopy: false,
                                  ),
                                ],
                              ),
                            ),
                          ):1.width,
                        ],
                      ),
                      15.height,
                      Divider(color: Colors.grey, height: 1,),
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomSearchTextField(
                            controller: controllers.search,
                            hintText: "Search Email, Subject",
                            onChanged: (value) {
                              remController.searchText.value = value.toString().trim();
                            },
                          ),
                          DateFilterBar(
                            selectedSortBy: remController.selectedMailSortBy,
                            selectedRange: remController.selectedMailRange,
                            selectedMonth: remController.selectedMailMonth,
                            focusNode: _focusNode,
                            onDaysSelected: () {
                              remController.sortMails();
                            },
                            onSelectMonth: () {
                              remController.selectMonth(
                                context,
                                remController.selectedMailSortBy,
                                remController.selectedMailMonth,
                                    () {
                                  remController.sortMails();
                                },
                              );
                            },
                            onSelectDateRange: (ctx) {
                              remController.showDatePickerDialog(ctx, (pickedRange) {
                                remController.selectedMailRange.value = pickedRange;
                                remController.sortMails();
                              });
                            },
                          )
                        ],
                      ),
                      15.height,
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),//date
                          1: FlexColumnWidth(2),//Mobile No.
                          2: FlexColumnWidth(3),//Call Type
                          3: FlexColumnWidth(4.5),//Message
                          4: FlexColumnWidth(4),//Attachment
                        },
                        border: TableBorder(
                          horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                          verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                        ),
                        children: [
                          TableRow(
                              decoration: BoxDecoration(
                                  color: colorsConst.primary,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5))),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      CustomText(
                                        textAlign: TextAlign.left,
                                        text: "Sent Mail",
                                        size: 15,
                                        isBold: true,
                                        isCopy: false,
                                        colors: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      GestureDetector(
                                        onTap: (){
                                          if(remController.sortFieldCallActivity.value=='mail' && remController.sortOrderCallActivity.value=='asc'){
                                            remController.sortOrderCallActivity.value='desc';
                                          }else{
                                            remController.sortOrderCallActivity.value='asc';
                                          }
                                          remController.sortFieldCallActivity.value='mail';
                                          remController.sortMails();
                                        },
                                        child: Obx(() => Image.asset(
                                          controllers.sortFieldCallActivity.value.isEmpty
                                              ? "assets/images/arrow.png"
                                              : controllers.sortOrderCallActivity.value == 'asc'
                                              ? "assets/images/arrow_up.png"
                                              : "assets/images/arrow_down.png",
                                          width: 15,
                                          height: 15,
                                        ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      CustomText(
                                        textAlign: TextAlign.left,
                                        text: "Subject",
                                        size: 15,
                                        isBold: true,
                                        isCopy: true,
                                        colors: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      GestureDetector(
                                        onTap: (){
                                          if(remController.sortFieldCallActivity.value=='subject' && remController.sortOrderCallActivity.value=='asc'){
                                            remController.sortOrderCallActivity.value='desc';
                                          }else{
                                            remController.sortOrderCallActivity.value='asc';
                                          }
                                          remController.sortFieldCallActivity.value='subject';
                                          remController.sortMails();
                                        },
                                        child: Obx(() => Image.asset(
                                          controllers.sortFieldCallActivity.value.isEmpty
                                              ? "assets/images/arrow.png"
                                              : controllers.sortOrderCallActivity.value == 'asc'
                                              ? "assets/images/arrow_up.png"
                                              : "assets/images/arrow_down.png",
                                          width: 15,
                                          height: 15,
                                        ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      CustomText(
                                        textAlign: TextAlign.left,
                                        text: "Message",
                                        size: 15,
                                        isBold: true,
                                        isCopy: true,
                                        colors: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      GestureDetector(
                                        onTap: (){
                                          if(remController.sortFieldCallActivity.value=='msg' && remController.sortOrderCallActivity.value=='asc'){
                                            remController.sortOrderCallActivity.value='desc';
                                          }else{
                                            remController.sortOrderCallActivity.value='asc';
                                          }
                                          remController.sortFieldCallActivity.value='msg';
                                          remController.sortMails();
                                        },
                                        child: Obx(() => Image.asset(
                                          controllers.sortFieldCallActivity.value.isEmpty
                                              ? "assets/images/arrow.png"
                                              : controllers.sortOrderCallActivity.value == 'asc'
                                              ? "assets/images/arrow_up.png"
                                              : "assets/images/arrow_down.png",
                                          width: 15,
                                          height: 15,
                                        ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Attachment",
                                    size: 15,
                                    isBold: true,
                                    isCopy: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          CustomText(
                                            textAlign: TextAlign.center,
                                            text: "Date",
                                            size: 15,
                                            isBold: true,
                                            isCopy: true,
                                            colors: Colors.white,
                                          ),
                                          const SizedBox(width: 3),
                                          GestureDetector(
                                            onTap: (){
                                              if(remController.sortFieldCallActivity.value=='date' && remController.sortOrderCallActivity.value=='asc'){
                                                remController.sortOrderCallActivity.value='desc';
                                              }else{
                                                remController.sortOrderCallActivity.value='asc';
                                              }
                                              remController.sortFieldCallActivity.value='date';
                                              remController.sortMails();
                                            },
                                            child: Obx(() => Image.asset(
                                              controllers.sortFieldCallActivity.value.isEmpty
                                                  ? "assets/images/arrow.png"
                                                  : controllers.sortOrderCallActivity.value == 'asc'
                                                  ? "assets/images/arrow_up.png"
                                                  : "assets/images/arrow_down.png",
                                              width: 15,
                                              height: 15,
                                            ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                      Expanded(
                          child: Obx((){
                            final searchText = remController.searchText.value.toLowerCase();
                            final filteredList = remController.mailFilteredList.where((activity) {
                              final matchesSearch = searchText.isEmpty ||
                                  (activity.toData.toString().toLowerCase().contains(searchText)) ||
                                  (activity.subject.toString().toLowerCase().contains(searchText));
                              return matchesSearch;
                            }).toList();
                            return controllers.isMailLoading.value?
                            Center(child:CircularProgressIndicator()):filteredList.isEmpty?
                            Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: SvgPicture.asset(
                                    "assets/images/noDataFound.svg"))
                                :RawKeyboardListener(
                              focusNode: _focusNode,
                              autofocus: true,
                              onKey: (event) {
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
                              child: ListView.builder(
                                controller: _controller,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final data = filteredList[index];
                                  return Table(
                                    columnWidths:const {
                                      0: FlexColumnWidth(3),//date
                                      1: FlexColumnWidth(2),//Mobile No.
                                      2: FlexColumnWidth(3),//Call Type
                                      3: FlexColumnWidth(4.5),//Message
                                      4: FlexColumnWidth(4),//Attachment
                                    },
                                    border: TableBorder(
                                      horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                      verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                      bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                    ),
                                    children:[
                                      TableRow(
                                          decoration: BoxDecoration(
                                            color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                          ),
                                          children:[
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: CustomText(
                                                textAlign: TextAlign.left,
                                                isCopy: true,
                                                text:data.toData.toString()=="null"?"":data.toData.toString(),
                                                size: 14,
                                                colors: colorsConst.textColor,
                                              ),
                                            ),
                                            Tooltip(
                                              message: data.subject.toString()=="null"?"":data.subject.toString(),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: CustomText(
                                                  textAlign: TextAlign.left,
                                                  isCopy: true,
                                                  text: data.subject.toString(),
                                                  size: 14,
                                                  colors:colorsConst.textColor,
                                                ),
                                              ),
                                            ),
                                            Tooltip(
                                              message: data.message.toString()=="null"?"":data.message.toString(),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: CustomText(
                                                  isCopy: true,
                                                  textAlign: TextAlign.left,
                                                  text: data.message.toString(),
                                                  size: 14,
                                                  colors:colorsConst.textColor,
                                                ),
                                              ),
                                            ),
                                            data.attachment.isNotEmpty
                                                ? Builder(
                                              builder: (context) {
                                                final file = data.attachment.toLowerCase();
                                                final pdfUrl = "$getImage?path=${Uri.encodeComponent(data.attachment)}";
                                                if (file.endsWith(".pdf")) {
                                                  return InkWell(
                                                    onTap: () async {
                                                      if (await canLaunchUrl(Uri.parse(pdfUrl))) {
                                                        await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.platformDefault);
                                                      } else {
                                                        print('Could not launch $pdfUrl');
                                                        utils.snackBar(context: context, msg: 'Could not launch $pdfUrl', color: Colors.red);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                                                          const SizedBox(height: 5),
                                                          const Text("View PDF", style: TextStyle(fontSize: 12)),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                } else if (file.endsWith(".jpg") ||
                                                    file.endsWith(".jpeg") ||
                                                    file.endsWith(".png")) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 5),
                                                    child: Image.network(
                                                      "$getImage?path=${Uri.encodeComponent(data.attachment)}",
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                } else {
                                                  return ListTile(
                                                    title: Text("Unsupported file"),
                                                  );
                                                }
                                              },
                                            )
                                                : Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Text(
                                                "No attachment",
                                                style: TextStyle(color: Colors.grey, fontSize: 14),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: CustomText(
                                                textAlign: TextAlign.left,
                                                text: controllers.formatDate(data.sentDate.toString()),
                                                size: 14,
                                                isCopy: true,
                                                colors: colorsConst.textColor,
                                              ),
                                            ),
                                          ]
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          })
                      ),
                    ],
                  ),
                ),

        ),
      ),
    );
  }
}
