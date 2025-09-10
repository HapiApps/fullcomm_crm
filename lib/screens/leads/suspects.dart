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
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_table_header.dart';
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
                    HeaderSection(
                      title: "New Leads - ${controllers.leadCategoryList[0]["value"]}",
                      subtitle: "View all of your ${controllers.leadCategoryList[0]["value"]} Information",
                    ),
                    20.height,
                    // Filter Section
                    FilterSection(
                      title: "Suspects",
                      count: controllers.allNewLeadsLength.value,
                      itemList: apiService.prospectsList,
                      onDelete: () {
                        _focusNode.requestFocus();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                content: CustomText(
                                  text: "Are you sure delete this customers?",
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
                                          _focusNode.requestFocus();
                                          await apiService.deleteCustomersAPI(context, apiService.prospectsList);
                                          setState(() {
                                            apiService.prospectsList.clear();
                                          });
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
                                      5.width
                                    ],
                                  ),
                                ],
                              );
                            });
                      },
                      onMail: () {
                        utils.bulkEmailDialog(_focusNode, list: apiService.prospectsList);
                      },
                      onPromote: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                content: CustomText(
                                  text: "Are you moving to the next level?",
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
                                          _focusNode.requestFocus();
                                          await apiService.insertProspectsAPI(context, apiService.prospectsList);
                                          setState(() {
                                            apiService.prospectsList.clear();
                                          });
                                        },
                                        height: 35,
                                        isLoading: true,
                                        backgroundColor: colorsConst.primary,
                                        radius: 2,
                                        width: 80,
                                        controller: controllers.productCtr,
                                        isImage: false,
                                        text: "Move",
                                        textColor: Colors.white,
                                      ),
                                      5.width
                                    ],
                                  ),
                                ],
                              );
                            });
                      },
                      onDisqualify: () {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return AlertDialog(
                                content: CustomText(
                                  text: "Are you sure disqualify this customers?",
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
                                        callback: (){
                                          _focusNode.requestFocus();
                                          apiService.disqualifiedCustomersAPI(context, apiService.prospectsList);
                                        },
                                        height: 35,
                                        isLoading: true,
                                        backgroundColor:
                                        colorsConst.primary,
                                        radius: 2,
                                        width: 100,
                                        controller: controllers.productCtr,
                                        isImage: false,
                                        text: "Disqualified",
                                        textColor:Colors.white,
                                      ),
                                      5.width
                                    ],
                                  ),
                                ],
                              );
                            });
                      },
                      searchController: controllers.search,
                      onSearchChanged: (value) {
                        controllers.searchQuery.value = value.toString();
                      },
                      onSelectMonth: () {
                        controllers.selectMonth(
                            context, controllers.selectedProspectSortBy, controllers.selectedMonth);
                      },
                      selectedMonth: controllers.selectedMonth,
                      selectedSortBy: controllers.selectedProspectSortBy,
                      isMenuOpen: controllers.isMenuOpen,
                    ),

                    10.height,
                    CustomTableHeader(
                      isAllSelected: controllers.isAllSelected.value,
                      onSelectAll: (value) {
                        if (value == true) {
                          controllers.isAllSelected.value = true;
                        } else {
                          controllers.isAllSelected.value = false;
                        }
                      },
                      onSortDate: () {
                        controllers.sortField.value = 'date';
                        controllers.sortOrder.value =
                        controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
                      },
                    ),
                    Expanded(
                      //height: MediaQuery.of(context).size.height/1.5,
                      child: Obx(() => controllers.isLead.value == false
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


