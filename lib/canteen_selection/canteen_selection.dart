import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart';
import 'package:food/utils/image_strings.dart';
import 'package:food/utils/sizes.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../containers/primary_header_container.dart';
import '../data/all_canteens_data.dart';
import '../homepage.dart';
import '../menu_screen/menu_screen.dart';
import 'canteen_card.dart';
import 'curved_appbar_tile.dart';
import 'promo_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of all items (canteens)
  List<String> allItems = [
    'Main DMS Cafeteria', 'Mech Corner', 'NEDEA Canteen', 'SFC', 'GCR Canteen', 'New DMS Cafeteria'
  ];


  // Initially empty list for filtered items
  List<String> filteredItems = [];

  // Text editing controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initializing filteredItems to an empty list, will be updated when search starts
    filteredItems = [];
    _searchController.addListener(_filterSearchResults);
  }

  // Function to filter the search results based on input
  void _filterSearchResults() {
    setState(() {
      if (_searchController.text.isEmpty) {
        // If no text is entered, reset filtered items to an empty list
        filteredItems = [];
      } else {
        // Otherwise, filter the list based on search query
        filteredItems = allItems
            .where((item) =>
            item.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            PrimaryHeaderContainer(
              child: Column(
                children: [
                  const HomeAppbar(),
                  // Search Bar with rounded corners and white background
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 8),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      child: TextField(
                        cursorColor: AppColors.darkerGrey,
                        style: TextStyle(color: AppColors.darkerGrey, fontSize: 14),
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a canteen...',
                          hintStyle: TextStyle(color: AppColors.primary),
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: AppColors.themeColor,
                          ),
                          filled: true, // Set background to white
                          fillColor: Colors.white, // White background
                          hoverColor: AppColors.themeColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50), // Rounded
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                  // Display search results only if there is input
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        // White background for dropdown with rounded corners
                        decoration: BoxDecoration(
                          color: Colors.white, // Set white background for dropdown
                          borderRadius: BorderRadius.circular(20), // Rounded corners for background
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                          child: Column(
                            children: filteredItems.map((item) {
                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
                                    title: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.search, // Use the search icon
                                          color: AppColors.accent,
                                          size: 16.0, // Adjust size if needed
                                        ),
                                        SizedBox(width: 8), // Spacing between icon and text
                                        Text(
                                          item,
                                          style: TextStyle(
                                            color: AppColors.darkerGrey,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      // Navigate only if the item is "DMS"
                                      if (item == "DMS Cafeteria" || item == "Main Cafeteria" || item == "Main DMS Cafeteria" ) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => HomePage()),
                                        );
                                      }
                                    },
                                  ),
                                  Divider( // Add a divider to visually separate the items
                                    height: 1,
                                    thickness: 0.3,
                                    color: AppColors.darkerGrey, // Light grey color for the divider
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height:5),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom:AppSizes.defaultSpace),
              child: Column(
                children: [
                  AppSlider(banners: [
                    AppImages.locationBanner1,
                    AppImages.locationBanner2,
                    AppImages.locationBanner3,],
                    onTapActions: [
                          () => Get.to(() => MenuScreen()), // Navigate for banner 1
                          () => Get.snackbar(
                          "Sorry",
                          "Delivery is currently unavailable from this canteen",
                          snackPosition: SnackPosition.BOTTOM,
                          colorText: AppColors.primary,
                          duration: Duration(seconds: 2)
                      ), // Show Snackbar for banner 2
                          () => Get.snackbar(
                          "Sorry",
                          "Delivery is currently unavailable from this canteen",
                          snackPosition: SnackPosition.BOTTOM,
                          colorText: AppColors.primary,
                          duration: Duration(seconds: 2)), // Navigate for banner 3
                    ],),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0),
              child:Align(
                  alignment: Alignment.topLeft,
                  child: Text('Select a Canteen',
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: AppColors.themeColor))),
            ),

            Column(
              children: allCanteens.map((canteen) {
                return Column(
                  children: [
                    CanteenCard(
                      canteenId: canteen['canteenId'],
                      title: canteen['title'],
                      imagePath: canteen['imagePath'],
                      rating: canteen['rating'],
                      reviews: canteen['reviews'],
                      priceLevel: canteen['priceLevel'],
                      time: canteen['time'],
                      peakHours: canteen['peakHours'],
                      deliveryCharges: canteen['deliveryCharges'],
                      onTap: () => canteen['onTap'](context),
                    ),
                    SizedBox(height: AppSizes.spaceBtwItems),
                  ],
                );
              }).toList(),
            ),

            SizedBox(height: AppSizes.spaceBtwItems),

          ],
        ),
      ),
    );
  }
}