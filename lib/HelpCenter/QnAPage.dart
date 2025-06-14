import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart';

class QnAPage extends StatefulWidget {
  @override
  _QnAPageState createState() => _QnAPageState();
}

class _QnAPageState extends State<QnAPage> {
  final List<Map<String, dynamic>> faqData = [
    {
      'question': 'How does the cafeteria app work?',
      'answer': 'The app allows students to browse the menu, place orders, and track their order status without waiting in line.',
    },
    {
      'question': 'Does the app support online payments?',
      'answer': 'No, the app does not support online payments at the moment.',
    },
    {
      'question': 'Can I use the app outside NED University?',
      'answer': 'No, the purpose of NED QuickServe is to provide a streamlined food ordering facility to everyone only within premises of NED University',
    },
    {
      'question': 'Who can use the app?',
      'answer': 'NED QuickServe aims to provide a streamlined food ordering facility to only the staff, teachers and students at NED University.',
    },
    {
      'question': 'What if I do not collect my order?',
      'answer': 'If any person fails to collect their order within a certain time frame they would be penalized by the management at the Main Cafeteria.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: Text(
          'FAQs',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: faqData.length,
          itemBuilder: (context, index) {
            var faq = faqData[index];
            return Card(
              color: AppColors.whiteColor,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                title: Text(
                  faq['question'],
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                leading: Icon(CupertinoIcons.question_circle, color: AppColors.themeColor),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      faq['answer'],
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}