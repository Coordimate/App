import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onPressed;
  final bool needCreateButton;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.needCreateButton,
    this.onPressed = defaultOnPressed,
  });

  static void defaultOnPressed() {}

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: const TextStyle(
              color: darkBlue,
              fontSize: 34,
              fontWeight: FontWeight.bold)
      ),
      centerTitle: true,
      actions: needCreateButton ?
      <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: darkBlue,
                size: 40
            ),
            onPressed: onPressed,
          ),
        ),
      ] : null,
    );
  }
}