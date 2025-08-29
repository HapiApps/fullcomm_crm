import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:fullcomm_crm/common/constant/default_constant.dart';
import 'package:fullcomm_crm/common/extentions/int_extensions.dart';
import 'package:fullcomm_crm/screens/dashboard.dart';
import 'package:fullcomm_crm/screens/home.dart';
import 'package:fullcomm_crm/screens/zoom_blocker.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/constant/api.dart';
import 'common/constant/colors_constant.dart';
import 'common/widgets/log_in.dart';
import 'components/custom_text.dart';
import 'controller/controller.dart';

Future<void> main() async {
  await GetStorage.init();
  final prefs = await SharedPreferences.getInstance();
  final loginScreen = prefs.getBool("loginScreen") ?? false;

  runApp(MyApp(
    loginScreen: loginScreen,
  ));
}

class MyInheritedWidget extends InheritedWidget {
  final int data;

  const MyInheritedWidget(
      {super.key, required this.data, required super.child});

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return oldWidget.data != data;
  }

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }
}

class MyApp extends StatelessWidget {
  final bool loginScreen;
  const MyApp({super.key, required this.loginScreen});

  @override
  Widget build(BuildContext context) {
    return ZoomBlocker(
      child: MyInheritedWidget(
        data: 42,
        child: GetMaterialApp(
          scrollBehavior: MyCustomScrollBehavior(),
          // scrollBehavior: const MaterialScrollBehavior().copyWith(
          //   dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
          // ),
          debugShowCheckedModeBanner: false,
          title: appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: false,
            scaffoldBackgroundColor: Colors.white,
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(const Color(0xffC1C0E0)),
              trackColor: MaterialStateProperty.all(const Color(0xff2C3557)),
              thickness: MaterialStateProperty.all(5),
              radius: const Radius.circular(10),
            ),
          ),

          home: SelectionArea(
              child: SplashScreen(
            loginScreen: loginScreen,
          )),
        ),
      ),
    );
  }
}

