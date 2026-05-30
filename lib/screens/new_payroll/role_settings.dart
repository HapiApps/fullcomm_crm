import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/new_payroll_controller.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/models/role_obj.dart';
import 'package:fullcomm_crm/screens/settings/terms_conditions.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
import '../../components/action_button.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/custom_textfield.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/dashboard_controller.dart';
import '../../controller/product_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../provider/employee_provider.dart';
import '../../services/api_services.dart';
import '../../services/new_payroll_api_services.dart';

class RoleSetting extends StatefulWidget {
  const RoleSetting({super.key});

  @override
  State<RoleSetting> createState() => _RoleSettingState();
}

class _RoleSettingState extends State<RoleSetting> {
  final FocusNode f1 = FocusNode();
  final FocusNode f2 = FocusNode();
  final FocusNode f3 = FocusNode();
  final FocusNode f4 = FocusNode();
  final FocusNode f5 = FocusNode();
  final FocusNode f6 = FocusNode();
  final FocusNode f7 = FocusNode();
  final FocusNode f8 = FocusNode();
  final FocusNode f10 = FocusNode();
  final FocusNode f11 = FocusNode();
  final FocusNode f12 = FocusNode();
  final FocusNode f13 = FocusNode();
  final FocusNode f14 = FocusNode();
  final FocusNode f15 = FocusNode();
  final FocusNode f16 = FocusNode();
  final FocusNode f17 = FocusNode();
  final FocusNode f18 = FocusNode();
  final FocusNode f19 = FocusNode();
  bool isRole=true;
  bool isDep=false;
  late FocusNode _focusNode;
  final ScrollController _controller = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  var services=NewPayrollApiServices.instance;
  List<double> colWidths = [
    80,   // 0 Checkbox
    100,  // 1 Actions
    130,  // 2 type
    150,  // 2 role
    90,  // 2 sal
    80,  // 2 ba
    70,  // 3 da
    80,  // 4 hra
    70,  // 5 pf
    70,  // 6 esi
    90,  // 7 bonus
    80,  // 8 lwf
    70,  // 8 nh
    70,  // 8 sh
    70,  // 8 oh
    70,  // 8 pt
    120,  // 8 pf w
    120,  // 8 esi w
    120,  // 8 dedu
    120,  // 8 total A
    100,  // 8 net pay
  ];
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    Future.delayed(Duration.zero, () {
      _focusNode.requestFocus();
      controllers.storage.write("com_id","1");
      FocusScope.of(context).requestFocus(f1);
      pyrlCtr.isAdd.value=false;
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      if(settingsController.roleList.isEmpty){
        settingsController.allRoles();
      }
      if(employeeData.depList.isEmpty){
        employeeData.fetchDepList();
      }
    });
  }
  @override
  void dispose() {
    f1.dispose();
    f2.dispose();
    f3.dispose();
    f4.dispose();
    f5.dispose();
    f6.dispose();
    f7.dispose();
    f8.dispose();
    f10.dispose();
    f11.dispose();
    f12.dispose();
    f13.dispose();
    f14.dispose();
    f15.dispose();
    f16.dispose();
    f17.dispose();
    f18.dispose();
    f19.dispose();
    _controller.dispose();
    _horizontalController.dispose();
    _focusNode.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final Map<int, TableColumnWidth> tableWidthMap = {
      for (int i = 0; i < colWidths.length; i++) i: FixedColumnWidth(colWidths[i])
    };
    double totalTableWidth = colWidths.reduce((a, b) => a + b);
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<EmployeeProvider>(builder: (context, employeeProvider, _) {
      return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(),
          Obx(()=> Container(
            width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.height,
                Row(
                  children: [
                    // IconButton(
                    //     onPressed: (){
                    //       Get.back();
                    //     },
                    //     icon: Icon(Icons.arrow_back)),
                    CustomText(
                      text: "Payroll Settings",
                      colors: colorsConst.textColor,
                      size: 20,
                      isBold: true,
                      isCopy: true,
                    ),
                  ],
                ),
                10.height,
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                20.height,
                if(pyrlCtr.isAdd.value==false)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if(pyrlCtr.selectedSettingIds.isNotEmpty)
                    ActionButton(
                      width: 100,
                      image: "assets/images/action_delete.png",
                      name: "Delete",
                      toolTip: "Click here to delete the customer details",
                      callback: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: CustomText(
                                text: "Are you sure delete this Call records?",
                                size: 16,
                                isBold: true,
                                isCopy: true,
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
                                            isCopy: false,
                                          )),
                                    ),
                                    10.width,
                                    CustomLoadingButton(
                                      callback: (){
                                        for(var i=0;i<pyrlCtr.selectedSettingIds.length;i++){
                                          for(var j=0;j<pyrlCtr.settingList.length;j++){
                                            if(pyrlCtr.selectedSettingIds[i]==pyrlCtr.settingList[j].id){
                                              pyrlCtr.settingList[j].active="0";
                                            }
                                          }
                                        }
                                        services.deleteSetting(context);
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
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),20.width,
                    CustomLoadingButton(
                        callback: (){
                          pyrlCtr.isAdd.value=true;
                          pyrlCtr.addSetting();
                        }, isLoading: false, text: pyrlCtr.isAdd.value==false?"Add Role":"View",isImage: false,height: 40,
                        backgroundColor: colorsConst.primary, radius: 5, width: 100),
                  ],
                ),10.height,
                if(pyrlCtr.isAdd.value==false)
                pyrlCtr.getUnits.value==false?
                CircularProgressIndicator():
                pyrlCtr.settingList.isEmpty?
                Center(child: CustomText(text: "No settings found", isCopy: false)):
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
                                          headerCell(0, Obx(() => Checkbox(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(2.0),
                                            ),
                                            side: WidgetStateBorderSide.resolveWith(
                                                  (states) => const BorderSide(width: 1.0, color: Colors.white),
                                            ),
                                            value: pyrlCtr.selectedSettingIds.length == pyrlCtr.settingList.length && pyrlCtr.settingList.isNotEmpty,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  pyrlCtr.selectAllCalls();
                                                } else {
                                                  pyrlCtr.unselectAllCalls();
                                                }
                                              });
                                            },
                                            activeColor: Colors.white,
                                            checkColor: colorsConst.primary,
                                          ))),
                                          headerCell(1, CustomText(
                                            textAlign: TextAlign.left,
                                            text: "Actions",//1
                                            size: 15,
                                            isBold: true,
                                            isCopy: false,
                                            colors: Colors.white,
                                          ),),
                                          headerCell(
                                            2,  Row(
                                            children: [
                                              CustomText(
                                                textAlign: TextAlign.left,
                                                text: "Type",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),
                                              3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='type' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='type';
                                                  pyrlCtr.sorting(
                                                    sortField: controllers.sortFieldCallActivity.value,
                                                    sortOrder: controllers.sortOrderCallActivity.value);
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
                                                text: "Setting Name",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),
                                              3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='role' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='role';
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
                                          headerCell(3, Row(
                                            children: [
                                              CustomText(//2
                                                textAlign: TextAlign.left,
                                                text: "Salary",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),
                                              3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='salary' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='salary';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                text: "PF",
                                                size: 15,
                                                isBold: true,
                                                isCopy: true,
                                                colors: Colors.white,
                                              ),
                                              3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='pf' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='pf';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                              CustomText(
                                                textAlign: TextAlign.left,
                                                text: "ESI",
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
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "LWF",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='lwf' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='lwf';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "NH",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='nh' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='nh';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "SH",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='sh' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='sh';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "OH",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='oh' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='oh';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "PT",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='pt' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='pt';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "PF Wages",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='pfwages' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='pfwages';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "ESI Wages",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='esiwages' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='esiwages';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "Deduction",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='dedu' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='dedu';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "Total Amt",
                                                isCopy: true,
                                                size: 15,
                                                isBold: true,
                                                colors: Colors.white,
                                              ),3.width,
                                              GestureDetector(
                                                onTap: (){
                                                  if(controllers.sortFieldCallActivity.value=='total' && controllers.sortOrderCallActivity.value=='asc'){
                                                    controllers.sortOrderCallActivity.value='desc';
                                                  }else{
                                                    controllers.sortOrderCallActivity.value='asc';
                                                  }
                                                  controllers.sortFieldCallActivity.value='total';
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                                textAlign: TextAlign.center,
                                                text: "Net Pay",
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
                                                  pyrlCtr.sorting(
                                                      sortField: controllers.sortFieldCallActivity.value,
                                                      sortOrder: controllers.sortOrderCallActivity.value);
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
                                    if (pyrlCtr.settingList.isEmpty) {
                                      return const Center(child: Text("No Settings found"));
                                    }
                                    return ListView.builder(
                                      controller: _controller,
                                      shrinkWrap: true,
                                      physics: const ScrollPhysics(),
                                      itemCount: pyrlCtr.settingList.length,
                                      itemBuilder: (context, index) {
                                        final data = pyrlCtr.settingList[index];
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
                                            if(pyrlCtr.settingList[index].active=="1")
                                            TableRow(
                                                decoration: BoxDecoration(
                                                  color: int.parse(index.toString()) % 2 == 0 ? Colors.white : colorsConst.backgroundColor,
                                                ),
                                                children:[
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Checkbox(
                                                      value: pyrlCtr.isCheckedRecordCall(data.id.toString()),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          pyrlCtr.toggleRecordSelectionCall(data.id.toString());
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        IconButton(
                                                            onPressed: (){
                                                              pyrlCtr.isAdd.value=true;
                                                              pyrlCtr.editIndex.value=index;
                                                            },
                                                            icon: SvgPicture.asset(
                                                              "assets/images/a_edit.svg",
                                                              width: 16,
                                                              height: 16,
                                                            )),
                                                        IconButton(
                                                            onPressed: (){
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    content: CustomText(
                                                                      text: "Are you sure delete this Call records?",
                                                                      size: 16,
                                                                      isBold: true,
                                                                      isCopy: true,
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
                                                                                isCopy: false,
                                                                              )),
                                                                        ),
                                                                        10.width,
                                                                        CustomLoadingButton(
                                                                          callback: (){
                                                                            pyrlCtr.selectedSettingIds.add(data.id.toString());
                                                                            for(var i=0;i<pyrlCtr.selectedSettingIds.length;i++){
                                                                              for(var j=0;j<pyrlCtr.settingList.length;j++){
                                                                                if(pyrlCtr.selectedSettingIds[i]==pyrlCtr.settingList[j].id){
                                                                                  pyrlCtr.settingList[j].active="0";
                                                                                }
                                                                              }
                                                                            }
                                                                            services.deleteSetting(context);
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
                                                                      ],
                                                                    ),
                                                                  ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            icon: SvgPicture.asset(
                                                              "assets/images/a_delete.svg",
                                                              width: 16,
                                                              height: 16,
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Column(
                                                      children: [
                                                        CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: pyrlCtr.settingList[index].monthlyWages==true?"Monthly Wages":"Daily Wages",
                                                          size: 14,
                                                          isCopy: true,
                                                          colors:colorsConst.textColor,
                                                        ),
                                                        CustomText(
                                                          textAlign: TextAlign.left,
                                                          text: pyrlCtr.settingList[index].roleName.toString()==""?"Department":"Role",
                                                          size: 14,isBold: true,
                                                          isCopy: true,
                                                          colors:colorsConst.primary,
                                                        ),
                                                      ],
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.left,
                                                      text: pyrlCtr.settingList[index].roleName.toString()==""?pyrlCtr.settingList[index].dName.toString():pyrlCtr.settingList[index].roleName.toString(),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].salary.text.isEmpty?pyrlCtr.settingList[index].perDay.text:pyrlCtr.settingList[index].salary.text.isEmpty),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].basic.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].da.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].hra.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].pf.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].esi.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].bonus.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.left,
                                                      text: pyrlCtr.settingList[index].tds.text,
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.left,
                                                      text: pyrlCtr.settingList[index].nH.text,
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.left,
                                                      text: pyrlCtr.settingList[index].sH.text,
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.left,
                                                      text: pyrlCtr.settingList[index].oH.text,
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].pt.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].pfWages.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].esiWages.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].deduction.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].totalAmt.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
                                                    ),
                                                  ),Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: CustomText(
                                                      textAlign: TextAlign.right,
                                                      text: productCtr.formatAmount(pyrlCtr.settingList[index].netPay.text),
                                                      size: 14,
                                                      isCopy: true,
                                                      colors:colorsConst.textColor,
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
                // ListView.builder(
                //     itemCount: pyrlCtr.settingList.length,
                //     shrinkWrap: true,
                //     physics: const NeverScrollableScrollPhysics(),
                //     itemBuilder: (context,index){
                //       return Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Row(
                //             children: [
                //               CustomText(text: pyrlCtr.settingList[index].monthlyWages==true?"Monthly Wages":"Daily Wages",isBold: true,colors: colorsConst.primary, isCopy: false,),
                //               20.width,
                //               CustomText(text: clearText(pyrlCtr.settingList[index].roleName.toString()),colors: colorsConst.primary, isCopy: false,),
                //               10.width,
                //               CustomText(text: productCtr.formatAmount(pyrlCtr.settingList[index].netPay.text),isBold: true,isCopy: false,),
                //             ],
                //           ),
                //           Row(
                //             children: [
                //               AppCustomDataText(title: 'Salary', value: productCtr.formatAmount(pyrlCtr.settingList[index].salary.text),),
                //               AppCustomDataText(title: 'Basic', value: productCtr.formatAmount(pyrlCtr.settingList[index].basic.text)),
                //               AppCustomDataText(title: 'DA', value: productCtr.formatAmount(pyrlCtr.settingList[index].da.text)),
                //               AppCustomDataText(title: 'HRA', value: productCtr.formatAmount(pyrlCtr.settingList[index].hra.text)),
                //             ],
                //           ),
                //           Row(
                //             children: [
                //               AppCustomDataText(title: 'PF', value: productCtr.formatAmount(pyrlCtr.settingList[index].pf.text)),
                //               AppCustomDataText(title: 'ESI', value: productCtr.formatAmount(pyrlCtr.settingList[index].esi.text)),
                //               AppCustomDataText(title: 'Bonus', value: productCtr.formatAmount(pyrlCtr.settingList[index].bonus.text)),
                //               AppCustomDataText(title: 'LWF', value: productCtr.formatAmount(pyrlCtr.settingList[index].tds.text)),
                //             ],
                //           ),
                //           Row(
                //             children: [
                //               AppCustomDataText(title: 'National Holidays', value: pyrlCtr.settingList[index].nH.text,),
                //               AppCustomDataText(title: 'State Holidays', value: pyrlCtr.settingList[index].sH.text,),
                //               AppCustomDataText(title: 'Others Holidays', value: pyrlCtr.settingList[index].oH.text,),
                //               AppCustomDataText(title: 'PT', value: productCtr.formatAmount(pyrlCtr.settingList[index].pt.text)),
                //             ],
                //           ),
                //           Row(
                //             children: [
                //               AppCustomDataText(title: 'PF Wages', value: productCtr.formatAmount(pyrlCtr.settingList[index].pfWages.text)),
                //               AppCustomDataText(title: 'ESI Wages', value: productCtr.formatAmount(pyrlCtr.settingList[index].esiWages.text)),
                //               AppCustomDataText(title: 'Deduction', value: productCtr.formatAmount(pyrlCtr.settingList[index].deduction.text)),
                //               AppCustomDataText(title: 'Total Amount', value: productCtr.formatAmount(pyrlCtr.settingList[index].totalAmt.text)),
                //             ],
                //           ),
                //           Divider(thickness: 0.5,color: colorsConst.third,),
                //         ],
                //       );
                //     }),
                if(pyrlCtr.isAdd.value==true)
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomLoadingButton(
                                  callback: (){
                                    pyrlCtr.isAdd.value=false;
                                    pyrlCtr.settingList.removeAt(pyrlCtr.editIndex.value);
                                  }, isLoading: false, text: "Cancel",isImage: false,textColor: colorsConst.primary,
                                  backgroundColor: Colors.white, radius: 5, width: 100,height: 35,),10.width,
                              // CustomLoadingButton(
                              //     callback: (){
                              //       bool hasInvalid = false;
                              //
                              //       for (var data in pyrlCtr.settingList) {
                              //         // Check if role or salary missing
                              //         if (data.roleName ==""  ||(data.salary.text.trim().isEmpty&& data.perDay.text.trim().isEmpty)) {
                              //           hasInvalid = true;
                              //           break;
                              //         }
                              //       }
                              //
                              //       if (hasInvalid) {
                              //         utils.snackBar(context: context, msg: "Please fill Role and Salary", color: Colors.red);
                              //       } else {
                              //         pyrlCtr.addSetting();
                              //       }
                              //     }, isLoading: false, text: "Add Role",isImage: false,textColor: colorsConst.primary,
                              //     backgroundColor: Colors.white, radius: 5, width: 100,height: 35,),10.width,
                              CustomLoadingButton(
                                  callback: (){
                                    bool hasInvalid = false;

                                    for (var data in pyrlCtr.settingList) {
                                      // Check if role or salary missing
                                      debugPrint("data.role");
                                      debugPrint(data.role.toString());
                                      debugPrint(data.salary.text.trim());
                                      if (data.roleName == "" && data.dName == "" || (data.salary.text.trim().isEmpty&& data.perDay.text.trim().isEmpty)) {
                                        hasInvalid = true;
                                        break;
                                      }

                                    }
                                    if (hasInvalid) {
                                      utils.snackBar(context: context, msg: "Please fill Role and Salary", color: Colors.red);
                                      pyrlCtr.submit.reset();
                                    } else {
                                      services.addRoleSetting(context);
                                    }
                                  }, isLoading: true, text: "Save",controller: pyrlCtr.submit,
                                  backgroundColor: colorsConst.primary, radius: 5, width: 100,height: 40)
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                final data = pyrlCtr.settingList[pyrlCtr.editIndex.value];

                                void calculateAmounts() {
                                  setState(() {
                                    double perDay = double.tryParse(data.monthlyWages==true?data.salary.text:data.perDay.text) ?? 0.0;
                                    double basic = double.tryParse(data.basic.text) ?? 0.0;
                                    double hra = double.tryParse(data.hra.text) ?? 0.0;
                                    double da = double.tryParse(data.da.text) ?? 0.0;
                                    double bonus = double.tryParse(data.bonus.text) ?? 0.0;
                                    double nh = double.tryParse(data.nH.text) ?? 0.0;
                                    double sh = double.tryParse(data.sH.text) ?? 0.0;
                                    double others = double.tryParse(data.oH.text) ?? 0.0;
                                    double oSalary = double.tryParse(data.optionSalary.text) ?? 0.0;

                                    double total = perDay+basic + hra + da + bonus + nh + sh + others + oSalary;
                                    data.totalAmt.text = total.toStringAsFixed(2);

                                    double esi = double.tryParse(data.esi.text) ?? 0.0;
                                    double pf = double.tryParse(data.pf.text) ?? 0.0;
                                    double tds = double.tryParse(data.tds.text) ?? 0.0;
                                    double pt = double.tryParse(data.pt.text) ?? 0.0;
                                    double adCharge = double.tryParse(data.adminCharges.text) ?? 0.0;

                                    double deductions = esi + pf + tds + pt+adCharge;
                                    data.deduction.text = deductions.toStringAsFixed(2);

                                    double netPay = total - deductions;
                                    data.netPay.text = netPay.toStringAsFixed(2);
                                  });
                                }

                                void calculatePFandESI() {
                                  setState(() {
                                    double pfWages = double.tryParse(data.pfWages.text) ?? 0.0;
                                    double esiWages = double.tryParse(data.esiWages.text) ?? 0.0;

                                    if(data.monthlyWages==true){
                                      double pf = (pfWages * 0.12).roundToDouble(); // 12% rounded
                                      double esi = (esiWages * 0.0075).roundToDouble(); // 0.75% rounded

                                      data.pf.text = pf.toStringAsFixed(0);
                                      data.esi.text = esi.toStringAsFixed(0);
                                    }else{
                                      double pf = pfWages * 0.12; // 12% rounded
                                      double esi = esiWages * 0.0075; // 0.75% rounded

                                      data.pf.text = pf.toString();
                                      data.esi.text = esi.toString();
                                    }
                                    calculateAmounts();
                                  });
                                }

                                return Column(
                                  children: [
                                    Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const CustomText(text:"Monthly Wages",colors:Colors.grey,isCopy: false,),
                                            SizedBox(
                                              width: 20,
                                              child: Checkbox(
                                                  activeColor:colorsConst.primary,
                                                  value: data.monthlyWages,
                                                  onChanged: (value){
                                                    setState((){
                                                      data.monthlyWages=value!;
                                                      calculateAmounts();
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),20.width,
                                        if(data.monthlyWages==true)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const CustomText(text:"Week Off",colors:Colors.grey,isCopy: false),
                                                SizedBox(
                                                  width: 20,
                                                  child: Checkbox(
                                                      activeColor:colorsConst.primary,
                                                      value: data.weekOff,
                                                      onChanged: (value){
                                                        setState((){
                                                          data.weekOff=value!;
                                                          if(data.weekOff==true){
                                                            data.sunday=true;
                                                            data.saturday=false;
                                                          }else{
                                                            data.sunday=false;
                                                            data.saturday=false;
                                                          }
                                                        });
                                                      }),
                                                ),
                                              ],
                                            ),
                                            if(data.weekOff==true)
                                              Row(
                                                children: [
                                                  const CustomText(text:"Sunday",colors:Colors.grey,isCopy: false),
                                                  SizedBox(
                                                    width: 20,
                                                    child: Checkbox(
                                                        activeColor:colorsConst.primary,
                                                        value: data.sunday,
                                                        onChanged: (value){
                                                          setState((){
                                                            data.sunday=value!;
                                                          });
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            if(data.weekOff==true)
                                              Row(
                                                children: [
                                                  const CustomText(text:"Saturday",colors:Colors.grey,isCopy: false),
                                                  SizedBox(
                                                    width: 20,
                                                    child: Checkbox(
                                                        activeColor:colorsConst.primary,
                                                        value: data.saturday,
                                                        onChanged: (value){
                                                          setState((){
                                                            data.saturday=value!;
                                                          });
                                                        }),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        20.width,
                                        Row(
                                          children: [
                                            const CustomText(text:"Role",colors:Colors.grey,isCopy: false),
                                            SizedBox(
                                              width: 20,
                                              child: Checkbox(
                                                  activeColor:colorsConst.primary,
                                                  value: isRole,
                                                  onChanged: (value){
                                                    setState((){
                                                      isRole=value!;
                                                      if(isRole==true){
                                                        isDep=false;
                                                      }
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),20.width,
                                        Row(
                                          children: [
                                            const CustomText(text:"Department",colors:Colors.grey,isCopy: false),
                                            SizedBox(
                                              width: 20,
                                              child: Checkbox(
                                                  activeColor:colorsConst.primary,
                                                  value: isDep,
                                                  onChanged: (value){
                                                    setState((){
                                                      isDep=value!;
                                                      if(isDep==true){
                                                        isRole=false;
                                                      }
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(
                                          width: screenWidth/5,
                                          text: data.monthlyWages==true?"Salary":"Per Day Salary",hintText: data.monthlyWages==true?"Salary":"Per Day Salary",
                                          controller: data.monthlyWages==true?data.salary:data.perDay,
                                          focusNode: f1,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f2);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: controllers.storage.read("com_id")=="1"?"Basic":"Optional Salary",hintText: controllers.storage.read("com_id")=="1"?"Basic":"Optional Salary",
                                          controller: controllers.storage.read("com_id")=="1"?data.basic:data.optionSalary,
                                          width: screenWidth/5,
                                          focusNode: f2,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f3);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: "Bonus",hintText: "Bonus",controller: data.bonus,
                                          width: screenWidth/5,
                                          focusNode: f3,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f4);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(text: controllers.storage.read("com_id")=="1"?"DA":"Conveyance",
                                          hintText: controllers.storage.read("com_id")=="1"?"DA":"Conveyance",controller: data.da,
                                          width: screenWidth/5,
                                          focusNode: f4,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f5);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: "ESI",hintText: "ESI",controller: data.esi,
                                          width: screenWidth/5,
                                          focusNode: f5,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f6);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculatePFandESI(),
                                        ),
                                        CustomTextField(text: controllers.storage.read("com_id")=="1"?"HRA":"Holidays",hintText: controllers.storage.read("com_id")=="1"?"HRA":"Holidays",
                                          controller: controllers.storage.read("com_id")=="1"?data.hra:data.oH,
                                          width: screenWidth/5,
                                          focusNode: f6,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f7);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(text: "PF",hintText: "PF",controller: data.pf,
                                          width: screenWidth/5,
                                          focusNode: f7,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f8);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculatePFandESI(),
                                        ),
                                        CustomTextField(text: controllers.storage.read("com_id")=="1"?"National Holidays":"Leave",hintText: controllers.storage.read("com_id")=="1"?"National Holidays":"Leave",
                                          controller: controllers.storage.read("com_id")=="1"?data.nH:data.leave,
                                          width: screenWidth/5,
                                          focusNode: f8,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f10);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: controllers.storage.read("com_id")=="1"?"LWF":"Admin Charges",hintText: controllers.storage.read("com_id")=="1"?"LWF":"Admin Charges",
                                          controller: controllers.storage.read("com_id")=="1"?data.tds:data.adminCharges,
                                          width: screenWidth/5,
                                          focusNode: f10,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f11);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(text: controllers.storage.read("com_id")=="1"?"State Holidays":"Gravity",hintText: controllers.storage.read("com_id")=="1"?"State Holidays":"Gravity",
                                          controller: controllers.storage.read("com_id")=="1"?data.sH:data.gravity,
                                          width: screenWidth/5,
                                          focusNode: f11,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f12);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: "PT",hintText: "PT",controller: data.pt,
                                          width: screenWidth/5,
                                          focusNode: f12,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f13);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: "Others",hintText: "Others",controller: data.oH,
                                          width: screenWidth/5,
                                          focusNode: f13,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f14);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(text: "Deduction",hintText: "Deduction",controller: data.deduction,
                                          width: screenWidth/5,
                                          focusNode: f14,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f15);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: "Total Amount",hintText: "Total Amount",controller: data.totalAmt,
                                          width: screenWidth/5,
                                          focusNode: f15,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f16);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                        CustomTextField(text: "Net Pay",hintText: "Net Pay",controller: data.netPay,
                                          width: screenWidth/5,
                                          focusNode: f16,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f17);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_) => calculateAmounts(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextField(text: "PF wages",hintText: "PF wages",controller: data.pfWages,
                                          width: screenWidth/5,
                                          focusNode: f17,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f18);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_)=>calculatePFandESI(),
                                        ),
                                        CustomTextField(text: "ESI wages",hintText: "ESI wages",controller: data.esiWages,
                                          width: screenWidth/5,
                                          focusNode: f18,
                                          onFieldSubmitted: (_){
                                            FocusScope.of(context).requestFocus(f19);
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.decimalInput,
                                          onChanged: (_)=>calculatePFandESI(),
                                        ),
                                        SizedBox(
                                          width: screenWidth/5,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if(isRole==true)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CustomText(
                                                          text: "Role",
                                                          size: 14,isCopy: false
                                                      ),
                                                      CustomText(
                                                          text: "*",
                                                          colors: Colors.red,
                                                          size: 15,isCopy: false
                                                      ),
                                                    ],
                                                  ),
                                                  // Container(
                                                  //   width: screenWidth/5,
                                                  //   height: 40,
                                                  //   decoration: customDecoration.baseBackgroundDecoration(
                                                  //       radius: 5,
                                                  //       color: Colors.white,borderColor: Colors.grey
                                                  //   ),
                                                  //   child: DropdownButtonFormField<Map<String, dynamic>>(
                                                  //     key: ValueKey(data.roleId), // 👈 forces dropdown to rebuild when reset
                                                  //     decoration: InputDecoration(
                                                  //       border: OutlineInputBorder(
                                                  //         borderRadius: BorderRadius.circular(10),
                                                  //       ),
                                                  //       enabledBorder: OutlineInputBorder(
                                                  //         borderRadius: BorderRadius.circular(10),
                                                  //         borderSide: const BorderSide(
                                                  //           color: Colors.white,
                                                  //           width: 1,
                                                  //         ),
                                                  //       ),
                                                  //       focusedBorder: OutlineInputBorder(
                                                  //         borderRadius: BorderRadius.circular(10),
                                                  //         borderSide: const BorderSide(
                                                  //           color: Colors.white,
                                                  //           width: 2,
                                                  //         ),
                                                  //       ),
                                                  //       contentPadding:
                                                  //       const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                  //     ),
                                                  //     isExpanded: true,
                                                  //     value: data.role,
                                                  //     hint: CustomText(
                                                  //       text: data.roleName==""?"Role":data.roleName.toString(),
                                                  //       colors: Colors.grey, isCopy: false,
                                                  //     ),
                                                  //     items: settingsController.roleList
                                                  //         .map<DropdownMenuItem<RoleModel>>>((item) {
                                                  //       return DropdownMenuItem<RoleModel>>(
                                                  //         value: item,
                                                  //         child: CustomText(
                                                  //           text: item.roleName,
                                                  //           colors: Colors.black,isCopy: false,
                                                  //         ),
                                                  //       );
                                                  //     }).toList(),
                                                  //     onChanged: (value) {
                                                  //       if (value == null) return;
                                                  //
                                                  //       final selectedRole = value;
                                                  //       final selectedRoleId = selectedRole["u_id"].toString();
                                                  //
                                                  //       bool roleExists = pyrlCtr.settingList.any((item) =>
                                                  //       item != data &&
                                                  //           item.roleId.toString() == selectedRoleId);
                                                  //
                                                  //       if (roleExists) {
                                                  //         utils.snackBar(context: context, msg: "This role is already added in another payroll setting.", color: Colors.red);
                                                  //         setState(() {
                                                  //           data.role = null;
                                                  //           data.roleId = "";
                                                  //           data.roleName = "";
                                                  //         });
                                                  //
                                                  //         return;
                                                  //       }
                                                  //
                                                  //       setState(() {
                                                  //         data.role = selectedRole;
                                                  //         data.roleId = selectedRoleId;
                                                  //         data.roleName = selectedRole["role_name"].toString();
                                                  //
                                                  //         data.dep = null;
                                                  //         data.dId = "";
                                                  //         data.dName = "";
                                                  //       });
                                                  //     },
                                                  //   ),
                                                  // ),
                                                  Container(
                                                    width: screenWidth/5,
                                                    height: 40,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                        radius: 8,
                                                        color: Colors.white,
                                                        borderColor: Colors.grey.shade400),
                                                    child: DropdownButtonHideUnderline(
                                                      child: ButtonTheme(
                                                        alignedDropdown: true,
                                                        child: DropdownButton<RoleModel>(
                                                          underline: const SizedBox(),
                                                          isExpanded: true,
                                                          value: data.role,
                                                          iconEnabledColor: Colors.black,

                                                          hint: CustomText(
                                                            text: "",
                                                            colors: Colors.grey.shade400,
                                                            size: 13,
                                                            isBold: false,
                                                            isStyle: true,
                                                            isCopy: true,
                                                          ),

                                                          items: settingsController.roleList
                                                              .map<DropdownMenuItem<RoleModel>>((item) {
                                                            return DropdownMenuItem<RoleModel>(
                                                              value: item,
                                                              child: CustomText(
                                                                text: item.roleName,
                                                                colors: Colors.black,
                                                                size: 13,
                                                                isCopy: false,
                                                                isBold: false,
                                                              ),
                                                            );
                                                          }).toList(),

                                                          onChanged: (RoleModel? value) {
                                                            // setState(() {
                                                            //   employeeProvider.role = value;
                                                            //   employeeProvider.roleId = value?.uId;
                                                            // });
                                                            if (value == null) return;
                                                            final selectedRole = value;
                                                            final selectedRoleId = selectedRole.uId.toString();

                                                            bool roleExists = pyrlCtr.settingList.any((item) =>
                                                            item != data &&
                                                                item.roleId.toString() == selectedRoleId);

                                                            if (roleExists) {
                                                              utils.snackBar(context: context, msg: "This role is already added in another payroll setting.", color: Colors.red);
                                                              setState(() {
                                                                data.role = null;
                                                                data.roleId = "";
                                                                data.roleName = "";
                                                              });

                                                              return;
                                                            }

                                                            setState(() {
                                                              data.role = selectedRole;
                                                              data.roleId = selectedRoleId;
                                                              data.roleName = selectedRole.roleName.toString();

                                                              data.dep = null;
                                                              data.dId = "";
                                                              data.dName = "";
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if(isDep==true)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CustomText(
                                                          text: "Department",
                                                          size: 14,isCopy: false
                                                      ),
                                                      CustomText(
                                                          text: "*",
                                                          colors: Colors.red,
                                                          size: 15,isCopy: false
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    width: screenWidth/5,
                                                    height: 40,
                                                    decoration: customDecoration.baseBackgroundDecoration(
                                                      radius: 5,
                                                      color: Colors.white,borderColor: Colors.grey
                                                    ),
                                                    child: DropdownButtonFormField<Map<String, dynamic>>(
                                                      key: ValueKey(data.roleId), // 👈 forces dropdown to rebuild when reset
                                                      decoration: InputDecoration(
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                          borderSide: const BorderSide(
                                                            color: Colors.white,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                          borderSide: const BorderSide(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        contentPadding:
                                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                                      ),
                                                      isExpanded: true,
                                                      value: data.dep,
                                                      hint: CustomText(
                                                        text: data.dName==""?"Department":data.dName.toString(),
                                                        colors: Colors.grey, isCopy: false,
                                                      ),
                                                      items: employeeProvider.depList
                                                          .map<DropdownMenuItem<Map<String, dynamic>>>((item) {
                                                        return DropdownMenuItem<Map<String, dynamic>>(
                                                          value: item,
                                                          child: CustomText(
                                                            text: item["department"],
                                                            colors: Colors.black,isCopy: false,
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        if (value == null) return;

                                                        final selectedRole = value;
                                                        final selectedRoleId = selectedRole["id"].toString();

                                                        bool roleExists = pyrlCtr.settingList.any((item) =>
                                                        item != data &&
                                                            item.dId.toString() == selectedRoleId);

                                                        if (roleExists) {
                                                          utils.snackBar(context: context, msg: "This department is already added in another payroll setting.", color: Colors.red);
                                                          setState(() {
                                                            data.dep = null;
                                                            data.dId = "";
                                                            data.dName = "";
                                                          });

                                                          return;
                                                        }

                                                        setState(() {
                                                          data.dep = selectedRole;
                                                          data.dId = selectedRoleId;
                                                          data.dName = selectedRole["department"].toString();

                                                          data.role = null;
                                                          data.roleId = "";
                                                          data.roleName = "";
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                100.height
              ],
            ),
          ))
        ],
      ),
    );
    });
  }
  String clearText(String value){
    if(value==""||value=="null"){
      return "-";
    }else{
      return value;
    }
  }
}


class AppCustomDataText extends StatelessWidget {
  const AppCustomDataText(
      {super.key, required this.title, required this.value,this.isLocation=false, this.lat, this.lng, this.isDSA=false, this.dsaCallback, this.height});

  final String title;
  final String value;
  final double? height;
  final double? lat;
  final double? lng;
  final bool? isLocation;
  final bool? isDSA;
  final VoidCallback? dsaCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            // color: Colors.pink,
            width: MediaQuery.of(context).size.width*0.1,
            child: CustomText(
              textAlign: TextAlign.start,
                text: title,
                colors: Colors.grey,
                size: 14,
                isBold: true, isCopy: false,),
          ),
          10.width, // TODO:: Change this width dynamically
          SizedBox(
            // color: Colors.yellow,
            // 0.3-0.43
            width: MediaQuery.of(context).size.width*0.05,
            child: CustomText(
                text: value,
              textAlign: TextAlign.end,
              size: 14,
                isBold: true, isCopy: false,),
          ),
        ],
      ),
    );
  }
}
