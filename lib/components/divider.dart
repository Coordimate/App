import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class CustomDivider extends StatelessWidget {
  final String text;
  final Color textColor; // Optional field for text color
  final bool stripes; // Optional field for stripes
  final Color dashColor; // Optional field for dash color

  const CustomDivider({
    super.key,
    required this.text,
    this.textColor = darkBlue, // Default to darkBlue
    this.stripes = true, // Default to false
    this.dashColor = darkBlue, // Default to darkBlue
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
                  color: Colors
                      .transparent, // Invisible line when stripes is false
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Text(
            text,
            style: TextStyle(
              color: textColor, // Use the textColor parameter
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
                  color: Colors
                      .transparent, // Invisible line when stripes is false
                ),
        ),
      ],
    );
  }
}
