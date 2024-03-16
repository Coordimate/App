import 'package:coordimate/components/colors.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final Function()? onTap;

  const LoginButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: darkBlue,
          border: Border.all(color: darkBlue, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                // fontWeight: FontWeight.bold,
                fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class LoginEmptyButton extends LoginButton {
  const LoginEmptyButton(
      {super.key, required super.text, required super.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          border: Border.all(color: darkBlue, width: 3), // Dark blue border
          borderRadius: BorderRadius.circular(10),
          color: Colors.white, // White fill color
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: darkBlue, // Dark blue text color
              // fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
