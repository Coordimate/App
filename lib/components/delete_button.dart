import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final String str;
  final VoidCallback showDeleteDialog;
  final Color color;

  const DeleteButton({
    super.key,
    required this.str,
    required this.showDeleteDialog,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: showDeleteDialog,
        child: Text(
          str,
          style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        )
    );
  }
}