import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/screens/employee/update_employee.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../common/constant/colors_constant.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_search_textfield.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import '../../provider/employee_provider.dart';
import 'add_employee.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      await employeeData.fetchRoleList();
      employeeData.staffRoleDetailsData(context: context);
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isWebView = screenWidth > screenHeight;

    return  Consumer<EmployeeProvider>(
        builder: (context,employeeProvider,_) {
      return Scaffold(
        body: Row(
          children: [
            SideBar(),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: "Employees",
                                  colors: colorsConst.textColor,
                                  size: 20,
                                  isBold: true,
                                ),
                                10.height,
                                CustomText(
                                  text: "View all employees",
                                  colors: colorsConst.textColor,
                                  size: 14,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.add,color: Colors.white,),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorsConst.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddEmployeePage(
                                  )));
                                },
                                label: CustomText(
                                  text: "Add Employee",
                                  colors: Colors.white,
                                  isBold :true,
                                  size: 14,
                                ),),
                            )
                          ],
                        ),
                        10.height,
                        Row(
                          children: [
                            CustomText(
                              text: "Employees",
                              colors: colorsConst.primary,
                              isBold: true,
                              size: 15,
                            ),
                            10.width,
                            CircleAvatar(
                              backgroundColor: colorsConst.primary,
                              radius: 17,
                              child: CustomText(
                                text: employeeProvider.filteredStaff.length.toString(),
                                colors: Colors.white,
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                        5.height,
                        Divider(
                          thickness: 1.5,
                          color: colorsConst.secondary,
                        ),
                        5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomSearchTextField(
                                hintText: "Search Employee...",
                                controller: employeeProvider.vendorSearchController,
                                onChanged:  (value){}
                            ),
                            employeeProvider.hasSelectedEmployee?
                            InkWell(
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: (){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: CustomText(
                                        text: "Are you sure delete this employees?",
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
                                                employeeProvider.employeeDelete(
                                                  context: context,
                                                  eIds: employeeProvider.selectedEmployeeIds,
                                                );
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
                              child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: colorsConst.secondary,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/action_delete.png"),
                                    10.width,
                                    CustomText(
                                      text: "Delete",
                                      colors: colorsConst.textColor,
                                      size: 14,
                                      isBold: true,
                                    ),
                                  ],
                                ),
                              ),
                            ):1.width
                          ],
                        ),

                  30.height,
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),//S.No
                      1: FlexColumnWidth(3.5),//Employee Name
                      2: FlexColumnWidth(3),//Role.
                      3: FlexColumnWidth(2),//Mobile No
                      4: FlexColumnWidth(3),//Email
                      5: FlexColumnWidth(2.5),//Action
                      6: FlexColumnWidth(2.5),
                      7: FlexColumnWidth(2.5),
                      8: FlexColumnWidth(2.5),
                      //6: FlexColumnWidth(4.5),//Actions
                    },
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: CustomText(
                                    textAlign: TextAlign.left,
                                    text: "S.No",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                ),

                                // Obx(() => GestureDetector(
                                //   onTap: (){
                                //     controllers.sortField.value = 'date';
                                //     controllers.sortOrder.value = 'asc';
                                //   },
                                //   child: Icon(
                                //     Icons.arrow_upward,
                                //     size: 16,
                                //     color: (controllers.sortField.value == 'date' &&
                                //         controllers.sortOrder.value == 'asc')
                                //         ? Colors.white
                                //         : Colors.grey,
                                //   ),
                                // )),
                                // Obx(() => GestureDetector(
                                //   onTap: (){
                                //     controllers.sortField.value = 'date';
                                //     controllers.sortOrder.value = 'desc';
                                //   },
                                //   child: Icon(
                                //     Icons.arrow_downward,
                                //     size: 16,
                                //     color: (controllers.sortField.value == 'date' &&
                                //         controllers.sortOrder.value == 'desc')
                                //         ? Colors.white
                                //         : Colors.grey,
                                //   ),
                                // )
                                // ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CustomText(
                                textAlign: TextAlign.left,
                                text: "Action",
                                size: 15,
                                isBold: true,
                                colors: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(//1
                                    textAlign: TextAlign.left,
                                    text: "Employee Name",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                 5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('name');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(//2
                                    textAlign: TextAlign.left,
                                    text: "Role",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('role');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Mobile No",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('mobile');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Email",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('email');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Address",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('address');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Salary",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('salary');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CustomText(
                                    textAlign: TextAlign.left,
                                    text: "Bonus",
                                    size: 15,
                                    isBold: true,
                                    colors: Colors.white,
                                  ),
                                  5.width,
                                  GestureDetector(
                                    onTap: (){
                                      employeeProvider.setFieldAndToggle('bonus');
                                    },
                                    child: Image.asset(
                                      employeeProvider.sortField.isEmpty
                                          ? "assets/images/arrow.png"
                                          : employeeProvider.sortOrder == 'asc'
                                          ? "assets/images/arrow_up.png"
                                          : "assets/images/arrow_down.png",
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: LayoutBuilder(builder: (context, constraints){
                        return employeeProvider.filteredStaff.isNotEmpty ? ListView.builder(
                          itemCount: employeeProvider.filteredStaff.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final staffData = employeeProvider.filteredStaff[index];
                            final staffId =  employeeProvider.filteredStaff[index].id;
                            return InkWell(
                              onTap: (){
                                employeeProvider.setSelectedEmployeeIndex(index);
                              },
                              child: Table(
                                columnWidths:const {
                                  0: FlexColumnWidth(2),//S.No
                                  1: FlexColumnWidth(3.5),//Employee Name
                                  2: FlexColumnWidth(3),//Role.
                                  3: FlexColumnWidth(2),//Mobile No
                                  4: FlexColumnWidth(3),//Email
                                  5: FlexColumnWidth(2.5),//Action
                                  6: FlexColumnWidth(2.5),
                                  7: FlexColumnWidth(2.5),
                                  8: FlexColumnWidth(2.5),
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
                                        SizedBox(
                                          width:screenWidth*0.05,
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: employeeProvider.isCheckedEmployee(staffId!),
                                                onChanged: (value) {
                                                  employeeProvider.toggleSelectionEmployee(staffId);
                                                },
                                              ),
                                              CustomText(text: "${index + 1}"),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  onPressed: (){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateEmployee(
                                                      employeeData :staffData ,
                                                    )));
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
                                                            text: "Are you sure delete this employees?",
                                                            size: 16,
                                                            isBold: true,
                                                            colors: colorsConst.textColor,
                                                          ),                                                                  actions: [
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
                                                                  employeeProvider.employeeDelete(
                                                                      eId:staffData.id,
                                                                      context: context
                                                                  );

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
                                        Tooltip(
                                          message: staffData.sName.toString()=="null"?"":staffData.sName.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: "${staffData.sName}",
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: CustomText(
                                            textAlign: TextAlign.left,
                                            text:employeeProvider.getRoleName(staffData.role.toString()=="null"?"1":staffData.role.toString()),
                                            size: 14,
                                            colors: colorsConst.textColor,
                                          ),
                                        ),
                                        Tooltip(
                                          message: staffData.sMobile.toString()=="null"?"":staffData.sMobile.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: staffData.sMobile.toString(),
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: staffData.email.toString()=="null"?"":staffData.email.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: staffData.email.toString(),
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: staffData.sAddress.toString()=="null"?"":staffData.sAddress.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: staffData.sAddress.toString(),
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: staffData.salary.toString()=="null"?"":staffData.salary.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: staffData.salary.toString(),
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: staffData.bonus.toString()=="null"?"":staffData.bonus.toString(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CustomText(
                                              textAlign: TextAlign.left,
                                              text: staffData.bonus.toString(),
                                              size: 14,
                                              colors:colorsConst.textColor,
                                            ),
                                          ),
                                        ),
                                        // Visibility(
                                        //   visible: employeeProvider.selectedEmployeeIndex == index,
                                        //   child: Column(
                                        //     crossAxisAlignment: CrossAxisAlignment.start,
                                        //     children: [
                                        //       const Divider(),
                                        //       Padding(
                                        //         padding: const EdgeInsets.all(20.0),
                                        //         child: Column(
                                        //           children: [
                                        //             Row(
                                        //               children: [
                                        //                 Padding(
                                        //                   padding: const EdgeInsets.all(4.0),
                                        //                   child: SizedBox(
                                        //                     width: screenWidth * 0.70,
                                        //                     child: Row(
                                        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                       children: [
                                        //                         Padding(
                                        //                           padding: const EdgeInsets.all(8.0),
                                        //                           child: Row(
                                        //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //                             children: [
                                        //                               SizedBox(
                                        //                                 child: const CustomText(text: "Email", isBold:true,),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                                 child: const Center(child: CustomText(text: ":", isBold:true)),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 child: CustomText(text: staffData.email ?? '-',),
                                        //                               ),
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                         Padding(
                                        //                           padding: const EdgeInsets.all(4.0),
                                        //                           child: Row(
                                        //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //                             children: [
                                        //                               SizedBox(
                                        //                                 child: const CustomText(text: "Address", isBold:true,),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                                 child: const Center(child: CustomText(text: ":", isBold:true)),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 child: CustomText(text: staffData.sAddress?.isNotEmpty == true ? staffData.sAddress! : '-',),
                                        //                               ),
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                         Padding(
                                        //                           padding: const EdgeInsets.all(4.0),
                                        //                           child: Row(
                                        //                             crossAxisAlignment: CrossAxisAlignment.start,
                                        //                             children: [
                                        //                               SizedBox(
                                        //                                 child: const CustomText(text: "Whatsapp No", isBold:true,),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                                 child: const Center(child: CustomText(text: ":", isBold:true)),
                                        //                               ),
                                        //                               SizedBox(
                                        //                                 child: CustomText(text: staffData.whatsapp?.isNotEmpty == true ? staffData.whatsapp! : '-'),
                                        //                               ),
                                        //                             ],
                                        //                           ),
                                        //                         ),
                                        //                         Row(
                                        //                           crossAxisAlignment: CrossAxisAlignment.start,
                                        //                           children: [
                                        //                             SizedBox(
                                        //                               child: CustomText(text: "Joining Date", isBold:true,),
                                        //                             ),
                                        //                             SizedBox(
                                        //                               width: isWebView ? screenWidth * 0.25 * 0.05 :  screenWidth *  0.05,
                                        //                               child: Center(child: CustomText(text: ":", isBold:true)),
                                        //                             ),
                                        //                             SizedBox(
                                        //                               child: CustomText(text: staffData.joiningDate?.isNotEmpty == true ?
                                        //                               DateFormat('dd-MM-yyyy').format(DateTime.parse("${staffData.joiningDate!}")): '-'),
                                        //                             ),
                                        //                           ],
                                        //                         ),
                                        //                       ],
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //               ],
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       )
                                        //     ],
                                        //   ),
                                        // ),
                                      ]
                                  ),

                                ],
                              ),
                            );
                          },
                        ) : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            100.height,
                            Center(
                                child: SvgPicture.asset(
                                    "assets/images/noDataFound.svg")),
                          ],
                        );
                      }
                      ),
                    ),
                  ),
                ],
              ),
            ),)
          ],
        ),
    );
  }
    );
  }
}

