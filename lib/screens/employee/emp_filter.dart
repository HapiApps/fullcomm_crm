import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:get/get.dart';
import '../../common/styles/decoration.dart';
import '../../components/Customtext.dart';
import '../../components/keyboard_search.dart';
import '../../controller/controller.dart';
import '../../controller/emp_report_controller.dart';
import '../../models/all_customers_obj.dart';
import '../../models/employee_details.dart';

class EmployeeFilter extends StatefulWidget {
  const EmployeeFilter({super.key});

  @override
  State<EmployeeFilter> createState() => _EmployeeFilterState();
}

class _EmployeeFilterState extends State<EmployeeFilter> {
  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,radius: 12,borderColor: Colors.grey.shade200
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 480,
                  height: 40,
                  child: KeyboardDropdownField<AllEmployeesObj>(
                    items: controllers.employees,
                    hintText: "Employee Name",
                    borderRadius: 5,
                    borderColor: Colors.grey.shade200,
                    labelBuilder: (customer) =>
                    '${customer.name} ${customer.phoneNo}',
                    itemBuilder: (customer) =>
                        Container(
                          width: 300,
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: CustomText(
                            text:
                            '${customer.name} , ${customer.phoneNo}',
                            colors: Colors.black,
                            size: 14,
                            isCopy: false,
                            textAlign: TextAlign.start,
                          ),
                        ),
                    textEditingController: controllers.cusController,
                    onSelected: (value) {
                      repCtr.empId.value=value.id;
                      repCtr.empName.value=value.name;
                      repCtr.getWholeReport(repCtr.empId.value);
                    },
                    onClear: () {
                      controllers.clearSelectedCustomer();
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: InkWell(
                onTap: () {
                  repCtr.showDatePickerDialog(context);
                },
                child: _date()),
          ),


          const SizedBox(width: 15),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 18,
              ),
            ),
            onPressed: () {},
            child: const CustomText(
              text: "Apply Filter",
              isCopy: false,
              colors: Colors.white,
              isBold: true,
            ),
          ),

          const SizedBox(width: 10),
          Container(
            height: 38,width: 70,
            decoration: customDecoration.baseBackgroundDecoration(
              color: Colors.white,radius: 5,borderColor: Colors.grey.shade200
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomText(
                text: "Reset",
                isCopy: false,
                isBold: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _dropdown(String hint) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        CustomText(
          text: hint,
          isCopy: false,
          isBold: true,
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: const [],
          onChanged: (v) {},
        )

      ],
    );
  }

  Widget _date() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const CustomText(
          text: "Date Range",
          isCopy: false,
          isBold: true,
        ),

        const SizedBox(height: 8),

        Obx(()=>Container(
          height: 38,
          decoration: customDecoration.baseBackgroundDecoration(
              color: Colors.white,radius: 5,borderColor: Colors.grey.shade200
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,color: Colors.grey,size: 20,),10.width,
                    CustomText(
                      text: "${repCtr.stDate.value}${repCtr.stDate.value!=repCtr.enDate.value&&repCtr.enDate.value != ""
                          ? " To ${repCtr.enDate.value}"
                          : ""}", isCopy: false,),
                  ],
                ),
                Icon(Icons.keyboard_arrow_down,color: Colors.grey,)
              ],
            ),
          ),
        )),

      ],
    );
  }
}