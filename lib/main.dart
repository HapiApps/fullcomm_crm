import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fullcomm_crm/controller/settings_controller.dart';
import 'package:fullcomm_crm/provider/employee_provider.dart';
import 'package:fullcomm_crm/provider/reminder_provider.dart';
import 'package:fullcomm_crm/screens/mobile_dashboard.dart';
import 'package:fullcomm_crm/screens/dashboard.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'common/constant/api.dart';
import 'common/constant/colors_constant.dart';
import 'common/widgets/log_in.dart';
import 'controller/reminder_controller.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  await GetStorage.init();
  final prefs = await SharedPreferences.getInstance();
  final loginScreen = prefs.getBool("loginScreen$versionNum") ?? false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(" Foreground message: ${message.data}");

    // App already open -> show dialog/snackbar
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(" Notification tapped: ${message.data}");

    // When user clicks the notification and app opens
  });

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
    remController.dataSource = _getDataSource();
    settingsController.allTemplates();
    remController.loadSavedFilters();
    if (widget.loginScreen) {
      apiService.getLeadCategories();
      apiService.allLeadsDetails();
      apiService.allQualifiedDetails();
      apiService.allNewLeadsDetails();
      apiService.allGoodLeadsDetails();
      apiService.allCustomerDetails();
      apiService.allTargetLeadsDetails();
      apiService.getRoles();
      apiService.getSheet();
      apiService.getAllCustomers();
      apiService.getOpenedMailActivity(true);
      apiService.getReplyMailActivity(true);
      apiService.getAllCallActivity("");
      apiService.getAllMailActivity();
      apiService.getAllMeetingActivity("");
      apiService.getAllNoteActivity();
      apiService.getUserHeading();
      remController.allReminders("2");
      settingsController.allRoles();
      settingsController.allOfficeHours();
      apiService.getAllEmployees();
    }
  }
  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(
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
              yearForegroundColor: WidgetStateProperty.all(Colors.black),
              todayForegroundColor: WidgetStateProperty.all(Colors.black),
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
                return Colors.black;
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
              child:widget.loginScreen == false ? const LoginPage() : kIsWeb?NewDashboard():MobileDashboard()),
        ),
      );
  }
  _DataSource _getDataSource() {
    List<Appointment> appointments = <Appointment>[];
    return _DataSource(appointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}