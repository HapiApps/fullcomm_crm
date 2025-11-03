import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_no_data.dart';
import 'package:fullcomm_crm/components/left_lead_tile.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../common/constant/api.dart';
import '../../components/custom_filter_seaction.dart';
import '../../components/custom_header_seaction.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_table_header.dart';
import '../../components/custom_text.dart';
import '../../components/left_table_header.dart';
import '../../controller/controller.dart';

class Qualified extends StatefulWidget {
  const Qualified({super.key});

  @override
  State<Qualified> createState() => _QualifiedState();
}

class _QualifiedState extends State<Qualified> {
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
      controllers.selectedIndex.value = 3;
      controllers.groupController.selectIndex(0);
      setState(() {
        controllers.search.clear();
        apiService.customerList = [];
        apiService.customerList.clear();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double minPartWidth = screenSize.width - 380.0;
    final double partWidth = minPartWidth / 10;
    final double adjustedPartWidth = partWidth;
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
              Obx(()=>Container(
                width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    HeaderSection(
                      title: "Good Leads - ${controllers.leadCategoryList[2]["value"]}",
                      subtitle: "View all of your ${controllers.leadCategoryList[2]["value"]} Information",
                    ),
                    20.height,
                    // Filter Section
                    FilterSection(
                      title: "Qualified",
                      count: controllers.allGoodLeadsLength.value,
                      itemList: apiService.customerList,
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
                                          await apiService.deleteCustomersAPI(context, apiService.customerList);
                                          setState(() {
                                            apiService.customerList.clear();
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
                        utils.bulkEmailDialog(_focusNode, list: apiService.customerList);
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
                                          await apiService.insertPromoteCustomerAPI(context,apiService.customerList);
                                          setState(() {
                                            apiService.customerList.clear();
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
                      onDemote: () {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) {
                              return AlertDialog(
                                content: CustomText(
                                  text: "Are you sure demote this customers?",
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
                                          apiService.insertProspectsAPI(
                                              context, apiService.customerList);
                                        },
                                        height: 35,
                                        isLoading: true,
                                        backgroundColor:
                                        colorsConst.primary,
                                        radius: 2,
                                        width: 100,
                                        controller: controllers.productCtr,
                                        isImage: false,
                                        text: "Demote",
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
                        controllers.searchQualified.value = value.toString();
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 400,
                          child: Column(
                            children: [
                              LeftTableHeader(
                                showCheckbox: true,
                                isAllSelected: controllers.isAllSelected.value,
                                onSelectAll: (value) {
                                  if (value == true) {
                                    controllers.isAllSelected.value = true;
                                    setState((){
                                      for(int j=0;j<controllers.isGoodLeadList.length;j++){
                                        controllers.isGoodLeadList[j]["isSelect"]=true;
                                        apiService.customerList.add({
                                          "lead_id":controllers.isGoodLeadList[j]["lead_id"],
                                          "user_id":controllers.storage.read("id"),
                                          "rating":controllers.isGoodLeadList[j]["rating"],
                                          "cos_id":controllers.storage.read("cos_id"),
                                        });
                                      }
                                    });
                                  } else {
                                    controllers.isAllSelected.value = false;
                                    for(int j=0;j<controllers.isGoodLeadList.length;j++){
                                      controllers.isGoodLeadList[j]["isSelect"]=false;
                                      setState((){
                                        var i=apiService.customerList.indexWhere((element) => element["lead_id"]==controllers.isGoodLeadList[j]["lead_id"]);
                                        apiService.customerList.removeAt(i);
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
                              Obx(() => controllers.paginatedQualifiedLeads.isNotEmpty?
                              ListView.builder(
                                controller: _verticalController,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: controllers.paginatedQualifiedLeads.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.paginatedQualifiedLeads[index];
                                  return Obx(()=>LeftLeadTile(
                                    pageName: "Qualified",
                                    saveValue: controllers.isGoodLeadList[index]["isSelect"],
                                    onChanged: (value){
                                      setState(() {
                                        if(controllers.isGoodLeadList[index]["isSelect"]==true){
                                          controllers.isGoodLeadList[index]["isSelect"]=false;
                                          var i=apiService.customerList.indexWhere((element) => element["lead_id"]==data.userId.toString());
                                          apiService.customerList.removeAt(i);
                                        }else{
                                          controllers.isGoodLeadList[index]["isSelect"]=true;
                                          apiService.customerList.add({
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
                              ):0.height
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
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 45,
                                    width: 4000,
                                    child: CustomTableHeader(
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
                                          setState((){
                                            for(int j=0;j<controllers.isGoodLeadList.length;j++){
                                              controllers.isGoodLeadList[j]["isSelect"]=true;
                                              apiService.customerList.add({
                                                "lead_id":controllers.isGoodLeadList[j]["lead_id"],
                                                "user_id":controllers.storage.read("id"),
                                                "rating":controllers.isGoodLeadList[j]["rating"],
                                                "cos_id":controllers.storage.read("cos_id"),
                                              });
                                            }
                                          });
                                        } else {
                                          controllers.isAllSelected.value = false;
                                          for(int j=0;j<controllers.isGoodLeadList.length;j++){
                                            controllers.isGoodLeadList[j]["isSelect"]=false;
                                            setState((){
                                              var i=apiService.customerList.indexWhere((element) => element["lead_id"]==controllers.isGoodLeadList[j]["lead_id"]);
                                              apiService.customerList.removeAt(i);
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
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    height: MediaQuery.of(context).size.height - 340,
                                    width: 4000,
                                    child: Obx(
                                            () => controllers.isLead.value == false
                                            ? Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: MediaQuery.of(context).size.height - 340,
                                                alignment: Alignment.center,
                                                child: const Center(child: CircularProgressIndicator()))
                                            : controllers.paginatedQualifiedLeads.isNotEmpty?
                                        ListView.builder(
                                          controller: _verticalController,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: controllers.paginatedQualifiedLeads.length,
                                          itemBuilder: (context, index) {
                                            final data = controllers.paginatedQualifiedLeads[index];
                                            return Obx(()=>CustomLeadTile(
                                              pageName: "Qualified",
                                              saveValue: controllers.isGoodLeadList[index]["isSelect"],
                                              onChanged: (value){
                                                setState(() {
                                                  if(controllers.isGoodLeadList[index]["isSelect"]==true){
                                                    controllers.isGoodLeadList[index]["isSelect"]=false;
                                                    var i=apiService.customerList.indexWhere((element) => element["lead_id"]==data.userId.toString());
                                                    apiService.customerList.removeAt(i);
                                                  }else{
                                                    controllers.isGoodLeadList[index]["isSelect"]=true;
                                                    apiService.customerList.add({
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

                    20.height,
                  ],
                ),
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
