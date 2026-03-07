import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/models/company_obj.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:group_button/group_button.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../common/constant/api.dart';
import '../common/utilities/jwt_storage.dart';
import '../common/utilities/utils.dart';
import '../common/widgets/log_in.dart';
import '../models/comments_obj.dart';
import '../models/customer_activity.dart';
import '../models/customer_full_obj.dart';
import '../models/employee_obj.dart';
import '../models/mail_receive_obj.dart';
import '../models/meeting_obj.dart';
import '../models/month_report_obj.dart';
import '../models/new_lead_obj.dart';
import '../models/product_obj.dart';
import '../models/user_heading_obj.dart';
import 'package:http/http.dart'as http;

import '../screens/leads/new_lead_page.dart';
import '../services/api_services.dart';
import 'dashboard_controller.dart';
final controllers = Get.put(Controller());

class Controller extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var tabCurrentIndex = 0.obs;
  bool isDialogOpen = false;
  var isUpdateLoading=false.obs;
  var sharingLocation="".obs;
  TextEditingController notesController=TextEditingController();
  Future<void> manageLead(BuildContext context,String id,int active) async {
    try {
      Map<String, dynamic> data = {
        "user_id": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id"),
        "id": id,
        "action": "manage_lead",
        "active": active,
      };
      print("Request: ${jsonEncode(data)}");
      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      Map<String, dynamic> result = json.decode(response.body);
      print("Response: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return manageLead(context,id,active);
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode == 200 && result["message"] == "OK") {
        utils.snackBar(context: context,msg: "Category ${active==1?'Active':"InActive"} successfully.",color: Colors.green);
        apiService.getAllLeadCategories();
        int index = controllers.leadCategoryList.indexWhere((e) => e.id == id);

        if (index != -1) {
          controllers.leadCategoryList.removeAt(index);
        }
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!, result["message"] ?? "Failed to Category ${active==1?'Active':"InActive"}.");
        controllers.productCtr.reset();
      }
    } catch (e) {
      apiService.errorDialog(Get.context!, e.toString());
      controllers.productCtr.reset();
    }
  }

  RxList<TextEditingController> numberList=<TextEditingController>[].obs;
