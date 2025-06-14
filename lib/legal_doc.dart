import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart';

class LegalDocumentsPage extends StatelessWidget {
  const LegalDocumentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(icon:
        Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Color(0xFF800000), // Maroon color for elegance
        title: Text(
          'Legal Documents',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 4, // Slight shadow for depth
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              title: const Text('Terms and Conditions',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndConditionsPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Privacy Policy',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(icon:
        Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Color(0xFF800000), // Maroon color for elegance
        title: Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 4, // Slight shadow for depth
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Divider(thickness: 1,),
              SizedBox(height: 16),
              Text(
                '1. Introduction',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'Welcome to the cafeteria app. By accessing or using our services, you agree to be bound by these terms and conditions.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '2. User Responsibilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'Users are expected to provide accurate information, including delivery addresses and payment details, to ensure smooth processing of orders.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '3. Ordering Process',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'All orders are subject to availability. Payment must be made in full for order confirmation. Refunds are handled in accordance with our refund policy.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '4. Prohibited Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'Users must not engage in fraudulent activities, misuse the app, or harm its reputation.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '5. Changes to Terms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'We reserve the right to update these terms and conditions at any time without prior notice.\n',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(icon:
        Icon(Icons.arrow_back_ios, color: AppColors.white),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Color(0xFF800000), // Maroon color for elegance
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 4, // Slight shadow for depth
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Divider(thickness:1,),
              SizedBox(height: 16),
              Text(
                '1. Data Collection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'We collect personal information such as name, contact details, and order history to improve your experience.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '2. Data Usage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'Your data is used to process orders, provide personalized recommendations, and improve app functionality.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '3. Data Sharing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'We do not share your personal data with third parties, except as required by law or to fulfill your orders.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '4. Security',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'We use secure protocols to protect your data from unauthorized access.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '5. Changes to Privacy Policy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                'This privacy policy may be updated periodically. Users will be notified of significant changes.\n',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}