import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart';

import '../favorites/favourite_controller.dart';
import '../favorites/favourite_notifier.dart';

class CanteenCard extends StatelessWidget {
  final int canteenId; // Unique ID for each canteen
  final String title;
  final String imagePath;
  final double rating;
  final int reviews;
  final String priceLevel;
  final String deliveryCharges;
  final String time;
  final String peakHours;
  final VoidCallback onTap;

  const CanteenCard({
    Key? key,
    required this.canteenId,
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.reviews,
    required this.priceLevel,
    required this.time,
    required this.peakHours,
    required this.onTap,
    required this.deliveryCharges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<List<int>>(
        valueListenable: favoriteNotifier,
        builder: (context, favoriteList, child) {
          bool isFavorite = favoriteList.contains(canteenId);

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black26, width: 1),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        width: double.infinity,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent, width: 1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "⭐ $rating ($reviews+ reviews)",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 7),
                          Divider(height: 1, thickness: 0.5, color: Colors.black26),
                          SizedBox(height: 7),
                          Text(
                            priceLevel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 12, color: AppColors.accent),
                                  SizedBox(width: 5),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 5),
                              Text("•", style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
                              SizedBox(width: 5),
                              Row(
                                children: [
                                  Icon(Icons.directions_bike_rounded, size: 12, color: AppColors.accent),
                                  SizedBox(width: 5),
                                  Text(
                                    "Rs. $deliveryCharges",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            "Avg. Peak Hours: $peakHours",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                  ],
                ),
              ),
              // Positioned Heart Icon
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () async {
                    String message;
                    if (isFavorite) {
                      await FavoritesManager.removeFromFavorites(canteenId, context);
                      message = "Removed from favorites";
                    } else {
                      await FavoritesManager.addToFavorites(canteenId, context);
                      message = "Added to favorites";
                    }

                    // Show Snackbar at the bottom
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.themeColor,
                        content: Text(message,style: TextStyle(color:AppColors.whiteColor,fontWeight: FontWeight.bold),),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.fixed,
                        elevation: 2,

                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color for circular icon
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.accent : Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
