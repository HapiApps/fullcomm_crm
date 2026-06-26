import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fullcomm_crm/billing_utils/sized_box.dart';
import 'package:fullcomm_crm/common/constant/colors_constant.dart';
import 'package:fullcomm_crm/res/components/k_loadings.dart';
import 'package:fullcomm_crm/services/api_services.dart';
import 'package:get/get.dart';
import '../../components/Customtext.dart';
import '../../controller/controller.dart';
import '../../models/customer_chat_obj.dart';

class ChatScreen extends StatefulWidget {
  final String id;
  final String customerName;
  final String number;

  const ChatScreen({
    super.key,
    required this.customerName, required this.number, required this.id,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  bool showEmoji = false;

  int selectedTab = 0;

  void sendMessage() {
    String text =
    messageController.text.trim();

    if (text.isEmpty) return;
    setState(() {
      controllers.customerChatDetails.add(ChatModel(id: '', type: '0', message: text, isRead: '0', createdTs: DateTime.now().toString()));
      for (int i = 0; i < controllers.chatCustomers.length; i++) {
        if (controllers.chatCustomers[i].id == widget.id) {
          controllers.chatCustomers[i] = controllers.chatCustomers[i].copyWith(
            message: text,
            createdTs: DateTime.now().toString(),
            type: "0",
          );
          break;
        }
      }
    });
    apiService.sendWhatAppMessage(context,text,widget.number,widget.id);

    messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 100),
          () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration:
            const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  String getChatDateLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    final messageDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (messageDate == today) {
      return "Today";
    }

    if (messageDate == yesterday) {
      return "Yesterday";
    }

    final difference =
        today.difference(messageDate).inDays;

    if (difference < 7) {
      const days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
      ];

      return days[date.weekday - 1];
    }

    if (date.year == now.year) {
      return "${date.day} ${_month(date.month)}";
    }

    return "${date.day} ${_month(date.month)} ${date.year}";
  }

  String _month(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    return months[month];
  }

