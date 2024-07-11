import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool needButton;
  final IconData buttonIcon;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.needButton,
    this.buttonIcon = Icons.add_circle_outline_rounded,
    this.onPressed = defaultOnPressed,
    this.leading,
  });

  static void defaultOnPressed() {}

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      title: Text(title,
          style: const TextStyle(
              color: darkBlue, fontSize: 34, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: needButton
          ? <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Icon(buttonIcon, color: darkBlue, size: 40),
                  onPressed: onPressed,
                ),
              ),
            ]
          : null,
    );
  }
}
