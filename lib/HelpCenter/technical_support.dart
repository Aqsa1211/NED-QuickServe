import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TechnicalSupportScreen extends StatelessWidget {
  const TechnicalSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample articles for Technical Support
    final List<Map<String, String>> articles = [
      {
        'title': 'App Not Loading Properly',
        'description': 'Steps to troubleshoot common app loading issues.',
      },
      {
        'title': 'How to Report a Bug',
        'description': 'Learn how to report bugs to our support team.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Technical Support',
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
      case 'App Not Loading Properly':
        return 'If the app is not loading, please check your internet connection, clear the app cache from your device settings, or restart your device.';
      case 'How to Report a Bug':
        return 'To report a bug, go to the "Help Center" section of the app, select "Report a Bug," and fill out the form with details about the issue.';
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