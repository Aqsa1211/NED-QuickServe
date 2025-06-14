import 'package:flutter/material.dart';
import '../favorites/favourite_notifier.dart';
import '../menu_screen/menu_screen.dart';
import '../utils/colors.dart';
import 'canteen_card.dart';

class FavouriteCanteens extends StatelessWidget {
  // List of all available canteens
  final List<Map<String, dynamic>> allCanteens;

  const FavouriteCanteens({Key? key, required this.allCanteens})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: Text(
          'Favorite Canteens',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<List<int>>(
        valueListenable: favoriteNotifier,
        builder: (context, favoriteList, child) {
          List<Map<String, dynamic>> favoriteCanteens =
          allCanteens.where((canteen) =>
              favoriteList.contains(canteen['canteenId'])).toList();

          if (favoriteCanteens.isEmpty) {
            return Center(child: Text("No favorite canteens yet."));
          }

          return ListView.builder(
            itemCount: favoriteCanteens.length,
            itemBuilder: (context, index) {
              var canteen = favoriteCanteens[index];
              return CanteenCard(
                canteenId: canteen['canteenId'],
                title: canteen['title'],
                imagePath: canteen['imagePath'],
                rating: canteen['rating'],
                reviews: canteen['reviews'],
                priceLevel: canteen['priceLevel'],
                deliveryCharges: canteen['deliveryCharges'],
                time: canteen['time'],
                peakHours: canteen['peakHours'],
                onTap: () {
                  String canteenTitle = canteen['title'].toString();

                  // Check if the canteen is "Main Cafeteria" or "DMS"
                  if (canteenTitle == "Main Cafeteria" || canteenTitle == "Main DMS Cafeteria") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuScreen(),
                      ),
                    );
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.themeColor,
                        content: Text("We don't deliver to this location yet",style: TextStyle(color:AppColors.white,fontWeight: FontWeight.bold),),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.fixed,
                        elevation: 2,

                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}