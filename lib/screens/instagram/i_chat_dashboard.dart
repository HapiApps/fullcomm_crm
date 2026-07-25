import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/Customtext.dart';
import '../../components/custom_sidebar.dart';
import '../../controller/controller.dart';
import 'i_chat_list.dart';
import 'i_chat_screen.dart';

class InstaDashBoard extends StatefulWidget {
  const InstaDashBoard({super.key});

  @override
  State<InstaDashBoard> createState() => _InstaDashBoardState();
}

class _InstaDashBoardState extends State<InstaDashBoard> {

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
                  InstaList(
                    chats: controllers.instagramCustomers,
                    selectedIndex: selectedIndex,
                    onSelect: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),

                  const VerticalDivider(width: 1),

                  Expanded(
                    child: controllers.instagramCustomers.isEmpty
                        ? Center(
                          child: CustomText(text: "No Customers Found", isCopy: false,),
                        ): InstaChatScreen(
                      key: ValueKey(controllers.instagramCustomers[selectedIndex >= controllers.instagramCustomers.length? 0: selectedIndex].id),
                      customerName: controllers.instagramCustomers[selectedIndex >= controllers.instagramCustomers.length? 0: selectedIndex].name,
                      instaId: controllers.instagramCustomers[selectedIndex >= controllers.instagramCustomers.length? 0: selectedIndex].instaId.toString(),
                      id: controllers.instagramCustomers[selectedIndex >= controllers.instagramCustomers.length? 0: selectedIndex].id,
                      recipientId: controllers.instagramCustomers[selectedIndex >= controllers.instagramCustomers.length? 0: selectedIndex].instaRecipientId.toString(),
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