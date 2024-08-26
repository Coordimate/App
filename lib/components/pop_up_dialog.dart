import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class CustomPopUpDialog extends StatelessWidget {
  final String question;
  final VoidCallback onYes;
  final VoidCallback onNo;

  const CustomPopUpDialog({
    super.key,
    required this.question,
    this.onYes = _defaultFunc,
    this.onNo = _defaultFunc,
  });

  static void _defaultFunc() {}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
        ),
      ),
      actions: <Widget>[
        ConfirmationButtons(onYes: onYes, onNo: onNo),
      ],
    );
  }
}

class ConfirmationButtons extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;
  final String yes;
  final String no;

  const ConfirmationButtons({
    super.key,
    required this.onYes,
    required this.onNo,
    this.yes = "Yes",
    this.no = "No",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            onPressed: onNo,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              elevation: WidgetStateProperty.all(0),
              side: WidgetStateProperty.all(const BorderSide(color: mediumBlue, width: 3)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Text(
                no,
                style: const TextStyle(
                    color: mediumBlue, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onYes,
            style: ButtonStyle(
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(mediumBlue),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Text(
                yes,
                style:const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),

      ],
    );
  }
}