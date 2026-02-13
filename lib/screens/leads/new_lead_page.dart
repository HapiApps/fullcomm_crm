import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/components/left_lead_tile.dart';
import 'package:get/get.dart';
import '../../common/utilities/mail_utils.dart';
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_no_data.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_table_header.dart';
import '../../components/custom_text.dart';
import '../../components/left_table_header.dart';
import '../../controller/controller.dart';
import '../../services/api_services.dart';

class NewLeadPage extends StatefulWidget {
  final String index;
  final String name;
  const NewLeadPage({super.key, required this.index, required this.name});

  @override
  State<NewLeadPage> createState() => _NewLeadPageState();
}

class _NewLeadPageState extends State<NewLeadPage> {
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
      apiService.getCustomLeads(widget.index);
      apiService.currentVersion();
      // controllers.selectedIndex.value = 2;
      controllers.groupController.selectIndex(0);
      setState(() {
        controllers.search.clear();
        apiService.newLeadList = [];
        apiService.newLeadList.clear();
        //Santhiya
        controllers.isAllSelected.value = false;
        for (var item in controllers.isLeadsList) {
          item["isSelect"] = false;

          apiService.newLeadList.removeWhere(
                (e) => e["lead_id"] == item["lead_id"],
          );
        }
      });
      controllers.searchProspects.value = "";
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
                        title: "Leads - ${widget.name}",
                        subtitle: "View all of your ${widget.name} ${widget.index} Information",
                        list: controllers.allLeadFuture,
                      ),
                      20.height,
                      // Filter Section
                      FilterSection(
                        //Santhiya
                        itemCount: controllers.newLeadList.length,
                        focusNode: _focusNode,
                        leadFuture: controllers.allLeadFuture,
                        title: widget.name,
                        count: controllers.allLeadsLength.value,
                        itemList: apiService.newLeadList,
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
                                            await apiService.deleteCustomersAPI(context, apiService.newLeadList);
                                            setState(() {
                                              apiService.newLeadList.clear();
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
                          mailUtils.bulkEmailDialog(_focusNode, list: apiService.newLeadList);
                        },
                        onPromote: () {
                          debugPrint("onTap");
                          showDialog(
                            context: context,
                            builder: (context) {
                              String selectedStage="";
                              for (var i=0;i<controllers.leadCategoryList.length;i++){
                                if(i==int.parse(widget.index)){
                                  selectedStage=controllers.leadCategoryList[i]["value"];
                                }
                              }
                              bool isEdit=false;
                              TextEditingController reasonController = TextEditingController();
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Select Stage",
                                          size: 14,
                                          isBold: true,
                                          isCopy: false,
                                        ),
                                        8.height,
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: colorsConst.primary),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: DropdownButton<String>(
                                            value: selectedStage,
                                            isExpanded: true,
                                            focusColor: Colors.transparent,
                                            underline: SizedBox(),
                                            items: controllers.leadCategoryList.map((item) {
                                              return DropdownMenuItem<String>(
                                                value: item["value"],
                                                child: Text(item["value"]),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedStage = value!;
                                                isEdit=true;
                                              });
                                            },
                                          ),
                                        ),
                                        15.height,
                                        TextField(
                                          controller: reasonController,
                                          decoration: InputDecoration(
                                            labelText: "Reason",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
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
                                            callback: () async {
                                              if (selectedStage == "Suspects") {
                                                await apiService.insertLeadPromoteAPI(context, apiService.newLeadList);
                                              } else if (selectedStage == "Qualified") {
                                                await apiService.insertQualifiedAPI(context, apiService.newLeadList);
                                              } else if (selectedStage == "Customers") {
                                                await apiService.insertPromoteCustomerAPI(context, apiService.newLeadList);
                                              }
                                              // else {
                                              //   await apiService.insertProspectsAPI(context, [deleteData]);
                                              // }
                                              setState(() {
                                                apiService.newLeadList.clear();
                                              });
                                            },
                                            height: 35,
                                            isLoading: true,
                                            backgroundColor:
                                            colorsConst.primary,
                                            radius: 2,
                                            width: 80,
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
                              String selectedStage="Suspects";
                              bool isEdit=false;
                              TextEditingController reasonController = TextEditingController();
                              // setState(() {
                              //   selectedStage = "Suspects";
                              // });
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Select Stage",
                                          size: 14,
                                          isBold: true,
                                          isCopy: false,
                                        ),
                                        8.height,
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: colorsConst.primary),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: DropdownButton<String>(
                                            value: selectedStage,
                                            isExpanded: true,
                                            focusColor: Colors.transparent,
                                            underline: SizedBox(),
                                            items: [
                                              "Suspects",
                                              "Qualified",
                                              "Customers",
                                            ].map((value) {
                                              return DropdownMenuItem(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedStage = value!;
                                                isEdit=true;
                                              });
                                            },
                                          ),
                                        ),
                                        15.height,
                                        TextField(
                                          controller: reasonController,
                                          decoration: InputDecoration(
                                            labelText: "Reason",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
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
                                            callback: () async {
                                              String status="0";
                                              if (selectedStage == "Suspects") {
                                                status="1";
                                              } else if (selectedStage == "Qualified") {
                                                status="3";
                                              } else if (selectedStage == "Customers") {
                                                status="4";
                                              }
                                              await apiService.updateLeadStatus(context, apiService.newLeadList,status);
                                              setState(() {
                                                apiService.newLeadList.clear();
                                              });
                                            },
                                            height: 35,
                                            isLoading: true,
                                            backgroundColor:
                                            colorsConst.primary,
                                            radius: 2,
                                            width: 80,
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
                        searchController: controllers.search,
                        onSearchChanged: (value) {
                          controllers.searchProspects.value = value.toString();
                          final suggestions = controllers.searchNewLeadList.where(
                                  (user) {
                                final phone = user.mobileNumber.toString().toLowerCase();
                                final name = user.firstname.toString().toLowerCase();
                                final city = user.companyName.toString().toLowerCase();
                                final input = value.toString().toLowerCase().trim();
                                return phone.contains(input) ||name.contains(input) ||city.contains(input);
                              }).toList();
                          controllers.newLeadList.value = suggestions;
                        },
                        onSelectMonth: () {
                          controllers.selectMonth(
                              context, controllers.selectedQualifiedSortBy, controllers.selectedPMonth);
                        },
                        selectedMonth: controllers.selectedPMonth,
                        selectedSortBy: controllers.selectedQualifiedSortBy,
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
                              width: 300,
                              child: Column(
                                children: [
                                  LeftTableHeader(
                                    showCheckbox: true,
                                    isAllSelected: controllers.isAllSelected.value,
                                    onSelectAll: (value) async {
                                      if (controllers.newLeadList.isEmpty) return;
                                      await Future.microtask(() {
                                        apiService.newLeadList.clear();
                                        if (value == true) {
                                          controllers.isAllSelected.value = true;
                                          for (var lead in controllers.isLeadsList) {
                                            lead["isSelect"] = true;
                                            apiService.newLeadList.add({
                                              "lead_id": lead["lead_id"].toString(),
                                              "user_id": controllers.storage.read("id").toString(),
                                              "rating": lead["rating"].toString(),
                                              "cos_id": controllers.storage.read("cos_id").toString(),
                                            });
                                          }
                                        } else {
                                          controllers.isAllSelected.value = false;
                                          for (var lead in controllers.isLeadsList) {
                                            lead["isSelect"] = false;
                                          }
                                          apiService.newLeadList.clear();
                                        }
                                      });
                                      setState(() {});
                                    },
                                    onSortDate: () {
                                      controllers.sortField.value = 'date';
                                      controllers.sortOrder.value =
                                      controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
                                    },
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height - 345,
                                    child: Obx(() => controllers.newLeadList.isNotEmpty?
                                    ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                      child: ListView.builder(
                                        controller: _leftController,
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: controllers.newLeadList.length,
                                        itemBuilder: (context, index) {
                                          final data = controllers.newLeadList[index];
                                          return Obx(()=>LeftLeadTile(
                                            leadIndex: widget.index,
                                            pageName: "Prospects",
                                            saveValue: controllers.isLeadsList[index]["isSelect"],
                                            onChanged: (value) {
                                              controllers.isAllSelected.value = false;
                                              final lead = controllers.isLeadsList[index];
                                              final leadId = data.userId.toString();
                                              if (lead["isSelect"] == true) {
                                                lead["isSelect"] = false;
                                                apiService.newLeadList.removeWhere((e) => e["lead_id"] == leadId);
                                              } else {
                                                lead["isSelect"] = true;
                                                apiService.newLeadList.add({
                                                  "lead_id": leadId,
                                                  "user_id": controllers.storage.read("id").toString(),
                                                  "rating": data.rating ?? "Warm",
                                                  "cos_id": controllers.storage.read("cos_id").toString(),
                                                });
                                              }
                                              setState(() {});
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
                                child: SingleChildScrollView(
                                  controller: _horizontalController,
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 45,
                                        width: tableWidth,
                                        child: CustomTableHeader(
                                          onSortName: () {
                                            controllers.sortField.value = 'name';
                                            controllers.sortOrderN.value =
                                            controllers.sortOrderN.value == 'asc' ? 'desc' : 'asc';
                                          },
                                          onSortDate: () {
                                            controllers.sortField.value = 'date';
                                            controllers.sortOrder.value =
                                            controllers.sortOrder.value == 'asc' ? 'desc' : 'asc';
                                          },
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        height: MediaQuery.of(context).size.height - 345,
                                        width: tableWidth,
                                        child: Obx(
                                                () => controllers.isLead.value == false
                                                ? Container(
                                                    alignment: Alignment.centerLeft,
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.height,
                                                    padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
                                                    child: const Center(child: CircularProgressIndicator()))
                                                : controllers.newLeadList.isNotEmpty?
                                            ListView.builder(
                                              controller: _rightController,
                                              shrinkWrap: true,
                                              physics: const ScrollPhysics(),
                                              itemCount: controllers.newLeadList.length,
                                              itemBuilder: (context, index) {
                                                final data = controllers.newLeadList[index];
                                                return Obx(()=>CustomLeadTile(
                                                  pageName: "Prospects",
                                                  saveValue: controllers.isLeadsList[index]["isSelect"],
                                                  onChanged: (value){
                                                    setState(() {
                                                      if(controllers.isLeadsList[index]["isSelect"]==true){
                                                        controllers.isLeadsList[index]["isSelect"]=false;
                                                        var i=apiService.newLeadList.indexWhere((element) => element["lead_id"]==data.userId.toString());
                                                        apiService.newLeadList.removeAt(i);
                                                      }else{
                                                        controllers.isLeadsList[index]["isSelect"]=true;
                                                        apiService.newLeadList.add({
                                                          "lead_id":data.userId.toString(),
                                                          "user_id":controllers.storage.read("id"),
                                                          "rating":data.rating ?? "Warm",
                                                          "cos_id":controllers.storage.read("cos_id"),
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

                      controllers.newLeadList.isNotEmpty? Obx(() {
                        final totalPages = controllers.totalProspectPages == 0 ? 1 : controllers.totalProspectPages;
                        final currentPage = controllers.currentProspectPage.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            utils.paginationButton(Icons.chevron_left, currentPage > 1, () {
                              _focusNode.requestFocus();
                              controllers.currentProspectPage.value--;
                            }),
                            ...utils.buildPagination(totalPages, currentPage),
                            utils.paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                              controllers.currentProspectPage.value++;
                              _focusNode.requestFocus();
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
      ),
    );
  }
}
