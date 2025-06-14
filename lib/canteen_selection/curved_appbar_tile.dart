import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/statistics.dart';
import 'package:food/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/all_canteens_data.dart';
import '../menu_screen/menu_screen.dart';
import '../profile/profile.dart';
import '../utils/colors.dart';
import 'curved_app_bar.dart';
import 'favorite_canteen.dart';
import '../utils/constant.dart';


class HomeAppbar extends StatefulWidget {
  const HomeAppbar({super.key});

  @override
  _HomeAppbarState createState() => _HomeAppbarState();
}

class _HomeAppbarState extends State<HomeAppbar> {
  String userName = "User"; // Default name
  String userEmail = "example@email.com"; // Default email

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Fetch user details
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "User";
      userEmail = prefs.getString('id') ?? "example@email.com";
    });
  }



  @override
  Widget build(BuildContext context) {

    return Appbar(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location icon and text
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: AppColors.whiteColor,
                          radius: 20,
                          child: Text(
                            userName[0].toUpperCase(),
                            style: TextStyle(
                                color: AppColors.themeColor,
                                fontWeight: FontWeight.bold, fontSize: 20
                            ),
                          ),
                        ),),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $userName",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                      Constants.locationString == ''
                      ? 'Set Default Delivery Address' : Constants.locationString,
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Row with heart & settings icons **without space**
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavouriteCanteens(allCanteens: allCanteens,)),
                      );
                    },
                    child: Icon(Icons.favorite_outline_rounded, color: AppColors.white, size: 24),
                  ),
                  SizedBox(width: 14,),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderStatisticsPage()),
                      );
                    },
                    child: Icon(CupertinoIcons.chart_bar_circle, color: AppColors.white, size: 24),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
