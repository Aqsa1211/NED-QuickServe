import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food/history.dart';
import 'package:food/profile/settings_menu_tile.dart';
import 'package:food/profile/user_profile_tile.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../utils/constant.dart';
import '../utils/sizes.dart';
import '../containers/primary_header_container.dart';
import 'section_heading.dart';
import '../utils/colors.dart';
import '../HelpCenter/help_center.dart';
import '../legal_doc.dart';
import '../review.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // var name = '';
  // var email = '';
  // bool isLoading = true;
  // getData() async {
  //   isLoading = true;
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   name = sharedPreferences.getString('name')!;
  //   email = sharedPreferences.getString('id')!;
  //   isLoading = false;
  // }
  //
  // @override
  // void initState() {
  //   getData();
  //
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
              child: Column(
                children: [
                  PrimaryHeaderContainer(
                    child: Column(
                      children: [
                        AppBar(
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back_ios,
                                color: AppColors.whiteColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                          backgroundColor: AppColors.transparentcolor,
                          title: Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const UserProfileTile(),
                        const SizedBox(height: AppSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.defaultSpace),
                    child: Column(
                      children: [
                        const SectionHeading(
                          title: 'User Details',
                          showActionButton: false,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        AppSettingsMenuTile(
                          icon: CupertinoIcons.home,
                          title: 'My Location',
                          subtitle: Constants.locationString == ''
                              ? 'Set Default Delivery Address'
                              : Constants.locationString,
                        ),
                        AppSettingsMenuTile(
                          icon: Iconsax.bag_tick,
                          title: 'My Orders',
                          subtitle: 'In-progress and Completed Orders',
                          onTap: () {
                            // Your action goes here
                            // For example, navigate to the HelpCenterScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderHistory()),
                            );
                          },
                        ),

                        const SizedBox(height: AppSizes.spaceBtwItems),
                        const SectionHeading(
                          title: 'General',
                          showActionButton: false,
                        ),
                        AppSettingsMenuTile(
                          icon: CupertinoIcons.question_circle,
                          title: 'Help Center',
                          subtitle: 'Get Answers to all your FAQs',
                          onTap: () {
                            // Your action goes here
                            // For example, navigate to the HelpCenterScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HelpCenter()),
                            );
                          },
                        ),
                        AppSettingsMenuTile(
                          icon: CupertinoIcons.doc_text,
                          title: 'Terms & Policies',
                          subtitle: 'Read our Terms & Conditions',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LegalDocumentsPage()),
                            );
                          },
                        ),
                        AppSettingsMenuTile(
                            icon: CupertinoIcons.hand_thumbsup,
                            title: 'Feedback & Review',
                            subtitle: 'Leave us a Review',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ReviewAndFeedbackScreen()),
                              );
                            }),
                        const SectionHeading(
                          title: 'App Settings',
                          showActionButton: false,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwItems),
                        AppSettingsMenuTile(
                          icon: CupertinoIcons.moon_stars,
                          title: 'Notifications',
                          subtitle: 'Allow notifications to pop up',
                          showActionButton: false,
                          trailing: Switch(value: false, onChanged: (value) {}),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
