import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_search_textfield.dart';
import 'package:fullcomm_crm/screens/leads/view_lead.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import '../../common/constant/api.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';

class DisqualifiedLead extends StatefulWidget {
  const DisqualifiedLead({super.key});

  @override
  State<DisqualifiedLead> createState() => _DisqualifiedLeadState();
}

class _DisqualifiedLeadState extends State<DisqualifiedLead> {
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
      controllers.selectedIndex.value = 5;
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
                width: MediaQuery.of(context).size.width - 150,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    buildHeaderSection(),
                    20.height,
                    // Filter Section
                    buildFilterSection(),
                    10.height,
                    Divider(thickness: 2, color: colorsConst.secondary),
                    10.height,
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),//check box
                        1: FlexColumnWidth(1),//mail
                        2: FlexColumnWidth(2),//N
                        3: FlexColumnWidth(2.5),//CN
                        4: FlexColumnWidth(2),//MN
                        5: FlexColumnWidth(3),//Details of Service Required
                        6: FlexColumnWidth(2),//Source of Prospect
                        7: FlexColumnWidth(2.5),// Added DateTime
                        8: FlexColumnWidth(1.5),// Added DateTime
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
                              Row(//0
                                children: [
                                  5.width,
                                  Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Obx(
                                          () => CustomCheckBox(
                                          text: "",
                                              onChanged: (value) {
                                                if (controllers.isAllSelected.value == true) {
                                                  controllers.isAllSelected.value = false;
                                                  for (int j = 0; j < controllers.isDisqualifiedList.length; j++) {
                                                    controllers.isDisqualifiedList[j]["isSelect"] = false;
                                                    setState(() {
                                                      var i = apiService.prospectsList.indexWhere((element) =>
                                                      element["lead_id"] == controllers.isDisqualifiedList[j]["lead_id"]);
                                                      apiService.prospectsList.removeAt(i);
                                                    });
                                                  }
                                                } else {
                                                  controllers.isAllSelected.value = true;
                                                  setState(() {
                                                    for (int j = 0; j < controllers.isDisqualifiedList.length; j++) {
                                                      controllers.isDisqualifiedList[j]["isSelect"] = true;
                                                      apiService.prospectsList.add({
                                                        "lead_id": controllers.isDisqualifiedList[j]["lead_id"],
                                                        "user_id": controllers.storage.read("id"),
                                                        "rating": controllers.isDisqualifiedList[j]["rating"],
                                                        "cos_id": cosId,
                                                        "mail": controllers.isDisqualifiedList[j]["mail_id"],
                                                      });
                                                    }
                                                  });
                                                }
                                                //controllers.isMainPerson.value=!controllers.isMainPerson.value;
                                              },
                                          saveValue: controllers.isAllSelected.value),
                                    ),
                                  ),
                                ],
                              ),
                              CustomText(
                                textAlign: TextAlign.center,
                                text: "\nMail\n",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                              CustomText(//1
                                textAlign: TextAlign.center,
                                text: "\nName\n",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                              CustomText(//2
                                textAlign: TextAlign.center,
                                text: "\nCompany Name\n",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                              CustomText(//3
                                textAlign: TextAlign.center,
                                text: "\nMobile No.\n",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                              // CustomText(
                              //   textAlign: TextAlign.center,
                              //   text: "\nEmail\n",
                              //   size: 15,
                              //   isBold: true,
                              //   colors: colorsConst.textColor,
                              // ),
                              Padding(//6
                                padding: const EdgeInsets.all(8.0),
                                child: CustomText(
                                  textAlign: TextAlign.center,
                                  text: "Details of Service\nRequired",
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                              ),
                              Padding(//7
                                padding: const EdgeInsets.all(8.0),
                                child: CustomText(
                                  textAlign: TextAlign.center,
                                  text: "Source Of \nProspect",
                                  size: 15,
                                  isBold: true,
                                  colors: Colors.white,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(//8
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomText(
                                      textAlign: TextAlign.center,
                                      text: "Added\nDateTime",
                                      size: 15,
                                      isBold: true,
                                      colors: Colors.white,
                                    ),
                                  ),
                                  Obx(() => GestureDetector(
                                    onTap: (){
                                      controllers.sortField.value = 'date';
                                      controllers.sortOrder.value = 'asc';
                                    },
                                    child: Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: (controllers.sortField.value == 'date' &&
                                          controllers.sortOrder.value == 'asc')
                                          ? colorsConst.third
                                          : Colors.grey,
                                    ),
                                  )),
                                  Obx(() => GestureDetector(
                                    onTap: (){
                                      controllers.sortField.value = 'date';
                                      controllers.sortOrder.value = 'desc';
                                    },
                                    child: Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: (controllers.sortField.value == 'date' &&
                                          controllers.sortOrder.value == 'desc')
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  )
                                  ),
                                ],
                              ),
                              CustomText(//4
                                textAlign: TextAlign.center,
                                text: "\nCity\n",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                              CustomText(//9
                                textAlign: TextAlign.center,
                                text: "\nStatus Update\n",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                            ]),
                      ],
                    ),
                    Expanded(
                      //height: MediaQuery.of(context).size.height/1.5,
                      child: Obx(
                              () => controllers.isLead.value == false
                              ? const Center(child: CircularProgressIndicator())
                              : controllers.paginatedDisqualified.isNotEmpty?
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
                                itemCount: controllers.paginatedDisqualified.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.paginatedDisqualified[index];
                                  return Obx(()=>CustomLeadTile(
                                      onChanged: (value){
                                        setState(() {
                                          if(controllers.isDisqualifiedList[index]["isSelect"]==true){
                                            controllers.isDisqualifiedList[index]["isSelect"]=false;
                                            var i=apiService.prospectsList.indexWhere((element) => element["lead_id"]==data.userId.toString());
                                            apiService.prospectsList.removeAt(i);
                                          }else{
                                            controllers.isDisqualifiedList[index]["isSelect"]=true;
                                            apiService.prospectsList.add({
                                              "lead_id":data.userId.toString(),
                                              "user_id":controllers.storage.read("id"),
                                              "rating":data.rating.toString(),
                                              "cos_id":cosId,
                                              "mail":data.emailId.toString(),
                                            });
                                          }
                                        });
                                      },
                                      saveValue: controllers.isDisqualifiedList[index]["isSelect"],
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
                    // Pagination
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
        color: colorsConst.secondary,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            CustomText(
              text: "Disqualified",
              colors: colorsConst.textColor,
              size: 25,
              isBold: true,
            ),
            5.height,
            CustomText(
              text: "View all of your Disqualified Information",
              colors: colorsConst.textColor,
              size: 14,
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
                  text: "Disqualified",
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
                      text: controllers.allDisqualifiedLength.value.toString(),
                      colors: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Tooltip(
                  message: "Click here to qualified the customer details",
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(color: colorsConst.primary)
                          )
                      ),
                      onPressed: () {
                        if(apiService.prospectsList.isNotEmpty){
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor:
                                  colorsConst.secondary,
                                  content: CustomText(
                                    text: "Are you sure qualified this customers?",
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
                                              border: Border.all(
                                                  color: colorsConst.third),
                                              color: colorsConst.primary),
                                          width: 80,
                                          height: 25,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.zero),
                                                backgroundColor: colorsConst.primary,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const CustomText(
                                                text: "Cancel",
                                                colors: Colors.white,
                                                size: 14,
                                              )),
                                        ),
                                        10.width,
                                        CustomLoadingButton(
                                          callback: (){
                                            apiService.qualifiedCustomersAPI(context, apiService.prospectsList);
                                          },
                                          height: 35,
                                          isLoading: true,
                                          backgroundColor:
                                          colorsConst.third,
                                          radius: 2,
                                          width: 80,
                                          controller: controllers.productCtr,
                                          isImage: false,
                                          text: "Qualified",
                                          textColor:
                                          colorsConst.primary,
                                        ),
                                        5.width
                                      ],
                                    ),
                                  ],
                                );
                              });
                        }else{
                          apiService.errorDialog(
                              context, "Please select customers");
                        }
                      },
                      child: CustomText(text: "Qualified",
                        colors: colorsConst.primary,)
                  ),
                ),
                5.width,
              ],
            ),
          ],
        ),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorsConst.secondary,
                  ),
                  onPressed: () => controllers.selectMonth(
                      context, controllers.selectedProspectSortBy, controllers.selectedMonth),
                  child: Text(
                    controllers.selectedMonth.value != null
                        ? DateFormat('MMMM yyyy').format(controllers.selectedMonth.value!)
                        : 'Select Month',
                  ),
                ),
                10.width,
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  color: colorsConst.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onSelected: (value) {
                    controllers.selectedProspectSortBy.value = value;
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "Today", child: Text("Today", style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(value: "Last 7 Days", child: Text("Last 7 Days", style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(value: "Last 30 Days", child: Text("Last 30 Days", style: TextStyle(color: colorsConst.textColor))),
                    PopupMenuItem(value: "All", child: Text("All", style: TextStyle(color: colorsConst.textColor))),
                  ],
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorsConst.secondary,
                    ),
                    onPressed: null,
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/images/sort.svg"),
                        const SizedBox(width: 6),
                        Obx(() => CustomText(
                          text: controllers.selectedProspectSortBy.value.isEmpty
                              ? "Sort by"
                              : controllers.selectedProspectSortBy.value,
                          colors: colorsConst.textColor,
                          size: 15,
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
            color: isCurrent ? colorsConst.third : colorsConst.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            //pageNum.toString().padLeft(2, '0'),
            pageNum.toString(),
            style: TextStyle(
              color: isCurrent ? Colors.black : Colors.white,
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
      child: Text('...', style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}


