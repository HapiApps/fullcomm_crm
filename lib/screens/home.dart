import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/colors_constant.dart';
import '../common/utilities/utils.dart';
import '../common/widgets/log_in.dart';
import '../controller/controller.dart';
import 'customer/view_customer.dart';
import 'dashboard.dart';
import 'leads/disqualified_lead.dart';
import 'leads/prospects.dart';
import 'leads/qualified.dart';
import 'leads/suspects.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvoked:(bool didPop){
        controllers.selectedIndex.value = controllers.oldIndex.value;
      },
      child: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              utils.sideBarFunction(context),
              Container(
                width: controllers.isLeftOpen.value == false &&
                    controllers.isRightOpen.value == false
                    ? screenWidth - 200
                    : screenWidth - 450,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.topLeft,
                child: Obx(() {
                  switch (controllers.selectedIndex.value) {
                    case 0:
                      return Dashboard();
                    case 1:
                      return Suspects();
                    case 2:
                      return Prospects();
                    case 3:
                      return Qualified();
                    case 4:
                      return ViewCustomer();
                    case 5:
                      return DisqualifiedLead();
                    case 7: // logout
                      Future.microtask(() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: colorsConst.primary,
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Do you want to log out?",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorsConst.primary,
                                          side: BorderSide(color: colorsConst.secondary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          "No",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final prefs =
                                          await SharedPreferences.getInstance();
                                          prefs.setBool("loginScreen", false);
                                          prefs.setBool("isAdmin", false);
                                          Get.to(const LoginPage(),
                                              duration: Duration.zero);
                                          controllers.selectedIndex.value = 0; // reset
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorsConst.primary,
                                          side: BorderSide(color: colorsConst.secondary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      });
                      return const SizedBox.shrink(); // empty widget instead
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),
              utils.funnelContainer(context),
            ],
          )
      ),
    );
  }
}
