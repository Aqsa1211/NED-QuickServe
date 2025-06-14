import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:food/canteen_selection/roundedimage.dart';
import 'package:get/get.dart';
import '../containers/circular_container.dart';
import '../utils/colors.dart';
import '../utils/sizes.dart';
import 'home_controller.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.banners,
    required this.onTapActions, // List of actions for each banner
  });

  final List<String> banners;
  final List<VoidCallback> onTapActions; // Each banner has a specific action

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    // Ensure banners and actions lists have the same length
    assert(banners.length == onTapActions.length, "Banners and onTapActions lists must be of equal length");

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          child: FlutterCarousel(
            options: FlutterCarouselOptions(
              enlargeCenterPage: true,
              aspectRatio: 2,
              viewportFraction: 0.95,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              showIndicator: false,
              onPageChanged: (index, _) => controller.updatePageIndicator(index),
            ),
            items: List.generate(banners.length, (index) {
              return GestureDetector(
                onTap: onTapActions[index], // Execute the specific action
                child: RoundedImage(imageUrl: banners[index]),
              );
            }),
          ),
        ),
        Center(
          child: Obx(
                () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < banners.length; i++)
                  CircularContainer(
                    width: 20,
                    height: 4,
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor: controller.carousalCurrentIndex.value == i
                        ? AppColors.themeColor
                        : AppColors.grey,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

