import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import '../../common/constant/api.dart';
import '../../common/constant/default_constant.dart';
import '../../common/utilities/utils.dart';
import '../../components/custom_sidebar.dart';
import '../../controller/controller.dart';
import 'call_comments.dart';
import 'mail_comments.dart';
import 'meeting_comments.dart';

class Records extends StatefulWidget {
  final String isReload;
  const Records({super.key, required this.isReload});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiService.getAllCustomers();
    if(widget.isReload=="true"){
      apiService.getAllCallActivity("");
      apiService.getAllMeetingActivity("");
    }
    // apiService.getAllMailActivity("");
    // apiService.getAllCallActivity("");
    // apiService.getAllMeetingActivity("");
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SideBar(),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    color: Color(0xffE2E8F0),
                    child: TabBar(
                      controller: controllers.tabController,
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,

                      labelColor: colorsConst.primary,
                      unselectedLabelColor: Colors.grey,

                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 18,
                      ),

                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone, size: 20),
                              6.width,
                              const Text('Call'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.mail, size: 20),
                              6.width,
                              const Text('Mail'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.group, size: 20),
                              6.width,
                              const Text('Appointment'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: controllers.tabController,
                      children: [
                        CallComments(),
                        MailComments(),
                        MeetingComments(),
                      ],
                    ),
                  ),
                ],
              ),
            ),)
          ],
        ),
      ),
    );
  }
}
