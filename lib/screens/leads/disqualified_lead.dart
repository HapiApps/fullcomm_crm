import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../common/constant/api.dart';
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_table_header.dart';
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
      apiService.currentVersion();
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
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controllers.selectedIndex.value = controllers.oldIndex.value;
        }
      },
      child: SelectionArea(
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
                  width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      HeaderSection(
                        title: "Disqualified",
                        subtitle: "View all of your disqualified Information",
                      ),
                      20.height,
                      // Filter Section
                      FilterSection(
                        title: "Disqualified",
                        count: controllers.allDisqualifiedLength.value,
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
                        onQualify: () {
                          showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return AlertDialog(
                                  content: CustomText(
                                    text: "Are you sure qualify this customers?",
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
                                            apiService.qualifiedCustomersAPI(context, apiService.prospectsList);
                                          },
                                          height: 35,
                                          isLoading: true,
                                          backgroundColor:
                                          colorsConst.primary,
                                          radius: 2,
                                          width: 100,
                                          controller: controllers.productCtr,
                                          isImage: false,
                                          text: "Qualified",
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
                        showCheckbox: true,
                        onSortName: () {
                          controllers.sortField.value = 'name';
                          controllers.sortOrderN.value =
                          controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
                        },
                        isAllSelected: controllers.isAllSelected.value,
                        onSelectAll: (value) {
                          if (value == true) {
                            controllers.isAllSelected.value = true;
                            setState(() {
                              for (int j = 0; j < controllers.isDisqualifiedList.length; j++) {
                                controllers.isDisqualifiedList[j]["isSelect"] = true;
                                apiService.prospectsList.add({
                                  "lead_id": controllers.isDisqualifiedList[j]["lead_id"],
                                  "user_id": controllers.storage.read("id"),
                                  "rating": controllers.isDisqualifiedList[j]["rating"],
                                  "cos_id": controllers.storage.read("cos_id"),
                                  "mail": controllers.isDisqualifiedList[j]["mail_id"],
                                });
                              }
                            });
                          } else {
                            controllers.isAllSelected.value = false;
                            for (int j = 0; j < controllers.isDisqualifiedList.length; j++) {
                              controllers.isDisqualifiedList[j]["isSelect"] = false;
                              setState(() {
                                var i = apiService.prospectsList.indexWhere((element) =>
                                element["lead_id"] == controllers.isDisqualifiedList[j]["lead_id"]);
                                apiService.prospectsList.removeAt(i);
                              });
                            }
                          }
                        },
                        onSortDate: () {
                          controllers.sortField.value = 'date';
                          controllers.sortOrder.value =
                          controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
                        },
                      ),
                      Expanded(
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
                                      pageName: "Disqualified",
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
                                                "cos_id":controllers.storage.read("cos_id"),
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
                                      updatedTs: data.updatedTs ?? "",
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
                      // Obx(() {
                      //   final totalPages = controllers.totalPages == 0 ? 1 : controllers.totalPages;
                      //   final currentPage = controllers.currentPage.value;
                      //   return Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       paginationButton(Icons.chevron_left, currentPage > 1, () {
                      //         _focusNode.requestFocus();
                      //         controllers.currentPage.value--;
                      //       }),
                      //       ...buildPagination(totalPages, currentPage),
                      //       paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                      //         controllers.currentPage.value++;
                      //         _focusNode.requestFocus();
                      //       }),
                      //     ],
                      //   );
                      // }),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}


