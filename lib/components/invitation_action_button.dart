import 'package:flutter/material.dart';

class InvitationActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final String iconPath;

  const InvitationActionButton({
    super.key,
    required this.onPressed,
    required this.color,
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
        icon: Image.asset(iconPath),
        onPressed: onPressed,
      ),
    );
  }
}