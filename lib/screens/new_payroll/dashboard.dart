import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:security/source/extentions/extensions.dart';
import 'package:security/view/new_payroll/pay_slip.dart';
import 'package:security/view/new_payroll/pf_wages.dart';
import 'package:security/view/new_payroll/salary_slip.dart';
import 'package:security/view/new_payroll/wages_sheet.dart';
import '../../component/home_container.dart';
import '../../constant/assets_constant.dart';
import '../../constant/color_constant.dart';
import '../../services/new_payroll_api_services.dart';
import '../../widgets/widgets_functions.dart';
import '../common/home.dart';
import 'attendance.dart';
import 'esi_wages.dart';

class NewPayroll extends StatefulWidget {
  const NewPayroll({super.key});

  @override
  State<NewPayroll> createState() => _NewPayrollState();
}

class _NewPayrollState extends State<NewPayroll> {
  var newPyrlServ=NewPayrollApiServices.instance;

  @override
  void initState() {
    newPyrlServ.getAllUnits();
    newPyrlServ.allEmpList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorsConst.backGroundColor,
      appBar: PreferredSize(preferredSize: const Size(300, 70),
          child: app_bar(text: "Payroll Console",callback1: (){
            Get.to(const HomePage(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
          })),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.height*0.9,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DashBoardContainer(
                    text: 'Attendance',
                    image: Image.asset(assets.attendance),
                    callback: () {
                      Get.to(const AttendanceDuty(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
                    },),
                  DashBoardContainer(
                    text: 'Wages Sheet',
                    image: Image.asset(assets.report),
                    callback: () {
                      Get.to(const UnitSlip(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
                    },),
                ],
              ),
              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DashBoardContainer(
                    text: 'ESI Wages',
                    image: Image.asset(assets.report),
                    callback: () {
                      Get.to(const ESIWages(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
                    },),
                  DashBoardContainer(
                    text: 'PF Wages',
                    image: Image.asset(assets.report),
                    callback: () {
                      Get.to(const PFWages(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
                    },),
                ],
              ),
              20.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DashBoardContainer(
                    text: 'Pay Slip',
                    image: Image.asset(assets.report),
                    callback: () {
                      Get.to(const PaySlip(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
                    },),
                  DashBoardContainer(
                    text: 'Salary Slip',
                    image: Image.asset(assets.report),
                    callback: () {
                      Get.to(const SalarySlip(), transition: Transition.rightToLeftWithFade, duration: const Duration(seconds: 1));
                    },),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
