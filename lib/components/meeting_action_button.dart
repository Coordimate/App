import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  // final IconData icon;
  final String iconPath;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.color,
    // required this.icon,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        // icon: Icon(icon, color: darkBlue),
        icon: Image.asset(iconPath),
        onPressed: onPressed,
      ),
    );
  }
}