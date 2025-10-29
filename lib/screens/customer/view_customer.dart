import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
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
import '../../services/api_services.dart';

class ViewCustomer extends StatefulWidget {
  const ViewCustomer({super.key});

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  late FocusNode _focusNode;
  Future refresh() async {
    refreshKey.currentState?.show(atTop: false);
    controllers.allCustomerFuture = apiService.allCustomerDetails();
    //await Future.delayed(const Duration(seconds: 3));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    Future.delayed(Duration.zero, () {
      controllers.search.clear();
      controllers.selectedIndex.value = 4;
      controllers.groupController.selectIndex(0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
                  children: [
                    // Header Section
                    HeaderSection(
                      title: "Customers",
                      subtitle: "View all of your Customer Information",
                    ),
                    // Filter Section
                    FilterSection(
                      title: "Customers",
                      count: controllers.allCustomerLength.value,
                      itemList: [],
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
                        controllers.searchCustomers.value = value.toString();
                      },
                      onSelectMonth: () {
                        controllers.selectMonth(
                            context, controllers.selectedCustomerSortBy, controllers.selectedQPMonth);
                      },
                      selectedMonth: controllers.selectedQPMonth,
                      selectedSortBy: controllers.selectedCustomerSortBy,
                      isMenuOpen: controllers.isMenuOpen,
                    ),
                    10.height,
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
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              height: MediaQuery.of(context).size.height - 340,
                              width: 4000,
                              child: Obx(() => controllers.isLead.value == false
                                  ? Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height - 340,
                                  alignment: Alignment.center,
                                  child: const Center(child: CircularProgressIndicator()))
                                  : controllers.paginatedCustomerLeads.isNotEmpty?
                              ListView.builder(
                                controller: _verticalController,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: controllers.paginatedCustomerLeads.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.paginatedCustomerLeads[index];
                                  return Obx(()=>CustomLeadTile(
                                    pageName: "Customers",
                                    showCheckbox: true,
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
                                    linkedin: "",
                                    x: "",
                                    name: data.firstname.toString().split("||")[0],
                                    mobileNumber: data.mobileNumber.toString().split("||")[0],
                                    email: data.email.toString().split("||")[0],
                                    companyName: data.companyName.toString(),
                                    mainWhatsApp: data.mobileNumber.toString().split("||")[0],
                                    emailUpdate: data.quotationUpdate.toString(),
                                    id: data.userId.toString(),
                                    status: data.leadStatus ?? "UnQualified",
                                    rating: data.rating ?? "Warm",
                                    mainName: data.firstname.toString().split("||")[0],
                                    mainMobile: data.mobileNumber.toString().split("||")[0],
                                    mainEmail: data.email.toString().split("||")[0],
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
                              ):
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: Center(
                                    child: SvgPicture.asset(
                                        "assets/images/noDataFound.svg")),
                              )
                              ),
                            ),
                          ],
                        ),
                      ),
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
