import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'circular_container.dart';
import 'curved_edges_widget.dart';

class PrimaryHeaderContainer extends StatelessWidget {
  const PrimaryHeaderContainer({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CurvedEdgeWidget(
      child: Container(
        color: AppColors.themeColor,
        padding: const EdgeInsets.only(bottom: 20),

        child: Stack(
          children: [
            Positioned(top:-150, right:-250, child: CircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.1))),
            Positioned(top:100, right:-300, child: CircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.1))),
            child,
          ],
          ),
        )
    );

  }
}