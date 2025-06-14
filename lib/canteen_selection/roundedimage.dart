import 'package:flutter/material.dart';
import '../../utils/sizes.dart';

class RoundedImage extends StatelessWidget {
  const RoundedImage({
    super.key,
    this.width,
    this.height,
    required this.imageUrl,
    this.applyImageRadius = true,
    this.border,
    this.backgroundColor,
    this.fit = BoxFit.cover, // Changed to cover for a better fit
    this.padding,
    this.isNetworkImage = false,
    this.onPressed,
    this.borderRadius = AppSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: applyImageRadius
            ? BorderRadius.circular(borderRadius)
            : BorderRadius.zero,
        child: Container(
          width: width,
          height: height,
          padding: padding,
          color: backgroundColor ?? Colors.transparent,
          child: isNetworkImage
              ? Image.network(
            imageUrl,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error),
          )
              : Image.asset(
            imageUrl,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}