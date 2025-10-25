import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';

import '../../common/utilities/utils.dart';
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
            utils.sideBarFunction(context),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 150:MediaQuery.of(context).size.width - 60,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  TabBar(
                    controller: controllers.tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: colorsConst.primary, size: 20),
                            6.width,
                            Text('Call', style: TextStyle(color: colorsConst.primary)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail, color: colorsConst.primary, size: 20),
                            6.width,
                            Text('Mail', style: TextStyle(color: colorsConst.primary)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group, color: colorsConst.primary, size: 20),
                            6.width,
                            Text('Appointment', style: TextStyle(color: colorsConst.primary)),
                          ],
                        ),
                      ),
                    ],
                    labelColor: colorsConst.primary,
                    indicatorColor: colorsConst.primary,
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
