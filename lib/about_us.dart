import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart'; // Import for custom theme colors

class AboutUsScreen extends StatelessWidget {
  final String aboutText =
      'NED QuickServe brings innovation to campus dining with an efficient food ordering system. '
      'Our mission is to simplify your cafeteria experience by providing personalized recommendations, '
      'quick service, and seamless departmental deliveries.';

  final String visionText =
      'To revolutionize campus dining by integrating technology and convenience, ensuring a delightful experience for all.';

  final String missionText =
      'To enhance the campus dining experience by combining quality food, fast service, and a user-friendly technology interface.';


  // Constant for padding
  static const double kPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9), // Lighter background for an elegant feel
      appBar: AppBar(
        leading:IconButton(icon:
        Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Color(0xFF800000), // Maroon color for elegance
        title: Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 4, // Slight shadow for depth
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40), // Gap before avatar
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage('assets/images/logo.webp'), // Ensure the logo is in assets/images
                ),
              ),
              SizedBox(height: 30),

              _buildSectionCard('About Us', aboutText),
              SizedBox(height: 20),

              _buildSectionCard('Our Vision', visionText),
              SizedBox(height: 20),

              _buildSectionCard('Our Mission', missionText),
              SizedBox(height: 30),


              SizedBox(height: 30),

              Center(
                child: Text(
                  'Thank you for choosing NED QuickServe!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF800000)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String content) {
    return Card(
      elevation: 6, // Slightly elevated for better prominence
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000)),
            ),
            SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                  fontSize: 16, color: Colors.black87, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }

}