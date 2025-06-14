import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:food/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'all_reviews.dart';

class ReviewAndFeedbackScreen extends StatefulWidget {
  @override
  _ReviewAndFeedbackScreenState createState() => _ReviewAndFeedbackScreenState();
}

class _ReviewAndFeedbackScreenState extends State<ReviewAndFeedbackScreen> {
  double _rating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String userName = "User";
  String userEmail = "example@email.com";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          color: rating >= index + 1
              ? AppColors.themeColor
              : AppColors.greycolor,
          size: 20,
        );
      }),
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "User";
      userEmail = prefs.getString('id') ?? "example@email.com";
    });
  }


  String _timeAgo(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: Text(
          'Review & Feedback',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.themeColor,
                  child: Icon(
                    CupertinoIcons.bubble_left_bubble_right,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Rate your experience:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.blackColor,
                ),
              ),
              Row(
                children: List.generate(5, (index) => _buildStarIcon(index + 1)),
              ),
              SizedBox(height: 20),
              Text(
                'Your Feedback:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Write your feedback here...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide your feedback.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.themeColor,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a rating.')),
                        );
                      } else {
                        String formattedDate = DateFormat('ddMMyy_HH.mm').format(DateTime.now());
                        String docId = "${userName}_$formattedDate";


                        await FirebaseFirestore.instance
                            .collection('review')
                            .doc(docId)
                            .set({
                          'userName': userName,
                          'userEmail': userEmail,
                          'rating': '$_rating/5.0',
                          'feedback': _feedbackController.text,
                          'timestamp': DateTime.now(),
                        });

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.pencil_ellipsis_rectangle,
                                  color: AppColors.themeColor,
                                  size: 40,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Thank You For Your Feedback",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start, // Align text to left
                              children: [
                                Text(
                                  'Rating: $_rating/5.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkerGrey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Divider(),
                                SizedBox(height: 4),
                                Text(
                                  'Feedback: ${_feedbackController.text}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkerGrey,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.themeColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _rating = 0.0;
                                        _feedbackController.clear();
                                      });
                                    },
                                    child: Text(
                                      "OK",
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )

                        );
                      }
                    }
                  },
                  child: Text(
                    'Submit Feedback',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Recent Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('review')
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error fetching reviews.");
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text("No reviews yet.");
                  }

                  final reviews = snapshot.data!.docs;

                  return SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 1),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          elevation: 1.5,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.themeColor,
                                        radius: 12,
                                        child: Text(
                                          review['userName'][0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold, fontSize: 14
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(review['userName'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Spacer(), // pushes the next widget to the right end
                                      Text(
                                        _timeAgo(review['timestamp']),
                                        style: TextStyle(
                                          color: AppColors.greycolor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStarRating(
                                        double.tryParse(review['rating'].toString().split('/').first) ?? 0.0,
                                      ),
                                      SizedBox(width:8),
                                      Text(
                                        "${review['rating'].split('/').first.split('.')[0]}/5",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black54,
                                        ),
                                      ),

                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(review['feedback'],),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllReviewsScreen()),
                    );
                  },
                  child: Text(
                    'View All Reviews',
                    style: TextStyle(
                      color: AppColors.themeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarIcon(int starIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _rating = starIndex.toDouble();
        });
      },
      child: Icon(
        Icons.star,
        color: _rating >= starIndex ? AppColors.themeColor : AppColors.greycolor,
        size: 30,
      ),
    );
  }
}
