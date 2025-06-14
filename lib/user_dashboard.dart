import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/utils/colors.dart';
import 'package:food/weatherRecommendation/weather_recommendation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoundedTopPage extends StatefulWidget {
  @override
  _RoundedTopPageState createState() => _RoundedTopPageState();
}

class _RoundedTopPageState extends State<RoundedTopPage> {
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  String userName = "User"; // Default name
  String userEmail = "example@email.com"; // Default email

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "User";
      userEmail = prefs.getString('id') ?? "example@email.com";
    });
  }

  Color _getHeaderColor() {
    double maxOffset = 200;
    double percent = (_scrollOffset / maxOffset).clamp(0, 1);
    return Color.lerp(AppColors.accent2, AppColors.themeColor, percent)!;
  }

  double _getHeaderHeight() {
    double minHeight = kToolbarHeight;  // height after the header shrinks
    double maxHeight = 200.0;  // max height of header
    return maxHeight - _scrollOffset.clamp(0, maxHeight - minHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getHeaderColor(),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,  // This keeps the header at the top after it shrinks
            backgroundColor: Colors.transparent,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double height = constraints.maxHeight;  // Get current height
                return FlexibleSpaceBar(
                  background: Container(
                    color: _getHeaderColor(),
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.only(left: 20, bottom: 20),
                    child: Text(
                      "Welcome Back, $userName",
                      style: TextStyle(
                        fontSize: height > kToolbarHeight ? 24 : 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sliver for the main body content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Horizontal scrollable icons section
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,  // Make it horizontal
                      child: Row(
                        children: [
                          _buildIcon(Icons.restaurant_rounded, "Canteens"),
                          _buildIcon(Icons.favorite, "Favorites"),
                          _buildIcon(CupertinoIcons.chart_bar_square_fill, "Statistics"),
                          _buildIcon(Icons.account_circle, "Profile"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Divider(),
                  ),
                  SizedBox(height: 8,),
                  // ListView section
                 Padding(
                   padding: const EdgeInsets.all(12.0),
                   child: WeatherBasedRecommendations(),
                 ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build icons
  Widget _buildIcon(IconData iconData, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          // Handle tap on icon
          print('$label icon tapped');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.themeColor.withOpacity(0.1),
              child: Icon(
                iconData,
                color:AppColors.themeColor ,
                size: 30,
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