  String formatTime(DateTime date) {
    int hour = date.hour;
    String amPm = hour >= 12 ? "PM" : "AM";

    hour = hour % 12;
    if (hour == 0) hour = 12;

    return "${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $amPm";
  }
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadChats();
  }
  Future<void> loadChats() async {
    await apiService.getCustomerChats(widget.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// HEADER
        buildHeader(),

        /// CHAT AREA
        Expanded(
          child: Container(
            color: const Color(0xffefeae2),
            child: Obx(()=>controllers.chatLoading.value==false?
            const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            ):controllers.customerChatDetails.isEmpty?
            Center(
              child: SizedBox(
                width: 150,
                height: 30,
                child: CustomText(text: "No messages found", isCopy: false),
              ),
            ):
            ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: controllers.customerChatDetails.length,
                itemBuilder: (_, index) {

                  final msg =
                  controllers.customerChatDetails[index];

                  final currentDate =
                  DateTime.parse(msg.createdTs);

                  bool showDateHeader = false;

                  if (index == 0) {
                    showDateHeader = true;
                  } else {

                    final previousDate =
                    DateTime.parse(
                      controllers
                          .customerChatDetails[index - 1]
                          .createdTs,
                    );

                    showDateHeader =
                        previousDate.day != currentDate.day ||
                            previousDate.month != currentDate.month ||
                            previousDate.year != currentDate.year;
                  }

                  bool isSender = msg.type.toString() == "0";


                  Map<String, dynamic>? data;

                  if (msg.message.trim().startsWith("{")) {
                    try {
                      data = jsonDecode(msg.message);

                      if (data?["type"] != "interactive") {
                        data = null;
                      }
                    } catch (e) {
                      data = null;
                    }
                  }

                  return Column(
                    children: [

                      if (showDateHeader)
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          child: Center(
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: CustomText(
                                text:getChatDateLabel(
                                  currentDate,
                                ), isCopy: false,
                              ),
                            ),
                          ),
                        ),

                      Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.4,
                            ),
                            margin:
                            const EdgeInsets.only(
                              bottom: 10,
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSender
                                  ? const Color(
                                  0xffDCF8C6)
                                  : Colors.white,
                              borderRadius:
                              BorderRadius.only(
                                topLeft:
                                const Radius.circular(
                                    12),
                                topRight:
                                const Radius.circular(
                                    12),
                                bottomLeft:
                                Radius.circular(
                                  isSender ? 12 : 2,
                                ),
                                bottomRight:
                                Radius.circular(
                                  isSender ? 2 : 12,
                                ),
                              ),
                            ),
                            child:data!=null?
                            interactiveBubble(
                              msg,
                              isSender,
                            ):
                            Column(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text:msg.message ?? "",isCopy: true,
                                ),5.height,
                                Align(
                                  alignment:Alignment.bottomRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomText(
                                        text: formatTime(
                                          currentDate,
                                        ),size: 11,colors: Colors.grey,isCopy: false,
                                      ),

                                      if (isSender)
                                        Padding(
                                          padding:
                                          EdgeInsets.only(
                                              left: 3),
                                          child: Icon(
                                            Icons.done_all,
                                            size: 15,
                                            color:msg.isRead=="0"?Colors.grey:Colors.blue,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
            )
            ),
          ),
        ),

        /// TABS
        Container(
          height: 45,
          decoration:
          const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.black12,
              ),
            ),
          ),
          child: Row(
            children: [

              const SizedBox(width: 15),

              InkWell(
                onTap: () {
                  setState(() {
                    selectedTab = 0;
                  });
                },
                child: Text(
                  "Reply",
                  style: TextStyle(
                    fontWeight:
                    selectedTab == 0
                        ? FontWeight
                        .bold
                        : FontWeight
                        .normal,
                  ),
                ),
              ),

              const SizedBox(width: 20),

              InkWell(
                onTap: () {
                  setState(() {
                    selectedTab = 1;
                  });
                },
                child: Text(
                  "Notes",
                  style: TextStyle(
                    fontWeight:
                    selectedTab == 1
                        ? FontWeight
                        .bold
                        : FontWeight
                        .normal,
                  ),
                ),
              ),
            ],
          ),
        ),

        selectedTab == 0
            ? buildReplyArea()
            : buildNotesArea(),

        if (showEmoji)
          SizedBox(
            height: 300,
            child: EmojiPicker(
              textEditingController:
              messageController,
            ),
          ),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      height: 70,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: colorsConst.primary,
            child: CustomText(text: widget.customerName[0], isCopy: true,isBold: true,colors: Colors.white,)
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              CustomText(text: widget.customerName, isCopy: true,isBold: true,),
              CustomText(text: widget.number, isCopy: true,)
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget buildReplyArea() {
    return Container(
      height: 85,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Row(
        children: [

          /// FILE
          IconButton(
            icon: const Icon(
              Icons.attach_file,
            ),
            onPressed: () async {
              FilePickerResult?
              result =
              await FilePicker
                  .platform
                  .pickFiles();

              if (result != null) {
                String file =
                    result.files.single
                        .name;

                setState(() {
                  // messages.add({
                  //   "message":
                  //   "📎 $file",
                  //   "type": "text"
                  // });
                });
              }
            },
          ),

          /// EMOJI
          IconButton(
            icon: const Icon(
              Icons
                  .emoji_emotions_outlined,
            ),
            onPressed: () {
              setState(() {
                showEmoji =
                !showEmoji;
              });
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.format_bold,
            ),
            onPressed: () {
              messageController.text =
              "*${messageController.text}*";
            },
          ),

          IconButton(
            icon: const Icon(
              Icons.format_italic,
            ),
            onPressed: () {
              messageController.text =
              "_${messageController.text}_";
            },
          ),

          Expanded(
            child: TextField(
              controller:
              messageController,
              onChanged: (value) {
                controllers.firstCaps(value, messageController);
                setState(() {});
              },
              onSubmitted: (_) {
                sendMessage();
              },
              decoration:
              const InputDecoration(
                hintText:
                "Type a message",
                border:
                OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 22,
            backgroundColor:
            Colors.blue,
            child: IconButton(
              onPressed: () {
                sendMessage();
              },
              icon: Icon(
                messageController.text
                    .trim()
                    .isEmpty
                    ? Icons.mic
                    : Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotesArea() {
    return Container(
      height: 85,
      padding:
      const EdgeInsets.all(15),
      alignment:
      Alignment.centerLeft,
      child: const TextField(
        decoration: InputDecoration(
          hintText:
          "Add internal note...",
          border:
          OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget templateCard() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 420,
        margin:
        const EdgeInsets.only(
            bottom: 15),
        padding:
        const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:
          const Color(0xffd9ffc0),
          borderRadius:
          BorderRadius.circular(
              12),
        ),
        child: Column(
          children: [

            const Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                "Venetz Ezy-Fix Framed Mosquito Net",
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            button(
                "How to measure"),

            const SizedBox(height: 10),

            button(
                "Size Chart and Price"),

            const SizedBox(height: 10),

            button(
                "Back to Main Menu"),
          ],
        ),
      ),
    );
  }

  Widget button(String text) {
    return InkWell(
      onTap: () {
        messageController.text =
            text;
      },
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(
              8),
        ),
        child: Center(
          child: Text(text),
        ),
      ),
    );
  }
  Widget interactiveBubble(dynamic msg, bool isSender) {

    final data = jsonDecode(msg.message);

    final interactive = data["interactive"];

    final body = interactive["body"]["text"];

    final List buttons =
    interactive["action"]["buttons"];

    return Align(
      alignment: isSender
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSender
              ? const Color(0xffDCF8C6)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 10),

            ...buttons.map((button) {

              return Container(
                margin:
                const EdgeInsets.only(
                  bottom: 8,
                ),
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                      8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  button["reply"]["title"],
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              );

            }).toList(),
          ],
        ),
      ),
    );
  }
}