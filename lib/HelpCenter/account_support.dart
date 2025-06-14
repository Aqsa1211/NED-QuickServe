import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AccountSupportScreen extends StatelessWidget {
  const AccountSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Articles for Account Support
    final List<Map<String, String>> articles = [
      {
        'title': 'How to Reset Your Password',
        'description': 'Learn the steps to securely reset your account password.',
      },
      {
        'title': 'Updating Your Profile Information',
        'description': 'Find out how to update your name, email, and other details.',
      },
      {
        'title': 'What to Do If Your Account is Locked',
        'description': 'Steps to regain access to your locked account.',
      },
      {
        'title': 'How to Delete Your Account',
        'description': 'Understand how to permanently delete your account.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Support',
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
      case 'How to Reset Your Password':
        return 'To reset your password, go to the login page and click on "Forgot Password." Enter your registered email, and you will receive a link to reset your password.';
      case 'Updating Your Profile Information':
        return 'To update your profile, navigate to the "Profile" section in the app, edit the required fields, and save changes.';
      case 'What to Do If Your Account is Locked':
        return 'If your account is locked, contact our support team through the "Help Center" or email us at support@example.com. Provide your account details for assistance.';
      case 'How to Delete Your Account':
        return 'To delete your account, go to the "Account Settings" section in the app, select "Delete Account," and confirm your action. Note that this action is irreversible.';
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