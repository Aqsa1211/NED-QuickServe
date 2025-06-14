// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:food/Model/review.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../URLs.dart';
// import '../api_service.dart';
//
// class ReviewController extends GetxController {
//   var isLoading = false.obs;
//   var reviewModel = ReviewModel().obs;
//
//   storeReviewApi(
//       {required BuildContext context,
//         required String rating,
//         required String comment})
//   async {
//     isLoading(false);
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     var m = sharedPreferences.getString('id');
//
//     Map<String, String> mapData = {};
//
//     mapData['firebase_id'] = m.toString();
//
//     mapData['feedback'] = comment;
//     mapData['rating'] =( rating.toString()) ;
//
//     var details = await APIService.postRequest(
//         apiName: Urls.reviewUrl, isJson: false, mapData: mapData);
//
//     if (details != null) {
//       reviewModel.value = reviewModelFromJson(details);
//       try {
//         isLoading(false);
//       } catch (e) {
//         if (kDebugMode) print(e);
//         isLoading(false);
//       }
//     } else {
//       isLoading(false);
//     }
//   }
// }