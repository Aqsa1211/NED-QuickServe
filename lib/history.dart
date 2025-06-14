import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FirebaseChat/chat_controller.dart';
import 'utils/colors.dart';
import 'package:get/get.dart';

class OrderHistory extends StatefulWidget {
  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}



class _OrderHistoryState extends State<OrderHistory> {
  ChatListingCLientController chatController = Get.put(ChatListingCLientController());
  bool isAscending = false; // Tracks the sorting order
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String fullEmail = prefs.getString('id') ?? "example@email.com";
    String trimmedEmail = fullEmail.split('@')[0]; // Keep only before '@'

    setState(() {
      userEmail = trimmedEmail;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.themeColor,
        title: Text(
          'Order History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isAscending ? CupertinoIcons.sort_up : CupertinoIcons.sort_down,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isAscending = !isAscending;
              });
            },
          ),
        ],
      ),
      body: userEmail == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user_orders")
            .doc(userEmail)
            .collection("orders")
            .orderBy('time', descending: !isAscending)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders found."));
          }

          List<DocumentSnapshot> orders = snapshot.data!.docs;

          return GroupedListView<dynamic, String>(
            elements: orders,
            groupBy: (element) {
              var orderDate = element['orderDate'];
              if (orderDate is Timestamp) {
                return DateFormat('dd-MM-yyyy').format(orderDate.toDate());
              } else if (orderDate is String) {
                return orderDate;
              }
              return "Unknown Date";
            },
            groupSeparatorBuilder: (String group) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  group,
                  style: TextStyle(
                    color: AppColors.themeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            itemBuilder: (context, element) {
              var orderDate = element['orderDate'];
              var formattedDate = orderDate is Timestamp
                  ? DateFormat('dd-MM-yyyy At \n hh:mm a').format(orderDate.toDate())
                  : orderDate.toString();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  leading: Icon(Iconsax.bag_tick,size:50,color:AppColors.themeColor,),
                  title: Text(
                    "Order ID: ${element['orderId']}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.themeColor.withOpacity(0.8),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date: $formattedDate",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600],fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "${element['items'].length} item(s) ordered", // Shows item count
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, color: AppColors.accent, size: 20),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order from",
                                    style: TextStyle(fontSize: 14, color: AppColors.darkerGrey),
                                  ),
                                  Text(
                                    "DMS",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.local_shipping_outlined, color: AppColors.accent, size: 20),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Delivered to",
                                    style: TextStyle(fontSize: 14, color: AppColors.darkerGrey),
                                  ),
                                  Text(
                                    "${element['deliveryLocation']} Dept. \n (Rs. ${element['deliveryCharge'].toStringAsFixed(2)}) ",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.dark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Divider(),
                          SizedBox(height: 8),
                          Center(
                            child: Text(
                              "Items Ordered",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.themeColor),
                            ),
                          ),
                          SizedBox(height: 8),
                          Table(
                            border: TableBorder.all(color: Colors.grey[300]!),
                            columnWidths: {
                              0: FlexColumnWidth(2), // Product Name
                              1: FlexColumnWidth(2), // Quantity
                              2: FlexColumnWidth(2), // Price
                            },
                            children: [
                              // Table Header
                              TableRow(
                                decoration: BoxDecoration(color:AppColors.themeColor),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Item Name",
                                      style: TextStyle(fontWeight: FontWeight.bold,color:AppColors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Quantity",
                                      style: TextStyle(fontWeight: FontWeight.bold,color:AppColors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Price",
                                      style: TextStyle(fontWeight: FontWeight.bold,color:AppColors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              // Table Rows - Items Ordered
                              ...element['items'].map<TableRow>((item) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(item['productName'], textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("x ${item['quantity']}", textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Rs. ${item['totalPrice'].toStringAsFixed(2)}", textAlign: TextAlign.center),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(),
                          SizedBox(height: 16),
                          Center(
                            child: Text(
                              "Total Amount: Rs. ${element['totalAmount'].toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
                            ),
                          ),
                          SizedBox(height: 16),
                          // ElevatedButton(
                          //   onPressed: () async {
                          //   },
                          //   child: Text('Reorder'),
                          //   style: ElevatedButton.styleFrom(
                          //     foregroundColor: Colors.white,
                          //     backgroundColor: AppColors.accent,
                          //     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          //     minimumSize: Size(double.infinity, 50),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            order: isAscending ? GroupedListOrder.ASC : GroupedListOrder.DESC,
          );
        },
      ),
    );
  }
}
