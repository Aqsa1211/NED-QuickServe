import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "../utils/colors.dart";

class AppSettingsMenuTile extends StatelessWidget {
  const AppSettingsMenuTile({super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.buttonTitle = CupertinoIcons.forward , this.onPressed, this.showActionButton = true
  });

  final IconData icon;
  final String title,subtitle;
  final IconData? buttonTitle;
  final Widget? trailing;
  final bool showActionButton;
  final void Function()? onPressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,size: 28,color: AppColors.themeColor),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (showActionButton)
            TextButton(onPressed: onPressed, child: Icon(buttonTitle)),
        ],
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
      trailing: trailing,
      onTap: onTap,
    );
  }
}