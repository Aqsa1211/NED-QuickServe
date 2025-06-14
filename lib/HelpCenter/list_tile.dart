import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

import "../utils/colors.dart";

class listTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String quantity;
  final VoidCallback onTap;

  const listTile({
    required this.icon,
    required this.text,
    required this.quantity,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.themeColor, size:50),
      title: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(quantity),
      trailing: Icon(Icons.arrow_forward_ios, color: AppColors.darkerGrey),
      onTap: onTap,
    );
  }
}