RxList<TextEditingController> infoNumberList=<TextEditingController>[].obs;
  final sortFieldCallActivity = ''.obs;
  final sortOrderCallActivity = 'asc'.obs;
  final sortFieldMeetingActivity = ''.obs;
  final sortOrderMeetingActivity = 'asc'.obs;
  final sortFieldEmployee = ''.obs;
  final sortOrderEmployee = 'asc'.obs;
  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      tabCurrentIndex.value = tabController.index;
    });
    super.onInit();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
    tabCurrentIndex.value = index;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
  // var version = "Version 0.0.14";
  //  var versionNum = "0.0.14";
  var serverVersion = "".obs,
      currentApk = "".obs,
      currentUserCount = "".obs,
      currentCRMLink = "".obs,
      versionActive = true.obs,
      planType = "".obs,
      updateAvailable = true.obs;
  var selectedChartMonth = DateTime.now().month.obs;
  var selectedChartYear = DateTime.now().year.obs;
  String countryDial = "+91";
  var isEyeOpen = false.obs,isLeftOpen=true.obs,isRightOpen=true.obs;
  RxInt selectedIndex = 100.obs,oldIndex=100.obs,selectedSettingsIndex = 0.obs;
  var isSettingsExpanded = false.obs;
  var isLeadsExpanded = false.obs;
  bool extended =false;
  RxString searchText = ''.obs;
  final RxString searchQuery = ''.obs,searchProspects = ''.obs,searchQualified = ''.obs,searchCustomers = ''.obs;
  Future<List<NewLeadObj>>? allCustomerFuture;
  Future<List<EmployeeObj>>? allEmployeeFuture;
  Future<List<ProductObj>>? allProductFuture;
  Future<CustomerFullDetails>? leadFuture;
  Future<List<CommentsObj>>? customCommentsFuture;
  Future<List<MailReceiveObj>>? customMailFuture;
  Future<List<NewLeadObj>>? allGoodLeadFuture;
  Future<List<CompanyObj>>? allCompanyFuture;
  var disqualifiedFuture     = <NewLeadObj>[].obs;
  var targetLeadsFuture      = <NewLeadObj>[].obs;
  var allNewLeadFuture       = <NewLeadObj>[].obs;
  var allRatingLeadFuture    = <NewLeadObj>[].obs;
  var allLeadFuture          = <NewLeadObj>[].obs;
  var allQualifiedLeadFuture = <NewLeadObj>[].obs;
  var allCustomerLeadFuture  = <NewLeadObj>[].obs;
  RxString selectedTemperature = "".obs;
  RxString selectedProspectTemperature = "".obs;
  RxString selectedQualifiedTemperature = "".obs;
  RxString selectedSortBy = "All".obs;
  RxString selectedProspectSortBy = "All".obs;
  RxString selectedQualifiedSortBy = "All".obs;
  RxString selectedCustomerSortBy = "All".obs;
  RxBool isMenuOpen = false.obs;
  var allLeads = <NewLeadObj>[].obs;
  final Rxn<DateTime> selectedMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedPMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedQPMonth = Rxn<DateTime>();
  final Rxn<DateTime> selectedCPMonth = Rxn<DateTime>();
  ButtonStyle? highlightCurrentMonth(DateTime month) {
    final now = DateTime.now();
    if (month.year == now.year && month.month == now.month) {
      return ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.green.shade700),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.green.shade700, width: 2.0),
          ),
        ),
      );
    }
    return null;
  }

  // void selectMonth(BuildContext context, RxString sortByKey, Rxn<DateTime> selectedMonthTarget) async {
  //   showMonthPicker(
  //     context: context,
  //     monthStylePredicate: (month) {
  //       final now = DateTime.now();
  //       if (month.month == now.month && month.year == now.year) {
  //         return ButtonStyle(
  //           foregroundColor: WidgetStateProperty.all(Colors.white),
  //           backgroundColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
  //         );
  //       } else {
  //         return ButtonStyle(
  //           foregroundColor: WidgetStateProperty.all(Colors.black),
  //           backgroundColor: WidgetStateProperty.all(Colors.transparent),
  //         );
  //       }
  //     },
  //     initialDate: selectedMonthTarget.value,
  //     firstDate: DateTime(2020),
  //       lastDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),//Santhiya
  //   ).then((selected) {
  //     if (selected != null) {
  //       sortByKey.value = 'Custom Month';
  //       selectedMonthTarget.value = selected;
  //     }
  //   });
  // }
  //Santhiya
  void selectMonth(
      BuildContext context,
      RxString sortByKey,
      Rxn<DateTime> selectedMonthTarget,
      RxList<NewLeadObj> list,
      RxList<NewLeadObj> list2
      ) {

    final now = DateTime.now();

    showMonthPicker(
      context: context,

      // ✅ Highlight current month
      monthStylePredicate: (month) {
        if (month.month == now.month && month.year == now.year) {
          return ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.white),
            backgroundColor:
            WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
          );
        }
        return null;
      },

      // ✅ Default open month
      initialDate: selectedMonthTarget.value ?? now,

      // ✅ Starting limit
      firstDate: DateTime(2020),

      // ✅ Allow full current month (Important)
      lastDate: DateTime(now.year, now.month + 1, 0),

    ).then((selected) {
      if (selected != null) {
        sortByKey.value = 'Custom Month';
        selectedMonthTarget.value = selected;
          DateTime? filterDate;

          print("Selected Month >>> ${controllers.selectedPMonth}");

          try {
            filterDate = DateTime.parse(controllers.selectedPMonth.toString());

            print("Filter Month >>> ${filterDate.month}");
            print("Filter Year >>> ${filterDate.year}");

          } catch (e) {
            filterDate = null;
            print("Parse error >>> $e");
          }

          final suggestions = list2.where((user) {

            DateTime createdDate =
            DateTime.parse(user.createdTs.toString());

            print("------------");
            print("User createdTs >>> ${user.createdTs}");

            if (filterDate != null) {
              bool match =
                  createdDate.month == filterDate.month &&
                      createdDate.year == filterDate.year;

              print("Match >>> $match");

              return match;
            }

            return true;
          }).toList();

          print("Filtered count >>> ${suggestions.length}");

          list.value = suggestions;
      }
    });
  }
  // void selectMonth(
  //     BuildContext context,
  //     RxString sortByKey,
  //     Rxn<DateTime> selectedMonthTarget,
  //     RxList<NewLeadObj> list,
  //     RxList<NewLeadObj> list2
  //     ) {
  //
  //   final now = DateTime.now();
  //
  //   showMonthPicker(
  //     context: context,
  //
  //     // ✅ Highlight current month
  //     monthStylePredicate: (month) {
  //       if (month.month == now.month && month.year == now.year) {
  //         return ButtonStyle(
  //           foregroundColor: WidgetStateProperty.all(Colors.white),
  //           backgroundColor:
  //           WidgetStateProperty.all(Colors.blue.withOpacity(0.2)),
  //         );
  //       }
  //       return null;
  //     },
  //
  //     // ✅ Default open month
  //     initialDate: selectedMonthTarget.value ?? now,
  //
  //     // ✅ Starting limit
  //     firstDate: DateTime(2020),
  //
  //     // ✅ Allow full current month (Important)
  //     lastDate: DateTime(now.year, now.month + 1, 0),
  //
  //   ).then((selected) {
  //     if (selected != null) {
  //       sortByKey.value = 'Custom Month';
  //       selectedMonthTarget.value = selected;
  //         DateTime? filterDate;
  //
  //         print("Selected Month >>> ${controllers.selectedPMonth}");
  //
  //         try {
  //           filterDate = DateTime.parse(controllers.selectedPMonth.toString());
  //
  //           print("Filter Month >>> ${filterDate.month}");
  //           print("Filter Year >>> ${filterDate.year}");
  //
  //         } catch (e) {
  //           filterDate = null;
  //           print("Parse error >>> $e");
  //         }
  //
  //         final suggestions = controllers.searchNewLeadList.where((user) {
  //
  //           DateTime createdDate =
  //           DateTime.parse(user.createdTs.toString());
  //
  //           print("------------");
  //           print("User createdTs >>> ${user.createdTs}");
  //
  //           if (filterDate != null) {
  //             bool match =
  //                 createdDate.month == filterDate.month &&
  //                     createdDate.year == filterDate.year;
  //
  //             print("Match >>> $match");
  //
  //             return match;
  //           }
  //
  //           return true;
  //         }).toList();
  //
  //         print("Filtered count >>> ${suggestions.length}");
  //
  //         controllers.newLeadList.value = suggestions;
  //     }
  //   });
  // }

  String formatDateTime(String inputDateTime) {
    DateTime dateTime;
    try {
      dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(inputDateTime);
    } catch (_) {
      try {
        dateTime = DateFormat('dd.MM.yyyy').parseStrict(inputDateTime);
      } catch (_) {
        try {
          dateTime = DateTime.parse(inputDateTime);
        } catch (_) {
          return 'Invalid date';
        }
      }
    }
    final hasTime = inputDateTime.contains(':');

    final outputFormat = hasTime ? DateFormat('yyyy-MM-dd hh:mm a') : DateFormat('yyyy-MM-dd');

    return outputFormat.format(dateTime.toLocal());
  }
  String formatDate(String inputDate) {
    try {
      String normalized = inputDate.replaceAll('.', '-');
      DateTime dateTime = DateFormat("dd-MM-yyyy h:mm a").parse(normalized);
      return DateFormat("dd MMM yyyy, h:mm a").format(dateTime);
    } catch (e) {
      return inputDate;
    }
  }
  // void setDateRange(PickerDateRange range,RxList<NewLeadObj> list,RxList<NewLeadObj> list2) {
  //   if (range.startDate != null && range.endDate != null) {
  //     selectedRange.value = DateTimeRange(
  //       start: range.startDate!,
  //       end: range.endDate!,
  //     );
  //
  //     print("Start Date >>> ${range.startDate}");
  //     print("End Date >>> ${range.endDate}");
  //
  //     final suggestions = list2.where((user) {
  //
  //       DateTime createdDate = DateTime.parse(user.createdTs.toString());
  //
  //       print("------------");
  //       print("User createdTs >>> ${user.createdTs}");
  //
  //       bool isInRange =
  //           createdDate.isAfter(range.startDate!.subtract(Duration(seconds: 1))) &&
  //               createdDate.isBefore(range.endDate!.add(Duration(days: 1)));
  //
  //       print("Range Match >>> $isInRange");
  //
  //       return isInRange;
  //
  //     }).toList();
  //
  //     print("Filtered count >>> ${suggestions.length}");
  //     list.value = suggestions;
  //   }
  // }
  void setDateRange(
      PickerDateRange range,
      RxList<NewLeadObj> list,
      RxList<NewLeadObj> list2) {

    if (range.startDate != null && range.endDate != null) {

      selectedRange.value = DateTimeRange(
        start: range.startDate!,
        end: range.endDate!,
      );

      print("Start Date >>> ${range.startDate}");
      print("End Date >>> ${range.endDate}");

      final suggestions = list2.where((user) {

        if (user.createdTs == null ||
            user.createdTs!.isEmpty ||
            user.createdTs == "null") {
          return false;
        }

        DateTime? createdDate = DateTime.tryParse(user.createdTs!);

        if (createdDate == null) return false;

        print("------------");
        print("User createdTs >>> ${user.createdTs}");

        bool isInRange =
            createdDate.isAfter(range.startDate!.subtract(const Duration(days: 1))) &&
                createdDate.isBefore(range.endDate!.add(const Duration(days: 1)));

        print("Range Match >>> $isInRange");

        return isInRange;

      }).toList();

      print("Filtered count >>> ${suggestions.length}");

      list.value = suggestions;
    }
  }
  void showDatePickerDialog(BuildContext context,RxString selectedSortBy,
      RxList<NewLeadObj> list,RxList<NewLeadObj> list2) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dynamic tempRange;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xffFFFCF9),
              title: const Text(
                'Select Date',
                style: TextStyle(
                  color: Color(0xFF004AAD),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                height: 300,
                width: 350,
                child: SfDateRangePicker(
                  backgroundColor: const Color(0xffFFFCF9),
                  minDate: DateTime(2023),
                  maxDate: DateTime.now(),
                  selectionMode: DateRangePickerSelectionMode.extendableRange,
                  selectionShape: DateRangePickerSelectionShape.circle,
                  selectionRadius: 18,
                  selectionColor: const Color(0xFF004AAD),
                  startRangeSelectionColor: const Color(0xFF004AAD),
                  endRangeSelectionColor: const Color(0xFF004AAD),
                  rangeSelectionColor: const Color(0x22004AAD),
                  monthCellStyle: const DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: 14,
                      height: 1.0,
                      color: Colors.black87,
                    ),
                  ),

                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    dayFormat: 'EEE',
                    viewHeaderHeight: 28,
                  ),
                  selectionTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.0, // fixes vertical centering of number inside circle
                  ),
                  onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      if (args.value is PickerDateRange) {
                        tempRange = args.value;
                      } else if (args.value is DateTime) {
                        tempRange = PickerDateRange(args.value, args.value);
                      }
                    });
                  },
                ),
              ),
              actions: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      'Click and drag to select multiple dates',
                      style: TextStyle(
                        color: Color(0xFF004AAD),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (tempRange != null) {
                          print("Selected Start Date >>> ${tempRange.startDate}");
                          print("Selected End Date >>> ${tempRange.endDate}");
                          DateTime start = tempRange.startDate;
                          DateTime end = tempRange.endDate ?? tempRange.startDate;

                          selectedSortBy.value = "";
                          setDateRange(PickerDateRange(start, end),list,list2);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color(0xFF004AAD),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  var currentPage = 1.obs;
  final itemsPerPage = 20; // Adjust based on your needs
  var currentProspectPage = 1.obs;
  final itemsProspectPerPage = 20;
  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  var disqualifiedSortField = ''.obs;
  var disqualifiedSortOrder = 'asc'.obs;
  var selectedRange = Rxn<DateTimeRange>();
  List<NewLeadObj> get paginatedDisqualified {
    final query = searchQuery.value.toLowerCase();
    final ratingFilter = selectedTemperature.value;
    final sortBy = selectedProspectSortBy.value; // 'Today', 'Last 7 Days', etc.
    final now = DateTime.now();
    final filteredLeads = disqualifiedFuture.where((lead) {
      final matchesQuery = (lead.firstname ?? '').toLowerCase().contains(query) ||
          (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
          (lead.companyName ?? '').toLowerCase().contains(query) ||
          (lead.email ?? '').toLowerCase().contains(query);

      final matchesRating = ratingFilter.isEmpty ||
          (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());

      bool matchesSort = true;

      if (lead.prospectEnrollmentDate != null) {
        DateTime? updatedDate;
        try {
          if (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty) {
            updatedDate = DateTime.tryParse(lead.updatedTs!);
          } else if (lead.prospectEnrollmentDate != null && lead.prospectEnrollmentDate!.isNotEmpty) {
            updatedDate = DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
          }
        } catch (_) {
          updatedDate = null;
          matchesSort = false;
        }

        if (updatedDate != null) {
          final diff = now.difference(updatedDate).inDays;

          switch (sortBy) {
            case 'Today':
              matchesSort = isSameDate(updatedDate, now);
              break;
            case 'Yesterday':
              matchesSort = diff <= 1;
              break;
            case 'Last 7 Days':
              matchesSort = diff <= 7;
              break;

            case 'Last 30 Days':
              matchesSort = diff <= 30;
              break;

            case 'Custom Month':
              if (selectedMonth.value != null) {
                matchesSort = updatedDate.year == selectedMonth.value!.year &&
                    updatedDate.month == selectedMonth.value!.month;
              } else {
                matchesSort = true;
              }
              break;

            case 'All':
            default:
              matchesSort = true;
          }
        } else {
          matchesSort = false;
        }
      } else {
        matchesSort = false;
      }

      return matchesQuery && matchesRating && matchesSort;
    }).toList();

    if (sortBy == 'Custom Month') {
      DateTime parseDate(String? dateStr, String? fallback) {
        if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
          dateStr = fallback;
        }
        DateTime? parsed;
        try {
          parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
        } catch (_) {
          parsed = DateTime.tryParse(dateStr!);
        }
        return parsed ?? DateTime(1900);
      }

      filteredLeads.sort((a, b) {
        final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
        final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
        return dateB.compareTo(dateA); // reverse order
      });
    }
    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();

            case 'company_name':
              return (lead.companyName ?? '').toLowerCase();

            case 'mobile_number':
              return (lead.mobileNumber ?? '').toLowerCase();

            case 'detailsOfServiceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();

            case 'source':
              return (lead.source ?? '').toLowerCase();

            case 'city':
              return (lead.city ?? '').toLowerCase();

            case 'status_update':
              return (lead.statusUpdate ?? '').toLowerCase();

            case 'updatedTs':
            case 'prospect_enrollment_date':
              DateTime parseDate(String? dateStr, String? fallback) {
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  dateStr = fallback;
                }
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  return DateTime(1900);
                }
                DateTime? parsed;
                try {
                  parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
                } catch (_) {
                  parsed = DateTime.tryParse(dateStr);
                }
                return parsed ?? DateTime(1900);
              }
              return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
            default:
            //final value = field;
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }
    int start = (currentPage.value - 1) * itemsPerPage;

    if (start >= filteredLeads.length) return [];

    int end = start + itemsPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;

    return filteredLeads.sublist(start, end);
  }

  var sortField = ''.obs;
  var sortOrder = 'asc'.obs;
  var sortOrderN = 'asc'.obs;
  var sortPField = ''.obs;
  var sortPOrder = 'asc'.obs;
  var sortQField = ''.obs;
  var sortQOrder = 'asc'.obs;

  List<NewLeadObj> get paginatedLeads {
    final query = searchQuery.value.toLowerCase();
    final ratingFilter = selectedTemperature.value;
    final sortBy = selectedProspectSortBy.value;
    final now = DateTime.now();

    final filteredLeads = allNewLeadFuture.where((lead) {
      final matchesQuery = query.isEmpty ||
          (lead.firstname?.toLowerCase().contains(query) ?? false) ||
          (lead.mobileNumber?.toLowerCase().contains(query) ?? false) ||
          (lead.companyName?.toLowerCase().contains(query) ?? false);

      final matchesRating = ratingFilter.isEmpty ||
          ((lead.rating ?? '').toLowerCase() == ratingFilter.toLowerCase());

      bool matchesSort = true;

      DateTime? updatedDate;
      if (lead.prospectEnrollmentDate != null ||
          (lead.updatedTs != null && lead.updatedTs!.isNotEmpty)) {
        try {
          if (lead.updatedTs != null &&
              lead.updatedTs != "null" &&
              lead.updatedTs!.isNotEmpty) {
            updatedDate = DateTime.tryParse(lead.updatedTs!);
          } else if (lead.prospectEnrollmentDate != null &&
              lead.prospectEnrollmentDate!.isNotEmpty) {
            updatedDate =
                DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
          }
        } catch (_) {
          updatedDate = null;
          matchesSort = false;
        }
      }
      if (updatedDate != null) {
        final diff = now.difference(updatedDate).inDays;
        switch (sortBy) {
          case 'Today':
            matchesSort = isSameDate(updatedDate, now);
            break;
          case 'Yesterday':
            matchesSort = diff == 1;
            break;
          case 'Last 7 Days':
            matchesSort = diff <= 7;
            break;
          case 'Last 30 Days':
            matchesSort = diff <= 30;
            break;
          case 'Custom Month':
            if (selectedMonth.value != null) {
              matchesSort = updatedDate.year == selectedMonth.value!.year &&
                  updatedDate.month == selectedMonth.value!.month;
            } else {
              matchesSort = true;
            }
            break;
          case 'All':
          default:
            matchesSort = true;
        }
        if (selectedRange.value != null) {
          final range = selectedRange.value!;
          final start = DateTime(range.start.year, range.start.month, range.start.day);
          final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
          matchesSort = matchesSort &&
              (updatedDate.isAfter(start) || updatedDate.isAtSameMomentAs(start)) &&
              (updatedDate.isBefore(end) || updatedDate.isAtSameMomentAs(end));
        }
      } else {
        matchesSort = false;
      }
      return matchesQuery && matchesRating && matchesSort;
    }).toList();
    if (sortBy == 'Custom Month') {
      DateTime parseDate(String? dateStr, String? fallback) {
        if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
          dateStr = fallback;
        }
        DateTime? parsed;
        try {
          parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
        } catch (_) {
          parsed = DateTime.tryParse(dateStr!);
        }
        return parsed ?? DateTime(1900);
      }

      filteredLeads.sort((a, b) {
        final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
        final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
        return dateB.compareTo(dateA); // reverse order
      });
    }
    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();
            case 'company_name':
              return (lead.companyName ?? '').toLowerCase();
            case 'mobile_number':
              return (lead.mobileNumber ?? '').toLowerCase();
            case 'detailsOfServiceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();
            case 'source':
              return (lead.source ?? '').toLowerCase();
            case 'city':
              return (lead.city ?? '').toLowerCase();
            case 'status_update':
              return (lead.statusUpdate ?? '').toLowerCase();
            case 'date':
            case 'prospect_enrollment_date':
              DateTime parseDate(String? dateStr, String? fallback) {
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  dateStr = fallback;
                }
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  return DateTime(1900);
                }
                DateTime? parsed;
                try {
                  parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
                } catch (_) {
                  parsed = DateTime.tryParse(dateStr);
                }
                return parsed ?? DateTime(1900);
              }
              return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
            default:
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }
    int start = (currentPage.value - 1) * itemsPerPage;
    if (start >= filteredLeads.length) return [];

    int end = start + itemsPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;

    return filteredLeads.sublist(start, end);
  }

  List<NewLeadObj> get paginatedRatingLeads {
    final query = searchQuery.value.toLowerCase();
    final ratingFilter = selectedTemperature.value;
    final sortBy = selectedProspectSortBy.value;
    final now = DateTime.now();

    final filteredLeads = allRatingLeadFuture.where((lead) {
      final matchesQuery = query.isEmpty ||
          (lead.firstname?.toLowerCase().contains(query) ?? false) ||
          (lead.mobileNumber?.toLowerCase().contains(query) ?? false) ||
          (lead.companyName?.toLowerCase().contains(query) ?? false);

      final matchesRating = ratingFilter.isEmpty ||
          ((lead.rating ?? '').toLowerCase() == ratingFilter.toLowerCase());

      bool matchesSort = true;

      DateTime? updatedDate;
      if (lead.prospectEnrollmentDate != null ||
          (lead.updatedTs != null && lead.updatedTs!.isNotEmpty)) {
        try {
          if (lead.updatedTs != null &&
              lead.updatedTs != "null" &&
              lead.updatedTs!.isNotEmpty) {
            updatedDate = DateTime.tryParse(lead.updatedTs!);
          } else if (lead.prospectEnrollmentDate != null &&
              lead.prospectEnrollmentDate!.isNotEmpty) {
            updatedDate =
                DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
          }
        } catch (_) {
          updatedDate = null;
          matchesSort = false;
        }
      }
      if (updatedDate != null) {
        final diff = now.difference(updatedDate).inDays;
        switch (sortBy) {
          case 'Today':
            matchesSort = isSameDate(updatedDate, now);
            break;
          case 'Yesterday':
            matchesSort = diff == 1;
            break;
          case 'Last 7 Days':
            matchesSort = diff <= 7;
            break;
          case 'Last 30 Days':
            matchesSort = diff <= 30;
            break;
          case 'Custom Month':
            if (selectedMonth.value != null) {
              matchesSort = updatedDate.year == selectedMonth.value!.year &&
                  updatedDate.month == selectedMonth.value!.month;
            } else {
              matchesSort = true;
            }
            break;
          case 'All':
          default:
            matchesSort = true;
        }
        if (selectedRange.value != null) {
          final range = selectedRange.value!;
          final start = DateTime(range.start.year, range.start.month, range.start.day);
          final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
          matchesSort = matchesSort &&
              (updatedDate.isAfter(start) || updatedDate.isAtSameMomentAs(start)) &&
              (updatedDate.isBefore(end) || updatedDate.isAtSameMomentAs(end));
        }
      } else {
        matchesSort = false;
      }
      return matchesQuery && matchesRating && matchesSort;
    }).toList();
    if (sortBy == 'Custom Month') {
      DateTime parseDate(String? dateStr, String? fallback) {
        if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
          dateStr = fallback;
        }
        DateTime? parsed;
        try {
          parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
        } catch (_) {
          parsed = DateTime.tryParse(dateStr!);
        }
        return parsed ?? DateTime(1900);
      }

      filteredLeads.sort((a, b) {
        final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
        final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
        return dateB.compareTo(dateA); // reverse order
      });
    }
    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();
            case 'company_name':
              return (lead.companyName ?? '').toLowerCase();
            case 'mobile_number':
              return (lead.mobileNumber ?? '').toLowerCase();
            case 'detailsOfServiceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();
            case 'source':
              return (lead.source ?? '').toLowerCase();
            case 'city':
              return (lead.city ?? '').toLowerCase();
            case 'status_update':
              return (lead.statusUpdate ?? '').toLowerCase();
            case 'date':
            case 'prospect_enrollment_date':
              DateTime parseDate(String? dateStr, String? fallback) {
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  dateStr = fallback;
                }
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  return DateTime(1900);
                }
                DateTime? parsed;
                try {
                  parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
                } catch (_) {
                  parsed = DateTime.tryParse(dateStr);
                }
                return parsed ?? DateTime(1900);
              }
              return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
            default:
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }
    int start = (currentPage.value - 1) * itemsPerPage;
    if (start >= filteredLeads.length) return [];

    int end = start + itemsPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;
    return filteredLeads.sublist(start, end);
  }

  final int mailPerPage = 100;

  List<String> get leadRanges {
    final totalCount = allNewLeadFuture.length; // total leads count
    if (totalCount == 0) return [];
    List<String> ranges = [];
    for (int i = 0; i < totalCount; i += mailPerPage) {
      final start = i + 1;
      final end = (i + mailPerPage) > totalCount ? totalCount : (i + mailPerPage);
      ranges.add("$start - $end");
    }
    return ranges;
  }
  List<String> get leadTargetRanges {
    final totalCount = targetLeadsFuture.length; // total leads count
    if (totalCount == 0) return [];
    List<String> ranges = [];
    for (int i = 0; i < totalCount; i += mailPerPage) {
      final start = i + 1;
      final end = (i + mailPerPage) > totalCount ? totalCount : (i + mailPerPage);
      ranges.add("$start - $end");
    }
    return ranges;
  }

  List<NewLeadObj> getLeadsByRange(int index) {
    final startIndex = index * mailPerPage;
    final endIndex = (startIndex + mailPerPage) > allNewLeadFuture.length
        ? allNewLeadFuture.length
        : startIndex + mailPerPage;

    return allNewLeadFuture.sublist(startIndex, endIndex);
  }

  List<NewLeadObj> get paginatedQualifiedLeads {
    final query = searchQualified.value.trim().toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedQualifiedSortBy.value; // 'Today', 'Last 7 Days', etc.
    final now = DateTime.now();

    final filteredLeads = allQualifiedLeadFuture.where((lead) {
      final matchesQuery = (lead.firstname ?? '').toLowerCase().contains(query) ||
          (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
          (lead.companyName ?? '').toLowerCase().contains(query) ||
          (lead.email ?? '').toLowerCase().contains(query);

      final matchesRating = ratingFilter.isEmpty ||
          (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());

      bool matchesSort = true;
      DateTime? updatedDate;

      if (lead.prospectEnrollmentDate != null) {
        try {
          if (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty) {
            updatedDate = DateTime.tryParse(lead.updatedTs!);
          } else if (lead.prospectEnrollmentDate != null && lead.prospectEnrollmentDate!.isNotEmpty) {
            updatedDate = DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
          }
        } catch (_) {
          updatedDate = null;
          matchesSort = false;
        }

        if (updatedDate != null) {
          final diff = now.difference(updatedDate).inDays;

          switch (sortBy) {
            case 'Today':
              matchesSort = isSameDate(updatedDate, now);
              break;
            case 'Yesterday':
              matchesSort = diff <= 1;
              break;
            case 'Last 7 Days':
              matchesSort = diff <= 7;
              break;
            case 'Last 30 Days':
              matchesSort = diff <= 30;
              break;
            case 'Custom Month':
              if (selectedPMonth.value != null) {
                matchesSort = updatedDate.year == selectedPMonth.value!.year &&
                    updatedDate.month == selectedPMonth.value!.month;
              } else {
                matchesSort = true;
              }
              break;
            case 'All':
            default:
              matchesSort = true;
          }
        } else {
          matchesSort = false;
        }
      } else {
        matchesSort = false;
      }

      // 🔹 Date Range Filter (selectedRange)
      bool matchesDateRange = true;
      if (selectedRange.value != null && updatedDate != null) {
        final start = selectedRange.value!.start;
        final end = selectedRange.value!.end;
        matchesDateRange = updatedDate.isAfter(start.subtract(const Duration(days: 1))) &&
            updatedDate.isBefore(end.add(const Duration(days: 1)));
      }

      return matchesQuery && matchesRating && matchesSort && matchesDateRange;
    }).toList();

    if (sortBy == 'Custom Month') {
      DateTime parseDate(String? dateStr, String? fallback) {
        if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
          dateStr = fallback;
        }
        DateTime? parsed;
        try {
          parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
        } catch (_) {
          parsed = DateTime.tryParse(dateStr!);
        }
        return parsed ?? DateTime(1900);
      }

      filteredLeads.sort((a, b) {
        final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
        final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
        return dateB.compareTo(dateA); // reverse order
      });
    }

    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();

            case 'company_name':
              return (lead.companyName ?? '').toLowerCase();

            case 'mobile_number':
              return (lead.mobileNumber ?? '').toLowerCase();

            case 'detailsOfServiceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();

            case 'source':
              return (lead.source ?? '').toLowerCase();

            case 'city':
              return (lead.city ?? '').toLowerCase();

            case 'status_update':
              return (lead.statusUpdate ?? '').toLowerCase();

            case 'updatedTs':
            case 'prospect_enrollment_date':
              DateTime parseDate(String? dateStr, String? fallback) {
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  dateStr = fallback;
                }
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  return DateTime(1900);
                }
                DateTime? parsed;
                try {
                  parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
                } catch (_) {
                  parsed = DateTime.tryParse(dateStr);
                }
                return parsed ?? DateTime(1900);
              }
              return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
            default:
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }

    int start = (currentProspectPage.value - 1) * itemsProspectPerPage;

    if (start >= filteredLeads.length) return [];

    int end = start + itemsProspectPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;

    return filteredLeads.sublist(start, end);
  }

  List<NewLeadObj> get paginatedCustomerLeads {
    final query = searchCustomers.value.trim().toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedCustomerSortBy.value;

    final now = DateTime.now();

    final filteredLeads = allCustomerLeadFuture.where((lead) {
      final matchesQuery = (lead.firstname ?? '').toLowerCase().contains(query) ||
          (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
          (lead.companyName ?? '').toLowerCase().contains(query) ||
          (lead.email ?? '').toLowerCase().contains(query);

      final matchesRating = ratingFilter.isEmpty ||
          (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());

      bool matchesSort = true;
      if (lead.prospectEnrollmentDate != null) {
        DateTime? updatedDate;
        try {
          if (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty) {
            updatedDate = DateTime.tryParse(lead.updatedTs!);
          } else if (lead.prospectEnrollmentDate != null && lead.prospectEnrollmentDate!.isNotEmpty) {
            updatedDate = DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
          }
        } catch (_) {
          updatedDate = null;
          matchesSort = false;
        }

        if (updatedDate != null) {
          final diff = now.difference(updatedDate).inDays;

          switch (sortBy) {
            case 'Today':
              matchesSort = isSameDate(updatedDate, now);
              break;
            case 'Yesterday':
              matchesSort = diff <= 1;
              break;
            case 'Last 7 Days':
              matchesSort = diff <= 7;
              break;
            case 'Last 30 Days':
              matchesSort = diff <= 30;
              break;

            case 'Custom Month':
              if (selectedQPMonth.value != null) {
                matchesSort = updatedDate.year == selectedQPMonth.value!.year &&
                    updatedDate.month == selectedQPMonth.value!.month;
              } else {
                matchesSort = true;
              }
              break;
            case 'All':
            default:
              matchesSort = true;
          }
        } else {
          matchesSort = false;
        }
      } else {
        matchesSort = false;
      }
      return matchesQuery && matchesRating && matchesSort;
    }).toList();

    if (sortBy == 'Custom Month') {
      DateTime parseDate(String? dateStr, String? fallback) {
        if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
          dateStr = fallback;
        }
        DateTime? parsed;
        try {
          parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
        } catch (_) {
          parsed = DateTime.tryParse(dateStr!);
        }
        return parsed ?? DateTime(1900);
      }
      filteredLeads.sort((a, b) {
        final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
        final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
        return dateB.compareTo(dateA); // reverse order
      });
    }
    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();

            case 'company_name':
              return (lead.companyName ?? '').toLowerCase();

            case 'mobile_number':
              return (lead.mobileNumber ?? '').toLowerCase();

            case 'detailsOfServiceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();

            case 'source':
              return (lead.source ?? '').toLowerCase();

            case 'city':
              return (lead.city ?? '').toLowerCase();

            case 'status_update':
              return (lead.statusUpdate ?? '').toLowerCase();

            case 'updatedTs':
            case 'prospect_enrollment_date':
              DateTime parseDate(String? dateStr, String? fallback) {
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  dateStr = fallback;
                }
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  return DateTime(1900);
                }
                DateTime? parsed;
                try {
                  parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
                } catch (_) {
                  parsed = DateTime.tryParse(dateStr);
                }
                return parsed ?? DateTime(1900);
              }
              return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
            default:
            //final value = field;
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }
    int start = (currentProspectPage.value - 1) * itemsProspectPerPage;

    if (start >= filteredLeads.length) return [];

    int end = start + itemsProspectPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;

    return filteredLeads.sublist(start, end);
  }

  List<NewLeadObj> get paginatedProspectsLeads {
    final query = searchProspects.value.toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedQualifiedSortBy.value;
    final now = DateTime.now();

    final filteredLeads = allLeadFuture.where((lead) {
      final matchesQuery =
          (lead.firstname ?? '').toLowerCase().contains(query) ||
              (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
              (lead.companyName ?? '').toLowerCase().contains(query) ||
              (lead.email ?? '').toLowerCase().contains(query);

      final matchesRating = ratingFilter.isEmpty ||
          (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());

      bool matchesSort = true;
      DateTime? updatedDate;

      if (lead.prospectEnrollmentDate != null) {
        try {
          if (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty) {
            updatedDate = DateTime.tryParse(lead.updatedTs!);
          } else if (lead.prospectEnrollmentDate != null && lead.prospectEnrollmentDate!.isNotEmpty) {
            updatedDate = DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
          }
        } catch (_) {
          updatedDate = null;
          matchesSort = false;
        }

        if (updatedDate != null) {
          final diff = now.difference(updatedDate).inDays;

          switch (sortBy) {
            case 'Today':
              matchesSort = isSameDate(updatedDate, now);
              break;
            case 'Yesterday':
              matchesSort = diff <= 1;
              break;
            case 'Last 7 Days':
              matchesSort = diff <= 7;
              break;
            case 'Last 30 Days':
              matchesSort = diff <= 30;
              break;
            case 'Custom Month':
              if (selectedPMonth.value != null) {
                matchesSort = updatedDate.year == selectedPMonth.value!.year &&
                    updatedDate.month == selectedPMonth.value!.month;
              } else {
                matchesSort = true;
              }
              break;
            case 'All':
            default:
              matchesSort = true;
          }
        } else {
          matchesSort = false;
        }
      } else {
        matchesSort = false;
      }

      // 🔹 Date Range Filter (selectedRange)
      bool matchesDateRange = true;
      if (selectedRange.value != null && updatedDate != null) {
        final start = selectedRange.value!.start;
        final end = selectedRange.value!.end;
        matchesDateRange = updatedDate.isAfter(start.subtract(const Duration(days: 1))) &&
            updatedDate.isBefore(end.add(const Duration(days: 1)));
      }

      return matchesQuery && matchesRating && matchesSort && matchesDateRange;
    }).toList();

    if (sortBy == 'Custom Month') {
      DateTime parseDate(String? dateStr, String? fallback) {
        if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
          dateStr = fallback;
        }
        DateTime? parsed;
        try {
          parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
        } catch (_) {
          parsed = DateTime.tryParse(dateStr!);
        }
        return parsed ?? DateTime(1900);
      }

      filteredLeads.sort((a, b) {
        final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
        final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
        return dateB.compareTo(dateA);
      });
    }

    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();
            case 'company_name':
              return (lead.companyName ?? '').toLowerCase();
            case 'mobile_number':
              return (lead.mobileNumber ?? '').toLowerCase();
            case 'detailsOfServiceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();
            case 'source':
              return (lead.source ?? '').toLowerCase();
            case 'city':
              return (lead.city ?? '').toLowerCase();
            case 'status_update':
              return (lead.statusUpdate ?? '').toLowerCase();
            case 'updatedTs':
            case 'prospect_enrollment_date':
              DateTime parseDate(String? dateStr, String? fallback) {
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  dateStr = fallback;
                }
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  return DateTime(1900);
                }
                DateTime? parsed;
                try {
                  parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
                } catch (_) {
                  parsed = DateTime.tryParse(dateStr);
                }
                return parsed ?? DateTime(1900);
              }
              return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
            default:
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }

    int start = (currentProspectPage.value - 1) * itemsProspectPerPage;
    if (start >= filteredLeads.length) return [];

    int end = start + itemsProspectPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;

    return filteredLeads.sublist(start, end);
  }

  // void selectRadio(){
  //   print("radioo");
  //   final query = searchProspects.value.toLowerCase();
  //   final ratingFilter = selectedProspectTemperature.value;
  //   final sortBy = selectedQualifiedSortBy.value;
  //   final now = DateTime.now();
  //
  //   final filteredLeads = newLeadList.where((lead) {
  //     final matchesQuery =
  //         (lead.firstname ?? '').toLowerCase().contains(query) ||
  //             (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
  //             (lead.companyName ?? '').toLowerCase().contains(query) ||
  //             (lead.email ?? '').toLowerCase().contains(query);
  //
  //     final matchesRating = ratingFilter.isEmpty ||
  //         (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());
  //
  //     bool matchesSort = true;
  //     DateTime? updatedDate;
  //
  //     if (lead.prospectEnrollmentDate != null) {
  //       try {
  //         if (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty) {
  //           updatedDate = DateTime.tryParse(lead.updatedTs!);
  //         } else if (lead.prospectEnrollmentDate != null && lead.prospectEnrollmentDate!.isNotEmpty) {
  //           updatedDate = DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
  //         }
  //       } catch (_) {
  //         updatedDate = null;
  //         matchesSort = false;
  //       }
  //
  //       if (updatedDate != null) {
  //         final diff = now.difference(updatedDate).inDays;
  //
  //         switch (sortBy) {
  //           case 'Today':
  //             matchesSort = isSameDate(updatedDate, now);
  //             break;
  //           case 'Yesterday':
  //             matchesSort = diff <= 1;
  //             break;
  //           case 'Last 7 Days':
  //             matchesSort = diff <= 7;
  //             break;
  //           case 'Last 30 Days':
  //             matchesSort = diff <= 30;
  //             break;
  //           case 'Custom Month':
  //             if (selectedPMonth.value != null) {
  //               matchesSort = updatedDate.year == selectedPMonth.value!.year &&
  //                   updatedDate.month == selectedPMonth.value!.month;
  //             } else {
  //               matchesSort = true;
  //             }
  //             break;
  //           case 'All':
  //           default:
  //             matchesSort = true;
  //         }
  //       } else {
  //         matchesSort = false;
  //       }
  //     } else {
  //       matchesSort = false;
  //     }
  //
  //     // 🔹 Date Range Filter (selectedRange)
  //     bool matchesDateRange = true;
  //     if (selectedRange.value != null && updatedDate != null) {
  //       final start = selectedRange.value!.start;
  //       final end = selectedRange.value!.end;
  //       matchesDateRange = updatedDate.isAfter(start.subtract(const Duration(days: 1))) &&
  //           updatedDate.isBefore(end.add(const Duration(days: 1)));
  //     }
  //
  //     return matchesQuery && matchesRating && matchesSort && matchesDateRange;
  //   }).toList();
  //
  //   if (sortBy == 'Custom Month') {
  //     DateTime parseDate(String? dateStr, String? fallback) {
  //       if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
  //         dateStr = fallback;
  //       }
  //       DateTime? parsed;
  //       try {
  //         parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
  //       } catch (_) {
  //         parsed = DateTime.tryParse(dateStr!);
  //       }
  //       return parsed ?? DateTime(1900);
  //     }
  //
  //     filteredLeads.sort((a, b) {
  //       final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
  //       final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
  //       return dateB.compareTo(dateA);
  //     });
  //   }
  //
  //   if (sortField.isNotEmpty) {
  //     filteredLeads.sort((a, b) {
  //       dynamic getFieldValue(NewLeadObj lead, String field) {
  //         switch (field) {
  //           case 'name':
  //             var name = lead.firstname ?? '';
  //             if (name.contains('||')) name = name.split('||')[0].trim();
  //             return name.toLowerCase();
  //           case 'company_name':
  //             return (lead.companyName ?? '').toLowerCase();
  //           case 'mobile_number':
  //             return (lead.mobileNumber ?? '').toLowerCase();
  //           case 'detailsOfServiceRequired':
  //             return (lead.detailsOfServiceRequired ?? '').toLowerCase();
  //           case 'source':
  //             return (lead.source ?? '').toLowerCase();
  //           case 'city':
  //             return (lead.city ?? '').toLowerCase();
  //           case 'status_update':
  //             return (lead.statusUpdate ?? '').toLowerCase();
  //           case 'updatedTs':
  //           case 'prospect_enrollment_date':
  //             DateTime parseDate(String? dateStr, String? fallback) {
  //               if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
  //                 dateStr = fallback;
  //               }
  //               if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
  //                 return DateTime(1900);
  //               }
  //               DateTime? parsed;
  //               try {
  //                 parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
  //               } catch (_) {
  //                 parsed = DateTime.tryParse(dateStr);
  //               }
  //               return parsed ?? DateTime(1900);
  //             }
  //             return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
  //           default:
  //             final value = lead.asMap()[field];
  //             return value.toString().toLowerCase();
  //         }
  //       }
  //
  //       final valA = getFieldValue(a, sortField.value);
  //       final valB = getFieldValue(b, sortField.value);
  //
  //       if (valA is DateTime && valB is DateTime) {
  //         return sortOrder.value == 'asc'
  //             ? valA.compareTo(valB)
  //             : valB.compareTo(valA);
  //       } else {
  //         return sortOrderN.value == 'asc'
  //             ? valA.compareTo(valB)
  //             : valB.compareTo(valA);
  //       }
  //     });
  //   }
  //
  //   int start = (currentProspectPage.value - 1) * itemsProspectPerPage;
  //   if (start >= filteredLeads.length) ;
  //
  //   int end = start + itemsProspectPerPage;
  //   end = end > filteredLeads.length ? filteredLeads.length : end;
  //
  //   controllers.newLeadList.value=filteredLeads.sublist(start, end);
  // }
  // void selectRadio(RxList<NewLeadObj> list,RxList<NewLeadObj> list2){
  //   isLead.value=false;
  //   print("radioo");
  //   final query = searchProspects.value.toLowerCase();
  //   final ratingFilter = selectedProspectTemperature.value;
  //   final sortBy = selectedQualifiedSortBy.value;
  //   final now = DateTime.now();
  //   print("radioo....${selectedQualifiedSortBy.value}");
  //
  //   final filteredLeads = list2.where((lead) {
  //     final matchesQuery =
  //         (lead.firstname ?? '').toLowerCase().contains(query) ||
  //             (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
  //             (lead.companyName ?? '').toLowerCase().contains(query) ||
  //             (lead.email ?? '').toLowerCase().contains(query);
  //
  //     final matchesRating = ratingFilter.isEmpty ||
  //         (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());
  //
  //     bool matchesSort = true;
  //     DateTime? updatedDate;
  //
  //     if (lead.prospectEnrollmentDate != null) {
  //       try {
  //         if (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty) {
  //           updatedDate = DateTime.tryParse(lead.updatedTs!);
  //         } else if (lead.prospectEnrollmentDate != null && lead.prospectEnrollmentDate!.isNotEmpty) {
  //           updatedDate = DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
  //         }
  //       } catch (_) {
  //         updatedDate = null;
  //         matchesSort = false;
  //       }
  //
  //       if (updatedDate != null) {
  //         final diff = now.difference(updatedDate).inDays;
  //
  //         switch (sortBy) {
  //           case 'Today':
  //             matchesSort = isSameDate(updatedDate, now);
  //             break;
  //           case 'Yesterday':
  //             matchesSort = diff <= 1;
  //             break;
  //           case 'Last 7 Days':
  //             matchesSort = diff <= 7;
  //             break;
  //           case 'Last 30 Days':
  //             matchesSort = diff <= 30;
  //             break;
  //           case 'Custom Month':
  //             if (selectedPMonth.value != null) {
  //               matchesSort = updatedDate.year == selectedPMonth.value!.year &&
  //                   updatedDate.month == selectedPMonth.value!.month;
  //             } else {
  //               matchesSort = true;
  //             }
  //             break;
  //           case 'All':
  //           default:
  //             matchesSort = true;
  //         }
  //       } else {
  //         matchesSort = false;
  //       }
  //     } else {
  //       matchesSort = false;
  //     }
  //
  //     // 🔹 Date Range Filter (selectedRange)
  //     bool matchesDateRange = true;
  //     if (selectedRange.value != null && updatedDate != null) {
  //       final start = selectedRange.value!.start;
  //       final end = selectedRange.value!.end;
  //       matchesDateRange = updatedDate.isAfter(start.subtract(const Duration(days: 1))) &&
  //           updatedDate.isBefore(end.add(const Duration(days: 1)));
  //     }
  //
  //     return matchesQuery && matchesRating && matchesSort && matchesDateRange;
  //   }).toList();
  //
  //   if (sortBy == 'Custom Month') {
  //     DateTime parseDate(String? dateStr, String? fallback) {
  //       if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
  //         dateStr = fallback;
  //       }
  //       DateTime? parsed;
  //       try {
  //         parsed = DateFormat('dd.MM.yyyy').tryParse(dateStr!);
  //       } catch (_) {
  //         parsed = DateTime.tryParse(dateStr!);
  //       }
  //       return parsed ?? DateTime(1900);
  //     }
  //
  //     filteredLeads.sort((a, b) {
  //       final dateA = parseDate(a.prospectEnrollmentDate, a.updatedTs);
  //       final dateB = parseDate(b.prospectEnrollmentDate, b.updatedTs);
  //       return dateB.compareTo(dateA);
  //     });
  //   }
  //
  //   if (sortField.isNotEmpty) {
  //     filteredLeads.sort((a, b) {
  //       dynamic getFieldValue(NewLeadObj lead, String field) {
  //         switch (field) {
  //           case 'name':
  //             var name = lead.firstname ?? '';
  //             if (name.contains('||')) name = name.split('||')[0].trim();
  //             return name.toLowerCase();
  //           case 'company_name':
  //             return (lead.companyName ?? '').toLowerCase();
  //           case 'mobile_number':
  //             return (lead.mobileNumber ?? '').toLowerCase();
  //           case 'detailsOfServiceRequired':
  //             return (lead.detailsOfServiceRequired ?? '').toLowerCase();
  //           case 'source':
  //             return (lead.source ?? '').toLowerCase();
  //           case 'city':
  //             return (lead.city ?? '').toLowerCase();
  //           case 'status_update':
  //             return (lead.statusUpdate ?? '').toLowerCase();
  //           case 'updatedTs':
  //           case 'prospect_enrollment_date':
  //             DateTime parseDate(String? dateStr, String? fallback) {
  //               if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
  //                 dateStr = fallback;
  //               }
  //               if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
  //                 return DateTime(1900);
  //               }
  //               DateTime? parsed;
  //               try {
  //                 parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
  //               } catch (_) {
  //                 parsed = DateTime.tryParse(dateStr);
  //               }
  //               return parsed ?? DateTime(1900);
  //             }
  //             return parseDate(lead.updatedTs, lead.prospectEnrollmentDate);
  //           default:
  //             final value = lead.asMap()[field];
  //             return value.toString().toLowerCase();
  //         }
  //       }
  //
  //       final valA = getFieldValue(a, sortField.value);
  //       final valB = getFieldValue(b, sortField.value);
  //
  //       if (valA is DateTime && valB is DateTime) {
  //         return sortOrder.value == 'asc'
  //             ? valA.compareTo(valB)
  //             : valB.compareTo(valA);
  //       } else {
  //         return sortOrderN.value == 'asc'
  //             ? valA.compareTo(valB)
  //             : valB.compareTo(valA);
  //       }
  //     });
  //   }
  //
  //   int start = (currentProspectPage.value - 1) * itemsProspectPerPage;
  //   if (start >= filteredLeads.length) ;
  //
  //   int end = start + itemsProspectPerPage;
  //   end = end > filteredLeads.length ? filteredLeads.length : end;
  //
  //   list.value=filteredLeads.sublist(start, end);
  //   // list.sort((a, b) {
  //   //   DateTime dateA = DateTime.tryParse(a.createdTs ?? '') ?? DateTime(1970);
  //   //   DateTime dateB = DateTime.tryParse(b.createdTs ?? '') ?? DateTime(1970);
  //   //   return dateB.compareTo(dateA);
  //   // });
  //   isLead.value=true;
  // }
  void selectRadio(RxList<NewLeadObj> list, RxList<NewLeadObj> list2) {
    isLead.value = false;

    final query = searchProspects.value.toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedQualifiedSortBy.value;
    final now = DateTime.now();

    DateTime? parseDate(String? updated, String? fallback) {
      try {
        if (updated != null && updated.isNotEmpty && updated != "null") {
          return DateTime.tryParse(updated);
        } else if (fallback != null && fallback.isNotEmpty) {
          return DateFormat('dd.MM.yyyy').tryParse(fallback);
        }
      } catch (_) {}
      return null;
    }

    final filteredLeads = list2.where((lead) {
      final matchesQuery =
          (lead.firstname ?? '').toLowerCase().contains(query) ||
              (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
              (lead.companyName ?? '').toLowerCase().contains(query) ||
              (lead.email ?? '').toLowerCase().contains(query);

      final matchesRating = ratingFilter.isEmpty ||
          (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());

      DateTime? updatedDate =
      parseDate(lead.updatedTs, lead.prospectEnrollmentDate);

      bool matchesSort = true;

      if (updatedDate != null) {
        final diff = now.difference(updatedDate).inDays;

        switch (sortBy) {
          case 'Today':
            matchesSort = updatedDate.year == now.year &&
                updatedDate.month == now.month &&
                updatedDate.day == now.day;
            break;

          case 'Yesterday':
            matchesSort = diff == 1;
            break;

          case 'Last 7 Days':
            matchesSort = diff <= 7;
            break;

          case 'Last 30 Days':
            matchesSort = diff <= 30;
            break;

          case 'Custom Month':
            if (selectedPMonth.value != null) {
              matchesSort = updatedDate.year == selectedPMonth.value!.year &&
                  updatedDate.month == selectedPMonth.value!.month;
            }
            break;

          case 'All':
          default:
            matchesSort = true;
        }
      }

      bool matchesDateRange = true;

      if (selectedRange.value != null && updatedDate != null) {
        final start = selectedRange.value!.start;
        final end = selectedRange.value!.end;

        matchesDateRange = updatedDate
            .isAfter(start.subtract(const Duration(days: 1))) &&
            updatedDate.isBefore(end.add(const Duration(days: 1)));
      }

      return matchesQuery && matchesRating && matchesSort && matchesDateRange;
    }).toList();

    /// 🔹 Default Date Sort (Latest First)
    filteredLeads.sort((a, b) {
      DateTime dateA =
          parseDate(a.updatedTs, a.prospectEnrollmentDate) ?? DateTime(1900);
      DateTime dateB =
          parseDate(b.updatedTs, b.prospectEnrollmentDate) ?? DateTime(1900);

      return dateB.compareTo(dateA);
    });

    /// 🔹 Column Sorting
    if (sortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) {
                name = name.split('||')[0].trim();
              }
              return name.toLowerCase();

            case 'company_name':
              return (lead.companyName ?? '').toLowerCase();

            case 'mobile_number':
              return (lead.mobileNumber ?? '').toLowerCase();

            case 'detailsOfServiceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();

            case 'source':
              return (lead.source ?? '').toLowerCase();

            case 'city':
              return (lead.city ?? '').toLowerCase();

            case 'status_update':
              return (lead.statusUpdate ?? '').toLowerCase();

            case 'updatedTs':
            case 'prospect_enrollment_date':
              return parseDate(
                  lead.updatedTs, lead.prospectEnrollmentDate) ??
                  DateTime(1900);

            default:
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }

    /// 🔹 Pagination
    int start = (currentProspectPage.value - 1) * itemsProspectPerPage;

    if (start >= filteredLeads.length) {
      start = 0;
    }

    int end = start + itemsProspectPerPage;

    if (end > filteredLeads.length) {
      end = filteredLeads.length;
    }

    list.value = filteredLeads.sublist(start, end);

    isLead.value = true;
  }
  var targetLeadSortField = ''.obs;
  var targetLeadSortOrder = 'asc'.obs;
  List<NewLeadObj> get paginatedTargetLead {
    final query = searchQuery.value.toLowerCase();
    final ratingFilter = selectedTemperature.value;
    final sortBy = selectedProspectSortBy.value;
    final now = DateTime.now();

    final filteredLeads = targetLeadsFuture.where((lead) {
      final matchesQuery = (lead.firstname ?? '').toLowerCase().contains(query) ||
          (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
          (lead.companyName ?? '').toLowerCase().contains(query);

      final matchesRating = ratingFilter.isEmpty ||
          (lead.rating?.toLowerCase() == ratingFilter.toLowerCase());

      bool matchesSort = true;
      DateTime? updatedDate;

      if (lead.prospectEnrollmentDate != null ||
          (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty)) {
        try {
          if (lead.updatedTs != null && lead.updatedTs != "null" && lead.updatedTs!.isNotEmpty) {
            updatedDate = DateTime.tryParse(lead.updatedTs!);
          } else if (lead.prospectEnrollmentDate != null && lead.prospectEnrollmentDate!.isNotEmpty) {
            updatedDate = DateFormat('dd.MM.yyyy').parse(lead.prospectEnrollmentDate!);
          }
        } catch (_) {
          updatedDate = null;
          matchesSort = false;
        }

        if (updatedDate != null) {
          final diff = now.difference(updatedDate).inDays;

          switch (sortBy) {
            case 'Today':
              matchesSort = isSameDate(updatedDate, now);
              break;
            case 'Yesterday':
              matchesSort = diff <= 1;
              break;
            case 'Last 7 Days':
              matchesSort = diff <= 7;
              break;
            case 'Last 30 Days':
              matchesSort = diff <= 30;
              break;
            case 'Custom Month':
              if (selectedMonth.value != null) {
                matchesSort = updatedDate.year == selectedMonth.value!.year &&
                    updatedDate.month == selectedMonth.value!.month;
              } else {
                matchesSort = true;
              }
              break;
            case 'All':
            default:
              matchesSort = true;
          }
        } else {
          matchesSort = false;
        }
      } else {
        matchesSort = false;
      }
      bool matchesDateRange = true;
      if (selectedRange.value != null && updatedDate != null) {
        final start = selectedRange.value!.start;
        final end = selectedRange.value!.end;
        matchesDateRange = updatedDate.isAfter(start.subtract(const Duration(days: 1))) &&
            updatedDate.isBefore(end.add(const Duration(days: 1)));
      }

      return matchesQuery && matchesRating && matchesSort && matchesDateRange;
    }).toList();

    if (targetLeadSortField.isNotEmpty) {
      filteredLeads.sort((a, b) {
        dynamic getFieldValue(NewLeadObj lead, String field) {
          switch (field) {
            case 'name':
              var name = lead.firstname ?? '';
              if (name.contains('||')) name = name.split('||')[0].trim();
              return name.toLowerCase();
            case 'companyName':
              return (lead.companyName ?? '').toLowerCase();
            case 'mobile':
              return (lead.mobileNumber ?? '').toLowerCase();
            case 'serviceRequired':
              return (lead.detailsOfServiceRequired ?? '').toLowerCase();
            case 'sourceOfProspect':
              return (lead.source ?? '').toLowerCase();
            case 'city':
              return (lead.city ?? '').toLowerCase();
            case 'statusUpdate':
              return (lead.statusUpdate ?? '').toLowerCase();
            case 'date':
              DateTime parseDate(String? dateStr, String? fallback) {
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  dateStr = fallback;
                }
                if (dateStr == null || dateStr.isEmpty || dateStr == "null") {
                  return DateTime(1900);
                }
                DateTime? parsed;
                try {
                  parsed = DateFormat('dd.MM.yyyy').parse(dateStr);
                } catch (_) {
                  parsed = DateTime.tryParse(dateStr);
                }
                return parsed ?? DateTime(1900);
              }

              return parseDate(lead.updatedTs,lead.prospectEnrollmentDate);
            default:
              final value = lead.asMap()[field];
              return value.toString().toLowerCase();
          }
        }

        final valA = getFieldValue(a, sortField.value);
        final valB = getFieldValue(b, sortField.value);

        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          return sortOrderN.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        }
      });
    }

    int start = (currentPage.value - 1) * itemsPerPage;
    if (start >= filteredLeads.length) return [];

    int end = start + itemsPerPage;
    end = end > filteredLeads.length ? filteredLeads.length : end;

    return filteredLeads.sublist(start, end);
  }


  int get totalPages => (allNewLeadFuture.length / itemsPerPage).ceil();
  int get totalProspectPages => (allLeadFuture.length / itemsPerPage).ceil();

  final groupController = GroupButtonController();
  final RoundedLoadingButtonController btnController = RoundedLoadingButtonController();
  final ScrollController suspectsScrollController = ScrollController();
  final ScrollController prospectsScrollController = ScrollController();
  final ScrollController qualifiedScrollController = ScrollController();

  var ratingLis = ["Cold", "Warm", "Hot"];
  var directVisit = "".obs,
      telephoneCalls = "".obs,
      allDirectVisit = "0".obs,

      allTelephoneCalls = "0".obs,
      allSentMails = "0".obs,
      allOpenedMails = "0".obs,
      allReplyMails = "0".obs,
      allIncomingCalls = "0".obs,
      allOutgoingCalls = "0".obs,
      allCalls = "0".obs,
      allMissedCalls = "0".obs,
      allScheduleMeet = "0".obs,
      allCompletedMeet = "0".obs,
      allCancelled = "0".obs,serverSheet = "0".obs,
      shortBy = "All".obs,
      isCommentsLoading = true.obs,isSent = false.obs,isOpened= false.obs,isReplied = false.obs,isMailLoading = false.obs,isIncoming = false.obs,isOutgoing= false.obs,isMissed = false.obs,isCallLoading = false.obs;
  var roleNameList    = [];
  var callNameList    = ["Visit","Call","Email","Appointment","Note"];
  var customers       = <AllCustomersObj>[].obs;
  var employees       = <AllEmployeesObj>[].obs;
  var callActivity    = <CustomerActivity>[].obs;
  var mailActivity    = <CustomerActivity>[].obs;
  var meetingActivity = <MeetingObj>[].obs;
  var noteActivity    = <CustomerActivity>[].obs;
  var fields          = <CustomerField>[].obs;
  var headingFields   = <String>[].obs;
  final defaultFields = [
    {"id": "1", "system_field": "name", "user_heading": "Name", "is_required": "1"},
    {"id": "8", "system_field": "company_name", "user_heading": "Company Name", "is_required": "1"},
    {"id": "2", "system_field": "mobile_number", "user_heading": "Mobile Number", "is_required": "1"},
    {"id": "14", "system_field": "details_of_service_required", "user_heading": "DETAILS OF SERVICES REQUIRED", "is_required": "1"},
    {"id": "9", "system_field": "source", "user_heading": "SOURCE OF PROSPECT", "is_required": "1"},
    {"id": "12", "system_field": "prospect_enrollment_date", "user_heading": "PROSPECT ENROLLMENT DATE", "is_required": "1"},
    {"id": "4", "system_field": "city", "user_heading": "City", "is_required": "1"},
    {"id": "18", "system_field": "status_update", "user_heading": "STATUS UPDATE", "is_required": "1"},
    {"id": "3", "system_field": "email", "user_heading": "Email", "is_required": "1"},
    {"id": "5", "system_field": "owner", "user_heading": "AC Manager", "is_required": "1"},
    {"id": "6", "system_field": "designation", "user_heading": "designation", "is_required": "1"},
    {"id": "7", "system_field": "department", "user_heading": "department", "is_required": "1"},
    {"id": "10", "system_field": "source_details", "user_heading": "PROSPECT SOURCE DETAILS", "is_required": "1"},
    {"id": "11", "system_field": "lead_status", "user_heading": "LEAD / PROSPECT", "is_required": "1"},
    {"id": "13", "system_field": "expected_convertion_date", "user_heading": "EXPECTED CONVERSION DATE", "is_required": "1"},
    {"id": "15", "system_field": "discussion_point", "user_heading": "DISCUSSION POINTS", "is_required": "1"},
    {"id": "16", "system_field": "product_discussion", "user_heading": "PRODUCT DISCUSSION", "is_required": "1"},
    {"id": "17", "system_field": "rating", "user_heading": "PROSPECT GRADING / RATING", "is_required": "1"},
    {"id": "19", "system_field": "status", "user_heading": "CURRENT STATUS", "is_required": "1"},
    {"id": "20", "system_field": "num_of_headcount", "user_heading": "TOTAL NUMBER OF HEAD COUNT", "is_required": "1"},
    {"id": "21", "system_field": "expected_billing_value", "user_heading": "EXPECTED BILLING VALUE", "is_required": "1"},
    {"id": "22", "system_field": "arpu_value", "user_heading": "ARPU VALUE", "is_required": "1"},
    {"id": "23", "system_field": "phone_no", "user_heading": "Phone", "is_required": "1"},
  ];

  String formatHeading(String heading) {

    String cleaned = heading.replaceAll(",", "").trim();
    return cleaned
        .split(" ")
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : "")
        .join(" ");
  }



  // String? getUserHeading(String systemField) {
  //   try {
  //     debugPrint('.....${fields}');
  //     return fields.firstWhere((f) => f.systemField == systemField).userHeading;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  String? getUserHeading(String systemField) {
    try {
      if (fields.isEmpty) return null;

      for (var f in fields) {
        if (f.systemField == systemField) {
          return f.userHeading;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }


  List<CustomerActivity> get filteredList {
    if (controllers.selectCallType.value.isEmpty) {
      return controllers.callActivity;
    }
    return controllers.callActivity
        .where((activity) => activity.callType == controllers.selectCallType.value)
        .toList();
  }

  void selectCustomer(AllCustomersObj c) {
    selectedCustomerId.value = c.id;
    selectedCustomerName.value = c.name;
    selectedCustomerMobile.value = c.phoneNo;
    selectedCustomerEmail.value = c.email;
    selectedCompanyName.value = c.companyName;
  }
  void selectNCustomer(String id, String name, String email, String mobile) {
    selectedCustomerId.value = id;
    selectedCustomerName.value = name;
    selectedCustomerEmail.value = email;
    selectedCustomerMobile.value = mobile;
    cusController.text = "$name - $mobile";
  }

  void clearSelectedCustomer() {
    selectedCustomerId.value = '';
    selectedCustomerName.value = '';
    selectedCustomerMobile.value = '';
    selectedCustomerEmail.value = '';
    selectedCompanyName.value = '';
    controllers.cusController.clear();
  }

  void selectEmployee(AllEmployeesObj c) {
    selectedEmployeeId.value = c.id;
    selectedEmployeeName.value = c.name;
    selectedEmployeeMobile.value = c.phoneNo;
    selectedEmployeeEmail.value = c.email;
  }
  void selectNEmployee(String id, String name,String mobile) {
    selectedEmployeeId.value = id;
    selectedEmployeeName.value = name;
    selectedEmployeeMobile.value = mobile;
    selectedEmployeeEmail.value = "";
    empController.text = "$name - $mobile";
  }

  void clearSelectedEmployee() {
    selectedEmployeeId.value = '';
    selectedEmployeeName.value = '';
    selectedEmployeeMobile.value = '';
    selectedEmployeeEmail.value = '';
    controllers.empController.clear();
  }

  RxString selectedCustomerId = ''.obs;
  RxString selectedCustomerName = ''.obs;
  RxString selectedCustomerMobile = ''.obs;
  RxString selectedCustomerEmail = ''.obs;
  RxString selectedCompanyName = ''.obs;

  RxString selectedEmployeeId = ''.obs;
  RxString selectedEmployeeName = ''.obs;
  RxString selectedEmployeeMobile = ''.obs;
  RxString selectedEmployeeEmail = ''.obs;

  TextEditingController cusController   = TextEditingController();
  TextEditingController empController   = TextEditingController();
  TextEditingController callCommentCont = TextEditingController();
  TextEditingController upCallCommentCont = TextEditingController();
  var roleList = [].obs;
  var stDate = "${DateTime.now().day.toString().padLeft(2, "0")}"
          "-${DateTime.now().month.toString().padLeft(2, "0")}"
          "-${DateTime.now().year.toString()}"
      .obs;
//var callList=["Order Follow - up","Payment Follow - up","Cold Calling","Self generated Leads","Reference Leads","Service Call"];
  var callListC = [
    "Order Follow - up",
    "Payment Follow - up",
    "Cold Calling",
    "Self generated Leads",
    "Reference Leads",
    "Service Call"
  ];
  RxList callList = [{"category":"Visit Call Type","id":"6","value":"Visit"},{"category":"Visit Call Type","id":"7","value":"Call"},{"category":"Visit Call Type","id":"8","value":"Email"},{"category":"Visit Call Type","id":"9","value":"Meeting"},{"category":"Visit Call Type","id":"10","value":"Note"},{"category":"Visit Call Type","id":"11","value":"Appointment"}].obs;
  var quotationStatus = ["Normal", "Urgent", "Critical"];
  var categoryList = ["BUILDING / APARTMENTS", "INDUSTRIES", "CORPORATES"];
  var statusList = ["Qualified", "UnQualified", "Nurturing", "Contacted"];

  var industryList = [
    "Manufacturing",
    "HealthCare",
    "Retail",
    "Financial Services",
    "Education",
    "Information Technology",
    "Entertainment",
    "Tourism & Hospitality",
    "Real Estate",
    "Transportation & Logistics",
    "Agriculture",
    "Construction",
    "Energy & Utilities",
    "Telecommunications",
    "Media & Advertising",
    "Automotive",
    "Pharmaceuticals & Biotechnology",
    "Government & Public Sector",
    "Non-Profit & NGOs",
    "Food & Beverages",
    "Fashion & Apparel",
    "E-Commerce",
    "Sports & Recreation",
  ];

  var callTypeList = [
    "Outgoing",
    "Incoming",
    "Missed"
  ];
  var callStatusList = [
    "Completed",
    "Pending",
    "Missed"
  ];
  // var hCallStatusList = [
  //   "Contacted",
  //   "Call back",
  //   "Demo Scheduled",
  //   "Not Interested"
  // ];
  RxList<Map<String, dynamic>> hCallStatusList =
      <Map<String, dynamic>>[].obs;

  Future<void> getCallStatus() async {
    try {

      hCallStatusList.clear();

      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "add_values",
        }),
      );

      // print("STATUS CODE add_values: ${response.statusCode}");
      // print("RAW RESPONSE: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getCallStatus();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode != 200) {
        // print("SERVER ERROR");
        return;
      }

      final decoded = jsonDecode(response.body);

      // ✅ Safety check
      if (decoded["status"] == "success" && decoded["data"] != null) {

        List<Map<String, dynamic>> list =
        List<Map<String, dynamic>>.from(decoded["data"]);

        // ✅ Store into RxList
        hCallStatusList.assignAll(list);

        // print("Loaded Items: ${hCallStatusList.length}");

      } else {
        // print("API Error: ${decoded["message"]}");
      }
    } catch (e) {
      // print("FLUTTER ERROR => $e");
    }
  }

  RxList<Map<String, dynamic>> rangeStatusList =
      <Map<String, dynamic>>[].obs;
  List<double> updates=[];
  List<double> mails=[];
  List<double> calls=[];
  List<String> xLabels=[];
  Future<void> getRangeStatus() async {
    try {

      rangeStatusList.clear();
      Map data = {
        "action": "get_data",
        "search_type": "range_report",
        "id": controllers.storage.read("id"),
        "role": controllers.storage.read("role"),
        "date": controllers.storage.read("role"),
        "cos_id": controllers.storage.read("cos_id"),
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));

      print("STATUS CODE range_report: ${request.statusCode}");
      print("RAW RESPONSE: ${data}");
      print("RAW RESPONSE: ${request.body}");
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getRangeStatus();
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode != 200) {
        // print("SERVER ERROR");
        return;
      }

      final decoded = jsonDecode(request.body);

      // ✅ Safety check
      if (request.statusCode==200) {
        var decoded = json.decode(request.body);

        if (decoded is List) {
          rangeStatusList.value =
          List<Map<String, dynamic>>.from(decoded);
          xLabels =
          rangeStatusList.value .map((e) => e["report_date"].toString()).toList();
          calls = rangeStatusList.value
              .map((e) => double.parse(e["total_calls"].toString()))
              .toList();

          mails = rangeStatusList.value
              .map((e) => double.parse(e["total_mails"].toString()))
              .toList();

           updates = rangeStatusList.value
              .map((e) => double.parse(e["total_customers"].toString()))
              .toList();
        } else {
          print("Unexpected format");
        }

        print("rangeStatusList Items: ${rangeStatusList.length}");

      } else {
        print("API Error: ${decoded["message"]}");
      }

    } catch (e) {
      print("FLUTTER ERROR => $e");
    }
  }

  RxList<Map<String, dynamic>> industriesList =
      <Map<String, dynamic>>[].obs;
