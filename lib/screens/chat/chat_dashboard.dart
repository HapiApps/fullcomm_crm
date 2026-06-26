import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/Customtext.dart';
import '../../components/custom_sidebar.dart';
import '../../controller/controller.dart';
import 'chat_list.dart';
import 'chat_screen.dart';

class ChatDashboard extends StatefulWidget {
  const ChatDashboard({super.key});

  @override
  State<ChatDashboard> createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard> {

  int selectedIndex = 3;

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
                  ChatList(
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
                        ): ChatScreen(
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