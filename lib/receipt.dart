import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food/menu_screen/menu_screen.dart';
import 'package:food/utils/colors.dart';

import 'ChatScreen.dart';

class ReceiptScreen extends StatelessWidget {
  final String orderId;
  final double totalAmount;
  final User firebaseUser;

  ReceiptScreen({
    Key? key,
    required this.orderId,
    required this.totalAmount,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF800000), // Maroon color to match your theme
        title: Align(
          alignment: Alignment.topCenter,
          child: Text(
            'Order Receipt',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              margin: EdgeInsets.only(top: 20),
              elevation: 7,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Title
                    Align(
                      child: Text(
                        "Order Summary",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.themeColor),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    // Order ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order ID:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          orderId,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // Total Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Amount:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Rs. $totalAmount",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // Payment Method
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Method:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Cash on Delivery",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    // Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Status:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          "Preparing",
                          style: TextStyle(fontSize: 16, color: AppColors.themeColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            // Order Processing Message
            Column(
              children: [
                Text(
                  'Order will be delivered soon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 20),
                SpinKitPouringHourGlass(
                  color: AppColors.themeColor,
                  size: 100.0,
                ),
                SizedBox(height: 20),
                Text(
                  'We are assigning the best delivery partner for your order. Hang tight while we process your request!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkerGrey,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 40),
            // Satisfaction Message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Your satisfaction is our priority. We hope you enjoy your meal!',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.themeColor,
                          height: 1.5,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Navigate to chat screen or implement chat feature here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(userType: '',)),
                );
              },
              child: Text(
                'Chat with Rider',
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal:10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Navigate to chat screen or implement chat feature here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuScreen()),
                );
              },
              child: Text(
                'Order Again ?',
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}