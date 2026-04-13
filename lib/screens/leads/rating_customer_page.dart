
import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/components/customer_name_tile.dart';
import 'package:get/get.dart';
import '../../common/utilities/mail_utils.dart';
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_no_data.dart';
import '../../components/custom_sidebar.dart';
import '../../components/dynamic_table_header.dart';
import '../../components/custom_text.dart';
import '../../components/customer_name_header.dart';
import '../../controller/controller.dart';
import '../../controller/table_controller.dart';
import '../../models/new_lead_obj.dart';
import '../../services/api_services.dart';

class RatingPage extends StatefulWidget {
  final String rep;
  final String type;
  const RatingPage({super.key, required this.type, required this.rep});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();
  late FocusNode _focusNode;
  void searchBy(){
    controllers.searchProspects.value = controllers.search.text;
    if(controllers.search.text.trim().isNotEmpty){
      final suggestions = controllers.ratingList2.where(
              (user) {
            final phone = user.mobileNumber.toString().toLowerCase();
            final name = user.firstname.toString().toLowerCase();
            final city = user.companyName.toString().toLowerCase();
            final input = controllers.search.text.toString().toLowerCase().trim();
            return phone.contains(input) ||name.contains(input) ||city.contains(input);
          }).toList();
      controllers.ratingList.value = suggestions;
    }
    controllers.selectRadio(controllers.ratingList, controllers.ratingList2);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // debugPrint("controllers.ratingList: ${controllers.ratingList}");
    // debugPrint("controllers.ratingList2: ${controllers.ratingList}");
    // debugPrint("controllers.ratingList: ${controllers.ratingList.length}");
    // debugPrint("controllers.ratingList2: ${controllers.ratingList2.length}");
    if(widget.rep=="1"){
      apiService.getCustomerRatingDetails(widget.type);
    }else{
      apiService.getLeadRatingDetails(widget.type);
    }
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      searchBy();
      controllers.totalProspectPages.value=(controllers.ratingList2.length / controllers.itemsPerPage).ceil();
    });
    Future.delayed(Duration.zero, () {
      controllers.selectRadio(controllers.ratingList,controllers.ratingList2);
      apiService.currentVersion();
      controllers.groupController.selectIndex(0);
      setState(() {
        // controllers.search.clear();
        controllers.idList.clear();
        for (var lead in controllers.ratingList) {
          lead.select = false;
        }
        // apiService.newLeadList = [];
        // apiService.newLeadList.clear();
        // //Santhiya
        controllers.isAllSelected.value = false;
        // for (var item in controllers.isLeadsList) {
        //   item["isSelect"] = false;
        //
        //   controllers.ratingList.removeWhere(
        //         (e) => e.userId== item["lead_id"],
        //   );
        // }
      });
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
    _horizontalController.dispose();
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    // double tableWidth;
    // if (screenWidth >= 1600) {
    //   tableWidth = 4000;
    // } else if (screenWidth >= 1200) {
    //   tableWidth = 3000;
    // } else if (screenWidth >= 900) {
    //   tableWidth = 2400;
    // } else {
    //   tableWidth = 2000;
    // }
    double tableWidth = tableController.tableHeadings.fold(
      0.0,
          (sum, h) => sum + (tableController.colWidth[h] ?? 150),
    );
    return SelectionArea(
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Obx(() => Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(20, 5, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    HeaderSection(
                      list: controllers.ratingList,list2: controllers.ratingList2,
                      title: "Leads - ${widget.type}",
                      subtitle: "View all of your ${widget.type} Information",
                      // list: controllers.allLeadFuture,
                    ),
                    20.height,
                    // Filter Section
                    FilterSection(
                      //Santhiya
                      leadIndex: "1000",
                      itemCount: controllers.ratingList.length,
                      count: controllers.ratingList2.length,
                      // count: controllers.allLeadList.length,
                      focusNode: _focusNode,
                      leadFuture: controllers.allLeadFuture,
                      title: widget.type,
                      itemList: controllers.idList,
                      onDelete: () {
                        _focusNode.requestFocus();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                content: CustomText(
                                  text: "Are you sure delete this lead?",
                                  size: 16,
                                  isCopy: false,
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
                                              isCopy: false,
                                              colors: colorsConst.primary,
                                              size: 14,
                                            )),
                                      ),
                                      10.width,
                                      CustomLoadingButton(
                                        callback: ()async{
                                          _focusNode.requestFocus();
                                          await apiService.deleteCustomersAPI(context, controllers.idList.value,controllers.ratingList,controllers.ratingList2);
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
                        // mailUtils.bulkEmailDialog(_focusNode, list: controllers.ratingList);
                        // mailUtils.bulkEmailDialog(_focusNode, list: controllers.allLeadList);
                        mailUtils.bulkEmail(_focusNode, list: controllers.ratingList);
                      },
                      onPromote: () {
                        debugPrint("onTapppp");
                        showDialog(
                          context: context,
                          builder: (context) {
                            String? stageId;
                            String selectedStage = "";
                            bool isEdit = false;

                            TextEditingController reasonController =
                            TextEditingController();

                            // int currentIndex = int.parse(widget.index.toString());
                            // int nextIndex = currentIndex + 1;

                            // Safe default selection
                            // if (controllers.leadCategoryList.isNotEmpty) {
                            //   if (nextIndex <
                            //       controllers.leadCategoryList.length) {
                            //     stageId = controllers
                            //         .leadCategoryList[nextIndex].leadStatus;
                            //     selectedStage = controllers
                            //         .leadCategoryList[nextIndex].value;
                            //   } else {
                            //     stageId =
                            //         controllers.leadCategoryList[0].leadStatus;
                            //     selectedStage =
                            //         controllers.leadCategoryList[0].value;
                            //   }
                            // }

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: CustomText(
                                    text: "Move to Next Level",
                                    size: 18,
                                    isBold: true,
                                    isCopy: false,
                                    colors: colorsConst.textColor,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: "New Stage",
                                        size: 14,
                                        isBold: true,
                                        isCopy: false,
                                      ),
                                      const SizedBox(height: 8),

                                      /// DROPDOWN
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: colorsConst.primary),
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        child: DropdownButton<String>(
                                          value: controllers
                                              .leadCategoryList
                                              .any((e) =>
                                          e.leadStatus ==
                                              stageId)
                                              ? stageId
                                              : null,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          items: controllers
                                              .leadCategoryList
                                              .map((item) {
                                            return DropdownMenuItem<String>(
                                              value: item.leadStatus,
                                              child: Text(item.value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              stageId = value;
                                              selectedStage = controllers
                                                  .leadCategoryList
                                                  .firstWhere((e) =>
                                              e.leadStatus ==
                                                  value)
                                                  .value;
                                              isEdit = true;
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      /// REASON FIELD
                                      TextField(
                                        controller: reasonController,
                                        decoration:
                                        const InputDecoration(
                                          labelText: "Reason",
                                          border:
                                          OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  /// ACTIONS
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        /// CANCEL
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                colorsConst.primary),
                                            color: Colors.white,
                                          ),
                                          width: 80,
                                          height: 30,
                                          child: ElevatedButton(
                                            style:
                                            ElevatedButton.styleFrom(
                                              shape:
                                              const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.zero,
                                              ),
                                              backgroundColor:
                                              Colors.white,
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(
                                                  context);
                                            },
                                            child: CustomText(
                                              text: "Cancel",
                                              isCopy: false,
                                              colors:
                                              colorsConst.primary,
                                              size: 14,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        /// PROMOTE BUTTON
                                        CustomLoadingButton(
                                          callback: () async {
                                            if (stageId == null) return;

                                            await apiService
                                                .insertPromoteListAPI(
                                              context,
                                              stageId.toString(),
                                              selectedStage,
                                              controllers.ratingList,
                                              controllers.ratingList2,
                                            );

                                            Navigator.pop(context);
                                          },
                                          height: 35,
                                          isLoading: true,
                                          backgroundColor:
                                          colorsConst.primary,
                                          radius: 2,
                                          width: 90,
                                          controller:
                                          controllers.productCtr,
                                          isImage: false,
                                          text: "Promote",
                                          textColor: Colors.white,
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      onDemote: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String? stageId;
                            String selectedStage = "";
                            bool isEdit = false;

                            TextEditingController reasonController =
                            TextEditingController();

                            // int currentIndex = int.parse(widget.index.toString());
                            // int nextIndex = currentIndex + 1;

                            // Safe default selection
                            // if (controllers.leadCategoryList.isNotEmpty) {
                            //   if (nextIndex <
                            //       controllers.leadCategoryList.length) {
                            //     stageId = controllers
                            //         .leadCategoryList[nextIndex].leadStatus;
                            //     selectedStage = controllers
                            //         .leadCategoryList[nextIndex].value;
                            //   } else {
                            //     stageId =
                            //         controllers.leadCategoryList[0].leadStatus;
                            //     selectedStage =
                            //         controllers.leadCategoryList[0].value;
                            //   }
                            // }

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: CustomText(
                                    text: "Move to Next Level",
                                    size: 18,
                                    isBold: true,
                                    isCopy: false,
                                    colors: colorsConst.textColor,
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: "New Stage",
                                        size: 14,
                                        isBold: true,
                                        isCopy: false,
                                      ),
                                      const SizedBox(height: 8),

                                      /// DROPDOWN
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: colorsConst.primary),
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        child: DropdownButton<String>(
                                          value: controllers
                                              .leadCategoryList
                                              .any((e) =>
                                          e.leadStatus ==
                                              stageId)
                                              ? stageId
                                              : null,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          items: controllers
                                              .leadCategoryList
                                              .map((item) {
                                            return DropdownMenuItem<String>(
                                              value: item.leadStatus,
                                              child: Text(item.value),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              stageId = value;
                                              selectedStage = controllers
                                                  .leadCategoryList
                                                  .firstWhere((e) =>
                                              e.leadStatus ==
                                                  value)
                                                  .value;
                                              isEdit = true;
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      /// REASON FIELD
                                      TextField(
                                        controller: reasonController,
                                        decoration:
                                        const InputDecoration(
                                          labelText: "Reason",
                                          border:
                                          OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  /// ACTIONS
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        /// CANCEL
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                colorsConst.primary),
                                            color: Colors.white,
                                          ),
                                          width: 80,
                                          height: 30,
                                          child: ElevatedButton(
                                            style:
                                            ElevatedButton.styleFrom(
                                              shape:
                                              const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.zero,
                                              ),
                                              backgroundColor:
                                              Colors.white,
                                              elevation: 0,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(
                                                  context);
                                            },
                                            child: CustomText(
                                              text: "Cancel",
                                              isCopy: false,
                                              colors:
                                              colorsConst.primary,
                                              size: 14,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        /// PROMOTE BUTTON
                                        CustomLoadingButton(
                                          callback: () async {
                                            if (stageId == null) return;

                                            await apiService
                                                .insertPromoteListAPI(
                                              context,
                                              stageId.toString(),
                                              selectedStage,
                                              controllers.ratingList,
                                              controllers.ratingList2,
                                            );

                                            Navigator.pop(context);
                                          },
                                          height: 35,
                                          isLoading: true,
                                          backgroundColor:
                                          colorsConst.primary,
                                          radius: 2,
                                          width: 90,
                                          controller:
                                          controllers.productCtr,
                                          isImage: false,
                                          text: "Demote",
                                          textColor: Colors.white,
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },

                      searchController: controllers.search,
                      onSearchChanged: (value) {
                        controllers.searchProspects.value = controllers.search.text;

                        final input = controllers.search.text.toLowerCase().trim();
                        final inputNoSpace = input.replaceAll(" ", "");

                        final suggestions = controllers.ratingList2.where((user) {

                          final company = user.companyName.toString().toLowerCase();
                          final name = user.firstname.toString().toLowerCase();
                          final phone = user.mobileNumber.toString().toLowerCase();

                          final companyNoSpace = company.replaceAll(" ", "");
                          final nameNoSpace = name.replaceAll(" ", "");

                          // initials
                          final companyInitial =
                          company.split(" ").where((e) => e.isNotEmpty).map((e) => e[0]).join();
                          final nameInitial =
                          name.split(" ").where((e) => e.isNotEmpty).map((e) => e[0]).join();

                          return company.contains(input) ||
                              name.contains(input) ||
                              phone.contains(input) ||
                              companyNoSpace.contains(inputNoSpace) ||
                              nameNoSpace.contains(inputNoSpace) ||
                              companyInitial.contains(inputNoSpace) ||
                              nameInitial.contains(inputNoSpace);
                        }).toList();

                        controllers.ratingList.value = suggestions;
                        print("onchanged called");

                        controllers.selectRadio(controllers.ratingList, controllers.ratingList2);
                      },
                      onSelectMonth: () {
                        controllers.selectMonth(
                            context, controllers.selectedQualifiedSortBy, controllers.selectedPMonth,controllers.ratingList,controllers.ratingList2);
                      },
                      selectedMonth: controllers.selectedPMonth,
                      selectedSortBy: controllers.selectedQualifiedSortBy,
                      isMenuOpen: controllers.isMenuOpen, list: controllers.ratingList, list2: controllers.ratingList2,
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
                            width: 300,
                            child: Column(
                              children: [
                                CustomerNameHeader(
                                  showCheckbox: true,
                                  isAllSelected: controllers.isAllSelected.value,
                                  onSelectAll: (value) async {
                                    if (controllers.ratingList.isEmpty) return;
                                    await Future.microtask(() {
                                      if (value == true) {
                                        controllers.isAllSelected.value = true;
                                        for (var lead in controllers.ratingList) {
                                          lead.select = true;
                                          controllers.idList.add(lead.userId);
                                        }
                                      } else {
                                        controllers.isAllSelected.value = false;
                                        controllers.idList.clear();
                                        for (var lead in controllers.ratingList) {
                                          lead.select = false;
                                        }
                                      }
                                    });
                                    setState(() {});
                                    debugPrint("...${controllers.idList}");
                                  },
                                  onSortDate: () {
                                    setState(() {
                                      controllers.sortField.value = 'name';
                                      controllers.sortOrder.value =
                                      controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
                                      controllers.changePage(controllers.ratingList,controllers.ratingList2);
                                      // if(controllers.sortOrder.value=="asc"){
                                      //   controllers.ratingList.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
                                      //   controllers.ratingList2.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
                                      // }else{
                                      //   controllers.ratingList.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
                                      //   controllers.ratingList2.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
                                      // }
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height - 345,
                                  child: Obx(() {
                                    if(controllers.ratingList.isEmpty){
                                      return 0.height;
                                    }

                                    // sortedList.sort((a, b) {
                                    //   DateTime dateA = DateTime.tryParse(a.createdTs ?? '') ?? DateTime(1970);
                                    //   DateTime dateB = DateTime.tryParse(b.createdTs ?? '') ?? DateTime(1970);
                                    //   return dateB.compareTo(dateA);
                                    // });
                                    return ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                      child: ListView.builder(
                                        controller: _leftController,
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: controllers.ratingList.length,
                                        itemBuilder: (context, index) {
                                          NewLeadObj data = controllers.ratingList[index];
                                          return CustomerNameTile(
                                            key: ValueKey(data.userId),
                                            listIndex: index,
                                            list: controllers.ratingList,list2: controllers.ratingList2,
                                            leadIndex: "1000",
                                            pageName: widget.type,
                                            saveValue: data.select==true?true:false,
                                            onChanged: (value) {
                                              controllers.isAllSelected.value = false;
                                              final lead = data;
                                              if (lead.select == true) {
                                                lead.select = false;
                                                controllers.idList.remove(lead.userId);
                                              } else {
                                                lead.select = true;
                                                controllers.idList.add(lead.userId);
                                              }
                                              setState(() {});
                                              debugPrint("...${controllers.idList}");
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
                                            mobileNumber: data.mobileNumber.toString(),
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
                                          );
                                        },
                                      ),
                                    );
                                  }
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
                              child: SingleChildScrollView(
                                controller: _horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width: tableWidth,
                                      child: DynamicTableHeader(
                                        onSortName: () {
                                          controllers.sortField.value = 'name';
                                          controllers.sortOrderN.value =
                                          controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
                                        },
                                        onSortDate: () {
                                          setState(() {
                                            controllers.sortField.value = 'date';
                                            controllers.sortOrder.value =
                                            controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
                                            // if(controllers.sortOrder.value=="asc"){
                                            //   controllers.ratingList.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
                                            //   controllers.ratingList2.sort((a, b) => a.firstname.toString().toLowerCase().compareTo(b.firstname.toString().toLowerCase()));
                                            // }else{
                                            //   controllers.ratingList.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
                                            //   controllers.ratingList2.sort((a, b) => b.firstname.toString().toLowerCase().compareTo(a.firstname.toString().toLowerCase()));
                                            // }
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      height: MediaQuery.of(context).size.height - 345,
                                      width: tableWidth,
                                      child: Obx(() {
                                        if (controllers.isLead.value == false) {
                                          return Container(
                                              alignment: Alignment.centerLeft,
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height,
                                              padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
                                              child: const Center(child: CircularProgressIndicator()));
                                        }

                                        if (controllers.ratingList.isEmpty) {
                                          return CustomNoData();
                                        }

                                        // sortedList.sort((a, b) {
                                        //   DateTime dateA = DateTime.tryParse(a.createdTs ?? '') ?? DateTime(1970);
                                        //   DateTime dateB = DateTime.tryParse(b.createdTs ?? '') ?? DateTime(1970);
                                        //   return dateB.compareTo(dateA);
                                        // });
                                        return ListView.builder(
                                          controller: _rightController,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: controllers.ratingList.length,
                                          itemBuilder: (context, index) {
                                            NewLeadObj data = controllers.ratingList[index];
                                            return CustomLeadTile(
                                              leadIndex: "1000",
                                              key: ValueKey(data.userId),
                                              listIndex: index,
                                              list: controllers.ratingList,list2: controllers.ratingList2,
                                              pageName: widget.type,
                                              saveValue: data.select==true?true:false,
                                              onChanged: (value) {
                                                controllers.isAllSelected.value = false;
                                                final lead = data;
                                                if (lead.select == true) {
                                                  lead.select = false;
                                                  controllers.idList.remove(lead.userId);
                                                } else {
                                                  lead.select = true;
                                                  controllers.idList.add(lead.userId);
                                                }
                                                setState(() {});
                                                debugPrint("...${controllers.idList}");
                                              },
                                              visitType: data.visitType.toString(),
                                              detailsOfServiceReq: data.detailsOfServiceRequired.toString(),
                                              statusUpdate: data.statusUpdate.toString(),
                                              department: data.department.toString(),
                                              designation: data.designation.toString(),
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
                                              status: data.status,
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
                                            );
                                          },
                                        );
                                      }
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

                    controllers.ratingList.isNotEmpty? Obx(() {
                      int totalPages = controllers.totalProspectPages.value == 0 ? 1 : controllers.totalProspectPages.value;
                      final currentPage = controllers.currentProspectPage.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
                            _focusNode.requestFocus();
                            controllers.currentProspectPage.value--;
                            controllers.changePage(controllers.ratingList,controllers.ratingList2);
                            print("controllers.currentProspectPage.value --- ${controllers.currentProspectPage.value}");
                          }),
                          ...utils.buildPagination(totalPages, currentPage),
                          utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                            controllers.currentProspectPage.value++;
                            _focusNode.requestFocus();
                            controllers.changePage(controllers.ratingList,controllers.ratingList2);
                            print("controllers.currentProspectPage.value +++ ${controllers.currentProspectPage.value}");
                          }),
                        ],
                      );
                    }):0.height,
                    20.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
