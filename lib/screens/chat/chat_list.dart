import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/components/custom_text.dart';

import '../../controller/controller.dart';

class ChatList extends StatelessWidget {

  final List chats;
  final int selectedIndex;
  final Function(int) onSelect;

  ChatList({
    super.key,
    required this.chats,
    required this.selectedIndex,
    required this.onSelect,
  });
  Color getAvatarColor(String name) {
    final colors = [
      Colors.red.shade200,
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.orange.shade200,
      Colors.purple.shade200,
      Colors.teal.shade200,
      Colors.pink.shade200,
    ];

    return colors[name.hashCode.abs() % colors.length];
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      width: 340,
      color: Colors.white,
      child: Column(
        children: [

          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: const Row(
              children: [
                CustomText(text: "All", isCopy: false,size: 22,isBold: true,)
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon:
                const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: controllers.customers.length,
              itemBuilder: (_, index) {

                final item = controllers.customers[index];

                return InkWell(
                  onTap: () {
                    onSelect(index);
                  },
                  child: Container(
                    color: selectedIndex == index
                        ? Colors.grey.shade100
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor: getAvatarColor(item.name),
                                  child: CustomText(text: item.name[0].trim(), isCopy: true,isBold: true,colors: Colors.white,)
                              ),10.width,
                              Column(
                                children: [
                                  CustomText(text: item.name.trim(), isCopy: true,isBold: true,),10.height,
                                  CustomText(text: item.companyName.trim(), isCopy: true,),
                                ],
                              ),
                            ],
                          ),
                          CustomText(text: item.id, isCopy: true,)
                        ],
                      ),
                    )
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}