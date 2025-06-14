// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:internet_connection_checker/internet_connection_checker.dart';
//
// import '../URLS.dart';
// import '../custom_snackbar.dart';
//
// class APIService {
//   static var client = http.Client();
//
//   static Future<String?> postRequest(
//       {required String apiName,
//         required bool isJson,
//         required Map<String, dynamic> mapData,
//         Map<String, String>? headers,
//         bool? isAuth})
//   async {
//     /// check_internet
//     bool result = await InternetConnectionChecker().hasConnection;
//     // var connectivityResult = await (Connectivity().checkConnectivity());
//     if (!result) {
//       customSnack(
//           isSuccess: false,
//           message: "No internet connection, Please connect to internet.".tr);
//       return null;
//     }
//     headers ??= {};
//     // try {
//     /// post Request
//     var response = await client
//         .post(Uri.parse(Urls.BASE_URL + apiName),
//         body: isJson ? json.encode(mapData) : mapData, headers: headers)
//         .timeout(const Duration(seconds: 60));
//
//     /// print response
//     if (kDebugMode) {
//       debugPrint(
//           "headers:$headers: body:$mapData:api:${Urls.BASE_URL + apiName} :response:${response.body}",
//           wrapWidth: 1024);
//     }
//     var statusCode = response.statusCode;
//     if (kDebugMode) {
//       print('statusCode:$statusCode');
//     }
//
//     /// check response
//     switch (statusCode) {
//       case HttpStatus.ok:
//         var jsonString = response.body;
//         return jsonString;
//
//       case HttpStatus.unauthorized:
//         var jsonString = response.body;
//
//         return jsonString;
//       case HttpStatus.created:
//         var jsonString = response.body;
//         return jsonString;
//
//       case HttpStatus.notFound:
//         var jsonString = response.body;
//
//         return jsonString;
//
//       case HttpStatus.found:
//         var jsonString = response.body;
//
//         return jsonString;
//
//       case HttpStatus.badRequest:
//         var jsonString = response.body;
//
//         return jsonString;
//
//       case HttpStatus.gatewayTimeout:
//         customSnack(
//             isSuccess: false,
//             message: "No response from the server, Please try again".tr);
//         return null;
//
//       default:
//         customSnack(
//             isSuccess: false,
//             message: "No response from the server, Please try again".tr);
//         return null;
//     }
//     // } catch (e) {
//     //   if (kDebugMode) print("api error:$e");
//     //   customSnack(
//     //       isSuccess: false,
//     //       message: "No response from the server, Please try again".tr);
//     //
//     //   return null;
//     // }
//   }
//
//
//   static Future<String?> getRequest(
//       {required String apiName,
//         Map<String, String>? headers,
//         bool? isAuth})
//   async {
//     try {
//       /// check_internet
//       bool result = await InternetConnectionChecker().hasConnection;
//       if (!result) {
//         customSnack(
//             isSuccess: false,
//             message: "No internet connection, Please connect to internet.".tr);
//         return null;
//       }
//
//       headers ??= {
//         "Accept": "application/json",
//         "Content-Type": "application/x-www-form-urlencoded"
//       };
//
//       /// get request
//       var response = await http
//           .get(Uri.parse(Urls.BASE_URL + apiName), headers: headers)
//           .timeout(const Duration(seconds: 60));
//
//       /// print response
//       if (kDebugMode) {
//         debugPrint(
//             "header:$headers:api:${Urls.BASE_URL + apiName}:response:${response.body}",
//             wrapWidth: 1024);
//       }
//       var statusCode = response.statusCode;
//
//       /// check response
//       switch (statusCode) {
//         case HttpStatus.ok:
//           var jsonString = response.body;
//           return jsonString;
//
//         case HttpStatus.gatewayTimeout:
//           customSnack(
//               isSuccess: false,
//               message: "No response from the server, Please try again".tr);
//           return null;
//
//         case HttpStatus.notFound:
//           var jsonString = response.body;
//           if (kDebugMode) debugPrint(jsonString, wrapWidth: 1024);
//           return jsonString;
//
//         case HttpStatus.unauthorized:
//           var jsonString = response.body;
//           if (kDebugMode) debugPrint(jsonString, wrapWidth: 1024);
//           return jsonString;
//
//         default:
//           customSnack(
//               isSuccess: false,
//               message: "No response from the server, Please try again".tr);
//           return null;
//       }
//     } catch (e) {
//       if (kDebugMode)
//         print('No response from the server, Please try again: $e');
//       customSnack(
//           isSuccess: false,
//           message: "No response from the server, Please try again".tr);
//       return null;
//     }
//   }
//
// }