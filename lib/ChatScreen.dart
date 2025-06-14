import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/FirebaseChat/firebase_chat.dart';
import 'package:food/utils/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'FirebaseChat/chat_controller.dart';
import 'utils/colors.dart'; // Ensure this file contains your theme colors
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required String userType}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _messagesStream;

  ChatListingCLientController chatController = Get.put(ChatListingCLientController());

  @override
  void initState() {
    super.initState();
    _messagesStream = FirebaseFirestore.instance
        .collection('Chats')
        .doc('1-2') // Static chat ID
        .collection('user_chats')
        .orderBy('time', descending: false)
        .snapshots();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await FirebaseChat().createChat(
        chat_id: "1-2",
        sender_id: '1', // Replace with dynamic user ID if required
        reciever_id: '2', // Replace with dynamic receiver ID if required
        msg: text.trim(),
        type: "customer", // Change based on user type
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.themeColor, // Use maroon theme color
        elevation: 4.0,
      ),
      body: Obx(() {
        return LoadingOverlay(
          isLoading: chatController.isLoading.isTrue,
          progressIndicator: const Center(child: CircularProgressIndicator()),
          child: StreamBuilder<QuerySnapshot>(
            stream: _messagesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              Future.delayed(const Duration(milliseconds: 100), () {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent);
                }
              });

              return Container(
                height: height,
                width: width,
                padding: EdgeInsets.only(
                    left: width * 0.05, right: width * 0.05, bottom: height * 0.1),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light background for better contrast
                  borderRadius: BorderRadius.circular(15),
                ),
                child: GroupedListView<dynamic, String>(
                  elements: snapshot.data?.docs ?? [],
                  controller: _scrollController,
                  groupBy: (element) => chatController.formatTime(
                    DateTime.fromMillisecondsSinceEpoch(element['time']),
                  ),
                  groupSeparatorBuilder: (String group) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        group,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, element) {
                    final isCustomer = element['type'] == "customer";
                    final DateTime messageTime =
                    DateTime.fromMillisecondsSinceEpoch(element['time']);
                    return Align(
                      alignment:
                      isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isCustomer
                              ? AppColors.grey.withOpacity(0.3)
                              : AppColors.greycolor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              element['msg'],
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat('hh:mm a').format(messageTime),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  order: GroupedListOrder.ASC,
                ),
              );
            },
          ),
        );
      }),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'Type a message',
                  fillColor: AppColors.whiteColor,
                  controller: _messageController,
                  textInputType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: AppColors.themeColor), // Send button in maroon
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}