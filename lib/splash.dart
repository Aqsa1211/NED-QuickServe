import 'package:flutter/material.dart';
import 'package:food/selectrole.dart';
import 'package:food/utils/colors.dart';
import 'utils/image_strings.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //FirebaseChat().createUser(user_id: '3', name: 'FATIMA', image: 'https://static.vecteezy.com/system/resources/previews/008/296/405/non_2x/rider-front-view-japanese-art-vector.jpg');
    // After the splash screen duration, navigate to the home screen
    Future.delayed(const Duration(seconds:4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) =>  UserTypeScreen()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.themeColor,  // Background color (#800000)
          image: DecorationImage(
            image: AssetImage('${AppImages.localImage}${AppImages.splash}'),  // Your full background image
            fit: BoxFit.cover,  // Ensures the image fills the screen
          ),
        ),
      ),
    );
  }
}
