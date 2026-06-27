import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/styles/decoration.dart';
import 'package:fullcomm_crm/components/custom_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../common/constant/assets_constant.dart';
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
            child: Row(
              children: [
                InkWell(
                  onTap:(){
                    Get.back();
                  },
                    child: const Icon(Icons.arrow_back_rounded,size: 22,)),10.width,
                const CustomText(text: "All", isCopy: false,size: 22,isBold: true,)
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value){
                final input = value.toString().toLowerCase().trim();
                controllers.chatCustomers.value = controllers.chatCustomers2.where((user) {
                  return user.name.toString().toLowerCase().contains(input) ||
                      user.phoneNo.toString().toLowerCase().contains(input) ||
                      user.companyName.toString().toLowerCase().contains(input);
                }).toList();
                if (controllers.chatCustomers.isNotEmpty) {
                  onSelect(0);
                }
              },
              decoration: InputDecoration(
                hintText: "Search Name Or Phone Number",
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
              itemCount: controllers.chatCustomers.length,
              itemBuilder: (_, index) {

                final item = controllers.chatCustomers[index];

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
                                  child: CustomText(text: item.name[0].trim(), isCopy: false,isBold: true,colors: Colors.white,)
                              ),10.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(text: item.name.trim(), isCopy: false,isBold: true,textAlign: TextAlign.start,),
                                      // Container(
                                      //   decoration: customDecoration.baseBackgroundDecoration(
                                      //     color: Colors.grey.shade200,radius: 5
                                      //   ),
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(3),
                                      //     child: Row(
                                      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //       children: [
                                      //         CustomText(text: "WA", isCopy: false,size: 10,),
                                      //         Image.asset(assets.whatsapp,width: 13,height: 13,)
                                      //       ],
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  ),10.height,
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context).size.width*0.11,
                                          child: Tooltip(
                                            message:item.message.toString().contains("Choose an option")?"Product Details":item.message.toString(),
                                            child: CustomText(text: "${item.type=="0"?"You: ":""}${item.message.toString().contains("Choose an option")?"Product Details":item.message.toString().trim().length > 10
                                                ? "${item.message.toString().trim().substring(0, 10)}..."
                                                : item.message.toString().trim()}", isCopy: false,textAlign: TextAlign.start,size: 13,colors: Colors.grey),
                                          )),
                                      CustomText(text: item.createdTs.toString()!=""&&item.createdTs.toString()!="null"?DateFormat('hh:mm a').format(
                                        DateTime.parse(item.createdTs.toString()),
                                      ):"", isCopy: false,size: 13,colors: Colors.grey,)
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
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