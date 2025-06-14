import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:food/profile/location.dart';
import 'SignUpScreen.dart';
import 'package:food/utils/colors.dart';

class UserTypeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    getCurrentLocation();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Select Your Role',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.whiteColor,
          ),
        ),
        backgroundColor: AppColors.themeColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgUserSelect.webp',
              fit: BoxFit.cover,
            ),
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Who Are You?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                // Radial Layout
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    buildCircularOption(
                      context,
                      'Student',
                      'assets/images/student.webp',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffSignUpScreen('Student'),
                          ),
                        );
                      },
                    ),
                    buildCircularOption(
                      context,
                      'Teacher',
                      'assets/images/teacher.webp',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffSignUpScreen('Teacher'),
                          ),
                        );
                      },
                    ),
                    buildCircularOption(
                      context,
                      'Staff Member',
                      'assets/images/staff.webp',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffSignUpScreen('Staff'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to Build Circular Option
  Widget buildCircularOption(
      BuildContext context, String title, String imagePath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.whiteColor.withOpacity(0.7),
                  AppColors.whiteColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}