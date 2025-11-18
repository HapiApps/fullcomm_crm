import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/mail_utils.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_no_data.dart';
import 'package:fullcomm_crm/components/left_lead_tile.dart';
import 'package:fullcomm_crm/components/left_table_header.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_table_header.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';

class Suspects extends StatefulWidget {
  const Suspects({super.key});

  @override
  State<Suspects> createState() => _SuspectsState();
}

class _SuspectsState extends State<Suspects> {
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();

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
      controllers.selectedIndex.value = 1;
      controllers.groupController.selectIndex(0);
      setState(() {
        apiService.prospectsList = [];
        apiService.prospectsList.clear();
        controllers.search.clear();
      });
      controllers.searchQuery.value = "";
    });
    _leftController.addListener(() {
      if (_rightController.hasClients &&
          (_rightController.offset != _leftController.offset)) {
        _rightController.jumpTo(_leftController.offset);
      }
    });
    _rightController.addListener(() {
      if (_leftController.hasClients &&
          (_leftController.offset != _rightController.offset)) {
        _leftController.jumpTo(_rightController.offset);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _leftController.dispose();
    _rightController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double tableWidth;
    if (screenWidth >= 1600) {
      tableWidth = 4000;
    } else if (screenWidth >= 1200) {
      tableWidth = 3000;
    } else if (screenWidth >= 900) {
      tableWidth = 2400;
    } else {
      tableWidth = 2000;
    }
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
              SideBar(),
              Obx(() => InkWell(
                mouseCursor: MouseCursor.defer,
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
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      HeaderSection(
                        title: "New Leads - ${controllers.leadCategoryList[0]["value"]}",
                        subtitle: "View all of your ${controllers.leadCategoryList[0]["value"]} Information",
                        list: controllers.allNewLeadFuture,
                      ),
                      20.height,
                      // Filter Section
                      FilterSection(
                        leadFuture: controllers.allNewLeadFuture,
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
                          mailUtils.bulkEmailDialog(_focusNode, list: apiService.prospectsList);
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
                      Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          interactive: true,
                          thickness: 8,
                          radius: const Radius.circular(8),
                          scrollbarOrientation: ScrollbarOrientation.bottom,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 240,
                                child: Column(
                                  children: [
                                    LeftTableHeader(
                                      showCheckbox: true,
                                      isAllSelected: apiService.prospectsList.isEmpty?false:controllers.isAllSelected.value,
                                      onSelectAll: (value) {
                                      if(controllers.paginatedLeads.isNotEmpty){
                                        if (value == true) {
                                          controllers.isAllSelected.value = true;
                                          setState(() {
                                            for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                              controllers.isNewLeadList[j]["isSelect"] = true;
                                              apiService.prospectsList.add({
                                                "lead_id": controllers.isNewLeadList[j]["lead_id"],
                                                "user_id": controllers.storage.read("id"),
                                                "rating": controllers.isNewLeadList[j]["rating"],
                                                "cos_id": controllers.storage.read("cos_id"),
                                                "mail_id":controllers.isNewLeadList[j]["mail"]
                                              });
                                            }
                                          });
                                        } else {
                                          controllers.isAllSelected.value = false;
                                          for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                            controllers.isNewLeadList[j]["isSelect"] = false;
                                            setState((){
                                              var i=apiService.prospectsList.indexWhere((element) => element["lead_id"]==controllers.isNewLeadList[j]["lead_id"]);
                                              apiService.prospectsList.removeAt(i);
                                            });
                                          }
                                        }
                                      }else{
                                        print("No Data Found");
                                        controllers.isAllSelected.value = false;
                                      }
                                      },
                                      onSortDate: () {
                                        controllers.sortField.value = 'date';
                                        controllers.sortOrder.value =
                                        controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
                                      },
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height - 345,
                                      child: Obx(() => controllers.isLead.value == false
                                          ? 0.height
                                          : controllers.paginatedLeads.isNotEmpty?
                                      ScrollConfiguration(
                                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                              child: ListView.builder(
                                               controller: _leftController,
                                                shrinkWrap: true,
                                                physics: const ScrollPhysics(),
                                                itemCount: controllers.paginatedLeads.length,
                                                itemBuilder: (context, index) {
                                                  final data = controllers.paginatedLeads[index];
                                                  return Obx(()=>LeftLeadTile(
                                              pageName: "Suspects",
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
                                                      "cos_id":controllers.storage.read("cos_id"),
                                                      "mail_id":data.email.toString().split("||")[0]
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
                                              linkedin: data.linkedin,
                                              x: data.x,
                                              name: data.firstname.toString().split("||")[0],
                                              mobileNumber: data.mobileNumber.toString().split("||")[0],
                                              email: data.email.toString().split("||")[0],
                                              companyName: data.companyName.toString(),
                                              mainWhatsApp: data.whatsapp.toString().split("||")[0],
                                              emailUpdate: data.quotationUpdate.toString(),
                                              id: data.userId.toString(),
                                              status: data.leadStatus ?? "UnQualified",
                                              rating: data.rating ?? "Warm",
                                              mainName: data.firstname.toString().split("||")[0],
                                              mainMobile: data.mobileNumber.toString().split("||")[0],
                                              mainEmail: data.email.toString().split("||")[0],
                                              title: "",
                                              whatsappNumber: data.whatsapp.toString().split("||")[0],
                                              mainTitle: "",
                                              addressId: data.addressId ?? "",
                                              companyWebsite: data.companyWebsite ?? "",
                                              companyNumber: data.companyNumber ?? "",
                                              companyEmail: data.companyEmail ?? "",
                                              industry: data.industry ?? "",
                                              productServices: data.product ?? "",
                                              source:data.source ?? "",
                                              owner: data.owner ?? "",
                                              timelineDecision: "",
                                              serviceInterest: "",
                                              description: "",
                                              leadStatus: data.leadStatus ?? "",
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
                                            ):0.height
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Focus(
                                  autofocus: true,
                                  focusNode: _focusNode,
                                  onKey: (node, event) {
                                    if (event is RawKeyDownEvent) {
                                      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                        _leftController.animateTo(
                                          _leftController.offset + 100,
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                        );
                                        return KeyEventResult.handled;
                                      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                        _rightController.animateTo(
                                          _rightController.offset - 100,
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
                                  child:  SingleChildScrollView(
                                    controller: _horizontalController,
                                    scrollDirection: Axis.horizontal,
                                    physics: const ClampingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 45,
                                          width: tableWidth,
                                          child: CustomTableHeader(
                                            showCheckbox: true,
                                            isAllSelected: controllers.isAllSelected.value,
                                            onSelectAll: (value) {
                                              if (value == true) {
                                                controllers.isAllSelected.value = true;
                                                setState(() {
                                                  for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                                    controllers.isNewLeadList[j]["isSelect"] = true;
                                                    apiService.prospectsList.add({
                                                      "lead_id": controllers.isNewLeadList[j]["lead_id"],
                                                      "user_id": controllers.storage.read("id"),
                                                      "rating": controllers.isNewLeadList[j]["rating"],
                                                      "cos_id": controllers.storage.read("cos_id"),
                                                      "mail_id":controllers.isNewLeadList[j]["mail"]
                                                    });
                                                  }
                                                });
                                              } else {
                                                controllers.isAllSelected.value = false;
                                                for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                                  controllers.isNewLeadList[j]["isSelect"] = false;
                                                  setState((){
                                                    var i=apiService.prospectsList.indexWhere((element) => element["lead_id"]==controllers.isNewLeadList[j]["lead_id"]);
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
                                            onSortName: () {
                                              // controllers.sortField.value = 'name';
                                              // controllers.sortOrderN.value =
                                              // controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
                                            },
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          height: MediaQuery.of(context).size.height - 345,
                                          width: tableWidth,
                                          child: Obx(() => controllers.isLead.value == false
                                              ? Container(
                                              alignment: Alignment.centerLeft,
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height,
                                              padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
                                              child: const Center(child: CircularProgressIndicator()))
                                              : controllers.paginatedLeads.isNotEmpty?
                                          ListView.builder(
                                            controller: _rightController,
                                            shrinkWrap: true,
                                            physics: const ScrollPhysics(),
                                            itemCount: controllers.paginatedLeads.length,
                                            itemBuilder: (context, index) {
                                              final data = controllers.paginatedLeads[index];
                                              return Obx(()=>CustomLeadTile(
                                                pageName: "Suspects",
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
                                                        "cos_id":controllers.storage.read("cos_id"),
                                                        "mail_id":data.email.toString().split("||")[0]
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
                                                linkedin: data.linkedin,
                                                x: data.x,
                                                name: data.firstname.toString().split("||")[0],
                                                mobileNumber: data.mobileNumber.toString().split("||")[0],
                                                email: data.email.toString().split("||")[0],
                                                companyName: data.companyName.toString(),
                                                mainWhatsApp: data.whatsapp.toString().split("||")[0],
                                                emailUpdate: data.quotationUpdate.toString(),
                                                id: data.userId.toString(),
                                                status: data.leadStatus ?? "UnQualified",
                                                rating: data.rating ?? "Warm",
                                                mainName: data.firstname.toString().split("||")[0],
                                                mainMobile: data.mobileNumber.toString().split("||")[0],
                                                mainEmail: data.email.toString().split("||")[0],
                                                title: "",
                                                whatsappNumber: data.whatsapp.toString().split("||")[0],
                                                mainTitle: "",
                                                addressId: data.addressId ?? "",
                                                companyWebsite: data.companyWebsite ?? "",
                                                companyNumber: data.companyNumber ?? "",
                                                companyEmail: data.companyEmail ?? "",
                                                industry: data.industry ?? "",
                                                productServices: data.product ?? "",
                                                source:data.source ?? "",
                                                owner: data.owner ?? "",
                                                timelineDecision: "",
                                                serviceInterest: "",
                                                description: "",
                                                leadStatus: data.leadStatus ?? "",
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
                                          ):
                                          CustomNoData()
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Obx(() {
                        final totalPages = controllers.totalPages == 0 ? 1 : controllers.totalPages;
                        final currentPage = controllers.currentPage.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
                              _focusNode.requestFocus();
                              controllers.currentPage.value--;
                            }),
                            ...utils.buildPagination(totalPages, currentPage),
                            utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
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
      ),
    );
  }
}


