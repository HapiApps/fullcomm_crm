import 'dart:convert';
import 'dart:io';
import 'package:fullcomm_crm/components/custom_loading_button.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
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
import '../../components/keyboard_search.dart';
import '../../components/month_calender.dart';
import '../../controller/controller.dart';
import '../../controller/new_payroll_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../models/employee_details.dart';
import '../../models/payroll/monthly_unit_payroll.dart';
import '../../models/payroll/unit_model.dart';
import '../../provider/employee_provider.dart';
import '../../services/new_payroll_api_services.dart';
import 'dart:typed_data';

class PaySlip extends StatefulWidget {
  const PaySlip({super.key});

  @override
  State<PaySlip> createState() => _PaySlipState();
}

class _PaySlipState extends State<PaySlip> {
  var newPyrlServ = NewPayrollApiServices.instance;
  String empId="";
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  List<double> colWidths = [
    80,   // no
    200,  // rank
    250,  // Name
    150,  // duty
    140,  // ot
    120,  // basic
    140,  // da
    150,  // hra
    150,  // earn
    100,  // ad
    130,  // uni
    150,  // pena
    150,  // pena
    150,  // pena
    150,  // esi
    150,  // pf
    150,  // ded
    150,  // net
  ];
  @override
  void initState() {
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
    return Consumer<EmployeeProvider>(builder: (context, employeeProvider, _) {
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
                    CustomAppbar(text:"Pay Slip"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EmpDropdown(
                          custList: employeeProvider.filteredStaff,
                          onChanged: (Staff? selectedEmployee) {
                            setState(() {
                              // Save selected employee details
                              controllers.storage.write("p_emp_id", selectedEmployee!.id);
                              controllers.storage.write("p_emp_name", selectedEmployee.sName);
                              empId=selectedEmployee.id.toString();
                              newPyrlServ.getPaySlip(empId);
                            });
                          },),
                        CustomLoadingButton(
                            callback: (){
                              generatePayrollPdf(pyrlCtr.unitPayrollList);
                            }, isLoading: false, text: "PDF",isImage: false,height: 35,
                            backgroundColor: colorsConst.primary, radius: 5, width: 100),
                      ],
                    ),
                    10.height,
                    pyrlCtr.getData.value == false ?
                    const Padding(
                      padding: EdgeInsets.all(25.0),
                      child: CircularProgressIndicator(),
                    ):
                    empId=="" ?
                    Center(
                      child: SizedBox(
                          height: 500,width: 500,
                          child: const CustomNoData()),
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
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: data.name,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors:colorsConst.textColor,
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
                                                          text:data.ot,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.basic,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.da,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.hra,
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
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.advance,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.uniform,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.penalty,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.bonus2,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.food,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.esi,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.pf,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.deduction,
                                                          size: 14,
                                                          isCopy: true,
                                                          colors: colorsConst.textColor,
                                                        ),
                                                      ),Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: CustomText(
                                                          textAlign: TextAlign.left,
                                                          text:data.netAmount,
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
    });
  }
  static pw.TableRow _tableRow(String key1, String val1, String key2, String val2) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(key1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(val1, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(key2, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(val2, style: const pw.TextStyle(fontSize: 9)),
        ),
      ],
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
  static Future<void> generatePayrollPdf(RxList<UnitPayroll> unitPayrollList) async {
    final pdf = pw.Document();

    // Load logo
    final imageByteData = await rootBundle.load(assets.logo);
    final imageList = imageByteData.buffer.asUint8List(
        imageByteData.offsetInBytes, imageByteData.lengthInBytes);
    final image = pw.MemoryImage(imageList);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Image(image, width: 80, height: 80),
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(controllers.comName.text,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 14),
                    ),
                    pw.Text(
                      "Address: ${controllers.comDoor.text}, ${controllers.comStreet.text}\n${controllers.comCity.text}, ${controllers.comState.text},"
                          " ${controllers.comCountry.text}, ${controllers.comPincode.text}",
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Center(
                child: pw.Text(
                  "Pay Slip",
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                )
            ),
            pw.SizedBox(height: 5),
            pw.Center(
                child: pw.Text(
                  pyrlCtr.month.value,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                )
            ),
            pw.SizedBox(height: 5),

            // Loop through each payroll
            ...unitPayrollList.map((e) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromInt(0xffcccccc)),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Employee Info
                    pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(2),
                        2: const pw.FlexColumnWidth(2),
                        3: const pw.FlexColumnWidth(2),
                      },
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffcccccc)),
                      children: [
                        _tableRow("Name", e.name ?? "", "Rank", e.roleName ?? ""),
                        _tableRow("Father Name", e.fn ?? "", "Site Name", e.unitName ?? ""),
                        _tableRow("ID No", e.empcd ?? "", "Phone", e.phoneNo ?? ""),
                        _tableRow("D.O.B", e.dob ?? "", "D.O.J", e.doj ?? ""),
                        _tableRow("PF No", e.pfNo ?? "", "ESI No", e.esiNo ?? ""),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // Salary Table
                    pw.Table(
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2),
                        1: const pw.FlexColumnWidth(2),
                        2: const pw.FlexColumnWidth(2),
                        3: const pw.FlexColumnWidth(2),
                      },
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffcccccc)),
                      children: [
                        _tableRow("Duty", e.duty ?? "","ESI", e.esi ?? ""),
                        _tableRow("Basic", e.basic ?? "","PF", e.pf ?? "",),
                        _tableRow("DA", e.da ?? "","PT", e.pt ?? "",),
                        _tableRow("HRA", e.hra ??"","Uniform", e.uniform ?? ""),
                        _tableRow("NFH", e.nH ??"","Advance", e.advance ?? ""),
                        _tableRow("SFH", e.sH ??"","Penalty", e.penalty ?? ""),
                        _tableRow("Others", e.oH ??"","Deduction", e.deduction ?? ""),
                        _tableRow("Total", e.total ??"","",""),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Net Amount : '),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                color: PdfColors.black, // choose your color
                                width: 1,               // thickness of border
                              ),
                              borderRadius: pw.BorderRadius.circular(4), // optional rounded corners
                            ),
                            child: pw.Text(
                              e.netAmount ?? '',
                              style: pw.TextStyle( fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ]
                    ),
                    // Bank details
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Words in rupees',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text('Bank Name',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text('A/C No',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text('IFSC Code',style: pw.TextStyle(fontSize: 9)),
                              ]
                          ),pw.SizedBox(width: 10),
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(' : ',style: pw.TextStyle(fontSize: 9)),
                              ]
                          ),
                          pw.SizedBox(width: 10),
                          pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('${NumberToWordsEnglish.convert(int.parse(e.netAmount.toString())).toString().capitalize}',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(e.bankName ?? '',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(e.accNo ?? '',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                                pw.SizedBox(height: 5),
                                pw.Text(e.ifscCode ?? '',style: pw.TextStyle( fontWeight: pw.FontWeight.bold,fontSize: 9)),
                              ]
                          ),
                        ]
                    ),
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    // Mobile vs Web handling
    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${unitPayrollList[0].name} ${pyrlCtr.month.value} Pay Slip.pdf',
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${unitPayrollList[0].name} ${pyrlCtr.month.value} Pay Slip.pdf');
      await file.writeAsBytes(await pdf.save());
    }
  }
}
