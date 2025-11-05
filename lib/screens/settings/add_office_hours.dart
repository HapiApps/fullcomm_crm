import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/default_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_loading_button.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../models/all_customers_obj.dart';
import '../../services/api_services.dart';

class AddOfficeHours extends StatefulWidget {
  const AddOfficeHours({super.key});

  @override
  State<AddOfficeHours> createState() => _AddOfficeHoursState();
}

class _AddOfficeHoursState extends State<AddOfficeHours> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiService.getAllEmployees();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SideBar(
            controllers: controllers,
            colorsConst: colorsConst,
            logo: logo,
            constValue: constValue,
            versionNum: versionNum,
          ),
          Obx(()=> Container(
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
                          text: "General Settings",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                        ),
                        10.height,
                        CustomText(
                          text: "Add your office hours",
                          colors: colorsConst.textColor,
                          size: 14,
                        ),
                      ],
                    ),
                    CustomLoadingButton(
                      callback: () async {
                          if(settingsController.shiftController.text.isEmpty) {
                            controllers.productCtr.reset();
                            utils.snackBar(msg: "Please enter shift name",
                                context: context,
                                color: Colors.red);
                          }else if(settingsController.daysController.text.isEmpty){
                            controllers.productCtr.reset();
                            utils.snackBar(msg: "Please enter days",
                                context: context,
                                color: Colors.red);
                          }else if(controllers.selectedEmployeeId.value.isEmpty){
                            controllers.productCtr.reset();
                            utils.snackBar(msg: "Please select employee",
                                context: context,
                                color: Colors.red);
                          }else{
                            await settingsController.insertOfficeHourAPI(context);
                          }
                      },
                      height: 40,
                      isLoading: true,
                      backgroundColor: colorsConst.primary,
                      radius: 7,
                      width: 120,
                      controller: controllers.productCtr,
                      isImage: false,
                      text: "Save Role",
                      textColor: Colors.white,
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.5,
                  color: colorsConst.secondary,
                ),
                20.height,
                Row(
                  children: [
                    CustomText(text: "Office Working Hours",
                      size: 20,
                      colors: colorsConst.textColor,
                      isBold: true,
                    ),
                  ],
                ),
                10.height,
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Employees",
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  color: const Color(0xff737373),
                                ),
                              ),
                              const CustomText(
                                text: "*",
                                colors: Colors.red,
                                size: 25,
                              )
                            ],
                          ),
                          5.height,
                          KeyboardDropdownField<AllEmployeesObj>(
                            items: controllers.employees,
                            borderRadius: 5,
                            borderColor: Colors.grey.shade300,
                            hintText: "Select Employees",
                            labelText: "",
                            labelBuilder: (customer) =>
                            '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                            itemBuilder: (customer) {
                              return Container(
                                width: 300,
                                alignment: Alignment.topLeft,
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: CustomText(
                                  text:
                                  '${customer.name} ${customer.name.isEmpty ? "" : "-"} ${customer.phoneNo}',
                                  colors: Colors.black,
                                  size: 14,
                                  textAlign: TextAlign.start,
                                ),
                              );
                            },
                            textEditingController:
                            controllers.empController,
                            onSelected: (value) {
                              controllers.selectEmployee(value);
                            },
                            onClear: () {
                              controllers.clearSelectedCustomer();
                            },
                          ),
                        ],
                      ),
                    ),
                    20.width,
                    SizedBox(
                      width: 300,
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Shift Name",
                                  style: GoogleFonts.lato(
                                      fontSize: 17,
                                      color: Color(0xff737373))),
                              const CustomText(
                                text: "*",
                                colors: Colors.red,
                                size: 25,
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: settingsController.shiftController,
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter Shift Name",
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontSize: 17,
                                fontFamily: GoogleFonts.lato().fontFamily,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                20.height,
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "From",
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  color: const Color(0xff737373),
                                ),
                              ),
                              const CustomText(
                                text: "*",
                                colors: Colors.red,
                                size: 25,
                              )
                            ],
                          ),
                          5.height,
                          TextField(
                            readOnly: true,
                            onTap: () {
                              settingsController.pickTime(context, true);
                            },
                            decoration: InputDecoration(
                              hintText: settingsController.formatTime(settingsController.fromTime.value),
                              suffixIcon: const Icon(Icons.access_time),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.width,
                    SizedBox(
                      width: 300,
                      height: 85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "To",
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  color: const Color(0xff737373),
                                ),
                              ),
                              const CustomText(
                                text: "*",
                                colors: Colors.red,
                                size: 25,
                              )
                            ],
                          ),
                          5.height,
                          TextField(
                            readOnly: true,
                            onTap: () => settingsController.pickTime(context, false),
                            decoration: InputDecoration(
                              hintText: settingsController.formatTime(settingsController.toTime.value),
                              suffixIcon: const Icon(Icons.access_time),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.width,
                    SizedBox(
                      width: 300,
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Days",
                                  style: GoogleFonts.lato(
                                      fontSize: 17,
                                      color: Color(0xff737373))),
                              const CustomText(
                                text: "*",
                                colors: Colors.red,
                                size: 25,
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: settingsController.daysController,
                            style: GoogleFonts.lato(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Enter days",
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontSize: 17,
                                fontFamily: GoogleFonts.lato().fontFamily,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
