// To parse this JSON data, do
//
//     final reviewModel = reviewModelFromJson(jsonString);

import 'dart:convert';

ReviewModel reviewModelFromJson(String str) => ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
  bool? success;
  Review? review;
  String? message;

  ReviewModel({
    this.success,
    this.review,
    this.message,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    success: json["success"],
    review: Review.fromJson(json["review"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "review": review!.toJson(),
    "message": message,
  };
}

class Review {
  String? firebaseId;
  String? rating;
  String? feedback;
  int? id;

  Review({
    this.firebaseId,
    this.rating,
    this.feedback,

    this.id,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    firebaseId: json["firebase_id"],
    rating: json["rating"],
    feedback: json["feedback"],

    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "firebase_id": firebaseId,
    "rating": rating,
    "feedback": feedback,
    "id": id,
  };
}