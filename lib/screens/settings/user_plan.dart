import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:get/get.dart';
import '../../common/constant/api.dart';
import '../../common/constant/colors_constant.dart';
import '../../common/constant/default_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_sidebar.dart';
import '../../components/custom_text.dart';
import '../../controller/controller.dart';
import 'dart:html' as html;

class UserPlan extends StatefulWidget {
  const UserPlan({super.key});

  @override
  State<UserPlan> createState() => _UserPlanState();
}

class _UserPlanState extends State<UserPlan> {
  final List<Map<String, dynamic>> plans = [
    {
      "plan": "Basic",
      "price": "₹199/month",
      "userLimit": "Up to 3 Users",
      "status": true,
      "usedUsers": 2,
      "totalUsers": 3,
    },
    {
      "plan": "Standard",
      "price": "₹1499/Year",
      "userLimit": "Up to 10 Users",
      "status": false,
      "usedUsers": 0,
      "totalUsers": 10,
    },
  ];
  // Reusable cell text
  Widget _cellText(String value) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(
      value,
      style: const TextStyle(fontSize: 14),
    ),
  );

  // Status Cell
  Widget _statusCell(bool active) => Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Checkbox(
          value: active,
          onChanged: (_) {},
          activeColor: Colors.blue,
        ),
        Text(
          active ? "Active" : "Inactive",
          style: TextStyle(
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ],
    ),
  );

  Widget _upgradeButton(BuildContext context, Map<String, dynamic> plan) =>
      Padding(
        padding: const EdgeInsets.all(10),
        child: TextButton(
          onPressed: () {
            _showUpgradeDialog(context, plan);
          },
          child: const Text(
            "Upgrade",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      );

  void _showUpgradeDialog(BuildContext context, Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text(
            "Upgrade Plan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Upgrade to ${plan["price"]} plan to add more users.",
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.pop(context);
                html.window.open("https://aruu.in/", "_blank");
              },
              child: const Text(
                "Upgrade",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Users Count Progress Bar
  Widget _userCount(int used, int total) => Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: used / total,
            color: Colors.green,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "$used/$total",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "User Plan & Access",
                          colors: colorsConst.textColor,
                          size: 20,
                          isBold: true,
                        ),
                        10.height,
                        CustomText(
                          text: "View all of your user plan & access",
                          colors: colorsConst.textColor,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
                30.height,
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),//Plan
                    1: FlexColumnWidth(2),//Price
                    2: FlexColumnWidth(3),//User Limit
                    3: FlexColumnWidth(2),//Status
                    4: FlexColumnWidth(2),//Upgrade Button
                    5: FlexColumnWidth(3),//Users Count
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
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Plan",//0
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Price",//1
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "User Limit",//2
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Status",//3
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "Upgrade Button",//3
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CustomText(
                              textAlign: TextAlign.left,
                              text: "User Count",//3
                              size: 15,
                              isBold: true,
                              colors: Colors.white,
                            ),
                          ),
                        ]),
                  ],
                ),
                Expanded(
                  child:ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Table(
                          columnWidths:const {
                            0: FlexColumnWidth(2),//Plan
                            1: FlexColumnWidth(2),//Price
                            2: FlexColumnWidth(3),//User Limit
                            3: FlexColumnWidth(2),//Status
                            4: FlexColumnWidth(2),//Upgrade Button
                            5: FlexColumnWidth(3),//Users Count
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
                                  _cellText(plans[index]["plan"]),//0
                                  _cellText(plans[index]["price"]),//1
                                  _cellText(plans[index]["userLimit"]),//2
                                  _statusCell(plans[index]["status"]),//3
                                  _upgradeButton(context, plans[index]),//4
                                  _userCount(plans[index]["usedUsers"], plans[index]["totalUsers"]),
                                ]
                            ),
                          ],
                        );
                      },
                    )
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
