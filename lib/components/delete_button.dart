import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class DeleteButton extends StatelessWidget {
  final String itemToDelete;
  final VoidCallback showDeleteDialog;
  final Color color;

  const DeleteButton({
    super.key,
    required this.itemToDelete,
    required this.showDeleteDialog,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: showDeleteDialog,
        child: Text(
          'Delete $itemToDelete',
          style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        )
    );
  }
}