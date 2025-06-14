// import 'package:flutter/material.dart';
//
// class CustomToast extends StatefulWidget {
//   final String msg;
//
//   const CustomToast({Key? key, required this.msg}) : super(key: key);
//
//   @override
//   State<CustomToast> createState() => _CustomToastState();
// }
//
// class _CustomToastState extends State<CustomToast> {
//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     return Card(
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Container(
//         // height: 50,
//         width: width,
//         padding:
//         const EdgeInsets.only(left: 20, right: 20, top: 13, bottom: 13),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // SvgPicture.asset('${Images.localIconsPath}${Images.app_logo}',width: 40,height: 40,fit: BoxFit.fill,),
//             // Expanded(
//             //   child: Padding(
//             //     padding: const EdgeInsets.only(left: 13,right: 13),
//             //     child: Text(widget.msg,maxLines:4,style: CustomTextStyles.l13BOLD_WHITE,),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }