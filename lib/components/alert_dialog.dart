import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  // final VoidCallback onOkPressed;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    // required this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text(title,  style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Text(content, style: const TextStyle(color: darkBlue))),
          TextButton(
            child: const Text('OK', style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold, fontSize: 20)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}