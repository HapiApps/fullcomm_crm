import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:fullcomm_crm/models/all_customers_obj.dart';
import 'package:intl/intl.dart';
import 'package:fullcomm_crm/models/company_obj.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:group_button/group_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../models/comments_obj.dart';
import '../models/customer_activity.dart';
import '../models/employee_obj.dart';
import '../models/mail_receive_obj.dart';
import '../models/meeting_obj.dart';
import '../models/month_report_obj.dart';
import '../models/new_lead_obj.dart';
import '../models/product_obj.dart';
import '../models/user_heading_obj.dart';

final controllers = Get.put(Controller());

class Controller extends GetxController with GetSingleTickerProviderStateMixin {
  var version = "Version 0.0.7";
  var versionNum = "0.0.7";
  late TabController tabController;
  var tabCurrentIndex = 0.obs;

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
      updateAvailable = true.obs;
  var selectedChartMonth = DateTime.now().month.obs;
  var selectedChartYear = DateTime.now().year.obs;
  String countryDial = "+91";
  var isEyeOpen = false.obs,isLeftOpen=true.obs,isRightOpen=true.obs;
  RxInt selectedIndex = 0.obs,oldIndex=0.obs;
  bool extended =false;
  RxString searchText = ''.obs;
  final RxString searchQuery = ''.obs,searchProspects = ''.obs,searchQualified = ''.obs;
  Future<List<NewLeadObj>>? allCustomerFuture;
  Future<List<EmployeeObj>>? allEmployeeFuture;
  Future<List<ProductObj>>? allProductFuture;
  Future<List<NewLeadObj>>? leadFuture;
  Future<List<CommentsObj>>? customCommentsFuture;
  Future<List<MailReceiveObj>>? customMailFuture;
  Future<List<NewLeadObj>>? allGoodLeadFuture;
  Future<List<CompanyObj>>? allCompanyFuture;
  var disqualifiedFuture      = <NewLeadObj>[].obs;
  var allNewLeadFuture        = <NewLeadObj>[].obs;
  var allLeadFuture           = <NewLeadObj>[].obs;
  var allQualifiedLeadFuture  = <NewLeadObj>[].obs;
  var allCustomerLeadFuture  = <NewLeadObj>[].obs;
  RxString selectedTemperature = "".obs;
  RxString selectedProspectTemperature = "".obs;
  RxString selectedQualifiedTemperature = "".obs;
  RxString selectedSortBy = "".obs;
  RxString selectedProspectSortBy = "".obs;
  RxString selectedQualifiedSortBy = "".obs;
  RxString selectedCustomerSortBy = "".obs;
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

