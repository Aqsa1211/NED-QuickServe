import 'package:flutter/material.dart';
class CustomTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final bool isPass;
  final bool passwordvisibility;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double borderRadius;
  final Color? fillColor;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validation;

  const CustomTextField({
    Key? key,
    this.hint,
    this.controller,
    this.textInputType,
    this.maxLines = 1,
    this.textInputAction,
    this.isPass = false,
    this.passwordvisibility = false,
    this.textStyle,
    this.hintStyle,
    this.borderRadius = 8.0,
    this.fillColor = Colors.white,
    this.suffixIcon,
    this.onChanged,
    this.validation,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      maxLines: maxLines,
      textInputAction: textInputAction,
      obscureText: isPass && !passwordvisibility,
      style: textStyle ?? TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: hintStyle ?? TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
      validator: validation,
    );
  }
}