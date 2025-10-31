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
import '../../components/custom_text.dart';
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
                              ),
                              5.height,
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
                                utils.showComposeMail(context);
                                // utils.sendEmailDialog(id: "1", name: "Customer",
                                //     mobile:"Customer", coName: "Customer");
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
                                  ),
                                ],
                              ),
                            ),
                          ):1.width,
                        ],
                      ),
                      15.height,
                      Divider(color: Colors.grey, height: 1,),
                      15.height,
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),//date
                          //1: FlexColumnWidth(3.5),//Customer Name
                          1: FlexColumnWidth(2),//Mobile No.
                          2: FlexColumnWidth(3),//Call Type
                          3: FlexColumnWidth(4.5),//Message
                          4: FlexColumnWidth(4),//Attachment
                          //5: FlexColumnWidth(4.5),//Actions
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

                                // Padding(
                                //   padding: const EdgeInsets.all(10.0),
                                //   child: CustomText(//1
                                //     textAlign: TextAlign.left,
                                //     text: "Customer Name",
                                //     size: 15,
                                //     isBold: true,
                                //     colors: Colors.white,
                                //   ),
                                // ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "S.NO",//0
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Actions",//1
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Sent Mail",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Subject",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Message",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Attachment",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: CustomText(
                                        textAlign: TextAlign.center,
                                        text: "Date",
                                        size: 15,
                                        isBold: true,
                                        colors: Colors.white,
                                      ),
                                    ),
                                    // Obx(() => GestureDetector(
                                    //   onTap: (){
                                    //     controllers.sortField.value = 'date';
                                    //     controllers.sortOrder.value = 'asc';
                                    //   },
                                    //   child: Icon(
                                    //     Icons.arrow_upward,
                                    //     size: 16,
                                    //     color: (controllers.sortField.value == 'date' &&
                                    //         controllers.sortOrder.value == 'asc')
                                    //         ? Colors.white
                                    //         : Colors.grey,
                                    //   ),
                                    // )),
                                    // Obx(() => GestureDetector(
                                    //   onTap: (){
                                    //     controllers.sortField.value = 'date';
                                    //     controllers.sortOrder.value = 'desc';
                                    //   },
                                    //   child: Icon(
                                    //     Icons.arrow_downward,
                                    //     size: 16,
                                    //     color: (controllers.sortField.value == 'date' &&
                                    //         controllers.sortOrder.value == 'desc')
                                    //         ? Colors.white
                                    //         : Colors.grey,
                                    //   ),
                                    // )
                                    // ),
                                  ],
                                ),

                                // Padding(
                                //   padding: const EdgeInsets.all(10.0),
                                //   child: CustomText(//9
                                //     textAlign: TextAlign.center,
                                //     text: "Actions",
                                //     size: 15,
                                //     isBold: true,
                                //     colors: Colors.white,
                                //   ),
                                // ),
                              ]),
                        ],
                      ),
                      Expanded(
                          child: Obx((){
                            return controllers.isMailLoading.value?
                            Center(child:CircularProgressIndicator()):controllers.mailActivity.isEmpty?
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                100.height,
                                Center(
                                    child: SvgPicture.asset(
                                        "assets/images/noDataFound.svg")),
                              ],
                            )
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
                                itemCount: controllers.mailActivity.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.mailActivity[index];
                                  return Table(
                                    columnWidths:const {
                                      0: FlexColumnWidth(3),//date
                                      //1: FlexColumnWidth(3.5),//Customer Name
                                      1: FlexColumnWidth(2),//Mobile No.
                                      2: FlexColumnWidth(3),//Call Type
                                      3: FlexColumnWidth(4.5),//Message
                                      4: FlexColumnWidth(4),//Attachment
                                      //5: FlexColumnWidth(4.5),//Actions
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

                                            // Tooltip(
                                            //   message: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                            //   child: Padding(
                                            //     padding: const EdgeInsets.all(10.0),
                                            //     child: CustomText(
                                            //       textAlign: TextAlign.center,
                                            //       text: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                            //       size: 14,
                                            //       colors:colorsConst.textColor,
                                            //     ),
                                            //   ),
                                            // ),

                                            SizedBox(
                                              width: 50,
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: remController.isCheckedRecordMAil(data.id.toString()),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        remController.toggleRecordSelectionMail(data.id.toString());
                                                      });
                                                    },
                                                  ),
                                                  //CustomText(text: "${index + 1}"),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                      onPressed: (){
                                                        // remController.updateTitleController.text = reminder.title.toString()=="null"?"":reminder.title.toString();
                                                        // remController.updateLocation = reminder.location.toString()=="null"?"":reminder.location.toString();
                                                        // remController.updateDetailsController.text = reminder.details.toString()=="null"?"":reminder.details.toString();
                                                        // remController.updateStartController.text = reminder.startDt.toString()=="null"?"":reminder.startDt.toString();
                                                        // remController.updateEndController.text = reminder.endDt.toString()=="null"?"":reminder.endDt.toString();
                                                        utils.showUpdateRecordDialog("",context);
                                                      },
                                                      icon:  SvgPicture.asset(
                                                        "assets/images/a_edit.svg",
                                                        width: 16,
                                                        height: 16,
                                                      )),
                                                  IconButton(
                                                      onPressed: (){
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              content: CustomText(
                                                                text: "Are you sure delete this Mail?",
                                                                size: 16,
                                                                isBold: true,
                                                                colors: colorsConst.textColor,
                                                              ),                                                                  actions: [
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
                                                                    callback: ()async{
                                                                      remController.selectedRecordMailIds.add(data.id.toString());
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
                                                      icon: SvgPicture.asset(
                                                        "assets/images/a_delete.svg",
                                                        width: 16,
                                                        height: 16,
                                                      ))
                                                ],
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: CustomText(
                                                textAlign: TextAlign.left,
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
                                                final pdfUrl = "$getImage?path=${Uri.encodeComponent(data.attachment)}"; // PDF-ன் முழு URL

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
                                                colors: colorsConst.textColor,
                                              ),
                                            ),
                                            // Padding(
                                            //   padding: const EdgeInsets.all(3.0),
                                            //   child: Row(
                                            //     mainAxisAlignment: MainAxisAlignment.center,
                                            //     children: [
                                            //       IconButton(
                                            //           onPressed: (){},
                                            //           icon: Icon(Icons.edit,color: Colors.green,)),
                                            //       IconButton(
                                            //           onPressed: (){},
                                            //           icon: SvgPicture.asset("assets/images/add_note.svg")),
                                            //       IconButton(
                                            //           onPressed: (){},
                                            //           icon: Icon(Icons.delete_outline_sharp,color: Colors.red,))
                                            //     ],
                                            //   ),
                                            // ),

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
