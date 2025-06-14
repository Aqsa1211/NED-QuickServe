import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart';
import 'QnAPage.dart';
import 'order_and_delivery_support.dart';
import 'payment_refund.dart';
import 'technical_support.dart';
import 'faqs.dart';
import 'list_tile.dart';

class HelpCenter extends StatelessWidget {
  const HelpCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Color(0xFF800000),
        title: Text(
          'Help Center',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  children: [
                    Text(
                      "Have a burning question?",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "🔥",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: "Search for topic or questions",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Frequently Asked",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QnAPage(), // Navigate to AllFAQsScreen
                            ),
                          );
                        },
                        child: Text(
                          "View All",
                          style: TextStyle(fontSize: 14, color: AppColors.darkerGrey),
                        ),
                      ),
                    ]),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FAQs(
                      text: 'Can I use the app outside NED University?',
                      icon: Icons.house_outlined,
                      colors: AppColors.white,
                    ),
                    FAQs(
                      text: 'What if I do not collect my order?',
                      icon: Icons.shopping_bag_outlined,
                      colors: AppColors.white,
                    ),
                    FAQs(
                      text: 'Who can use the app?',
                      icon: Icons.mobile_friendly,
                      colors: AppColors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Topics",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QnAPage(), // Navigate to AllFAQsScreen
                          ),
                        );
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(fontSize: 14, color: AppColors.darkerGrey),
                      ),
                    ),
                  ],
                ),
              ),
              listTile(
                icon: CupertinoIcons.money_dollar,
                text: 'Payment & Refund',
                quantity: "3 articles",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentRefundScreen(),
                    ),
                  );
                },),
              listTile(
                icon: CupertinoIcons.settings_solid,
                text: 'Technical Support',
                quantity: "4 articles",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TechnicalSupportScreen(),
                    ),
                  );
                },),
              listTile(
                icon: Icons.directions_bike,
                text: 'Order & Delivery',
                quantity: "6 articles",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDeliveryScreen(),
                    ),
                  );
                },),
            ],
          ),
        ),
      ),
    );
  }
}