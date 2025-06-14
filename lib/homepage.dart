import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/canteen_selection/canteen_selection.dart';
import 'package:food/personalizedRecommendation/personalized_recommendation_service.dart';
import 'package:food/personalizedRecommendation/recommendation_widget.dart';
import 'package:food/profile/profile.dart';
import 'package:food/review.dart';
import 'package:food/selectrole.dart';
import 'package:food/statistics.dart';
import 'package:food/utils/sizes.dart';
import 'package:food/weatherRecommendation/weather_recommendation.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food/utils/colors.dart';
import 'about_us.dart';
import 'canteen_selection/canteen_card.dart';
import 'canteen_selection/curved_appbar_tile.dart';
import 'contact_us.dart';
import 'containers/primary_header_container.dart';
import 'data/all_canteens_data.dart';
import 'data/all_food_items.dart';
import 'favorites/favourites.dart';
import 'history.dart';
import 'kpi.dart';
import 'menu_screen/menu_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  double _scrollPosition = 0;
  double _opacity = 1;
  final RecommendationService _recommendationService = RecommendationService();
  List<Map<String, dynamic>> recommendedItems = [];
  bool isLoading = true;
  String userName = "User";
  String userEmail = "example@email.com";
  int orderCount = 0;
  List<Map<String, dynamic>> orders = [];
  List<ExpenditureData> expenditureData = [];
  Map<String, int> itemFrequency = {};
  List<String> filteredItems = [];

  final List<String> allItems = [
    'DMS Cafeteria',
    'Main Cafeteria',
    'Main DMS Cafeteria',
  ];

  void _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
      _opacity = _scrollPosition < 100 ? 1 - _scrollPosition / 100 : 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadUserData();
    _searchController.addListener(_onSearchChanged);

  }

  double calculateTrimmedMean(List<double> values, double trimPercent) {
    if (values.isEmpty) return 0;

    values.sort();
    int trimCount = (values.length * trimPercent).toInt();

    List<double> trimmed = values.sublist(trimCount, values.length - trimCount);
    return trimmed.reduce((a, b) => a + b) / trimmed.length;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      filteredItems = allItems
          .where((item) =>
          item.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "User";
      userEmail = prefs.getString('id') ?? "example@email.com";
    });
  }

  Future<void> fetchRecommendations() async {
    // You should ideally get this from FirebaseAuth or your login flow
    String safeEmail = userEmail.split('@')[0]; // e.g. userEmail.split('@')[0]

    final items = await _recommendationService.getTopOrderedItems(safeEmail);
    setState(() {
      recommendedItems = items;
      isLoading = false;
    });
  }

  Widget _buildClickableImage(String assetPath) {
    return GestureDetector(
      onTap: () {
        // Navigate to a page, open a dialog, or show a snackbar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()), // replace with your screen
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          assetPath,
          width: 140,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildQuickAccessIcon(IconData icon, String label, Widget routePage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => routePage),
        );
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200], // You can change to match your theme
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: AppColors.themeColor),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _selectedItem = 'Menu'; // Default selected item

  Widget _buildDrawer() {
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(50)),
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.themeColor),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/neduet.webp'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to NED QuickServe!',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Good food, good mood, every day!',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(CupertinoIcons.doc_plaintext, 'Menu', MenuScreen()),
                  _buildDrawerItem(Icons.history, 'Order History', OrderHistory()),
                  _buildDrawerItem(Icons.favorite, 'Favourites', FavouritesPage(allFoodItems: allFoodItems)),
                  _buildDrawerItem(Icons.person, 'Profile', ProfileScreen()),
                  _buildDrawerItem(CupertinoIcons.chart_bar_circle, 'Statistics', OrderStatisticsPage()),
                  Divider(),
                  _buildDrawerItem(CupertinoIcons.info, 'About Us', AboutUsScreen()),
                  _buildDrawerItem(CupertinoIcons.phone_fill, 'Contact Us', ContactUsScreen()),
                  _buildDrawerItem(Icons.exit_to_app, 'Logout', UserTypeScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget destination) {
    bool isSelected = _selectedItem == title;

    return GestureDetector(
      onTap: () {
        _selectedItem = title;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
        ),
        child: Row(
          children: [
            if (isSelected)
              Container(
                width: 5,
                height: 40,
                color: AppColors.themeColor, // Vertical selection indicator
              ),
            Expanded(
              child: ListTile(
                leading: Icon(icon, color: AppColors.themeColor),
                title: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? AppColors.themeColor :AppColors.darkGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String fullEmail = prefs.getString('id') ?? "example@email.com";
      String userEmail = fullEmail.split('@')[0]; // match document ID

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user_orders')
          .doc(userEmail)
          .collection('orders')
          .get();

      double expenditure = 0;
      int count = 0;
      Map<String, int> tempItemFrequency = {};
      List<ExpenditureData> tempExpenditureData = [];

      DateTime now = DateTime.now();

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('totalAmount') && data.containsKey('orderDate')) {
          Timestamp timestamp = data['orderDate'];
          DateTime orderDate = timestamp.toDate();

          if (orderDate.month == now.month && orderDate.year == now.year) {
            expenditure += (data['totalAmount'] as num).toDouble();
            count++;

            tempExpenditureData.add(ExpenditureData(
              orderDate,
              (data['totalAmount'] as num).toDouble(),
            ));

            List items = data['items'] ?? [];
            for (var item in items) {
              String name = item['productName'];
              int quantity = (item['quantity'] as num).toInt();

              // For debugging
              print('Order Date: $orderDate | Product: $name | Quantity: $quantity');

              tempItemFrequency[name] =
                  (tempItemFrequency[name] ?? 0) + quantity;
            }
          }
        }
      }

      setState(() {
        orders = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        orderCount = count;
        expenditureData = tempExpenditureData;
        itemFrequency = tempItemFrequency;
      });
    } catch (error) {
      print("Error fetching orders: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    double trimmedMean = calculateTrimmedMean(expenditureData.map((e) => e.amount).toList(), 0.1);

    String mostOrderedItem = "";
    int maxFrequency = 0;
    itemFrequency.forEach((item, frequency) {
      if (frequency > maxFrequency) {
        maxFrequency = frequency;
        mostOrderedItem = item;
      }
    });

    return Scaffold(
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              // color: Colors.white,
              padding: const EdgeInsets.only(bottom: 16),
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
                              cursorColor: AppColors.primary,
                              style: TextStyle(color: AppColors.darkerGrey, fontSize: 14),
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search for a canteen...',
                                hintStyle: TextStyle(color: AppColors.themeColor),
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
                                                MaterialPageRoute(builder: (context) => MenuScreen()),
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
                        SizedBox(height: 15),
                        // Review prompt with animation
                        AnimatedOpacity(
                          duration: Duration(seconds: 2),
                          opacity: _opacity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text column on the left
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Make sure \nto leave us \na review!',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ReviewAndFeedbackScreen()),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Tap to leave a feedback',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.white,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Icon(Icons.arrow_circle_right, color: AppColors.white),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Image on the right
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Image.asset(
                                      'assets/images/review.png',
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Horizontally scrollable clickable images
                      ],
                    ),
                  ),
                ],
              ),
            ),


            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildQuickAccessIcon(Icons.restaurant_rounded, 'Menu', MenuScreen()),
                  SizedBox(width: 16),
                  _buildQuickAccessIcon(Icons.restaurant_rounded, 'Canteens', HomeScreen()),
                  SizedBox(width: 16),
                  _buildQuickAccessIcon(CupertinoIcons.pencil_ellipsis_rectangle, 'Feedback', ReviewAndFeedbackScreen()),
                  SizedBox(width: 16),
                  _buildQuickAccessIcon(Icons.history, 'Orders', OrderHistory()),
                  SizedBox(width: 16),
                  _buildQuickAccessIcon(Icons.person, 'Profile', ProfileScreen()),
                  SizedBox(width: 16),
                  _buildQuickAccessIcon(CupertinoIcons.chart_bar_circle, 'Statistics', OrderStatisticsPage()),
                  // Add more icons and routes as needed
                ],
              ),
            ),
            SizedBox(height: 10,),
            Divider(),
            SizedBox(height: 20,),

            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0,horizontal: 16),
                child: Text('Your Monthly Statistics',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18, color: AppColors.darkerGrey),),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                KpiCard(title: "Total Orders", value: "$orderCount", color:AppColors.themeColor, icon:Iconsax.bag_tick),
                KpiCard(
                    title:"Avg. Expenditure",  value:"Rs. ${trimmedMean.toStringAsFixed(2)}", color: AppColors.themeColor, icon:CupertinoIcons.money_dollar_circle),
                KpiCard(title:"Most Ordered Item",  value:"$mostOrderedItem ($maxFrequency)", color:AppColors.themeColor, icon:CupertinoIcons.heart_fill),
              ],
            ),
            SizedBox(height: 30,),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildClickableImage('assets/images/cookie.png'),
                  SizedBox(width: 12),
                  _buildClickableImage('assets/images/biryani_banner.png'),
                  SizedBox(width: 12),
                  _buildClickableImage('assets/images/cookie.png'),
                  // Add more as needed
                ],
              ),
            ),
            SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: WeatherBasedRecommendations(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0,right: 16,bottom: 8),
              child: Align(
                alignment: Alignment.topLeft,
                  child: Text("Order Again?",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),)),
            ),
            PersonalizedRecommendationsPage(),
            SizedBox(height: 20,),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Align(
            //       alignment: Alignment.topLeft,
            //       child: Row(
            //         children: [
            //           Text("Order", style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
            //           SizedBox(width: 5,),
            //           GestureDetector(
            //               onTap:  () {
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(builder: (context) => HomeScreen()),
            //                 );
            //               },
            //               child: Icon(Icons.arrow_circle_right,color: AppColors.darkerGrey,))
            //         ],
            //       )
            //   ),
            // ),
            // Column(
            //   children: allCanteens.map((canteen) {
            //     return Column(
            //       children: [
            //         CanteenCard(
            //           canteenId: canteen['canteenId'],
            //           title: canteen['title'],
            //           imagePath: canteen['imagePath'],
            //           rating: canteen['rating'],
            //           reviews: canteen['reviews'],
            //           priceLevel: canteen['priceLevel'],
            //           time: canteen['time'],
            //           peakHours: canteen['peakHours'],
            //           deliveryCharges: canteen['deliveryCharges'],
            //           onTap: () => canteen['onTap'](context),
            //         ),
            //         SizedBox(height: AppSizes.spaceBtwItems),
            //       ],
            //     );
            //   }).toList(),
            // ),

          ],
        ),
      ),
    );
  }
}
