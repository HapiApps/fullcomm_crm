import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/delete_button.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import '../../common/constant/api.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_lead_tile.dart';
import '../../components/custom_text.dart';
import '../../components/promote_button.dart';
import '../../controller/controller.dart';

class Qualified extends StatefulWidget {
  const Qualified({super.key});

  @override
  State<Qualified> createState() => _QualifiedState();
}

class _QualifiedState extends State<Qualified> {
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
        body: Container(
                width: MediaQuery.of(context).size.width - 130,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
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
                            Obx(
                              () => CustomText(
                                text:
                                    "Good Leads - ${controllers.leadCategoryList[2]["value"]}",
                                colors: colorsConst.textColor,
                                size: 25,
                                isBold: true,
                              ),
                            ),
                            10.height,
                            Obx(
                              () => CustomText(
                                text:
                                    "View all of your ${controllers.leadCategoryList[2]["value"]} Information",
                                colors: colorsConst.textColor,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                        // CustomLoadingButton(
                        //   callback: () {
                        //     utils.showImportDialog(context);
                        //   },
                        //   height: 35,
                        //   isLoading: false,
                        //   backgroundColor: colorsConst.third,
                        //   radius: 2,
                        //   width: 100,
                        //   isImage: false,
                        //   text: "Import",
                        //   textColor: Colors.black,
                        // ),
                      ],
                    ),
                    10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomText(
                              text: "Qualified",
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
                                  text: controllers.allGoodLeadsLength.value.toString(),
                                  colors: Colors.white,
                                  size: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DeleteButton(
                              leadList: apiService.customerList,
                              callback: () {
                                apiService.deleteCustomersAPI(
                                    context, apiService.customerList);
                              },
                            ),
                            5.width,
                            Obx(
                              () => PromoteButton(
                                headText: controllers.leadCategoryList[1]
                                    ["value"],
                                leadList: apiService.customerList,
                                callback: () {
                                  apiService.insertProspectsAPI(
                                      context, apiService.customerList);
                                },
                                text: "Demote",
                              ),
                            ),
                            5.width,
                            PromoteButton(
                              headText: "Customers",
                              leadList: apiService.customerList,
                              callback: () {
                                apiService.insertPromoteCustomerAPI(context);
                              },
                              text: "Promote",
                            ),
                          ],
                        )
                      ],
                    ),
                    10.height,
                    Divider(
                      thickness: 2,
                      color: colorsConst.secondary,
                    ),
                    15.height,
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
                                              for(int j=0;j<controllers.isGoodLeadList.length;j++){
                                                controllers.isGoodLeadList[j]["isSelect"]=false;
                                                setState((){
                                                  var i=apiService.customerList.indexWhere((element) => element["lead_id"]==controllers.isGoodLeadList[j]["lead_id"]);
                                                  apiService.customerList.removeAt(i);
                                                });
                                              }
                                            }else{
                                              controllers.isAllSelected.value=true;
                                              setState((){
                                                for(int j=0;j<controllers.isGoodLeadList.length;j++){
                                                  controllers.isGoodLeadList[j]["isSelect"]=true;
                                                  apiService.customerList.add({
                                                    "lead_id":controllers.isGoodLeadList[j]["lead_id"],
                                                    "user_id":controllers.storage.read("id"),
                                                    "rating":controllers.isGoodLeadList[j]["rating"],
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
                                          ? Colors.white
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
                              : controllers.paginatedQualifiedLeads.isNotEmpty?
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
                                itemCount: controllers.paginatedQualifiedLeads.length,
                                itemBuilder: (context, index) {
                                  final data = controllers.paginatedQualifiedLeads[index];
                                  return Obx(()=>CustomLeadTile(
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

                    20.height,
                  ],
                ),
              ),
      ),
    );
  }
}