var refreshValue=true.obs;
  Future<void> getIndustries() async {
    try {
      refreshValue.value=false;
      industriesList.clear();

      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "action": "add_industry",
        }),
      );

      // print("STATUS CODE add_values: ${response.statusCode}");
      // print("RAW RESPONSE: ${response.body}");
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return getIndustries();
        } else {
          controllers.setLogOut();
        }
      }
      if (response.statusCode != 200) {
        // print("SERVER ERROR");
        return;
      }

      final decoded = jsonDecode(response.body);

      // ✅ Safety check
      if (decoded["status"] == "success" && decoded["data"] != null) {

        List<Map<String, dynamic>> list =
        List<Map<String, dynamic>>.from(decoded["data"]);

        // ✅ Store into RxList
        industriesList.assignAll(list);
        refreshValue.value=true;
        print("Loaded Items: ${industriesList}");

      } else {
        refreshValue.value=true;
        print("API Error: ${decoded["message"]}");
      }

    } catch (e) {
      refreshValue.value=true;
      print("FLUTTER ERROR => $e");
    }
  }

  var stateList = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh ",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttarakhand",
    "West Bengal",
    "Uttar Pradesh",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman & Diu",
    "Delhi NCT",
    "Jammu & Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry"
  ];

  final FocusNode focusNode = FocusNode();

  var storage = GetStorage();
  var isAdd = false.obs;
  var isCoAdd = false.obs;
  RxString employeeHeading = "Employee Information".obs,
      le = "Employee Information".obs,
      attachmentImage = "".obs;
  String selectedGender = 'Male',
      selectedMarital = 'Single',
      selectedRelationShip = 'Spouse',
      selectedRating = "Warm";
  RxList contacts = [].obs;
  List<String?> allCities = [];
  List<String?> allCountry = [];
  List<String?> allStates = [];
  var allLeadsLength = 0.obs,
      allNewLeadsLength = 0.obs,
      allDisqualifiedLength=0.obs,
      allGoodLeadsLength = 0.obs,
      allCompanyLength = 0.obs,
      allCustomerLength = 0.obs,
      allTargetLength=0.obs,
      allProductLength = 0.obs,
      allEmployeeLength = 0.obs, selectCallType = "All".obs,selectMeetingType = "".obs;

  var states,
      upState,
      upCoState,
      category,
      source,
      status,
      rating,
      industry,
      callType="Outgoing",
      callStatus="",
      upCallType="Incoming",
      upcallStatus="Completed",
      visitType,
      qStatus,
      coIndustry,
      benefits,
      department,
      position,
      employeeType,
      emState,
      cusState,
      cusFieldOfficer,
      subCategory,
      tax,
      topProduct,
      service,
      coState,
      designation,
      role,
      pinCode,
      roleId;

  String leadCategory = "Suspects";
  RxList<bool> editMode = <bool>[].obs;
  RxList<LeadStatusModel> leadCategoryList = <LeadStatusModel>[].obs;
  RxList<LeadStatusModel> allLeadCategoryList = <LeadStatusModel>[].obs;
  // RxList leadCategoryList = [
  //   {"lead_status": "1", "value": "Suspects","id" : "1"},
  //   {"lead_status": "2", "value": "Prospects","id" : "2"},
  //   {"lead_status": "3", "value": "Qualified","id" : "3"},
  //   {"lead_status": "4", "value": "Customers","id" : "4"},
  //   {"lead_status": "0", "value": "Target Leads","id" : "5"},
  //   {"lead_status": "5", "value": "No Matches","id" : "6"}].obs;

  RxList leadCategoryGrList = [].obs;
  List eventImages = [
    "assets/image/event_logo1.jpeg",
    "assets/image/event_logo2.jpeg",
    "assets/image/itinerary2.jpeg",
    "assets/image/itinerary1.jpeg"
  ];
