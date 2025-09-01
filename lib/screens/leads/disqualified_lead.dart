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
        body: Obx(() => InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Container(
            width: controllers.isLeftOpen.value == false &&
                controllers.isRightOpen.value == false
                ? MediaQuery.of(context).size.width - 200
                : MediaQuery.of(context).size.width - 445,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.height,
                // Header Section
                buildHeaderSection(),
                20.height,
                // Filter Section
                buildFilterSection(),
                10.height,
                Divider(thickness: 2, color: colorsConst.secondary),
                10.height,
                // Table Section
                Focus(
                  autofocus: true,
                  focusNode: _focusNode,
                  onKey: (node, event) {
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        _verticalController.animateTo(
                          _verticalController.offset + 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        _verticalController.animateTo(
                          _verticalController.offset - 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                        _horizontalController.animateTo(
                          _horizontalController.offset + 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        _horizontalController.animateTo(
                          _horizontalController.offset - 100,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Scrollbar(
                    controller: _horizontalController,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                    width: 40,
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
                                ),
                                headerCell(
                                  width: 150, text: "Name",
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
                                headerCell(width: 180, text: "Company Name",
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
                                headerCell(width: 120, text: "Mobile No.",
                                  isSortable: true,
                                  fieldName: 'mobile',
                                  sortField: controllers.sortField,
                                  sortOrder: controllers.sortOrder,
                                  onSortAsc: () {
                                    controllers.sortField.value = 'mobile';
                                    controllers.sortOrder.value = 'asc';
                                  },
                                  onSortDesc: () {
                                    controllers.sortField.value = 'mobile';
                                    controllers.sortOrder.value = 'desc';
                                  },
                                ),
                                headerCell(width: 260, text: "Details of Service Required",
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
                                headerCell(width: 200, text: "Source Of Prospect",
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
                                headerCell(width: 200, text: "Added DateTime",
                                  isSortable: true,
                                  fieldName: 'date',
                                  sortField: controllers.sortField,
                                  sortOrder: controllers.sortOrder,
                                  onSortAsc: () {
                                    controllers.sortField.value = 'date';
                                    controllers.sortOrder.value = 'asc';
                                  },
                                  onSortDesc: () {
                                    controllers.sortField.value = 'date';
                                    controllers.sortOrder.value = 'desc';
                                  },
                                ),
                                headerCell(width: 150, text: "City",
                                  fieldName: 'city',
                                  sortField: controllers.sortField,
                                  sortOrder: controllers.sortOrder,
                                  isSortable: true,
                                  onSortAsc: () {
                                    controllers.sortField.value = 'city';
                                    controllers.sortOrder.value = 'asc';
                                  },
                                  onSortDesc: () {
                                    controllers.sortField.value = 'city';
                                    controllers.sortOrder.value = 'desc';
                                  },
                                ),
                                headerCell(width: 200, text: "Status Update",
                                  fieldName: 'statusUpdate',
                                  sortField: controllers.sortField,
                                  sortOrder: controllers.sortOrder,
                                  isSortable: true,
                                  onSortAsc: () {
                                    controllers.sortField.value = 'statusUpdate';
                                    controllers.sortOrder.value = 'asc';
                                  },
                                  onSortDesc: () {
                                    controllers.sortField.value = 'statusUpdate';
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
                            width: 1510,
                            child: Scrollbar(
                              controller: _verticalController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              interactive: true,
                              thickness: 10,
                              radius: const Radius.circular(10),
                              child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  return 5.height;
                                },
                                controller: _verticalController,
                                itemCount: controllers.paginatedDisqualified.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.paginatedDisqualified[index];
                                  return InkWell(
                                    onTap: () {
                                      Get.to(ViewLead(
                                        id:data.userId.toString(),
                                        linkedin: "",
                                        x: "",
                                        mainName:data.firstname.toString().split("||")[0],
                                        mainMobile:data.mobileNumber.toString().split("||")[0],
                                        mainEmail:data.emailId.toString().split("||")[0],
                                        mainWhatsApp: data.mobileNumber.toString().split("||")[0],
                                        companyName:data.companyName.toString(),
                                        status:data.leadStatus ?? "UnQualified",
                                        rating:data.rating ?? "Warm",
                                        emailUpdate:data.quotationUpdate.toString(),
                                        name:data.firstname.toString().split("||")[0],
                                        title:"",
                                        mobileNumber:data.mobileNumber.toString().split("||")[0],
                                        whatsappNumber:data.mobileNumber.toString().split("||")[0],
                                        email:data.emailId.toString().split("||")[0],
                                        mainTitle:"",
                                        addressId:data.addressId ?? "",
                                        companyWebsite:"",
                                        companyNumber:"",
                                        companyEmail:"",
                                        industry:"",
                                        productServices:"",
                                        source:"",
                                        owner:"",
                                        budget:"",
                                        timelineDecision:"",
                                        serviceInterest:"",
                                        description:"",
                                        leadStatus:data.quotationStatus ?? "",
                                        active:data.active ?? "",
                                        addressLine1:data.doorNo ?? "",
                                        addressLine2:data.landmark1 ?? "",
                                        area:data.area ?? "",
                                        city: data.city ?? "",
                                        state: data.state ?? "",
                                        country: data.country ?? "",
                                        pinCode: data.pincode ?? "",
                                        quotationStatus:data.quotationStatus.toString(),
                                        productDiscussion:data.productDiscussion.toString(),
                                        discussionPoint:data.discussionPoint.toString(),
                                        notes:data.notes.toString(),
                                        prospectEnrollmentDate:data.prospectEnrollmentDate ?? "",
                                        expectedConvertionDate: data.expectedConvertionDate ?? "",
                                        numOfHeadcount: data.numOfHeadcount ?? "",
                                        expectedBillingValue: data.expectedBillingValue ?? "",
                                        arpuValue: data.arpuValue ?? "",
                                        updateTs: data.createdTs ?? "",
                                        sourceDetails: data.sourceDetails ?? "",
                                      ),duration: Duration.zero
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Container(
                                              height: 70,
                                              width: 40,
                                              alignment: Alignment.center,
                                              child: Obx(() =>  CustomCheckBox(
                                                  text: "",
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
                                                  saveValue: controllers.isDisqualifiedList[index]["isSelect"]),
                                              ),
                                            ),
                                          ),
                                          dataCell(width: 150, text: data.firstname.toString().split("||")[0]),
                                          dataCell(width: 180, text: data.companyName ?? ""),
                                          dataCell(width: 120, text: data.mobileNumber.toString().split("||")[0]),
                                          dataCell(width: 260, text: data.detailsOfServiceRequired ?? ""),
                                          dataCell(width: 200, text: data.source ?? ""),
                                          dataCell(width: 200, text: controllers.formatDateTime(data.prospectEnrollmentDate.toString().isEmpty||data.prospectEnrollmentDate.toString()=="null"?data.updatedTs.toString():data.prospectEnrollmentDate.toString())),
                                          dataCell(width: 150, text: data.city ?? ""),
                                          dataCell(width: 200, text: data.statusUpdate ?? ""),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
            10.height,
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
            Obx(() => GroupButton(
              controller: controllers.groupController,
              options: GroupButtonOptions(
                spacing: 1,
                elevation: 0,
                selectedTextStyle: TextStyle(color: colorsConst.third),
                selectedBorderColor: Colors.transparent,
                selectedColor: Colors.transparent,
                unselectedBorderColor: Colors.transparent,
                unselectedColor: Colors.transparent,
                unselectedTextStyle: TextStyle(color: colorsConst.textColor),
              ),
              onSelected: (name, index, isSelected) {
                controllers.employeeHeading.value = name;
              },
              buttons: [
                "All Disqualified ${controllers.allDisqualifiedLength.value}"
              ],
            )),
            Row(
              children: [
                Tooltip(
                  message: "Click here to qualified the customer details",
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorsConst.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(color: colorsConst.third)
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
                      child: CustomText(text: "Qualified",colors: colorsConst.textColor,)
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


