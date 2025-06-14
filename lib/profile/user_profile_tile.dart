import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../utils/colors.dart';

class UserProfileTile extends StatefulWidget {
  const UserProfileTile({super.key});

  @override
  _UserProfileTileState createState() => _UserProfileTileState();
}

class _UserProfileTileState extends State<UserProfileTile> {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16), // Spacing between icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName, // Display dynamic username
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .apply(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail, // Display dynamic email
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .apply(color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
