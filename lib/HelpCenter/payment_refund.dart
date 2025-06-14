import 'package:flutter/material.dart';

import '../utils/colors.dart';

class PaymentRefundScreen extends StatelessWidget {
  const PaymentRefundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample articles for Payment & Refund
    final List<Map<String, String>> articles = [
      {
        'title': 'How to Request a Refund',
        'description': 'Learn the steps to request a refund for your orders.',
      },
      {
        'title': 'Accepted Payment Methods',
        'description': 'Details on the payment options supported by the app.',
      },
      {
        'title': 'Refund Policy',
        'description': 'Understand the conditions and timeline for refunds.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment & Refund',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: Color(0xFF800000),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                article['title']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(article['description']!),
              trailing: Icon(Icons.arrow_forward_ios, color: AppColors.darkerGrey),
              onTap: () {
                // Navigate to a detailed article screen or show additional content
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailScreen(
                      title: article['title']!,
                      content: _getArticleContent(article['title']!),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Mock function to fetch article content
  String _getArticleContent(String title) {
    switch (title) {
      case 'How to Request a Refund':
        return 'To request a refund, navigate to the "Order History" section, select the order you want to refund, and click on "Request Refund."';
      case 'Accepted Payment Methods':
        return 'We support various payment methods including credit/debit cards, mobile wallets, and cash on delivery. For online payments, make sure your card is activated for internet transactions.';
      case 'Refund Policy':
        return 'Refunds are processed within 5-7 business days. Orders must be canceled within 30 minutes of placement to qualify for a refund.';
      default:
        return 'No content available.';
    }
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const ArticleDetailScreen({required this.title, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: Color(0xFF800000),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: TextStyle(fontSize: 16, color: AppColors.black),
        ),
      ),
    );
  }
}