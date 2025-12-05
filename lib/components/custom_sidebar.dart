import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constant/api.dart';
import '../common/constant/colors_constant.dart';
import '../common/constant/default_constant.dart';
import '../common/widgets/log_in.dart';
import '../controller/controller.dart';
import '../screens/leads/view_customer.dart';
import '../screens/dashboard.dart';
import '../screens/employee/employee_screen.dart';
import '../screens/employee/role_management.dart';
import '../screens/leads/disqualified_lead.dart';
import '../screens/leads/prospects.dart';
import '../screens/leads/qualified.dart';
import '../screens/leads/suspects.dart';
import '../screens/leads/target_leads.dart';
import '../screens/records/records.dart';
import '../screens/reminder/reminder_page.dart';
import '../screens/settings/general_settings.dart';
import '../screens/settings/reminder_settings.dart';

class SideBar extends StatelessWidget {

  const SideBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    RxBool isSettingsHovered = false.obs;
    return Obx(() => controllers.isLeftOpen.value
        ? Container(
      width: 150,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: "Click to close the side panel.",
                  child: InkWell(
                    focusColor: Colors.transparent,
                    onTap: () {
                      controllers.isLeftOpen.value = !controllers.isLeftOpen.value;
                    },
                    child: CircleAvatar(
                      backgroundColor: colorsConst.secondary,
                      child: const Icon(Icons.chevron_left, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            CustomText(text:  controllers.storage.read("f_name") ?? "",
              size: 20,
              isBold: true,
              isCopy: true,
            ),
            Image.asset(logo),
            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 0,
              icon: Icons.dashboard_outlined,
              selectedImage: "assets/images/s_dash.png",
              unSelectedImage: "assets/images/u_dash.png",
              label: constValue.dashboard,
              page: const NewDashboard(),
            ),
            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 1,
              icon: Icons.remove_red_eye_outlined,
              label: controllers.leadCategoryList[0]["value"],
              selectedImage: "assets/images/s_suspects.png",
              unSelectedImage: "assets/images/u_suspects.png",
              onPreTap: () {
                // controllers.selectedMonth.value = null;
                // controllers.selectedProspectSortBy.value = "Today";
                controllers.isLead.value = true;
              },
              page: const Suspects(),
            ),

            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 2,
              icon: Icons.flag_outlined,
              label: controllers.leadCategoryList[1]["value"],
              selectedImage: "assets/images/s_prospects.png",
              unSelectedImage: "assets/images/u_prospects.png",
              onPreTap: () {
                // controllers.selectedPMonth.value = null;
                // controllers.selectedQualifiedSortBy.value = "Today";
              },
              page: const Prospects(),
            ),

            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 3,
              icon: Icons.verified_outlined,
              label: controllers.leadCategoryList[2]["value"],
              selectedImage: "assets/images/s_qualified.png",
              unSelectedImage: "assets/images/u_qualified.png",
              onPreTap: () {
                // controllers.selectedPMonth.value = null;
                // controllers.selectedQualifiedSortBy.value = "Today";
                controllers.isEmployee.value = true;
              },
              page: const Qualified(),
            ),

            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 4,
              icon: Icons.dashboard_customize,
              label: controllers.leadCategoryList[3]["value"],
              selectedImage: "assets/images/s_customer.png",
              unSelectedImage: "assets/images/u_customers.png",
              onPreTap: () {
                // controllers.selectedMonth.value = null;
                // controllers.selectedProspectSortBy.value = "Today";
              },
              page: const ViewCustomer(),
            ),

            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 5,
              icon: Icons.cancel_outlined,
              label: controllers.leadCategoryList[5]["value"],
              selectedImage: "assets/images/s_disqualified.png",
              unSelectedImage: "assets/images/u_disqualified.png",
              onPreTap: () {
                // controllers.selectedMonth.value = null;
                // controllers.selectedProspectSortBy.value = "Today";
              },
              page: const DisqualifiedLead(),
            ),
            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 12,
              icon: Icons.dashboard_customize,
              label: controllers.leadCategoryList[4]["value"],
              selectedImage: "assets/images/s_target.png",
              unSelectedImage: "assets/images/u_target.png",
              onPreTap: () {
                // controllers.selectedMonth.value = null;
                // controllers.selectedProspectSortBy.value = "Today";
              },
              page: const TargetLeads(),
            ),

            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 6,
              icon: Icons.receipt_long,
              label: "Records",
              selectedImage: "assets/images/s_records.png",
              unSelectedImage: "assets/images/u_records.png",
              page: const Records(isReload: "true"),
            ),

            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              index: 11,
              icon: Icons.alarm,
              label: "Reminder",
              selectedImage: "assets/images/s_reminder.png",
              unSelectedImage: "assets/images/u_reminder.png",
              page: const ReminderPage(),
            ),
            controllers.storage.read("role") != "See All Customer Records"
                ? const SizedBox.shrink()
                : Obx(() {
              bool isExpanded = controllers.isSettingsExpanded.value;
              bool isSelected = controllers.selectedIndex.value == 7 ||
                  (controllers.selectedIndex.value >= 701 &&
                      controllers.selectedIndex.value <= 705);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => isSettingsHovered.value = true,
                    onExit: (_) => isSettingsHovered.value = false,
                    child: GestureDetector(
                      onTap: () {
                        controllers.oldIndex.value = controllers.selectedIndex.value;
                        controllers.selectedIndex.value = 7;
                        controllers.isSettingsExpanded.toggle();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffF3F8FD)
                              : isSettingsHovered.value
                              ? const Color(0xffF8FAFF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border(
                            left: BorderSide(
                              color: colorsConst.primary,
                              width: 4,
                            ),
                          )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              size: 20,
                              color: isSelected
                                  ? colorsConst.primary
                                  : isSettingsHovered.value
                                  ? colorsConst.primary.withOpacity(0.7)
                                  : Colors.black,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: IgnorePointer(
                                child: Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? colorsConst.primary
                                        : isSettingsHovered.value
                                        ? colorsConst.primary
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 250),
                              turns: isExpanded ? 0.5 : 0,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 22,
                                color: isSelected ? colorsConst.primary : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isExpanded
                        ? Padding(
                      padding: const EdgeInsets.only(left: 32, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          subItem(context, "General Settings", 701, const GeneralSettings()),
                          subItem(context, "Role Management", 702, const RoleManagement()),
                          //subItem(context, "User Plan & Access", 703, const UserPlan()),
                          subItem(context, "User Management", 704, const EmployeeScreen()),
                          subItem(context, "Reminder Settings", 705, const ReminderSettings()),
                        ],
                      ),
                    )
                        : const SizedBox(),
                  ),
                ],
              );
            }),

            // Logout item (special because it shows dialog)
            SidebarItem(
              context: context,
              controllers: controllers,
              colorsConst: colorsConst,
              selectedImage: "assets/images/s_logout.png",
              unSelectedImage: "assets/images/u_logout.png",
              index: 10,
              icon: Icons.logout,
              label: "LogOut",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Do you want to log out?",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colorsConst.textColor,
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
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: colorsConst.primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                    color: colorsConst.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setBool("loginScreen$versionNum", false);
                                  prefs.setBool("isAdmin", false);
                                  Get.to(const LoginPage(), duration: Duration.zero);
                                  controllers.selectedIndex.value = 10;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorsConst.primary,
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
              },
            ),
          ],
        ),
      ),
    )
        : Container(
      width: 60,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(6, 8, 0, 0),
      alignment: Alignment.topCenter,
      color: Colors.white,
      child: Tooltip(
        message: "Click to view the side panel",
        child: InkWell(
          focusColor: Colors.transparent,
          onTap: () {
            controllers.isLeftOpen.value = !controllers.isLeftOpen.value;
          },
          child: CircleAvatar(
            backgroundColor: colorsConst.secondary,
            child: const Icon(Icons.menu, color: Colors.black),
          ),
        ),
      ),
    ));
  }
}

