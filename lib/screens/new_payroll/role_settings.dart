import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/common/utilities/utils.dart';
import 'package:fullcomm_crm/controller/new_payroll_controller.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/screens/settings/terms_conditions.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/key_constant.dart';
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
  var services=NewPayrollApiServices.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      controllers.storage.write("com_id","1");
      FocusScope.of(context).requestFocus(f1);
      services.getRoleSettings(context);
      final employeeData = Provider.of<EmployeeProvider>(context, listen: false);
      if(employeeData.roleList.isEmpty){
        employeeData.fetchRoleList();
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: [
                    IconButton(
                        onPressed: (){
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back)),
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
                    color: Colors.grey
                ),20.height,
                pyrlCtr.getUnits.value==false?
                CircularProgressIndicator():
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
                                    bool hasInvalid = false;

                                    for (var data in pyrlCtr.settingList) {
                                      // Check if role or salary missing
                                      if (data.roleName ==""  ||(data.salary.text.trim().isEmpty&& data.perDay.text.trim().isEmpty)) {
                                        hasInvalid = true;
                                        break;
                                      }
                                    }

                                    if (hasInvalid) {
                                      utils.snackBar(context: context, msg: "Please fill Role and Salary", color: Colors.red);
                                    } else {
                                      pyrlCtr.addSetting();
                                    }
                                  }, isLoading: false, text: "Add Role",isImage: false,textColor: colorsConst.primary,
                                  backgroundColor: Colors.white, radius: 5, width: 100,height: 35,),10.width,
                              CustomLoadingButton(
                                  callback: (){
                                    bool hasInvalid = false;

                                    for (var data in pyrlCtr.settingList) {
                                      // Check if role or salary missing
                                      debugPrint("data.role");
                                      debugPrint(data.role.toString());
                                      debugPrint(data.salary.text.trim());
                                      if (data.roleName == "" || (data.salary.text.trim().isEmpty&& data.perDay.text.trim().isEmpty)) {
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
                              itemCount: pyrlCtr.settingList.length,
                              itemBuilder: (context, index) {
                                final data = pyrlCtr.settingList[index];
                  
                                void calculateAmounts() {
                                  setState(() {
                                    double perDay = double.tryParse(data.perDay.text) ?? 0.0;
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
                                  });
                                }
                  
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        ),
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
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                  onTap:(){
                                                    pyrlCtr.settingList.removeAt(index);
                                                  },
                                                  child: const Icon(Icons.delete_outline_outlined,color: Colors.red,))
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
                                        Container(
                                          width: screenWidth / 5,
                                          decoration: customDecoration.baseBackgroundDecoration(
                                            radius: 10,
                                            color: Colors.white,
                                          ),
                                          child: DropdownButtonFormField<Map<String, dynamic>>(
                                            key: ValueKey(data.roleId), // 👈 forces dropdown to rebuild when reset
                                            decoration: InputDecoration(
                                              label: Row(
                                                children: [
                                                  CustomText(
                                                      text: "Role",
                                                      colors: Colors.grey,
                                                      size: 14,isCopy: false
                                                  ),
                                                  CustomText(
                                                      text: "*",
                                                      colors: Colors.red,
                                                      size: 15,isCopy: false
                                                  ),
                                                ],
                                              ),
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
                                            value: data.role,
                                            hint: CustomText(
                                              text: data.roleName==""?"Role":data.roleName.toString(),
                                              colors: Colors.grey, isCopy: false,
                                            ),
                                            items: employeeProvider.roleList
                                                .map<DropdownMenuItem<Map<String, dynamic>>>((item) {
                                              return DropdownMenuItem<Map<String, dynamic>>(
                                                value: item,
                                                child: CustomText(
                                                  text: item["role_name"],
                                                  colors: Colors.black,isCopy: false,
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value == null) return;
                                              final selectedRole = value;
                  
                                              bool roleExists = pyrlCtr.settingList.any((item) =>
                                              item.role != null &&
                                                  item.role["u_id"] == selectedRole["u_id"] &&
                                                  item != data);
                  
                                              if (roleExists) {
                                                Get.snackbar(
                                                  "Duplicate Role",
                                                  "This role is already added in another payroll setting.",
                                                  backgroundColor: Colors.red.withOpacity(0.8),
                                                  colorText: Colors.white,
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  margin: const EdgeInsets.all(10),
                                                );
                  
                                                // Reset the selection properly
                                                setState(() {
                                                  data.roleId = ""; // reset ID
                                                  data.roleName = "";
                                                  data.role = null; // reset value (will trigger rebuild due to key)
                                                });
                                              } else {
                                                setState(() {
                                                  data.role = selectedRole;
                                                  data.roleId = selectedRole["u_id"].toString();
                                                  data.roleName = selectedRole["role_name"].toString();
                                                });
                                              }
                                            },
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
}
