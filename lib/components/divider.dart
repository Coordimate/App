import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class CustomDivider extends StatelessWidget {
  final String text;

  const CustomDivider({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: darkBlue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            text,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 24,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: darkBlue,
          ),
        ),
      ],
    );
  }
}