import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart'; // Import for custom theme colors
import 'package:url_launcher/url_launcher.dart'; // Import for URL launcher

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light grey background color
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF800000), // Maroon color to match your theme
        title: Text(
          'Contact Us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40), // Gap added before the avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF800000), // Maroon color
                child: Icon(
                  Icons.group,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Get in Touch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
              SizedBox(height: 30),
              // Contact Information Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ContactItem(
                        icon: CupertinoIcons.link,
                        label: 'Website',
                        info: 'www.ned_maincafetaria',
                        onTap: () => _launchURL(Uri.parse('https://www.example.com')),
                      ),
                      Divider(),
                      ContactItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        info: 'saleem.dms@hotmail.com',
                        onTap: () => _launchEmail('saleem.dms@hotmail.com'),
                      ),
                      Divider(),
                      ContactItem(
                        icon: Icons.phone,
                        label: 'Phone',
                        info: '0301-8377738',
                        onTap: () => _launchURL(Uri.parse('tel:+923018377738')),
                      ),
                      Divider(),
                      ContactItem(
                        icon: CupertinoIcons.placemark_fill,
                        label: 'Location',
                        info: 'DMS Cafeteria, NED University Of Engineering & Technology, Karachi, Sindh',
                        onTap: () => _launchURL(
                          Uri.parse('https://maps.google.com/?q=DMS+Cafeteria+W4J7+XPV+NED+University+Karachi'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication); // Open in external app or browser
    } catch (e) {
      throw 'Could not launch $uri';
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw 'Could not send email to $email';
    }
  }
}

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String info;
  final VoidCallback onTap;

  ContactItem({
    required this.icon,
    required this.label,
    required this.info,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF800000)), // Maroon color for icons
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Text(
                  info,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
