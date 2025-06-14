import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food/review.dart';
import 'package:food/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class AllReviewsScreen extends StatelessWidget {
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

  String _formatDateTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  String _timeAgo(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return timeago.format(dateTime);
  }

  Map<int, int> _calculateRatingDistribution(List<QueryDocumentSnapshot> reviews) {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var review in reviews) {
      final ratingString = review['rating'] as String;
      final rating = double.tryParse(ratingString.split('/')[0])?.round() ?? 0;
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = distribution[rating]! + 1;
      }
    }
    return distribution;
  }
  Widget _buildRatingBars(Map<int, int> distribution, int totalReviews) {
    const double barWidth = 80.0; // adjust as needed

    return Column(
      children: List.generate(5, (index) {
        int star = 5 - index;
        int count = distribution[star] ?? 0;
        double percent = totalReviews == 0 ? 0 : (count / totalReviews);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  "$star.0",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Icon(Icons.star, size: 16, color: AppColors.themeColor),
              SizedBox(width: 8),
              Container(
                width: barWidth,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.greycolor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.themeColor,
                        borderRadius: BorderRadius.circular(10), // This makes the filled portion rounded
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                "$count review${count == 1 ? '' : 's'}",
                style: TextStyle(color: AppColors.greycolor),
              ),
            ],
          ),
        );
      }),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        title: Text('All Reviews', style: TextStyle(color: AppColors.whiteColor)),
        iconTheme: IconThemeData(color: AppColors.whiteColor),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('review')
            .orderBy('timestamp', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading reviews."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No reviews found."));
          }

          final reviews = snapshot.data!.docs;
          // Calculate average rating
          double totalRating = 0.0;
          for (var review in reviews) {
            final ratingString = review['rating'] as String;
            final rating = double.tryParse(ratingString.split('/')[0]) ?? 0.0;
            totalRating += rating;
          }
          final avgRating = totalRating / reviews.length;
          final ratingDistribution = _calculateRatingDistribution(reviews);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rating Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Average Rating Section
                        Column(
                          children: [
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.themeColor,
                              ),
                            ),
                            _buildStarRating(avgRating),
                            SizedBox(height: 8),
                            Text(
                              "${reviews.length} reviews",
                              style: TextStyle(color: AppColors.greycolor),
                            ),
                          ],
                        ),

                        SizedBox(width: 24),

                        // Rating Breakdown Bars
                        Expanded(
                          child: _buildRatingBars(ratingDistribution, reviews.length),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${reviews.length} Reviews",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReviewAndFeedbackScreen()),
                            );
                          },
                          icon: Icon(Icons.edit, color: AppColors.themeColor),
                          label: Text(
                            "Write a review",
                            style: TextStyle(color: AppColors.themeColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


              Expanded(
                child: ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final ratingString = review['rating'] as String;
                    final rating = double.tryParse(ratingString.split('/')[0]) ?? 0.0;
                    final timestamp = review['timestamp'] as Timestamp;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 1.5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.themeColor,
                                  radius: 20,
                                  child: Text(
                                    review['userName'][0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10), // space between avatar and name
                                Text(
                                  review['userName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                                Spacer(), // pushes the next widget to the right end
                                Text(
                                  _timeAgo(timestamp),
                                  style: TextStyle(
                                    color: AppColors.greycolor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),
                            Row(
                              children: [
                                _buildStarRating(rating),
                                SizedBox(width: 4,),
                                Text(
                                  "${rating.toInt()}/5",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.greycolor,
                                    fontSize: 14,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  _formatDateTime(timestamp),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.greycolor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),
                            Text(
                              review['feedback'],
                              style: TextStyle(color: AppColors.blackColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
