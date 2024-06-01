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
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onYes();
                  },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(mediumBlue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text("Yes",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onNo();
                  },
                style: ButtonStyle(
                  side: MaterialStateProperty.all(const BorderSide(color: mediumBlue, width: 3)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: const Text("No",
                    style: TextStyle(color: mediumBlue, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}