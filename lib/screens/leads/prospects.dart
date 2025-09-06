import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/delete_button.dart';
import 'package:fullcomm_crm/components/lead_con.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../common/constant/api.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_text.dart';
import '../../components/promote_button.dart';
import '../../controller/controller.dart';
import '../../models/lead_obj.dart';
import '../../models/new_lead_obj.dart';
import '../../services/api_services.dart';

class Prospects extends StatefulWidget {
  const Prospects({super.key});

  @override
  State<Prospects> createState() => _ProspectsState();
}

class _ProspectsState extends State<Prospects> {
  final ScrollController _controller = ScrollController();
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
      controllers.selectedIndex.value = 2;
      controllers.groupController.selectIndex(0);
      setState(() {
        controllers.search.clear();
        apiService.qualifiedList = [];
        apiService.qualifiedList.clear();
      });
      controllers.searchProspects.value = "";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth = screenSize.width - 380.0;
    final double partWidth = minPartWidth / 10;
    final double adjustedPartWidth = partWidth;
    return SelectionArea(
      child: Scaffold(
        body: Obx(
          () => Container(
            width: MediaQuery.of(context).size.width - 130,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
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
                        Obx(() => CustomText(
                            text: "Leads - ${controllers.leadCategoryList[1]["value"]}",
                            colors: colorsConst.textColor,
                            size: 25,
                            isBold: true,
                          ),
                        ),
                        10.height,
                        Obx(() => CustomText(
                            text: "View all of your ${controllers.leadCategoryList[1]["value"]} Information",
                            colors: colorsConst.textColor,
                            size: 14,
                          ),
                        )
                      ],
                    ),
                    CustomLoadingButton(
                      callback: () {
                        utils.showImportDialog(context);
                      },
                      height: 35,
                      isLoading: false,
                      backgroundColor: colorsConst.third,
                      radius: 2,
                      width: 100,
                      isImage: false,
                      text: "Import",
                      textColor: Colors.black,
                    ),
                  ],
                ),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => GroupButton(
                        //isRadio: true,
                        controller: controllers.groupController,
                        options: GroupButtonOptions(
                            //borderRadius: BorderRadius.circular(20),
                            spacing: 1,
                            elevation: 0,
                            selectedTextStyle:
                                TextStyle(color: colorsConst.third),
                            selectedBorderColor: Colors.transparent,
                            selectedColor: Colors.transparent,
                            unselectedBorderColor: Colors.transparent,
                            unselectedColor: Colors.transparent,
                            unselectedTextStyle:
                                TextStyle(color: colorsConst.textColor)),
                        onSelected: (name, index, isSelected) async {
                          controllers.employeeHeading.value = name;
                        },
                        // buttons: ["All ${controllers.leadCategoryList[1]["value"]} ${controllers.allLeadsLength.value}",
                        //   "Contacted 10","Closed 10","UnHold 10","Follow-up 10","Engaged 10"],
                        buttons: [
                          "All ${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[1]["value"]} ${controllers.allLeadsLength.value}"
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // IconButton(
                        //     onPressed: (){},
                        //     icon: SvgPicture.asset("assets/images/call.svg")),
                        // 5.width,
                        // IconButton(
                        //     onPressed: (){},
                        //     icon: SvgPicture.asset("assets/images/email.svg")),
                        DeleteButton(
                          leadList: apiService.qualifiedList,
                          callback: () {
                            apiService.deleteCustomersAPI(
                                context, apiService.qualifiedList);
                          },
                        ),
                        5.width,
                        Obx(
                          () => PromoteButton(
                            headText: controllers.leadCategoryList[0]
                                ["value"],
                            leadList: apiService.qualifiedList,
                            callback: () {
                              apiService.insertSuspectsAPI(context);
                            },
                            text: "Demote",
                          ),
                        ),
                        5.width,
                        Obx(
                          () => PromoteButton(
                            headText: controllers.leadCategoryList[2]
                                ["value"],
                            leadList: apiService.qualifiedList,
                            callback: () {
                              apiService.insertQualifiedAPI(context);
                            },
                            text: "Promote",
                          ),
                        ),
                        5.width
                      ],
                    )
                  ],
                ),
                10.height,
                Divider(
                  thickness: 2,
                  color: colorsConst.secondary,
                ),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomSearchTextField(
                      controller: controllers.search,
                      hintText: "Search Name, Company, Mobile No.",
                      onChanged: (value) {
                        controllers.searchProspects.value = value.toString();
                      },
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorsConst.secondary,
                          ),
                          onPressed: () => controllers.selectMonth(
                              context,
                              controllers.selectedQualifiedSortBy,
                              controllers.selectedPMonth),
                          child: Text(
                            controllers.selectedPMonth.value != null
                                ? DateFormat('MMMM yyyy').format(
                                    controllers.selectedPMonth.value!)
                                : 'Select Month',
                          ),
                        ),
                        10.width,
                        PopupMenuButton<String>(
                          offset: const Offset(0, 40), // position below button
                          color: colorsConst.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onSelected: (value) {
                            controllers.selectedQualifiedSortBy.value = value;
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: "Today",
                              child: Text("Today",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
                            PopupMenuItem(
                              value: "Last 7 Days",
                              child: Text("Last 7 Days",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
                            PopupMenuItem(
                              value: "Last 30 Days",
                              child: Text("Last 30 Days",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
                            PopupMenuItem(
                              value: "All",
                              child: Text("All",
                                  style: TextStyle(
                                      color: colorsConst.textColor)),
                            ),
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
                                      text: controllers.selectedQualifiedSortBy.value.isEmpty
                                          ? "Sort by"
                                          : controllers.selectedQualifiedSortBy.value,
                                      colors: colorsConst.textColor,
                                      size: 15),
                                )
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                10.height,
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),//check box
                    1: FlexColumnWidth(1),//check box
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
                    bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                    //left: const BorderSide(width: 1, color: Colors.grey),
                    //right:  BorderSide(width: 1, color: Colors.grey),
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
                                        if(controllers.isAllSelected.value==true){
                                          controllers.isAllSelected.value=false;
                                          for(int j=0;j<controllers.isLeadsList.length;j++){
                                            controllers.isLeadsList[j]["isSelect"]=false;
                                            setState((){
                                              var i=apiService.qualifiedList.indexWhere((element) => element["lead_id"]==controllers.isLeadsList[j]["lead_id"]);
                                              apiService.qualifiedList.removeAt(i);
                                            });
                                          }
                                        }else{
                                          controllers.isAllSelected.value=true;
                                          setState((){
                                            for(int j=0;j<controllers.isLeadsList.length;j++){
                                              controllers.isLeadsList[j]["isSelect"]=true;
                                              apiService.qualifiedList.add({
                                                "lead_id":controllers.isLeadsList[j]["lead_id"],
                                                "user_id":controllers.storage.read("id"),
                                                "rating":controllers.isLeadsList[j]["rating"],
                                                "cos_id":cosId,
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
                                      ?Colors.white
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
                          : controllers.paginatedProspectsLeads.isNotEmpty?
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
                          child:  ScrollbarTheme(
                            data: ScrollbarThemeData(
                              thumbColor: MaterialStateProperty.all(const Color(0xff2C3557)),
                              trackColor: MaterialStateProperty.all(const Color(0xff465271)),
                              radius: const Radius.circular(10),
                              thickness: MaterialStateProperty.all(20),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              thickness: 10,
                              trackVisibility: true,
                              radius: const Radius.circular(10),
                              controller: _controller,
                              child: ListView.builder(
                                controller: _controller,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: controllers.paginatedProspectsLeads.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.paginatedProspectsLeads[index];
                                  return Obx(()=>CustomLeadTile(
                                    saveValue: controllers.isLeadsList[index]["isSelect"],
                                    onChanged: (value){
                                      setState(() {
                                        if(controllers.isLeadsList[index]["isSelect"]==true){
                                          controllers.isLeadsList[index]["isSelect"]=false;
                                          var i=apiService.qualifiedList.indexWhere((element) => element["lead_id"]==data.userId.toString());
                                          apiService.qualifiedList.removeAt(i);
                                        }else{
                                          controllers.isLeadsList[index]["isSelect"]=true;
                                          apiService.qualifiedList.add({
                                            "lead_id":data.userId.toString(),
                                            "user_id":controllers.storage.read("id"),
                                            "rating":data.rating ?? "Warm",
                                            "cos_id":cosId,
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
                  // Ensure totalPages is at least 1
                  final totalPages = controllers.totalProspectPages == 0
                      ? 1
                      : controllers.totalProspectPages;
                  final currentPage = controllers.currentProspectPage.value;

                  // Clamp currentPage if needed (optional safeguard)
                  if (currentPage > totalPages) {
                    controllers.currentProspectPage.value = totalPages;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.chevron_left,
                              color: colorsConst.textColor),
                          onPressed: currentPage > 1
                              ? () =>
                                  controllers.currentProspectPage.value--
                              : null,
                        ),
                      ),
                      ...buildPagination(totalPages, currentPage),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.chevron_right,
                              color: colorsConst.textColor),
                          onPressed: currentPage < totalPages
                              ? () =>
                                  controllers.currentProspectPage.value++
                              : null,
                        ),
                      ),
                    ],
                  );
                }),

                20.height,
              ],
            ),
          ),
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
      child: GestureDetector(
        onTap: () => controllers.currentProspectPage.value = pageNum,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent ? colorsConst.third : colorsConst.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            pageNum.toString().padLeft(2, '0'),
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
