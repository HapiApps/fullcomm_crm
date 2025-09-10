import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/action_button.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_search_textfield.dart';
import 'package:fullcomm_crm/components/delete_button.dart';
import 'package:fullcomm_crm/components/disqualified_button.dart';
import 'package:fullcomm_crm/components/promote_button.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constant/api.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import 'add_lead.dart';

class Suspects extends StatefulWidget {
  const Suspects({super.key});

  @override
  State<Suspects> createState() => _SuspectsState();
}

class _SuspectsState extends State<Suspects> {
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  late FocusNode _focusNode;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    Future.delayed(Duration.zero, () {
      controllers.selectedIndex.value = 1;
      controllers.groupController.selectIndex(0);
      setState(() {
        apiService.prospectsList = [];
        apiService.prospectsList.clear();
        controllers.search.clear();
      });
      controllers.searchQuery.value = "";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            utils.sideBarFunction(context),
            Obx(() => InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                _focusNode.requestFocus();
              },
              child: Container(
                width:MediaQuery.of(context).size.width - 150,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    buildHeaderSection(),
                    20.height,
                    // Filter Section
                    buildFilterSection(),
                    10.height,
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),//check box
                        1: FlexColumnWidth(3),//mail
                        2: FlexColumnWidth(2),//N
                        3: FlexColumnWidth(2.5),//CN
                        4: FlexColumnWidth(2),//MN
                        5: FlexColumnWidth(3),//Details of Service Required
                        6: FlexColumnWidth(2),//Source of Prospect
                        7: FlexColumnWidth(2),// Added DateTime
                        8: FlexColumnWidth(2),// city
                        9: FlexColumnWidth(3),// Status Update
                        // 9: FlexColumnWidth(3),
                        // 10: FlexColumnWidth(3),
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
                                  Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: Obx(
                                          () => Checkbox(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(2.0),
                                            ),
                                            side: WidgetStateBorderSide.resolveWith(
                                                  (states) => BorderSide(width: 1.0, color: Colors.white),
                                            ),
                                            checkColor: colorsConst.primary,
                                            activeColor: Colors.white,
                                            value: controllers.isAllSelected.value,
                                              onChanged: (value) {
                                                if (controllers.isAllSelected.value == true) {
                                                  controllers.isAllSelected.value = false;
                                                  for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                                    controllers.isNewLeadList[j]["isSelect"] = false;
                                                    setState(() {
                                                      var i = apiService.prospectsList.indexWhere((element) =>
                                                      element["lead_id"] == controllers.isNewLeadList[j]["lead_id"]);
                                                      apiService.prospectsList.removeAt(i);
                                                    });
                                                  }
                                                } else {
                                                  controllers.isAllSelected.value = true;
                                                  setState(() {
                                                    for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                                      controllers.isNewLeadList[j]["isSelect"] = true;
                                                      apiService.prospectsList.add({
                                                            "lead_id": controllers.isNewLeadList[j]["lead_id"],
                                                            "user_id": controllers.storage.read("id"),
                                                            "rating": controllers.isNewLeadList[j]["rating"],
                                                            "cos_id": cosId,
                                                            "mail_id":controllers.isNewLeadList[j]["mail_id"]
                                                          });
                                                    }
                                                  });
                                                }}
                                          ),
                                    ),
                                  ),

                              Container(
                                height: 45,
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(
                                  textAlign: TextAlign.center,
                                  text: "Actions",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(//1
                                  textAlign: TextAlign.left,
                                  text: "Name",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(//2
                                  textAlign: TextAlign.left,
                                  text: "Company Name",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(//3
                                  textAlign: TextAlign.left,
                                  text: "Mobile No.",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Details of Service Required",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(
                                  textAlign: TextAlign.left,
                                  text: "Source Of Prospect",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: Row(
                                  children: [
                                    CustomText(
                                      textAlign: TextAlign.left,
                                      text: "Added DateTime",
                                      size: 15,
                                      colors: Colors.white,
                                    ),
                                    3.width,
                                    GestureDetector(
                                      onTap: (){
                                        controllers.sortField.value = 'date';
                                        if(controllers.sortOrder.value == 'asc') {
                                          controllers.sortOrder.value = 'desc';
                                        }else{
                                          controllers.sortOrder.value = 'asc';
                                        }
                                      },
                                      child: Obx(()=>Image.asset(controllers.sortField.value.isEmpty?
                                      "assets/images/arrow.png":controllers.sortOrder.value == 'asc'?"assets/images/arrow_up.png":"assets/images/arrow_down.png",
                                        width: 15,height: 15,),)

                                    ),
                                    // Column(
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   crossAxisAlignment: CrossAxisAlignment.center,
                                    //   children: [
                                    //     Obx(() => GestureDetector(
                                    //       onTap: (){
                                    //         controllers.sortField.value = 'date';
                                    //         controllers.sortOrder.value = 'asc';
                                    //       },
                                    //       child: Icon(
                                    //         Icons.arrow_drop_up,
                                    //         size: 20,
                                    //         color: (controllers.sortField.value == 'date' &&
                                    //             controllers.sortOrder.value == 'asc')
                                    //             ? Colors.white
                                    //             : Colors.grey,
                                    //       ),
                                    //     )),
                                    //     Obx(() => GestureDetector(
                                    //       onTap: (){
                                    //         controllers.sortField.value = 'date';
                                    //         controllers.sortOrder.value = 'desc';
                                    //       },
                                    //       child: Icon(
                                    //         Icons.arrow_drop_down,
                                    //         size: 20,
                                    //         color: (controllers.sortField.value == 'date' &&
                                    //             controllers.sortOrder.value == 'desc')
                                    //             ? Colors.white
                                    //             : Colors.grey,
                                    //       ),
                                    //     )
                                    //     ),
                                    //   ],
                                    // ),

                                  ],
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(//4
                                  textAlign: TextAlign.left,
                                  text: "City",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                              Container(
                                height: 45,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5,right: 5),
                                child: CustomText(//9
                                  textAlign: TextAlign.left,
                                  text: "Status Update",
                                  size: 15,
                                  colors: Colors.white,
                                ),
                              ),
                            ]),
                      ],
                    ),
                    Expanded(
                      //height: MediaQuery.of(context).size.height/1.5,
                      child: Obx(
                              () => controllers.isLead.value == false
                              ? const Center(child: CircularProgressIndicator())
                              : controllers.paginatedLeads.isNotEmpty?
                          GestureDetector(
                            onTap: () {
                              _focusNode.requestFocus();
                            },
                            child: RawKeyboardListener(
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
                              child:  ListView.builder(
                                controller: _controller,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: controllers.paginatedLeads.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.paginatedLeads[index];
                                  return Obx(()=>CustomLeadTile(
                                    saveValue: controllers.isNewLeadList[index]["isSelect"],
                                    onChanged: (value){
                                      setState(() {
                                        if(controllers.isNewLeadList[index]["isSelect"]==true){
                                          controllers.isNewLeadList[index]["isSelect"]=false;
                                          var i=apiService.prospectsList.indexWhere((element) => element["lead_id"]==data.userId.toString());
                                          apiService.prospectsList.removeAt(i);
                                        }else{
                                          controllers.isNewLeadList[index]["isSelect"]=true;
                                          apiService.prospectsList.add({
                                            "lead_id":data.userId.toString(),
                                            "user_id":controllers.storage.read("id"),
                                            "rating":data.rating ?? "Warm",
                                            "cos_id":cosId,
                                            "mail_id":data.emailId.toString().split("||")[0]
                                          });
                                        }
                                      });
                                    },
                                    visitType: data.visitType.toString(),
                                    detailsOfServiceReq: data.detailsOfServiceRequired.toString(),
                                    statusUpdate: data.statusUpdate.toString(),
                                    index: index,
                                    points: data.points.toString(),
                                    quotationStatus: data.quotationStatus.toString(),
                                    quotationRequired: data.quotationRequired.toString(),
                                    productDiscussion: data.productDiscussion.toString(),
                                    discussionPoint: data.discussionPoint.toString(),
                                    notes: data.notes.toString(),
                                    linkedin: "",
                                    x: "",
                                    name: data.firstname.toString().split("||")[0],
                                    mobileNumber: data.mobileNumber.toString().split("||")[0],
                                    email: data.emailId.toString().split("||")[0],
                                    companyName: data.companyName.toString(),
                                    mainWhatsApp: data.mobileNumber.toString().split("||")[0],
                                    emailUpdate: data.quotationUpdate.toString(),
                                    id: data.userId.toString(),
                                    status: data.leadStatus ?? "UnQualified",
                                    rating: data.rating ?? "Warm",
                                    mainName: data.firstname.toString().split("||")[0],
                                    mainMobile: data.mobileNumber.toString().split("||")[0],
                                    mainEmail: data.emailId.toString().split("||")[0],
                                    title: "",
                                    whatsappNumber: data.mobileNumber.toString().split("||")[0],
                                    mainTitle: "",
                                    addressId: data.addressId ?? "",
                                    companyWebsite: "",
                                    companyNumber: "",
                                    companyEmail: "",
                                    industry: "",
                                    productServices: "",
                                    source:data.source ?? "",
                                    owner: "",
                                    budget: "",
                                    timelineDecision: "",
                                    serviceInterest: "",
                                    description: "",
                                    leadStatus: data.quotationStatus ?? "",
                                    active: data.active ?? "",
                                    addressLine1: data.doorNo ?? "",
                                    addressLine2: data.landmark1 ?? "",
                                    area: data.area ?? "",
                                    city: data.city ?? "",
                                    state: data.state ?? "",
                                    country: data.country ?? "",
                                    pinCode: data.pincode ?? "",
                                    prospectEnrollmentDate: data.prospectEnrollmentDate ?? "",
                                    expectedConvertionDate: data.expectedConvertionDate ?? "",
                                    numOfHeadcount: data.numOfHeadcount ?? "",
                                    expectedBillingValue: data.expectedBillingValue ?? "",
                                    arpuValue: data.arpuValue ?? "",
                                    updatedTs: data.createdTs ?? "",
                                    sourceDetails: data.sourceDetails ?? "",
                                  ));
                                },
                              ),
                            ),
                          ):
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              100.height,
                              Center(
                                  child: SvgPicture.asset(
                                      "assets/images/noDataFound.svg")),
                            ],
                          )
                      ),
                    ),

                    Obx(() {
                      final totalPages = controllers.totalPages == 0 ? 1 : controllers.totalPages;
                      final currentPage = controllers.currentPage.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          paginationButton(Icons.chevron_left, currentPage > 1, () {
                            _focusNode.requestFocus();
                            controllers.currentPage.value--;
                          }),
                          ...buildPagination(totalPages, currentPage),
                          paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                            controllers.currentPage.value++;
                            _focusNode.requestFocus();
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget paginationButton(IconData icon, bool isEnabled, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(icon, color: colorsConst.textColor),
        onPressed: isEnabled ? onPressed : null,
        // onLongPress: (){
        //   _focusNode.requestFocus();
        // },
      ),
    );
  }

  Widget buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => CustomText(
              text: "New Leads - ${controllers.leadCategoryList[0]["value"]}",
              colors: colorsConst.textColor,
              size: 25,
              isBold: true,
            )),
            10.height,
            Obx(() => CustomText(
              text: "View all of your ${controllers.leadCategoryList[0]["value"]} Information",
              colors: colorsConst.textColor,
              size: 14,
            )),
          ],
        ),
        Row(
          children: [
            CustomLoadingButton(
              callback: () async {
                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                setState(() {
                  final leadPersonalCount = sharedPref.getInt("leadCount") ?? 1;
                  controllers.leadPersonalItems.value = leadPersonalCount;
                  controllers.isMainPersonList.value = [];
                  controllers.isCoMobileNumberList.value = [];
                  for (int i = 0; i < leadPersonalCount; i++) {
                    controllers.isMainPersonList.add(false);
                    controllers.isCoMobileNumberList.add(false);
                  }
                  controllers.leadCoNameCrt.text = sharedPref.getString("leadCoName") ?? "";
                  controllers.leadCoMobileCrt.text = sharedPref.getString("leadCoMobile") ?? "";
                });
                _focusNode.requestFocus();
                Get.to(const AddLead(), duration: Duration.zero);
              },
              isLoading: false,
              height: 35,
              backgroundColor: colorsConst.primary,
              radius: 2,
              width: 100,
              isImage: false,
              text: "Add Lead",
              textColor: Colors.white,
            ),
            15.width,
            CustomLoadingButton(
              callback: () {
                _focusNode.requestFocus();
                utils.showImportDialog(context);
              },
              height: 35,
              isLoading: false,
              backgroundColor: Colors.white,
              radius: 2,
              width: 100,
              isImage: false,
              text: "Import",
              textColor: colorsConst.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFilterSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CustomText(
                  text: "Suspects",
                  colors: colorsConst.primary,
                  isBold: true,
                  size: 15,
                ),
                10.width,
                CircleAvatar(
                  backgroundColor: colorsConst.primary,
                  radius: 17,
                  child: Obx(
                        () => CustomText(
                      text: controllers.allNewLeadsLength.value.toString(),
                      colors: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),

            apiService.prospectsList.isEmpty?0.height:Row(
              children: [
                ActionButton(width: 150, image: "assets/images/action_delete.png", name: "Delete"),
                GestureDetector(
                  onTap: (){
                    _focusNode.requestFocus();
                  },
                  child: DeleteButton(
                    leadList: apiService.prospectsList,
                    callback: () {
                      _focusNode.requestFocus();
                      apiService.deleteCustomersAPI(context, apiService.prospectsList);
                    },
                  ),
                ),
                5.width,
                IconButton(
                    onPressed: (){
                      _focusNode.requestFocus();
                        utils.bulkEmailDialog(_focusNode,list:apiService.prospectsList);
                    },
                    icon: SvgPicture.asset("assets/images/email.svg",color: colorsConst.primary,)),
                GestureDetector(
                  onTap: (){
                    _focusNode.requestFocus();
                  },
                  child: DisqualifiedButton(
                    leadList: apiService.prospectsList,
                    focusNode: _focusNode,
                    callback: () {
                      _focusNode.requestFocus();
                      apiService.disqualifiedCustomersAPI(context, apiService.prospectsList);
                    },
                  ),
                ),
                5.width,
                GestureDetector(
                  onTap: (){
                    _focusNode.requestFocus();
                  },
                  child: Obx(() => PromoteButton(
                    headText: controllers.leadCategoryList[1]["value"],
                    leadList: apiService.prospectsList,
                    callback: () {
                      _focusNode.requestFocus();
                      apiService.insertProspectsAPI(context, apiService.prospectsList);
                    },
                    text: "Promote",
                  )),
                ),
                5.width,
              ],
            ),
          ],
        ),
        10.height,
        Divider(thickness: 1.5, color: colorsConst.secondary),
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomSearchTextField(
              hintText: "Search Name, Company, Mobile No.",
              controller: controllers.search,
              onChanged: (value) {
                controllers.searchQuery.value = value.toString();
              },
            ),
            Row(
              children: [
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorsConst.secondary,
                      shadowColor: Colors.transparent
                    ),
                    onPressed: (){
                      controllers.selectMonth(
                          context, controllers.selectedProspectSortBy, controllers.selectedMonth);
                      _focusNode.requestFocus();
                    },
                    child: CustomText(
                      text:controllers.selectedMonth.value != null
                          ? DateFormat('MMMM yyyy').format(controllers.selectedMonth.value!)
                          : 'Select Month',
                      colors: colorsConst.textColor,
                    ),
                  ),
                ),
                10.width,
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  color: Color(0xffE7EEF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  onSelected: (value) {
                    controllers.selectedProspectSortBy.value = value;
                    _focusNode.requestFocus();
                    controllers.isMenuOpen.value = false;
                  },
                  onCanceled: () {
                    controllers.isMenuOpen.value = false;
                  },
                  onOpened: () {
                    controllers.isMenuOpen.value = true;
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "Today", child: Text("Today", style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(value: "Last 7 Days", child: Text("Last 7 Days", style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(value: "Last 30 Days", child: Text("Last 30 Days", style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(value: "All", child: Text("All", style: TextStyle(color: colorsConst.textColor))),
                  ],
                  child: Container(
                    color: colorsConst.secondary,
                    height: 36,
                    padding: EdgeInsets.all(9),
                    child: Row(
                      children: [
                        Obx(() => CustomText(
                          text: controllers.selectedProspectSortBy.value.isEmpty
                              ? "Filter by Date Range"
                              : controllers.selectedProspectSortBy.value,
                          colors: colorsConst.textColor,
                        )),
                        5.width,
                        Obx(() => Icon(
                          controllers.isMenuOpen.value
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: colorsConst.textColor,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }



  Widget headerCell({
    required double width,
    required String text,
    required bool isSortable,
    required String fieldName,
    void Function()? onSortAsc,
    void Function()? onSortDesc,
    required RxString sortField,
    required RxString sortOrder,
  }) {
    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: text,
            size: 15,
            isBold: true,
            colors: Colors.white,
          ),
          if (isSortable) ...[
            Obx(() => GestureDetector(
              onTap: onSortAsc,
              child: Icon(
                Icons.arrow_upward,
                size: 16,
                color: (sortField.value == fieldName &&
                    sortOrder.value == 'asc')
                    ? colorsConst.third // highlight color
                    : Colors.grey, // default color
              ),
            )),
            Obx(() => GestureDetector(
              onTap: onSortDesc,
              child: Icon(
                Icons.arrow_downward,
                size: 16,
                color: (sortField.value == fieldName &&
                    sortOrder.value == 'desc')
                    ? colorsConst.third
                    : Colors.grey,
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget dataCell({required double width, required String text}) {
    return Tooltip(
      message: text=="null"?"":text,
      child: Container(
        width: width,
        height: 50,
        alignment: Alignment.center,
        child: CustomText(
          text: text,
          size: 14,
          colors: colorsConst.textColor,
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
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          controllers.currentPage.value = pageNum;
          _focusNode.requestFocus();
        },
        onLongPress: (){
          _focusNode.requestFocus();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent ? colorsConst.primary : colorsConst.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            //pageNum.toString().padLeft(2, '0'),
            pageNum.toString(),
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.black,
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
      child: Text('...', style: TextStyle(fontSize: 18, color: Colors.black)),
    );
  }
}


