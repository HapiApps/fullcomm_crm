import 'dart:convert';
import 'dart:io';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Stack;
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../billing_utils/sized_box.dart';
import '../../common/constant/api.dart' as assets;
import '../../common/constant/colors_constant.dart';
import '../../common/styles/decoration.dart';
import '../../common/utilities/utils.dart';
import '../../components/Customtext.dart';
import '../../components/custom_appbar.dart';
import '../../components/custom_no_data.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/emp_drop.dart';
import '../../components/month_calender.dart';
import '../../controller/controller.dart';
import '../../controller/new_payroll_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../models/payroll/unit_model.dart';
import '../../services/new_payroll_api_services.dart';
import 'dart:typed_data';

class PFWages extends StatefulWidget {
  const PFWages({super.key});

  @override
  State<PFWages> createState() => _PFWagesState();
}

class _PFWagesState extends State<PFWages> {
  var newPyrlServ = NewPayrollApiServices.instance;
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  List<double> colWidths = [
    80,   // no
    200,  // rank
    250,  // Name
    100,  // uan no
    150,  // duty
    140,  // salary wages
    120,  // pf wages
    140,  // pay amount
    150,  // dob
    150,  // doj
    100,  // age
    130,  // f name
    150,  // no
  ];
  @override
  void initState() {
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      newPyrlServ.getPfWages();
    });
    super.initState();
  }
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      const double horizontalScrollAmount = 60.0;
      const double verticalScrollAmount = 50.0; // Adjust for row height

      // --- HORIZONTAL SCROLLING ---
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _horizontalController.animateTo(
          (_horizontalController.offset + horizontalScrollAmount).clamp(0.0, _horizontalController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _horizontalController.animateTo(
          (_horizontalController.offset - horizontalScrollAmount).clamp(0.0, _horizontalController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }

      // --- VERTICAL SCROLLING (Add this part) ---
      else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _controller.animateTo(
          (_controller.offset + verticalScrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _controller.animateTo(
          (_controller.offset - verticalScrollAmount).clamp(0.0, _controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  Widget headerCell(int index, Widget child) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          alignment: index==0?Alignment.center:Alignment.centerLeft,
          child: child,
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 10,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                colWidths[index] += details.delta.dx;
                if (colWidths[index] < 60) colWidths[index] = 60;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    var mobileSize = MediaQuery
        .of(context)
        .size
        .width * 0.95;
    var webSize = MediaQuery
        .of(context)
        .size
        .width * 0.97;
    double screenWidth = MediaQuery.of(context).size.width;
    final Map<int, TableColumnWidth> tableWidthMap = {
      for (int i = 0; i < colWidths.length; i++) i: FixedColumnWidth(colWidths[i])
    };

    double totalTableWidth = colWidths.reduce((a, b) => a + b);
    return SelectionArea(
      child: Scaffold(
          backgroundColor: colorsConst.backgroundColor,
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SideBar(),
              Obx(()=>Container(
                width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 160:MediaQuery.of(context).size.width - 60,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(text:"PF Wages"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomSearchTextField(
                          controller: controllers.search,
                          hintText: "Search Employee Name",
                          onChanged: (value) {
                            controllers.searchText.value = value.toString().trim();
                            pyrlCtr.filterAndSort(
                              searchText: controllers.searchText.value.toLowerCase(),
                              sortField: controllers.sortFieldCallActivity.value,
                              sortOrder: controllers.sortOrderCallActivity.value,
                            );
                          },
                        ),
                        Row(
                          children: [
                            SizedBox(
                                height: 35,
                                child: Obx(()=>ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:colorsConst.secondary,
                                      shadowColor: Colors.transparent,
                                    ),
                                    onPressed: (){
                                      showMonthPicker2(
                                          context: context,
                                          month: pyrlCtr.month,
                                          function: (){
                                            newPyrlServ.getPfWages();
                                          }
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        CustomText(
                                          text:pyrlCtr.month.value,isCopy: false,colors: Colors.black,
                                        ),
                                        5.width,
                                        const Icon(Icons.calendar_today,
                                            color: Colors.black, size: 17),
                                        10.width,
                                      ],
                                    )
                                ),)
                            ),10.width,
                            CustomLoadingButton(
                                callback: (){
                                  pfWagesPayrollExport();
                                }, isLoading: false, text: "Download",isImage: false,height: 35,
                                backgroundColor: colorsConst.primary, radius: 5, width: 100)
                          ],
                        ),
                      ],
                    ),
                    10.height,
                    pyrlCtr.getData.value == false ?
                    const Padding(
                      padding: EdgeInsets.all(25.0),
                      child: CircularProgressIndicator(),
                    ):
                    pyrlCtr.unitPayrollList.isEmpty ?
                    Center(
                      child: SizedBox(
                          height: 500,width: 500,
                          child: const CustomNoData()),
                    ):
                    Expanded(
                      child: KeyboardListener(
                        focusNode: _focusNode,
                        autofocus: true,
                        onKeyEvent: _handleKeyEvent,
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              _focusNode.requestFocus();
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: totalTableWidth,
                                child: Column(
                                  children: [
                                    // HEADER
                                    Table(
                                      columnWidths: tableWidthMap,
                                      border: TableBorder(
                                        horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                        verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                      ),
                                      children: [
                                        TableRow(
                                            decoration: BoxDecoration(
                                                color: colorsConst.primary,
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(5),
                                                    topRight: Radius.circular(5))),
                                            children: [
                                              headerCell(1, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "S.No",//1
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: false,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='id' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='id';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(
                                                2,  Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Rank",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='rank' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='rank';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(
                                                3,  Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Name",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='name' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='name';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(4, Row(
                                                children: [
                                                  CustomText(//2
                                                    textAlign: TextAlign.left,
                                                    text: "UAN No",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='uan' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='uan';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(5, Row(
                                                children: [
                                                  CustomText(//2
                                                    textAlign: TextAlign.left,
                                                    text: "Working Days",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='duty' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='duty';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(6, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Salary Wages",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='earn' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='earn';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(7, Row(
                                                children: [
                                                  CustomText(//4
                                                    textAlign: TextAlign.left,
                                                    text: "PF Wages",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='pfwages' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='pfwages';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(8, Row(
                                                children: [
                                                  CustomText(//4
                                                    textAlign: TextAlign.left,
                                                    text: "Pay Amount",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='esi' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='esi';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(9, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "Date Of Birth",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='dob' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='dob';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(10, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Date Of Joining",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='doj' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='doj';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(10, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Age",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='age' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='age';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(10, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Father Name",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='father' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='father';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                              headerCell(10, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Phone Number",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='no' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='no';
                                                      pyrlCtr.filterAndSort(
                                                        searchText: controllers.searchText.value.toLowerCase(),
                                                        sortField: controllers.sortFieldCallActivity.value,
                                                        sortOrder: controllers.sortOrderCallActivity.value,
                                                      );
                                                    },
                                                    child: Obx(() => Image.asset(
                                                      controllers.sortFieldCallActivity.value.isEmpty
                                                          ? "assets/images/arrow.png"
                                                          : controllers.sortOrderCallActivity.value == 'asc'
                                                          ? "assets/images/arrow_up.png"
                                                          : "assets/images/arrow_down.png",
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    ),
                                                  ),
                                                ],
                                              ),),
                                            ]),
                                      ],
                                    ),
                                    // BODY LIST
                                    Expanded(
                                      child: Obx(() {
                                        if (pyrlCtr.unitPayrollList.isEmpty) {
                                          return const Center(child: Text("No data found"));
                                        }
                                        return ListView.builder(
                                          controller: _controller,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: pyrlCtr.unitPayrollList.length,
                                          itemBuilder: (context, index) {
                                            var data = pyrlCtr.unitPayrollList[index];
                                            return Table(
                                              columnWidths: {
                                                for (int i = 0; i < colWidths.length; i++)
                                                  i: FixedColumnWidth(colWidths[i]),
                                              },
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              ),
                                              children:[
                                                TableRow(
                                                    decoration: BoxDecoration(
                                                      color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                    ),
                                                    children:[
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:(index+1).toString(),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.roleName,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Tooltip(
                                                        message: data.name,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: CustomText(
                                                            textAlign: TextAlign.left,
                                                            text: data.name,
                                                            size: 14,
                                                            isCopy: true,
                                                            colors:colorsConst.textColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.pfNo,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.duty,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.total,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.pfWagesAmt,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.pf,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.dob.toString()=="null"?"":utils.formatDob(data.dob.toString()),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.doj.toString()=="null"?"":utils.formatDob(data.doj.toString()),
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.dob,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.fn,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.phoneNo,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                    ]
                                                ),

                                              ],
                                            );
                                          },
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          )
      ),
    );
  }

  Widget customWid(String? value, {double width = 8, bool bold = false}) {
    // value null or empty na show panna empty
    if (value == null || value.trim().isEmpty) {
      return const SizedBox(); // or return Text('') if needed
    }

    // number format
    String formattedValue = value;

    // Try to parse value as number
    final number = num.tryParse(value.replaceAll(',', ''));

    if (number != null) {
      formattedValue = NumberFormat('#,##0').format(number);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomText(
        text: formattedValue,
        isBold: bold, isCopy: true,
      ),
    );
  }
  
  Future<void> pfWagesPayrollExport() async {
    String clean(String? value) {
      if (value == null || value.toLowerCase() == "null") {
        return "";
      }
      return value;
    }

    String getSafe(List<String> list, int idx) {
      return idx < list.length ? clean(list[idx]) : '';
    }

    final Workbook workbook = Workbook();
    final Worksheet worksheet = workbook.worksheets[0];

    // Header format
    worksheet.getRangeByName('A1:N1').merge();
    worksheet
        .getRangeByName('A1:N1')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet.getRangeByName('A2:H2').merge();
    worksheet.getRangeByName('I2:N2').merge();
    worksheet
        .getRangeByName('A2:N2')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet
        .getRangeByName('A2:N2')
        .cellStyle
        .hAlign = HAlignType.center;

    worksheet
        .getRangeByName('A1')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A2')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A3:N3')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A3')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A3:N3')
        .cellStyle
        .backColor = '#CA1617';
    worksheet
        .getRangeByName('A3:N3')
        .cellStyle
        .fontColor = '#ffffff';

    // Report Title
    worksheet.getRangeByName("A1").setText("PF Wages Sheet");
    worksheet
        .getRangeByName("A2:H2")
        .rowHeight = 60; // height adjust pannalam


    worksheet.getRangeByName("A2").setText(
        "${controllers.comName.text}\n Address : ${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
            " ${controllers.comCountry.text}, ${controllers.comPincode.text}");
    worksheet.getRangeByName("I2").setText(
        "Month : ${pyrlCtr.month.value}");

    // Headers`
    List<String> headers = [
      "S.No",
      "Rank",
      "Name",
      "UAN No",
      "Working Days",
      "Salary wages",
      "PF Wages",
      "Pay Amount",
      "Date Of Birth",
      "Date Of Joining",
      "Age",
      "Father Name",
      "Phone Number",
    ];
    for (int j = 0; j < headers.length; j++) {
      worksheet.getRangeByIndex(3, j + 1).setText(headers[j]);
    }


    // Fill data
    for (int i = 0; i < pyrlCtr.unitPayrollList.length; i++) {
      worksheet.getRangeByIndex(i + 4, 1).setText("${i + 1}"); // S.No
      worksheet.getRangeByIndex(i + 4, 2).setText(pyrlCtr.unitPayrollList[i].roleName); // ID No
      worksheet.getRangeByIndex(i + 4, 3).setText(pyrlCtr.unitPayrollList[i].name); // ID No
      worksheet.getRangeByIndex(i + 4, 4).setText(pyrlCtr.unitPayrollList[i].pfNo); // ID No
      worksheet.getRangeByIndex(i + 4, 5).setText(pyrlCtr.unitPayrollList[i].duty); // ID No
      worksheet.getRangeByIndex(i + 4, 6).setText(pyrlCtr.unitPayrollList[i].total); // ID No
      // worksheet.getRangeByIndex(i + 4, 7).setText("${((int.parse(pyrlCtr.unitPayrollList[i].pfWages.toString()) /
      //     int.parse(payrollCtr.lastDate.toString())) *
      //     int.parse(pyrlCtr.unitPayrollList[i].duty.toString())).round()}"); // ID No
      worksheet.getRangeByIndex(i + 4, 7).setText(pyrlCtr.unitPayrollList[i].pfWagesAmt); // ID No
      worksheet.getRangeByIndex(i + 4, 8).setText(pyrlCtr.unitPayrollList[i].pf); // ID No
      worksheet.getRangeByIndex(i + 4, 9).setText(pyrlCtr.unitPayrollList[i].dob.toString()=="null"?"":utils.formatDob(pyrlCtr.unitPayrollList[i].dob.toString())); // ID No
      worksheet.getRangeByIndex(i + 4, 10).setText(pyrlCtr.unitPayrollList[i].doj.toString()=="null"?"":utils.formatDob(pyrlCtr.unitPayrollList[i].doj.toString())); // ID No
      worksheet.getRangeByIndex(i + 4, 11).setText(calculateAge(pyrlCtr.unitPayrollList[i].dob.toString())); // ID No
      worksheet.getRangeByIndex(i + 4, 12).setText(pyrlCtr.unitPayrollList[i].fn); // ID No
      worksheet.getRangeByIndex(i + 4, 13).setText(pyrlCtr.unitPayrollList[i].phoneNo); // ID No
    }

    // Save
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', '${pyrlCtr.month.value} PF Wages Sheet.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/${pyrlCtr.month.value} PF Wages Sheet.xlsx';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }

  String calculateAge(String dob) {
    if (dob.isEmpty) return '';

    try {
      DateTime birthDate;

      // Try parsing as yyyy-MM-dd first
      if (dob.contains('-')) {
        List<String> parts = dob.split('-');

        if (parts[0].length == 4) {
          // Format: yyyy-MM-dd
          int year = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int day = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        } else {
          // Format: dd-MM-yyyy
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        }
      } else if (dob.contains('/')) {
        // Handle yyyy/MM/dd or dd/MM/yyyy
        List<String> parts = dob.split('/');
        if (parts[0].length == 4) {
          int year = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int day = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        } else {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          birthDate = DateTime(year, month, day);
        }
      } else {
        return '';
      }

      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age.toString();
    } catch (e) {
      return '';
    }
  }
}