var otp = "".obs;
  Future<List>? imageListFuture;
  late List<String> userdata = [];
  List contactsID = [];
  var allCate = [];
  List attendanceMark = [];
  var emailCount = 0.obs;
  var isTemplate = false.obs,
      isAllSelected = false.obs,
      isLeadLoading = false.obs;

  var idList = [].obs,dateList = [].obs,
      isMainPersonList = [].obs,
      isNewLeadList = [].obs,isDisqualifiedList=[].obs,isCustomerList=[].obs,isTargetLeadList=[].obs,allLeadList=<NewLeadObj>[].obs,newLeadList=<NewLeadObj>[].obs,searchNewLeadList=<NewLeadObj>[].obs,
      isLeadsList = [].obs,
      isGoodLeadList = [].obs,
      isCoMobileNumberList = [].obs,
      mailReceivesList = [].obs;
  var empName = "".obs,
      empId = "".obs,
      empEmail = "".obs,
      empPhone = "".obs,
      empDOB = "".obs,
      upDate = "".obs,
      exDate = "".obs,
      prospectDate = "".obs,
      fDate = "".obs,
      toDate = "".obs,
      callTime = "".obs,
      upCallTime = "".obs,
      fTime = "".obs,
      toTime = "".obs,
      leadDOR = "".obs,
      empDoorNo = "".obs,
      empStreet = "".obs,
      empArea = "".obs,
      empCity = "".obs,
      empCountry = "".obs,
      empPinCode = "".obs,
      empDOJ = "".obs,
      empManagerName = "".obs,
      empSalary = "".obs,
      empBonus = "".obs,
      empDegree = "".obs,
      empInstitution = "".obs,
      empGraYear = "".obs;
  var isMainPerson = false.obs,
      light = false.obs,
      isImageLoaded = false.obs,
      isLead = true.obs,
      isCustomer = true.obs,
      isProduct = true.obs,
      isEmployee = true.obs;
  var lng = 0.0.obs, lat = 0.0.obs;
  var isMobileNumber = false.obs,
      isCoMobileNumber = true.obs,
      isProfileBasicInfo = false.obs,
      isEventLoaded = false.obs,
      isWhatsApp = false.obs;
  var cate = "", cateDes = "", categoryId = "", cateId = "";

  ScrollController scrollController = ScrollController();
  TextEditingController loginNumber = TextEditingController();
  TextEditingController loginPassword = TextEditingController();
  TextEditingController signFirstName = TextEditingController();
  TextEditingController signLastName = TextEditingController();
  TextEditingController signMobileNumber = TextEditingController();
  TextEditingController signemail = TextEditingController();
  TextEditingController signWhatsappNumber = TextEditingController();
  TextEditingController signPassword = TextEditingController();
  TextEditingController signReferBy = TextEditingController();

  // TODO: leadControllersName
  TextEditingController signupPasswordController = TextEditingController();
  List<TextEditingController> leadNameCrt = <TextEditingController>[TextEditingController()].obs;
  List<TextEditingController> leadMobileCrt = <TextEditingController>[TextEditingController()].obs;
  List<TextEditingController> leadWhatsCrt = <TextEditingController>[TextEditingController()].obs;
  List<TextEditingController> leadEmailCrt = <TextEditingController>[TextEditingController()].obs;
  List<TextEditingController> leadTitleCrt = <TextEditingController>[TextEditingController()].obs;
  List<TextEditingController> leadFieldName = <TextEditingController>[];
  List<TextEditingController> leadFieldValue = <TextEditingController>[];
  //TextEditingController leadNameCrt = TextEditingController();
  TextEditingController leadOwnerNameCrt = TextEditingController();
  TextEditingController leadSourceCrt = TextEditingController();
  TextEditingController leadGstNumCrt = TextEditingController();
  TextEditingController leadGstLocationCrt = TextEditingController();
  TextEditingController leadGstDORCrt = TextEditingController();
  TextEditingController leadDisPointsCrt = TextEditingController();
  TextEditingController throughBy = TextEditingController();
  TextEditingController leadPointsCrt = TextEditingController();
  // TextEditingController leadWhatsCrt = TextEditingController();
  TextEditingController leadCoNameCrt = TextEditingController();
  TextEditingController leadCoMobileCrt = TextEditingController();
  TextEditingController leadCoEmailCrt = TextEditingController();
  TextEditingController leadInduCrt = TextEditingController();
  TextEditingController leadWebsite = TextEditingController();
  TextEditingController meetingTitleCrt = TextEditingController();
  TextEditingController meetingVenueCrt = TextEditingController();
  TextEditingController leadProduct = TextEditingController();
  TextEditingController leadActions = TextEditingController();
  //TextEditingController leadNotes = TextEditingController();
  TextEditingController leadSecondaryEmailCrt = TextEditingController();
  TextEditingController sourceCrt = TextEditingController();
  TextEditingController prospectGradingCrt = TextEditingController();
  TextEditingController statusCrt = TextEditingController();
  TextEditingController budgetCrt = TextEditingController();
  TextEditingController pDiscussedCrt = TextEditingController();
  TextEditingController exMonthBillingValCrt = TextEditingController();
  TextEditingController noOfHeadCountCrt = TextEditingController();
  TextEditingController additionalNotesCrt = TextEditingController();
  TextEditingController responsePriCrt = TextEditingController();
  TextEditingController arpuCrt = TextEditingController();
  TextEditingController expectedConversionDateCrt = TextEditingController();
  TextEditingController prospectEnrollmentDateCrt = TextEditingController();
  TextEditingController leadXCrt = TextEditingController();
  TextEditingController leadLinkedinCrt = TextEditingController();
  TextEditingController doorNumberController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController industryValueCtr = TextEditingController();
  TextEditingController countryController =
      TextEditingController(text: "India");
  TextEditingController leadTime = TextEditingController();
  TextEditingController leadDescription = TextEditingController();
  TextEditingController dateOfConCtr = TextEditingController();
  TextEditingController timeOfConCtr = TextEditingController();
  TextEditingController emailToCtr = TextEditingController();
  TextEditingController emailSubjectCtr = TextEditingController();
  TextEditingController emailMessageCtr = TextEditingController();
  TextEditingController emailQuotationCtr = TextEditingController();
  TextEditingController statusController = TextEditingController();

  // TODO: productControllersName
  TextEditingController prodNameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController comparePriceController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController netPriceController = TextEditingController();
  TextEditingController hsnController = TextEditingController();
  TextEditingController prodBrandController = TextEditingController();
  TextEditingController discountOnMRPController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController prodDescriptionController = TextEditingController();

  // TODO: customerControllersName
  TextEditingController customerIdController = TextEditingController();
  TextEditingController customerMobileController = TextEditingController();
  TextEditingController customerCoNameController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerUnitNameController = TextEditingController();
  TextEditingController customerAreaController = TextEditingController();
  TextEditingController customerPinCodeController = TextEditingController();
  TextEditingController customerStreetController = TextEditingController();
  TextEditingController customerCountryController = TextEditingController();
  TextEditingController customerCityController = TextEditingController();
  TextEditingController customerLocationLinkController =
      TextEditingController();
  TextEditingController customerNoUnitController = TextEditingController();
  TextEditingController customerFieldOfficerController =
      TextEditingController();
  TextEditingController noOfEmpController = TextEditingController();
  TextEditingController customerDescriptionController = TextEditingController();

  // TODO: employeeControllersName
  TextEditingController emNameController = TextEditingController();
  TextEditingController emIDController = TextEditingController();
  TextEditingController emEmailController = TextEditingController();
  TextEditingController emPhoneController = TextEditingController();
  TextEditingController emDOBController = TextEditingController();
  TextEditingController emDepartmentController = TextEditingController();
  TextEditingController emPositionController = TextEditingController();
  TextEditingController emDoorNoController = TextEditingController();
  TextEditingController emStreetController = TextEditingController();
  TextEditingController emAreaController = TextEditingController();
  TextEditingController emCityController = TextEditingController();
  TextEditingController emStateController = TextEditingController();
  TextEditingController emPinCodeController = TextEditingController();
  TextEditingController emManagerController = TextEditingController();
  TextEditingController emCountryController =
      TextEditingController(text: "India");
  TextEditingController emDOJController = TextEditingController();
  TextEditingController emSalaryController = TextEditingController();
  TextEditingController emBonusController = TextEditingController();
  TextEditingController emDegreeController = TextEditingController();
  TextEditingController emInstitutionController = TextEditingController();
  TextEditingController emGraduationYearController = TextEditingController();

  TextEditingController search = TextEditingController();

  RxList<TextEditingController> mailControllers = <TextEditingController>[].obs;
  RxList<TextEditingController> phoneControllers =
      <TextEditingController>[].obs;
  RxList<TextEditingController> webSiteControllers =
      <TextEditingController>[].obs;
  TextEditingController stallNameController = TextEditingController();
  TextEditingController stallSizeController = TextEditingController();
  TextEditingController convenienceController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController employeeName = TextEditingController();
  TextEditingController employeeMobile = TextEditingController();
  TextEditingController employeeEmail = TextEditingController();
  TextEditingController fbMediaController = TextEditingController();
  TextEditingController inController = TextEditingController();

  List<TextEditingController> eventLtiDateControllers =
      <TextEditingController>[].obs;
  List<TextEditingController> eventLtiStTimeController =
      <TextEditingController>[].obs;
  List<TextEditingController> eventLtiEndTimeController =
      <TextEditingController>[].obs;
  List<TextEditingController> eventCorporateControllers =
      <TextEditingController>[].obs;
  List<TextEditingController> stallPriceControllers =
      <TextEditingController>[].obs;
  List<TextEditingController> thingsControllers = <TextEditingController>[].obs;
  List<TextEditingController> powerToolsControllers =
      <TextEditingController>[].obs;

  // TODO: companyControllersName
  TextEditingController coNameController = TextEditingController();
  TextEditingController coMobileController = TextEditingController();
  TextEditingController coEmailController = TextEditingController();
  TextEditingController coProductController = TextEditingController();
  TextEditingController coWebSiteController = TextEditingController();
  TextEditingController coXController = TextEditingController();
  TextEditingController coLinkedinController = TextEditingController();
  TextEditingController coDNoController = TextEditingController();
  TextEditingController coStreetController = TextEditingController();
  TextEditingController coAreaController = TextEditingController();
  TextEditingController coCityController = TextEditingController();
  TextEditingController coStateController =
      TextEditingController(text: "Tamil Nadu");
  TextEditingController coPinCodeController = TextEditingController();
  TextEditingController coCountryController =
      TextEditingController(text: "India");
  var monthData = <CustomerMonthData>[].obs;

  var rangeStart = DateTime.now().subtract(const Duration(days: 6)).obs;
  var rangeEnd = DateTime.now().obs;

  void moveRange(int days) {
    rangeStart.value = rangeStart.value.add(Duration(days: days));
    rangeEnd.value = rangeEnd.value.add(Duration(days: days));
  }
  void setData(List<dynamic> data) {
    monthData.value = data.map((e) => CustomerMonthData.fromJson(e)).toList();
  }

  List<FlSpot> get chartSpots {
    final monthMap = {
      "Jan": 1,
      "Feb": 2,
      "Mar": 3,
      "Apr": 4,
      "May": 5,
      "Jun": 6,
      "Jul": 7,
      "Aug": 8,
      "Sep": 9,
      "Oct": 10,
      "Nov": 11,
      "Dec": 12,
    };

    return monthData.map((d) {
      final x = monthMap[d.monthName] ?? 0;
      return FlSpot(x.toDouble(), d.totalCustomers);
    }).toList();
  }
  var leadPersonalItems = 1.obs,
      leadFieldItems = 1.obs,
      leadSocialItems = 1.obs,
      fbItems = 1.obs,
      inItems = 1.obs,
      stallItems = 1.obs;
  var leadMobiles = "".obs,
      leadNames = "".obs,
      leadTitles = "".obs,
      leadEmails = "".obs,
      leadWhatsApps = "".obs;
  var mainLeadName = "".obs,
      mainLeadMobile = "".obs,
      mainLeadTitle = "".obs,
      mainLeadEmail = "".obs,
      mainLeadWhatsApp = "".obs;
  var emailMsg = "".obs;
  var fbMsg = "".obs;
  var inMsg = "".obs, isAdmin = false.obs, isPanel = false.obs;
  RxString selectedCity = 'Chennai'.obs;
  RxString selectedState = 'Tamil Nadu'.obs;

