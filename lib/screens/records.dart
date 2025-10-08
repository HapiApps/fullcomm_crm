import 'package:flutter/material.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/common/extentions/extensions.dart';

import '../common/utilities/utils.dart';
import 'call_comments.dart';
import 'cus_mail_comments.dart';
import 'mail_comments.dart';
import 'meeting_comments.dart';

class Records extends StatefulWidget {
  const Records({super.key});

  @override
  State<Records> createState() => _RecordsState();
}

class _RecordsState extends State<Records> {
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
            Container(
              width: screenWidth - 150,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  TabBar(
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
                            Text('Meeting', style: TextStyle(color: colorsConst.primary)),
                          ],
                        ),
                      ),
                    ],
                    labelColor: colorsConst.primary,
                    indicatorColor: colorsConst.primary,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        CallComments(),
                        MailComments(),
                        MeetingComments(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
