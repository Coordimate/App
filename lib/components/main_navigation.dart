import 'package:flutter/material.dart';
import 'package:coordimate/components/colors.dart';

class BottomIcons extends StatefulWidget {
  @override
  _BottomIconsState createState() => _BottomIconsState();
}

class _BottomIconsState extends State<BottomIcons> {
  bool _isPersonButtonPressed = false;
  bool _isLockButtonPressed = false;
  bool _isEmailButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTapDown: (_) {
              setState(() {
                _isPersonButtonPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isPersonButtonPressed = false;
              });
            },
            onTapCancel: () {
              setState(() {
                _isPersonButtonPressed = false;
              });
            },
            onTap: () {
              // Implement action for the first button
            },
            child: Container(
              color: _isPersonButtonPressed ? Colors.grey[300] : Colors.white,
              child: Image.asset(
                'lib/images/person.png',
                height: 50,
                width: 50,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTapDown: (_) {
              setState(() {
                _isLockButtonPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isLockButtonPressed = false;
              });
            },
            onTapCancel: () {
              setState(() {
                _isLockButtonPressed = false;
              });
            },
            onTap: () {
              // Implement action for the second button
            },
            child: Container(
              color: _isLockButtonPressed ? Colors.grey[300] : Colors.white,
              child: Image.asset(
                'lib/images/lock.png',
                height: 50,
                width: 50,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTapDown: (_) {
              setState(() {
                _isEmailButtonPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isEmailButtonPressed = false;
              });
            },
            onTapCancel: () {
              setState(() {
                _isEmailButtonPressed = false;
              });
            },
            onTap: () {
              // Implement action for the third button
            },
            child: Container(
              color: _isEmailButtonPressed ? Colors.grey[300] : Colors.white,
              child: Image.asset(
                'lib/images/email.png',
                height: 50,
                width: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