// class ZengrafDashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Zengraf Dashboard',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: DashboardPage(),
//     );
//   }
// }
//
// class DashboardPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Zengraf'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.message),
//             onPressed: () {},
//           ),
//           CircleAvatar(
//             backgroundImage: AssetImage('assets/profile.jpg'), // Add your image asset here
//           ),
//           SizedBox(width: 16),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               child: Text('Menu', style: TextStyle(color: Colors.white)),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//             ),
//             ListTile(
//               title: Text('Dashboard'),
//               onTap: () {},
//             ),
//             ListTile(
//               title: Text('Lead'),
//               onTap: () {},
//             ),
//             ListTile(
//               title: Text('Client'),
//               onTap: () {},
//             ),
//             ListTile(
//               title: Text('Customer'),
//               onTap: () {},
//             ),
//             ListTile(
//               title: Text('Products'),
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   SummaryCard(
//                     title: 'Leads',
//                     value: '100',
//                     subtitle: '+8% from yesterday',
//                     color: Colors.redAccent,
//                   ),
//                   SummaryCard(
//                     title: 'This Week',
//                     value: '100',
//                     subtitle: '+8% from previous week',
//                     color: Colors.orangeAccent,
//                   ),
//                   SummaryCard(
//                     title: 'This Month',
//                     value: '100',
//                     subtitle: '+8% from previous month',
//                     color: Colors.greenAccent,
//                   ),
//                   SummaryCard(
//                     title: 'Total Leads',
//                     value: '100',
//                     color: Colors.purpleAccent,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Expanded(
//                     child: Container(
//                       height: 200.0,
//                       padding: EdgeInsets.all(8.0),
//                       color: Colors.white,
//                       child: LineChart(LineChartData(
//                         gridData: const FlGridData(show: false),
//                         titlesData: const FlTitlesData(show: true),
//                         borderData: FlBorderData(show: false),
//                         lineBarsData: [
//                           LineChartBarData(
//                             spots: [
//                               FlSpot(0, 1),
//                               FlSpot(1, 3),
//                               FlSpot(2, 10),
//                               FlSpot(3, 7),
//                               FlSpot(4, 12),
//                               FlSpot(5, 13),
//                               FlSpot(6, 17),
//                             ],
//                             isCurved: true,
//                             color: Colors.blue,
//                             barWidth: 4,
//                             isStrokeCapRound: true,
//                             dotData: FlDotData(show: false),
//                           ),
//                         ],
//                       )),
//                     ),
//                   ),
//                   SizedBox(width: 16.0),
//                   Expanded(
//                     child: Container(
//                       height: 200.0,
//                       padding: EdgeInsets.all(8.0),
//                       color: Colors.white,
//                       child: BarChart(BarChartData(
//                         gridData: FlGridData(show: false),
//                         titlesData: FlTitlesData(show: true),
//                         borderData: FlBorderData(show: false),
//                         barGroups: [
//                           BarChartGroupData(x: 0, barRods: [BarChartRodData(color: Colors.lightBlueAccent, toY: 8)]),
//                           BarChartGroupData(x: 1, barRods: [BarChartRodData(color: Colors.lightBlueAccent, toY: 10)]),
//                           BarChartGroupData(x: 2, barRods: [BarChartRodData(color: Colors.lightBlueAccent, toY: 14)]),
//                           BarChartGroupData(x: 3, barRods: [BarChartRodData(color: Colors.lightBlueAccent, toY: 15)]),
//                           BarChartGroupData(x: 4, barRods: [BarChartRodData(color: Colors.lightBlueAccent, toY: 13)]),
//                           BarChartGroupData(x: 5, barRods: [BarChartRodData(color: Colors.lightBlueAccent, toY: 10)]),
//                         ],
//                       )),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   RatingCard(color: Colors.red, title: "Total Hot", value: "120"),
//                   RatingCard(color: Colors.orange, title: "Total Warm", value: "120"),
//                   RatingCard(color: Colors.green, title: "Total Cold", value: "120"),
//                 ],
//               ),
//               SizedBox(height: 16.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Expanded(
//                     child: InfoCard(
//                       title: 'Quotations Sent',
//                       value: '200',
//                     ),
//                   ),
//                   SizedBox(width: 16.0),
//                   Expanded(
//                     child: InfoCard(
//                       title: 'Emails Sent',
//                       value: '50',
//                       additionalInfo: 'Not Sent: 45',
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Expanded(
//                     child: InfoCard(
//                       title: 'Total Customers',
//                       value: '150',
//                     ),
//                   ),
//                   SizedBox(width: 16.0),
//                   Expanded(
//                     child: InfoCard(
//                       title: 'Total Products',
//                       value: '150',
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SummaryCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String subtitle;
//   final Color color;
//
//   SummaryCard({
//     required this.title,
//     required this.value,
//     this.subtitle = '',
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Card(
//         color: color,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.black,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: Colors.black,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                //var conData="";
                Widget text(String text) {
                  return CustomText(
                    text: text,
                    colors: colorsConst.textColor,
                    size: 12,
                  );
                }

                switch (value.toInt()) {
                  case 1:
                    return text('Jan');
                  case 2:
                    return text('Feb');
                  case 3:
                    return text('Mar');
                  case 4:
                    return text('Apr');
                  case 5:
                    return text('May');
                  case 6:
                    return text('Jun');
                  case 7:
                    return text('Jul');
                  case 8:
                    return text('Aug');
                  case 9:
                    return text('Sep');
                  case 10:
                    return text('Oct');
                  case 11:
                    return text('Nov');
                  case 12:
                    return text('Dec');
                }
                return text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        minX: 1,
        maxX: 12,
        minY: 0,
        maxY: 250,
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 40),
              FlSpot(2, 40),
              FlSpot(3, 20),
              FlSpot(4, 80),
              FlSpot(5, 100),
              FlSpot(6, 220),
              FlSpot(7, 240),
              FlSpot(8, 160),
              FlSpot(9, 180),
              FlSpot(10, 80),
              FlSpot(11, 20),
              FlSpot(12, 40),
            ],
            isCurved: true,
            color: Colors.pink,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class RatingCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;

  const RatingCard({
    super.key,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: color,
                  ),
                  8.width,
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? additionalInfo;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            8.height,
            Text(
              value,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (additionalInfo != null)
              Text(
                additionalInfo!,
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final bool loginScreen;
  const SplashScreen({super.key, required this.loginScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    apiService.getRoles();
    apiService.getLeadCategory();
    apiService.getVisitType();
    if (widget.loginScreen) {
      apiService.allLeadsDetails();
      apiService.allQualifiedDetails();
      apiService.allNewLeadsDetails();
      controllers.allGoodLeadFuture = apiService.allGoodLeadsDetails();
      controllers.allCustomerFuture = apiService.allCustomerDetails();
    }
    //  Future.delayed(Duration.zero,(){
    //    setState(() {
    //    controllers.selectStateList=[];
    //    for (var entry in controllers.pinCodeList){
    //      if (entry['STATE'] is String && !controllers.selectStateList.contains(entry['STATE'])) {
    //        controllers.selectStateList.add(entry['STATE']);
    //      }
    //    }
    //    for (var item in controllers.stateList){
    //      if (!controllers.selectStateList.contains(item)){
    //        print(item);
    //      }
    //    }
    //   controllers.selectCityList=[];
    //   for (var entry in controllers.pinCodeList){
    //     if (entry['STATE'] == "Tamil Nadu" && entry['DISTRICT'] is String){
    //       if (!controllers.selectCityList.contains(entry['DISTRICT'])) {
    //         controllers.selectCityList.add(entry['DISTRICT'].toString().trim());
    //       }
    //     }
    //   }
    // });
    //
    //  });
    //controllers.allCompanyFuture=apiService.allCompanyDetails();
    //controllers.allEmployeeFuture=apiService.allEmployeeDetails();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 300,
      splashIconSize: 800,
      splashTransition: SplashTransition.fadeTransition,
      splash: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Image.asset("assets/images/app_logo.png",fit: BoxFit.fill,),
            CustomText(
              text: "$appName CRM",
              size: 30,
              colors: colorsConst.primary,
              isBold: true,
            )
          ],
        ),
      ),
      pageTransitionType: PageTransitionType.fade,
      nextScreen: widget.loginScreen == false ? const LoginPage() : const Home(),
      //nextScreen:widget.loginScreen?const BottomPage():const LoginPage(),
      //nextScreen:const BottomPage(),
    );
  }
}