//selectedCity = 'Chennai'.obs,
  //,selectedState = 'State'.obs
  RxString selectedCountry = 'India'.obs;

  // TODO: DateTimeFunction

  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // TODO: imagePickerFunction

  var count = 1.obs;
  final RoundedLoadingButtonController leadCtr =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController productCtr =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController emailCtr =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController customerCtr =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController employeeCtr =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController loginCtr =
      RoundedLoadingButtonController();

  DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  var selectPinCodeList = [];
  var selectStateList = [];
  var selectCityList = [];
  Future correctionStatus(BuildContext context,String ops,String id) async {
    try{
      print("statusCrt.text..........${statusCrt.text}");
      Map data = {
        "action": "correction_status",
        "ops": ops,
        "value": statusController.text,
        "id": id,
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${data}");
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return correctionStatus(context,ops,id);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200){
        Navigator.pop(context);
        Navigator.pop(context);
        getCallStatus();
        controllers.productCtr.reset();
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }
  Future insertIndustries(BuildContext context) async {
    try{
      print("insert_industry..........${industryValueCtr.text.trim()}");
      Map data = {
        "action": "insert_industry",
        "value": industryValueCtr.text.trim(),
        "created_by": controllers.storage.read("id"),
        "cos_id": controllers.storage.read("cos_id")
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      print("request ${data}");
      print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertIndustries(context);
        } else {
          controllers.setLogOut();
        }
      }
      if (request.statusCode == 200){
        getIndustries();
        controllers.productCtr.reset();
        Navigator.pop(context);
      } else {
        apiService.errorDialog(Get.context!,request.body);
        controllers.productCtr.reset();
      }
    }catch(e){
      apiService.errorDialog(Get.context!,e.toString());
      controllers.productCtr.reset();
    }
  }
  Future<void> setLogOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("loginScreen$versionNum", false);
    prefs.setBool("isAdmin", false);
    Get.offAll(() => LoginPage());
    controllers.selectedIndex.value = 10;
  }
  Future refreshToken() async {
    try{
      // print("refreshToken..........");
      Map data = {
        "action": "refresh_tokens",
        "id": controllers.storage.read("id"),
        "refresh_token": "${TokenStorage().readRefreshToken()}",
      };
      final request = await http.post(Uri.parse(scriptApi),
          headers: {
            'X-API-TOKEN': "${TokenStorage().readToken()}",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8")
      );
      // print("request ${data}");
      // print("request ${request.body}");
      Map<String, dynamic> response = json.decode(request.body);
      if (request.statusCode == 200){
        TokenStorage().writeToken(response['access_token']);
        return true;
      } else {
        return false;
      }
    }catch(e){
      return false;
    }
  }
  Future<bool> saveVisitingCardToServers(
      String contactType,
      String nameP,
      String phoneP,
      String emailP,
      String doorNumP,
      String streetP,
      String areaP,
      String cityP,
      String stateP,
      String countryP,
      String pincodeP,
      String coNameP,
      String designationP,
      String jobTitleP) async {
    try {
      final phoneD = phoneP.trim();

      if (phoneD.isEmpty) {
        Get.snackbar(
          "Error",
          "Data not clear. Please capture the card again",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        controllers.isUpdateLoading.value = false;
        return false;
      }
      Future<http.StreamedResponse> sendRequest(String token) async {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(scriptApi),
        );

        request.fields.addAll({
          "action": "share_visiting_card_crm",
          "user_id": controllers.storage.read("id").toString(),
          "fullname_g": nameP,
          "phone_number_g": phoneD,
          "whatsapp_number_g": phoneD,
          "mobile_number_g": phoneD,
          "phone_map": phoneD,
          "email": emailP,
          "email_map": emailP,
          "co_address": "",
          "sharing_location": controllers.sharingLocation.value,
          "notes": controllers.notesController.text,
          "address": cityP,
          "door_no": doorNumP,
          "street_name": streetP,
          "area": areaP,
          "city": cityP,
          "state": stateP,
          "pincode": pincodeP,
          "country": countryP,
          "notes_g": "",
          "live_data_g": "1",
          "facebook_id_g":"",
          "instagram_id_g":"",
          "twitter_id_g":"",
          "linkedin_id_g":"",
          "co_name_g": coNameP,
          "designation": jobTitleP,
          "info_g": designationP,
          "industry_g": "",
          "sub_industry_g": "",
          "products_g": "",
          "data_from": "3",
          "contact_type": contactType,
        });

        request.headers.addAll({
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        });


        return await request.send();
      }
      String token = controllers.storage.read("jwt_token");
      var streamedResponse = await sendRequest(token);

      if (streamedResponse.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return saveVisitingCardToServers(contactType,nameP,phoneP,emailP,doorNumP,streetP,
              areaP,cityP,stateP,countryP,pincodeP,coNameP,designationP,jobTitleP);
        } else {
          controllers.setLogOut();
        }
      }

      final responseBody = await streamedResponse.stream.bytesToString();

      debugPrint("Server response: $responseBody");

      if (responseBody.isEmpty) {
        Get.snackbar(
          "Error",
          "Server returned empty response",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        controllers.isUpdateLoading.value = false;
        controllers.btnController.reset();
        return false;
      }

      final dataOutput = jsonDecode(responseBody);

      if (streamedResponse.statusCode != 200 ||
          dataOutput["status"] == "error") {
        Get.snackbar(
          "Error",
          dataOutput["message"] ?? "Server error",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
        controllers.isUpdateLoading.value = false;
        controllers.btnController.reset();
        return false;
      }

      Get.snackbar(
        "Success",
        "Visiting card saved successfully!",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      controllers.btnController.reset();
      // Get.to(NewLeadPage(index: controllers.leadCategoryList[0].leadStatus ,name: controllers.leadCategoryList[0].value));
      return true;

    } catch (e, st) {
      debugPrint("❌ saveVisitingCard error: $e\n$st");

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      controllers.isUpdateLoading.value = false;
      controllers.btnController.reset();
      return false;
    }
  }
  Future<void> insertSingleCustomer(BuildContext context,
      String contactType,
      String nameP,
      String phoneP,
      String emailP,
      String doorNumP,
      String streetP,
      String areaP,
      String cityP,
      String stateP,
      String countryP,
      String pincodeP,
      String coNameP,
      String designationP,
      String web,
      String jobTitleP) async {
    try {
      // Lead Status
      String leadId = controllers.leadCategory == "Suspects"
          ? "1"
          : controllers.leadCategory == "Prospects"
          ? "2"
          : controllers.leadCategory == "Qualified"
          ? "3"
          : "4";

      // Visit Type
      String callListId = "";
      for (var role in controllers.callList) {
        if (role['value'] == controllers.visitType) {
          callListId = role['id'].toString();
          break;
        }
      }

      /// ✅ CUSTOMER LIST (DO NOT use Map<String,String>)
      List<Map<String, dynamic>> customersList = [
        {
          "cos_id": controllers.storage.read("cos_id").toString(),
          "name": nameP,
          "email": emailP,
          "phone_no": phoneP,
          "whatsapp_no": "",
          "created_by": controllers.storage.read("id").toString(),
          "platform": "3",
          "department": "",
          "designation": designationP,
          "main_person": "1"
        }
      ];

      /// ✅ MAIN REQUEST BODY
      Map<String, dynamic> data = {
        "action": "single_customer",
        "user_id": controllers.storage.read("id").toString(),
        "cos_id": controllers.storage.read("cos_id").toString(),

        "company_name": coNameP,
        "product_discussion": "",
        "source": "",
        "points": "",
        "quotation_status": "",

        "door_no": "",
        "area": "",
        "city": "",
        "country": "India",
        "state": "Tamil Nadu",
        "pincode": 0,

        "co_website": web,
        "co_number": "",
        "co_email": "",
        "linkedin": "",
        "x": "",

        "industry":"",
        "product": "",
        "source_details": "",

        "type": "1",
        "lat": 0.0,
        "lng": 0.0,
        "platform": "3",

        "lead_status": "1",
        "status": controllers.status,
        "quotation_required": "1",
        "visit_type": 0,

        "prospect_enrollment_date": "",

        "expected_convertion_date": "",

        "status_update": "",
        "num_of_headcount": 0,
        "expected_billing_value":0.0,
        "arpu_value":0.0,

        "details_of_service_required":"",
        "rating":0,
        "owner": "",

        /// ✅ IMPORTANT: SEND ARRAY, NOT STRING
        "data": customersList,
      };

      final response = await http.post(
        Uri.parse(scriptApi),
        headers: {
          'X-API-TOKEN': "${TokenStorage().readToken()}",
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      final body = response.body.toString();
      if (response.statusCode == 401) {
        final refreshed = await controllers.refreshToken();
        if (refreshed) {
          return insertSingleCustomer(context,contactType,nameP,phoneP,emailP,doorNumP,streetP,areaP,cityP,stateP,countryP,pincodeP,coNameP,designationP, web,jobTitleP);
        } else {
          controllers.setLogOut();
        }
      }
      print(response.body);
      if (response.statusCode == 200 &&body.contains("Customer saved successfully")) {
        var res = jsonDecode(response.body);

        int customerId = int.parse(res["cus_id"].toString());
        int addressId = 0;
        LeadStatusModel? data;
        int index=0;
        for(var i=0;i<controllers.leadCategoryList.length;i++){
          if(controllers.leadCategoryList[i].leadStatus=="1"){
            log("dataaaa: ${controllers.leadCategoryList[i]}");
            log("dataaaa: ${controllers.leadCategoryList[i].list.length}");
            log("dataaaa: ${controllers.leadCategoryList[i].list2.length}");
            controllers.leadCategoryList[i].list.add(NewLeadObj(
              select: false,
              userId:customerId.toString(),
              addressId: addressId.toString(),
              firstname: nameP,
              email: emailP,
              mobileNumber: phoneP,
              whatsapp: "",
              companyName: coNameP,
              productDiscussion: "",
              source: "",
              notes: "",
              quotationStatus: "",
              quotationRequired: "1",

              doorNo: "",
              area: "",
              city: "",
              country: "India",
              state: "Tamil Nadu",
              pincode: "",

              companyWebsite: web,
              companyNumber: "",
              companyEmail: "",
              linkedin: "",
              x: "",

              industry: "",
              product: "",
              sourceDetails:"",

              type: "1",
              lat: "0.0",
              lng: "0.0",

              leadStatus: "1",
              status: "",
              visitType: "",

              prospectEnrollmentDate:DateFormat("dd.MM.yyyy").format(DateTime.now()),

              expectedConvertionDate:DateFormat("dd.MM.yyyy").format(DateTime.now()),

              statusUpdate: "",
              numOfHeadcount: "",
              expectedBillingValue:"",
              arpuValue: "",

              detailsOfServiceRequired:"",
              rating: "",
              owner: "",
              createdTs: DateTime.now().toString(),
              updatedTs: DateTime.now().toString(),
            ));
            controllers.leadCategoryList[i].list2.add(NewLeadObj(
              select: false,
              userId:customerId.toString(),
              addressId: addressId.toString(),
              firstname: nameP,
              email: emailP,
              mobileNumber: phoneP,
              whatsapp: "",
              companyName: coNameP,
              productDiscussion: "",
              source: "",
              notes: "",
              quotationStatus: "",
              quotationRequired: "1",

              doorNo: "",
              area: "",
              city: "",
              country: "India",
              state: "Tamil Nadu",
              pincode: "",

              companyWebsite: web,
              companyNumber: "",
              companyEmail: "",
              linkedin: "",
              x: "",

              industry: "",
              product: "",
              sourceDetails:"",

              type: "1",
              lat: "0.0",
              lng: "0.0",

              leadStatus: "1",
              status: "",
              visitType: "",

              prospectEnrollmentDate:DateFormat("dd.MM.yyyy").format(DateTime.now()),

              expectedConvertionDate:DateFormat("dd.MM.yyyy").format(DateTime.now()),

              statusUpdate: "",
              numOfHeadcount: "",
              expectedBillingValue:"",
              arpuValue: "",

              detailsOfServiceRequired:"",
              rating: "",
              owner: "",
              createdTs: DateTime.now().toString(),
              updatedTs: DateTime.now().toString(),
            ));
            index=i;
            controllers.leadCategoryList.refresh();
            data=controllers.leadCategoryList[i];
            break;
          }
        }
        log("dataaaa: ${data}");
        log("dataaaa: ${data!.list.length}");
        log("dataaaa: ${data.list2.length}");
        controllers.selectedIndex.value=int.parse(data.leadStatus.toString());
        controllers.selectedQualifiedSortBy.value="All";
        dashController.getDashboardReport();
        controllers.leadCategoryList.refresh();
        controllers.btnController.reset();
        Get.to(NewLeadPage(index: data.leadStatus ,
          name: data.value,list: data.list,list2: data.list2, listIndex: index,));
        // apiService.getCustomLeads();
        // Navigator.pushReplacement(
        //   context,
          // MaterialPageRoute(builder: (_) =>  NewLeadPage(index: controllers.leadCategoryList[0].leadStatus ,name: controllers.leadCategoryList[0].value)),
        // );
      }
      else if (body.contains("Phone number")) {
        controllers.btnController.reset();
        apiService.errorDialog(context, "Phone number already exists");
      } else {
        controllers.btnController.reset();
        apiService.errorDialog(context, body);
      }
    } catch (e) {
      controllers.btnController.reset();
      apiService.errorDialog(context, e.toString());
    }
  }

}
