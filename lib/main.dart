import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fullcomm_crm/common/extentions/int_extensions.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/provider/employee_provider.dart';
import 'package:fullcomm_crm/provider/reminder_provider.dart';
import 'package:fullcomm_crm/screens/new_dashboard.dart';
import 'package:fullcomm_crm/screens/zoom_blocker.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/constant/api.dart';
import 'common/constant/colors_constant.dart';
import 'common/widgets/log_in.dart';
import 'components/custom_text.dart';
import 'controller/controller.dart';
import 'controller/reminder_controller.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  await GetStorage.init();
  final prefs = await SharedPreferences.getInstance();
  final loginScreen = prefs.getBool("loginScreen${controllers.versionNum}") ?? false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],child: MyApp(loginScreen: loginScreen,)));
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

class MyApp extends StatefulWidget {
  final bool loginScreen;
  const MyApp({super.key, required this.loginScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (widget.loginScreen) {
      apiService.allLeadsDetails();
      apiService.allQualifiedDetails();
      apiService.allNewLeadsDetails();
      apiService.allGoodLeadsDetails();
      apiService.allCustomerDetails();
      apiService.getRoles();
      apiService.getSheet();
      apiService.getAllCustomers();
      apiService.getOpenedMailActivity(true);
      apiService.getReplyMailActivity(true);
      apiService.getAllCallActivity();
      apiService.getAllMailActivity();
      apiService.getAllMeetingActivity();
      apiService.getAllNoteActivity();
      apiService.getUserHeading();
      remController.allReminders("2");
      settingsController.allRoles();
      settingsController.allOfficeHours();
    }
  }
  @override
  Widget build(BuildContext context) {
    return ZoomBlocker(
      child: MyInheritedWidget(
        data: 42,
        child: GetMaterialApp(
          scrollBehavior: MyCustomScrollBehavior(),
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: colorsConst.primary,
              primary: colorsConst.primary,
              secondary: colorsConst.primary
            ),
            useMaterial3: false,
            textTheme: GoogleFonts.latoTextTheme(),
            primaryColor: colorsConst.primary,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white, // Calendar background
              headerBackgroundColor: colorsConst.primary, // Top header background
              headerForegroundColor: Colors.white, // Header text color
              todayForegroundColor: WidgetStateProperty.all(colorsConst.primary),
              todayBackgroundColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              surfaceTintColor: Colors.transparent,
              dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorsConst.primary;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
              rangeSelectionBackgroundColor:colorsConst.primary,
              rangeSelectionOverlayColor: WidgetStateProperty.all(
                Colors.teal.withOpacity(0.25),
              ),
              elevation: 4,
            ),
            scaffoldBackgroundColor: colorsConst.backgroundColor,
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(Colors.grey),
              trackColor: WidgetStateProperty.all(Colors.white),
              thickness: WidgetStateProperty.all(5),
              radius: const Radius.circular(5),
            ),
          ),
          home: SelectionArea(
              child:widget.loginScreen == false ? const LoginPage() : const NewDashboard()),
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
    // apiService.getLeadCategory();
    // apiService.getVisitType();
    apiService.getAllCustomers();
    apiService.getOpenedMailActivity(true);
    apiService.getReplyMailActivity(true);
    apiService.getAllCallActivity();
    apiService.getAllMailActivity();
    apiService.getAllMeetingActivity();
    apiService.getAllNoteActivity();
    apiService.getUserHeading();
    if (widget.loginScreen) {
      apiService.allLeadsDetails();
      apiService.allQualifiedDetails();
      apiService.allNewLeadsDetails();
      apiService.allGoodLeadsDetails();
      apiService.allCustomerDetails();
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
      duration: 100,
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
              text: appName,
              size: 30,
              colors: colorsConst.primary,
              isBold: true,
            )
          ],
        ),
      ),
      pageTransitionType: PageTransitionType.fade,
      nextScreen: widget.loginScreen == false ? const LoginPage() : const NewDashboard(),
      //nextScreen:widget.loginScreen?const BottomPage():const LoginPage(),
      //nextScreen:const BottomPage(),
    );
  }
}


class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final int currentMonth = DateTime.now().month;

    return Obx(() => LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          ),
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
                Widget text(String text) {
                  return CustomText(
                    text: text,
                    colors: colorsConst.textColor,
                    size: 12,
                  );
                }

                // Only show labels up to the current month
                if (value.toInt() > currentMonth) return const SizedBox.shrink();

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
        maxX: currentMonth.toDouble(), // Set maxX to current month
        minY: 0,
        maxY: 250,
        lineBarsData: [
          LineChartBarData(
            spots: controllers.chartSpots
                .where((spot) => spot.x <= currentMonth)
                .toList(), // Filter spots to current month
            isCurved: true,
            color: Colors.pink,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    ));
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
