import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/homepage.dart';

import '../menu_screen/menu_screen.dart';
import '../utils/colors.dart';

List<Map<String, dynamic>> allCanteens = [
  {
    'canteenId': 001,
    'title': "Main DMS Cafeteria",
    'imagePath': "assets/dms_select.webp",
    'rating': 4.5,
    'reviews': 200,
    'priceLevel': "\$\$\$",
    'time': "5-10 min",
    'peakHours': "Between 12 PM - 2 PM",
    'deliveryCharges': '5.00-15.00',
    'onTap': (BuildContext context) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    },
  },
  {
    'canteenId': 002,
    'title': "New DMS Cafeteria",
    'imagePath': "assets/dms2.webp",
    'rating': 4.5,
    'reviews': 200,
    'priceLevel': "\$\$\$",
    'time': "5-10 min",
    'peakHours': "Between 12 PM - 2 PM",
    'deliveryCharges': "vary by location",
    'onTap':(BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.themeColor,
          content: Text("We don't deliver from this location yet",style: TextStyle(color:AppColors.white,fontWeight: FontWeight.bold),),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          elevation: 2,

        ),
      );
    },
  },
  {
    'canteenId': 003,
    'title': "NEDEA Cafeteria",
    'imagePath': "assets/nedea_select.webp",
    'rating': 0.0,
    'reviews': 0,
    'priceLevel': "\$",
    'time': "5-15 min",
    'peakHours': "Between 11 AM - 1 PM",
    'deliveryCharges': "0.0",
    'onTap':(BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.themeColor,
          content: Text("We don't deliver from this location yet",style: TextStyle(color:AppColors.white,fontWeight: FontWeight.bold),),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          elevation: 2,

        ),
      );
    },
  },
  {
    'canteenId': 004,
    'title': "Mech Corner",
    'imagePath': "assets/mech_corner_select.webp",
    'rating': 0.0,
    'reviews': 0,
    'priceLevel': "\$\$",
    'time': "5-7 min",
    'peakHours': "Between 1 PM - 3 PM",
    'deliveryCharges': "0.0",
    'onTap': (BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.themeColor,
          content: Text("We don't deliver from this location yet",
            style: TextStyle(
                color: AppColors.white, fontWeight: FontWeight.bold),),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          elevation: 2,

        ),
      );
    },
  },
  {
    'canteenId': 005,
    'title': "SFC Canteen",
    'imagePath': "assets/sfc_select.webp",
    'rating': 0.0,
    'reviews': 0,
    'priceLevel': "\$",
    'time': "5-20 min",
    'peakHours': "Between 11 AM - 12 PM",
    'deliveryCharges': "0.0",
    'onTap': (BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.themeColor,
          content: Text("We don't deliver to this location yet",style: TextStyle(color:AppColors.white,fontWeight: FontWeight.bold),),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          elevation: 2,

        ),
      );
    },
  },
];