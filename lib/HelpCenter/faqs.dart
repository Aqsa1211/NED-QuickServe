import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'QnAPage.dart';

class FAQs extends StatelessWidget {
  final Color colors;
  final String text;
  final IconData icon;

  const FAQs({
    super.key,
    required this.text,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to QnAPage and pass data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QnAPage(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          height: 230,
          width: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF800000),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: colors,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  alignment: const Alignment(0.9, 0),
                  child: Icon(
                    icon,
                    color: AppColors.white,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}