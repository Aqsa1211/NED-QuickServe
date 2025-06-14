import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../device/device_utility.dart';


class Appbar extends StatelessWidget implements PreferredSizeWidget {
  const Appbar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: showBackArrow
          ? IconButton(onPressed: () => Get.back(), icon: const Icon(Iconsax.arrow_left))
          : leadingIcon != null
          ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
          : null,
      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(DeviceUtils.getAppBarHeight());
}