class SidebarItem extends StatelessWidget {
  final BuildContext context;
  final dynamic controllers;
  final dynamic colorsConst;
  final int index;
  final IconData icon;
  final String selectedImage;
  final String unSelectedImage;
  final String label;
  final Widget? page;
  final VoidCallback? onTap;
  final VoidCallback? onPreTap;

  const SidebarItem({
    super.key,
    required this.context,
    required this.controllers,
    required this.colorsConst,
    required this.index,
    required this.icon,
    required this.label,
    this.page,
    this.onTap,
    this.onPreTap, required this.selectedImage, required this.unSelectedImage,
  });

  @override
  Widget build(BuildContext _) {
    RxBool isHovered = false.obs;
    return Obx(() {
      bool isSelected = controllers.selectedIndex.value == index;
      return  InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (onPreTap != null) onPreTap!();
          if (onTap != null) {
            onTap!();
          } else if (page != null) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => page!,
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
          controllers.oldIndex.value = controllers.selectedIndex.value;
          controllers.selectedIndex.value = index;
          controllers.isSettingsExpanded.value = false;
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          child: Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xffF3F8FD)
                  : isHovered.value
                  ? const Color(0xffF8FAFF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isHovered.value
                  ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ]
                  : [],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: isSelected ? 5 : 0,
                  child: Container(color: colorsConst.primary),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.only(
                    left: isSelected ? 20 : (isHovered.value ? 18 : 12),
                    right: 12,
                  ),
                  child: Row(
                    children: [
                      // Icon(
                      //   icon,
                      //   color: isSelected
                      //       ? colorsConst.primary
                      //       : isHovered.value
                      //       ? colorsConst.primary
                      //       : Colors.black,
                      // ),
                      Image.asset(isSelected?selectedImage:isHovered.value?selectedImage:unSelectedImage,
                        width: 18,height: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? colorsConst.primary
                              : isHovered.value
                              ? colorsConst.primary
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      );
    });
  }
}

Widget subItem(BuildContext context, String title, int index, Widget page) {
  RxBool isHovered = false.obs;

  return Obx(() {
    bool isSelected = controllers.selectedIndex.value == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffF3F8FD)
              : isHovered.value
              ? const Color(0xffF8FAFF)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            controllers.oldIndex.value = controllers.selectedIndex.value;
            controllers.selectedIndex.value = index;
            controllers.isSettingsExpanded.value = true;

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => page,
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                left: 0,
                top: 0,
                bottom: 0,
                width: isSelected ? 4 : 0,
                child: Container(color: colorsConst.primary),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? colorsConst.primary
                        : isHovered.value
                        ? colorsConst.primary
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}


