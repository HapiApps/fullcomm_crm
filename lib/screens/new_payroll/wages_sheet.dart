import 'dart:convert';
import 'dart:io';
import 'package:fullcomm_crm/components/custom_no_data.dart';
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
import '../../components/custom_loading_button.dart';
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

class UnitSlip extends StatefulWidget {
  const UnitSlip({super.key});

  @override
  State<UnitSlip> createState() => _UnitSlipState();
}

class _UnitSlipState extends State<UnitSlip> {
  var newPyrlServ = NewPayrollApiServices.instance;
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  List<double> colWidths = [
    80,   // no
    150,  // rank
    200,  // Name
    100,  // duty
    100,  // ot
    100,  // basic
    100,  // da
    100,  // hra
    130,  // earn
    130,  // ad
    100,  // uni
    100,  // pena
    100,  // bonus
    150,  // fc
    70,  // esi
    70,  // pf
    130,  // ded
    130,  // net
  ];
  @override
  void initState() {
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      pyrlCtr.users.clear();
      pyrlCtr.unitPayrollList.clear();
      newPyrlServ.getUnitPayroll();
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
                    CustomAppbar(text:"Wages Sheet"),
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
                                            newPyrlServ.getUnitPayroll();
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
                            ),
                            20.width,
                            CustomLoadingButton(
                              callback: (){
                                unitPayrollExport(0);
                              },
                              isLoading: false,
                              height: 35,
                              backgroundColor: Colors.white,
                              radius: 2,
                              width: 100,
                              isImage: false,
                              text: "Excel",
                              textColor: colorsConst.primary,
                            ),
                            20.width,
                            CustomLoadingButton(
                              callback: (){
                                unitPayrollPreviewPdf(0);
                              },
                              isLoading: false,
                              height: 35,
                              backgroundColor: Colors.white,
                              radius: 2,
                              width: 100,
                              isImage: false,
                              text: "PDF",
                              textColor: colorsConst.primary,
                            ),
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
                                                    text: "Duty",
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
                                              headerCell(5, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.left,
                                                    text: "OT",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='ot' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='ot';
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
                                                    text: "Basic",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='basic' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='basic';
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
                                                    text: "DA",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='da' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='da';
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
                                                    text: "HRA",
                                                    size: 15,
                                                    isBold: true,
                                                    isCopy: true,
                                                    colors: Colors.white,
                                                  ),
                                                  3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='hra' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='hra';
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
                                                    text: "Earning",
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
                                              headerCell(10, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Advance",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='advance' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='advance';
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
                                              headerCell(11, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Uniform",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='uniform' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='uniform';
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
                                              headerCell(11, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Penalty",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='penalty' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='addedBy';
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
                                              headerCell(12, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Bonus",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='bonus' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='bonus';
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
                                              headerCell(13, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Food Charges",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='fc' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='fc';
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
                                              headerCell(14, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "ESI",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
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
                                              headerCell(15, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "PF",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='pf' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='pf';
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
                                              headerCell(16, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Deduction",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='ded' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='ded';
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
                                              headerCell(16, Row(
                                                children: [
                                                  CustomText(
                                                    textAlign: TextAlign.center,
                                                    text: "Net Amount",
                                                    isCopy: true,
                                                    size: 15,
                                                    isBold: true,
                                                    colors: Colors.white,
                                                  ),3.width,
                                                  GestureDetector(
                                                    onTap: (){
                                                      if(controllers.sortFieldCallActivity.value=='net' && controllers.sortOrderCallActivity.value=='asc'){
                                                        controllers.sortOrderCallActivity.value='desc';
                                                      }else{
                                                        controllers.sortOrderCallActivity.value='asc';
                                                      }
                                                      controllers.sortFieldCallActivity.value='net';
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
                                          return const Center(
                                            child: SizedBox(
                                                height: 500,width: 800,
                                                child: const CustomNoData()),
                                          );
                                        }
                                        return ListView.builder(
                                          controller: _controller,
                                          shrinkWrap: true,
                                          physics: const ScrollPhysics(),
                                          itemCount: pyrlCtr.unitPayrollList.length,
                                          itemBuilder: (context, index) {
                                            var namesList = pyrlCtr.unitPayrollList[0].name.toString().split(',');
                                            var roleList = pyrlCtr.unitPayrollList[0].roleName.toString().split(',');
                                            var dutyList = pyrlCtr.unitPayrollList[0].duty.toString().split(',');
                                            var otList = pyrlCtr.unitPayrollList[0].ot.toString().split(',');
                                            var basicList = pyrlCtr.unitPayrollList[0].basic.toString().split(',');
                                            var hraList = pyrlCtr.unitPayrollList[0].hra.toString().split(',');
                                            var daList = pyrlCtr.unitPayrollList[0].da.toString().split(',');
                                            var netAmtList = pyrlCtr.unitPayrollList[0].netAmount.toString().split(',');
                                            var advanceList = pyrlCtr.unitPayrollList[0].advance.toString().split(',');
                                            var uniformList = pyrlCtr.unitPayrollList[0].uniform.toString().split(',');
                                            var penaltyList = pyrlCtr.unitPayrollList[0].penalty.toString().split(',');
                                            var esiList = pyrlCtr.unitPayrollList[0].esi.toString().split(',');
                                            var pfList = pyrlCtr.unitPayrollList[0].pf.toString().split(',');
                                            var deductionList = pyrlCtr.unitPayrollList[0].deduction.toString().split(',');
                                            var totalList = pyrlCtr.unitPayrollList[0].total.toString().split(',');
                                            var bonus2List = pyrlCtr.unitPayrollList[0].bonus2.toString().split(',');
                                            var foodList = pyrlCtr.unitPayrollList[0].food.toString().split(',');
                                            print("namesList   : ${namesList.length}");
                                            print("roleList    : ${roleList.length}");
                                            print("dutyList    : ${dutyList.length}");
                                            print("otList      : ${otList.length}");
                                            print("basicList   : ${basicList.length}");
                                            print("hraList     : ${hraList.length}");
                                            print("daList      : ${daList.length}");
                                            print("netAmtList  : ${netAmtList.length}");
                                            print("advanceList : ${advanceList.length}");
                                            print("uniformList : ${uniformList.length}");
                                            print("penaltyList : ${penaltyList.length}");
                                            print("esiList     : ${esiList.length}");
                                            print("pfList      : ${pfList.length}");
                                            print("deductionList : ${deductionList.length}");
                                            print("totalList   : ${totalList.length}");
                                            return  Table(
                                              columnWidths: {
                                                for (int i = 0; i < colWidths.length; i++)
                                                  i: FixedColumnWidth(colWidths[i]),
                                              },
                                              border: TableBorder(
                                                horizontalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                verticalInside:BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                bottom:  BorderSide(width: 0.5, color: Colors.grey.shade400),
                                              ),
                                              children: List.generate(namesList.length, (index) {
                                                return TableRow(
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
                                                          text:roleList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: namesList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors:colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:dutyList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:otList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:basicList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:daList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:hraList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:totalList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:advanceList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:uniformList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:penaltyList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:bonus2List[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:foodList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:esiList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:pfList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:deductionList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:netAmtList[index],
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                    ]
                                                );
                                              }),
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

  pw.TableRow _row(String title, String value, pw.Font baseFont) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(title, style: pw.TextStyle(font: baseFont)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: pw.TextStyle(font: baseFont)),
        ),
      ],
    );
  }

  Future<void> unitPayrollExport(int index) async {
    String clean(String? value, {bool? isName=false}) {
      if (value == null || value.trim().isEmpty || value.toLowerCase() == "null") {
        return "";
      }
      // Try converting to number & format it
      final number = num.tryParse(value);
      print("number $number");
      if (number != null&&isName==false) {
        return NumberFormat('#,##0').format(number);

        // 👉 If you want INDIAN format:
        // return NumberFormat.decimalPattern('en_IN').format(number);
      }

      return value;
    }
    String getSafe(List<String> list, int idx,{bool? isName=false}) {
      return idx < list.length ? clean(list[idx],isName: isName) : "";
    }
    String getSafe2(String? value,{bool? isName=false}) {
      return clean(value,isName: isName);
    }


    final Workbook workbook = Workbook();
    final Worksheet worksheet = workbook.worksheets[0];

    // Header format
    worksheet.getRangeByName('A1:V1').merge();
    worksheet
        .getRangeByName('A1:V1')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet.getRangeByName('A2:V2').merge();
    worksheet.getRangeByName('A3:K3').merge();
    worksheet.getRangeByName('L3:V3').merge();
    worksheet
        .getRangeByName('A2:V2')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet
        .getRangeByName('A3:V3')
        .cellStyle
        .hAlign = HAlignType.center;
    worksheet
        .getRangeByName('A4:V4')
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
        .getRangeByName('A3:V3')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A4')
        .cellStyle
        .bold = true;
    worksheet
        .getRangeByName('A4:V4')
        .cellStyle
        .backColor = '#CA1617';
    worksheet
        .getRangeByName('A4:V4')
        .cellStyle
        .fontColor = '#ffffff';

    // Report Title
    worksheet.getRangeByName("A1").setText("Register Of Wages");
    worksheet.getRangeByName("A2").setText("Form No XVII");
    worksheet
        .getRangeByName("A3:V3")
        .rowHeight = 60; // height adjust pannalam


    worksheet.getRangeByName("A3").setText(
        "${controllers.comName.text}\n Address : ${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
            " ${controllers.comCountry.text}, ${controllers.comPincode.text}");
    worksheet.getRangeByName("L3").setText(
        "Month : ${pyrlCtr.month.value}");
    List<String> headers = [
        "S.No",
        "Rank",
        "Name",
        "Site Salary",
        "Duty",
        "OT",
        "Basic",
        "DA",
        "HRA",
        "Earning",
        "ESI",
        "PF",
        "Advance",
        "Penalty",
        "Uniform",
        "Bonus",
        "Food charges",
        "Deduction",
        "Net salary",
        "A/C Name",
        "A/C No",
        "IFSC Code"
      ];
    // Headers`
    for (int j = 0; j < headers.length; j++) {
      worksheet.getRangeByIndex(4, j + 1).setText(headers[j]);
    }
    // Data lists (comma separated)
    var namesList = pyrlCtr.unitPayrollList[index].name.toString().split(',');
    var empcdList = pyrlCtr.unitPayrollList[index].empcd.toString().split(',');
    var roleList = pyrlCtr.unitPayrollList[index].roleName.toString().split(
        ',');
    var dutyList = pyrlCtr.unitPayrollList[index].duty.toString().split(',');
    var otList = pyrlCtr.unitPayrollList[index].ot.toString().split(',');
    var netAmtList = pyrlCtr.unitPayrollList[index].netAmount.toString().split(
        ',');
    var advanceList = pyrlCtr.unitPayrollList[index].advance.toString().split(
        ',');
    var uniformList = pyrlCtr.unitPayrollList[index].uniform.toString().split(
        ',');
    var penaltyList = pyrlCtr.unitPayrollList[index].penalty.toString().split(
        ',');
    var deductionList = pyrlCtr.unitPayrollList[index].deduction
        .toString()
        .split(',');
    var totalList = pyrlCtr.unitPayrollList[index].total.toString().split(',');
    var basicList = pyrlCtr.unitPayrollList[index].basic.toString().split(',');
    var hraList = pyrlCtr.unitPayrollList[index].hra.toString().split(',');
    var daList = pyrlCtr.unitPayrollList[index].da.toString().split(',');
    var esiList = pyrlCtr.unitPayrollList[index].esi.toString().split(',');
    var pfList = pyrlCtr.unitPayrollList[index].pf.toString().split(',');
    var acList = pyrlCtr.unitPayrollList[index].aC.toString().split(',');
    var accNoList = pyrlCtr.unitPayrollList[index].accNo.toString().split(',');
    var opList = pyrlCtr.unitPayrollList[index].op.toString().split(',');
    var bonusList = pyrlCtr.unitPayrollList[index].bonus.toString().split(',');
    var bonus2List = pyrlCtr.unitPayrollList[index].bonus2.toString().split(',');
    var foodList = pyrlCtr.unitPayrollList[index].food.toString().split(',');
    var ifscList = pyrlCtr.unitPayrollList[index].ifscCode.toString().split(
        ',');
    var bkNameList = pyrlCtr.unitPayrollList[index].bankName.toString().split(
        ',');
    var salaryList = pyrlCtr.unitPayrollList[index].salary.toString().split(
        ',');
    int rowCountEx = [
      namesList.length,
      roleList.length,
      dutyList.length,
      otList.length,
      netAmtList.length,
      advanceList.length,
      uniformList.length,
      penaltyList.length,
      deductionList.length,
      totalList.length,
      basicList.length,
      daList.length,
      hraList.length,
      totalList.length,
      totalList.length,//
      totalList.length,//
      esiList.length,
      pfList.length,
      accNoList.length,
      ifscList.length,
      bkNameList.length
    ].reduce((a, b) => a > b ? a : b);
        for (int i = 0; i < rowCountEx; i++) {
          worksheet.getRangeByIndex(i + 5, 1).setText("${i + 1}");
          worksheet.getRangeByIndex(i + 5, 2).setText(getSafe(roleList, i));
          worksheet.getRangeByIndex(i + 5, 3).setText(getSafe(namesList, i));
          worksheet.getRangeByIndex(i + 5, 4).setText(getSafe(salaryList, i));
          worksheet.getRangeByIndex(i + 5, 5).setText(getSafe(dutyList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 6).setText(getSafe(otList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 7).setText(getSafe(basicList, i));
          worksheet.getRangeByIndex(i + 5, 8).setText(getSafe(daList, i));
          worksheet.getRangeByIndex(i + 5, 9).setText(getSafe(hraList, i));
          worksheet.getRangeByIndex(i + 5, 10).setText(getSafe(totalList, i));
          worksheet.getRangeByIndex(i + 5, 11).setText(getSafe(esiList, i));
          worksheet.getRangeByIndex(i + 5, 12).setText(getSafe(pfList, i));
          worksheet.getRangeByIndex(i + 5, 13).setText(getSafe(advanceList, i));
          worksheet.getRangeByIndex(i + 5, 14).setText(getSafe(penaltyList, i));
          worksheet.getRangeByIndex(i + 5, 15).setText(getSafe(uniformList, i));
          worksheet.getRangeByIndex(i + 5, 16).setText(getSafe(bonus2List, i));
          worksheet.getRangeByIndex(i + 5, 17).setText(getSafe(foodList, i));
          worksheet.getRangeByIndex(i + 5, 18).setText(getSafe(deductionList, i));
          worksheet.getRangeByIndex(i + 5, 19).setText(getSafe(netAmtList, i));
          worksheet.getRangeByIndex(i + 5, 20).setText(getSafe(bkNameList, i));
          worksheet.getRangeByIndex(i + 5, 21).setText(getSafe(accNoList, i,isName: true));
          worksheet.getRangeByIndex(i + 5, 22).setText(getSafe(ifscList, i));
        }

    // Save
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', 'Register Of Wages - ${pyrlCtr.month.value}.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/Register Of Wages - ${pyrlCtr.month.value}.xlsx';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }

  Future<void> unitPayrollPreviewPdf(int index) async {
    final pdf = pw.Document();
    final imageByteData = await rootBundle.load(assets.logo);
    final imageList = imageByteData.buffer
        .asUint8List(imageByteData.offsetInBytes, imageByteData.lengthInBytes);
    final image = pw.MemoryImage(imageList);
    String clean(String? value, {bool? isName=false}) {
      if (value == null || value.trim().isEmpty || value.toLowerCase() == "null") {
        return "";
      }

      // Try converting to number & format it
      final number = num.tryParse(value);
      if (number != null&&isName==false) {
        return NumberFormat('#,##0').format(number);

        // 👉 If you want INDIAN format:
        // return NumberFormat.decimalPattern('en_IN').format(number);
      }

      return value;
    }
    String getSafe(List<String> list, int idx,{bool? isName=false}) {
      return idx < list.length ? clean(list[idx],isName: isName) : "";
    }
    String getSafe2(String? value,{bool? isName=false}) {
      return clean(value,isName: isName);
    }
    // Data lists
    var namesList = pyrlCtr.unitPayrollList[index].name.toString().split(',');
    var empcdList = pyrlCtr.unitPayrollList[index].empcd.toString().split(',');
    var roleList = pyrlCtr.unitPayrollList[index].roleName.toString().split(',');
    var dutyList = pyrlCtr.unitPayrollList[index].duty.toString().split(',');
    var otList = pyrlCtr.unitPayrollList[index].ot.toString().split(',');
    var netAmtList = pyrlCtr.unitPayrollList[index].netAmount.toString().split(',');
    var advanceList = pyrlCtr.unitPayrollList[index].advance.toString().split(',');
    var uniformList = pyrlCtr.unitPayrollList[index].uniform.toString().split(',');
    var penaltyList = pyrlCtr.unitPayrollList[index].penalty.toString().split(',');
    var deductionList = pyrlCtr.unitPayrollList[index].deduction.toString().split(',');
    var totalList = pyrlCtr.unitPayrollList[index].total.toString().split(',');
    var basicList = pyrlCtr.unitPayrollList[index].basic.toString().split(',');
    var hraList = pyrlCtr.unitPayrollList[index].hra.toString().split(',');
    var daList = pyrlCtr.unitPayrollList[index].da.toString().split(',');
    var esiList = pyrlCtr.unitPayrollList[index].esi.toString().split(',');
    var pfList = pyrlCtr.unitPayrollList[index].pf.toString().split(',');
    var accNoList = pyrlCtr.unitPayrollList[index].accNo.toString().split(',');
    var ifscList = pyrlCtr.unitPayrollList[index].ifscCode.toString().split(',');
    var bkNameList = pyrlCtr.unitPayrollList[index].bankName.toString().split(','); // ✅ Fix A/C Name
    var acList = pyrlCtr.unitPayrollList[index].aC.toString().split(','); // ✅ Fix A/C Name
    var opList = pyrlCtr.unitPayrollList[index].op.toString().split(','); // ✅ Fix A/C Name
    var bonusList = pyrlCtr.unitPayrollList[index].bonus.toString().split(','); // ✅ Fix A/C Name
    var bonus2List = pyrlCtr.unitPayrollList[index].bonus2.toString().split(','); // ✅ Fix A/C Name
    var foodList = pyrlCtr.unitPayrollList[index].food.toString().split(','); // ✅ Fix A/C Name
    var salaryList = pyrlCtr.unitPayrollList[index].salary.toString().split(
        ',');
    int rowCount = [
      namesList.length,
      roleList.length,
      dutyList.length,
      otList.length,
      netAmtList.length,
      advanceList.length,
      uniformList.length,
      penaltyList.length,
      deductionList.length,
      totalList.length,
      basicList.length,
      hraList.length,
      daList.length,
      esiList.length,
      pfList.length,
      accNoList.length,
      accNoList.length,//
      accNoList.length,//
      ifscList.length,
      bkNameList.length
    ].reduce((a, b) => a > b ? a : b);
    // ✅ Totals calculation for all numeric fields
    double totalDuty = 0.0;
    double totalOt = 0.0;
    int totalEarning = 0;
    int totalAdvance = 0;
    int totalPenalty = 0;
    int totalUniform = 0;
    int totalDeduction = 0;
    int totalNetAmt = 0;

    int totalBasic = 0;
    int totalHra = 0;
    int totalDa = 0;
    int totalEsi = 0;
    int totalPf = 0;
    int totalOp = 0;
    int totalAd = 0;
    int totalB = 0;
    int totalB2 = 0;
    int totalFood = 0;

    totalDuty = dutyList.fold(0.0, (sum, v) => sum + (double.tryParse(v) ?? 0.0));
    totalOt = otList.fold(0.0, (sum, v) => sum + (double.tryParse(v) ?? 0.0));
    totalEarning = totalList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalAdvance = advanceList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalPenalty = penaltyList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalUniform = uniformList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalDeduction = deductionList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalNetAmt = netAmtList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));

    totalBasic = basicList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalHra = hraList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalDa = daList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));

    totalAd = basicList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalB = hraList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalOp = daList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalEsi = esiList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalPf = pfList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalPf = pfList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalB2 = bonus2List.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    totalFood = foodList.fold(0, (sum, v) => sum + (int.tryParse(clean(v)) ?? 0));
    // Build PDF content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(16),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                "Register Of Wages",
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                "Form No XVII",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Image(
                  image,
                  width: 100,
                  height: 100,
                ),
                pw.Row(
                    children: [
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(controllers.comName.text,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                "Address: ${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
                                    " ${controllers.comCountry.text}, ${controllers.comPincode.text}"),
                          ]
                      ),
                      pw.SizedBox(width: 20),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Month")
                          ]
                      ),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(" : ${pyrlCtr.month.value}")
                          ]
                      ),
                    ]
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Table.fromTextArray(
              headers: [
                "S.No",
                "Name",
                "Rank",
                "Salary",
                "Duty",
                "OT",
                "Basic",
                "DA",
                "HRA",
                "Earning",
                "Advance",
                "Penalty",
                "Uniform",
                "Bonus",
                "Food Chg",
                "ESI",
                "PF",
                "Deduction",
                "Net salary",
                "A/C Name",  // ✅ Fixed
                "A/C No",
                "IFSC Code"
              ],
              data: List<List<String>>.generate(
                rowCount,
                    (i) => [
                  (i+1).toString(),
                  getSafe(namesList, i),
                  getSafe(roleList, i),
                  getSafe(salaryList, i),
                  getSafe(dutyList, i,isName: true),
                  getSafe(otList, i,isName: true),
                  getSafe(basicList, i),
                  getSafe(daList, i),
                  getSafe(hraList, i),
                  getSafe(totalList, i),
                  getSafe(advanceList, i),
                  getSafe(penaltyList, i),
                  getSafe(uniformList, i),
                  getSafe(bonus2List, i),
                  getSafe(foodList, i),
                  getSafe(esiList, i),
                  getSafe(pfList, i),
                  getSafe(deductionList, i),
                  getSafe(netAmtList, i),
                  getSafe(bkNameList, i), // ✅ A/C Name working
                  getSafe(accNoList, i,isName: true),
                  getSafe(ifscList, i),
                ],
              )..add([ // ✅ Total row update
                "",
                "",
                "Total",
                "",
                "$totalDuty",
                "$totalOt",
                "$totalBasic",
                "$totalDa",
                "$totalHra",
                "$totalEarning",
                "$totalAdvance",
                "$totalPenalty",
                "$totalUniform",
                "$totalB2",
                "$totalFood",
                "$totalEsi",
                "$totalPf",
                "$totalDeduction",
                "$totalNetAmt",
                "",
                "",
                ""
              ]),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9),
              cellStyle: pw.TextStyle(fontSize: 8),
              headerDecoration: pw.BoxDecoration(color: PdfColors.red),
              cellAlignment: pw.Alignment.center,
              cellPadding: const pw.EdgeInsets.all(2),
              border: pw.TableBorder.all(width: 0.5),
               columnWidths: {
                0: const pw.FixedColumnWidth(35),   // S.No
                1: const pw.FixedColumnWidth(57),   // Name
                2: const pw.FixedColumnWidth(35),   // Rank
                3: const pw.FixedColumnWidth(45),   // Salary
                4: const pw.FixedColumnWidth(32),   // Duty
                5: const pw.FixedColumnWidth(25),   // OT
                6: const pw.FixedColumnWidth(40),   // Basic
                7: const pw.FixedColumnWidth(35),   // DA
                8: const pw.FixedColumnWidth(40),   // HRA
                9: const pw.FixedColumnWidth(50),  // Total
                10: const pw.FixedColumnWidth(54),  // Advance
                11: const pw.FixedColumnWidth(50),  // Penalty
                12: const pw.FixedColumnWidth(50),  // Uniform
                13: const pw.FixedColumnWidth(40),  // ESI
                14: const pw.FixedColumnWidth(35),  // PF
                15: const pw.FixedColumnWidth(25),  // Deduction
                16: const pw.FixedColumnWidth(25),  // Net Salary
                17: const pw.FixedColumnWidth(53),  // A/C Name
                18: const pw.FixedColumnWidth(50),  // A/C No
                19: const pw.FixedColumnWidth(50),  // IFSC Code
                20: const pw.FixedColumnWidth(50),  // IFSC Code
                21: const pw.FixedColumnWidth(50),  // IFSC Code
              },
            ),
          ];
        },
      ),
    );

    // // Show PDF preview
    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );
    // Save PDF bytes
    Uint8List bytes = await pdf.save();
    if (kIsWeb) {
      AnchorElement(
        href: 'data:application/octet-stream;charset=utf-161e;base64,${base64
            .encode(bytes)}',
      )
        ..setAttribute('download', 'Register Of Wages - ${pyrlCtr.month.value}.pdf')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String filename = '$path/"Register Of Wages - ${pyrlCtr.month.value}.pdf';
      final File file = File(filename);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(filename, linuxByProcess: true);
    }
  }

}
