import 'package:flutter/material.dart';
import '../utils/colors.dart';

class OrderDeliveryScreen extends StatelessWidget {
  const OrderDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Articles for Order & Delivery
    final List<Map<String, String>> articles = [
      {
        'title': 'How to Track Your Order',
        'description': 'Learn how to track your order status in real-time.',
      },
      {
        'title': 'Delivery Time Estimates',
        'description': 'Understand how long it takes for your order to arrive.',
      },
      {
        'title': 'What Happens if My Order is Delayed?',
        'description': 'Steps to follow if your order is delayed.',
      },
      {
        'title': 'How to Cancel an Order',
        'description': 'Find out how to cancel your order before it is processed.',
      },
      {
        'title': 'Who Delivers My Order?',
        'description': 'Information about our delivery personnel and process.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order & Delivery',
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
      case 'How to Track Your Order':
        return 'To track your order, navigate to the "My Orders" section in the app. Select the order, and you will see live updates on its status.';
      case 'Delivery Time Estimates':
        return 'Our average delivery time ranges between 15–30 minutes. You can see a more accurate estimate while placing your order.';
      case 'What Happens if My Order is Delayed?':
        return 'If your order is delayed, you will receive a notification with an updated delivery time. For further assistance, contact our support team.';
      case 'How to Cancel an Order':
        return 'To cancel an order, go to "My Orders," select the order you want to cancel, and tap the "Cancel Order" button. This can only be done before the order is prepared.';
      case 'Who Delivers My Order?':
        return 'Your order is delivered by our trained delivery staff or a reliable third-party service, ensuring quality and timely delivery.';
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