  void selectMonth(BuildContext context, RxString sortByKey,
      Rxn<DateTime> selectedMonthTarget) async {
    showMonthPicker(
      context: context,
      monthStylePredicate: highlightCurrentMonth,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((selected) {
      if (selected != null) {
        sortByKey.value = 'Custom Month';
        selectedMonthTarget.value = selected;
      }
    });
  }

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

  var currentPage = 1.obs;
  final itemsPerPage = 20; // Adjust based on your needs
  var currentProspectPage = 1.obs;
  final itemsProspectPerPage = 20;
  bool isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  var disqualifiedSortField = ''.obs;
  var disqualifiedSortOrder = 'asc'.obs;
  List<NewLeadObj> get paginatedDisqualified {
    final query = searchQuery.value.toLowerCase();
    final ratingFilter = selectedTemperature.value;
    final sortBy = selectedProspectSortBy.value; // 'Today', 'Last 7 Days', etc.
    final now = DateTime.now();
    final filteredLeads = disqualifiedFuture.where((lead) {
      final matchesQuery = (lead.firstname ?? '').toLowerCase().contains(query) ||
          (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
          (lead.emailId ?? '').toLowerCase().contains(query);

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
        dynamic valA;
        dynamic valB;

        switch (sortField.value) {
          case 'name':
            String nameA = a.firstname ?? '';
            String nameB = b.firstname ?? '';
            if (nameA.contains('||')) {
              nameA = nameA.split('||')[0].trim();
            }
            if (nameB.contains('||')) {
              nameB = nameB.split('||')[0].trim();
            }
            valA = nameA.toLowerCase();
            valB = nameB.toLowerCase();
            break;
          case 'companyName':
            valA = a.companyName ?? '';
            valB = b.companyName ?? '';
            break;
          case 'mobile':
            valA = a.mobileNumber ?? '';
            valB = b.mobileNumber ?? '';
            break;
          case 'serviceRequired':
            valA = a.detailsOfServiceRequired ?? '';
            valB = b.detailsOfServiceRequired ?? '';
            break;
          case 'sourceOfProspect':
            valA = a.source ?? '';
            valB = b.source ?? '';
            break;
          case 'city':
            valA = a.city ?? '';
            valB = b.city ?? '';
            break;
          case 'statusUpdate':
            valA = a.statusUpdate ?? '';
            valB = b.statusUpdate ?? '';
            break;
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
            valA = parseDate(a.updatedTs, a.prospectEnrollmentDate);
            valB = parseDate(b.updatedTs, b.prospectEnrollmentDate);

            break;
          default:
            valA = '';
            valB = '';
        }
        if (valA is DateTime && valB is DateTime) {
          return sortOrder.value == 'asc'
              ? valA.compareTo(valB)
              : valB.compareTo(valA);
        } else {
          print("short ${sortOrderN.value}");
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
    final sortBy = selectedProspectSortBy.value; // 'Today', 'Last 7 Days', etc.
    final now = DateTime.now();

    final filteredLeads = allNewLeadFuture.where((lead) {
      final matchesQuery = query.isEmpty ||
          (lead.firstname?.toLowerCase().contains(query) ?? false) ||
          (lead.mobileNumber?.toLowerCase().contains(query) ?? false) ||
          (lead.companyName?.toLowerCase().contains(query) ?? false);

      final matchesRating = ratingFilter.isEmpty || ((lead.rating ?? '').toLowerCase() == ratingFilter.toLowerCase());

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
        dynamic valA;
        dynamic valB;

        switch (sortField.value) {
          case 'name':
            String nameA = a.firstname ?? '';
            String nameB = b.firstname ?? '';
            if (nameA.contains('||')) {
              nameA = nameA.split('||')[0].trim();
            }
            if (nameB.contains('||')) {
              nameB = nameB.split('||')[0].trim();
            }
            valA = nameA.toLowerCase();
            valB = nameB.toLowerCase();
            break;
          case 'companyName':
            valA = a.companyName ?? '';
            valB = b.companyName ?? '';
            break;
          case 'mobile':
            valA = a.mobileNumber ?? '';
            valB = b.mobileNumber ?? '';
            break;
          case 'serviceRequired':
            valA = a.detailsOfServiceRequired ?? '';
            valB = b.detailsOfServiceRequired ?? '';
            break;
          case 'sourceOfProspect':
            valA = a.source ?? '';
            valB = b.source ?? '';
            break;
          case 'city':
            valA = a.city ?? '';
            valB = b.city ?? '';
            break;
          case 'statusUpdate':
            valA = a.statusUpdate ?? '';
            valB = b.statusUpdate ?? '';
            break;
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
            valA = parseDate(a.updatedTs, a.prospectEnrollmentDate);
            valB = parseDate(b.updatedTs, b.prospectEnrollmentDate);

            break;
          default:
            valA = '';
            valB = '';
        }

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

  // to get leads of specific range
  List<NewLeadObj> getLeadsByRange(int index) {
    final startIndex = index * mailPerPage;
    final endIndex = (startIndex + mailPerPage) > allNewLeadFuture.length
        ? allNewLeadFuture.length
        : startIndex + mailPerPage;

    return allNewLeadFuture.sublist(startIndex, endIndex);
  }

  List<NewLeadObj> get paginatedQualifiedLeads {
    final query = search.text.trim().toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedQualifiedSortBy.value; // 'Today', 'Last 7 Days', etc.

    final now = DateTime.now();

    final filteredLeads = allQualifiedLeadFuture.where((lead) {
      final matchesQuery = (lead.firstname ?? '').toLowerCase().contains(query) ||
          (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
          (lead.emailId ?? '').toLowerCase().contains(query);

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
        dynamic valA;
        dynamic valB;

        switch (sortField.value) {
          case 'name':
            String nameA = a.firstname ?? '';
            String nameB = b.firstname ?? '';
            if (nameA.contains('||')) {
              nameA = nameA.split('||')[0].trim();
            }
            if (nameB.contains('||')) {
              nameB = nameB.split('||')[0].trim();
            }
            valA = nameA.toLowerCase();
            valB = nameB.toLowerCase();
            break;
          case 'companyName':
            valA = a.companyName ?? '';
            valB = b.companyName ?? '';
            break;
          case 'mobile':
            valA = a.mobileNumber ?? '';
            valB = b.mobileNumber ?? '';
            break;
          case 'serviceRequired':
            valA = a.detailsOfServiceRequired ?? '';
            valB = b.detailsOfServiceRequired ?? '';
            break;
          case 'sourceOfProspect':
            valA = a.source ?? '';
            valB = b.source ?? '';
            break;
          case 'city':
            valA = a.city ?? '';
            valB = b.city ?? '';
            break;
          case 'statusUpdate':
            valA = a.statusUpdate ?? '';
            valB = b.statusUpdate ?? '';
            break;
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
            valA = parseDate(a.updatedTs, a.prospectEnrollmentDate);
            valB = parseDate(b.updatedTs, b.prospectEnrollmentDate);
            break;
          default:
            valA = '';
            valB = '';
        }
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
    final query = search.text.trim().toLowerCase();
    final ratingFilter = selectedProspectTemperature.value;
    final sortBy = selectedCustomerSortBy.value;

    final now = DateTime.now();

    final filteredLeads = allCustomerLeadFuture.where((lead) {
      final matchesQuery = (lead.firstname ?? '').toLowerCase().contains(query) ||
          (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
          (lead.emailId ?? '').toLowerCase().contains(query);

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
        dynamic valA;
        dynamic valB;

        switch (sortField.value) {
          case 'name':
            String nameA = a.firstname ?? '';
            String nameB = b.firstname ?? '';
            if (nameA.contains('||')) {
              nameA = nameA.split('||')[0].trim();
            }
            if (nameB.contains('||')) {
              nameB = nameB.split('||')[0].trim();
            }
            valA = nameA.toLowerCase();
            valB = nameB.toLowerCase();
            break;
          case 'companyName':
            valA = a.companyName ?? '';
            valB = b.companyName ?? '';
            break;
          case 'mobile':
            valA = a.mobileNumber ?? '';
            valB = b.mobileNumber ?? '';
            break;
          case 'serviceRequired':
            valA = a.detailsOfServiceRequired ?? '';
            valB = b.detailsOfServiceRequired ?? '';
            break;
          case 'sourceOfProspect':
            valA = a.source ?? '';
            valB = b.source ?? '';
            break;
          case 'city':
            valA = a.city ?? '';
            valB = b.city ?? '';
            break;
          case 'statusUpdate':
            valA = a.statusUpdate ?? '';
            valB = b.statusUpdate ?? '';
            break;
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
            valA = parseDate(a.updatedTs, a.prospectEnrollmentDate);
            valB = parseDate(b.updatedTs, b.prospectEnrollmentDate);
            break;
          default:
            valA = '';
            valB = '';
        }

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
    final sortBy = selectedQualifiedSortBy.value; // 'Today', 'Last 7 Days', etc.

    final now = DateTime.now();

    final filteredLeads = allLeadFuture.where((lead) {
      final matchesQuery =
          (lead.firstname ?? '').toLowerCase().contains(query) ||
              (lead.mobileNumber ?? '').toLowerCase().contains(query) ||
              (lead.emailId ?? '').toLowerCase().contains(query);

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
        dynamic valA;
        dynamic valB;

        switch (sortField.value) {
          case 'name':
            String nameA = a.firstname ?? '';
            String nameB = b.firstname ?? '';
            if (nameA.contains('||')) {
              nameA = nameA.split('||')[0].trim();
            }
            if (nameB.contains('||')) {
              nameB = nameB.split('||')[0].trim();
            }
            valA = nameA.toLowerCase();
            valB = nameB.toLowerCase();
            break;
          case 'companyName':
            valA = a.companyName ?? '';
            valB = b.companyName ?? '';
            break;
          case 'mobile':
            valA = a.mobileNumber ?? '';
            valB = b.mobileNumber ?? '';
            break;
          case 'serviceRequired':
            valA = a.detailsOfServiceRequired ?? '';
            valB = b.detailsOfServiceRequired ?? '';
            break;
          case 'sourceOfProspect':
            valA = a.source ?? '';
            valB = b.source ?? '';
            break;
          case 'city':
            valA = a.city ?? '';
            valB = b.city ?? '';
            break;
          case 'statusUpdate':
            valA = a.statusUpdate ?? '';
            valB = b.statusUpdate ?? '';
            break;
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
            valA = parseDate(a.updatedTs, a.prospectEnrollmentDate);
            valB = parseDate(b.updatedTs, b.prospectEnrollmentDate);
            break;
          default:
            valA = '';
            valB = '';
        }

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
      totalWarm = "".obs,
      totalCold = "".obs,
      totalHot = "".obs,
      allTelephoneCalls = "0".obs,
      allSentMails = "0".obs,
      allOpenedMails = "0".obs,
      allReplyMails = "0".obs,
      allIncomingCalls = "0".obs,
      allOutgoingCalls = "0".obs,
      allMissedCalls = "0".obs,
      allScheduleMeet = "0".obs,
      allCompletedMeet = "0".obs,
      allCancelled = "0".obs,serverSheet = "0".obs,
      shortBy = "All".obs,
      isCommentsLoading = true.obs,isSent = false.obs,isOpened= false.obs,isReplied = false.obs,isMailLoading = false.obs,isIncoming = false.obs,isOutgoing= false.obs,isMissed = false.obs,isCallLoading = false.obs;
  var roleNameList    = [];
  var callNameList    = ["Visit","Call","Email","Meeting","Note"];
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



  String? getUserHeading(String systemField) {
    try {
      return fields.firstWhere((f) => f.systemField == systemField).userHeading;
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
  void clearSelectedCustomer() {
    selectedCustomerId.value = '';
    selectedCustomerName.value = '';
    selectedCustomerMobile.value = '';
    selectedCustomerEmail.value = '';
    selectedCompanyName.value = '';
  }

  void selectEmployee(AllEmployeesObj c) {
    selectedEmployeeId.value = c.id;
    selectedEmployeeName.value = c.name;
    selectedEmployeeMobile.value = c.phoneNo;
    selectedEmployeeEmail.value = c.email;
  }
  void clearSelectedEmployee() {
    selectedEmployeeId.value = '';
    selectedEmployeeName.value = '';
    selectedEmployeeMobile.value = '';
    selectedEmployeeEmail.value = '';
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
  RxList callList = [{"category":"Visit Call Type","id":"6","value":"Visit"},{"category":"Visit Call Type","id":"7","value":"Call"},{"category":"Visit Call Type","id":"8","value":"Email"},{"category":"Visit Call Type","id":"9","value":"Meeting"},{"category":"Visit Call Type","id":"10","value":"Note"}].obs;
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
    "Incoming",
    "Outgoing",
    "Missed"
  ];
  var callStatusList = [
    "Completed",
    "Pending",
    "Missed"
  ];

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
      allProductLength = 0.obs,
      allEmployeeLength = 0.obs, selectCallType = "".obs,selectMeetingType = "".obs;

  var states,
      upState,
      upCoState,
      category,
      source,
      status,
      rating,
      industry,
  callType,
      callStatus,
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

  String upRegistration = "No",
      upInvitation = "No",
      upEventState = "Tamil Nadu",
      leadCategory = "Suspects";
  RxList leadCategoryList = [{"category":"Lead Status","id":"1","value":"Suspects"},{"category":"Lead Status","id":"1","value":"Prospects"},{"category":"Lead Status","id":"1","value":"Qualified"},{"category":"Lead Status","id":"1","value":"Suspects"},{"category":"Lead Status","id":"1","value":"Prospects"},{"category":"Lead Status","id":"1","value":"Qualified"}].obs;
  RxList leadCategoryGrList = [].obs;
  List eventImages = [
    "assets/image/event_logo1.jpeg",
    "assets/image/event_logo2.jpeg",
    "assets/image/itinerary2.jpeg",
    "assets/image/itinerary1.jpeg"
  ];

  final picker = ImagePicker();
  Future<List>? imageListFuture;
  late List<String> userdata = [];
  List contactsID = [];
  var allCate = [];
  List attendanceMark = [];
  var emailCount = 0.obs;
  var isTemplate = false.obs,
      isAllSelected = false.obs,
      isLeadLoading = false.obs;

  var dateList = [].obs,
      isMainPersonList = [].obs,
      isNewLeadList = [].obs,isDisqualifiedList=[].obs,
      isLeadsList = [].obs,
      isGoodLeadList = [].obs,
      isCoMobileNumberList = [].obs,
      mailReceivesList = [].obs;
  var empName = "".obs,
      empId = "".obs,
      empEmail = "".obs,
      empPhone = "".obs,
      empDOB = "".obs,
      exDate = "".obs,
      prospectDate = "".obs,
      fDate = "".obs,
      toDate = "".obs,
      callTime = "".obs,
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
  TextEditingController signEmailID = TextEditingController();
  TextEditingController signWhatsappNumber = TextEditingController();
  TextEditingController signPassword = TextEditingController();
  TextEditingController signReferBy = TextEditingController();

  // TODO: leadControllersName
  TextEditingController signupPasswordController = TextEditingController();
  List<TextEditingController> leadNameCrt = <TextEditingController>[].obs;
  List<TextEditingController> leadMobileCrt = <TextEditingController>[].obs;
  List<TextEditingController> leadWhatsCrt = <TextEditingController>[].obs;
  List<TextEditingController> leadEmailCrt = <TextEditingController>[].obs;
  List<TextEditingController> leadTitleCrt = <TextEditingController>[].obs;
  List<TextEditingController> leadFieldName = <TextEditingController>[];
  List<TextEditingController> leadFieldValue = <TextEditingController>[];
  //TextEditingController leadNameCrt = TextEditingController();
  TextEditingController leadOwnerNameCrt = TextEditingController();
  TextEditingController leadSourceCrt = TextEditingController();
  TextEditingController leadGstNumCrt = TextEditingController();
  TextEditingController leadGstLocationCrt = TextEditingController();
  TextEditingController leadGstDORCrt = TextEditingController();
  TextEditingController leadDisPointsCrt = TextEditingController();
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
  var dayReport = <CustomerDayData>[].obs;
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

  var pinCodeList = [
    {
      "PINCODE": 110001,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110002,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110003,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110004,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110005,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110006,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110007,
      "STATE": "Delhi",
      "DISTRICT": "North Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110008,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110009,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110010,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110011,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110012,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110013,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110014,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110015,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110016,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110017,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110018,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110019,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110020,
      "STATE": "Delhi",
      "DISTRICT": "New Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110021,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110022,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110023,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110024,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110025,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110026,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110027,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110028,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110029,
      "STATE": "Delhi",
      "DISTRICT": "New Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110030,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110031,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110032,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110033,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110034,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110035,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110036,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110037,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110038,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110039,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110040,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110041,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110042,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110043,
      "STATE": "Delhi",
      "DISTRICT": "New Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110044,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110045,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110046,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110047,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110048,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110049,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110050,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110051,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110052,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110053,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110054,
      "STATE": "Delhi",
      "DISTRICT": "North Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110055,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110056,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110057,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110058,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110059,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110060,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110061,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110062,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110063,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110064,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110065,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110066,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110067,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110068,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110069,
      "STATE": "Delhi",
      "DISTRICT": "Central Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110070,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110071,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110072,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110073,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110074,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110075,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110076,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110077,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110078,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110080,
      "STATE": "Delhi",
      "DISTRICT": "South Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110081,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110082,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110083,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110084,
      "STATE": "Delhi",
      "DISTRICT": "New Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110085,
      "STATE": "Delhi",
      "DISTRICT": "North Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110086,
      "STATE": "Delhi",
      "DISTRICT": "North Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110087,
      "STATE": "Delhi",
      "DISTRICT": "West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110088,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110089,
      "STATE": "Delhi",
      "DISTRICT": "North West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110090,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110091,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110092,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110093,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110094,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110095,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110096,
      "STATE": "Delhi",
      "DISTRICT": "East Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110097,
      "STATE": "Delhi",
      "DISTRICT": "South West Delhi",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 110098,
      "STATE": "Delhi",
      "DISTRICT": "New Delhi",
      "LOCATION": "Delhi NCR"
    },
    {"PINCODE": 110099, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 121001,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121002,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121003,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121004,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121005,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121006,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121007,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121008,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121009,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121010,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121013,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121101,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121102,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121105,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 121106,
      "STATE": "Haryana",
      "DISTRICT": "Faridabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122001,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122002,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122003,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122004,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122005,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122006,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122007,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122008,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122009,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122010,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122011,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122015,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122016,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122017,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122018,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {"PINCODE": 122021, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 122022, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 122050,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122052,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122101,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 122102,
      "STATE": "Haryana",
      "DISTRICT": "Gurgaon",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124102,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124103,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124104,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124105,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124108,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124201,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124412,
      "STATE": "Haryana",
      "DISTRICT": "Rohtak",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124501,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124504,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124505,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 124507,
      "STATE": "Haryana",
      "DISTRICT": "Jhajjar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 133301,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 133302,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134103,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134104,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134105,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134108,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134109,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134112,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134113,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134114,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134115,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134116,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 134117,
      "STATE": "Haryana",
      "DISTRICT": "Panchkula",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140103,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140109,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140110,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140112,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140119,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140125,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140133,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140201,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140301,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140306,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140307,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140308,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140413,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140501,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140506,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140507,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140603,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140604,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 140901,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160001,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160002,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160003,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160004,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160005,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160009,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160011,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160012,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160014,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160015,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160016,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160017,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160018,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160019,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160020,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160022,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160023,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160025,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160030,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160036,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160043,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160047,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160055,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160059,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160062,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160071,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160101,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160102,
      "STATE": "Chandigarh",
      "DISTRICT": "Chandigarh",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160103,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 160104,
      "STATE": "Punjab",
      "DISTRICT": "Mohali",
      "LOCATION": "Chandigarh MR"
    },
    {
      "PINCODE": 201001,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201002,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201003,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201004,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201005,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201006,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201007,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201008,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201009,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201010,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201011,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201012,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201013,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201014,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201015,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201016,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201017,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201019,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201020,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201102,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {"PINCODE": 201109, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 201301,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201302,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Ghaziabad",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201303,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201304,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201305,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201306,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201307,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201308,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201309,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201310,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201314,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 201318,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Gautam Buddha Nagar",
      "LOCATION": "Delhi NCR"
    },
    {
      "PINCODE": 226001,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226002,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226003,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226004,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226005,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226006,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226007,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226008,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226009,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226010,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226011,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226012,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226013,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226014,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226015,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226016,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226017,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226018,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226019,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226020,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226021,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226022,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226023,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226024,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226025,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226026,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226027,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226028,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226029,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226030,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226031,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226101,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226102,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226103,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226104,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226201,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226202,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226203,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226301,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226302,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226303,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226401,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 226501,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227101,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227105,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227106,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227107,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227111,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227115,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227116,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227125,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227132,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227202,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227205,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227207,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227208,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227305,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227308,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 227309,
      "STATE": "Uttar Pradesh",
      "DISTRICT": "Lucknow",
      "LOCATION": "Lucknow"
    },
    {
      "PINCODE": 301001,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301002,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301018,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301019,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301021,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301023,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301028,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301403,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301404,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301409,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301416,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301701,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301707,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 301713,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 302001,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302002,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302003,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302004,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302005,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302006,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302007,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302008,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302009,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302010,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302011,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302012,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302013,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302014,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302015,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302016,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302017,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302018,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302019,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302020,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302021,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302022,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302023,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302024,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302025,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302026,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302027,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302028,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302029,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {"PINCODE": 302030, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 302031,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302032,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302033,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302034,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302035,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302036,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302037,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302038,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302039,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302040,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302041,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 302042,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {"PINCODE": 302043, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 303007,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303012,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303101,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303104,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303121,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303301,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303701,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303702,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303704,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303805,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303903,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303904,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 303905,
      "STATE": "Rajasthan",
      "DISTRICT": "Jaipur",
      "LOCATION": "Jaipur"
    },
    {
      "PINCODE": 305001,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305002,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305003,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305004,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305005,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305007,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305008,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305009,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305012,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305024,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305203,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305204,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305206,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305402,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305403,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305405,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305407,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305601,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305621,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305622,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305623,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305624,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305625,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305627,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305630,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {"PINCODE": 305631, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 305801,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305811,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305812,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305813,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305815,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305901,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305923,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305924,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305925,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 305926,
      "STATE": "Rajasthan",
      "DISTRICT": "Ajmer",
      "LOCATION": "Ajmer"
    },
    {
      "PINCODE": 321607,
      "STATE": "Rajasthan",
      "DISTRICT": "Alwar",
      "LOCATION": "Alwar"
    },
    {
      "PINCODE": 332001,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332025,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332027,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332029,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332030,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332031,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332042,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332301,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332302,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332304,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332305,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332307,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332311,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332315,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332318,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332403,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332404,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332602,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332603,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332701,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332702,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332703,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332707,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332708,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332711,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332712,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332713,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332719,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332722,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 332742,
      "STATE": "Rajasthan",
      "DISTRICT": "Sikar",
      "LOCATION": "Sikar"
    },
    {
      "PINCODE": 360001,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360002,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360004,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360005,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360007,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360022,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360024,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360025,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 360026,
      "STATE": "Gujarat",
      "DISTRICT": "Rajkot",
      "LOCATION": "Rajkot"
    },
    {
      "PINCODE": 380001,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380002,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380003,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380004,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380005,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380006,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380007,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380008,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380009,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380013,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380014,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380015,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380016,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380018,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380019,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380021,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380022,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380023,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380024,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380025,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380026,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380027,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380028,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380038,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380049,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380050,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380051,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380052,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380054,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380055,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380058,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380059,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380060,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380061,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380063,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 380081,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382006,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382007,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382016,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382021,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382024,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {"PINCODE": 382027, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 382030,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382042,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382110,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382115,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382120,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382130,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382140,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382150,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382170,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382210,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382213,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382220,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382225,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382240,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382260,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382305,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382308,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382315,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382321,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {"PINCODE": 382325, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 382330,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382340,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382345,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {"PINCODE": 382346, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 382350,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382355,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382405,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382415,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382418,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382421,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382422,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382424,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382425,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382426,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382427,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382428,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382430,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382433,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382435,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382440,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382443,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382445,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382449,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382455,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382460,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382463,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382465,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382470,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382475,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382480,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382481,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 382610,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382620,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382640,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382705,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 382721,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {"PINCODE": 382722, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 382725,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382735,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382740,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 382855,
      "STATE": "Gujarat",
      "DISTRICT": "Gandhi Nagar",
      "LOCATION": "Gandhi Nagar"
    },
    {
      "PINCODE": 383120,
      "STATE": "Gujarat",
      "DISTRICT": "Sabarkantha",
      "LOCATION": "Sabarkantha"
    },
    {
      "PINCODE": 384001,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384002,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384120,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384140,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384160,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384315,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384320,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384330,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384345,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {
      "PINCODE": 384430,
      "STATE": "Gujarat",
      "DISTRICT": "Mahesana",
      "LOCATION": "Mahesana"
    },
    {"PINCODE": 384441, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 384445, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 384470, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 384550, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 387001,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387002,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387115,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387130,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387310,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 387315,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387325,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387345,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 387355,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387360,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387370,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387375,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387411,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387430,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387520,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387610,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387620,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387810,
      "STATE": "Gujarat",
      "DISTRICT": "Ahmedabad",
      "LOCATION": "Ahmedabad"
    },
    {
      "PINCODE": 388001,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388110,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388120,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388121,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388130,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388160,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388205,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388210,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388220,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388235,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388305,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388306,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388310,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388315,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388320,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388325,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388330,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388335,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388340,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388345,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388350,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388355,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388360,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388365,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388370,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388410,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 388430,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388440,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388450,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388465,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388470,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388510,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388540,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388545,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388550,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388560,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388570,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 389350,
      "STATE": "Gujarat",
      "DISTRICT": "Panch Mahals",
      "LOCATION": "Panch Mahals"
    },
    {
      "PINCODE": 390001,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390002,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390003,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390004,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390005,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390006,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390007,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390008,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390009,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390010,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390011,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390012,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390013,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390014,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390015,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390016,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390017,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390018,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390019,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390020,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390021,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390022,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390023,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390024,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 390025,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391101,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391107,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391135,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391210,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391240,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391242,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391310,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391320,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391330,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391340,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391345,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391346,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391347,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391350,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391410,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391440,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391442,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391445,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391510,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391520,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391740,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391745,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391760,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391761,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391770,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391774,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391775,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391776,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 391780,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 392001,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {"PINCODE": 392002, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 392011,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392012,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392015,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392020,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392030,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392035,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392110,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392160,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392210,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392220,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392230,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 392240,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 393001,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 393002,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 393010,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 393020,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 393110,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 394101,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394105,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394107,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394115,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 394116,
      "STATE": "Gujarat",
      "DISTRICT": "Bharuch",
      "LOCATION": "Bharuch"
    },
    {
      "PINCODE": 394150,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394155,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394180,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394185,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394210,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394221,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394270,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394326,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394335,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 394510,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395001,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395002,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395005,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395006,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395007,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395008,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395009,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395010,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395012,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395013,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395017,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395023,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 396195,
      "STATE": "Gujarat",
      "DISTRICT": "Valsad",
      "LOCATION": "Valsad"
    },
    {
      "PINCODE": 400001,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400002,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400003,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400004,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400005,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400006,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400007,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400008,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400009,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400010,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400011,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400012,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400013,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400014,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400015,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400016,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400017,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400018,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400019,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400020,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400021,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400022,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400023,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400024,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400025,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400026,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400027,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400028,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400029,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400030,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400031,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400032,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400033,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400034,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400035,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400036,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400037,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400038,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400039,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400040,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400041,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400042,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400043,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {"PINCODE": 400045, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 400047,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400049,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400050,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400051,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400052,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400053,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400054,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400055,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400056,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400057,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400058,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400059,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400060,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400061,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400062,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400063,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400064,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400065,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400066,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400067,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400068,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400069,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400070,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400071,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400072,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {"PINCODE": 400073, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 400074,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400075,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400076,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400077,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400078,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400079,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400080,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400081,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400082,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400083,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400084,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400085,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400086,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400087,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400088,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400089,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400090,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400091,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400092,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400093,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400094,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400095,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400096,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400097,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400098,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400099,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {"PINCODE": 400100, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 400101,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400102,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400103,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400104,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400105,
      "STATE": "Maharashtra",
      "DISTRICT": "Mumbai",
      "LOCATION": "Mumbai MR"
    },
    {"PINCODE": 400106, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 400601,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400602,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400603,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400604,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400605,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400606,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400607,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400608,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400610,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400611,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400612,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400613,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400614,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400615,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400701,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400703,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400705,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400706,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400708,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400709,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 400710,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401101,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401102,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401104,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401105,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401106,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401107,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401201,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401202,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401203,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401206,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401207,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401208,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401209,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401210,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401301,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401302,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401303,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401305,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401401,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401402,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401404,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401405,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401501,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401502,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401504,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 401506,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 410206,
      "STATE": "Maharashtra",
      "DISTRICT": "Raigarh(MH)",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 410208,
      "STATE": "Maharashtra",
      "DISTRICT": "Raigarh(MH)",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 410209,
      "STATE": "Maharashtra",
      "DISTRICT": "Raigarh(MH)",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 410210,
      "STATE": "Maharashtra",
      "DISTRICT": "Raigarh(MH)",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 410218,
      "STATE": "Maharashtra",
      "DISTRICT": "Raigarh(MH)",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 410221,
      "STATE": "Maharashtra",
      "DISTRICT": "Raigarh(MH)",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 410501,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 410506,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 410507,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {"PINCODE": 411000, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 411001,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411002,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411003,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411004,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411005,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411006,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411007,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411008,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411009,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {"PINCODE": 411010, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 411011,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411012,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411013,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411014,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411015,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411016,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411017,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411018,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411019,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411020,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411021,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411022,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411023,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411024,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411025,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411026,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411027,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411028,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411029,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411030,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411031,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411032,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411033,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411034,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411035,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411036,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411037,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411038,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411039,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411040,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411041,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411042,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411043,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411044,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411045,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411046,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411047,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411048,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411049,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411050,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411051,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411052,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411053,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411054,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411055,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {"PINCODE": 411056, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 411057,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411058,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {"PINCODE": 411059, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 411060,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411061,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 411062,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {"PINCODE": 411063, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411064, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411066, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 411067,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {"PINCODE": 411070, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411074, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411101, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411103, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411109, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411201, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411207, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411208, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 411501, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 412035, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 412101,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412105,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412106,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412107,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412108,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412109,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412110,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412111,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412112,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412114,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412115,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412201,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412202,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412207,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412208,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412216,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412307,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412308,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 412404,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 413115,
      "STATE": "Maharashtra",
      "DISTRICT": "Pune",
      "LOCATION": "Pune"
    },
    {
      "PINCODE": 413704,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413705,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414001,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414002,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414003,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414005,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414006,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414103,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414110,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414111,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414201,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414301,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {"PINCODE": 414404, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 414410, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 414601,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 415570,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {"PINCODE": 420003, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 421001,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421002,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {"PINCODE": 421003, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 421004,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421005,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421102,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421103,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421201,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421202,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421203,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421204,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {"PINCODE": 421206, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 421301,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421303,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421304,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421306,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421501,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421502,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421503,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421504,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421505,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 421605,
      "STATE": "Maharashtra",
      "DISTRICT": "Thane",
      "LOCATION": "Mumbai MR"
    },
    {
      "PINCODE": 422001,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422002,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422003,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422004,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422005,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422006,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422007,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422008,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422009,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422010,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422011,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422012,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422013,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422015,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422101,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422102,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422103,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422105,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422112,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422113,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422201,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422202,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422206,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422207,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422209,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422212,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422213,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422214,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422216,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422221,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422222,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422301,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422303,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422305,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422306,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422401,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422402,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422403,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422405,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422501,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422502,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422503,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422605,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 422608,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 422622,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 423102,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423104,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423107,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 423109,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 423110,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423203,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423204,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423206,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423401,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423402,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423601,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 423701,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 423704,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431001,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431003,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431004,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431005,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431006,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431007,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431009,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431010,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431011,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431107,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431109,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431114,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431119,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431134,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431139,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431140,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431146,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431154,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431201,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431202,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 431210,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 440001,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440002,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440003,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440004,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440005,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440006,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440007,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440008,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440009,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440010,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440011,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440012,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440013,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440014,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440015,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440016,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440017,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440018,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440019,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440020,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440021,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440022,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440023,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440024,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440025,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440026,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440027,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440028,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440029,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440030,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440032,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440033,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440034,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440035,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440036,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 440037,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441001,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441002,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441103,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441104,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441106,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441107,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441108,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441109,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441110,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441111,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441113,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441203,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441302,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441404,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441501,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 452001,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452002,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452003,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452005,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452006,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452007,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452008,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452009,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452010,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452011,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452012,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452013,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452014,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452015,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452016,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452018,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 452020,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453001,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453111,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453112,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453115,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453220,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453331,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453441,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453446,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453551,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453552,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453555,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 453556,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Indore",
      "LOCATION": "Indore"
    },
    {
      "PINCODE": 462001,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462002,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462003,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462004,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462007,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462008,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462010,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462011,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462013,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462016,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462020,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462021,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462022,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462023,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462024,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462026,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462027,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462030,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462031,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462032,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462033,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462036,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462037,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462038,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462039,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462040,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462041,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462042,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462043,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462044,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462045,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462046,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462047,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462066,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462101,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 462120,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 463106,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 463111,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 464993,
      "STATE": "Madhya Pradesh",
      "DISTRICT": "Bhopal",
      "LOCATION": "Bhopal"
    },
    {
      "PINCODE": 500001,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500002,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500003,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500004,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500005,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500006,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500007,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500008,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500009,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500010,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500011,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500012,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500013,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500014,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500015,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500016,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500017,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500018,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500019,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500020,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500021,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500022,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500023,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500024,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500025,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500026,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500027,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500028,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500029,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500030,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500031,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500032,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500033,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500034,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500035,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500036,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500037,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500038,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500039,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500040,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500041,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500042,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500043,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500044,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500045,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500046,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500047,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500048,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500049,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500050,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500051,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500052,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500053,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500054,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500055,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500056,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500057,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500058,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500059,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500060,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500061,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500062,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500063,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500064,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500065,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500066,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500067,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500068,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500069,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500070,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500071,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500072,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500073,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500074,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500075,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500076,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500077,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500078,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500079,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500080,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500081,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500082,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500083,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500084,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500085,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500086,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500087,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500088,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500089,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500090,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500091,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500092,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500093,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500094,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500095,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500096,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500097,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500098,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500100,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500101,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 500103,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {"PINCODE": 500105, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 500107,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501203,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501218,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501301,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501401,
      "STATE": "Telangana",
      "DISTRICT": "Hyderabad",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501504,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501505,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501510,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 501511,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 505001,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505002,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505185,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505186,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505215,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505401,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505415,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505445,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505451,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505469,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505474,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505481,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505505,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505527,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 505531,
      "STATE": "Telangana",
      "DISTRICT": "Karim Nagar",
      "LOCATION": "Karim Nagar"
    },
    {
      "PINCODE": 506001,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506002,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506003,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506004,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506005,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506006,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506007,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506008,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506009,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {"PINCODE": 506010, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 506011,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506013,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506015,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {"PINCODE": 506063, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 506151,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506166,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {"PINCODE": 506234, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 506310,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506313,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506319,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506330,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506331,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {"PINCODE": 506333, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 506342,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {"PINCODE": 506350, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 506359, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 506360, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 506365,
      "STATE": "Telangana",
      "DISTRICT": "Mahabubabad",
      "LOCATION": "Mahabubabad"
    },
    {
      "PINCODE": 506370,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506371,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 506391,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 507001,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507002,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507003,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507157,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507158,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507160,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507163,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507170,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507182,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507183,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507208,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 507318,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 508284,
      "STATE": "Telangana",
      "DISTRICT": "Nalgonda",
      "LOCATION": "Nalgonda"
    },
    {
      "PINCODE": 509325,
      "STATE": "Telangana",
      "DISTRICT": "K.V.Rangareddy",
      "LOCATION": "Hyderabad"
    },
    {
      "PINCODE": 515001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515110,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515134,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515144,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515202,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515211,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515212,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515231,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515261,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515401,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515402,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515411,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515413,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515415,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515425,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515501,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515531,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515541,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515591,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515661,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515671,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515701,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515722,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515751,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515761,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515765,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515775,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515801,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515803,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515812,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515865,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 515867,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Ananthapur",
      "LOCATION": "Ananthapur"
    },
    {
      "PINCODE": 516001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516115,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516126,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516130,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516152,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516162,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516172,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516175,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516203,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516213,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516214,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516227,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516257,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516267,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516269,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516270,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516289,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516309,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516310,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516311,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516312,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516329,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516330,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516339,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516349,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516350,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516356,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516360,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516361,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516362,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516390,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516391,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516434,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516464,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 516502,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Cuddapah",
      "LOCATION": "Cuddapah"
    },
    {
      "PINCODE": 517001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517101,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517102,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517112,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517152,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517214,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517234,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517237,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517247,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517299,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517305,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517319,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517325,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517326,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517352,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517370,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517408,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517424,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517426,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517501,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517502,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517503,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517505,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517506,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517507,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517536,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517569,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517581,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517582,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517583,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517584,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517640,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517644,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517645,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 517646,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Chittoor",
      "LOCATION": "Chittoor"
    },
    {
      "PINCODE": 518001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518006,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518007,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518102,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518112,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518122,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518134,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518155,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518186,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518196,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518216,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518221,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518222,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518301,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518302,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518313,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518343,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518344,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518345,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518346,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518348,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518349,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518350,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518360,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518380,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518385,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518395,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518401,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518422,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518463,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518464,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518466,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518501,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518511,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518513,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518533,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518543,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518553,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518563,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 518599,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Kurnool",
      "LOCATION": "Kurnool"
    },
    {
      "PINCODE": 520001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520006,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520007,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520008,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520010,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520011,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520012,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520013,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 520015,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521101,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521102,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521104,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521105,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521107,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521108,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521121,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521122,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521126,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521133,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521134,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521137,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521139,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521151,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521153,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521157,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521158,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521162,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521165,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521180,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521183,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521190,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521202,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521211,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521212,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521215,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521225,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521226,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521228,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521241,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521245,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521260,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521301,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521311,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521327,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521328,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521333,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521344,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521356,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521366,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521390,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521456,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521457,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 522001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522006,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522007,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522008,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522009,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522016,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522017,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522018,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522019,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522034,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522124,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522202,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {"PINCODE": 522203, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 522212,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522233,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522236,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522256,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522265,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522302,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522303,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522304,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522305,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522307,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522309,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522311,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522312,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522313,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522314,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522316,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522329,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522330,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522402,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522403,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522409,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522410,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522411,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522412,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522413,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522414,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522415,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522421,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522426,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522435,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522501,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522502,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522503,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522508,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522509,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522510,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522601,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522614,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522615,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522616,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522617,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522619,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522647,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522659,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 522663,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 523001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523101,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523104,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523105,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523113,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523135,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523155,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523156,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523157,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523165,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523166,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523167,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523168,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523169,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523187,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523214,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523223,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523226,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523230,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523240,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523247,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523252,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523254,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523260,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523263,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523273,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523274,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523286,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523292,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523301,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523316,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523320,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523327,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523328,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523329,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523330,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523331,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523333,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523336,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523356,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523357,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523367,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523369,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523370,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523371,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 523373,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Prakasam",
      "LOCATION": "Prakasam"
    },
    {
      "PINCODE": 524001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524101,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524132,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524137,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524152,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524304,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524305,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524306,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524307,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524309,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524315,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524319,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524322,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524344,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524345,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524347,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524406,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 524411,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Nellore",
      "LOCATION": "Nellore"
    },
    {
      "PINCODE": 530001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530007,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530008,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530009,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530010, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530011,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530012,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530013,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530014,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530015,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530016,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530017,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530018,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530019, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530020,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530021, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530022,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530023, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530024,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530025, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530026,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530027,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530028,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530029,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530030, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530031,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530032,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530033, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 530034, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530035,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530036, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 530037, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 530038, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 530039, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530040,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530041,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530042, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530043,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530044,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530045,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530046,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530047,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530048,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530049,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {"PINCODE": 530050, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 530051,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530052,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 530053,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531011,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531019,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531021,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531031,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531032,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531033,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531035,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531036,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531055,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531061,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531083,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531126,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531127,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531162,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531163,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531173,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 531219,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 533001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533006,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {"PINCODE": 533007, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 533016,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533101,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533102,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533103,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533104,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533105,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533106,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533107,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533124,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533125,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533126,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533210,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533214,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533215,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533216,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533221,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533223,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533228,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533233,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533235,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533236,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533237,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533238,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533242,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533244,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533251,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533255,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533286,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533287,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533289,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533291,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533292,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533293,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533294,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533296,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533297,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533306,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533308,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533340,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533341,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533342,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533343,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533344,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533346,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533401,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533408,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533429,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533432,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533433,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533434,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533437,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533440,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533444,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533445,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533448,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533449,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533450,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533461,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533462,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533463,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533468,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533577,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 534001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534006,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534007,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534101,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534102,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534111,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534112,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534122,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534123,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534124,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534126,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534145,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534165,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534196,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534198,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534199,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534202,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534206,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534208,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534211,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534215,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534222,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534225,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534235,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534243,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534245,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534260,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534265,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534266,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534267,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534268,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534269,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534275,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534280,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534281,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534301,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534302,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534305,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534312,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534313,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534316,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534320,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534324,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534326,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534330,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534340,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534341,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534342,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534350,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534401,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534425,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534426,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534432,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534447,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534449,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534452,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 535001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535002,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535003,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535004,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 535128,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 535148,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535204,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535213,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535217,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535218,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535221,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535250,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 535270,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535280,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 560001,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560002,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560003,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560004,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560005,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560006,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560007,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560008,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560009,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560010,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560011,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560012,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560013,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560014,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560015,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560016,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560017,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560018,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560019,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560020,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560021,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560022,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560023,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560024,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560025,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560026,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560027,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560028,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560029,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560030,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560031,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560032,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560033,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560034,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560035,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560036,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560037,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560038,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560039,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560040,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560041,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560042,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560043,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560044,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560045,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560046,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560047,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560048,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560049,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560050,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560051,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560052,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560053,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560054,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560055,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560056,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560057,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560058,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560059,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560060,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560061,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560062,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560063,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560064,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560065,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560066,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560067,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560068,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560069,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560070,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560071,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560072,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560073,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560074,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560075,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560076,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560077,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560078,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560079,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560080,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560081,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560082,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560083,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560084,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560085,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560086,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560087,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560090,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560091,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560092,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560093,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560094,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560095,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560096,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560097,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560098,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560099,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560100,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {"PINCODE": 560101, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 560102,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560103,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560104,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560105,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {"PINCODE": 560106, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 560108,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560109,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560110,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560111,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560112,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560113,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560114,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560115,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560116,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560117,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560300,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 560500,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 561201,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562106,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562107,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562108,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562109,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562112,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562114,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562117,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562119,
      "STATE": "Karnataka",
      "DISTRICT": "Bangalore Rural",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562120,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562121,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562125,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562126,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562128,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562138,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562149,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562157,
      "STATE": "Karnataka",
      "DISTRICT": "Bengaluru",
      "LOCATION": "Bangalore"
    },
    {
      "PINCODE": 562159,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562160,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 562161,
      "STATE": "Karnataka",
      "DISTRICT": "Ramanagar",
      "LOCATION": "Ramanagar"
    },
    {
      "PINCODE": 563101,
      "STATE": "Karnataka",
      "DISTRICT": "Kolar",
      "LOCATION": "Kolar"
    },
    {
      "PINCODE": 563114,
      "STATE": "Karnataka",
      "DISTRICT": "Kolar",
      "LOCATION": "Kolar"
    },
    {
      "PINCODE": 563130,
      "STATE": "Karnataka",
      "DISTRICT": "Kolar",
      "LOCATION": "Kolar"
    },
    {
      "PINCODE": 563131,
      "STATE": "Karnataka",
      "DISTRICT": "Kolar",
      "LOCATION": "Kolar"
    },
    {
      "PINCODE": 563133,
      "STATE": "Karnataka",
      "DISTRICT": "Kolar",
      "LOCATION": "Kolar"
    },
    {
      "PINCODE": 563135,
      "STATE": "Karnataka",
      "DISTRICT": "Kolar",
      "LOCATION": "Kolar"
    },
    {
      "PINCODE": 570001,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570002,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570003,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570004,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570005,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570006,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570007,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570008,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570009,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570010,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570011,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570012,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {"PINCODE": 570013, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 570014,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570015,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570016,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570017,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570018,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570019,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570020,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570021,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570022,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570023,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570024,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570025,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570026,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570027,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570028,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570029,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570030,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570031,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 570032,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571105,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571106,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571107,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571111,
      "STATE": "Karnataka",
      "DISTRICT": "Chamrajnagar",
      "LOCATION": "Chamrajnagar"
    },
    {
      "PINCODE": 571114,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571125,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571128,
      "STATE": "Karnataka",
      "DISTRICT": "Chamrajnagar",
      "LOCATION": "Chamrajnagar"
    },
    {
      "PINCODE": 571130,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571187,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571301,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571302,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571311,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571313,
      "STATE": "Karnataka",
      "DISTRICT": "Chamrajnagar",
      "LOCATION": "Chamrajnagar"
    },
    {
      "PINCODE": 571319,
      "STATE": "Karnataka",
      "DISTRICT": "Chamrajnagar",
      "LOCATION": "Chamrajnagar"
    },
    {
      "PINCODE": 571320,
      "STATE": "Karnataka",
      "DISTRICT": "Chamrajnagar",
      "LOCATION": "Chamrajnagar"
    },
    {
      "PINCODE": 571342,
      "STATE": "Karnataka",
      "DISTRICT": "Chamrajnagar",
      "LOCATION": "Chamrajnagar"
    },
    {
      "PINCODE": 571401,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571402,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571404,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571405,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571415,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571416,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571419,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571422,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571424,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571425,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571427,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571429,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571433,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571434,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571435,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571438,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571440,
      "STATE": "Karnataka",
      "DISTRICT": "Chamrajnagar",
      "LOCATION": "Chamrajnagar"
    },
    {
      "PINCODE": 571445,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571450,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571477,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571478,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571491,
      "STATE": "Karnataka",
      "DISTRICT": "CHAMRAJNAGAR",
      "LOCATION": "CHAMRAJNAGAR"
    },
    {
      "PINCODE": 571602,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571606,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571607,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571610,
      "STATE": "Karnataka",
      "DISTRICT": "Mysuru",
      "LOCATION": "Mysuru"
    },
    {
      "PINCODE": 571807,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 571811,
      "STATE": "Karnataka",
      "DISTRICT": "Mandya",
      "LOCATION": "Mandya"
    },
    {
      "PINCODE": 572101,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572102,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572103,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572104,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572105,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572106,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572107,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572118,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572122,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572138,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572140,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572168,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572216,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 572223,
      "STATE": "Karnataka",
      "DISTRICT": "Tumakuru",
      "LOCATION": "Tumakuru"
    },
    {
      "PINCODE": 573101,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573102,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573103,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573115,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573116,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573127,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573201,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573202,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573211,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573225,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 574104,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 574116,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 574118,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 574129,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 574142,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574144,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574146,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574150,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574151,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574153,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574154,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574197,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574199,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574201,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574203,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574219,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574225,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574226,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574227,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574231,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574240,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574267,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574279,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574324,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574325,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574326,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574509,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575003,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575004,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575005,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575006,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575007,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575008,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575009,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575010,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575011,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575013,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575014,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575015,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575016,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575017,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575019,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575022,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575023,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575025,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575027,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575028,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575029,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575030,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 576101,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576102,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576103,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576104,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576106,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576107,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576108,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576124,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576213,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576215,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576216,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576218,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576225,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576228,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576232,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576247,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576282,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576283,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 577001,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577002,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577003,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577004,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577005,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577006,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577201,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577204,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577205,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577213,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577217,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577229,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577231,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577301,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577302,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577401,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577416,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577423,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577430,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577432,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577435,
      "STATE": "Karnataka",
      "DISTRICT": "Shivamogga",
      "LOCATION": "Shivamogga"
    },
    {
      "PINCODE": 577530,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577552,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577556,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 577601,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 580001,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580002,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580003,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580004,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580005,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580006,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580007,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580008,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580009,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580020,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580021,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580023,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580024,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580025,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580026,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580027,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580028,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580029,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580030,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580031,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580032,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580112,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580114,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 580118,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {"PINCODE": 580201, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 581103,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 581105,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 581113,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 581195,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 581196,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 581204,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 581207,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 581209,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 582201,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 582208,
      "STATE": "Karnataka",
      "DISTRICT": "Dharwad",
      "LOCATION": "Dharwad"
    },
    {
      "PINCODE": 583131,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 590001,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590003,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590005,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590006,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590008,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590009,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590010,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590011,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590015,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590016,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590017,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590018,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590019,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 590020,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591102,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591110,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591113,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591115,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591116,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591118,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591124,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591126,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591130,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591136,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591147,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591153,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591173,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591201,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591213,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591216,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591217,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591218,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591219,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591220,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591223,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591224,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591226,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591228,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591229,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591230,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591231,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591234,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591237,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591239,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591243,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591263,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591287,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591302,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591304,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591306,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591307,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591308,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591309,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591310,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591311,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591312,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591313,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591314,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591315,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591317,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591340,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591345,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 591346,
      "STATE": "Karnataka",
      "DISTRICT": "Belagavi",
      "LOCATION": "Belagavi"
    },
    {
      "PINCODE": 600001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600011,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600013,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600014,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600015,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600016,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600017,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600018,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600019,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600020,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600021,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600022,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600023,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600024,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600025,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600026,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600027,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600028,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600029,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600030,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600031,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600032,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600033,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600034,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600035,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600036,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600037,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600038,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600039,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600040,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600041,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600042,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600043,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600044,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600045,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600046,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600047,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600048,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600049,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600050,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600052,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600053,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600054,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600055,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600056,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600057,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600058,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600059,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600060,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600061,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600062,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600063,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600064,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600065,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600066,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600067,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600068,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600069,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600070,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600071,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600072,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600073,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600074,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600075,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600076,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600077,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600078,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600079,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600080,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600081,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600082,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600083,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600084,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600085,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600086,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600087,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600088,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600089,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600090,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600091,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600092,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600093,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600094,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600095,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600096,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600097,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600098,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600099,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600100,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600111,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600113,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600114,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600115,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600116,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600117,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600118,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Chennai",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600119,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600120,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600122,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600123,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600124,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600125,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600126,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600127,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600128,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600129,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600130,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 600131,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601206,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 601302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602021,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602023,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602024,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602025,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602026,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602027,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 602117,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603111,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603127,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603209,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603210,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603211,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603306,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603308,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603313,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603314,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603405,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 603406,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 605001,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605002,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605003,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605004,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605005,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605006,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 605008,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605009,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605010,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605011,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605012,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605013,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605014,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605101,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605104,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 605110,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605111,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 605501,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 607001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607205,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 607403,
      "STATE": "Pondicherry",
      "DISTRICT": "Pondicherry",
      "LOCATION": "Pondicherry"
    },
    {
      "PINCODE": 608801,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Cuddalore",
      "LOCATION": "Cuddalore"
    },
    {
      "PINCODE": 612001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613503,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613504,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 613602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614211,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614626,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thanjavur",
      "LOCATION": "Thanjavur"
    },
    {
      "PINCODE": 614902,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 620001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620011,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620013,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620014,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620015,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620016,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620017,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620018,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620019,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620020,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620021,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620022,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620023,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620024,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620025,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620026,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 620102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621111,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621216,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621218,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ariyalur",
      "LOCATION": "Ariyalur"
    },
    {
      "PINCODE": 621601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621703,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621706,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 621712,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 624001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624206,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624208,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624215,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624306,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624307,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624308,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624617,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624620,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624622,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 624701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624702,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624705,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624707,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624708,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624709,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624710,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624801,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624802,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 625001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625011,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625014,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625015,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625016,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625017,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625018,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625019,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625020,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625021,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625022,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625023,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625052,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625113,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625122,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625123,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625124,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625125,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625205,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625207,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625209,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625214,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625218,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625221,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625234,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625305,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625503,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625512,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625514,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625529,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625531,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625536,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625537,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625562,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {"PINCODE": 625566, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 625577,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625604,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625704,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625706,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625707,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625708,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626123,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626130,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626133,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626134,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626138,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626149,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626531,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626532,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626533,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626612,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 627001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627011,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627113,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627114,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627116,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627118,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627119,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627121,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627129,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627151,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627152,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627351,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627352,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627353,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627354,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627356,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627357,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627358,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627359,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627412,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627413,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627414,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627416,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627417,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627418,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627420,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627421,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627422,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627425,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627426,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627427,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627428,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627431,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627436,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627451,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627452,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627453,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627551,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627604,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627654,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627657,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627659,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627719,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627753,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627755,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627756,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627759,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627760,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627761,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627801,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627808,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627809,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627810,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627811,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627814,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627817,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627818,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627851,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627852,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627855,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627856,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627859,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627867,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 627954,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 628502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tirunelveli",
      "LOCATION": "Tirunelveli"
    },
    {
      "PINCODE": 630211,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630321,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630411,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630551,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630555,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630557,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630561,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630562,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630606,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630611,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630709,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 631051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 631203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631210,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631551,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631552,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631553,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631561,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631604,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631605,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631606,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanchipuram",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 632002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632013,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {"PINCODE": 632052, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 632053, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {"PINCODE": 632054, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 632055,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632057,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632058,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632059,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632404,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632507,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 632509,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632515,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632516,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632517,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 632519,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Vellore",
      "LOCATION": "Vellore"
    },
    {
      "PINCODE": 635103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635113,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635117,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635118,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635121,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635124,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 635126,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Krishnagiri",
      "LOCATION": "Krishnagiri"
    },
    {
      "PINCODE": 636001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636011,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636013,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636014,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636015,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636016,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636017,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636030,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636111,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636115,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636122,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636140,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636305,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636306,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636307,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636308,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636309,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636351,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636404,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636406,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636451,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636452,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636453,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636454,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636455,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636456,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636458,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636463,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636503,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 637104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 637209,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 637211,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 637303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 637304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 637501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 637502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 637504,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 637508,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 638001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 638007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 638009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638011,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638052,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638053,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638054,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638057,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638060,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 638104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638111,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638115,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638116,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638151,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638153,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638154,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638183,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Namakkal",
      "LOCATION": "Namakkal"
    },
    {
      "PINCODE": 638301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638312,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638313,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638315,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638316,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638452,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638453,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638455,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638459,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638476,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638503,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638505,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638506,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638512,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638656,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638660,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638661,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638751,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 638752,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 639101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 639103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruchirappalli",
      "LOCATION": "Tiruchirappalli"
    },
    {
      "PINCODE": 639201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Erode",
      "LOCATION": "Erode"
    },
    {
      "PINCODE": 641001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641009,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641010,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641011,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641012,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641013,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641014,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641015,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641016,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641017,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641018,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641019,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641020,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641021,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641022,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641023,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641024,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641025,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641026,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641027,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641028,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641029,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641030,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641031,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641032,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641033,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641034,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641035,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641036,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641037,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641038,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641039,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641040,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641041,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641042,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641043,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641044,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641045,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641046,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641047,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641048,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641049,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641050,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641062,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641111,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641112,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641113,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641114,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641407,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641604,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641605,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641606,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641607,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641652,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641653,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641654,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641658,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641659,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641662,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641663,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641664,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641665,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641666,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641668,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641670,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641671,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 641687,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642007,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642114,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642120,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642123,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642129,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642134,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {
      "PINCODE": 642205,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Coimbatore",
      "LOCATION": "Coimbatore"
    },
    {"PINCODE": 652005, "STATE": 0, "DISTRICT": 0, "LOCATION": 0},
    {
      "PINCODE": 700001,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700002,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700003,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700004,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700005,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700006,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700007,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700008,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700009,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700010,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700011,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700012,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700013,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700014,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700015,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700016,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700017,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700018,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700019,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700020,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700021,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700022,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700023,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700024,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700025,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700026,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700027,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700028,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700029,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700030,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700031,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700032,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700033,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700034,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700035,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700036,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700037,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700038,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700039,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700040,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700041,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700042,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700043,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700044,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700045,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700046,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700047,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700048,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700049,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700050,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700051,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700052,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700053,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700054,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700055,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700056,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700057,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700058,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700059,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700060,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700061,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700062,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700063,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700064,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700065,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700066,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700067,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700068,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700069,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700070,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700071,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700072,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700073,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700074,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700075,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700076,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700077,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700078,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700079,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700080,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700081,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700082,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700083,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700084,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700085,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700086,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700087,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700088,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700089,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700090,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700091,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700092,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700093,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700094,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700095,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700096,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700097,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700098,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700099,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700100,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700101,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700102,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700103,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700104,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700105,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700106,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700107,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700108,
      "STATE": "West Bengal",
      "DISTRICT": "Kolkata",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700109,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700110,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700111,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700112,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700113,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700114,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700115,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700116,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700117,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700118,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700119,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700120,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700121,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700122,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700123,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700124,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700125,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700126,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700127,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700128,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700129,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700130,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700131,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700132,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700133,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700134,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700135,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700136,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700137,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700138,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700139,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700140,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700141,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700142,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700143,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700144,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700145,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700146,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700147,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700148,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700149,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700150,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700151,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700152,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700153,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700154,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700155,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700156,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700157,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700158,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700159,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700160,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700161,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 700162,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711101,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711102,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711103,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711104,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711105,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711106,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711107,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711108,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711109,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711110,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711111,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711112,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711113,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711114,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711115,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711201,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711202,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711203,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711204,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711205,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711206,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711225,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711226,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711227,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711301,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711302,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711303,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711304,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711305,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711306,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711307,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711308,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711309,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711310,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711312,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711313,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711314,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711315,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711316,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711317,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711322,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711324,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711325,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711326,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711328,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711401,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711403,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711404,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711405,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711408,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711409,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711410,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711411,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711412,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711413,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711414,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711415,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 711416,
      "STATE": "West Bengal",
      "DISTRICT": "Howrah",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712101,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712102,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712103,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712104,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712105,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712121,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712122,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712123,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712124,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712125,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712134,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712135,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712136,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712137,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712138,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712139,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712146,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712147,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712148,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712149,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712152,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712154,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712156,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712157,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712201,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712202,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712203,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712204,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712221,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712222,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712223,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712232,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712233,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712234,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712235,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712245,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712246,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712247,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712248,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712249,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712250,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712258,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712301,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712302,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712303,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712304,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712305,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712306,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712308,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712309,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712310,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712311,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712401,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712402,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712403,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712404,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712405,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712406,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712407,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712408,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712409,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712410,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712411,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712412,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712413,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712414,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712415,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712416,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712417,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712418,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712419,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712420,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712422,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712423,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712424,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712426,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712428,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712429,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712501,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712502,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712503,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712504,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712512,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712513,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712514,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712515,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712601,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712602,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712611,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712612,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712613,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712614,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712615,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712616,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712617,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712701,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712702,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712704,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712705,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712706,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712707,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 712708,
      "STATE": "West Bengal",
      "DISTRICT": "Hooghly",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 713101,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713102,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713103,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713121,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713122,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713124,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713125,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713126,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713127,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713128,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713129,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713130,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713131,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713132,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713140,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713141,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713142,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713143,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713144,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713145,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713146,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713147,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713148,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713149,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713151,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713152,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713153,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713154,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713166,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713202,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713204,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713205,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713206,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713207,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713209,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713212,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713213,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713214,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713216,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713217,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713322,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713323,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713337,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713338,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713342,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713346,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713347,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713358,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713362,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713363,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713376,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713378,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713381,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713384,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713401,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713403,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713404,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713405,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713406,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713407,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713408,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713409,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713420,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713421,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713422,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713423,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713424,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713426,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713427,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713428,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713502,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713512,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713515,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713519,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 713520,
      "STATE": "West Bengal",
      "DISTRICT": "Purba Bardhaman",
      "LOCATION": "Purba Bardhaman"
    },
    {
      "PINCODE": 721130,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721131,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721134,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721135,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721137,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721139,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721151,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721152,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721153,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721154,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721158,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721171,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721172,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721253,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721401,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721403,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721405,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721420,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721422,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721423,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721425,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721427,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721428,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721429,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721430,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721431,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721432,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721433,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721434,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721435,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721437,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721438,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721439,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721440,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721441,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721442,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721443,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721444,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721446,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721447,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721448,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721449,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721450,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721452,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721453,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721454,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721455,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721456,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721458,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721463,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721601,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721602,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721603,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721604,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721606,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721607,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721624,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721625,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721626,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721627,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721628,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721629,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721631,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721632,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721633,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721634,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721635,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721636,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721637,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721641,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721642,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721643,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721644,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721645,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721646,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721647,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721648,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721649,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721650,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721651,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721652,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721653,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721654,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721655,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721656,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721657,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721658,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 721659,
      "STATE": "West Bengal",
      "DISTRICT": "East Midnapore",
      "LOCATION": "East Midnapore"
    },
    {
      "PINCODE": 743122,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743123,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743124,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743125,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743126,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743127,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743128,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743129,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743130,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743133,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743134,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743135,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743136,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743144,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743145,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743165,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743166,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743193,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743194,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743195,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743221,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743222,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743223,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743232,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743233,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743234,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743235,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743245,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743247,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743248,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743249,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743251,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743252,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743262,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743263,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743268,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743269,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743270,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743271,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743272,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743273,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743274,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743276,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743286,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743287,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743289,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743290,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743291,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743292,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743293,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743294,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743295,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743297,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743299,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743312,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743318,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743329,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743330,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743331,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743332,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743336,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743337,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743338,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743345,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743347,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743348,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743349,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743351,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743352,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743354,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743355,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743356,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743357,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743363,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743368,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743370,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743371,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743372,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743373,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743374,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743375,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743376,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743377,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743378,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743383,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743384,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743385,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743387,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743389,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743390,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743391,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743392,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743395,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743396,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743398,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743399,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743401,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743405,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743411,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743412,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743413,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743414,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743422,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743423,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743424,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743425,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743426,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743427,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743428,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743429,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743435,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743437,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743438,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743439,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743440,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743441,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743442,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743443,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743445,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743446,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743456,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743486,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743502,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743503,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743504,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743507,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743513,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743601,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743603,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743606,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743609,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743610,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743611,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743613,
      "STATE": "West Bengal",
      "DISTRICT": "South 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743701,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743702,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743703,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743704,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743706,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743708,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743710,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 743711,
      "STATE": "West Bengal",
      "DISTRICT": "North 24 Parganas",
      "LOCATION": "Kolkata MR"
    },
    {
      "PINCODE": 824213,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 824216,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 824218,
      "STATE": "Maharashtra",
      "DISTRICT": "Aurangabad",
      "LOCATION": "Aurangabad"
    },
    {
      "PINCODE": 413709,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414102,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414603,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414302,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414105,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413710,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413706,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413716,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413726,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413707,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413722,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414303,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 414605,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 413737,
      "STATE": "Maharashtra",
      "DISTRICT": "Ahmed Nagar",
      "LOCATION": "Ahmed Nagar"
    },
    {
      "PINCODE": 442302,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444601,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444602,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444603,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444604,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444606,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444607,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444701,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444713,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444718,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444726,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444801,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444803,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444804,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444805,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444810,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444811,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444812,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444814,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444815,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444818,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444819,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444903,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444904,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444909,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444911,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444913,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444914,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 444921,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 431108,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 431138,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 431152,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 441811,
      "STATE": "Maharashtra",
      "DISTRICT": "Amravati",
      "LOCATION": "Amravati"
    },
    {
      "PINCODE": 441904,
      "STATE": "Maharashtra",
      "DISTRICT": "Bhandara",
      "LOCATION": "Bhandara"
    },
    {
      "PINCODE": 441917,
      "STATE": "Maharashtra",
      "DISTRICT": "Bhandara",
      "LOCATION": "Bhandara"
    },
    {
      "PINCODE": 441920,
      "STATE": "Maharashtra",
      "DISTRICT": "Bhandara",
      "LOCATION": "Bhandara"
    },
    {
      "PINCODE": 443001,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443002,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443101,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443103,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443104,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443105,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443112,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443201,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443202,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443203,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443204,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443209,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443301,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443303,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443305,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443306,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443307,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443404,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 443406,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 444203,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 444301,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 444306,
      "STATE": "Maharashtra",
      "DISTRICT": "Buldhana",
      "LOCATION": "Buldhana"
    },
    {
      "PINCODE": 441601,
      "STATE": "Maharashtra",
      "DISTRICT": "Gondia",
      "LOCATION": "Gondia"
    },
    {
      "PINCODE": 441614,
      "STATE": "Maharashtra",
      "DISTRICT": "Gondia",
      "LOCATION": "Gondia"
    },
    {
      "PINCODE": 441614,
      "STATE": "Maharashtra",
      "DISTRICT": "Gondia",
      "LOCATION": "Gondia"
    },
    {
      "PINCODE": 441614,
      "STATE": "Maharashtra",
      "DISTRICT": "Gondia",
      "LOCATION": "Gondia"
    },
    {
      "PINCODE": 440031,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441101,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441105,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441114,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441116,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441123,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441201,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441304,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441401,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441402,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441403,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441406,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441408,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441409,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441502,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441503,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 441504,
      "STATE": "Maharashtra",
      "DISTRICT": "Nagpur",
      "LOCATION": "Nagpur"
    },
    {
      "PINCODE": 422108,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 422307,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423114,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423211,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 423304,
      "STATE": "Maharashtra",
      "DISTRICT": "Nashik",
      "LOCATION": "Nashik"
    },
    {
      "PINCODE": 442001,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442005,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442006,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442101,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442103,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442104,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442105,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442107,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442110,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442201,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442204,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442301,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442303,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 442306,
      "STATE": "Maharashtra",
      "DISTRICT": "Wardha",
      "LOCATION": "Wardha"
    },
    {
      "PINCODE": 444105,
      "STATE": "Maharashtra",
      "DISTRICT": "Washim",
      "LOCATION": "Washim"
    },
    {
      "PINCODE": 444403,
      "STATE": "Maharashtra",
      "DISTRICT": "Washim",
      "LOCATION": "Washim"
    },
    {
      "PINCODE": 444409,
      "STATE": "Maharashtra",
      "DISTRICT": "Washim",
      "LOCATION": "Washim"
    },
    {
      "PINCODE": 444503,
      "STATE": "Maharashtra",
      "DISTRICT": "Washim",
      "LOCATION": "Washim"
    },
    {
      "PINCODE": 444505,
      "STATE": "Maharashtra",
      "DISTRICT": "Washim",
      "LOCATION": "Washim"
    },
    {
      "PINCODE": 444507,
      "STATE": "Maharashtra",
      "DISTRICT": "Washim",
      "LOCATION": "Washim"
    },
    {
      "PINCODE": 444512,
      "STATE": "Maharashtra",
      "DISTRICT": "Washim",
      "LOCATION": "Washim"
    },
    {
      "PINCODE": 387240,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388180,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 388620,
      "STATE": "Gujarat",
      "DISTRICT": "Anand",
      "LOCATION": "Anand"
    },
    {
      "PINCODE": 361001,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361002,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361003,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361005,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361006,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361007,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361008,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361009,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361012,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361013,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 361142,
      "STATE": "Gujarat",
      "DISTRICT": "Jamnagar",
      "LOCATION": "Jamnagar"
    },
    {
      "PINCODE": 387003,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387305,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387335,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387380,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387530,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 387560,
      "STATE": "Gujarat",
      "DISTRICT": "Kheda",
      "LOCATION": "Kheda"
    },
    {
      "PINCODE": 395015,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 395021,
      "STATE": "Gujarat",
      "DISTRICT": "Surat",
      "LOCATION": "Surat"
    },
    {
      "PINCODE": 391430,
      "STATE": "Gujarat",
      "DISTRICT": "Vadodara",
      "LOCATION": "Vadodara"
    },
    {
      "PINCODE": 624101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624213,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624216,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624228,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sitharevu",
      "LOCATION": "Sitharevu"
    },
    {
      "PINCODE": 624312,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sitharevu",
      "LOCATION": "Sitharevu"
    },
    {
      "PINCODE": 624314,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sitharevu",
      "LOCATION": "Sitharevu"
    },
    {
      "PINCODE": 624316,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624404,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624610,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624615,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624624,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624703,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624711,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624714,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 624803,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dindigul",
      "LOCATION": "Dindigul"
    },
    {
      "PINCODE": 638327,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dalavaipettai",
      "LOCATION": "Dalavaipettai"
    },
    {
      "PINCODE": 638710,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Dalavaipettai",
      "LOCATION": "Dalavaipettai"
    },
    {
      "PINCODE": 629001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629151,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629154,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629155,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629156,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629157,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629158,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629159,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629160,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629161,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629164,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629165,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629166,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629167,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629168,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629169,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629173,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629174,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629176,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629177,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629178,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629179,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629180,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629181,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629183,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629187,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629188,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629189,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629190,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629191,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629193,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629194,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629195,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629197,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629252,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629253,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629305,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629504,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629702,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629704,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629707,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629708,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629801,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629803,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629805,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629806,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629808,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629809,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629810,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629852,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629854,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629855,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629901,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 629902,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Kanyakumari",
      "LOCATION": "Kanyakumari"
    },
    {
      "PINCODE": 625051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625114,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625116,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625121,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625126,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625206,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625217,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 625504,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626512,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626513,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626516,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626518,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626523,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626535,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626537,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626566,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626702,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626706,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 626709,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 636815,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638059,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638117,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638606,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638607,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638652,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638653,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638663,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638665,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638668,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638671,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638687,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638696,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638802,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 638806,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 641102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Madurai",
      "LOCATION": "Madurai"
    },
    {
      "PINCODE": 609001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609111,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609113,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609115,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609118,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609205,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609305,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609306,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609307,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609310,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609313,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609314,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609406,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609503,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609505,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609506,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609703,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609704,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609801,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609805,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609806,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609809,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 609810,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 610005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 610106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 610201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 610212,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 611001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 611003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 611103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 611106,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 611117,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 611118,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 612201,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 612203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 614712,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 614807,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 614810,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 614820,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Nagapattinam",
      "LOCATION": "Nagapattinam"
    },
    {
      "PINCODE": 614616,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 614805,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 621316,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622407,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622411,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622422,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 622502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Pudukkottai",
      "LOCATION": "Pudukkottai"
    },
    {
      "PINCODE": 623115,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623120,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623135,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623309,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623404,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623406,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623409,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623503,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623504,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623514,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623515,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623516,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623517,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623519,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623520,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623521,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623523,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623526,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623529,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623533,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623538,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623539,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623544,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623566,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623604,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623605,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623704,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623706,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623707,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623712,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623719,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623801,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623802,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623804,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623806,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623807,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 623808,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Ramanathapuram",
      "LOCATION": "Ramanathapuram"
    },
    {
      "PINCODE": 636102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636117,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636130,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636139,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 636462,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 637026,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 637109,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 637217,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Salem",
      "LOCATION": "Salem"
    },
    {
      "PINCODE": 630001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630206,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630212,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630215,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630303,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630305,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630306,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630307,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630309,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630310,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630311,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630318,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630408,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630413,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630505,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630612,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 630702,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Sivaganga",
      "LOCATION": "Sivaganga"
    },
    {
      "PINCODE": 625513,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625515,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625516,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625517,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625518,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625519,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625520,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625521,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625522,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625525,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625526,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625528,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625530,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625538,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625540,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625547,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625552,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625556,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625572,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625579,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625582,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 625605,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627124,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627131,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627361,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627435,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627724,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627763,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627773,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627821,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Theni",
      "LOCATION": "Theni"
    },
    {
      "PINCODE": 627956,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruneveli",
      "LOCATION": "Tiruneveli"
    },
    {
      "PINCODE": 631208,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631209,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 631304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvallur",
      "LOCATION": "Chennai MR"
    },
    {
      "PINCODE": 604403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 604405,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 604407,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 604408,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 604410,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 604504,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 604601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606603,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606704,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606705,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606707,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606710,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606754,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606801,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606803,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606804,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606808,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 606811,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 631701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 631702,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 632301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 635703,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvannamalai",
      "LOCATION": "Tiruvannamalai"
    },
    {
      "PINCODE": 609502,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610051,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610104,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610105,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610113,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610114,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610205,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 610211,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 612601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 612701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 612704,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614014,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614016,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614020,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614028,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614403,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614702,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614703,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614710,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614713,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614719,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 614738,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Tiruvarur",
      "LOCATION": "Tiruvarur"
    },
    {
      "PINCODE": 628001,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628002,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628003,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628004,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628005,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628006,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628008,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628101,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628102,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628208,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628209,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628212,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628214,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628215,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628217,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628218,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628219,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628221,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628223,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628228,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628229,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628251,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628253,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628304,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628501,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628612,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628614,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628615,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628616,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628617,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628618,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628619,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628620,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628621,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628624,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628625,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628655,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628656,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628702,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628703,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628704,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628705,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628714,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628717,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628722,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628723,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628724,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628726,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628752,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628809,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628851,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628901,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628903,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628908,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628911,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 628952,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 626053,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Thoothukudi",
      "LOCATION": "Thoothukudi"
    },
    {
      "PINCODE": 626110,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626117,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626121,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626122,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626124,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626125,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626137,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626140,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626141,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626142,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626143,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626144,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626145,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626154,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626159,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626161,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626177,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626189,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 626190,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Virudhunagar",
      "LOCATION": "Virudhunagar"
    },
    {
      "PINCODE": 522101,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 533256,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533347,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533348,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533349,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533350,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533351,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 535558,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535501,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 521175,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 521185,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 535591,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 534460,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 522270,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 522273,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 521235,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 522111,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 533435,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 533446,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 535525,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 532001,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532005,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532127,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532168,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532185,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532186,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532201,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532203,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532213,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532221,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532222,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532312,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532322,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532401,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532402,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532404,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532410,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532421,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532428,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532440,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532457,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 532460,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Srikakulam",
      "LOCATION": "Srikakulam"
    },
    {
      "PINCODE": 533212,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 535522,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 521178,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Krishna",
      "LOCATION": "Krishna"
    },
    {
      "PINCODE": 535463,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535527,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535124,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 531133,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Visakhapatnam",
      "LOCATION": "Visakhapatnam"
    },
    {
      "PINCODE": 533295,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 522102,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 535220,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 535581,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 522238,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Guntur",
      "LOCATION": "Guntur"
    },
    {
      "PINCODE": 535502,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 533290,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 535594,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 533008,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "East Godavari",
      "LOCATION": "East Godavari"
    },
    {
      "PINCODE": 535559,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "Vizianagaram",
      "LOCATION": "Vizianagaram"
    },
    {
      "PINCODE": 534435,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534444,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 534455,
      "STATE": "Andhra Pradesh",
      "DISTRICT": "West Godavari",
      "LOCATION": "West Godavari"
    },
    {
      "PINCODE": 574164,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574165,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574166,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574169,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574179,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574189,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574266,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 575020,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 577007,
      "STATE": "Karnataka",
      "DISTRICT": "Davangere",
      "LOCATION": "Davangere"
    },
    {
      "PINCODE": 573134,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 573226,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 577119,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 576126,
      "STATE": "Karnataka",
      "DISTRICT": "Hassan",
      "LOCATION": "Hassan"
    },
    {
      "PINCODE": 576127,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576201,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 576254,
      "STATE": "Karnataka",
      "DISTRICT": "Udupi",
      "LOCATION": "Udupi"
    },
    {
      "PINCODE": 562105,
      "STATE": "Karnataka",
      "DISTRICT": "Chikkaballapur",
      "LOCATION": "Chikkaballapur"
    },
    {
      "PINCODE": 562104,
      "STATE": "Karnataka",
      "DISTRICT": "Chikkaballapur",
      "LOCATION": "Chikkaballapur"
    },
    {
      "PINCODE": 562103,
      "STATE": "Karnataka",
      "DISTRICT": "Chikkaballapur",
      "LOCATION": "Chikkaballapur"
    },
    {
      "PINCODE": 562102,
      "STATE": "Karnataka",
      "DISTRICT": "Chikkaballapur",
      "LOCATION": "Chikkaballapur"
    },
    {
      "PINCODE": 562101,
      "STATE": "Karnataka",
      "DISTRICT": "Chikkaballapur",
      "LOCATION": "Chikkaballapur"
    },
    {
      "PINCODE": 575018,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574173,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574148,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574145,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 574143,
      "STATE": "Karnataka",
      "DISTRICT": "Dakshina Kannada",
      "LOCATION": "Dakshina Kannada"
    },
    {
      "PINCODE": 507305,
      "STATE": "Telangana",
      "DISTRICT": "Khammam",
      "LOCATION": "Khammam"
    },
    {
      "PINCODE": 502381,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502331,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502303,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502255,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502248,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502130,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502125,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502117,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502115,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502113,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502110,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502109,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502101,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 713386,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713383,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713377,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713375,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713371,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713369,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713368,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713365,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713364,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713360,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713359,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713357,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713343,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713341,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713340,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713339,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713336,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713335,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713334,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713333,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713332,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713331,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713325,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713324,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713315,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713310,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713305,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713304,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713303,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713302,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 713301,
      "STATE": "West Bengal",
      "DISTRICT": "Paschim Bardhaman",
      "LOCATION": "Paschim Bardhaman"
    },
    {
      "PINCODE": 607207,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 607204,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 607203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 607107,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605755,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605701,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605652,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605602,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605601,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605402,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605401,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605301,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605203,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605202,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605108,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 605103,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 604302,
      "STATE": "Tamil Nadu",
      "DISTRICT": "Villupuram",
      "LOCATION": "Villupuram"
    },
    {
      "PINCODE": 506329,
      "STATE": "Telangana",
      "DISTRICT": "Warangal",
      "LOCATION": "Warangal"
    },
    {
      "PINCODE": 502325,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502319,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502305,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502300,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    },
    {
      "PINCODE": 502032,
      "STATE": "Telangana",
      "DISTRICT": "Medak",
      "LOCATION": "Medak"
    }
  ];
}
