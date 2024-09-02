import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  final Color textColor;
  final bool stripes;
  final Color dashColor;

  const CustomDivider({
    super.key,
    required this.text,
    this.textColor = darkBlue,
    this.stripes = true,
    this.dashColor = darkBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: stripes
              ? Divider(
                  thickness: 1,
                  color: dashColor,
                )
              : const Divider(
                  thickness: 1,
                  color: Colors.transparent,
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
            ),
          ),
        ),
        Expanded(
          child: stripes
              ? Divider(
                  thickness: 1,
                  color: dashColor,
                )
              : const Divider(
                  thickness: 1,
                  color: Colors.transparent,
                ),
        ),
      ],
    );
  }
}
