import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/models/comments_obj.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_date_box.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import 'package:intl/intl.dart';

import '../../controller/reminder_controller.dart';

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
            width: screenWidth - 150,
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
                              controllers.empDOB.value = "";
                              controllers.callTime.value = "";
                              setState(() {
                                controllers.clearSelectedCustomer();
                                controllers.cusController.text = "";
                                controllers.callType = "Incoming";
                                controllers.callStatus = "Completed";
                              });
                              controllers.callCommentCont.text = "";
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    var customerError;
                                    var dateError;
                                    var timeError;
                                    return StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState){
                                      return  AlertDialog(
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
                                          height: 450,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                               // Divider(),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomText(
                                                          text:"Customer Name",
                                                          colors: colorsConst.textColor,
                                                          size: 13,
                                                        ),
                                                        const CustomText(
                                                          text: "*",
                                                          colors: Colors.red,
                                                          size: 25,
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 480,
                                                      height: 50,
                                                      child: KeyboardDropdownField<AllCustomersObj>(
                                                        items: controllers.customers,
                                                        borderRadius: 5,
                                                        borderColor: Colors.grey.shade300,
                                                        hintText: "Customers",
                                                        labelText: "",
                                                        labelBuilder: (customer) =>'${customer.name} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                        itemBuilder: (customer) {
                                                          return Container(
                                                            width: 300,
                                                            alignment: Alignment.topLeft,
                                                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                            child: CustomText(
                                                              text: '${customer.name} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                              colors: Colors.black,
                                                              size: 14,
                                                              textAlign: TextAlign.start,
                                                            ),
                                                          );
                                                        },
                                                        textEditingController: controllers.cusController,
                                                        onSelected: (value) {
                                                          controllers.selectCustomer(value);
                                                        },
                                                        onClear: () {
                                                          controllers.clearSelectedCustomer();
                                                        },
                                                      ),
                                                    ),
                                                    if (customerError != null)
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 4.0),
                                                        child: Text(
                                                          customerError!,
                                                          style: const TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                10.height,

                                                // Row(
                                                //   children: [
                                                //     8.width,
                                                //     CustomDropDown(
                                                //       saveValue: controllers.callType,
                                                //       valueList: controllers.callTypeList,
                                                //       text: "Call Type",
                                                //       width: 480,
                                                //       //inputFormatters: constInputFormatters.textInput,
                                                //       onChanged: (value) async {
                                                //         setState(() {
                                                //           controllers.callType = value;
                                                //         });
                                                //       },
                                                //     ),
                                                //   ],
                                                // ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Obx(() => CustomDateBox(
                                                        text: "Date",
                                                        isOptional: true,
                                                        errorText: dateError,
                                                        value: controllers.empDOB.value,
                                                        width: 235,
                                                        onTap: () {
                                                          utils.datePicker(
                                                              context: context,
                                                              textEditingController: controllers.dateOfConCtr,
                                                              pathVal: controllers.empDOB);
                                                        },
                                                      ),
                                                    ),
                                                    15.width,
                                                    Obx(() => CustomDateBox(
                                                        text: "Time",
                                                      isOptional: true,
                                                        errorText: timeError,
                                                        value: controllers.callTime.value,
                                                        width: 235,
                                                        onTap: () {
                                                          utils.timePicker(
                                                              context: context,
                                                              textEditingController:
                                                              controllers.timeOfConCtr,
                                                              pathVal: controllers.callTime);
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                10.height,
                                                Row(
                                                  children: [
                                                    5.width,
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CustomText(
                                                              text:"Call Type",
                                                              colors: colorsConst.textColor,
                                                              size: 13,
                                                            ),
                                                            const CustomText(
                                                              text: "*",
                                                              colors: Colors.red,
                                                              size: 25,
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: controllers.callTypeList.map<Widget>((type) {
                                                            return Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Radio<String>(
                                                                  value: type,
                                                                  groupValue: controllers.callType,
                                                                  activeColor: colorsConst.primary,
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      controllers.callType = value!;
                                                                    });
                                                                  },
                                                                ),
                                                                CustomText(text:type,size: 14,),
                                                                20.width, // space between options
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                10.height,
                                                Row(
                                                  children: [
                                                    5.width,
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CustomText(
                                                              text:"Status",
                                                              colors: colorsConst.textColor,
                                                              size: 13,
                                                            ),
                                                            const CustomText(
                                                              text: "*",
                                                              colors: Colors.red,
                                                              size: 25,
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: controllers.callStatusList.map<Widget>((type) {
                                                            return Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Radio<String>(
                                                                  value: type,
                                                                  groupValue: controllers.callStatus,
                                                                  activeColor: colorsConst.primary,
                                                                  onChanged: (value) {
                                                                    setState(() {
                                                                      controllers.callStatus = value!;
                                                                    });
                                                                  },
                                                                ),
                                                                CustomText(text:type,size: 14,),
                                                                20.width // space between options
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                10.height,
                                                // Row(
                                                //   children: [
                                                //     8.width,
                                                //     CustomDropDown(
                                                //       saveValue: controllers.callStatus,
                                                //       valueList: controllers.callStatusList,
                                                //       text: "Status",
                                                //       width: 480,
                                                //       onChanged: (value) async {
                                                //         setState(() {
                                                //           controllers.callStatus = value;
                                                //         });
                                                //       },
                                                //     ),
                                                //   ],
                                                // ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text:"Notes",
                                                      colors: colorsConst.textColor,
                                                      size: 13,
                                                    ),
                                                    SizedBox(
                                                      width: 480,
                                                      height: 80,
                                                      child: TextField(
                                                        controller: controllers.callCommentCont,
                                                        maxLines: null,
                                                        expands: true,
                                                        textAlign: TextAlign.start,
                                                        decoration: InputDecoration(
                                                          hintText: "Notes",
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(5),
                                                            borderSide: BorderSide(
                                                              color: Color(0xffE1E5FA),
                                                            ),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(5),
                                                            borderSide: BorderSide(
                                                              color: Color(0xffE1E5FA),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
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
                                                  if(controllers.selectedCustomerId.value.isEmpty) {
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      customerError =
                                                      "Please select customer";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.empDOB.value.isEmpty) {
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      dateError =
                                                      "Please select date";
                                                    });
                                                    return;
                                                  }
                                                  if(controllers.callTime.value.isEmpty) {
                                                    controllers.productCtr.reset();
                                                    setState(() {
                                                      timeError = "Please select time";
                                                    });
                                                    return;
                                                  }
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
                                          }
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
                        Obx(()=>utils.selectHeatingType("All",
                            controllers.selectCallType.value=="All", (){
                              controllers.selectCallType.value="All";
                            }, false,controllers.allCalls),),
                        10.width,
                        Obx(()=> utils.selectHeatingType("Incoming",
                            controllers.selectCallType.value=="Incoming", (){
                          controllers.selectCallType.value="Incoming";
                        }, false,controllers.allIncomingCalls),),
                        10.width,
                        Obx(()=>utils.selectHeatingType("Outgoing",
                            controllers.selectCallType.value=="Outgoing", (){
                              controllers.selectCallType.value="Outgoing";
                        }, false,controllers.allOutgoingCalls),),
                        10.width,
                        Obx(()=> utils.selectHeatingType("Missed",
                            controllers.selectCallType.value=="Missed", (){
                              controllers.selectCallType.value="Missed";
                        }, true,controllers.allMissedCalls),)
                      ],
                    ),
                    5.height,
                    Divider(
                      thickness: 1.5,
                      color: colorsConst.secondary,
                    ),
                    5.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomSearchTextField(
                          controller: controllers.search,
                          hintText: "Search Customer Name, Mobile",
                          onChanged: (value) {
                              controllers.searchText.value = value.toString().trim();
                              remController.filterAndSortCalls(
                                allCalls: controllers.callActivity,
                                searchText: controllers.searchText.value.toLowerCase(),
                                callType: controllers.selectCallType.value,
                                sortField: controllers.sortFieldCallActivity.value,
                                sortOrder: controllers.sortOrderCallActivity.value,
                              );
                          },
                        ),
                        remController.selectedRecordCallIds.isNotEmpty?
                        InkWell(
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: CustomText(
                                    text: "Are you sure delete this Call records?",
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
                                            remController.deleteRecordCallAPI(context);
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
                        // Table Header
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),//date
                        1: FlexColumnWidth(1.5),//Customer Name
                        2: FlexColumnWidth(2),//Mobile No.
                        3: FlexColumnWidth(2),//Call Type
                        4: FlexColumnWidth(2),//Message
                        5: FlexColumnWidth(2.5),//Status
                        6: FlexColumnWidth(3),//Lead Status
                        7: FlexColumnWidth(3.5),//Status
                        8: FlexColumnWidth(3),
                        //6: FlexColumnWidth(4.5),//Actions
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
                                child:  Obx(() => Checkbox(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                  side: WidgetStateBorderSide.resolveWith(
                                        (states) => const BorderSide(width: 1.0, color: Colors.white),
                                  ),
                                  value: remController.selectedRecordCallIds.length == remController.callFilteredList.length && remController.callFilteredList.isNotEmpty,
                                  onChanged: (value) {
                                    if (value == true) {
                                      remController.selectAllCalls();
                                    } else {
                                      remController.unselectAllCalls();
                                    }
                                  },
                                  activeColor: Colors.white,
                                  checkColor: colorsConst.primary,
                                )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
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
                                child: Row(
                                  children: [
                                    CustomText(
                                      textAlign: TextAlign.left,
                                      text: "Customer Name",
                                      size: 15,
                                      isBold: true,
                                      colors: Colors.white,
                                    ),
                                    3.width,
                                    GestureDetector(
                                      onTap: (){
                                        if(controllers.sortFieldCallActivity.value=='customerName' && controllers.sortOrderCallActivity.value=='asc'){
                                          controllers.sortOrderCallActivity.value='desc';
                                        }else{
                                          controllers.sortOrderCallActivity.value='asc';
                                        }
                                        controllers.sortFieldCallActivity.value='customerName';
                                        remController.filterAndSortCalls(
                                          allCalls: controllers.callActivity,
                                          searchText: controllers.searchText.value.toLowerCase(),
                                          callType: controllers.selectCallType.value,
                                          sortField: controllers.sortFieldCallActivity.value,
                                          sortOrder: controllers.sortOrderCallActivity.value,
                                        );
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
                                    CustomText(//2
                                      textAlign: TextAlign.left,
                                      text: "Mobile No",
                                      size: 15,
                                      isBold: true,
                                      colors: Colors.white,
                                    ),
                                    3.width,
                                    GestureDetector(
                                      onTap: (){
                                        if(controllers.sortFieldCallActivity.value=='mobile' && controllers.sortOrderCallActivity.value=='asc'){
                                          controllers.sortOrderCallActivity.value='desc';
                                        }else{
                                          controllers.sortOrderCallActivity.value='asc';
                                        }
                                        controllers.sortFieldCallActivity.value='mobile';
                                        remController.filterAndSortCalls(
                                          allCalls: controllers.callActivity,
                                          searchText: controllers.searchText.value.toLowerCase(),
                                          callType: controllers.selectCallType.value,
                                          sortField: controllers.sortFieldCallActivity.value,
                                          sortOrder: controllers.sortOrderCallActivity.value,
                                        );
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
                                  text: "Call Type",
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
                                child: CustomText(//4
                                  textAlign: TextAlign.left,
                                  text: "Status",
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: CustomText(//4
                                  textAlign: TextAlign.left,
                                  text: "Lead Status",
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
                                    child: Row(
                                      children: [
                                        CustomText(
                                          textAlign: TextAlign.left,
                                          text: "Date",
                                          size: 15,
                                          isBold: true,
                                          colors: Colors.white,
                                        ),
                                        3.width,
                                        GestureDetector(
                                          onTap: (){
                                            if(controllers.sortFieldCallActivity.value=='date' && controllers.sortOrderCallActivity.value=='asc'){
                                              controllers.sortOrderCallActivity.value='desc';
                                            }else{
                                              controllers.sortOrderCallActivity.value='asc';
                                            }
                                            controllers.sortFieldCallActivity.value='date';
                                            remController.filterAndSortCalls(
                                              allCalls: controllers.callActivity,
                                              searchText: controllers.searchText.value.toLowerCase(),
                                              callType: controllers.selectCallType.value,
                                              sortField: controllers.sortFieldCallActivity.value,
                                              sortOrder: controllers.sortOrderCallActivity.value,
                                            );
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
                            return remController.callFilteredList.isEmpty?
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
                                      itemCount: remController.callFilteredList.length,
                                      itemBuilder: (context, index) {
                                  final data = remController.callFilteredList[index];
                                  final leadStatus = data.leadStatus == "1"
                                      ? "Suspects"
                                      : data.leadStatus == "2"
                                      ? "Prospects"
                                      : data.leadStatus == "3"
                                      ? "Qualified"
                                      : "Customers";
                                  return Table(
                                    columnWidths:const {
                                      0: FlexColumnWidth(1),//date
                                      1: FlexColumnWidth(1.5),//Customer Name
                                      2: FlexColumnWidth(2),//Mobile No.
                                      3: FlexColumnWidth(2),//Call Type
                                      4: FlexColumnWidth(2),//Message
                                      5: FlexColumnWidth(2.5),//Status
                                      6: FlexColumnWidth(3),//Lead Status
                                      7: FlexColumnWidth(3.5),//Status
                                      8: FlexColumnWidth(3),
                                      //6: FlexColumnWidth(4.5),//Actions
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
                                              child: Checkbox(
                                                value: remController.isCheckedRecordCall(data.id.toString()),
                                                onChanged: (value) {
                                                  setState(() {
                                                    remController.toggleRecordSelectionCall(data.id.toString());
                                                  });
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  IconButton(
                                                      onPressed: (){
                                                        String sentDate = data.sentDate;
                                                        if (sentDate.isNotEmpty) {
                                                          List<String> parts = sentDate.split(' ');
                                                          String datePart = parts[0];
                                                          String timePart = parts.sublist(1).join(' ');
                                                          controllers.upDate.value = datePart;
                                                          controllers.upCallTime.value = timePart;
                                                        }
                                                        controllers.selectNCustomer(data.sentId, data.customerName, "", data.toData);
                                                        controllers.upCallType = data.callType;
                                                        controllers.upcallStatus = data.callStatus;
                                                        controllers.upCallCommentCont.text = data.message;
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (context) {
                                                              var customerError;
                                                              var dateError;
                                                              var timeError;
                                                              return StatefulBuilder(
                                                                  builder: (BuildContext context, StateSetter setState){
                                                                    return  AlertDialog(
                                                                      title: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          CustomText(
                                                                            text: "Update Call log",
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
                                                                        height: 450,
                                                                        child: SingleChildScrollView(
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                              // Divider(),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      CustomText(
                                                                                        text:"Customer Name",
                                                                                        colors: colorsConst.textColor,
                                                                                        size: 13,
                                                                                      ),
                                                                                      const CustomText(
                                                                                        text: "*",
                                                                                        colors: Colors.red,
                                                                                        size: 25,
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 480,
                                                                                    height: 50,
                                                                                    child: KeyboardDropdownField<AllCustomersObj>(
                                                                                      items: controllers.customers,
                                                                                      borderRadius: 5,
                                                                                      borderColor: Colors.grey.shade300,
                                                                                      hintText: "Customers",
                                                                                      labelText: "",
                                                                                      labelBuilder: (customer) =>'${customer.name} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                                                      itemBuilder: (customer) {
                                                                                        return Container(
                                                                                          width: 300,
                                                                                          alignment: Alignment.topLeft,
                                                                                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                                                          child: CustomText(
                                                                                            text: '${customer.name} ${customer.name.isEmpty?"":"-"} ${customer.phoneNo}',
                                                                                            colors: Colors.black,
                                                                                            size: 14,
                                                                                            textAlign: TextAlign.start,
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                      textEditingController: controllers.cusController,
                                                                                      onSelected: (value) {
                                                                                        controllers.selectCustomer(value);
                                                                                      },
                                                                                      onClear: () {
                                                                                        controllers.clearSelectedCustomer();
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  if (customerError != null)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 4.0),
                                                                                      child: Text(
                                                                                        customerError!,
                                                                                        style: const TextStyle(
                                                                                            color: Colors.red,
                                                                                            fontSize: 13),
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                              10.height,
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Obx(() => CustomDateBox(
                                                                                    text: "Date",
                                                                                    isOptional: true,
                                                                                    errorText: dateError,
                                                                                    value: controllers.upDate.value,
                                                                                    width: 235,
                                                                                    onTap: () {
                                                                                      utils.datePicker(
                                                                                          context: context,
                                                                                          textEditingController: controllers.dateOfConCtr,
                                                                                          pathVal: controllers.upDate);
                                                                                    },
                                                                                  ),
                                                                                  ),
                                                                                  15.width,
                                                                                  Obx(() => CustomDateBox(
                                                                                    text: "Time",
                                                                                    isOptional: true,
                                                                                    errorText: timeError,
                                                                                    value: controllers.upCallTime.value,
                                                                                    width: 235,
                                                                                    onTap: () {
                                                                                      utils.timePicker(
                                                                                          context: context,
                                                                                          textEditingController:
                                                                                          controllers.timeOfConCtr,
                                                                                          pathVal: controllers.upCallTime);
                                                                                    },
                                                                                  ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              10.height,
                                                                              Row(
                                                                                children: [
                                                                                  5.width,
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          CustomText(
                                                                                            text:"Call Type",
                                                                                            colors: colorsConst.textColor,
                                                                                            size: 13,
                                                                                          ),
                                                                                          const CustomText(
                                                                                            text: "*",
                                                                                            colors: Colors.red,
                                                                                            size: 25,
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        children: controllers.callTypeList.map<Widget>((type) {
                                                                                          return Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              Radio<String>(
                                                                                                value: type,
                                                                                                groupValue: controllers.upCallType,
                                                                                                activeColor: colorsConst.primary,
                                                                                                onChanged: (value) {
                                                                                                  setState(() {
                                                                                                    controllers.upCallType = value!;
                                                                                                  });
                                                                                                },
                                                                                              ),
                                                                                              CustomText(text:type,size: 14,),
                                                                                              20.width, // space between options
                                                                                            ],
                                                                                          );
                                                                                        }).toList(),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              10.height,
                                                                              Row(
                                                                                children: [
                                                                                  5.width,
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          CustomText(
                                                                                            text:"Status",
                                                                                            colors: colorsConst.textColor,
                                                                                            size: 13,
                                                                                          ),
                                                                                          const CustomText(
                                                                                            text: "*",
                                                                                            colors: Colors.red,
                                                                                            size: 25,
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        children: controllers.callStatusList.map<Widget>((type) {
                                                                                          return Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              Radio<String>(
                                                                                                value: type,
                                                                                                groupValue: controllers.upcallStatus,
                                                                                                activeColor: colorsConst.primary,
                                                                                                onChanged: (value) {
                                                                                                  setState(() {
                                                                                                    controllers.upcallStatus = value!;
                                                                                                  });
                                                                                                },
                                                                                              ),
                                                                                              CustomText(text:type,size: 14,),
                                                                                              20.width // space between options
                                                                                            ],
                                                                                          );
                                                                                        }).toList(),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              10.height,
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  CustomText(
                                                                                    text:"Notes",
                                                                                    colors: colorsConst.textColor,
                                                                                    size: 13,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 480,
                                                                                    height: 80,
                                                                                    child: TextField(
                                                                                      controller: controllers.upCallCommentCont,
                                                                                      maxLines: null,
                                                                                      expands: true,
                                                                                      textAlign: TextAlign.start,
                                                                                      decoration: InputDecoration(
                                                                                        hintText: "Notes",
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(5),
                                                                                          borderSide: BorderSide(
                                                                                            color: Color(0xffE1E5FA),
                                                                                          ),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(5),
                                                                                          borderSide: BorderSide(
                                                                                            color: Color(0xffE1E5FA),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
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
                                                                                if(controllers.selectedCustomerId.value.isEmpty) {
                                                                                  controllers.productCtr.reset();
                                                                                  setState(() {
                                                                                    customerError =
                                                                                    "Please select customer";
                                                                                  });
                                                                                  return;
                                                                                }
                                                                                if(controllers.upDate.value.isEmpty) {
                                                                                  controllers.productCtr.reset();
                                                                                  setState(() {
                                                                                    dateError =
                                                                                    "Please select date";
                                                                                  });
                                                                                  return;
                                                                                }
                                                                                if(controllers.upCallTime.value.isEmpty) {
                                                                                  controllers.productCtr.reset();
                                                                                  setState(() {
                                                                                    timeError =
                                                                                    "Please select time";
                                                                                  });
                                                                                  return;
                                                                                }
                                                                                apiService.updateCallCommentAPI(context, "7",data.id);
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
                                                                  }
                                                              );
                                                            });
                                                      },
                                                      icon: SvgPicture.asset(
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
                                                                text: "Are you sure delete this Call records?",
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
                                                                      remController.selectedRecordCallIds.add(data.id.toString());
                                                                      remController.deleteRecordCallAPI(context);
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
                                            Tooltip(
                                              message: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: CustomText(
                                                  textAlign: TextAlign.left,
                                                  text: data.customerName.toString()=="null"?"":data.customerName.toString(),
                                                  size: 14,
                                                  colors:colorsConst.textColor,
                                                ),
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
                                              message: data.callType.toString()=="null"?"":data.callType.toString(),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: CustomText(
                                                  textAlign: TextAlign.left,
                                                  text: data.callType.toString(),
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
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: CustomText(
                                                textAlign: TextAlign.left,
                                                text: data.callStatus.toString(),
                                                size: 14,
                                                colors:colorsConst.textColor,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: CustomText(
                                                textAlign: TextAlign.left,
                                                text: leadStatus.toString(),
                                                size: 14,
                                                colors:colorsConst.textColor,
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
                                        //             mainAxisAlignment: MainAxisAlignment.center,
                                        //             children: [
                                        //               IconButton(
                                        //                   onPressed: (){},
                                        //                   icon: Icon(Icons.edit,color: Colors.green,)),
                                        //               IconButton(
                                        //                   onPressed: (){},
                                        //                   icon: SvgPicture.asset("assets/images/add_note.svg")),
                                        //               IconButton(
                                        //                   onPressed: (){},
                                        //                   icon: Icon(Icons.delete_outline_sharp,color: Colors.red,))
                                        //             ],
                                        //           ),
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
                    20.height,
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
