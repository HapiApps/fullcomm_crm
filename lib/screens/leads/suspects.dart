import 'package:flutter/services.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:fullcomm_crm/components/custom_search_textfield.dart';
import 'package:fullcomm_crm/components/delete_button.dart';
import 'package:fullcomm_crm/components/promote_button.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constant/api.dart';
import '../../components/custom_checkbox.dart';
import '../../components/custom_lead_tile.dart';
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

  void _showSortPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // optional: no dark background
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.only(top: 200, right: 200),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: colorsConst.secondary,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => RadioListTile<String>(
                        title: CustomText(
                          text: "Today",
                          colors: colorsConst.textColor,
                        ),
                        value: "Today",
                        groupValue: controllers.selectedProspectSortBy.value,
                        onChanged: (value) {
                          controllers.selectedProspectSortBy.value = value!;
                          Navigator.pop(context); // close popup
                        },
                        activeColor: colorsConst.third,
                      )),
                  Obx(() => RadioListTile<String>(
                        title: CustomText(
                            text: "Last 7 Days", colors: colorsConst.textColor),
                        value: "Last 7 Days",
                        groupValue: controllers.selectedProspectSortBy.value,
                        onChanged: (value) {
                          controllers.selectedProspectSortBy.value = value!;
                          Navigator.pop(context);
                        },
                        activeColor: colorsConst.third,
                      )),
                  Obx(() => RadioListTile<String>(
                        title: CustomText(
                            text: "Last 30 Days",
                            colors: colorsConst.textColor),
                        value: "Last 30 Days",
                        groupValue: controllers.selectedProspectSortBy.value,
                        onChanged: (value) {
                          controllers.selectedProspectSortBy.value = value!;
                          Navigator.pop(context);
                        },
                        activeColor: colorsConst.third,
                      )),
                  Obx(() => RadioListTile<String>(
                        title: CustomText(
                            text: "All", colors: colorsConst.textColor),
                        value: "All",
                        groupValue: controllers.selectedProspectSortBy.value,
                        onChanged: (value) {
                          controllers.selectedProspectSortBy.value = "";
                          Navigator.pop(context);
                        },
                        activeColor: colorsConst.third,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          controllers.selectedProspectSortBy.value = "";
                          Navigator.pop(context);
                        },
                        child: const CustomText(
                            text: "Clear", colors: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
        backgroundColor: colorsConst.primary,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            utils.sideBarFunction(context),
            Obx(() => Container(
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
                  Expanded(
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
                                  color: colorsConst.secondary,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20))
                                 ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Obx(
                                          () => CustomCheckBox(
                                          text: "",
                                          onChanged: (value) {
                                            if (controllers.isAllSelected.value ==
                                                true) {
                                              controllers.isAllSelected.value = false;
                                              for (int j = 0;
                                              j < controllers.isNewLeadList.length;
                                              j++) {
                                                controllers.isNewLeadList[j]
                                                ["isSelect"] = false;
                                                setState(() {
                                                  var i = apiService.prospectsList
                                                      .indexWhere((element) =>
                                                  element["lead_id"] == controllers.isNewLeadList[j]["lead_id"]);
                                                  apiService.prospectsList.removeAt(i);
                                                });
                                              }
                                            } else {
                                              controllers.isAllSelected.value = true;
                                              setState(() {
                                                for (int j = 0; j < controllers.isNewLeadList.length; j++) {
                                                  controllers.isNewLeadList[j]["isSelect"] = true;
                                                  apiService.prospectsList.add(
                                                      {
                                                        "lead_id": controllers.isNewLeadList[j]["lead_id"],
                                                        "user_id": controllers.storage.read("id"),
                                                        "rating": controllers.isNewLeadList[j]["rating"],
                                                        "cos_id": cosId,
                                                      });
                                                  print(apiService.prospectsList);
                                                }
                                              });
                                            }
                                            //controllers.isMainPerson.value=!controllers.isMainPerson.value;
                                          },
                                          saveValue: controllers.isAllSelected.value),
                                    ),
                                  ),
                                  headerCell(width: 150, text: "Name"),
                                  headerCell(width: 180, text: "Company Name"),
                                  headerCell(width: 80, text: "Mobile No."),
                                  headerCell(width: 250, text: "Details of Service Required"),
                                  headerCell(width: 200, text: "Source Of Prospect"),
                                  headerCell(width: 200, text: "Added DateTime"),
                                  headerCell(width: 150, text: "City"),
                                  headerCell(width: 200, text: "Status Update"),
                                ],
                              ),
                            ),
                            10.height,
                            // Table Body
                            SizedBox(
                              height: MediaQuery.of(context).size.height - 400,
                              width: controllers.isLeftOpen.value == false &&
                                  controllers.isRightOpen.value == false
                                  ? MediaQuery.of(context).size.width - 200
                                  : MediaQuery.of(context).size.width - 445,
                              child: Scrollbar(
                                controller: _verticalController,
                                thumbVisibility: true,
                                thickness: 10,
                                radius: const Radius.circular(10),
                                child: ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return 5.height;
                                  },
                                  controller: _verticalController,
                                  itemCount: controllers.paginatedLeads.length,
                                  itemBuilder: (context, index) {
                                    final data = controllers.paginatedLeads[index];
                                    return GestureDetector(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                              color: colorsConst.secondary,
                                             ),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 40,
                                              alignment: Alignment.center,
                                              child: Obx(() =>  CustomCheckBox(
                                                  text: "",
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
                                                          "rating":data.rating.toString(),
                                                          "cos_id":cosId,
                                                        });
                                                      }
                                                    });
                                                  },
                                                  saveValue: controllers.isNewLeadList[index]["isSelect"]),
                                              ),
                                            ),
                                            dataCell(width: 150, text: data.firstname ?? ""),
                                            dataCell(width: 180, text: data.companyName ?? ""),
                                            dataCell(width: 80, text: data.mobileNumber ?? ""),
                                            dataCell(width: 250, text: data.detailsOfServiceRequired ?? ""),
                                            dataCell(width: 200, text: data.source ?? ""),
                                            dataCell(width: 200, text: controllers.formatDateTime(data.updatedTs.toString())),
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
                          controllers.currentPage.value--;
                        }),
                        ...buildPagination(totalPages, currentPage),
                        paginationButton(Icons.chevron_right, currentPage < totalPages, () {
                          controllers.currentPage.value++;
                        }),
                      ],
                    );
                  }),

                ],
              ),
            )),
            utils.funnelContainer(context)
          ],
        ),
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
        icon: Icon(icon, color: colorsConst.textColor),
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }

  Widget buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => CustomText(
              text: "New Leads - ${controllers.leadCategoryList[0]["value"]}",
              colors: colorsConst.textColor,
              size: 25,
              isBold: true,
            )),
            10.height,
            Obx(() => CustomText(
              text: "View all of your ${controllers.leadCategoryList[0]["value"]} Information",
              colors: colorsConst.textColor,
              size: 14,
            )),
          ],
        ),
        Row(
          children: [
            CustomLoadingButton(
              callback: () async {
                SharedPreferences sharedPref = await SharedPreferences.getInstance();
                setState(() {
                  // Load all shared preferences into controllers
                  final leadPersonalCount = sharedPref.getInt("leadCount") ?? 1;
                  controllers.leadPersonalItems.value = leadPersonalCount;
                  controllers.isMainPersonList.value = [];
                  controllers.isCoMobileNumberList.value = [];
                  for (int i = 0; i < leadPersonalCount; i++) {
                    controllers.isMainPersonList.add(false);
                    controllers.isCoMobileNumberList.add(false);
                  }
                  // Load other fields...
                  controllers.leadCoNameCrt.text = sharedPref.getString("leadCoName") ?? "";
                  controllers.leadCoMobileCrt.text = sharedPref.getString("leadCoMobile") ?? "";
                  // ...continue loading other fields as needed
                });
                Get.to(const AddLead(), duration: Duration.zero);
              },
              isLoading: false,
              height: 35,
              backgroundColor: colorsConst.third,
              radius: 2,
              width: 100,
              isImage: false,
              text: "Add Lead",
              textColor: Colors.black,
            ),
            15.width,
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
                "All ${controllers.leadCategoryList.isEmpty ? "" : controllers.leadCategoryList[0]["value"]} ${controllers.allNewLeadsLength.value}"
              ],
            )),
            Row(
              children: [
                DeleteButton(
                  leadList: apiService.prospectsList,
                  callback: () {
                    apiService.deleteCustomersAPI(context, apiService.prospectsList);
                  },
                ),
                5.width,
                Obx(() => PromoteButton(
                  headText: controllers.leadCategoryList[1]["value"],
                  leadList: apiService.prospectsList,
                  callback: () {
                    apiService.insertProspectsAPI(context, apiService.prospectsList);
                  },
                  text: "Promote",
                )),
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



  Widget headerCell({required double width, required String text}) {
    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      child: CustomText(
        text: text,
        size: 15,
        isBold: true,
        colors: colorsConst.textColor,
      ),
    );
  }

  Widget dataCell({required double width, required String text}) {
    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      child: CustomText(
        text: text,
        size: 14,
        colors: colorsConst.textColor,
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
        onTap: () => controllers.currentPage.value = pageNum,
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


