import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/Customtext.dart';
import '../../components/custom_sidebar.dart';
import '../../controller/controller.dart';
import 'w_chat_list.dart';
import 'w_chat_screen.dart';

class WhatsAppDashboard extends StatefulWidget {
  const WhatsAppDashboard({super.key});

  @override
  State<WhatsAppDashboard> createState() => _WhatsAppDashboardState();
}

class _WhatsAppDashboardState extends State<WhatsAppDashboard> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return SelectionArea(
      child: Scaffold(
        body: Row(
          children: [
            SideBar(),
            Obx(()=>Container(
              width:controllers.isLeftOpen.value?MediaQuery.of(context).size.width - 160:MediaQuery.of(context).size.width - 60,
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Row(
                children: [
                  WhatsAppList(
                    chats: controllers.chatCustomers,
                    selectedIndex: selectedIndex,
                    onSelect: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),

                  const VerticalDivider(width: 1),

                  Expanded(
                    child: controllers.chatCustomers.isEmpty
                        ? Center(
                          child: CustomText(text: "No Customers Found", isCopy: false,),
                        ): WhatsAppChatScreen(
                      key: ValueKey(controllers.chatCustomers[selectedIndex >= controllers.chatCustomers.length? 0: selectedIndex].id),
                      customerName: controllers.chatCustomers[selectedIndex >= controllers.chatCustomers.length? 0: selectedIndex].name,
                      number: controllers.chatCustomers[selectedIndex >= controllers.chatCustomers.length? 0: selectedIndex].phoneNo,
                      id: controllers.chatCustomers[selectedIndex >= controllers.chatCustomers.length? 0: selectedIndex].id,
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