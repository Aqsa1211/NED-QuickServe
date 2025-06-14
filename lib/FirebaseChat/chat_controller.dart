import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatListingCLientController extends GetxController {
  var isLoading = false.obs;

  String formatTime(DateTime time) {
    DateTime now = DateTime.now();
    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return "Today";
    } else if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day - 1) {
      return "Yesterday";
    }
    return DateFormat("MMM dd, yyyy").format(time);
  }

  getDateAsString(String string) {}

}